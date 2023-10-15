import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:templatr/shoelace.dart';

const Create create = Create();
const Update update = Update();
const GetByKey getByKey = GetByKey();
const Search search = Search();

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
  });
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
