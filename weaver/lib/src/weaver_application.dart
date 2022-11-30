import 'package:args/args.dart';
import 'package:box/box.dart';
import 'package:box/mongodb.dart';
import 'package:controller/controller.dart';
import 'package:dio/dio.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:fabric_weaver/src/weaver_config.dart';
import 'package:fabric_weaver/src/weaver_server.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final Logger log = Logger('weaver_application');
final ArgParser argumentParser = ArgParser()
  ..addOption('env', abbr: 'e', defaultsTo: '');

class WeaverApplication {
  final Fabric fabric;
  final Map<Spec, Factory> factories;
  final String configDir;
  final List<String> arguments;

  WeaverApplication(
    this.fabric, {
    this.factories = const {},
    required this.configDir,
    this.arguments = const [],
  }) {
    _configureDefaults();
    _configureLogging();
    _parseArguments();
  }

  Future start() async {
    var environment = fabric.getString('env');
    log.info(
        'Starting application for environment ${environment.isNotEmpty ? environment : 'default'}');
    var config = <String, String>{};
    if (environment.isNotEmpty) {
      config = loadConfig(configDir, '');
    }
    config.addAll(loadConfig(configDir, environment));
    fabric.registerConfigMap(config);
    fabric.registerInstance(fabric);
    fabric.registerInstance(Dio());
    for (var entry in factories.entries) {
      fabric.register(entry.key, entry.value);
    }
    _configureBox();
    _startHttpServer();
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
      WeaverServer(
        handler: handler,
        port: fabric.getInt('server.port'),
      ).start();
    }
  }

  Handler _createRequestHandler(List<DispatcherBuilder> dispatcherBuilders) {
    var dispatcher = createRequestDispatcher(
      dispatcherBuilders,
      corsEnabled: true,
    );
    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(dispatcher);
    return handler;
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  void _configureLogging() {
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void _parseArguments() {
    var results = argumentParser.parse(arguments);
    fabric.registerConfig('env', results['env']);
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
}
