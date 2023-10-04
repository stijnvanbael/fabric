import 'package:fabric_prefab_example/todo/todo.dart';
import 'package:templatr/html.dart';
import 'package:templatr/shoelace.dart' as sl;

String listTodos(List<Todo> todos) => html(lang: 'en', content: [
      head([
        meta(charset: 'utf-8'),
        meta(httpEquiv: 'X-UA-Compatible', content: 'IE=edge'),
        meta(
          name: 'viewport',
          content: 'width=device-width, initial-scale=1.0',
        ),
        title('Todos'),
        link(
          rel: LinkRel.stylesheet,
          href:
              'https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.17/dist/shoelace/shoelace.css',
        ),
        script(
          type: 'module',
          src:
              'https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.17/dist/shoelace/shoelace.esm.js',
        ),
      ]),
      body([
        h1('Todos'),
        ul(
          todos.map((todo) => li(sl.checkbox(todo.description))).toList(),
        ),
      ])
    ]);
