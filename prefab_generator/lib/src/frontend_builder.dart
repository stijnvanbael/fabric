import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:logging/logging.dart';
import 'package:merging_builder_svb/merging_builder_svb.dart';
import 'package:source_gen/source_gen.dart';

import 'frontend/basic.dart';

class FrontendBuilderDispatcher
    extends MergingGenerator<FrontendComponents?, Prefab> {
  final Logger logger = Logger('FrontendBuilder');

  @override
  Future<String> generateMergedContent(
          Stream<FrontendComponents?> stream) async =>
      (await stream.whereNotNull().toList())
          .groupBy((c) => c.frontendName)
          .entries
          .map((entry) => FrontendBuilder.forName(entry.key)
              .compose(entry.value.map((c) => c.components).toList()))
          .firstOrNull ??
      '';

  @override
  FrontendComponents? generateStreamItemForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS) {
      throw '@Prefab can only be used on a class, found on $element';
    }
    final clazz = element as ClassElement;
    final frontend = element.getMeta<Prefab>()!.read('frontend');
    if (frontend.isNull) return null;
    final frontendName = frontend.read('name').stringValue;
    final builder = FrontendBuilder.forName(frontendName);
    return builder.generateComponents(clazz, frontend);
  }
}

abstract class FrontendBuilder extends Generator {
  static final Map<String, FrontendBuilder> _frontendRegistry = {};

  static List<Generator> get defaults => [BasicFrontendBuilder()];

  final String name;

  FrontendBuilder(this.name) {
    _frontendRegistry[name] = this;
  }

  factory FrontendBuilder.forName(String name) {
    final builder = _frontendRegistry[name];
    if (builder == null) {
      throw ArgumentError('Undefined frontend: $name');
    }
    return builder;
  }

  FrontendComponents generateComponents(
    ClassElement clazz,
    ConstantReader frontend,
  );

  String compose(List<Map<String, String>> components);

  @override
  String generate(LibraryReader library, BuildStep buildStep) => '';
}

class FrontendComponents {
  final String frontendName;
  final Map<String, String> components;

  FrontendComponents(this.frontendName, this.components);
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}
