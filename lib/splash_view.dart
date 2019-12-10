import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBodyColor(),
    );
  }

  Color getBodyColor() {
    switch (FlavorConfig.appFlavor) {
      case Flavor.APP:
        return Colors.purple;
      case Flavor.HUMANITY_FIRST:
        return Colors.indigo;
      case Flavor.TULSI:
        return Colors.red[100];
      default:
        return Colors.amber;
    }
  }
}
