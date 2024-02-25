import 'dart:io';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

final Logger _log = Logger('weaver_config');
final RegExp _include = RegExp(r'\$include\((.+)\)');

Map<String, String> loadConfig(
  String configDir, [
  String environment = '',
  String secretsPath = '',
]) {
  var dir = _relativeConfigDir(configDir);
  var suffix = environment.isNotEmpty ? '-$environment' : '';
  var config = <String, String>{};
  config.addAll(_loadConfig(dir, 'config$suffix'));
  config.addAll(_loadConfig(dir, '$secretsPath$suffix'));
  return config;
}

Map<String, String> _loadConfig(String dir, String name) {
  var path = '$dir/$name.yaml';
  _log.fine('Loading $path');
  var configFile = File(path);
  if (configFile.existsSync()) {
    _log.fine('$path found');
    var contents = configFile.readAsStringSync();
    var yaml = loadYaml(contents);
    var flattened = _flatten(yaml, '');
    _log.fine('Config: $flattened');
    return flattened;
  } else {
    _log.warning('No config found on $path');
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
  return {prefix.substring(0, prefix.length - 1): _valueOf(yaml)};
}

String _valueOf(yaml) {
  final stringValue = yaml.toString();
  final include = _include.firstMatch(stringValue);
  if (include != null) {
    var fileName = 'lib/conf/${include.group(1)}';
    final file = File(fileName);
    if (!file.existsSync()) {
      throw ArgumentError('Included file not found: $fileName');
    }
    return file.readAsStringSync();
  }
  return stringValue;
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
