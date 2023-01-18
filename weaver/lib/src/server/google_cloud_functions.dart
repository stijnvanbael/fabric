import 'dart:async';

import 'package:functions_framework/functions_framework.dart';
import 'package:functions_framework/serve.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final Logger _log = Logger('google_cloud_functions_weaver_server');

class GoogleCloudFunctionsServer {
  final Handler handler;

  GoogleCloudFunctionsServer({
    required this.handler,
  });

  Future start() async {
    await serve([], _resolveFunctionName);
    _log.info('Serving Google Cloud Function at 0.0.0.0:8080');
  }

  FunctionTarget? _resolveFunctionName(String name) {
    switch (name) {
      case 'function':
        return FunctionTarget.http((request) => dispatch(handler, request));
      default:
        return null;
    }
  }
}

@CloudFunction()
FutureOr<Response> dispatch(Handler requestHandler, Request request) =>
    requestHandler(request);
