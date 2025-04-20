import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/invitation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../flavor_config.dart';

class InviteMembersGroup extends StatefulWidget {
  final TimebankModel? timebankModel;
  final String? parenttimebankid;

  InviteMembersGroup({
    this.timebankModel,
    this.parenttimebankid,
  });

  @override
  _InviteMembersGroupState createState() => _InviteMembersGroupState();
}

class _InviteMembersGroupState extends State<InviteMembersGroup> {
  final TextEditingController searchTextController = TextEditingController();
  Future<TimebankModel>? getTimebankDetails;
  TimebankModel? parenttimebankModel;
  List<String> parentTimebankMembersList = [];
  List<String> groupMembersList = [];
  List<InvitationModel>? listInvitationModel;
  static const String INVITE = "Invite";
  static const String JOINED = "Joined";
  static const String DECLINED = "Declined";
  static const String INVITED = "Invited";
  InvitationModel? invitationModel;
  @override
  void initState() {
    super.initState();

    _setTimebankModel();
    getParentTimebankMembersList();
    getMembersList();
    searchTextController.addListener(() {
      setState(() {});
    });
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankModel!.id,
    ).then((onValue) {
      setState(() {
        groupMembersList = onValue.listOfElement!;
      });
    });
  }

  void getParentTimebankMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.parenttimebankid!,
    ).then((onValue) {
      setState(() {
        logger.d("${onValue.listOfElement} members");
        parentTimebankMembersList = onValue.listOfElement!;
      });
    });
  }

  void _setTimebankModel() async {
    parenttimebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.parenttimebankid!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).invite_members,
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
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7)),
                  hintText: S.of(context).search_by_email_name,
                  hintStyle: TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
              child: Container(
                height: 25,
                child: Text(
                  S.of(context).members,
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
//    if (searchTextController.text.trim().length < 1) {
//      return Offstage();
//    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchForUserWithTimebankId(
            queryString: searchTextController.text,
            validItems: parentTimebankMembersList),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(S.of(context).try_later);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          List<UserModel> userlist = snapshot.data ?? [];
          userlist.removeWhere((user) =>
              user.sevaUserID == SevaCore.of(context).loggedInUser.sevaUserID);
          if (userlist.isEmpty) {
            return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(S.of(context).no_member_found),
                ));
          }
          return Padding(
            padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: userlist.length,
                itemBuilder: (context, index) {
                  //  return userInviteWidget(email: "Umesha@uipep.com");

                  if (groupMembersList.contains(userlist[index].sevaUserID)) {
                    return joinedUserWidget(user: userlist[index]);
                  } else {
                    return getInvitationStatus(
                      userModel: userlist[index],
                    );
                  }
                }),
          );
        });
  }

  Widget getInvitationStatus({
    UserModel? userModel,
  }) {
    return FutureBuilder<InvitationModel?>(
      future: FirestoreManager.getInvitationModel(
          timebankId: widget.timebankModel!.id,
          sevauserid: userModel!.sevaUserID!),
      builder: (context, snapshot) {
        GroupInviteStatus groupInviteStatus;
        if (snapshot.connectionState == ConnectionState.waiting)
          return Offstage();
        if (snapshot.hasError) return Offstage();
        if (snapshot.hasData) {
          invitationModel = snapshot.data;
          GroupInviteUserModel groupInviteUserModel =
              GroupInviteUserModel.fromMap(invitationModel!.data!);
          if (groupInviteUserModel.declined == true) {
            groupInviteStatus = GroupInviteStatus.DECLINED;
            return userWidget(
              user: userModel,
              status: S.of(context).declined,
              groupInviteUserModel: groupInviteUserModel,
              groupInviteStatus: groupInviteStatus,
            );
          }
          groupInviteStatus = GroupInviteStatus.INVITED;
          return userWidget(
              groupInviteStatus: groupInviteStatus,
              user: userModel,
              groupInviteUserModel: groupInviteUserModel,
              status: S.of(context).invited);
        } else {
          groupInviteStatus = GroupInviteStatus.INVITE;
          return userWidget(
              user: userModel,
              status: S.of(context).invite,
              groupInviteStatus: groupInviteStatus);
        }
      },
    );
  }

  Widget joinedUserWidget({
    UserModel? user,
  }) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: user!.photoURL != null
                      ? ClipOval(
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeIn,
                            fadeInDuration: Duration(milliseconds: 400),
                            fadeOutDuration: Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            placeholder: 'lib/assets/images/noimagefound.png',
                            image: user.photoURL!,
                          ),
                        )
                      : CircleAvatar(),
                  // onTap: goToNext(snapshot.data),
                  title: Text(user.fullname!,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Europa')),
                  //subtitle: Text(user.email, style: TextStyle(fontFamily: 'Europa')),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CustomElevatedButton(
                        onPressed: () {},
                        padding: EdgeInsets.all(8),
                        elevation: 2,
                        child: Text(JOINED,
                            style: TextStyle(fontFamily: 'Europa')),
                        color: FlavorConfig.values.theme?.primaryColor ??
                            Colors.grey,
                        textColor: FlavorConfig.values.buttonTextColor,
                        shape: StadiumBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget userWidget({
    GroupInviteStatus? groupInviteStatus,
    UserModel? user,
    String? status,
    GroupInviteUserModel? groupInviteUserModel,
  }) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: user!.photoURL != null
                      ? ClipOval(
                          child: FadeInImage.assetNetwork(
                            fadeInCurve: Curves.easeIn,
                            fadeInDuration: Duration(milliseconds: 400),
                            fadeOutDuration: Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            placeholder: 'lib/assets/images/noimagefound.png',
                            image: user.photoURL!,
                          ),
                        )
                      : CircleAvatar(),
                  // onTap: goToNext(snapshot.data),
                  title: Text(user.fullname!,
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Europa')),
                  subtitle: invitationStatusText(
                      status!, groupInviteUserModel!, groupInviteStatus!),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: buttonWidget(
                          user: user,
                          groupInviteUserModel: groupInviteUserModel,
                          groupInviteStatus: groupInviteStatus),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget invitationStatusText(
      String status,
      GroupInviteUserModel groupInviteUserModel,
      GroupInviteStatus groupInviteStatus) {
    String statusText = getGroupUserStatusTitle(groupInviteStatus);
    if (groupInviteStatus == GroupInviteStatus.INVITE) {
      return Offstage();
    }

    String date = DateFormat(
      'dd MMM yyyy',
    ).format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(
              groupInviteUserModel.declined!
                  ? groupInviteUserModel.declinedTimestamp!
                  : groupInviteUserModel.timestamp!),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone!),
    );
    return Text(
      statusText + ' ' + S.of(context).on + ' ' + date,
      style: TextStyle(
          color: groupInviteUserModel.declined! ? Colors.red : Colors.blue,
          fontFamily: 'Europa'),
    );
  }

  Widget buttonWidget(
      {UserModel? user,
      GroupInviteUserModel? groupInviteUserModel,
      GroupInviteStatus? groupInviteStatus}) {
    if (groupInviteStatus == GroupInviteStatus.INVITED ||
        groupInviteStatus == GroupInviteStatus.DECLINED) {
      return CustomElevatedButton(
        padding: EdgeInsets.all(8),
        elevation: 2,
        onPressed: () {
          if (groupInviteStatus == GroupInviteStatus.INVITED) {
            setState(() {
              resendNotification(
                  userEmail: user!.email!,
                  notificationId: groupInviteUserModel!.notificationId!);
            });
          } else {
            setState(() {
              resendNotificationIfDeclined(
                  userEmail: user!.email!,
                  notificationId: groupInviteUserModel!.notificationId!);
            });
          }
        },
        child: Text(S.of(context).resend_invite,
            style: TextStyle(fontFamily: 'Europa')),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        shape: StadiumBorder(),
      );
    } else {
      return CustomElevatedButton(
        padding: EdgeInsets.all(8),
        elevation: 2,
        onPressed: () {
          setState(() {
            sendInvitationNotification(userModel: user!);
          });
        },
        child:
            Text(S.of(context).invite, style: TextStyle(fontFamily: 'Europa')),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        shape: StadiumBorder(),
      );
    }
  }

  String getGroupUserStatusTitle(GroupInviteStatus status) {
    switch (status) {
      case GroupInviteStatus.INVITED:
        return INVITED;

      case GroupInviteStatus.JOINED:
        return JOINED;

      case GroupInviteStatus.DECLINED:
        return DECLINED;

      default:
        return INVITE;
    }
  }

  Widget gettigStatus() {
    return CustomElevatedButton(
      padding: EdgeInsets.all(8),
      elevation: 2,
      onPressed: () {},
      child: Text(S.of(context).invite_members_group_dots),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  void resendNotification({String? userEmail, String? notificationId}) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    await CollectionRef.invitations.doc(invitationModel!.id).update({
      'data.timestamp': timestamp,
    });
    await CollectionRef.users
        .doc(userEmail)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': false,
      'data.timestamp': timestamp,
    });
  }

  void resendNotificationIfDeclined(
      {String? notificationId, String? userEmail}) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    await CollectionRef.invitations.doc(invitationModel!.id).update({
      'data.timestamp': timestamp,
      'data.declined': false,
    });
    await CollectionRef.users
        .doc(userEmail)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': false,
      'data.declined': false,
      'data.timestamp': timestamp,
    });
  }

  void sendInvitationNotification({
    UserModel? userModel,
  }) async {
    String notificationId = utils.Utils.getUuid();
    String invitationId = utils.Utils.getUuid();
    GroupInviteUserModel groupInviteUserModel = GroupInviteUserModel(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        timebankId: widget.parenttimebankid,
        timebankName: widget.timebankModel!.name,
        timebankImage: widget.timebankModel!.photoUrl,
        aboutTimebank: widget.timebankModel!.missionStatement,
        adminName: SevaCore.of(context).loggedInUser.fullname,
        groupId: widget.timebankModel!.id,
        invitedUserId: userModel!.sevaUserID,
        declined: false,
        declinedTimestamp: 0,
        invitationId: invitationId,
        adminId: SevaCore.of(context).loggedInUser.sevaUserID,
        notificationId: notificationId);

    InvitationModel invitationModel = InvitationModel(
      timebankId: widget.timebankModel!.id,
      type: InvitationType.GroupInvite,
      data: groupInviteUserModel.toMap(),
      id: utils.Utils.getUuid(),
    );

    NotificationsModel notification = NotificationsModel(
        id: notificationId,
        timebankId: widget.parenttimebankid,
        data: groupInviteUserModel.toMap(),
        isRead: false,
        type: NotificationType.GroupJoinInvite,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: userModel.sevaUserID);
    await FirestoreManager.createJoinInvite(invitationModel: invitationModel);
    await CollectionRef.users
        .doc(userModel.email)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());

    // setState(() {});
  }
}

enum GroupInviteStatus { INVITE, INVITED, JOINED, DECLINED }

//class GroupInvitationStatus {
//  bool isInvited;
//
//  GroupInvitationStatus.notYetInvited() {
//    this.isInvited = false;
//  }
//  GroupInvitationStatus.isInvited() {
//    this.isInvited = true;
//  }
//}
