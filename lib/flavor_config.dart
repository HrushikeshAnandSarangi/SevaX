import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum Flavor {
  APP,
  HUMANITY_FIRST,
  TULSI,
  TOM
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
        return '73d0de2c-198b-4788-be64-a804700a88a4';
        break;
      case Flavor.HUMANITY_FIRST:
        return 'ab7c6033-8b82-42df-9f41-3c09bae6c3a2';
        break;
      case Flavor.TULSI:
        return '6897fefc-9380-4ca6-8373-5e7760bb31be';
        break;
      case Flavor.TOM :
      return 'f4b0b4c4-3d37-4514-b00b-ee424950c038';
      break;
    }
  }

  static get timebankName {
    switch (appFlavor) {
      case Flavor.APP:
         return 'Seva Exchange';
        break;
      case Flavor.HUMANITY_FIRST:
        return 'Yang 2020';
        break;
      case Flavor.TULSI:
        return 'Tulsi 2020';
        break;
      case Flavor.TOM :
      return 'Tom 2020';
      break;
    }
  }

  static get theme {
    switch (appFlavor) {
      case Flavor.APP:
        return ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Color(0xFF6f76f6),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            primaryColor: Color(0xFF6f76f6),
            accentColor: Color(0xFF3f46c6),
            indicatorColor: Colors.amberAccent,
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.white);
        break;
      case Flavor.HUMANITY_FIRST:
        return ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Colors.indigo,
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white)
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
              color: Color.fromARGB(255, 26, 50, 102),
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white),
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
        case Flavor.TOM:
        return ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Color.fromARGB(255, 11, 40, 161),
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            primaryColor: Color.fromARGB(255, 11, 40, 161),
            accentColor: Color.fromARGB(255,224,100,70),
            indicatorColor: Colors.white,
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Color.fromARGB(255,224,100,70),);
        break;
    }
  }
}
