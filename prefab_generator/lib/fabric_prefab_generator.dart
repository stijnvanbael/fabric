library fabric_prefab_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/controller_builder.dart';
import 'src/extension_builder.dart';
import 'src/repository_builder.dart';

Builder prefabBuilder(BuilderOptions options) => PartBuilder([
      ExtensionBuilder(),
      ControllerBuilder(),
      RepositoryBuilder(),
    ], '.prefab.g.dart');
