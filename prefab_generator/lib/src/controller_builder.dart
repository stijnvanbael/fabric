import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:logging/logging.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class ControllerBuilder extends GeneratorForAnnotation<Prefab> {
  final Logger logger = Logger('ControllerBuilder');

  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element.kind != ElementKind.CLASS) {
      throw '@Prefab can only be used on a class, found on $element';
    }
    final clazz = element as ClassElement;
    final entityName = clazz.name;
    final standardUseCases =
        annotation.objectValue.getField('useCases')!.toSetValue()!;
    final customUseCases =
        clazz.methods.where((element) => element.hasMeta(UseCase)).toList();
    return '''
    @controller
    @managed
    class $entityName\$Controller {
      final $entityName\$Repository _repository;
      
      $entityName\$Controller(
        this._repository,
      );
      
      ${standardUseCases.map((useCase) => _standardUseCase(useCase, clazz)).join('\n\n')}
      
      ${customUseCases.map((useCase) => _customUseCase(useCase, clazz)).join('\n\n')}
    }
    
    ${customUseCases.map((useCase) => _useCaseRequest(useCase, clazz)).join('\n\n')}
    
    ${_fieldEnum(clazz)}
    ''';
  }

  String _standardUseCase(DartObject useCase, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.fields
        .where((field) =>
            !field.isStatic && !field.isPrivate && field.hasMeta(Key))
        .first;
    if (isType(useCase.type!, Create)) {
      return _createMethod(clazz, entityName, keyField);
    } else if (isType(useCase.type!, GetByKey)) {
      return _getByKeyMethod(clazz, entityName, keyField);
    } else if (isType(useCase.type!, Search)) {
      return _searchMethod(clazz, entityName, keyField);
    } else {
      logger.warning('Unknown use case: $useCase');
      return '';
    }
  }

  String _createMethod(
    ClassElement clazz,
    String entityName,
    FieldElement keyField,
  ) {
    return '''
      @Post('/${entityName.paramCase.plural}')
      Future<Response> create$entityName(@body $entityName ${entityName.camelCase}) async {
        final ${keyField.name} = await _repository.save(${entityName.camelCase});
        return Response(201, headers: {
          'content-type': 'application/json',
          'location': '/todos/\$${keyField.name}'
        });
      }
      ''';
  }

  String _getByKeyMethod(
    ClassElement clazz,
    String entityName,
    FieldElement keyField,
  ) {
    return '''
    @Get('/${entityName.paramCase.plural}/:${keyField.name}')
    Future<Response> get$entityName(${keyField.type.getDisplayString(withNullability: false)} ${keyField.name}) async {
      final ${entityName.camelCase} = await _repository.findBy${keyField.name.pascalCase}(${keyField.name});
      if (${entityName.camelCase} == null) {
        return Response.notFound("No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}");
      }
      return Response.ok(jsonEncode(${entityName.camelCase}.toJson()));
    }
    ''';
  }

  String _searchMethod(
    ClassElement clazz,
    String entityName,
    FieldElement keyField,
  ) {
    final fields = clazz.fields
        .where((field) =>
            !field.isStatic && !field.isPrivate && !field.hasMeta(Key))
        .toList();
    return '''
    @Get('/${entityName.paramCase.plural}')
    Future<Response> search${entityName.pascalCase.plural}(
      ${entityName.pascalCase}\$Field? orderBy,
      SortDirection? direction,
      ${fields.map((f) => _parameter(f, Nullability.nullable)).join(',')}
    ) async {
      final results = await _repository.search(
        orderBy,
        direction ?? SortDirection.ascending, 
        ${_arguments(fields)});
      return Response.ok(jsonEncode(PagedResults(results.map((e) => e.toJson()).toList()).toJson()));
    }
    ''';
  }

  String _customUseCase(
    MethodElement method,
    ClassElement clazz,
  ) {
    final entityName = clazz.name;
    final keyField = clazz.fields
        .where((field) =>
            !field.isStatic && !field.isPrivate && field.hasMeta(Key))
        .first;
    final request = method.getMeta<UseCase>()!.read('request');
    final httpMethod = request.read('method').stringValue.pascalCase;
    final path = request.read('path').stringValue;
    final requestBody = method.parameters.isNotEmpty
        ? ', @body ${entityName.pascalCase}\$${method.name.pascalCase}Request request'
        : '';
    final update = method.returnType.element == clazz
        ? _immutableUpdate(entityName, method)
        : _mutableUpdate(entityName, method);
    return '''
    @$httpMethod('/${entityName.paramCase.plural}/:${keyField.name}$path')
    Future<Response> ${method.name}(${_parameter(keyField)}$requestBody) async {
      final ${entityName.camelCase} = await _repository.findBy${keyField.name.pascalCase}(${keyField.name});
      if (${entityName.camelCase} == null) {
        return Response.notFound("No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}");
      }
      $update
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

  String _useCaseRequest(
    MethodElement method,
    ClassElement clazz,
  ) {
    if (method.parameters.isEmpty) {
      return '';
    }
    final entityName = clazz.name;
    final requestName =
        '${entityName.pascalCase}\$${method.name.pascalCase}Request';
    return '''
    @JsonSerializable(createToJson: false)
    @validatable
    class $requestName {
      ${method.parameters.map(_parameter).map((p) => '$p;').join('\n')}
      
      $requestName(
        ${method.parameters.map((p) => 'this.${p.name},').join('\n')}
      );
      
      static $requestName fromJson(Map<String, dynamic> json) => _\$${requestName}FromJson(json);
    }
    ''';
  }

  String _fieldEnum(ClassElement clazz) {
    final fields = clazz.fields.where(
        (field) => !field.isStatic && !field.isPrivate && !field.hasMeta(Key));
    return '''
    enum ${clazz.name.pascalCase}\$Field {
      ${fields.map((f) => f.name).join(',')};
      
      String get name => toString().substring(toString().indexOf('.') + 1);
    }
    ''';
  }
}
