import 'dart:io';

import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:yaml/yaml.dart';

final Logger log = Logger('weaver');

class WeaverApplication {
  final Fabric fabric;
  final Map<Spec, Factory> factories;
  final String configDir;

  WeaverApplication(
    this.fabric, {
    this.factories = const {},
    required this.configDir,
  }) {
    _configureDefaults();
  }

  Future start() async {
    _configureLogging();
    log.info('Starting application');
    _loadConfig();
    for (var entry in factories.entries) {
      fabric.register(entry.key, entry.value);
    }
    var handler = _createRequestHandler();

    var server = await serve(handler, '0.0.0.0', fabric.getInt('server.port'));
    log.info('Serving at http://${server.address.host}:${server.port}');
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  void _loadConfig() {
    var configFile = File('${_relativeConfigDir()}/config.yaml');
    if (configFile.existsSync()) {
      log.info('Loading config from $configFile');
      var contents = configFile.readAsStringSync();
      var yaml = loadYaml(contents);
      var flattened = _flatten(yaml, '');
      log.fine('Config: $flattened');
      fabric.registerConfigMap(flattened);
    } else {
      log.warning('$configFile not found, assuming defaults');
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

  String _relativeConfigDir() {
    var currentPath = Directory.current.path.split('/');
    var configPath = configDir.split('/');
    for (var index = 0; index < currentPath.length; index++) {
      var subPath = currentPath.sublist(index);
      if (configPath.startsWith(subPath)) {
        return configPath.sublist(subPath.length).join('/');
      }
    }
    return configDir;
  }
}

extension IterableStartsWith<T> on Iterable<T> {
  bool startsWith(Iterable<T> elements) {
    if (length < elements.length) {
      return false;
    }
    for (var index = 0; index < elements.length; index++) {
      if (elementAt(index) != elements.elementAt(index)) {
        return false;
      }
    }
    return true;
  }
}
