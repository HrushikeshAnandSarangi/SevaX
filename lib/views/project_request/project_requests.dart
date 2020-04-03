import 'package:flutter/material.dart';

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
          Container(
            height: 10,
          ),
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

  Widget get requestCards {
    var count = 10;
    return Expanded(
      child: SizedBox(
        height: 200.0,
        child: ListView.builder(
            itemCount: count,
            itemBuilder: (_context, index) {
              return index < count - 1
                  ? getListTile()
                  : SizedBox(
                      height: 50,
                    );
            }),
      ),
    );
  }

  BoxDecoration get containerDecorationR {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(2),
            spreadRadius: 6,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }

  Widget getListTile() {
    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(
                              Icons.place,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Container(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                "Manchester",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: 'Europa'),
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
                  margin: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        height: 60,
                        width: 60,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                          ),
                          minRadius: 40.0,
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              getSpacerItem(
                                Text(
                                  'Experienced Designer',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Europa'),
                                ),
                              ),
                              getSpacerItem(
                                Text(
                                  '17 Jan 10:00 AM - 17 Jan 11:00 PM',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    'Design Principal - Electronic and Communication Design',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getSpacerItem(Widget item) {
    return Row(
      children: <Widget>[
        item,
        Spacer(),
      ],
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
