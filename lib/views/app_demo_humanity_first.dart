import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class AppDemoHumanityFirst extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IntroScreenState();
  }
}

class IntroScreenState extends State<AppDemoHumanityFirst> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        backgroundImage: 'lib/assets/images/Info_1.png',
        title: "",
        description: "",
        backgroundColor: Color(0xff203152),
      ),
    );

    slides.add(
      new Slide(
        backgroundBlendMode: BlendMode.colorBurn,
        backgroundImage: 'lib/assets/images/Info_2.png',
        title: "",
        pathImage: '',
        description: "",
        backgroundColor: Color(0xff203152),
      ),
    );

    slides.add(
      new Slide(
        backgroundBlendMode: BlendMode.colorBurn,
        backgroundImage: 'lib/assets/images/Info_3.png',
        title: "",
        pathImage: '',
        description: "",
        backgroundColor: Color(0xff203152),
      ),
    );

    slides.add(
      new Slide(
        backgroundBlendMode: BlendMode.colorBurn,
        backgroundImage: 'lib/assets/images/Info_4.png',
        title: "",
        pathImage: 'lib/',
        description: "",
        backgroundColor: Color(0xff203152),
      ),
    );
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(49),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Colors.black,
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Colors.black,
    );
  }

  List<Widget> renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
          child: ListView(
            children: <Widget>[
              GestureDetector(
                child: Image.asset(
                  currentSlide.pathImage,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                child: Text(
                  currentSlide.title,
                  style: currentSlide.styleTitle,
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.only(top: 20.0),
              ),
              Container(
                child: Text(
                  currentSlide.description,
                  style: currentSlide.styleDescription,
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                margin: EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,
      onSkipPress: () {
        print("Intro skipped");

        Navigator.pop(context, {'response': 'SKIPPED'});
      },
      onDonePress: () {
        Navigator.pop(context, {'response': 'ACCEPTED'});
      },
      colorDot: Colors.white54,
      renderNextBtn: this.renderSkipBtn(),
      colorActiveDot: Colors.white,
      colorDoneBtn: Colors.white,
      renderDoneBtn: this.renderDoneBtn(),
      colorSkipBtn: Colors.white,
      renderSkipBtn: Text('Skip'),
      isShowSkipBtn: true,
    );
  }
}
