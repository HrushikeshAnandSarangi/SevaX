import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/invitation_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/utils/deep_link_manager/deep_link_manager.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/TimebankCodeModel.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:share/share.dart';

class InviteAddMembers extends StatefulWidget {
  final String communityId;
  final String timebankId;
  final TimebankModel timebankModel;

  InviteAddMembers(this.timebankId, this.communityId, this.timebankModel);

  @override
  State<StatefulWidget> createState() => InviteAddMembersState();
}

class InviteAddMembersState extends State<InviteAddMembers> {
  TimebankCodeModel codeModel = TimebankCodeModel();
  final TextEditingController searchTextController =
      new TextEditingController();
  Future<TimebankModel> getTimebankDetails;
  TimebankModel timebankModel;

  var validItems = List<String>();
  InvitationManager inivitationManager = InvitationManager();

  @override
  void initState() {
    super.initState();
    _setTimebankModel();
    getMembersList();
    searchTextController.addListener(() {
      setState(() {});
    });
    initDynamicLinks(context);
    // setState(() {});
  }

  void getMembersList() {
    FirestoreManager.getAllTimebankIdStream(
      timebankId: widget.timebankId,
    ).then((onValue) {
      setState(() {
        validItems = onValue;
      });
    });
  }

  void _setTimebankModel() async {
    timebankModel = await getTimebankDetailsbyFuture(
      timebankId: widget.timebankId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlavorConfig.values.timebankName == "Yang 2020"
              ? AppLocalizations.of(context)
                  .translate('members', 'yang_yang_codes')
              : AppLocalizations.of(context)
                  .translate('members', 'invite_members'),
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: FutureBuilder(
          future: getTimebankDetails,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            return inviteCodeWidget;
          },
        ),
      ),
    );
  }

  Widget get inviteCodeWidget {
    return Column(
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
                hintText: AppLocalizations.of(context)
                    .translate('members', 'invite_via_email'),
                hintStyle: TextStyle(color: Colors.black45, fontSize: 13)),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 15, 0, 0),
          child: Container(
            height: 25,
            child: Text(
              AppLocalizations.of(context).translate('members', 'members'),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        buildList(),
        !widget.timebankModel.private == true
            ? Padding(
                padding: EdgeInsets.all(5),
                child: GestureDetector(
                  child: Container(
                    height: 25,
                    child: Row(
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context)
                              .translate('members', 'invite_via_code'),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Image.asset("lib/assets/images/add.png"),
                      ],
                    ),
                  ),
                  onTap: () async {
                    _asyncInputDialog(context);
                  },
                ),
              )
            : Offstage(),
        !widget.timebankModel.private == true
            ? getTimebankCodesWidget
            : Offstage(),
      ],
    );
  }

  Widget buildList() {
    return StreamBuilder<List<UserModel>>(
        stream: SearchManager.searchUserInSevaX(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(AppLocalizations.of(context)
                .translate('members', 'please_try_later'));
          }
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(),
              ),
            );
          }
          List<UserModel> userlist = snapshot.data;
          if (userlist.length > 1) {
            userlist.removeWhere((user) =>
                user.sevaUserID ==
                SevaCore.of(context).loggedInUser.sevaUserID);
          }

          print("user list ${snapshot.data}");
          print("user  ${userlist}");
          if (userlist.length == 0) {
            if (searchTextController.text.length > 1 &&
                isvalidEmailId(searchTextController.text)) {
              return userInviteWidget(email: searchTextController.text);
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: searchTextController.text.length > 1
                    ? Text(
                        "${searchTextController.text} ${AppLocalizations.of(context).translate('members', 'not_found')}")
                    : Container(),
              ),
            );
          }
          return Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      return userWidget(
                        user: userlist[index],
                      );
                    })),
          );

          return Text("");
        });
  }

  bool isvalidEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (emailPattern.hasMatch(value)) return true;
    return false;
  }

  Widget userInviteWidget({
    String email,
  }) {
    inivitationManager.initDialogForProgress(context: context);
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(),
                  title: Text(email,
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.w700)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(right: 8),
                      child: FutureBuilder(
                        future: inivitationManager.checkInvitationStatus(
                            email, timebankModel.id),
                        builder: (BuildContext context,
                            AsyncSnapshot<InvitationStatus> snapshot) {
                          if (!snapshot.hasData) {
                            return gettigStatus();
                          }
                          var invitationStatus = snapshot.data;
                          if (invitationStatus.isInvited) {
                            return resendInvitation(
                              invitation: inivitationManager
                                  .getInvitationForEmailFromCache(
                                inviteeEmail: email,
                              ),
                            );
                          }
                          return inviteMember(
                            inviteeEmail: email,
                            timebankModel: timebankModel,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget inviteMember({
    String inviteeEmail,
    TimebankModel timebankModel,
  }) {
    return RaisedButton(
      onPressed: () async {
        inivitationManager.showProgress(
            title: AppLocalizations.of(context)
                .translate('members', 'sending_invitation'));
        await inivitationManager.inviteMemberToTimebankViaLink(
          invitation: InvitationViaLink.createInvitation(
            timebankTitle: timebankModel.name,
            timebankId: timebankModel.id,
            senderEmail: SevaCore.of(context).loggedInUser.email,
            inviteeEmail: inviteeEmail,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          ),
        );
        inivitationManager.hideProgress();
        setState(() {});
      },
      child: Text(AppLocalizations.of(context).translate('members', 'invite')),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  void showProgressDialog() {}

  Widget resendInvitation({InvitationViaLink invitation}) {
    return RaisedButton(
      onPressed: () async {
        inivitationManager.showProgress(
            title: AppLocalizations.of(context)
                .translate('members', 'sending_invitation'));
        await inivitationManager.resendInvitationToMember(
          invitation: invitation,
        );
        inivitationManager.hideProgress();

        setState(() {});
      },
      child: Text(
        AppLocalizations.of(context).translate('members', 'resend_invite'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
        ),
      ),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  Widget gettigStatus() {
    return RaisedButton(
      onPressed: null,
      child: Text(AppLocalizations.of(context).translate('members', 'dots')),
      color: Colors.indigo,
      textColor: Colors.white,
      shape: StadiumBorder(),
    );
  }

  Widget userWidget({
    UserModel user,
  }) {
    bool isJoined = false;
    if (validItems.contains(user.sevaUserID)) {
      isJoined = true;
    }

    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
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
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                  // subtitle: Text(user.email),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: RaisedButton(
                        onPressed: !isJoined
                            ? () async {
                                await addMemberToTimebank(
                                        sevaUserId: user.sevaUserID,
                                        timebankId: timebankModel.id,
                                        communityId: timebankModel.communityId,
                                        userEmail: user.email)
                                    .commit();
                                setState(() {
                                  getMembersList();
                                });
                              }
                            : null,
                        child: Text(isJoined
                            ? AppLocalizations.of(context)
                                .translate('members', 'joined')
                            : AppLocalizations.of(context)
                                .translate('members', 'add')),
                        color: FlavorConfig.values.theme.primaryColor,
                        textColor: Colors.white,
                        shape: StadiumBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get getTimebankCodesWidget {
    return StreamBuilder<List<TimebankCodeModel>>(
        stream: getTimebankCodes(timebankId: widget.timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<TimebankCodeModel> codeList = snapshot.data.reversed.toList();

          if (codeList.length == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(AppLocalizations.of(context)
                    .translate('members', 'no_codes')),
              ),
            );
          }
          return Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: codeList.length,
                itemBuilder: (context, index) {
                  String length = "0";

                  TimebankCodeModel timebankCode = codeList.elementAt(index);
                  if (timebankCode.usersOnBoarded == null) {
                    length = AppLocalizations.of(context)
                        .translate('members', 'no_yet_redeemed');
                  } else {
                    if (timebankCode.usersOnBoarded.length == 1) {
                      length = AppLocalizations.of(context)
                          .translate('members', 'by_1');
                    } else if (timebankCode.usersOnBoarded.length > 1) {
                      length =
                          "${AppLocalizations.of(context).translate('members', 'by_n')} ${timebankCode.usersOnBoarded.length} ${AppLocalizations.of(context).translate('members', 'users')}";
                    } else {
                      length = AppLocalizations.of(context)
                          .translate('members', 'no_yet_redeemed');
                    }
                  }
                  return GestureDetector(
                    child: Card(
                      margin: EdgeInsets.all(5),
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(FlavorConfig.values.timebankName == "Yang 2020"
                                ? AppLocalizations.of(context)
                                        .translate('members', 'yang_code') +
                                    timebankCode.timebankCode
                                : AppLocalizations.of(context)
                                        .translate('members', 'timebank_code') +
                                    timebankCode.timebankCode),
                            Text(length),
                            Text(
                              DateTime.now().millisecondsSinceEpoch >
                                      timebankCode.validUpto
                                  ? AppLocalizations.of(context)
                                      .translate('members', 'expired')
                                  : AppLocalizations.of(context)
                                      .translate('members', 'active'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Share.share(shareText(timebankCode));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('members', 'share_code'),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey,
                                    ),
                                    iconSize: 30,
                                    onPressed: () {
                                      deleteShareCode(
                                          timebankCode.timebankCodeId);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
  }

  String shareText(TimebankCodeModel timebankCode) {
    var text =
        "${SevaCore.of(context).loggedInUser.fullname} ${AppLocalizations.of(context).translate('members', 'invited_you')} \"${timebankModel.name}\" ${AppLocalizations.of(context).translate('members', 'invite_text')} \"${timebankCode.timebankCode}\" ${AppLocalizations.of(context).translate('members', 'prompt_text')}";
    return text;
  }

  Stream<List<TimebankCodeModel>> getTimebankCodes({
    String timebankId,
  }) async* {
    var data = Firestore.instance
        .collection('timebankCodes')
        .where('timebankId', isEqualTo: timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<TimebankCodeModel>>.fromHandlers(
        handleData: (querySnapshot, timebankCodeSink) {
          List<TimebankCodeModel> timebankCodes = [];
          querySnapshot.documents.forEach((documentSnapshot) {
            timebankCodes.add(TimebankCodeModel.fromMap(
              documentSnapshot.data,
            ));
          });
          timebankCodeSink.add(timebankCodes);
        },
      ),
    );
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
    String timebankCode = createCryptoRandomString();

    String teamName = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('members', 'code_generated')),
          content: new Row(
            children: <Widget>[
              Text(timebankCode +
                  AppLocalizations.of(context).translate('members', 'is_code')),
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                AppLocalizations.of(context)
                    .translate('members', 'publish_code'),
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                var today = new DateTime.now();
                var oneDayFromToday =
                    today.add(new Duration(days: 30)).millisecondsSinceEpoch;
                registerTimebankCode(
                  timebankCode: timebankCode,
                  timebankId: widget.timebankId,
                  validUpto: oneDayFromToday,
                  communityId: widget.communityId,
                );
                Navigator.of(context).pop("completed");
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('shared', 'cancel'),
                style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static String createCryptoRandomString([int length = 10]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(100));
    return base64Url.encode(values).substring(0, 6).toLowerCase();
  }

  Future<void> registerTimebankCode({
    String timebankId,
    String timebankCode,
    int validUpto,
    String communityId,
  }) async {
    codeModel.createdOn = DateTime.now().millisecondsSinceEpoch;
    codeModel.timebankId = timebankId;
    codeModel.validUpto = validUpto;
    codeModel.timebankCodeId = utils.Utils.getUuid();
    codeModel.timebankCode = timebankCode;
    codeModel.communityId = communityId;

    print('codemodel ${codeModel.toString()}');
    await Firestore.instance
        .collection('timebankCodes')
        .document(codeModel.timebankCodeId)
        .setData(codeModel.toMap());
  }

  void deleteShareCode(String timebankCodeId) {
    Firestore.instance
        .collection("timebankCodes")
        .document(timebankCodeId)
        .delete();

    print('deleted');
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  WriteBatch addMemberToTimebank(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) {
    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var addToCommunityRef =
        Firestore.instance.collection('communities').document(communityId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(userEmail);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    batch.updateData(newMemberDocumentReference, {
      'communities': FieldValue.arrayUnion([communityId]),
    });

    batch.updateData(addToCommunityRef, {
      'members': FieldValue.arrayUnion([sevaUserId]),
    });

    sendNotificationToMember(
        communityId: communityId,
        timebankId: timebankId,
        sevaUserId: sevaUserId,
        userEmail: userEmail);

    return batch;
  }

  Future<void> sendNotificationToMember(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) async {
    UserAddedModel userAddedModel = UserAddedModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        adminName: SevaCore.of(context).loggedInUser.fullname);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: userAddedModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberAdded,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: sevaUserId);

    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
  }
}
