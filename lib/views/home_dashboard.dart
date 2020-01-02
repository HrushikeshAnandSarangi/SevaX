import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profile.dart';




class Home_DashBoard extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),


        centerTitle: true,
        title: Text(
          'DashBoard',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54,
              fontSize: 20,

              fontWeight: FontWeight.w500),

        ),


      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            SizedBox(height: 30,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child:
                  FadeAnimation(1,

                    Text("Your Time Bank(s)",

                    style: TextStyle(
                        fontWeight: FontWeight.bold,

                        color: Colors.black87,
                        fontFamily: 'Europa',
                        fontSize: 20),
                  ),
                  ),
                  ),
                  SizedBox(height: 20,),
                  FadeAnimation(1.4, Container(
                    height: 200,

                    child: ListView(
                      padding: EdgeInsets.only(left: 12),
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        makeItem(image: 'lib/assets/splash_images/1.jpg', title: 'Time Bank 1'),
                        makeItem(image: 'lib/assets/splash_images/2.jpg', title: 'Time Bank 2'),
                        makeItem(image: 'lib/assets/splash_images/3.jpg', title: 'Time Bank 3'),
                        makeItem(image: 'lib/assets/splash_images/4.jpg', title: 'Time Bank 4')
                      ],
                    ),
                  )),

                  SizedBox(height: 20,),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget makeItem({image, title}) {
    return AspectRatio(
      aspectRatio: 3/ 4,
      child: Container(

        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover
            )
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(.8),
                    Colors.black.withOpacity(.2),
                  ]
              )
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(title,
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

}