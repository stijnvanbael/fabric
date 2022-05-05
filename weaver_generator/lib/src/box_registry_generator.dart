import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:box/box.dart';
import 'package:build/build.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'definition.dart';

class BoxRegistryGenerator extends MergingGenerator<Definition, Entity> {
  @override
  Definition generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element.kind != ElementKind.CLASS) {
      throw "ERROR: @Entity can only be used on a class, found on $element";
    }
    return Definition(
      registration: "..register(${element.name}\$BoxSupport())",
      imports: {_pathOf((element as ClassElement).enclosingElement)},
    );
  }

  @override
  FutureOr<String> generateMergedContent(Stream<Definition> stream) async {
    var imports = <String>{};
    var registrations = await stream.map((definition) {
      for (var element in definition.imports) {
        imports.add("import '$element';");
      }
      return definition.registration;
    }).join("\n");
    return """
    import 'package:box/box.dart';
    import 'package:fabric_manager/fabric_manager.dart';
    ${imports.join("\n")}
        
    void registerBox(Fabric fabric) {
      fabric.registerInstance(Registry()
        $registrations);
    }
    """;
  }

  String _pathOf(CompilationUnitElement library) {
    var uri = library.librarySource.uri;
    if (uri.scheme == "asset") {
      return uri.pathSegments.skip(2).join("/");
    } else {
      return uri.toString();
    }
  }
}
