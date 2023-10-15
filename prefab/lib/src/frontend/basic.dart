import 'package:templatr/html.dart';
import 'package:templatr/shoelace.dart' as sl;

abstract class BasicFrontendTemplate {
  String page(List<String> content) => _template(menu(), content);

  String _template(List<String> menuItems, List<String> content) =>
      html(lang: 'en', content: [
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
          link(rel: LinkRel.stylesheet, href: '/styles/prefab.css'),
          script(
            type: 'module',
            src:
                'https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.17/dist/shoelace/shoelace.esm.js',
          ),
        ]),
        body([
          aside([
            sl.menu(
              items: menuItems,
            )
          ]),
          main(content),
        ])
      ]);

  List<String> menu();
}
