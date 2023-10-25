import 'dart:async';
import 'dart:developer';

import 'package:args/args.dart';
import 'package:box/box.dart';
import 'package:box/mongodb.dart';
import 'package:cipher_string/cipher_string.dart';
import 'package:controller/controller.dart';
import 'package:dio/dio.dart' show Dio;
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:fabric_weaver/src/config.dart';
import 'package:fabric_weaver/src/server/shelf.dart';
import 'package:hotreloader/hotreloader.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:shutdown/shutdown.dart';

import 'logging/google_cloud_logging.dart';
import 'server/google_cloud_functions.dart';

final Logger log = Logger('weaver_application');
final ArgParser argumentParser = ArgParser()
  ..addOption('env', abbr: 'e', defaultsTo: '')
  ..addOption('secrets', abbr: 's', defaultsTo: '.secrets');

class WeaverApplication {
  final Fabric fabric;
  final Map<Spec, Factory> factories;
  final String configDir;
  final List<String> arguments;
  final HotReloader? reloader;

  WeaverApplication(
    this.fabric, {
    this.factories = const {},
    required this.configDir,
    this.arguments = const [],
    this.reloader,
  }) {
    _configureDefaults();
    _parseArguments();
    _registerShutdownHook();
  }

  Future start() async {
    _configureFabric();
    _configureLogging();
    _configureBox();
    _configureSecurity();
    _configureCipher();
    _startHttpServer();
  }

  void _configureFabric() {
    var environment = fabric.getString('env');
    var secretsPath = fabric.getString('secrets');
    log.info(
        'Starting application for environment ${environment.isNotEmpty ? environment : 'default'}');
    var config = <String, String>{};
    if (environment.isNotEmpty) {
      config = loadConfig(configDir, '', secretsPath);
    }
    config.addAll(loadConfig(configDir, environment, secretsPath));
    fabric.registerConfigMap(config);
    fabric.registerInstance(fabric);
    fabric.registerInstance(Dio());
    for (var entry in factories.entries) {
      fabric.register(entry.key, entry.value);
    }
  }

  void _startHttpServer() {
    var handlers = fabric.getInstances<Handler>();
    var dispatcherBuilders = fabric.getInstances<DispatcherBuilder>();
    var handler = handlers.length == 1
        ? handlers.first
        : (dispatcherBuilders.isNotEmpty
            ? _createRequestHandler(dispatcherBuilders.toList())
            : null);
    if (handler != null) {
      fabric.registerInstance(RequestHandler(handler));
      final httpEnabled = fabric.getBool('server.enabled', defaultValue: true);
      if (httpEnabled) {
        final serverType =
            fabric.getString('server.type', defaultValue: 'shelf');
        switch (serverType) {
          case 'shelf':
            ShelfWeaverServer(
              handler: handler,
              port: fabric.getInt('server.port'),
            ).start();
            break;
          case 'google-cloud-functions':
            GoogleCloudFunctionsServer(
              handler: handler,
              port: fabric.getInt('server.port'),
            ).start();
            break;
          default:
            throw ArgumentError('Unknown server type: $serverType. '
                'Known types are shelf and google-cloud-functions');
        }
      }
    }
  }

  Handler _createRequestHandler(List<DispatcherBuilder> dispatcherBuilders) {
    var dispatcher = createRequestDispatcher(dispatcherBuilders,
        corsEnabled: fabric.getBool('server.cors.enabled', defaultValue: false),
        allowedOrigins: fabric.getString(
          'server.cors.allowed-origins',
          defaultValue: '',
        ),
        defaultHandler: proxyHandler('http://localhost:8081'));
    final logEnabled = fabric.getBool(
      'server.log-requests',
      defaultValue: true,
    );
    final serverType = fabric.getString('server.type', defaultValue: 'shelf');
    var pipeline =
        Pipeline().addMiddleware((innerHandler) => (request) => runZoned(
              () => innerHandler(request),
              zoneValues: {#logging: <String, String>{}},
            ));
    if (logEnabled && serverType == 'shelf') {
      pipeline = pipeline.addMiddleware(logRequests());
    }
    var handler = pipeline.addHandler(dispatcher);
    return handler;
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  void _configureLogging() {
    final googleCloudLoggingEnabled = fabric.getBool(
      'google-cloud.logging.enabled',
      defaultValue: false,
    );
    hierarchicalLoggingEnabled = true;
    if (googleCloudLoggingEnabled) {
      configureGoogleCloudLogging();
    } else {
      Logger.root.onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
    }
    Logger('HttpUtils').level = Level.WARNING;
    Logger('dns_lookup').level = Level.WARNING;
  }

  void _parseArguments() {
    var results = argumentParser.parse(arguments);
    fabric.registerConfig('env', results['env']);
    fabric.registerConfig('secrets', results['secrets']);
  }

  void _configureBox() {
    var type = fabric.getString('box.type', defaultValue: '');
    switch (type) {
      case 'memory':
        fabric.registerFactory<Box>(
          (fabric) => MemoryBox(fabric.getInstance()),
        );
        break;
      case 'file':
        fabric.registerFactory<Box>(
          (fabric) =>
              FileBox(fabric.getString('box.file.path'), fabric.getInstance()),
        );
        break;
      case 'mongodb':
        fabric.registerFactory<Box>((fabric) => MongoDbBox(
            fabric.getString('box.mongodb.connection'), fabric.getInstance()));
        break;
      default:
        if (type.isNotEmpty) {
          throw ArgumentError('Unsupported box type: $type');
        }
    }
  }

  void _configureSecurity() {
    final issuerUri = fabric.getString('security.issuer-uri', defaultValue: '');
    if (issuerUri.isNotEmpty) {
      fabric.registerInstance<Security>(JwtSecurity(
        issuerUri: Uri.parse(issuerUri),
        clientId: fabric.getString('security.client-id'),
      ));
    }
  }

  void _configureCipher() {
    final cipherKey = fabric.getString('cipher.key', defaultValue: '');
    final decryptionEnabled =
        fabric.getBool('cipher.decrypt', defaultValue: false);
    if (cipherKey.isNotEmpty) {
      cipher = Cipher(cipherKey, decryptionEnabled: decryptionEnabled);
    }
  }

  void _registerShutdownHook() {
    addHandler(() => reloader?.stop());
  }
}

class RequestHandler {
  final Handler _handler;

  RequestHandler(this._handler);

  FutureOr<Response> handle(Request request) => _handler(request);
}

Future<HotReloader?> enableHotReload() async {
  if ((await Service.getInfo()).serverUri == null) {
    print('ℹ️ Hot reload is not enabled, run with VM option '
        '--enable-vm-service to enable');
    return null;
  } else {
    print('🔥 Hot reload is enabled, application will reload automatically '
        'after sources have been changed');
  }
  return await HotReloader.create();
}
