A library that combines `fabric` with the power of `box` and `controller`.

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
