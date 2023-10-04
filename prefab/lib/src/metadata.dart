import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';

const Create create = Create();
const Update update = Update();
const GetByKey getByKey = GetByKey();
const Search search = Search();

class Prefab extends JsonSerializable implements Entity, Validatable {
  @override
  final String? name;
  final Set<UseCase> useCases;
  final Set<Type> controllerMixins;

  const Prefab({
    this.name,
    this.useCases = const {},
    this.controllerMixins = const {},
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
