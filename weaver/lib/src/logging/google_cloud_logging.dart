import 'dart:convert';

import 'package:logging/logging.dart';

void configureGoogleCloudLogging() {
  Logger.root.onRecord.listen((record) {
    print(jsonEncode({
      'logName': record.loggerName,
      'timestamp': record.time.toIso8601String(),
      'severity': _mapToCloudLogLevel(record.level),
      'message': record.message,
    }));
  });
}

String _mapToCloudLogLevel(Level level) {
  if (level == Level.FINE) {
    return 'DEBUG';
  } else if (level == Level.INFO) {
    return 'INFO';
  } else if (level == Level.WARNING) {
    return 'WARNING';
  } else if (level == Level.SEVERE) {
    return 'ERROR';
  } else if (level == Level.SHOUT) {
    return 'CRITICAL';
  } else {
    return 'DEFAULT';
  }
}
