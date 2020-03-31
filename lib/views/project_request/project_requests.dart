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
        ],
      ),
    );
  }

  Widget get requestStatusBar {
    return Container(
      height: 75,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      color: Colors.green,
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
