import 'package:fabric_manager/fabric_manager.dart';

void main() {
  var fabric = Fabric();

  fabric.registerFactory((fabric) =>
      GreetingService(fabric.getString("greetingService.greeting")));
  fabric.registerConfig("greetingService.greeting", "Howdy");

  var greetingService = fabric.getInstance<GreetingService>();
  print(greetingService.greet("Joe"));
}

class GreetingService {
  final String greeting;

  GreetingService(this.greeting);

  String greet(String name) => "$greeting $name!";
}
