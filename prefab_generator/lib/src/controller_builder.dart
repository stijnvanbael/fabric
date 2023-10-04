import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/use_cases/use_case_builder.dart';
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
    final mixins =
        annotation.objectValue.getField('controllerMixins')!.toSetValue()!;
    final customUseCases =
        clazz.methods.where((element) => element.hasMeta(UseCase)).toList();
    var mixinsClause = mixins.isNotEmpty
        ? ' with ${mixins.map((mixin) => mixin.toTypeValue()!.element!.name).join(',')}'
        : '';
    return '''
    @controller
    @managed
    class $entityName\$Controller$mixinsClause {
      final $entityName\$Repository _repository;
      
      $entityName\$Controller(
        this._repository,
      );
      
      ${standardUseCases.map((useCase) => UseCaseBuilder.controllerMethod(useCase, clazz, clazz)).join('\n\n')}
      
      ${customUseCases.map((method) => UseCaseBuilder.controllerMethod(method.getMeta<UseCase>()!.objectValue, method, clazz)).join('\n\n')}
    }
    
    ${customUseCases.map((method) => UseCaseBuilder.requestClass(method.getMeta<UseCase>()!.objectValue, method, clazz)).join('\n\n')}
    
    ${_fieldEnum(clazz)}
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
