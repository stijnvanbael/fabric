import 'package:box/box.dart';

import 'weaver_application.g.dart';

void main() {
  startApplication(
    (fabric) => MemoryBox(fabric.getInstance()),
    configDir: 'example/conf',
  );
}
