import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:source_gen/source_gen.dart';

class ManagedObjectGenerator
    extends MergingGenerator<MapEntry<String, String>, Managed> {
  @override
  MapEntry<String, String> generateStreamItemForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS) {
      throw "ERROR: @Managed can only be used on a class, found on $element";
    }
    var constructor = (element as ClassElement).unnamedConstructor;
    if (constructor == null) {
      throw "ERROR: No unnamed constructor found for $element";
    }
    var constructorParams = constructor.parameters;
    var typeName = element.name;
    return MapEntry(element.enclosingElement.librarySource.shortName, """
      fabric.registerFactory((Fabric fabric) {
        return $typeName(
        ${constructorParams.map(_generateParam).join(",\n")}
        );
      });
    """);
  }

  @override
  Future<String> generateMergedContent(
      Stream<MapEntry<String, String>> stream) async {
    var imports = <String>{};
    var definitions = await stream.map((element) {
      imports.add("import '${element.key}';");
      return element.value;
    }).join("\n");
    if (definitions.isEmpty) {
      return "";
    }
    return """
      import 'package:fabric_manager/fabric_manager.dart';
      ${imports.join("\n")}
      
      Fabric createFabric() {
      var fabric = Fabric();
      $definitions
      return fabric;
      }
    """;
  }

  String _generateParam(ParameterElement param) {
    var result = "";
    if (param.isNamed) {
      result += "${param.name} = ";
    }
    var typeName = param.type.element?.name;
    if (typeName == null) {
      throw "ERROR: missing type for parameter ${param.name} of ${param.enclosingElement?.name}";
    }
    result += "fabric.getInstance<$typeName>()";
    return result;
  }

  bool _isClass(Element element) => element.kind == ElementKind.CLASS;
}
