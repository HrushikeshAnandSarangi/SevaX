import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

class Intro extends StatelessWidget {
  final Function onSkip;
  Intro({
    @required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      data: [
        'images/intro_screens/Broadcasting_feeds.png',
        'images/intro_screens/Groups_and_Projects.png',
        'images/intro_screens/Messaging_and_communication.png',
        'images/intro_screens/Requests_and_Offers.png',
        'images/intro_screens/What_is_a_timebank_and_how_can_people_find_and_join_one.png',
      ],
      onSkip: onSkip,
    );
  }
}
