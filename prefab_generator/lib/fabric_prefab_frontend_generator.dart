library fabric_prefab_generator;

import 'package:build/build.dart';
import 'package:fabric_prefab_generator/src/frontend_builder.dart';
import 'package:merging_builder_svb/merging_builder_svb.dart';

Builder templateBuilder(BuilderOptions options) {
  var folder = options.config['folder'];
  return MergingBuilder<FrontendComponents?, PackageDir>(
    generator: FrontendBuilderDispatcher(),
    inputFiles: '$folder/**.dart',
    outputFile: '$folder/prefab_frontend.g.dart',
  );
}
