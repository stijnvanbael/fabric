import 'dart:async';

import 'package:logging/logging.dart';

mixin MetaLogger {
  late final Logger _logger = Logger(runtimeType.toString());

  void shout(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.shout(MetaMessage(message, _meta), error, stackTrace);

  void severe(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(MetaMessage(message, _meta), error, stackTrace);

  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.warning(MetaMessage(message, _meta), error, stackTrace);

  void info(String message) => _logger.info(MetaMessage(message, _meta));

  void fine(String message) => _logger.fine(MetaMessage(message, _meta));

  void finer(String message) => _logger.finer(MetaMessage(message, _meta));

  void finest(String message) => _logger.finest(MetaMessage(message, _meta));

  void setMeta(String key, String value) => _meta[key] = value;

  void clearMeta(String key) => _meta.remove(key);

  Map<String, String> get _meta =>
      Zone.current[#logging] as Map<String, String>;
}

class MetaMessage {
  final String message;
  final Map<String, String> metadata;

  MetaMessage(this.message, this.metadata);

  @override
  String toString() => message;
}
