import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeBankAboutView extends StatefulWidget {
  @override
  _TimeBankAboutViewState createState() => _TimeBankAboutViewState();
}

class _TimeBankAboutViewState extends State<TimeBankAboutView> {
  String text="We provide full-cycle services in the areas of App development, web-based enterprise solutions, web application and portal development, We combine our solid business domain experience, technical expertise, profound knowledge of latest industry trends and quality-driven delivery model to offer progressive, end-to-end mobile and web solutions.Single app for all user-types: Teachers, Students & Parent Teachers can take attendance, students can view timetables, parents can view attendance, principal and admins can send messages & announcements, etc. using the same app,Though the traditional login mechanism with the username and password is preferred by the majority of users; the One Time Password (OTP) login via SMS and Emails is favored by all the app users. We have incorporated both of them in the school mobile app to choose the one that suits you the best.";
  bool descTextShowFlag = false;
  bool iUserJoined=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Image.network(
              'http://www.farazessaniphotography.com/wp-content/uploads/2016/07/4Y7C4124.jpg',
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left:20.0,bottom: 10,top: 10),
              child: RichText(
                  text: TextSpan(style: TextStyle(color: Colors.black),children: [
                TextSpan(
                  text: 'Part of',

                  style: TextStyle(
                       fontSize: 16, fontFamily: 'Europa'),
                ),
                TextSpan(
                  text: " Seva Exchange Time Bank",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Europa'),
                )
              ]),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(left:20.0),
              child: Text(
                'Bangalore Hosur-San Timebank',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa'),
              ),
            ),
            SizedBox(
              height: 30,
            ),

          iUserJoined?
          Container(
            height: 40,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        image: DecorationImage(fit: BoxFit.cover,
                            image: NetworkImage('http://www.farazessaniphotography.com/wp-content/uploads/2016/07/4Y7C4124.jpg'))
                    ),

                  ),
                );
              },


            ),
          ):Container(

          ),
            Padding(
              padding: const EdgeInsets.only(top:10.0,left: 20),
              child: Text('2000'+' Volunteers',style: TextStyle(
                fontFamily: 'Europa',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Bangalore, India',
                style: TextStyle(
                fontFamily: 'Europa',
                fontSize: 16,
                color: Colors.grey,
              ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,top: 10,bottom: 10),
              child: Text('About us',
                style: TextStyle(
                fontFamily: 'Europa',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20,bottom: 10),
              child: Text('We’re a software technology company based in Bangalore, Hyderbad, USA founded in December 2015.',
                style: TextStyle(
                fontFamily: 'Europa',
                fontSize: 16,
                color: Colors.black,
              ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text,
                    style: TextStyle(
                      fontFamily: 'Europa',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: descTextShowFlag ? null : 2,textAlign: TextAlign.start),
                InkWell(
                  onTap: (){ setState(() {
                    descTextShowFlag = !descTextShowFlag;
                  }); },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      descTextShowFlag ? Text("Read Less",style: TextStyle(
                        fontFamily: 'Europa',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),)
                          :  Text("Read More",style: TextStyle(
                        fontFamily: 'Europa',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),


            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Organizers',
                style: TextStyle(
                  fontFamily: 'Europa',
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,

                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(style: TextStyle(color: Colors.black),
                            children: [

                              TextSpan(
                                text: "John Doe",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Europa'),
                              ),
                              TextSpan(
                                text: '  and Others',
                                style: TextStyle(
                                    fontSize: 16, fontFamily: 'Europa'),
                              ),
                            ]),
                      ),
                      Text('Message',
                        style: TextStyle(
                          fontFamily: 'Europa',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),

                    ],
                  ),
                  Spacer(),

                  Container(
                    height: 60,
                    width: 60,
                    child: Center(
                      child: Text('Uipep'),
                    ),
                    decoration:BoxDecoration(
                        color: Colors.yellow,
                      shape: BoxShape.circle
                    ),
                  )
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
