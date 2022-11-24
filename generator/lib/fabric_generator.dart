/// Support for doing something awesome.
///
/// More dartdocs go here.
library fabric_generator;

import 'package:build/build.dart';
import 'package:fabric_generator/src/managed_object_generator.dart';
import 'package:merging_builder_svb/merging_builder_svb.dart';

export 'src/managed_object_generator.dart';

Builder fabricLibBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, LibDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: 'lib/**.dart',
      outputFile: 'lib/fabric.g.dart',
    );

Builder fabricTestBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: 'test/**.dart',
      outputFile: 'test/fabric.g.dart',
    );

Builder fabricExampleBuilder(BuilderOptions options) =>
    MergingBuilder<Definition, PackageDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: 'example/**.dart',
      outputFile: 'example/fabric.g.dart',
    );
