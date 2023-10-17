import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:intl/intl.dart';
import 'package:templatr/html.dart' as h;
import 'package:templatr/shoelace.dart' as sl;

abstract class BasicFrontendTemplate {
  final Registry registry;
  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  BasicFrontendTemplate(this.registry);

  String page(List<String> content) => h.html(lang: 'en', content: [
        h.head([
          h.meta(charset: 'utf-8'),
          h.meta(httpEquiv: 'X-UA-Compatible', content: 'IE=edge'),
          h.meta(
            name: 'viewport',
            content: 'width=device-width, initial-scale=1.0',
          ),
          h.title('Todos'),
          h.link(
            rel: h.LinkRel.stylesheet,
            href:
                'https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.17/dist/shoelace/shoelace.css',
          ),
          h.link(rel: h.LinkRel.stylesheet, href: '/styles/prefab.css'),
          h.script(
            type: 'module',
            src:
                'https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.17/dist/shoelace/shoelace.esm.js',
          ),
        ]),
        h.body([
          h.aside([
            sl.menu(
              items: menu(),
            )
          ]),
          h.main(content),
        ])
      ]);

  List<String> list<T>(List<T> items) {
    final entity = registry.lookup<T>();
    return [
      h.h1(entity.name),
      h.div([
        h.table([
          h.thead([
            h.tr(entity.fieldAccessors.keys
                .where((field) => !entity.keyFields.contains(field))
                .map((field) => h.th([field.sentenceCase]))
                .toList()),
          ]),
          h.tbody(items.map((item) => listItem(item, entity)).toList()),
        ]),
      ], classes: [
        'panel'
      ])
    ];
  }

  List<String> menu();

  String listItem<T>(T item, EntitySupport<T> entity) {
    final cells = entity.fieldAccessors.entries
        .where((field) => !entity.keyFields.contains(field.key))
        .map(
            (field) => h.td([formatCell(item, field.key, field.value, entity)]))
        .toList();
    return h.tr(cells);
  }

  String formatCell<T>(
    T item,
    String fieldName,
    dynamic Function(T) fieldAccessor,
    EntitySupport<T> entity,
  ) {
    final value = fieldAccessor(item);
    return switch (value) {
      String s => s,
      num n => n.toString(),
      bool b => sl.checkbox('', checked: b, disabled: true),
      DateTime d => dateFormat.format(d),
      _ => throw ArgumentError('Unsupported type: ')
    };
  }
}
