import 'package:args/args.dart';
import 'package:controller/controller.dart';
import 'package:fabric_manager/fabric_manager.dart';
import 'package:fabric_metadata/fabric_metadata.dart';
import 'package:fabric_weaver/src/weaver_config.dart';
import 'package:fabric_weaver/src/weaver_server.dart';
import 'package:logging/logging.dart';

final Logger log = Logger('weaver_application');
final ArgParser argumentParser = ArgParser()
  ..addOption('env', abbr: 'e', defaultsTo: '');

class WeaverApplication {
  final Fabric fabric;
  final Map<Spec, Factory> factories;
  final String configDir;
  final List<String> arguments;

  WeaverApplication(
    this.fabric, {
    this.factories = const {},
    required this.configDir,
    this.arguments = const [],
  }) {
    _configureDefaults();
    _configureLogging();
    _parseArguments();
  }

  Future start() async {
    var environment = fabric.getString('env');
    log.info('Starting application for environment ${environment.isNotEmpty ? environment : 'default'}');
    var config = <String, String>{};
    if (environment.isNotEmpty) {
      config = loadConfig(configDir, '');
    }
    config.addAll(loadConfig(configDir, environment));
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

  void _parseArguments() {
    var results = argumentParser.parse(arguments);
    fabric.registerConfig('env', results['env']);
  }
}
