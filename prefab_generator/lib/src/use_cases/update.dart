import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/use_cases/use_case_builder.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:logging/logging.dart';
import 'package:recase/recase.dart';

class UpdateBuilder extends UseCaseBuilder<MethodElement, Update> {
  final Logger logger = Logger('UpdateBuilder');

  @override
  String generateControllerMethod(MethodElement element, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.fields
        .where((field) =>
            !field.isStatic && !field.isPrivate && field.hasMeta(Key))
        .first;
    final request = element.getMeta<UseCase>()!.read('request');
    final httpMethod = request.read('method').stringValue.pascalCase;
    final path = request.read('path').stringValue;
    final requestBody = element.parameters.isNotEmpty
        ? ', @body ${entityName.pascalCase}\$${element.name.pascalCase}Request request'
        : '';
    final update = element.returnType.element == clazz
        ? _immutableUpdate(entityName, element)
        : _mutableUpdate(entityName, element);
    return '''
    @$httpMethod('/${entityName.paramCase.plural}/:${keyField.name}$path')
    Future<Response> ${element.name}(${_parameter(keyField)}$requestBody) async {
      final ${entityName.camelCase} = await _repository.findBy${keyField.name.pascalCase}(${keyField.name});
      if (${entityName.camelCase} == null) {
        return Response.notFound("No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}");
      }
      $update
    }
    ''';
  }

  @override
  String generateRequestClass(MethodElement element, ClassElement clazz) {
    if (element.parameters.isEmpty) {
      return '';
    }
    final entityName = clazz.name;
    final requestName =
        '${entityName.pascalCase}\$${element.name.pascalCase}Request';
    return '''
    @JsonSerializable(createToJson: false)
    @validatable
    class $requestName {
      ${element.parameters.map(_parameter).map((p) => '$p;').join('\n')}
      
      $requestName(
        ${element.parameters.map((p) => 'this.${p.name},').join('\n')}
      );
      
      static $requestName fromJson(Map<String, dynamic> json) => _\$${requestName}FromJson(json);
    }
    ''';
  }

  String _immutableUpdate(String entityName, MethodElement method) => '''
      final updated = ${entityName.camelCase}.${method.name}(${_arguments(method.parameters, 'request.')});
      await _repository.save(updated);
      return Response.ok(jsonEncode(updated.toJson()));
      ''';

  String _mutableUpdate(String entityName, MethodElement method) {
    logger.warning('Update use case $entityName.${method.name}() does not have'
        ' $entityName, assuming it modifies the object itself. This is not'
        ' advised, it is safer to make entities immutable and have use cases'
        ' return a copy of the entity.');
    return '''
      ${entityName.camelCase}.${method.name}(${_arguments(method.parameters, 'request.')});
      await _repository.save(${entityName.camelCase});
      return Response.ok(jsonEncode(${entityName.camelCase}.toJson()));
      ''';
  }

  String _parameter(
    VariableElement parameter, [
    Nullability nullability = Nullability.inherit,
  ]) =>
      '${nullability.outputType(parameter)} ${parameter.name}';

  String _arguments(List<VariableElement> variables, [String prefix = '']) =>
      variables.map((variable) => prefix + variable.name).join(', ');
}
