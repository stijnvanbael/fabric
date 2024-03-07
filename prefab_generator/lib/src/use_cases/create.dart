import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/use_cases/use_case_builder.dart';
import 'package:fabric_prefab_generator/src/util.dart';

class CreateBuilder extends UseCaseBuilder<ClassElement, Create> {
  @override
  String generateControllerMethod(ClassElement element, ClassElement clazz) {
    final entityName = clazz.name;
    final keyField = clazz.keyField;
    // TODO: apply base URL and request path in the annotation
    return '''
      @Post('/api/${entityName.paramCase.plural}')
      Future<Response> create$entityName(@body $entityName ${entityName.camelCase}) async {
        final ${keyField.name} = await repository.save(${entityName.camelCase});
        return Response(201, headers: {
          'content-type': 'application/json',
          'location': '/api/${entityName.paramCase.plural}/\$${keyField.name}'
        });
      }
      ''';
  }
}
