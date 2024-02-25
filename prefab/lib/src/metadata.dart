import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:templatr/shoelace.dart';
import 'package:uuid/uuid_value.dart';

const Create create = Create();
const Update update = Update();
const GetByKey getByKey = GetByKey();
const Search search = Search();
const UuidConverter uuidConverter = UuidConverter();

class Prefab extends JsonSerializable implements Entity, Validatable {
  @override
  final String? name;
  final Set<UseCase> useCases;
  final Set<Type> controllerMixins;
  final Frontend? frontend;

  const Prefab({
    this.name,
    this.useCases = const {},
    this.controllerMixins = const {},
    this.frontend,
  }) : super(converters: const [UuidConverter()]);
}

class Create extends UseCase {
  const Create([HttpRequest request = const Post('')]) : super(request);
}

class GetByKey extends UseCase {
  const GetByKey([HttpRequest request = const Get('/:id')])
      : super(request); // Replace :id with key placeholder
}

class Search extends UseCase {
  const Search([HttpRequest request = const Get('')])
      : super(request); // Replace :id with key placeholder
}

class Update extends UseCase {
  const Update([HttpRequest request = const Put('')]) : super(request);
}

abstract class UseCase {
  final HttpRequest request;

  const UseCase(this.request);
}

enum SortDirection { ascending, descending }

abstract class Frontend {
  final String name;

  const Frontend(this.name);
}

class BasicFrontend extends Frontend {
  final Icon? icon;

  const BasicFrontend(this.icon) : super('basic');
}

class UuidConverter extends JsonConverter<UuidValue, String> {
  const UuidConverter();

  @override
  UuidValue fromJson(String json) => UuidValue.fromString(json);

  @override
  String toJson(UuidValue object) => object.toString();
}
