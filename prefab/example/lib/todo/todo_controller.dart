import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_example/todo/todo.dart';
import 'package:intl/intl.dart';
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
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    return Response.ok(
      frontend.page(
        [
          h1('Todos'),
          div([
            table([
              thead([
                tr([
                  th(['Description']),
                  th(['Done']),
                  th(['Created']),
                ]),
              ]),
              tbody(
                todos
                    .map((todo) => tr([
                          td([todo.description]),
                          td([
                            sl.checkbox('', checked: todo.done, disabled: true)
                          ]),
                          td([dateFormat.format(todo.created)]),
                        ]))
                    .toList(),
              )
            ]),
          ], classes: [
            'panel'
          ])
        ],
      ),
      headers: {'content-type': 'text/html'},
    );
  }
}
