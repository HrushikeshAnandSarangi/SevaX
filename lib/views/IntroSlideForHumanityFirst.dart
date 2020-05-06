// import 'package:flutter/material.dart';
// import 'package:intro_slider/intro_slider.dart';
// import 'package:intro_slider/slide_object.dart';

// class IntroScreenHukanityFirst extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return IntroScreenState();
//   }
// }

// class IntroScreenState extends State<IntroScreenHukanityFirst> {
//   List<Slide> slides = new List();

//   Function goToTab;

//   @override
//   void initState() {
//     super.initState();

//     slides.add(
//       new Slide(
//         backgroundBlendMode: BlendMode.colorBurn,
//         backgroundImage: 'lib/assets/images/washingtondc.jpg',
//         title: "Create a local Yang Gang Chapter",
//         styleTitle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20.0,
//         ),
//         pathImage: 'lib/',
//         description:
//             "WelcomeOrganize Yang Gang events and invite volunteers.\nInvite new Yang Gang members",
//         backgroundColor: Color(0xff203152),
//       ),
//     );

//     slides.add(
//       new Slide(
//         backgroundBlendMode: BlendMode.colorBurn,
//         backgroundImage: 'lib/assets/images/yang_standing.jpg',
//         title: "Create a Campaign Request",
//         styleTitle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20.0,
//         ),
//         pathImage: 'lib/',
//         description:
//             "Request volunteer skills, tasks, items, or time for Yang Bucks.\nVolunteers can discover local Yang Gangs and discover volunteer opportunities ",
//         backgroundColor: Color(0xff203152),
//       ),
//     );

//     slides.add(
//       new Slide(
//         backgroundBlendMode: BlendMode.colorBurn,
//         backgroundImage: 'lib/assets/images/yang_banner.jpg',
//         title: "Create a Project",
//         pathImage: 'lib/',
//         styleTitle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20.0,
//         ),
//         description:
//             "Use projects to manage multiple campaign requests.\nTime-tracking tools for volunteers to be rewarded with Yangbucks",
//         backgroundColor: Color(0xff203152),
//       ),
//     );

//     slides.add(
//       new Slide(
//         backgroundBlendMode: BlendMode.colorBurn,
//         backgroundImage: 'lib/assets/images/yang_fourth_.jpg',
//         title: "Create a Volunteer Offer",
//         pathImage: 'lib/',
//         styleTitle: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20.0,
//         ),
//         description:
//             "Contribute a particular skill, item, or offer your time to a Yang Gang.\nShare photos and news to the Yang Gang Feed and chat with other Yang Gang members nationally",
//         backgroundColor: Color(0xff203152),
//       ),
//     );
//   }

//   void onTabChangeCompleted(index) {
//     // Index of current tab is focused
//   }

//   Widget renderNextBtn() {
//     return Icon(
//       Icons.navigate_next,
//       color: Color(49),
//       size: 35.0,
//     );
//   }

//   Widget renderDoneBtn() {
//     return Icon(
//       Icons.done,
//       color: Colors.black,
//     );
//   }

//   Widget renderSkipBtn() {
//     return Icon(
//       Icons.skip_next,
//       color: Colors.black,
//     );
//   }

//   List<Widget> renderListCustomTabs() {
//     List<Widget> tabs = new List();
//     for (int i = 0; i < slides.length; i++) {
//       Slide currentSlide = slides[i];
//       tabs.add(Container(
//         width: double.infinity,
//         height: double.infinity,
//         child: Container(
//           margin: EdgeInsets.only(bottom: 60.0, top: 60.0),
//           child: ListView(
//             children: <Widget>[
//               GestureDetector(
//                 child: Image.asset(
//                   currentSlide.pathImage,
//                   width: 200.0,
//                   height: 200.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Container(
//                 child: Text(
//                   currentSlide.title,
//                   style: currentSlide.styleTitle,
//                   textAlign: TextAlign.center,
//                 ),
//                 margin: EdgeInsets.only(top: 20.0),
//               ),
//               Container(
//                 child: Text(
//                   currentSlide.description,
//                   style: currentSlide.styleDescription,
//                   textAlign: TextAlign.center,
//                   maxLines: 5,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 margin: EdgeInsets.only(top: 20.0),
//               ),
//             ],
//           ),
//         ),
//       ));
//     }
//     return tabs;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IntroSlider(
//       slides: this.slides,
//       onSkipPress: () {
//         print("Intro skipped");

//         Navigator.pop(context, {'response': 'SKIPPED'});
//       },
//       onDonePress: () {
//         Navigator.pop(context, {'response': 'ACCEPTED'});
//       },
//       colorDot: Colors.white54,
//       renderNextBtn: this.renderSkipBtn(),
//       colorActiveDot: Colors.white,
//       colorDoneBtn: Colors.white,
//       renderDoneBtn: this.renderDoneBtn(),
//       colorSkipBtn: Colors.white,
//       renderSkipBtn: Text('Skip'),
//       isShowSkipBtn: true,
//     );
//   }
// }
