import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:fabric_prefab/fabric_prefab.dart';
import 'package:fabric_prefab_generator/src/util.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';

class FrontendControllerBuilder extends GeneratorForAnnotation<Prefab> {
  final Logger logger = Logger('ControllerBuilder');

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final clazz = element as ClassElement;
    final entityName = clazz.name;
    return '''
    @controller
    @managed
    class $entityName\$FrontendController {
      final $entityName\$Repository repository;
      final ApplicationFrontendTemplate frontend;
      
      $entityName\$FrontendController(
        this.repository,
        this.frontend,
      );
      
      ${_listPage(clazz)}
    }
    ''';
  }

  String _listPage(ClassElement clazz) {
    final entityName = clazz.name;
    return '''
    @Get('/${entityName.paramCase.plural}')
    Future<Response> list${entityName.plural}() async {
      final entities = await repository.search(
        $entityName\$Field.description,
        SortDirection.ascending,
        null,
        null,
        null,
      );
      return Response.ok(
        frontend.page(frontend.list(entities)),
        headers: {'content-type': 'text/html'},
      );
    }
    ''';
  }
}
