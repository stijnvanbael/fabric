import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';

import 'use_case_builder.dart';

class DeleteByKeyBuilder extends UseCaseBuilder<ClassElement, DeleteByKey> {
  @override
  String generateControllerMethod(ClassElement element, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.keyField;
    return '''
    @Delete('/api/${entityName.paramCase.plural}/:${keyField.name}')
    Future<Response> delete$entityName(${keyField.type.getDisplayString(withNullability: false)} ${keyField.name}) async {
      final deleted = await repository.deleteBy${keyField.name.pascalCase}(${keyField.name});
      return switch(deleted) {
        0 => Response.notFound('No ${entityName.sentenceCase.toLowerCase()} found with ${keyField.name} \$${keyField.name}'),
        _ => Response.ok(''),
      };
    }
    ''';
  }
}
