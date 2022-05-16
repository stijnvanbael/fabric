import 'dart:io';

import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:yaml/yaml.dart';

final Logger log = Logger('weaver');

class WeaverApplication {
  final Fabric fabric;
  final Factory<Box>? databaseFactory;
  final String configDir;

  WeaverApplication(
    this.fabric, {
    this.databaseFactory,
    required this.configDir,
  }) {
    _configureDefaults();
  }

  Future start() async {
    _configureLogging();
    log.info('Starting application');
    _loadConfig();
    if (databaseFactory != null) {
      fabric.registerFactory(databaseFactory!);
    }
    var handler = _createRequestHandler();

    var server = await serve(handler, '0.0.0.0', fabric.getInt('server.port'));
    log.info('Serving at http://${server.address.host}:${server.port}');
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  void _loadConfig() {
    log.fine('Loading config.yaml');
    var configFile = File('$configDir/config.yaml');
    if (configFile.existsSync()) {
      log.fine('config.yaml found');
      var contents = configFile.readAsStringSync();
      var yaml = loadYaml(contents);
      var flattened = _flatten(yaml, '');
      log.fine('Config: $flattened');
      fabric.registerConfigMap(flattened);
    } else {
      log.fine('config.yaml not found');
    }
  }

  Handler _createRequestHandler() {
    var dispatcher = createRequestDispatcher(
      fabric.getInstances<DispatcherBuilder>().toList(),
      corsEnabled: true,
    );
    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(dispatcher);
    return handler;
  }

  void _configureLogging() {
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Map<String, String> _flatten(dynamic yaml, String prefix) {
    if (yaml is Map) {
      return yaml.entries
          .map((entry) => _flatten(entry.value, '$prefix${entry.key}.'))
          .reduce((map1, map2) => {...map1, ...map2});
    }
    if (yaml is List) {
      throw ArgumentError('List config not yet supported');
    }
    return {prefix.substring(0, prefix.length - 1): yaml.toString()};
  }
}
