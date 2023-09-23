import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';

const Create create = Create();
const GetByKey getByKey = GetByKey();

class Prefab extends JsonSerializable implements Entity, Validatable {
  final String? name;
  final Set<UseCase> useCases;

  const Prefab({this.name, this.useCases = const {}});
}

class Create extends UseCase {
  const Create() : super(const Post(''));
}

class GetByKey extends UseCase {
  const GetByKey(): super(const Get('/:id'));
}

class UseCase {
  final HttpRequest request;

  const UseCase(this.request);
}
