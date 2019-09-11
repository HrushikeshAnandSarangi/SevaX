import 'package:flutter/material.dart';

import '../components/intro_slider.dart';
import 'package:sevaexchange/views/login/login_page.dart';

class SplashcreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  //  SplashScreen({Key key}) : super(key: key);

  SplashScreen({this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  SplashScreenState createState() => new SplashScreenState();
}

// image carousel
class SplashScreenState extends State<SplashScreen> {
  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        //  title: "ERASER",
        //  description: "Helping my Community is what I look forward to every week",
        //  pathImage: "lib/assets/volunteers_mobile.png",
        //  backgroundColor: Color(0xfff5a623),
        backgroundImage: "lib/assets/splash_images/1.jpg",
      ),
    );
    slides.add(
      new Slide(
        //  title: "PENCIL",
        //  description: "Ye indulgence unreserved connection alteration appearance",
        backgroundImage: "lib/assets/splash_images/2.jpg",
        //  backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      new Slide(
        //  title: "RULER",
        //  description:
        //  "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        backgroundImage:
            "lib/assets/splash_images/3.jpg", //  backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        //  title: "RULER",
        //  description:
        //  "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        backgroundImage:
            "lib/assets/splash_images/4.jpg", //  backgroundColor: Color(0xff9932CC),
      ),
    );
    slides.add(
      new Slide(
        //  title: "RULER",
        //  description:
        //  "Much evil soon high in hope do view. Out may few northward believing attempted. Yet timed being songs marry one defer men our. Although finished blessing do of",
        backgroundImage:
            "lib/assets/splash_images/5.jpg", //  backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  void onDonePress() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
              // onSignedIn: null,
              )),
    );
  }

  void onSkipPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage(
              // onSignedIn: null,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
      onSkipPress: this.onSkipPress,
    );
  }
}
