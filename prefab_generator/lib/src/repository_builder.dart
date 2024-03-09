import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:source_gen/source_gen.dart';

class RepositoryBuilder extends GeneratorForAnnotation<Prefab> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element.kind != ElementKind.CLASS) {
      throw 'ERROR: @Prefab can only be used on a class, found on $element';
    }
    final useCases = annotation.objectValue.getField('useCases')!.toSetValue()!;
    if (useCases.isEmpty) {
      return '';
    }
    final clazz = element as ClassElement;
    final entityName = element.name;
    final fields = clazz.fields
        .where((field) =>
            !field.isStatic &&
            !field.isPrivate &&
            field.type.convertsToPrimitive)
        .toList();
    final mixins =
        annotation.objectValue.getField('repositoryMixins')!.toSetValue()!;
    final keyField = fields.where((field) => field.hasMeta(Key)).first;
    var keyType = keyField.type.getDisplayString(withNullability: false);
    var nonKeyFields = fields.where((f) => !f.hasMeta(Key));
    var mixinsClause = mixins.isNotEmpty
        ? ' with ${mixins.map((mixin) => mixin.toTypeValue()!.element!.name).join(',')}'
        : '';
    return '''
    @managed
    class $entityName\$Repository$mixinsClause {
      final Box box;
    
      $entityName\$Repository(this.box);
    
      Future<$keyType> save($entityName ${entityName.camelCase}) => box.store(${entityName.camelCase});
    
      Future<$entityName?> findBy${keyField.name.pascalCase}($keyType ${keyField.name}) => box.find<$entityName>(${keyField.name}${keyType == 'UuidValue' ? '.toString()' : ''});
      
      Future<List<$entityName>> search(
      ${entityName.pascalCase}\$Field? orderBy,
      SortDirection direction,
      ${nonKeyFields.map((f) => _parameter(f, Nullability.nullable)).join(',')}
      ) =>
        box
          .selectFrom<$entityName>()
          .filterWith(${entityName.pascalCase}\$Field.values, [${nonKeyFields.map((f) => f.name).join(',')}])
          .orderByWith(orderBy, direction)
          .list();
      
      Future<int> deleteBy${keyField.name.pascalCase}($keyType ${keyField.name}) =>
          box.deleteFrom<$entityName>().where('${keyField.name}').equals(${keyField.name}${keyType == 'UuidValue' ? '.toString()' : ''}).execute();
    }
    '''; // TODO: query fields
  }

  String _parameter(
    VariableElement parameter, [
    Nullability nullability = Nullability.inherit,
  ]) =>
      '${nullability.outputType(parameter)} ${parameter.name}';
}
