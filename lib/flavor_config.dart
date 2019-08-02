import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum Flavor {
  APP,
  HUMANITY_FIRST,
  TULSI,
}

class FlavorValues {
  final String name;

  FlavorValues({
    @required this.name,
  });
}

class FlavorConfig {
  static Flavor appFlavor;
  static get timebankId {
    switch (appFlavor) {
      case Flavor.APP:
        // TODO: Handle this case.
        break;
      case Flavor.HUMANITY_FIRST:
        return 'ajilo297@gmail.com*1559128156543';
        break;
      case Flavor.TULSI:
        return 'ajilo297@gmail.com*1563778489754';
        break;
    }
  }

  static get timebankName {
    switch (appFlavor) {
      case Flavor.APP:
        // TODO: Handle this case.
        break;
      case Flavor.HUMANITY_FIRST:
        return 'Yang 2020';
        break;
      case Flavor.TULSI:
        return 'Tulsi 2020';
        break;
    }
  }

  static get theme {
    switch (appFlavor) {
      case Flavor.APP:
        // TODO: Handle this case.
        break;
      case Flavor.HUMANITY_FIRST:
        return ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Colors.white,
              elevation: 1,
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            primaryColor: Colors.indigo,
            accentColor: Colors.red[900],
            indicatorColor: Colors.red[900],
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.white);
        break;
      case Flavor.TULSI:
        return ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Colors.white,
              elevation: 1,
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            primaryColor: Color.fromARGB(255, 26, 50, 102),
            accentColor: Colors.red[900],
            indicatorColor: Colors.white,
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.red[900],);
        break;
    }
  }
}
