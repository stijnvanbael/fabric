library fabric_prefab_generator;

import 'package:build/build.dart';
import 'package:fabric_prefab_generator/src/use_cases/use_case_builder.dart';
import 'package:source_gen/source_gen.dart';

import 'src/controller_builder.dart';
import 'src/extension_builder.dart';
import 'src/repository_builder.dart';

Builder defaultExtensions(BuilderOptions options) =>
    PartBuilder(UseCaseBuilder.defaults, '.prefab-default.g.dart');

Builder prefabBuilder(BuilderOptions options) => PartBuilder([
      ExtensionBuilder(),
      ControllerBuilder(),
      RepositoryBuilder(),
    ], '.prefab.g.dart');
