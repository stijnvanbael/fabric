import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab_generator/src/use_cases/create.dart';
import 'package:fabric_prefab_generator/src/use_cases/delete_by_key.dart';
import 'package:fabric_prefab_generator/src/use_cases/get_by_key.dart';
import 'package:fabric_prefab_generator/src/use_cases/search.dart';
import 'package:fabric_prefab_generator/src/use_cases/update.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:source_gen/source_gen.dart';

abstract class UseCaseBuilder<E extends Element, T> extends Generator {
  static final Map<Type, UseCaseBuilder> _useCaseRegistry = {};

  UseCaseBuilder() {
    _useCaseRegistry[T] = this;
  }

  static List<Generator> get defaults => [
        CreateBuilder(),
        GetByKeyBuilder(),
        SearchBuilder(),
        UpdateBuilder(),
        DeleteByKeyBuilder(),
      ];

  static String controllerMethod(
    DartObject useCase,
    Element element,
    ClassElement clazz,
  ) =>
      _findBuilder(useCase, element, clazz)
          .generateControllerMethod(element, clazz);

  static String requestClass(
    DartObject useCase,
    Element element,
    ClassElement clazz,
  ) =>
      _findBuilder(useCase, element, clazz)
          .generateRequestClass(element, clazz);

  static UseCaseBuilder _findBuilder(
      DartObject useCase, Element element, ClassElement clazz) {
    final type = _useCaseRegistry.keys
        .where((type) => useCase.type!.isType(type))
        .firstOrNull;
    if (type == null) {
      throw ArgumentError(
          'No UseCaseBuilder defined for ${useCase.type?.element?.name}');
    } else {
      var useCaseBuilder = _useCaseRegistry[type]!;
      useCaseBuilder._validateElement(element);
      return useCaseBuilder;
    }
  }

  @override
  String generate(LibraryReader library, BuildStep buildStep) => '';

  String generateControllerMethod(E element, ClassElement clazz);

  String generateRequestClass(E element, ClassElement clazz) => '';

  void _validateElement(Element element) {
    if (element is! E) {
      throw ArgumentError(
          '@$T can only be applied to a $E, was applied to $element');
    }
  }
}
