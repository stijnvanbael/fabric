import 'package:analyzer/dart/element/element.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/frontend_builder.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:source_gen/source_gen.dart';

class BasicFrontendBuilder extends FrontendBuilder {
  static const menuItem = 'menu-item';

  BasicFrontendBuilder() : super('basic');

  @override
  String compose(List<Map<String, String>> components) {
    final menuItems = components.map((e) => e[menuItem]).join(',');
    return """
    import 'package:fabric_prefab/fabric_prefab.dart';
    import 'package:templatr/shoelace.dart' as sl;
    
    @managed
    class ApplicationFrontendTemplate extends BasicFrontendTemplate {
      ApplicationFrontendTemplate(Registry registry) : super(registry);
    
      @override
      List<String> menu() => [$menuItems];
    }
    """;
  }

  @override
  FrontendComponents generateComponents(
    ClassElement clazz,
    ConstantReader frontend,
  ) {
    return FrontendComponents(name, {
      menuItem: _generateMenuItem(clazz, frontend),
    });
  }

  String _generateMenuItem(ClassElement clazz, ConstantReader frontend) {
    final icon = frontend.read('icon');
    final iconHtml = !icon.isNull
        ? icon
            .read('name')
            .stringValue
            .apply((it) => " + sl.icon(sl.Icon.$it, slot: 'prefix')")
        : '';
    return "sl.menuItem('${clazz.name.sentenceCase.plural}'$iconHtml)";
  }
}
