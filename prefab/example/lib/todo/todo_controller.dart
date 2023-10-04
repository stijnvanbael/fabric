import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_example/todo/todo.dart';
import 'package:fabric_prefab_example/todo/todo.template.dart';

abstract mixin class TodoController {
  Todo$Repository get repository;

  @Get('/www/todos')
  Future<Response> getTodos() async => Response.ok(
        listTodos(await repository.search(
            null, SortDirection.ascending, null, null, null)),
        headers: {'content-type': 'text/html'},
      );
}
