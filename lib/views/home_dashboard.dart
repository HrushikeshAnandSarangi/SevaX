import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sticky_headers/sticky_headers.dart';



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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin{

  TabController controller ;

  @override
  void initState() {
    controller = TabController(initialIndex: 0,length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: SafeArea(
        child: ListView(
          children: <Widget>[

           // SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
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
                      Spacer(),

                      IconButton(icon: Icon(Icons.add_circle_outline),
                          iconSize: 35,
                          color: Colors.grey,
                          alignment: Alignment.center,
                          onPressed: (){

                          }),

                    ],
                  ),
                  //SizedBox(height: 20,),
                  FadeAnimation(1.4, Container(
                    height: size.height*0.25,

                    child: ListView(
                      shrinkWrap: true,
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

                  SizedBox(height: 30,),
                  Container(
                    height: 10,
                    color: Colors.grey[300],
                  ),
                  Container(
                    height: 15,
                    color: Colors.white,
                  ),
                ],

              ),
            ),
          

            StickyHeader(
              header: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20,bottom: 10,top: 10),
                      child: Text('Your Calender',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Europa',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,

                      ),
                      ),
                    ),
                    TabBar(
                      labelColor: Colors.black,
                      //labelColor: Colors.white,
                      indicatorColor: Colors.black,
                      tabs: [
                        Tab(child: Text('Pending ')),
                        Tab(
                            child: Text(
                              'Not Accepted ',
                            )),
                        Tab(
                            child: Text(
                              'Completed ',
                            )),
                      ],
                      controller: controller,
                      isScrollable: false,
                      unselectedLabelColor: Colors.black,

                    ),
                  ],
                ),
              ),
              content: Container(

                height: size.height-95,
                      child: MyTaskPage(controller),

              ),
            ),



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

            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover
            )
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(12),
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
                  color: Colors.white,
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