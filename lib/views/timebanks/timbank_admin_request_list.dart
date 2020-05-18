import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/invite_members.dart';
import 'package:sevaexchange/views/timebanks/invite_members_group.dart';
import 'package:shimmer/shimmer.dart';

import '../switch_timebank.dart';
import 'edit_super_admins_view.dart';

class TimebankRequestAdminPage extends StatefulWidget {
  final String timebankId;
  final String userEmail;
  final bool isUserAdmin;
  final bool isCommunity;
  final bool isFromGroup;
  var listOfMembers = HashMap<String, UserModel>();

  TimebankRequestAdminPage({
    @required this.isUserAdmin,
    @required this.timebankId,
    @required this.userEmail,
    @required this.isCommunity,
    @required this.isFromGroup,
  });

  @override
  _TimebankAdminPageState createState() => _TimebankAdminPageState();
}

class _TimebankAdminPageState extends State<TimebankRequestAdminPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _listController;
  ScrollController _pageScrollController;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  var _isLoading = false;
  var _lastReached = false;
  var adminsNotLoaded = true;
  var timebankModel = TimebankModel({});
  var _adminsWidgets = List<Widget>();
  var _coordinatorsWidgets = List<Widget>();
  var _membersWidgets = List<Widget>();
  var _requestsWidgets = List<Widget>();
  var _adminEmails = List<String>();
  var isProgressBarActive = false;
  var debounceValue = Debouncer(milliseconds: 500);
  var joinRequestList = List<JoinRequestModel>();

  HashMap<String, int> emailIndexMap = HashMap();
  HashMap<int, UserModel> indexToModelMap = HashMap();
  HashMap<String, bool> adminToModelMap = HashMap();
  Map onActivityResult;
  var selectedUsers = HashMap<String, UserModel>();
  var nullCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final GlobalKey<FormState> _formKey = GlobalKey();
  String reason = '';

  @override
  void initState() {
    _listController = ScrollController();
    _pageScrollController = ScrollController();
    _pageScrollController.addListener(_scrollListener);
    getTimebankJoinRequest(timebankID: widget.timebankId)
        .listen((_joinRequestList) {
      joinRequestList = _joinRequestList == null ? [] : _joinRequestList;
      resetAndLoad();
    });
    FirestoreManager.getTimebankModelStream(timebankId: widget.timebankId)
        .listen((_timebankModel) {
      timebankModel = _timebankModel;
      resetAndLoad();
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _listController.removeListener(_scrollListener);
    super.dispose();
  }

  _scrollListener() {
    if (_listController.position.viewportDimension >=
            _listController.position.maxScrollExtent &&
        !_listController.position.outOfRange &&
        !_isLoading &&
        !_lastReached) {
      if (nullCount < 3) {
        loadNextMembers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: getTimebackList(context, widget.timebankId),
    );
  }

  Widget get circularBar {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getTimebackList(BuildContext context, String timebankId) {
    if (isProgressBarActive) {
      return AlertDialog(
        title: Text('Updating Users'),
        content: LinearProgressIndicator(),
      );
    }
    if (timebankModel.id != "") {
      return getDataScrollView(
        context,
        timebankModel,
      );
    }
    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return circularBar;
        }
        TimebankModel timebankModel = snapshot.data;
        return getDataScrollView(
          context,
          timebankModel,
        );
      },
    );
  }

  Widget getDataScrollView(
    BuildContext context,
    TimebankModel timebankModel,
  ) {
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        controller: _pageScrollController,
        slivers: <Widget>[
          // getAppBar(context, timebankModel),
          SliverList(
            delegate: SliverChildListDelegate(
              getContent(context, timebankModel),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAppBar(BuildContext context, TimebankModel timebankModel) {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      expandedHeight: 0,
      floating: false,
      snap: false,
      pinned: true,
      elevation: 0,
      actions: <Widget>[
        !(timebankModel.admins
                .contains(SevaCore.of(context).loggedInUser.sevaUserID))
            ? Offstage()
            : IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSuperTimebankView(
                        timebankId: timebankModel.id,
                        superAdminTimebankModel: timebankModel,
                      ),
                    ),
                  );
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          timebankModel.name,
          style: TextStyle(color: Colors.white),
        ),
        collapseMode: CollapseMode.pin,
        background: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  height: 130,
                  width: 130,
                  margin: EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                        blurRadius: 17,
                      )
                    ],
                    shape: CircleBorder(),
                  ),
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'lib/assets/images/profile.png',
                      image: timebankModel.photoUrl == null
                          ? 'lib/assets/images/profile.png'
                          : timebankModel.photoUrl,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future loadItems() async {
    if (adminsNotLoaded) {
      adminsNotLoaded = false;
      if (widget.isUserAdmin) {
        var newList =
            await getFutureTimebankJoinRequest(timebankID: widget.timebankId);
        if (newList != null && newList.length > 0) {
          loadAllRequest(newList);
        }
      }
      await loadAdmins();
      if ((FlavorConfig.appFlavor == Flavor.APP ||
          FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
        await loadCoordinators();
      }
      await loadNextMembers();
      setState(() {});
    }
  }

  Future loadAllRequest(List<JoinRequestModel> modelItemList) async {
    _requestsWidgets = [];
    _requestsWidgets.add(getSectionTitle(context, 'Requests'));
    for (var i = 0; i < modelItemList.length; i++) {
      if (modelItemList[i] == null ||
          modelItemList[i].operationTaken ||
          modelItemList[i].userId == null) {
        continue;
      }
      var isWidgetEmpty = false;
      var userWidget = FutureBuilder<UserModel>(
        future:
            FirestoreManager.getUserForId(sevaUserId: modelItemList[i].userId),
        builder: (context, snapshot) {
          var requestModelItem = modelItemList[i];
          if (snapshot.hasError) return Text(snapshot.error.toString());
          if (snapshot.connectionState == ConnectionState.waiting) {
            return shimmerWidget;
          }

          UserModel user = snapshot.data;
          if (user == null || user.sevaUserID == null) {
            isWidgetEmpty = true;
            return Container();
          }
          widget.listOfMembers[user.sevaUserID] = user;
          return getUserRequestWidget(
            user,
            context,
            timebankModel,
            requestModelItem,
            SevaCore.of(context).loggedInUser.currentCommunity,
          );
        },
      );
      if (!isWidgetEmpty) {
        _requestsWidgets.add(userWidget);
      }
    }
    if (_requestsWidgets.length == 1) {
      _requestsWidgets = [];
    }
    setState(() {});
  }

  Widget getUserRequestWidget(
      UserModel user,
      BuildContext context,
      TimebankModel model,
      JoinRequestModel joinRequestModel,
      String communityId) {
    user.photoURL = user.photoURL == null ? defaultUserImageURL : user.photoURL;
    user.fullname = user.fullname == null ? defaultUsername : user.fullname;
    var item = Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(user.photoURL ?? defaultUserImageURL),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        user.fullname,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            widget.isUserAdmin
                ? Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: CustomRaisedButton(
                          action: Actions.Approve,
                          debouncer: debounceValue,
                          onTap: () async {
                            setState(() {
                              isProgressBarActive = true;
                            });

                            await addMemberToTimebank(
                              timebankId: joinRequestModel.entityId,
                              joinRequestId: joinRequestModel.id,
                              memberJoiningSevaUserId: joinRequestModel.userId,
                              notificaitonId: joinRequestModel.notificationId,
                              communityId: communityId,
                              newMemberJoinedEmail: user.email,
                              isFromGroup: joinRequestModel.isFromGroup,
                            ).commit();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: CustomRaisedButton(
                          action: Actions.Reject,
                          debouncer: debounceValue,
                          onTap: () async {
                            setState(() {
                              isProgressBarActive = true;
                            });

                            rejectMemberJoinRequest(
                              joinRequestId: joinRequestModel.id,
                              notificaitonId: joinRequestModel.notificationId,
                              timebankId: joinRequestModel.entityId,
                            ).commit().then((onValue) {
                              resetAndLoad();
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : Offstage(),
          ],
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            //                   <--- left side
            color: Colors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: item,
    );
  }

  WriteBatch rejectMemberJoinRequest({
    String timebankId,
    String joinRequestId,
    String notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  WriteBatch addMemberToTimebank({
    String timebankId,
    String memberJoiningSevaUserId,
    String joinRequestId,
    String communityId,
    String newMemberJoinedEmail,
    String notificaitonId,
    bool isFromGroup,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(newMemberJoinedEmail);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.updateData(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
        'currentCommunity': communityId
      });

      var addToCommunityRef =
          Firestore.instance.collection('communities').document(communityId);
      batch.updateData(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  void resetVariables() {
    _pageIndex = 1;
    _indexSoFar = 0;
    currSelectedState = false;
    selectedUserModelIndex = -1;
    _isLoading = false;
    _lastReached = false;
    adminsNotLoaded = true;
    _adminsWidgets = [];
    _membersWidgets = [];
    _adminEmails = [];
    _requestsWidgets = [];
    _coordinatorsWidgets = [];
    emailIndexMap = HashMap();
    indexToModelMap = HashMap();
    adminToModelMap = HashMap();
    nullCount = 0;
  }

  void resetAndLoad() async {
    resetVariables();
    await loadItems();
    setState(() {
      isProgressBarActive = false;
    });
  }

  List<Widget> getContent(BuildContext context, TimebankModel model) {
    if (timebankModel.id == "") {
      timebankModel = model;
    }
    loadItems();
    return [listViewWidget];
  }

  List<Widget> getAllMembers() {
    var _avtars = List<Widget>();
    _avtars.addAll(_adminsWidgets);
    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      _avtars.addAll(_coordinatorsWidgets);
    }
    _avtars.addAll(_requestsWidgets);
    _avtars.addAll(_membersWidgets);
    return _avtars;
  }

  Widget get emptyCard {
    return Container(
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Text('No user found'),
        ),
      ),
    );
  }

  Widget get listViewWidget {
    var _avtars = getAllMembers();
    return ListView.builder(
      scrollDirection: Axis.vertical,
      controller: _listController,
      shrinkWrap: true,
      itemCount: fetchItemsCount(),
      itemBuilder: (BuildContext ctxt, int index) => Padding(
        padding: const EdgeInsets.all(0.0),
        child: index < _avtars.length
            ? _avtars[index]
            : Container(
                width: double.infinity,
                height: 80,
                child: circularBar,
              ),
      ),
    );
  }

  int fetchItemsCount() {
    var _avtars = getAllMembers();
    if (!_lastReached) {
      return _avtars.length + 1;
    }
    return _avtars.length;
  }

  Future loadAdmins() async {
    if (timebankModel.admins == null) {
      timebankModel.admins = List<String>();
    }
    var adminUserModel = await FirestoreManager.getUserForUserModels(
        admins: timebankModel.admins);
    _adminsWidgets = [];
    _adminEmails = [];
    _adminsWidgets.add(getSectionTitle(context, 'Admins & Organizers'));
    SplayTreeMap<String, dynamic>.from(adminUserModel, (a, b) => a.compareTo(b))
        .forEach((key, user) {
      String email = user.email.toString().trim();
      _adminEmails.add(email);
      _adminsWidgets
          .add(getUserWidget(user, context, timebankModel, true, false));
    });
  }

  Widget getUserWidget(UserModel user, BuildContext context,
      TimebankModel model, bool isAdmin, bool isPromoteBottonVisible) {
    user.photoURL = user.photoURL == null ? defaultUserImageURL : user.photoURL;
    user.fullname = user.fullname == null ? defaultUsername : user.fullname;
    var item = Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileViewer(
                      userEmail: user.email,
                    )));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(user.photoURL ?? defaultUserImageURL),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          user.fullname,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              getUserWidgetButton(
                  user, context, model, isAdmin, isPromoteBottonVisible),
            ],
          ),
        ));
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            //                   <--- left side
            color: Colors.grey,
            width: 0.2,
          ),
        ),
      ),
      child: item,
    );
  }

  _exitTimebankOrGroup({
    UserModel user,
    BuildContext context,
    TimebankModel model,
    bool isAdmin,
  }) {
    return showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text('Exit ${widget.isFromGroup ? 'Group' : 'Timebank'}',
              style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(hintText: 'Enter reason to exit'),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter reason to exit';
                    }
                    reason = value;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      'Exit',
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content:
                                Text("Please check your internet connection."),
                            action: SnackBarAction(
                              label: 'Dismiss',
                              onPressed: () => _scaffoldKey.currentState
                                  .hideCurrentSnackBar(),
                            ),
                          ),
                        );
                        return;
                      }
                      if (!_formKey.currentState.validate()) {
                        return;
                      }
                      Navigator.pop(viewContext);

                      setState(() {
                        isProgressBarActive = true;
                      });
                      List<String> members =
                          timebankModel.members.map((s) => s).toList();
                      members.remove(user.sevaUserID);

                      if (widget.isCommunity != null && widget.isCommunity) {
                        CommunityModel communityModel =
                            await getCommunityDetailsByCommunityId(
                                communityId: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity);

                        await _exitFromTimebank(
                                model: timebankModel,
                                userId: user.sevaUserID,
                                communityModel: communityModel)
                            .commit();
                      } else {
                        model.members = members;

                        print(" time id ${model.id}");
                        print(" members  ${model.members}");
                        print(" reason  ${reason}");

                        sendNotificationToAdmin(
                            user: user,
                            timebank: model,
                            communityId: SevaCore.of(context)
                                .loggedInUser
                                .currentCommunity);

                        await FirestoreManager.updateTimebank(
                            timebankModel: model);

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePageRouter(),
                          ),
                        );
                      }
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: dialogButtonSize, color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getUserWidgetButton(
    UserModel user,
    BuildContext context,
    TimebankModel model,
    bool isAdmin,
    bool isPromoteBottonVisible,
  ) {
//    print(
//        "SevaCore.of(context).loggedInUser.sevaUserID:${SevaCore.of(context).loggedInUser.sevaUserID}");
//    print("user.sevaUserID:${user.sevaUserID}");

    if (SevaCore.of(context).loggedInUser.sevaUserID == user.sevaUserID &&
        !widget.isUserAdmin) {
      return Padding(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: CustomRaisedButton(
          debouncer: debounceValue,
          action: Actions.Exit,
          onTap: () async {
            _exitTimebankOrGroup(
                user: user, context: context, model: model, isAdmin: isAdmin);
          },
        ),
      );
    } else {
      return SevaCore.of(context).loggedInUser.sevaUserID == user.sevaUserID ||
              !widget.isUserAdmin ||
              user.sevaUserID == timebankModel.creatorId
          ? Offstage()
          : Row(
              children: <Widget>[
                if (isPromoteBottonVisible)
                  Padding(
                    padding: EdgeInsets.only(left: 2, right: 2),
                    child: CustomRaisedButton(
                      debouncer: debounceValue,
                      action: Actions.Promote,
                      onTap: () async {
                        setState(() {
                          isProgressBarActive = true;
                        });
                        List<String> admins =
                            timebankModel.admins.map((s) => s).toList();
                        admins.add(user.sevaUserID);
                        _updateTimebank(timebankModel, admins: admins);
                      },
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(left: 2, right: 2),
                  child: CustomRaisedButton(
                    debouncer: debounceValue,
                    action: Actions.Remove,
                    onTap: () async {
                      //Here we need to put dialog

                      Map<String, bool> onActivityResult = await showAdvisory(
                          dialogTitle:
                              "Are you sure you want to remove ${user.fullname}?");
                      if (onActivityResult['PROCEED']) {
                        setState(() {
                          isProgressBarActive = true;
                        });
                        if (isAdmin) {
                          List<String> admins =
                              timebankModel.admins.map((s) => s).toList();
                          admins.remove(user.sevaUserID);
                          _updateTimebank(timebankModel, admins: admins);
                        } else {
                          List<String> members =
                              timebankModel.members.map((s) => s).toList();
                          members.remove(user.sevaUserID);
                          if (widget.isCommunity != null &&
                              widget.isCommunity) {
                            _removeUserFromCommunityAndUpdateUserCommunityList(
                              model: timebankModel,
                              members: members,
                              userId: user.sevaUserID,
                            );
                          } else {
                            _updateTimebank(timebankModel, members: members);
                          }
                        }
                      } else {
                        return;
                      }
                    },
                  ),
                ),
              ],
            );
    }
  }

  Future _addUserToCommunityAndUpdateUserCommunityList({
    TimebankModel model,
    List<UserModel> members,
    String currentCommunity,
  }) async {
    if (model == null || members == null || members.length == 0) {
      return;
    }
    if (model.members == null) {
      model.members = List<String>();
    }
    var communityModel =
        await getCommunityDetailsByCommunityId(communityId: currentCommunity);
    members.forEach((user) async {
      //Update community members inside community collection
      var communityMembers = List<String>();
      if (!communityModel.members.contains(user)) {
        communityMembers.addAll(communityModel.members);
      }
      communityMembers.add(user.sevaUserID);
      communityModel.members = communityMembers;

      //Update community inside user collections
      var communities = List<String>();
      if (user.communities.length > 0) {
        communities.addAll(user.communities);
      }
      if (user.communities != null &&
          !user.communities.contains(currentCommunity)) {
        communities.add(currentCommunity);
      }
      user.communities = communities;
      if (user.currentCommunity == '') {
        user.currentCommunity =
            SevaCore.of(context).loggedInUser.currentCommunity;
      }
      var insertMembers = model.members.contains(user.sevaUserID);
      print("Itemqwerty:${user.sevaUserID} is present:$insertMembers");
      var memberList = List<String>();
      memberList.addAll(model.members);
      if (!model.members.contains(user.sevaUserID)) {
        memberList.add(user.sevaUserID);
      }
      model.members = memberList;
      print(
          "Itemqwerty:${user.sevaUserID} is listSize:${model.members.length}");
      await updateUser(user: user);
    });
    await updateCommunity(communityModel: communityModel);
    await FirestoreManager.updateTimebank(timebankModel: model);
    resetAndLoad();
  }

  WriteBatch _exitFromTimebank(
      {TimebankModel model, String userId, CommunityModel communityModel}) {
    WriteBatch batch = Firestore.instance.batch();

    UserModel user = SevaCore.of(context).loggedInUser;
    String currentCommunity =
        SevaCore.of(context).loggedInUser.currentCommunity;

    var timebankRef =
        Firestore.instance.collection('timebanknew').document(model.id);
    var communityRef =
        Firestore.instance.collection('communities').document(currentCommunity);

    var userRef = Firestore.instance.collection('users').document(user.email);

    if (model.members.contains(user.sevaUserID)) {
      batch.updateData(timebankRef, {
        'members': FieldValue.arrayRemove([user.sevaUserID]),
      });
    }

    var communities = List<String>();
    if (!widget.isFromGroup) {
      if (user.communities != null &&
          user.communities.contains(currentCommunity)) {
        communities.addAll(user.communities);
        communities.remove(currentCommunity);
        batch.updateData(userRef, {
          'communities': FieldValue.arrayRemove([currentCommunity]),
          'currentCommunity': communities.length > 0 ? communities[0] : ''
        });
        if (communities.length > 0) {
          SevaCore.of(context).loggedInUser.currentCommunity = communities[0];
        }
      }
      if (communityModel.members.contains(user.sevaUserID)) {
        batch.updateData(communityRef, {
          'members': FieldValue.arrayRemove([user.sevaUserID]),
        });
      }
    }

    sendNotificationToAdmin(
        user: user, timebank: model, communityId: currentCommunity);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SwitchTimebank(),
      ),
    );

    return batch;
  }

  Future _removeUserFromCommunityAndUpdateUserCommunityList({
    TimebankModel model,
    List<String> members,
    String userId,
  }) async {
    if (model == null || members == null || members.length == 0) {
      return;
    }
    UserModel user = await getUserForId(sevaUserId: userId);
    var currentCommunity = SevaCore.of(context).loggedInUser.currentCommunity;
    print("Current community:$currentCommunity");
    var communities = List<String>();
    if (user.communities != null && user.communities.length > 0) {
      communities.addAll(user.communities);
      communities.remove(currentCommunity);
    }
    user.communities = communities.length > 0 ? communities : null;

    if (user.communities == null) {
      user.currentCommunity = '';
    } else if (user.communities.contains(currentCommunity)) {
      user.currentCommunity =
          user.communities.length > 0 ? user.communities[0] : '';
    }
    var communityModel =
        await getCommunityDetailsByCommunityId(communityId: currentCommunity);
    if (communityModel.members.contains(user.sevaUserID)) {
      var newMembers = List<String>();
      for (var i = 0; i < communityModel.members.length; i++) {
        if (communityModel.members[i] != user.sevaUserID) {
          newMembers.remove(communityModel.members[i]);
        }
      }
      communityModel.members = newMembers;
    }
    model.members = members;
    await updateUser(user: user);
    await updateCommunity(communityModel: communityModel);
    await FirestoreManager.updateTimebank(timebankModel: model);
    resetAndLoad();
  }

  void sendNotificationToAdmin({
    UserModel user,
    TimebankModel timebank,
    String communityId,
  }) async {
    UserExitModel userExitModel = UserExitModel(
        userPhotoUrl: user.photoURL,
        timebank: timebank.name,
        reason: reason,
        userName: user.fullname);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: userExitModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberExitTimebank,
        communityId: communityId,
        senderUserId: user.sevaUserID,
        targetUserId: timebank.creatorId);
    print("bhhfhff ${userExitModel} ");
    print(" timebank id ${timebank.id + timebank.members.toString()}");
    await Firestore.instance
        .collection('timebanknew')
        .document(timebank.id)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
  }

  Future loadCoordinators() async {
    if (timebankModel.admins == null) {
      timebankModel.coordinators = List<String>();
    }
    if (timebankModel.coordinators.length != 0) {
      bool isCoordinator = timebankModel.coordinators.contains(
        SevaCore.of(context).loggedInUser.sevaUserID,
      );

      var onValue = await FirestoreManager.getUserForUserModels(
          admins: timebankModel.admins);
      _adminsWidgets = [];
      _adminEmails = [];
      _adminsWidgets.add(getSectionTitle(context, 'Coordinators'));
      SplayTreeMap<String, dynamic>.from(onValue, (a, b) => a.compareTo(b))
          .forEach((key, user) {
        _adminEmails.add(user.email);
        if (isCoordinator) {
          _coordinatorsWidgets
              .add(getUserWidget(user, context, timebankModel, true, false));
        }
      });
      setState(() {});
    }
  }

  Future<Map> showAdvisory({String dialogTitle, String confirmationTitle}) {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
              dialogTitle,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              FlatButton(
                child: Text(
                  confirmationTitle ?? "Yes",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  return Navigator.of(viewContext).pop({'PROCEED': true});
                },
              ),
            ],
          );
        });
  }

  void _navigateToAddMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InviteMembersGroup(
          parenttimebankid: SevaCore.of(context).loggedInUser.currentTimebank,
          timebankModel: timebankModel,
        ),
      ),
    );
  }

  Future loadNextMembers() async {
    if (_membersWidgets.length == 0) {
      if (widget.isUserAdmin) {
        var gesture = TransactionLimitCheck(
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                getSectionTitle(context, 'Members '),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Image.asset("lib/assets/images/add.png"),
                )
              ],
            ),
            onTap: widget.isFromGroup
                ? _navigateToAddMembers
                : () async {
                    print(
                        "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nTimebankCode");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteAddMembers(timebankModel.id,
                            timebankModel.communityId, timebankModel),
                      ),
                    );
                  },
          ),
        );
        _membersWidgets.add(gesture);
      } else {
        _membersWidgets.add(
          getSectionTitle(context, 'Members '),
        );
      }
    }
    if (!_isLoading && !_lastReached) {
      _isLoading = true;
      UserModelListMoreStatus onValue =
          await FirestoreManager.getUsersForAdminsCoordinatorsMembersTimebankId(
              widget.timebankId, _pageIndex, widget.userEmail);
      var userModelList = onValue.userModelList;
      if (userModelList == null || userModelList.length == 0) {
        nullCount++;
        _isLoading = false;
        _pageIndex = _pageIndex + 1;
        if (nullCount < 3) {
          loadNextMembers();
        } else {
          setState(() {
            if (_membersWidgets.length == 1) {
              _membersWidgets.add(emptyCard);
            }
            _lastReached = true;
          });
        }
      } else {
        nullCount = 0;
        var addItems = userModelList.map((memberObject) {
          if (_adminEmails.contains(memberObject.email.trim())) {
            return Offstage();
          }
          var member = memberObject.sevaUserID;
          if (widget.listOfMembers != null &&
              widget.listOfMembers.containsKey(member)) {
            return getUserWidget(widget.listOfMembers[member], context,
                timebankModel, false, true);
          }
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              widget.listOfMembers[user.sevaUserID] = user;
              return getUserWidget(user, context, timebankModel, false, true);
            },
          );
        }).toList();
        if (addItems.length > 0) {
          var lastIndex = _membersWidgets.length;
          setState(() {
            var iterationCount = 0;
            for (int i = 0; i < addItems.length; i++) {
              var email = userModelList[i].email.trim();
              if (emailIndexMap[userModelList[i].email] == null &&
                  !_adminEmails.contains(email)) {
//                print("Member email found:$email");
                // Filtering duplicates
                _membersWidgets.add(addItems[i]);
                indexToModelMap[lastIndex] = userModelList[i];
                emailIndexMap[email] = lastIndex++;
                iterationCount++;
              }
            }
            _indexSoFar = _indexSoFar + iterationCount;
            _pageIndex = _pageIndex + 1;
          });
        }
        _isLoading = false;
      }
      if (onValue.lastPage == true) {
        setState(() {
          if (_membersWidgets.length == 1) {
            _membersWidgets.add(emptyCard);
          }
          _lastReached = onValue.lastPage;
        });
      }
    }
  }

  Widget getCoordinationList(BuildContext context, TimebankModel model) {
    if (model.coordinators == null || model.coordinators.isEmpty)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Coordinators'),
        ...model.coordinators.map((coordinator) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: coordinator),
            builder: (context, snapshot) {
              if (snapshot == null || !snapshot.hasData) return Offstage();
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              return getUserWidget(user, context, model, true, false);
            },
          );
        }).toList(),
      ],
    );
  }

  void removeAsAdmin(TimebankModel model, UserModel user) {
    List<String> admins = model.admins.map((s) => s).toList();
    List<String> coordinators = model.coordinators.map((s) => s).toList();
    coordinators.add(user.sevaUserID);
    admins.remove(user.sevaUserID);
    _updateTimebank(
      model,
      coordinators: coordinators,
      admins: admins,
    );
  }

  void removeFromTimebank(
    TimebankModel model,
    UserModel user,
  ) {
    List<String> admins = model.admins.map((s) => s).toList();
    List<String> coordinators = model.coordinators.map((s) => s).toList();
    List<String> members = model.members.map((s) => s).toList();
    admins.remove(user.sevaUserID);
    coordinators.remove(user.sevaUserID);
    members.remove(user.sevaUserID);
    _updateTimebank(
      model,
      members: members,
      admins: admins,
      coordinators: coordinators,
    );
  }

  void addToAdmin(TimebankModel model, UserModel user) {
    List<String> admins = model.admins.map((s) => s).toList();
    List<String> coordinators = model.coordinators.map((s) => s).toList();
    admins.add(user.sevaUserID);
    coordinators.remove(user.sevaUserID);
    _updateTimebank(
      model,
      admins: admins,
      coordinators: coordinators,
    );
  }

  Widget getSectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget getDataCard({
    @required String title,
  }) {
    return Container(
      child: Column(
        children: <Widget>[Text('')],
      ),
    );
  }

  Widget get shimmerWidget {
    return Shimmer.fromColors(
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey.withAlpha(40),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
            title: Container(
              color: Colors.grey.withAlpha(90),
              height: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(90),
            ),
            subtitle: Container(
              color: Colors.grey.withAlpha(90),
              height: 8,
            )),
      ),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
    );
  }

  Future _updateTimebank(
    TimebankModel model, {
    List<String> admins,
    List<String> coordinators,
    List<String> members,
  }) async {
    if (model == null) {
      return;
    }
    if (admins != null) {
      model.admins = admins;
    }
    if (coordinators != null) {
      model.coordinators = coordinators;
    }
    if (members != null) {
      model.members = members;
    }
    await FirestoreManager.updateTimebank(timebankModel: model);
    resetAndLoad();
  }
}

enum Actions {
  Approve,
  Reject,
  Remove,
  Promote,
  Exit,
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class CustomRaisedButton extends StatelessWidget {
  final Actions action;
  final Function onTap;
  final Debouncer debouncer;

  const CustomRaisedButton({
    Key key,
    this.onTap,
    this.action,
    this.debouncer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var btn = RaisedButton(
      padding: EdgeInsets.all(0),
      color: (action == Actions.Approve || action == Actions.Promote)
          ? null
          : Colors.red,
      child: Text(
        action.toString().split('.')[1],
        style: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        debouncer.run(() => onTap());
      },
    );
    return Container(
      width: 70,
      height: 30,
      child: btn,
    );
  }
}
