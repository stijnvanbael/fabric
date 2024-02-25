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
    final hasFrontend = !annotation.objectValue.getField('frontend')!.isNull;
    return hasFrontend
        ? '''
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
    '''
        : '';
  }

  String _listPage(ClassElement clazz) {
    final entityName = clazz.name;
    // TODO: make search call dynamic based on properties
    final fields = clazz.fields
        .where((field) =>
            !field.isStatic &&
            !field.isPrivate &&
            !field.hasMeta(Key) &&
            field.type.convertsToPrimitive)
        .toList();
    return '''
    @Get('/${entityName.paramCase.plural}')
    Future<Response> list${entityName.plural}() async {
      final entities = await repository.search(
        null,
        SortDirection.ascending,
        ${fields.map((e) => 'null').join(',')}
      );
      return Response.ok(
        frontend.page('${entityName.plural.sentenceCase}', frontend.list(entities)),
        headers: {'content-type': 'text/html'},
      );
    }
    ''';
  }
}
