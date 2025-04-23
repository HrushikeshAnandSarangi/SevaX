import 'package:universal_io/io.dart' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Flavor { APP, SEVA_DEV }

class FlavorValues {
  final String? googleMapsKey;
  final String? bundleId;
  final String? packageName;
  final String appName;
  final String timebankName;
  String timebankId;
  final String requestTitle;
  final String offertitle;
  final ThemeData? theme;
  final Color buttonTextColor;
  final Color? textColor;
  final String timebankTitle;
  final String cloudFunctionBaseURL;
  final String elasticSearchBaseURL;
  final String stripePublishableKey;
  final String androidPayMode;
  final String dynamicLinkUriPrefix;
  final String? envMode;

  FlavorValues({
    this.googleMapsKey,
    this.bundleId,
    this.packageName,
    required this.appName,
    required this.timebankName,
    required this.timebankId,
    this.requestTitle = 'Request',
    this.envMode,
    this.offertitle = 'Offer',
    this.theme,
    this.buttonTextColor = Colors.white,
    this.textColor,
    this.timebankTitle = 'Seva Community',
    required this.cloudFunctionBaseURL,
    required this.elasticSearchBaseURL,
    required this.stripePublishableKey,
    required this.androidPayMode,
    required this.dynamicLinkUriPrefix,
  });
}

class FlavorConfig {
  static Flavor? appFlavor;

  static FlavorValues get values {
    switch (appFlavor) {
      case Flavor.SEVA_DEV:
        return FlavorValues(
          googleMapsKey: io.Platform.isIOS
              ? "AIzaSyCK7MCjpmmpw1Zftm3YzIh-zM-9MR-j7lE"
              : "AIzaSyDqrcoceem6kuwknDPCt4ebO0Y9Hg5wMBs",
          bundleId: 'com.sevaexchange.dev',
          packageName: 'com.sevaexchange.dev',
          elasticSearchBaseURL: "https://dev-es.sevaexchange.com",
          stripePublishableKey: "pk_test_Ht3PQZ4PkldeKISCo6RYsl0v004ONW8832",
          androidPayMode: "test",
          cloudFunctionBaseURL:
              "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net",
          appName: 'Seva Dev',
          envMode: "DEV",
          timebankId: '73d0de2c-198b-4788-be64-a804700a88a4',
          timebankName: 'Seva Exchange',
          offertitle: 'Offer',
          requestTitle: 'Request',
          textColor: const Color(0xFFD8D8D8),
          buttonTextColor: Colors.black,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              titleTextStyle: const TextStyle(color: Colors.white),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              elevation: 0.7,
              actionsIconTheme: const IconThemeData(color: Colors.black54),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            primaryColor: const Color(0xFF766FE0),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              secondary: const Color.fromARGB(255, 255, 166, 35),
              brightness: Brightness.light,
            ),
            secondaryHeaderColor: Colors.white,
            indicatorColor: Colors.amberAccent.shade100,
            fontFamily: 'Europa',
            splashColor: Colors.grey,
            bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Color(0xFF766FE0),
              textTheme: ButtonTextTheme.primary,
              height: 39,
              shape: StadiumBorder(),
            ),
            primaryTextTheme: const TextTheme(
              labelLarge: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          dynamicLinkUriPrefix: "https://sevadev.page.link",
        );

      case Flavor.APP:
        return FlavorValues(
          googleMapsKey: io.Platform.isIOS
              ? "AIzaSyCK7MCjpmmpw1Zftm3YzIh-zM-9MR-j7lE"
              : "AIzaSyDqrcoceem6kuwknDPCt4ebO0Y9Hg5wMBs",
          bundleId: 'com.sevaexchange.app',
          packageName: 'com.sevaexchange.sevax',
          elasticSearchBaseURL: "https://es.sevaexchange.com",
          cloudFunctionBaseURL:
              "https://us-central1-sevaxproject4sevax.cloudfunctions.net",
          androidPayMode: "production",
          stripePublishableKey: "pk_live_UF4dJaTWW2zXECJ5xdzuAe7P00ga985PfN",
          appName: 'Seva Exchange',
          envMode: "PROD",
          timebankId: '73d0de2c-198b-4788-be64-a804700a88a4',
          timebankName: 'Seva Exchange',
          offertitle: 'Offer',
          requestTitle: 'Request',
          buttonTextColor: Colors.black,
          textColor: const Color(0xFFD8D8D8),
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              titleTextStyle: const TextStyle(color: Colors.white),
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              elevation: 0.7,
              actionsIconTheme: const IconThemeData(color: Colors.white),
            ),
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            primaryColor: const Color(0xFF766FE0),
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              secondary: const Color.fromARGB(255, 255, 166, 35),
              brightness: Brightness.light,
            ),
            secondaryHeaderColor: Colors.white,
            indicatorColor: Colors.amberAccent.shade100,
            fontFamily: 'Europa',
            splashColor: Colors.grey,
            bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
            inputDecorationTheme: const InputDecorationTheme(
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            buttonTheme: const ButtonThemeData(
              buttonColor: Color(0xFF766FE0),
              textTheme: ButtonTextTheme.primary,
              height: 39,
              shape: StadiumBorder(),
            ),
            primaryTextTheme: const TextTheme(
              labelLarge: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          dynamicLinkUriPrefix: "https://sevaexchange.page.link",
        );

      default:
        throw Exception('Unknown flavor $appFlavor');
    }
  }
}
