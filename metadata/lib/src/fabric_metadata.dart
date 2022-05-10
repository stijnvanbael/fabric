const managed = Managed();

class Managed {
  final String? name;

  const Managed({this.name});
}

abstract class Spec {
  const Spec();
}

class TypeSpec extends Spec {
  final Type type;

  const TypeSpec(this.type);

  @override
  String toString() => "type = $type";

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TypeSpec && type == other.type;

  @override
  int get hashCode => type.hashCode;
}

class NameSpec extends Spec {
  final String name;

  const NameSpec(this.name);

  @override
  String toString() => "name = $name";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameSpec &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Definition {
  final Type type;
  final String? name;

  const Definition({
    required this.type,
    this.name,
  });
}

class Config {
  final String name;

  const Config(this.name);
}
