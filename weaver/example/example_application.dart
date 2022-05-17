import 'dart:io';

import 'package:box/box.dart';
import 'package:fabric_metadata/fabric_metadata.dart';

import 'weaver_application.g.dart';

void main() {
  print(Directory.current);
  startApplication(
    factories: {
      TypeSpec(Box): (fabric) => MemoryBox(fabric.getInstance()),
    },
    configDir: 'example/conf',
  );
}
