import 'package:fabric_metadata/fabric_metadata.dart';

typedef Factory<T> = T Function(Fabric fabric);

class Fabric {
  final Map<Spec, Set<Factory>> _registry = {};
  final Map<Spec, Set<dynamic>> _cache = {};
  final Set<Spec> _underConstruction = {};
  final Map<String, String> _config = {};

  void registerInstance<T>(T instance) => registerFactory<T>(value(instance));

  void registerFactory<T>(Factory<T> factory) =>
      register<T>(TypeSpec(T), factory);

  void register<T>(Spec spec, Factory<T> factory) =>
      _registry.putIfAbsent(spec, () => {}).add(factory);

  T getInstance<T>([Spec? spec]) {
    var instances = getInstances<T>(spec);
    if (instances.length > 1) {
      throw StateError("Multiple definitions found for $T($spec)");
    }
    return instances.first;
  }

  Set<T> getInstances<T>([Spec? spec]) {
    spec ??= TypeSpec(T);
    var instances = _fromCache<T>(spec);
    if (instances == null) {
      instances = _createInstances<T>(spec);
      _addToCache<T>(spec, instances);
    }
    return instances;
  }

  Set<T>? _fromCache<T>(Spec spec) => _cache[spec] as Set<T>?;

  Set<T> _createInstances<T>(Spec spec) {
    _startConstruction<T>(spec);
    var factories = _registry[spec];
    if (factories == null) {
      throw ArgumentError("No factory registered for $T($spec)");
    }
    var instances = factories.map((factory) => factory(this) as T).toSet();
    _finishConstruction<T>(spec);
    return instances;
  }

  void _startConstruction<T>(Spec spec) {
    if (_underConstruction.contains(spec)) {
      throw StateError(
          "Circular dependency detected when constructing $T($spec)");
    }
    _underConstruction.add(spec);
  }

  void _finishConstruction<T>(Spec spec) => _underConstruction.remove(spec);

  void _addToCache<T>(Spec spec, Set<T> instances) => _cache[spec] = instances;

  void registerConfig(String key, String value) => _config[key] = value;

  void registerConfigMap(Map<String, String> configMap) =>
      _config.addAll(configMap);

  String getString(String key, {String? defaultValue}) {
    if (!_config.containsKey(key)) {
      if (defaultValue == null) {
        throw StateError("No confiq registered for key '$key'");
      } else {
        return defaultValue;
      }
    }
    return _config[key]!;
  }

  int getInt(String key, {int? defaultValue}) =>
      int.parse(getString(key, defaultValue: defaultValue?.toString()));
}

Factory<T> value<T>(T instance) {
  return (fabric) => instance;
}
