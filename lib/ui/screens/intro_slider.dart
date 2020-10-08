import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class Intro extends StatelessWidget {
  final Function onSkip;
  Intro({
    @required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    logger.i(">>>>" + AppConfig.remoteConfig.getString('intro_screens'));
    List<dynamic> introSliderScreenshots =
        json.decode(AppConfig.remoteConfig.getString('intro_screens'));
    return IntroSlider(
      data: [...introSliderScreenshots],
      onSkip: onSkip,
    );
  }
}
