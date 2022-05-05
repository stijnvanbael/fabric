import 'package:box/box.dart';
import 'package:controller/controller.dart';

part 'todo.g.dart';

@validatable
@entity
class Todo {
  @key
  final String? id;
  final String description;

  Todo({
    this.id,
    required this.description,
  });

  Todo.fromJson(Map<String, dynamic> json)
      : this(
          id: json['id'],
          description: json['description'],
        );

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
      };
}
