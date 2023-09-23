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
  final String message;

  TodoController(
    this.repository,
    @Config('controller.message') this.message,
  );

  @Post('/todos')
  Future<Response> addTodo(@body Todo todo) async {
    final created = await repository.save(todo);
    return Response(201, body: message, headers: {
      'content-type': 'application/json',
      'location': '/todos/$created'
    });
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
