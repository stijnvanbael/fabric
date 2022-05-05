/// Support for doing something awesome.
///
/// More dartdocs go here.
library fabric_weaver_generator;

import 'package:build/build.dart';
import 'package:fabric_weaver_generator/src/application_generator.dart';
import 'package:fabric_weaver_generator/src/box_registry_generator.dart';
import 'package:fabric_weaver_generator/src/definition.dart';
import 'package:fabric_weaver_generator/src/dispatcher_generator.dart';
import 'package:merging_builder/merging_builder.dart';

Builder dispatcherLibBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, LibDir>(
      generator: DispatcherGenerator(),
      inputFiles: 'lib/**.dart',
      outputFile: 'lib/weaver_dispatcher.g.dart',
    );

Builder dispatcherTestBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: DispatcherGenerator(),
      inputFiles: 'test/**.dart',
      outputFile: 'test/weaver_dispatcher.g.dart',
    );

Builder dispatcherExampleBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: DispatcherGenerator(),
      inputFiles: 'example/**.dart',
      outputFile: 'example/weaver_dispatcher.g.dart',
    );

Builder boxRegistryLibBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: BoxRegistryGenerator(),
      inputFiles: 'lib/**.dart',
      outputFile: 'lib/weaver_box_registry.g.dart',
    );

Builder boxRegistryTestBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: BoxRegistryGenerator(),
      inputFiles: 'test/**.dart',
      outputFile: 'test/weaver_box_registry.g.dart',
    );

Builder boxRegistryExampleBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: BoxRegistryGenerator(),
      inputFiles: 'example/**.dart',
      outputFile: 'example/weaver_box_registry.g.dart',
    );

Builder applicationLibBuilder(BuilderOptions options) =>
    MergingBuilder<dynamic, PackageDir>(
      generator: ApplicationGenerator(),
      inputFiles: 'lib/**.dart',
      outputFile: 'lib/weaver_application.g.dart',
    );

Builder applicationTestBuilder(BuilderOptions options) =>
    MergingBuilder<dynamic, PackageDir>(
      generator: ApplicationGenerator(),
      inputFiles: 'test/**.dart',
      outputFile: 'test/weaver_application.g.dart',
    );

Builder applicationExampleBuilder(BuilderOptions options) =>
    MergingBuilder<dynamic, PackageDir>(
      generator: ApplicationGenerator(),
      inputFiles: 'example/**.dart',
      outputFile: 'example/weaver_application.g.dart',
    );
