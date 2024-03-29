/// Support for doing something awesome.
///
/// More dartdocs go here.
library fabric_generator;

import 'package:build/build.dart';
import 'package:fabric_generator/src/managed_object_generator.dart';
import 'package:merging_builder_svb/merging_builder_svb.dart';

export 'src/managed_object_generator.dart';

Builder fabricBuilder(BuilderOptions options) {
  var folder = options.config['folder'];
  return MergingBuilder<Definition, PackageDir>(
      generator: ManagedObjectGenerator(),
      inputFiles: '$folder/**.dart',
      outputFile: '$folder/fabric.g.dart',
    );
}
