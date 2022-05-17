import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:fabric_weaver/src/weaver_config.dart';
import 'package:fabric_weaver/src/weaver_server.dart';
import 'package:logging/logging.dart';

final Logger log = Logger('weaver_application');

class WeaverApplication {
  final Fabric fabric;
  final Map<Spec, Factory> factories;
  final String configDir;

  WeaverApplication(
    this.fabric, {
    this.factories = const {},
    required this.configDir,
  }) {
    _configureDefaults();
  }

  Future start() async {
    _configureLogging();
    log.info('Starting application');
    var config = loadConfig(configDir);
    fabric.registerConfigMap(config);
    for (var entry in factories.entries) {
      fabric.register(entry.key, entry.value);
    }

    WeaverServer(
      fabric.getInstances<DispatcherBuilder>().toList(),
      port: fabric.getInt('server.port'),
    ).start();
  }

  void _configureDefaults() {
    fabric.registerConfig('server.port', '8080');
  }

  void _configureLogging() {
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
}
