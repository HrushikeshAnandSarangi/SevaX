import 'package:flutter/material.dart';
import 'package:sevaexchange/components/intro_slider.dart';

class IntroScreenHukanityFirst extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IntroScreenState();
  }
}

class IntroScreenState extends State<IntroScreenHukanityFirst> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        backgroundBlendMode: BlendMode.colorBurn,
        backgroundImage: 'lib/assets/images/yang_banner.jpg',
        title: "Welcome",
        pathImage: 'lib/',
        description:
            "Welcome to Humanty first application, where you can create yang gangs,  invite people to join campaigns ",
        backgroundColor: Color(0xff203152),
      ),
    );

    slides.add(
      new Slide(
        backgroundBlendMode: BlendMode.colorBurn,
        backgroundImage: 'lib/assets/images/andrew_two.jpg',
        title: "Team up",
        pathImage: 'lib/',
        description:
            "Create you own, where you can create yang gangs,  invite people to join campaigns and do a lot more stuff, You'll enjoy",
        backgroundColor: Color(0xff203152),
      ),
    );






  }

  void onDonePress() {
    // Back to the first tab
    this.goToTab(0);
  }

  void onTabChangeCompleted(index) {
    // Index of current tab is focused
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Color(0xffffcc5c),
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Color(0xffffcc5c),
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Color(0xffffcc5c),
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
              )),
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
      onDonePress: this.onDonePress,
      renderSkipBtn: Text('Skip'),
    );
  }
}
