import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('Fabric manager', () {
    test('Register instance', () {
      var fabric = Fabric();
      var instance = TestRepository();
      fabric.registerInstance<Repository>(instance);
      expect(fabric.getInstance<Repository>(), instance);
    });

    test('Custom spec', () {
      var cool = NameSpec("cool");
      var boring = NameSpec("boring");
      var fabric = Fabric();
      var coolInstance = TestRepository();
      var boringInstance = TestRepository();
      fabric.register<Repository>(cool, (fabric) => coolInstance);
      fabric.register<Repository>(boring, (fabric) => boringInstance);
      expect(fabric.getInstance<Repository>(cool), coolInstance);
    });

    test('Register factory', () {
      var fabric = Fabric();
      fabric.registerFactory<Repository>((fabric) => TestRepository());
      expect(fabric.getInstance<Repository>(), isA<TestRepository>());
    });

    test('Cache result', () {
      var fabric = Fabric();
      fabric.registerFactory<Repository>((fabric) => TestRepository());
      var instance1 = fabric.getInstance<Repository>();
      var instance2 = fabric.getInstance<Repository>();
      expect(instance2, instance1);
    });

    test('Not registered', () {
      var fabric = Fabric();
      expect(() => fabric.getInstance<Repository>(),
          throwsA(isA<ArgumentError>()));
    });

    test('Dependency chain', () {
      var fabric = Fabric();
      var repository = TestRepository();
      fabric.registerInstance<Repository>(repository);
      fabric.registerFactory((fabric) => Service(fabric.getInstance()));
      expect(fabric.getInstance<Service>().repository, repository);
    });

    test('Circular dependency', () {
      var fabric = Fabric();
      fabric.registerFactory<Repository>(
          (fabric) => BrokenRepository(fabric.getInstance()));
      fabric.registerFactory((fabric) => Service(fabric.getInstance()));

      expect(() => fabric.getInstance<Repository>(),
          throwsA(isA<StateError>()));
    });

    test('All instances', () {
      var fabric = Fabric();
      var instance1 = TestRepository();
      var instance2 = TestRepository();
      fabric.registerInstance<Repository>(instance1);
      fabric.registerInstance<Repository>(instance2);
      expect(fabric.getInstances<Repository>(), {instance1, instance2});
    });

    test('Duplicate definition', () {
      var fabric = Fabric();
      var instance1 = TestRepository();
      var instance2 = TestRepository();
      fabric.registerInstance<Repository>(instance1);
      fabric.registerInstance<Repository>(instance2);
      expect(() => fabric.getInstance<Repository>(), throwsA(isA<StateError>()));
    });
  });
}

abstract class Repository {}

class TestRepository implements Repository {}

class Service {
  final Repository repository;

  Service(this.repository);
}

class BrokenRepository implements Repository {
  final Service service;

  BrokenRepository(this.service);
}
