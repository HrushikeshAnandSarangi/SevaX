import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'dart:math';

import 'package:sevaexchange/views/profile/profileedit.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';

class ProfileViewer extends StatelessWidget {
  final String userEmail;

  ProfileViewer({Key key, this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
          title: Text('User Profile',style: TextStyle(color: Colors.white),),
          centerTitle: false,
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('users')
                .document(userEmail)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 110.0,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(top: 25.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        snapshot.data['photourl'] ?? ''),
                                    minRadius: 40.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                        child: Center(
                          child: Text(
                            snapshot.data['fullname'],
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 17.0),
                            // overflow: TextOverflow.ellipsis,
                            // maxLines: 2,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 2.6,
                              0,
                              MediaQuery.of(context).size.width / 2.6,
                              0),
                          child: OutlineButton(
                            borderSide: BorderSide(color: Theme.of(context).accentColor,),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.forum,color: Theme.of(context).accentColor,),
                                Text(' Chat')
                              ],
                            ),
                            onPressed: userEmail == loggedInEmail
                                ? null
                                : () {
                                    print(userEmail);

                                    print(loggedInEmail);
                                    List users = [userEmail, loggedInEmail];
                                    users.sort();
                                    MessageModel model = MessageModel();
                                    model.user1 = users[0];
                                    model.user2 = users[1];
                                    print(model.user1);
                                    print(model.user2);
                                    createChat(chat: model);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatView(
                                                useremail: userEmail,
                                                messageModel: model,
                                              )),
                                    );
                                  },
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child: Divider(
                          color: Colors.deepPurple,
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Bio and CV',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child: Text(
                          snapshot.data['bio'] ?? '',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w400),
                        ),
                      ),

                      // Container(
                      //   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
                      //   child: Text(
                      //     'My Interests',
                      //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
                      //   ),
                      // ),

                      Container(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Text(
                          'My Interests',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child:
                            getChipWidgets(snapshot.data['interests'], context),
                      ),

                      Container(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Text(
                          'My Skills',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child: getChipWidgets(snapshot.data['skills'], context),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                      ),

                      // Container(
                      //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                      //   child: TaskButton(),
                      // ),
                      // Container(
                      //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                      //   child: HoursExchangeButton(),
                      // ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
                      //   child: Text('appName  - ' + _appName + 'appName  - ' + _appName +
                      //               'packageName  - ' + _packageName +
                      //               'version  - ' + _version +
                      //               'BuildNumber  - ' + _buildNumber),
                      // ),
                      // Container(
                      //   child: Text(' '),
                      // ),
                    ],
                  ));
              }
            }));
  }
}

class FollowSection extends StatefulWidget {
  _FollowSectionState createState() => _FollowSectionState();
}

class _FollowSectionState extends State<FollowSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 15.0),
                child: Followers(),
              ),
              Container(
                padding: EdgeInsets.only(right: 15.0),
                child: Following(),
              ),
              Container(
                child: NumberOfPosts(),
              ),
            ],
          ),
          EditButton(),
        ],
      ),
    );
  }
}

class NameInfo extends StatefulWidget {
  _NameInfoState createState() => _NameInfoState();
}

class _NameInfoState extends State<NameInfo> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      child: Text(
        SevaCore.of(context).loggedInUser.fullname,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.0),
        // overflow: TextOverflow.ellipsis,
        // maxLines: 2,
      ),
    )
        // crossAxisAlignment: CrossAxisAlignment.center,
        // children: <Widget>[
        //   Center(
        //     child: Text("data"),
        //   ),
        // Text(

        //   globals.fullname,
        //   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17.0),
        //   overflow: TextOverflow.ellipsis,
        //   maxLines: 2,
        // ),
        // ],
        // ),
        );
  }
}

class Followers extends StatefulWidget {
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '63',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            'Connections',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class Following extends StatefulWidget {
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '190',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            'Following',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class NumberOfPosts extends StatefulWidget {
  _NumberOfPostsState createState() => _NumberOfPostsState();
}

class _NumberOfPostsState extends State<NumberOfPosts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '90',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            'Posts',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12.0),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 5.0),
            height: 30.0,
            child: ButtonTheme(
              minWidth: 206.0,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileEdit()),
                  );
                },
                textColor: Colors.white,
                color: Colors.blue,
                child: Text(
                  'EDIT',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FlatButton(
            onPressed: () {
              //     Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyTasksView()),
              // );
            },
            color: Colors.white70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('My Tasks'),
                Icon(Icons.keyboard_arrow_right, size: 24.0),
              ],
            )));
  }
}

class HoursExchangeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: FlatButton(
            onPressed: () {
              //     Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => MyTasksView()),
              // );
            },
            color: Colors.white70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('My Hours and Exchanges'),
                Icon(Icons.keyboard_arrow_right, size: 24.0),
              ],
            )));
  }
}

Color _getChipColor() {
  List colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.redAccent,
  ];

  Random random = Random();
  int selected = random.nextInt(18);

  return colors[selected];
}

Widget getChipWidgets(List<dynamic> strings, BuildContext context) {
  return Wrap(
      spacing: 5.0,
      alignment: WrapAlignment.start,
      children: strings
          .map((item) => ActionChip(
                padding: EdgeInsets.all(3.0),
                onPressed: () {},
                backgroundColor: Theme.of(context).accentColor,
                label: Text(
                  item,
                  style: TextStyle(color: Colors.white),
                ),
              ))
          .toList());
}
