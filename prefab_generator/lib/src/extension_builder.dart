import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:source_gen/source_gen.dart';

class ExtensionBuilder extends GeneratorForAnnotation<Prefab> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    _verifyIsClass(element);
    final abstract =
        annotation.objectValue.getField('abstract')!.toBoolValue()!;
    if (abstract) return '';
    final params = element.children
        .whereType<ConstructorElement>()
        .map((constructor) => constructor.parameters)
        .first;
    final entityName = element.name!;
    return '''
    extension $entityName\$Prefab on $entityName {
      ${_copy(entityName, params)}
          
      Map<String, dynamic> toJson() => _\$${entityName}ToJson(this);
    }
    ''';
  }

  String _copy(String entityName, List<ParameterElement> params) => '''
    $entityName copy({
      ${params.map(_paramDeclaration).join(',')}
    }) => $entityName(
      ${params.map(_constructorParam).join(',')}
    );
    ''';

  String _paramDeclaration(ParameterElement param) {
    final type = param.type.getDisplayString(withNullability: false);
    final name = param.name;
    return '$type? $name';
  }

  String _constructorParam(ParameterElement param) {
    final name = param.name;
    return '$name: $name ?? this.$name';
  }

  void _verifyIsClass(Element element) {
    if (element.kind != ElementKind.CLASS) {
      throw 'ERROR: @Prefab can only be used on a class, found on $element';
    }
  }
}
