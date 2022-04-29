import 'package:fabric_metadata/fabric_metadata.dart';

typedef Factory<T> = T Function(Fabric fabric);

class Fabric {
  final Map<Type, Map<Spec, Set<Factory>>> _registry = {};
  final Map<Type, Map<Spec, Set<dynamic>>> _cache = {};
  final Map<Type, Set<Spec>> _underConstruction = {};

  void registerInstance<T>(T instance) => registerFactory<T>(value(instance));

  void registerFactory<T>(Factory<T> factory) =>
      register<T>(TypeSpec(T), factory);

  void register<T>(Spec spec, Factory<T> factory) => _registry
      .putIfAbsent(T, () => {})
      .putIfAbsent(spec, () => {})
      .add(factory);

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

  Set<T>? _fromCache<T>(Spec spec) => _cache[T]?[spec] as Set<T>?;

  Set<T> _createInstances<T>(Spec spec) {
    _startConstruction<T>(spec);
    var factories = _registry[T]?[spec];
    if (factories == null) {
      throw ArgumentError("No factory registered for $T($spec)");
    }
    var instances = factories.map((factory) => factory(this) as T).toSet();
    _finishConstruction<T>(spec);
    return instances;
  }

  void _startConstruction<T>(Spec spec) {
    _underConstruction.putIfAbsent(T, () => {});
    if (_underConstruction[T]!.contains(spec)) {
      throw StateError(
          "Circular dependency detected when constructing $T($spec)");
    }
    _underConstruction[T]!.add(spec);
  }

  void _finishConstruction<T>(Spec spec) => _underConstruction[T]!.remove(spec);

  void _addToCache<T>(Spec spec, Set<T> instances) =>
      _cache.putIfAbsent(T, () => {})[spec] = instances;
}

Factory<T> value<T>(T instance) {
  return (fabric) => instance;
}
