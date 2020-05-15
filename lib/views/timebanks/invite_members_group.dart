import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';

import '../../flavor_config.dart';

class InviteMembersGroup extends StatefulWidget {
  final TimebankModel timebankModel;

  InviteMembersGroup({this.timebankModel});

  @override
  _InviteMembersGroupState createState() => _InviteMembersGroupState();
}

class _InviteMembersGroupState extends State<InviteMembersGroup> {
  final TextEditingController searchTextController =
      new TextEditingController();
  Future<TimebankModel> getTimebankDetails;
  TimebankModel timebankModel;
  var validItems = List<String>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMembersList();

    searchTextController.addListener(() {
      setState(() {});
    });
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankModel.id,
    ).then((onValue) {
      setState(() {
        validItems = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Invite Members",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: searchTextController,
                decoration: InputDecoration(
                    suffixIcon: Offstage(
                      offstage: searchTextController.text.length == 0,
                      child: IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          //searchTextController.clear();
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => searchTextController.clear());
                        },
                      ),
                    ),
                    hasFloatingPlaceholder: false,
                    alignLabelWithHint: true,
                    isDense: true,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(5.0, 15.0, 5.0, 3.0),
                    filled: true,
                    fillColor: Colors.grey[300],
                    focusedBorder: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white),
                      borderRadius: new BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: new BorderRadius.circular(25.7)),
                    hintText: 'Invite members via email',
                    hintStyle: TextStyle(color: Colors.black45, fontSize: 13)),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
              child: Container(
                height: 25,
                child: Text(
                  "Members",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildList() {
    print("search ${searchTextController.text}");

//    if (searchTextController.text.trim().length < 1) {
//      //  print('Search requires minimum 1 character');
//      return Offstage();
//    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchForUserWithTimebankId(
            queryString: searchTextController.text, validItems: validItems),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Please try again later');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            );
          }
          List<UserModel> userlist = snapshot.data;
          print("user list ${snapshot.data}");
          print("user  ${userlist}");
          if (userlist.length == 0) {
            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text("No Member found"),
                ));
          }
          return Padding(
              padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userlist.length,
                  itemBuilder: (context, index) {
//
                    //  return userInviteWidget(email: "Umesha@uipep.com");
                    return userWidget(
                      user: userlist[index],
                    );
                  }));
        });
  }

  Widget userWidget({
    UserModel user,
  }) {
    bool isJoined = false;
    if (validItems.contains(user.sevaUserID)) {
      isJoined = true;
    }

    return ListTile(
      leading: user.photoURL != null
          ? ClipOval(
              child: FadeInImage.assetNetwork(
                fadeInCurve: Curves.easeIn,
                fadeInDuration: Duration(milliseconds: 400),
                fadeOutDuration: Duration(milliseconds: 200),
                width: 50,
                height: 50,
                placeholder: 'lib/assets/images/noimagefound.png',
                image: user.photoURL,
              ),
            )
          : CircleAvatar(),
      // onTap: goToNext(snapshot.data),
      title: Text(user.fullname,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
      subtitle: Text(user.email),
      trailing: RaisedButton(
        onPressed: !isJoined
            ? () async {
                setState(() {
                  //getMembersList();
                });
              }
            : null,
        child: Text(isJoined ? "Joined" : "Add"),
        color: FlavorConfig.values.theme.accentColor,
        textColor: FlavorConfig.values.buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }
}
