import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class ControllerBuilder extends GeneratorForAnnotation<Prefab> {
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
    final useCases = annotation.objectValue.getField('useCases')!.toSetValue()!;
    return '''
    @controller
    @managed
    class $entityName\$Controller {
      final $entityName\$Repository _repository;
      
      $entityName\$Controller(
        this._repository,
      );
      
      ${useCases.map((useCase) => _controllerMethod(useCase, clazz)).join('\n\n')}
    }
    ''';
  }

  String _controllerMethod(DartObject useCase, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.fields
        .where((field) =>
            !field.isStatic && !field.isPrivate && field.hasMeta(Key))
        .first;
    if (isType(useCase.type!, Create)) {
      return _createMethod(clazz, entityName, keyField);
    } else if (isType(useCase.type!, GetByKey)) {
      return _getByKeyMethod(clazz, entityName, keyField);
    } else {
      print('[WARNING] unknown use case: $useCase');
      return '';
    }
  }

  String _createMethod(
    ClassElement clazz,
    String entityName,
    FieldElement keyField,
  ) {
    return '''
        @Post('/${entityName.paramCase}s')
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
    @Get('/${entityName.paramCase}s/:${keyField.name}')
    Future<Response> get$entityName(${keyField.type.getDisplayString(withNullability: false)} ${keyField.name}) async {
      var ${entityName.camelCase} = await _repository.findBy${keyField.name.pascalCase}(${keyField.name});
      if (${entityName.camelCase} == null) {
        return Response.notFound("No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}");
      }
      return Response.ok(jsonEncode(${entityName.camelCase}.toJson()));
    }
    ''';
  }
}
