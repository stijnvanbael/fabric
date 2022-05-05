import 'dart:convert';

import 'package:controller/controller.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:shelf/shelf.dart';

import 'todo.dart';
import 'todo_repository.dart';

part 'todo_controller.g.dart';

@controller
@managed
class TodoController {
  final TodoRepository repository;

  TodoController(this.repository);

  @Post('/todos')
  Future<Response> addTodo(@body Todo todo) async {
    await repository.save(todo);
    return Response.ok("added");
  }

  @Get('/todos/:id')
  Future<Response> getTodo(String id) async {
    var todo = await repository.findById(id);
    if (todo == null) {
      return Response.notFound("No todo found with id $id");
    }
    return Response.ok(jsonEncode(todo.toJson()));
  }
}
