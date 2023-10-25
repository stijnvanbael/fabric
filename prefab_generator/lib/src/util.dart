import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:source_gen/source_gen.dart';

extension ElementHasMeta on Element {
  bool hasMeta(Type meta) => metadata
      .any((element) => element.computeConstantValue()!.type!.isType(meta));

  ConstantReader? getMeta<T>() => metadata
      .map((element) {
        var value = element.computeConstantValue();
        if (value!.type!.isType(T)) {
          return value;
        }
        return null;
      })
      .where((value) => value != null)
      .map((value) => ConstantReader(value!))
      .firstOrNull;
}

extension DartTypeExtensions on DartType {
  bool isType(Type expected) => accept(TypeChecker(expected));
}

extension ClassElementExtensions on ClassElement {
  FieldElement get keyField => fields
      .where(
          (field) => !field.isStatic && !field.isPrivate && field.hasMeta(Key))
      .first;
}

class TypeChecker implements TypeVisitor<bool> {
  final Type expectedType;

  TypeChecker(this.expectedType);

  @override
  bool visitInterfaceType(InterfaceType type) => _isMatch(type);

  bool _isMatch(InterfaceType type) =>
      type.element.name == expectedType.toString() ||
      type.allSupertypes.any(_isMatch);

  @override
  bool visitDynamicType(DynamicType type) => false;

  @override
  bool visitFunctionType(FunctionType type) => false;

  @override
  bool visitNeverType(NeverType type) => false;

  @override
  bool visitTypeParameterType(TypeParameterType type) => false;

  @override
  bool visitVoidType(VoidType type) => false;

  @override
  bool visitRecordType(RecordType type) => false;

  @override
  bool visitInvalidType(InvalidType type) => false;
}

enum Nullability {
  nullable(false, '?'),
  notNull(false, ''),
  inherit(true, '');

  final bool _inherit;
  final String _suffix;

  const Nullability(this._inherit, this._suffix);

  String outputType(VariableElement element) {
    return element.type.getDisplayString(withNullability: _inherit) + _suffix;
  }
}
