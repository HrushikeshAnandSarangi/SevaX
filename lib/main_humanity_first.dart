import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

void main() {
  FlavorConfig config = FlavorConfig(
    flavor: Flavor.HUMANITY_FIRST,
    values: FlavorValues(name: 'App'),
  );

  runApp(MainApplication());
}

class MainApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
