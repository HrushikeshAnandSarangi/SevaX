import 'package:flutter/material.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

class ProjectRequests extends StatefulWidget {
  final String timebankId;
  ProjectRequests({@required this.timebankId});
  State<StatefulWidget> createState() {
    return RequestsState();
  }
}

// Create a Form Widget

class RequestsState extends State<ProjectRequests> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: Column(
          children: <Widget>[
            Text(
              'Requests',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          requestStatusBar,
          addRequest,
          requestCards,
        ],
      ),
    );
  }

  Widget get requestStatusBar {
    return Container(
      height: 75,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      color: Color.fromRGBO(250, 231, 53, 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              setTitle(num: '10', title: 'Requests'),
              setTitle(num: '3', title: 'Pending'),
              setTitle(num: '7', title: 'Completed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget get requestCards{
//    return ListView.builder(
//        itemCount: 1,
//        itemBuilder: (_context , int index) {
//          return getListTile();
//        }
//    );
    return getListTile();
  }

  Widget getListTile(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            offset: Offset(0.2, 1),
          ),
        ],
      ),
      margin: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width - 30,
      height: 150,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(
                        Icons.add_location,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Container(
                        width: MediaQuery.of(context).size.width - 170,
                        child: Text(
                          "Manchester",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Text(
                  'an hour ago',
                  style: TextStyle(
                    color: Colors.black38,
                  ),
                )
              ],
            ),
          ),
        Container(
//          width: MediaQuery.of(context).size.width-50,
          margin: EdgeInsets.only(right: 10,left: 10),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                height: 40,
                width: 40,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                  ),
                  minRadius: 40.0,
                ),
              ),
              Container(

                margin: EdgeInsets.only(left: 10),
                child: Container(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Experienced Designer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '17 Jan 10:00 AM - 17 Jan 11:00 PM',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 80),
          child: Text(
            'Design Principal - Electronic and Communication Design',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ],
      ),
    );
  }

  Widget get addRequest {
    return Container(
      margin: EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width - 20,
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "Add request",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Spacer(),
          Column(
            children: <Widget>[
              Container(
                height: 10,
              ),
              GestureDetector(
                child: Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 10,
                    child: Image.asset("lib/assets/images/add.png"),
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget setTitle({String num, String title}) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            num,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
