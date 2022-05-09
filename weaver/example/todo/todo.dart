import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@validatable
@entity
@JsonSerializable()
class Todo {
  @key
  final String? id;
  final String description;

  Todo({
    this.id,
    required this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoToJson(this);
}
