import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/use_cases/use_case_builder.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:recase/recase.dart';

class SearchBuilder extends UseCaseBuilder<ClassElement, Search> {
  @override
  String generateControllerMethod(ClassElement element, ClassElement clazz) {
    final entityName = clazz.name;
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

  String _parameter(
    VariableElement parameter, [
    Nullability nullability = Nullability.inherit,
  ]) =>
      '${nullability.outputType(parameter)} ${parameter.name}';

  String _arguments(List<VariableElement> variables, [String prefix = '']) =>
      variables.map((variable) => prefix + variable.name).join(', ');
}