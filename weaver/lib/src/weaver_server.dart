import 'package:controller/controller.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

final Logger log = Logger('weaver_server');

class WeaverServer {
  final List<DispatcherBuilder> dispatcherBuilders;
  final int port;

  WeaverServer(
    this.dispatcherBuilders, {
    required this.port,
  });

  Future start() async {
    var handler = _createRequestHandler();

    var server = await serve(handler, '0.0.0.0', port);
    log.info('Serving at http://${server.address.host}:${server.port}');
  }

  Handler _createRequestHandler() {
    var dispatcher = createRequestDispatcher(
      dispatcherBuilders,
      corsEnabled: true,
    );
    var handler =
        const Pipeline().addMiddleware(logRequests()).addHandler(dispatcher);
    return handler;
  }
}
