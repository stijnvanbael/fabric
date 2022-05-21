import 'dart:io';

import 'weaver_application.g.dart';

void main(List<String> arguments) {
  print(Directory.current);
  startApplication(configDir: 'example/conf', arguments: arguments);
}
