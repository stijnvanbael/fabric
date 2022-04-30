Fabric
------

Fabric is a dependency injection library.
Using a generator, it can automate the task of wiring dependencies for you.

## Features

* A central registry for registering dependencies
* A generator to automatically generate wiring code

## Getting started

Add the Fabric libraries to pubspec.yaml:

```yaml
dependencies:
  fabric_metadata: 0.0.1
  fabric_manager: 0.0.1

dev_dependencies:
  build_runner: ^2.1.10
  fabric_generator: 0.0.1
```

## Usage

Add the `@managed` annotation to the classes you want to manage dependencies for:

```dart
@managed
class FooService {
  final FooRepository repository;
  
  FooService(this.repository);
}

@managed
class PostgresqlFooRepository implements FooRepository {
  
}
```

Generate wiring code:

```shell
dart pub get
dart run build_runner build 
```

Import the generated code and get the stuff you need:

```dart
import 'fabric.g.dart';

main() {
  var fabric = createFabric();
  var service = fabric.getInstance<FooService>();
}
```