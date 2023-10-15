import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_example/todo/todo.dart';
import 'package:templatr/html.dart';
import 'package:templatr/shoelace.dart' as sl;

import '../prefab_frontend.g.dart';

abstract mixin class TodoController {
  Todo$Repository get repository;

  ApplicationFrontendTemplate get frontend;

  @Get('/todos')
  Future<Response> getTodos() async {
    final todos = await repository.search(
      Todo$Field.description,
      SortDirection.ascending,
      null,
      null,
      null,
    );
    return Response.ok(
      frontend.page(
        [
          h1('Todos'),
          ul(
            todos.map((todo) => li(sl.checkbox(todo.description))).toList(),
          ),
        ],
      ),
      headers: {'content-type': 'text/html'},
    );
  }
}
