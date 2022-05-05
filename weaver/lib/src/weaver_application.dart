import 'package:box/box.dart';
import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

final Logger log = Logger('weaver');

class WeaverApplication {
  final Fabric fabric;
  final Factory<Box>? databaseFactory;

  WeaverApplication(this.fabric, {this.databaseFactory});

  Future start() async {
    _configureLogging();
    if (databaseFactory != null) {
      fabric.registerFactory(databaseFactory!);
    }
    var handler = _createRequestHandler();

    var server = await serve(handler, '0.0.0.0', 8080); // TODO: configure port
    log.info('Serving at http://${server.address.host}:${server.port}');
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
