import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_weaver/src/weaver_config.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

final Logger log = Logger('weaver_application');

class WeaverApplication {
  final Fabric fabric;
  final Factory<Box>? databaseFactory;
  final String configDir;

  WeaverApplication(
    this.fabric, {
    this.databaseFactory,
    required this.configDir,
  }) {
    _configureDefaults();
  }

  Future start() async {
    _configureLogging();
    log.info('Starting application');
    var config = loadConfig(configDir);
    fabric.registerConfigMap(config);
    if (databaseFactory != null) {
      fabric.registerFactory(databaseFactory!);
    }
    var handler = _createRequestHandler();

    var server = await serve(handler, '0.0.0.0', fabric.getInt('server.port'));
    log.info('Serving at http://${server.address.host}:${server.port}');
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  Handler _createRequestHandler() {
    var dispatcher = createRequestDispatcher(
      fabric.getInstances<DispatcherBuilder>().toList(),
      corsEnabled: true,
    );
    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(dispatcher);
    return handler;
  }

  void _configureLogging() {
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}
