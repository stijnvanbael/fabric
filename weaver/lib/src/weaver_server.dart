import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

final Logger log = Logger('weaver_server');

class WeaverServer {
  final Handler handler;
  final int port;

  WeaverServer({
    required this.handler,
    this.port = 8080,
  });

  Future start() async {
    var server = await serve(handler, '0.0.0.0', port);
    log.info('Serving at http://${server.address.host}:${server.port}');
  }
}
