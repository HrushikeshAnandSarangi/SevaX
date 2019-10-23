import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum Flavor { APP, HUMANITY_FIRST, TULSI, TOM }

class FlavorValues {
  final String appName;
  final String timebankName;
  String timebankId;
  final String requestTitle;
  final String offertitle;
  final ThemeData theme;
  final Color buttonTextColor;
  final String timebankTitle;

  FlavorValues(
      {@required this.appName,
      @required this.timebankName,
      @required this.timebankId,
      this.requestTitle = 'Request',
      this.offertitle = 'Offer',
      this.theme,
      this.buttonTextColor = Colors.white,
      this.timebankTitle = 'Timebank'});
}

class FlavorConfig {
  static Flavor appFlavor;

  static FlavorValues get values {
    switch (appFlavor) {
      case Flavor.APP:
        return FlavorValues(
          appName: 'Seva Exchange',
          timebankId: '73d0de2c-198b-4788-be64-a804700a88a4',
          timebankName: 'Seva Exchange',
          offertitle: 'Offer',
          requestTitle: 'Request',
          buttonTextColor: Colors.black,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Color.fromARGB(255, 109, 110, 172),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            primaryColor: Color.fromARGB(255, 109, 110, 172),
            accentColor: Color.fromARGB(255, 239, 179, 100),
            indicatorColor: Colors.amberAccent,
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.white,
          ),
        );
        break;
      case Flavor.HUMANITY_FIRST:
        return FlavorValues(
          appName: 'Humanity First',
          timebankTitle: 'Yang Gang ',
          timebankId: 'ab7c6033-8b82-42df-9f41-3c09bae6c3a2',
          timebankName: 'Yang 2020',
          offertitle: 'Volunteer Offer',
          requestTitle: 'Campaign Request',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
                brightness: Brightness.light,
                color: Color.fromARGB(255, 4, 47, 110),
                elevation: 4,
                actionsIconTheme: IconThemeData(color: Colors.white),
                iconTheme: IconThemeData(color: Colors.white)),
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            primaryColor: Color.fromARGB(255, 4, 47, 110),
            accentColor: Colors.red[900],
            indicatorColor: Colors.red[900],
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.white,
          ),
        );
        break;
      case Flavor.TULSI:
        return FlavorValues(
          appName: 'Tulsi 2020',
          timebankId: '6897fefc-9380-4ca6-8373-5e7760bb31be',
          timebankName: 'Tulsi 2020',
          offertitle: 'Offer',
          requestTitle: 'Request',
          theme: ThemeData(
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
            bottomAppBarColor: Colors.red[900],
          ),
        );
        break;
      case Flavor.TOM:
        return FlavorValues(
            appName: 'Tom 2020',
            timebankId: 'f4b0b4c4-3d37-4514-b00b-ee424950c038',
            timebankName: 'Tom 2020',
            offertitle: 'Offer',
            requestTitle: 'Request',
            theme: ThemeData(
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
              accentColor: Color.fromARGB(255, 224, 100, 70),
              indicatorColor: Colors.white,
              primaryColorBrightness: Brightness.light,
              accentColorBrightness: Brightness.light,
              fontFamily: 'Montserrat',
              splashColor: Colors.grey,
              bottomAppBarColor: Color.fromARGB(255, 11, 40, 161),
            ));
        break;
      default:
        return FlavorValues(
          appName: 'Seva Exchange',
          timebankId: '73d0de2c-198b-4788-be64-a804700a88a4',
          timebankName: 'Seva Exchange',
          offertitle: 'Offer',
          requestTitle: 'Request',
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: Color.fromARGB(255, 109, 110, 172),
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 4,
              actionsIconTheme: IconThemeData(color: Colors.white),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            primaryColor: Color.fromARGB(255, 109, 110, 172),
            accentColor: Color(0xFF3f46c6),
            indicatorColor: Colors.amberAccent,
            primaryColorBrightness: Brightness.light,
            accentColorBrightness: Brightness.light,
            fontFamily: 'Montserrat',
            splashColor: Colors.grey,
            bottomAppBarColor: Colors.white,
          ),
        );
    }
  }
}
