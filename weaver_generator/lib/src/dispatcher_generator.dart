import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:controller/controller.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'definition.dart';

class DispatcherGenerator extends MergingGenerator<Definition, Controller> {
  @override
  Definition generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element.kind != ElementKind.CLASS) {
      throw "ERROR: @Controller can only be used on a class, found on $element";
    }
    return Definition(
      registration: "fabric.registerFactory<DispatcherBuilder>((fabric) => "
          "${element.name}\$DispatcherBuilder(fabric.getInstance()));",
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
    import 'package:controller/controller.dart';
    import 'package:fabric_manager/fabric_manager.dart';
    ${imports.join("\n")}
        
    void registerDispatcherBuilders(Fabric fabric) {
      $registrations
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