import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class Intro extends StatelessWidget {
  final VoidCallback onSkip;
  Intro({
    required this.onSkip,
  });

  @override
  @override
  Widget build(BuildContext context) {
    logger.i(">>>>" + AppConfig.remoteConfig!.getString('intro_screens'));
    List<dynamic> introSliderScreenshots =
        json.decode(AppConfig.remoteConfig!.getString('intro_screens'));
    List<ContentConfig> slides =
        introSliderScreenshots.map<ContentConfig>((item) {
      return ContentConfig(
        title: item['title'] ?? '',
        description: item['description'] ?? '',
        pathImage: item['image'] ?? '',
        backgroundColor: Colors.white,
      );
    }).toList();
    return IntroSlider(
      listContentConfig: slides,
      onDonePress: onSkip,
      onSkipPress: onSkip,
      skipButtonStyle: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
      nextButtonStyle: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
      doneButtonStyle: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
