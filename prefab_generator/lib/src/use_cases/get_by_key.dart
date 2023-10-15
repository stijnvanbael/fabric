import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:recase/recase.dart';

import 'use_case_builder.dart';

class GetByKeyBuilder extends UseCaseBuilder<ClassElement, GetByKey> {
  @override
  String generateControllerMethod(ClassElement element, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.keyField;
    return '''
    @Get('/api/${entityName.paramCase.plural}/:${keyField.name}')
    Future<Response> get$entityName(${keyField.type.getDisplayString(withNullability: false)} ${keyField.name}) async {
      final ${entityName.camelCase} = await repository.findBy${keyField.name.pascalCase}(${keyField.name});
      if (${entityName.camelCase} == null) {
        return Response.notFound("No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}");
      }
      return Response.ok(jsonEncode(${entityName.camelCase}.toJson()));
    }
    ''';
  }
}
