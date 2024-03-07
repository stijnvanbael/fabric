import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:templatr/shoelace.dart';
import 'package:uuid/uuid_value.dart';

const Create create = Create();
const GetByKey getByKey = GetByKey();
const Update update = Update();
const Search search = Search();
const UuidConverter uuidConverter = UuidConverter();
const Payload requestPayload = Payload(createFactory: true);

class Prefab extends Payload implements Entity {
  @override
  final String? name;
  final String baseUrl;
  final Set<ClassUseCase> useCases;
  final Set<Type> controllerMixins;
  final Set<Type> repositoryMixins;
  final Frontend? frontend;
  final bool abstract;

  const Prefab({
    this.name,
    this.baseUrl = '/#entity',
    this.useCases = const {},
    this.controllerMixins = const {},
    this.repositoryMixins = const {},
    this.frontend,
    this.abstract = false,
  }) : super(createToJson: true, createFactory: !abstract);
}

class Create extends ClassUseCase {
  const Create([HttpRequest request = const Post('')]) : super(request);
}

class GetByKey extends ClassUseCase {
  const GetByKey([HttpRequest request = const Get('/:id')])
      : super(request); // TODO: Replace :id with key placeholder
}

class Search extends ClassUseCase {
  const Search([HttpRequest request = const Get('')]) : super(request);
}

class Update extends MethodUseCase {
  const Update([HttpRequest request = const Put('')]) : super(request);
}

abstract class UseCase {
  final HttpRequest request;

  const UseCase(this.request);
}

abstract class ClassUseCase extends UseCase {
  const ClassUseCase(super.request);
}

abstract class MethodUseCase extends UseCase {
  const MethodUseCase(super.request);
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

class Payload extends JsonSerializable implements Validatable {
  const Payload({
    bool createToJson = true,
    bool createFactory = false,
  }) : super(
          createToJson: createToJson,
          createFactory: createFactory,
          converters: const [uuidConverter],
        );
}
