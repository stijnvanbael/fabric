An application bootstrapper that combines `fabric_manager` with the power of `box`, `controller` and `retrofit`.

## Features

Wires your web application with a database and all required dependencies.

## Getting started

Create file `bin/server.dart` with contents:

```dart
import '../lib/weaver_application.g.dart';

main(List<String> arguments) async {
  application = startApplication(arguments: arguments);
}
```

See the respective libraries on how to use them.
