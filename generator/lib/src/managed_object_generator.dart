import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:merging_builder_svb/merging_builder_svb.dart';
import 'package:source_gen/source_gen.dart';

import 'util.dart';

class ManagedObjectGenerator extends MergingGenerator<Definition, Managed> {
  @override
  Definition generateStreamItemForAnnotatedElement(
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
    return Definition(
      registration: """
        fabric.registerFactory((Fabric fabric) {
          return $typeName(
          ${constructorParams.map(_generateParam).join(",\n")}
          );
        });
      """,
      imports: {
        _pathOf(element.enclosingElement),
        ...constructorParams.map((param) =>
            _pathOf(param.type.element!.library!.definingCompilationUnit)),
      },
    );
  }

  @override
  Future<String> generateMergedContent(Stream<Definition> stream) async {
    var imports = <String>{};
    var definitions = await stream.map((definition) {
      for (var element in definition.imports) {
        imports.add("import '$element';");
      }
      return definition.registration;
    }).join("\n");
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
    var config = getMeta(param, Config);
    if (config != null) {
      result +=
          "fabric.getString('${config.getField("name")!.toStringValue()}')";
    } else {
      result += "fabric.getInstance<$typeName>()";
    }
    return result;
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

class Definition {
  final String registration;
  final Set<String> imports;

  Definition({
    required this.registration,
    required this.imports,
  });
}
