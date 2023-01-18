import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

final Logger _log = Logger('shelf_weaver_server');

class ShelfWeaverServer {
  final Handler handler;
  final int port;

  ShelfWeaverServer({
    required this.handler,
    this.port = 8080,
  });

  Future start() async {
    var server = await serve(handler, '0.0.0.0', port);
    _log.info('Serving at http://${server.address.host}:${server.port}');
  }
}
