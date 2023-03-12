import 'dart:async';

import 'package:logging/logging.dart';

mixin MetaLogger {
  late final Logger _logger = Logger(runtimeType.toString());

  void shout(String Function() message,
          [Object? error, StackTrace? stackTrace]) =>
      _log(Level.SHOUT, message, error, stackTrace);

  void severe(String Function() message,
          [Object? error, StackTrace? stackTrace]) =>
      _log(Level.SEVERE, message, error, stackTrace);

  void warning(String Function() message,
          [Object? error, StackTrace? stackTrace]) =>
      _log(Level.WARNING, message, error, stackTrace);

  void info(String Function() message) => _log(Level.INFO, message);

  void fine(String Function() message) => _log(Level.FINE, message);

  void finer(String Function() message) => _log(Level.FINER, message);

  void finest(String Function() message) => _log(Level.FINEST, message);

  void _log(
    Level level,
    String Function() message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_logger.isLoggable(level)) {
      _logger.log(level, MetaMessage(message(), _meta), error, stackTrace);
    }
  }

  T withMeta<T>(T Function() runnable) => runZoned(
        runnable,
        zoneValues: {#logging: <String, String>{}},
      );

  void setMeta(String key, String value) => _requiredMeta[key] = value;

  void clearMeta(String key) => _requiredMeta.remove(key);

  Map<String, String> get _requiredMeta {
    if (_meta == null) {
      throw StateError(
          'No logging metadata available, wrap with withMeta() first');
    }
    return _meta!;
  }

  Map<String, String>? get _meta =>
      Zone.current[#logging] as Map<String, String>?;
}

class MetaMessage {
  final String message;
  final Map<String, String>? metadata;

  MetaMessage(this.message, this.metadata);

  @override
  String toString() => message;
}
