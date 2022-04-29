/// Support for doing something awesome.
///
/// More dartdocs go here.
library fabric_generator;

import 'package:build/build.dart';
import 'package:fabric_generator/src/managed_object_generator.dart';
import 'package:merging_builder/merging_builder.dart';

export 'src/managed_object_generator.dart';

Builder fabricLibBuilder(BuilderOptions options) =>
    MergingBuilder<MapEntry<String, String>, LibDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: 'lib/*.dart',
      outputFile: 'lib/fabric.g.dart',
    );

Builder fabricTestBuilder(BuilderOptions options) =>
    MergingBuilder<MapEntry<String, String>, PackageDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: 'test/*.dart',
      outputFile: 'test/fabric.g.dart',
    );
