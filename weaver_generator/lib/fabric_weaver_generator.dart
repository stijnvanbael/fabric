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

Builder dispatcherBuilder(BuilderOptions options) {
  var folder = options.config['folder'];
  return MergingBuilder<Definition, PackageDir>(
    generator: DispatcherGenerator(),
    inputFiles: '$folder/**.dart',
    outputFile: '$folder/weaver_dispatcher.g.dart',
  );
}

Builder boxRegistryBuilder(BuilderOptions options) {
  var folder = options.config['folder'];
  return MergingBuilder<Definition, PackageDir>(
    generator: BoxRegistryGenerator(),
    inputFiles: '$folder/**.dart',
    outputFile: '$folder/weaver_box_registry.g.dart',
  );
}

Builder applicationBuilder(BuilderOptions options) {
  var folder = options.config['folder'];
  return MergingBuilder<dynamic, PackageDir>(
    generator: ApplicationGenerator(folder),
    inputFiles: '$folder/**.dart',
    outputFile: '$folder/weaver_application.g.dart',
  );
}
