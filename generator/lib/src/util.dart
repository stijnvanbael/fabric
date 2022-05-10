import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';

bool hasMeta(Element element, Type meta) => element.metadata
    .any((element) => isType(element.computeConstantValue()!.type!, meta));

DartObject? getMeta(Element element, Type meta) => element.metadata
    .map((element) => element.computeConstantValue()!)
    .firstOrNull;

bool isType(DartType typeToTest, Type expectedType) =>
    typeToTest.accept(TypeChecker(expectedType));

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
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    var iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
