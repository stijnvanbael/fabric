import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

class ApplicationGenerator extends MergingGenerator<dynamic, PackageDir> {
  @override
  String generateMergedContent(Stream<dynamic> stream) {
    return """
      import 'package:fabric_manager/fabric_manager.dart';
      import 'package:fabric_metadata/fabric_metadata.dart';
      import 'package:fabric_weaver/fabric_weaver.dart';
            
      import 'fabric.g.dart';
      import 'weaver_box_registry.g.dart';
      import 'weaver_dispatcher.g.dart';
      
      void startApplication({
        Map<Spec, Factory> factories = const {},
        String configDir = 'lib/conf',
      }) {
        var fabric = createFabric();
        registerDispatcherBuilders(fabric);
        registerBox(fabric);
        var application = WeaverApplication(
          fabric,
          factories: factories,
          configDir: configDir,
        );
        application.start();
      } 
    """;
  }

  @override
  generateStreamItemForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return null;
  }
}
