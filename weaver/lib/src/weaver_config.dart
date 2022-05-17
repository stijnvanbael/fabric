import 'dart:io';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final Logger log = Logger('weaver_config');

Map<String, String> loadConfig(String configDir) {
  log.fine('Loading config.yaml');
  var configFile = File('${_relativeConfigDir(configDir)}/config.yaml');
  if (configFile.existsSync()) {
    log.fine('config.yaml found');
    var contents = configFile.readAsStringSync();
    var yaml = loadYaml(contents);
    var flattened = _flatten(yaml, '');
    log.fine('Config: $flattened');
    return flattened;
  } else {
    log.fine('config.yaml not found');
    return {};
  }
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


String _relativeConfigDir(String configDir) {
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