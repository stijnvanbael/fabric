import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:recase/recase.dart';
import 'package:source_gen/source_gen.dart';

class RepositoryBuilder extends GeneratorForAnnotation<Prefab> {
  @override
  generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element.kind != ElementKind.CLASS) {
      throw 'ERROR: @Prefab can only be used on a class, found on $element';
    }
    final clazz = element as ClassElement;
    final entityName = element.name;
    final fields = clazz.fields
        .where((field) => !field.isStatic && !field.isPrivate)
        .toList();
    final keyField = fields.where((field) => field.hasMeta(Key)).first;
    var keyType = keyField.type.getDisplayString(withNullability: false);
    var nonKeyFields = fields.where((f) => !f.hasMeta(Key));
    return '''
    @managed
    class $entityName\$Repository {
      final Box _box;
    
      $entityName\$Repository(this._box);
    
      Future<$keyType> save($entityName ${entityName.camelCase}) => _box.store(${entityName.camelCase});
    
      Future<$entityName?> findBy${keyField.name.pascalCase}($keyType ${keyField.name}) => _box.find<$entityName>(${keyField.name});
      
      Future<List<$entityName>> search(
      ${entityName.pascalCase}\$Field? orderBy,
      SortDirection direction,
      ${nonKeyFields.map((f) => _parameter(f, Nullability.nullable)).join(',')}
      ) =>
        _box
          .selectFrom<$entityName>()
          .filterWith(${entityName.pascalCase}\$Field.values, [${nonKeyFields.map((f) => f.name).join(',')}])
          .orderByWith(orderBy, direction)
          .list();
    }
    '''; // TODO: query fields
  }

  String _parameter(
    VariableElement parameter, [
    Nullability nullability = Nullability.inherit,
  ]) =>
      '${nullability.outputType(parameter)} ${parameter.name}';
}
