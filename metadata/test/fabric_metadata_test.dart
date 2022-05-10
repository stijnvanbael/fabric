import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'fabric.g.dart';

void main() {
  group('Fabric metadata', () {
    test('Unnamed constructor param', () {
      var fabric = createFabric();
      fabric.registerConfig("service.property", "value");
      var service = fabric.getInstance<Service>();

      expect(service, isA<Service>());
      expect(service.repository, isA<Repository>());
      expect(service.property, "value");
    });
  });
}

@managed
class Repository {}

@managed
class Service {
  final Repository repository;
  final String property;

  Service(
    this.repository,
    @Config("service.property") this.property,
  );
}
