import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/invitation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';

import '../../flavor_config.dart';

class InviteMembersGroup extends StatefulWidget {
  final TimebankModel timebankModel;
  final String parenttimebankid;

  InviteMembersGroup({
    this.timebankModel,
    this.parenttimebankid,
  });

  @override
  _InviteMembersGroupState createState() => _InviteMembersGroupState();
}

class _InviteMembersGroupState extends State<InviteMembersGroup> {
  final TextEditingController searchTextController =
      new TextEditingController();
  Future<TimebankModel> getTimebankDetails;
  TimebankModel parenttimebankModel;
  var parentTimebankMembersList = List<String>();
  var groupMembersList = List<String>();
  List<InvitationModel> listInvitationModel;
  static const String INVITE = "Invite";
  static const String JOINED = "Joined";
  static const String INVITED = "Invited";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(
        ("group id ${widget.timebankModel.id}  parenttimebank ${widget.parenttimebankid}"));
    _setTimebankModel();
    getParentTimebankMembersList();
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
        groupMembersList = onValue;
      });
    });
  }

  void getParentTimebankMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.parenttimebankid,
    ).then((onValue) {
      setState(() {
        parentTimebankMembersList = onValue;
      });
    });
  }

  void _setTimebankModel() async {
    parenttimebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.parenttimebankid,
    );
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
            queryString: searchTextController.text,
            validItems: parentTimebankMembersList),
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
          userlist.removeWhere((user) =>
              user.sevaUserID == SevaCore.of(context).loggedInUser.sevaUserID);
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
                    //  return userInviteWidget(email: "Umesha@uipep.com");
                    GroupInviteStatus status;
                    String title = "";

                    if (groupMembersList.contains(userlist[index].sevaUserID)) {
                      status = GroupInviteStatus.JOINED;
                      title = "Joined";
                      return userWidget(
                          user: userlist[index], status: status, title: title);
                    }
                    print("sttat $title");

                    return userWidget(
                        user: userlist[index], status: status, title: title);
                  }));
        });
  }

  String getGroupUserStatusTitle(GroupInviteStatus status) {
    print(" check satttt $status");
    switch (status) {
      case GroupInviteStatus.INVITED:
        return INVITED;

      case GroupInviteStatus.JOINED:
        return JOINED;

      default:
        return INVITE;
    }
  }

  Widget userWidget({
    UserModel user,
    GroupInviteStatus status,
    String title,
  }) {
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
        onPressed: title == "Invite"
            ? () {
                setState(() {
                  sendInvitationNotification(userModel: user);
                });
              }
            : null,
        child: Text(title ?? ""),
        color: FlavorConfig.values.theme.accentColor,
        textColor: FlavorConfig.values.buttonTextColor,
        shape: StadiumBorder(),
      ),
    );
  }

  void sendInvitationNotification({
    UserModel userModel,
  }) async {
    GroupInviteUserModel groupInviteUserModel = GroupInviteUserModel(
        timebankId: widget.parenttimebankid,
        timebankName: widget.timebankModel.name,
        timebankImage: widget.timebankModel.photoUrl,
        aboutTimebank: widget.timebankModel.missionStatement,
        adminName: SevaCore.of(context).loggedInUser.fullname,
        groupId: widget.timebankModel.id);

    InvitationModel invitationModel = InvitationModel(
        timebankId: widget.timebankModel.id,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        type: InvitationType.GroupInvite,
        data: groupInviteUserModel.toMap(),
        id: utils.Utils.getUuid(),
        invitedUserId: userModel.sevaUserID,
        adminId: SevaCore.of(context).loggedInUser.sevaUserID,
        timestamp: DateTime.now().millisecondsSinceEpoch);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: widget.parenttimebankid,
        data: groupInviteUserModel.toMap(),
        isRead: false,
        type: NotificationType.GroupJoinInvite,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: userModel.sevaUserID);
    await FirestoreManager.createJoinInvite(invitationModel: invitationModel);
    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());

    setState(() {});
  }
}

enum GroupInviteStatus { INVITE, INVITED, JOINED }
