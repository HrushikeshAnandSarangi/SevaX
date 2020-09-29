import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/reported_member_navigator_widget.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/invite_members.dart';
import 'package:sevaexchange/views/timebanks/invite_members_group.dart';
import 'package:sevaexchange/views/timebanks/transfer_ownership_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:shimmer/shimmer.dart';

import '../switch_timebank.dart';
import 'member_level.dart';

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
    this.isCommunity,
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
  final profanityDetector = ProfanityDetector();

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
  BuildContext parentContext;
  @override
  void dispose() {
    _listController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
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
    super.build(context);
    parentContext = context;
    return Scaffold(
      key: _scaffoldKey,
      body: getTimebackList(context, widget.timebankId),
    );
  }

  Widget get circularBar {
    return LoadingIndicator();
  }

  Widget getTimebackList(BuildContext context, String timebankId) {
    if (isProgressBarActive) {
      return AlertDialog(
        title: Text(S.of(context).updating_users),
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
    _requestsWidgets.add(
      getSectionTitle(
        context,
        S.of(context).requests,
      ),
    );
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
//                              isProgressBarActive = true;
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
          child: Text(
            S.of(context).no_user_found,
          ),
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
    // _adminsWidgets.add(reportedMemberBuilder(
    //     SevaCore.of(context).loggedInUser.currentCommunity));
    if (widget.isUserAdmin ||
        SevaCore.of(context).loggedInUser.sevaUserID ==
            timebankModel.creatorId) {
      _adminsWidgets.add(ReportedMemberNavigatorWidget(
        isTimebankReport: !widget.isFromGroup,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        timebankModel: timebankModel,
      ));
    }
    _adminsWidgets
        .add(getSectionTitle(context, S.of(context).admins_organizers));
    SplayTreeMap<String, dynamic>.from(adminUserModel, (a, b) => a.compareTo(b))
        .forEach((key, user) {
      String email = user.email.toString().trim();
      _adminEmails.add(email);
      _adminsWidgets
          .add(getUserWidget(user, context, timebankModel, true, false));
    });
  }

  Widget reportedMemberBuilder(String communityId) {
    return FutureBuilder(
      future: Firestore.instance
          .collection("reported_users_list")
          .where("communityId", isEqualTo: communityId)
          .getDocuments(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(snapshot.data.documents.length.toString());
        }
        return Container();
      },
    );
  }

  Widget getUserWidget(UserModel user, BuildContext context,
      TimebankModel model, bool isAdmin, bool isPromoteBottonVisible) {
    user.photoURL = user.photoURL == null ? defaultUserImageURL : user.photoURL;
    user.fullname = user.fullname == null ? defaultUsername : user.fullname;
    var item = Padding(
        padding: EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileViewer(
                  userEmail: user.email,
                  timebankId: timebankModel.id,
                  entityName: timebankModel.name,
                  isFromTimebank: !widget.isFromGroup,
                ),
              ),
            );
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

  void _exitTimebankOrGroup({
    UserModel user,
    BuildContext context,
    TimebankModel model,
    bool isAdmin,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
              '${S.of(context).exit} ${widget.isFromGroup ? S.of(context).group : S.of(context).timebank}',
              style: TextStyle(fontSize: 15.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                      hintText: S.of(context).enter_reason_to_exit),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(fontSize: 17.0),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).enter_reason_to_exit_hint;
                    } else if (profanityDetector.isProfaneString(value)) {
                      return S.of(context).profanity_text_alert;
                    } else {
                      reason = value;
                      globals.userExitReason = value;
                      return null;
                    }
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
                      S.of(context).exit,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                      ),
                    ),
                    onPressed: () async {
                      var connResult = await Connectivity().checkConnectivity();
                      if (connResult == ConnectivityResult.none) {
                        _scaffoldKey.currentState.showSnackBar(
                          SnackBar(
                            content: Text(S.of(context).check_internet),
                            action: SnackBarAction(
                              label: S.of(context).dismiss,
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

//                      List<String> members =
//                          timebankModel.members.map((s) => s).toList();
//                      members.remove(user.sevaUserID);
                      if (widget.isCommunity != null && widget.isCommunity) {
                        removeMemberTimebankFn(
                            context: parentContext,
                            userModel: user,
                            isFromExit: true,
                            timebankModel: model);
                      } else {
                        removeMemberGroupFn(
                            context: parentContext,
                            userModel: user,
                            isFromExit: true,
                            timebankModel: model);
//                        // TODO this is temporory fix a full fetched refreshing scienario is needed
//                        Navigator.of(parentContext).pushAndRemoveUntil(
//                            MaterialPageRoute(
//                              builder: (context) => HomePageRouter(),
//                            ),
//                            (Route<dynamic> route) => false);
//
//                        FirestoreManager.updateTimebank(timebankModel: model);
                      }
                    },
                  ),
                  FlatButton(
                    child: Text(
                      S.of(context).cancel,
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
    if (SevaCore.of(context).loggedInUser.sevaUserID == user.sevaUserID &&
        !widget.isUserAdmin) {
      return Padding(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: CustomRaisedButton(
          debouncer: debounceValue,
          action: Actions.Exit,
          onTap: () async {
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => TransferOwnerShipView(
//                  timebankModel: timebankModel,
//                ),
//              ),
//            );

            _exitTimebankOrGroup(
                user: user, context: context, model: model, isAdmin: isAdmin);
          },
        ),
      );
    } else {
      if (!widget.isUserAdmin) {
        return widget.isUserAdmin &&
                (SevaCore.of(context).loggedInUser.sevaUserID ==
                        user.sevaUserID ||
                    user.sevaUserID == timebankModel.creatorId)
            ? actionButtonsUser(user, model, isPromoteBottonVisible)
            : Offstage();
      } else {
        return widget.isUserAdmin &&
                (SevaCore.of(context).loggedInUser.sevaUserID ==
                        user.sevaUserID ||
                    user.sevaUserID == timebankModel.creatorId)
            ? Offstage()
            : actionButtonsAdmin(user, model, isPromoteBottonVisible);
      }
    }
  }

  Widget actionButtonsAdmin(
          UserModel user, TimebankModel model, bool isPromoteBottonVisible) =>
      PopupMenuButton(
        itemBuilder: (_context) {
          var list = List<PopupMenuEntry<Object>>();
          if (isPromoteBottonVisible == true) {
            list.add(
              PopupMenuItem(
                value: 1,
                child: CustomRaisedButton(
                  debouncer: debounceValue,
                  action: Actions.Promote,
                  onTap: () async {
                    Navigator.pop(_context);
                    setState(() {
                      isProgressBarActive = true;
                    });

                    // PROMOTTE
                    await MembershipManager.updateMembershipStatus(
                      associatedName:
                          SevaCore.of(context).loggedInUser.fullname,
                      communityId:
                          SevaCore.of(context).loggedInUser.currentCommunity,
                      timebankId: timebankModel.id,
                      notificationType:
                          NotificationType.MEMBER_PROMOTED_AS_ADMIN,
                      parentTimebankId: timebankModel.parentTimebankId,
                      targetUserId: user.sevaUserID,
                      timebankName: timebankModel.name,
                      userEmail: user.email,
                    );
                  },
                ),
              ),
            );
          } else {
            list.add(
              PopupMenuItem(
                value: 2,
                child: CustomRaisedButton(
                  debouncer: debounceValue,
                  action: Actions.Demote,
                  onTap: () async {
                    Navigator.pop(_context);
                    setState(() {
                      isProgressBarActive = true;
                    });
                    // DEMOTE
                    await MembershipManager.updateMembershipStatus(
                      associatedName:
                          SevaCore.of(context).loggedInUser.fullname,
                      communityId:
                          SevaCore.of(context).loggedInUser.currentCommunity,
                      timebankId: timebankModel.id,
                      notificationType:
                          NotificationType.MEMBER_DEMOTED_FROM_ADMIN,
                      parentTimebankId: timebankModel.parentTimebankId,
                      targetUserId: user.sevaUserID,
                      timebankName: timebankModel.name,
                      userEmail: user.email,
                    );
                  },
                ),
              ),
            );
          }
          list.add(
            PopupMenuItem(
              value: 3,
              child: CustomRaisedButton(
                debouncer: debounceValue,
                action: Actions.Remove,
                onTap: () async {
                  //Here we need to put dialog
                  Navigator.pop(_context);
                  Map<String, bool> onActivityResult = await showAdvisory(
                      dialogTitle:
                          "${S.of(context).member_removal_confirmation} ${user.fullname}?");
                  if (onActivityResult['PROCEED']) {
                    setState(() {
                      isProgressBarActive = true;
                    });
                    if (widget.isCommunity != null && widget.isCommunity) {
                      await removeMemberTimebankFn(
                        context: parentContext,
                        userModel: user,
                        isFromExit: false,
                        timebankModel: model,
                      );
                      setState(() {
                        isProgressBarActive = false;
                      });
                    } else {
                      await removeMemberGroupFn(
                        context: parentContext,
                        userModel: user,
                        isFromExit: false,
                        timebankModel: model,
                      );
                      setState(() {
                        isProgressBarActive = false;
                      });
                    }
                  } else {
                    return;
                  }
                },
              ),
            ),
          );

          list.add(
            PopupMenuItem(
              value: 4,
              child: CustomRaisedButton(
                  debouncer: debounceValue,
                  action: Actions.Loan,
                  onTap: () => {
                        Navigator.pop(_context),
                        _showFontSizePickerDialog(user, model)
                      }),
            ),
          );
          return list;
        },
        elevation: 4,
        padding: EdgeInsets.symmetric(horizontal: 10),
      );
  Widget actionButtonsUser(user, model, isPromoteBottonVisible) =>
      PopupMenuButton(
        itemBuilder: (_context) {
          var list = List<PopupMenuEntry<Object>>();
          if (isPromoteBottonVisible == true) {
            list.add(
              PopupMenuItem(
                value: 1,
                child: CustomRaisedButton(
                  debouncer: debounceValue,
                  action: Actions.Promote,
                  onTap: () async {
                    Navigator.pop(_context);
                    setState(() {
                      isProgressBarActive = true;
                    });

                    List<String> admins =
                        timebankModel.admins.map((s) => s).toList();
                    admins.add(user.sevaUserID);
                    Firestore.instance
                        .collection('communities')
                        .document(timebankModel.communityId)
                        .updateData({
                      'admins': FieldValue.arrayUnion([user.sevaUserID]),
                    });
                    _updateTimebank(timebankModel, admins: admins);
                  },
                ),
              ),
            );
          } else {
            list.add(
              PopupMenuItem(
                value: 2,
                child: CustomRaisedButton(
                  debouncer: debounceValue,
                  action: Actions.Demote,
                  onTap: () async {
                    Navigator.pop(_context);
                    setState(() {
                      isProgressBarActive = true;
                    });
                    List<String> admins =
                        timebankModel.admins.map((s) => s).toList();

                    Firestore.instance
                        .collection('communities')
                        .document(timebankModel.communityId)
                        .updateData({
                      'admins': FieldValue.arrayRemove([user.sevaUserID]),
                    });
                    admins.remove(user.sevaUserID);
                    _updateTimebank(timebankModel, admins: admins);
                  },
                ),
              ),
            );
          }
          list.add(
            PopupMenuItem(
              value: 3,
              child: CustomRaisedButton(
                debouncer: debounceValue,
                action: Actions.Remove,
                onTap: () async {
                  Navigator.pop(_context);

                  //Here we need to put dialog
                  Map<String, bool> onActivityResult = await showAdvisory(
                      dialogTitle:
                          "${S.of(context).member_removal_confirmation} ${user.fullname}?");
                  if (onActivityResult['PROCEED']) {
                    setState(() {
                      isProgressBarActive = true;
                    });
                    if (widget.isCommunity != null && widget.isCommunity) {
                      await removeMemberTimebankFn(
                          context: parentContext,
                          userModel: user,
                          isFromExit: false,
                          timebankModel: model);
                      setState(() {
                        isProgressBarActive = false;
                      });
                    } else {
                      await removeMemberGroupFn(
                          context: parentContext,
                          userModel: user,
                          isFromExit: false,
                          timebankModel: model);
                      setState(() {
                        isProgressBarActive = false;
                      });
                    }
                  } else {
                    return;
                  }
                },
              ),
            ),
          );
          return list;
        },
        elevation: 4,
        padding: EdgeInsets.symmetric(horizontal: 10),
      );
  void _showFontSizePickerDialog(UserModel user, model) async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (timebankModel.balance <= 0) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).insufficient_credits_to_donate),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    // <-- note the async keyword here
    double donateAmount = 0;
//     this will contain the result from Navigator.pop(context, result)
    final donateAmount_Received = await showDialog<double>(
      context: context,
      builder: (context) => InputDonateDialog(
          donateAmount: donateAmount,
          maxAmount: timebankModel.balance.toDouble()),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      setState(() {
        donateAmount = donateAmount_Received;
        timebankModel.balance = timebankModel.balance - donateAmount_Received;
      });
      //from, to, timestamp, credits, isApproved, type, typeid, timebankid
      await TransactionBloc().createNewTransaction(
          model.id,
          user.sevaUserID,
          DateTime.now().millisecondsSinceEpoch,
          donateAmount,
          true,
          "ADMIN_DONATE_TOUSER",
          null,
          model.id);
      await showDialog<double>(
        context: context,
        builder: (context) => InputDonateSuccessDialog(
            onComplete: () => {Navigator.pop(context)}),
      );
    }
  }

  // Future _addUserToCommunityAndUpdateUserCommunityList({
  //   TimebankModel model,
  //   List<UserModel> members,
  //   String currentCommunity,
  // }) async {
  //   if (model == null || members == null || members.length == 0) {
  //     return;
  //   }
  //   if (model.members == null) {
  //     model.members = List<String>();
  //   }
  //   var communityModel =
  //       await getCommunityDetailsByCommunityId(communityId: currentCommunity);
  //   members.forEach((user) async {
  //     //Update community members inside community collection
  //     var communityMembers = List<String>();
  //     if (!communityModel.members.contains(user)) {
  //       communityMembers.addAll(communityModel.members);
  //     }
  //     communityMembers.add(user.sevaUserID);
  //     communityModel.members = communityMembers;

  //     //Update community inside user collections
  //     var communities = List<String>();
  //     if (user.communities.length > 0) {
  //       communities.addAll(user.communities);
  //     }
  //     if (user.communities != null &&
  //         !user.communities.contains(currentCommunity)) {
  //       communities.add(currentCommunity);
  //     }
  //     user.communities = communities;
  //     if (user.currentCommunity == '') {
  //       user.currentCommunity =
  //           SevaCore.of(context).loggedInUser.currentCommunity;
  //     }
  //     var insertMembers = model.members.contains(user.sevaUserID);
  //
  //     var memberList = List<String>();
  //     memberList.addAll(model.members);
  //     if (!model.members.contains(user.sevaUserID)) {
  //       memberList.add(user.sevaUserID);
  //     }
  //     model.members = memberList;
  //
  //         "Itemqwerty:${user.sevaUserID} is listSize:${model.members.length}");
  //     await updateUser(user: user);
  //   });
  //   await updateCommunity(communityModel: communityModel);
  //   await FirestoreManager.updateTimebank(timebankModel: model);
  //   resetAndLoad();
  // }

  // Future _removeUserFromCommunityAndUpdateUserCommunityList({
  //   TimebankModel model,
  //   List<String> members,
  //   String userId,
  // }) async {
  //   if (model == null || members == null || members.length == 0) {
  //     return;
  //   }
  //   UserModel user = await getUserForId(sevaUserId: userId);
  //   var currentCommunity = SevaCore.of(context).loggedInUser.currentCommunity;
  //
  //   var communities = List<String>();
  //   if (user.communities != null && user.communities.length > 0) {
  //     communities.addAll(user.communities);
  //     communities.remove(currentCommunity);
  //   }
  //   user.communities = communities.length > 0 ? communities : null;

  //   if (user.communities == null) {
  //     user.currentCommunity = '';
  //   } else if (user.communities.contains(currentCommunity)) {
  //     user.currentCommunity =
  //         user.communities.length > 0 ? user.communities[0] : '';
  //   }
  //   var communityModel =
  //       await getCommunityDetailsByCommunityId(communityId: currentCommunity);
  //   if (communityModel.members.contains(user.sevaUserID)) {
  //     var newMembers = List<String>();
  //     for (var i = 0; i < communityModel.members.length; i++) {
  //       if (communityModel.members[i] != user.sevaUserID) {
  //         newMembers.remove(communityModel.members[i]);
  //       }
  //     }
  //     communityModel.members = newMembers;
  //   }
  //   model.members = members;
  //   await updateUser(user: user);
  //   await updateCommunity(communityModel: communityModel);
  //   await FirestoreManager.updateTimebank(timebankModel: model);
  //   resetAndLoad();
  // }

  Future sendNotificationToAdmin({
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
        timebankId: timebank.id,
        data: userExitModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberExitTimebank,
        communityId: communityId,
        senderUserId: user.sevaUserID,
        targetUserId: timebank.creatorId);
    await Firestore.instance
        .collection('timebanknew')
        .document(timebank.id)
        .collection("notifications")
        .document(notification.id)
        .setData((notification..isTimebankNotification = true).toMap());
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
      _adminsWidgets.add(getSectionTitle(context, S.of(context).co_ordinators));
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
                  S.of(context).cancel,
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
                  confirmationTitle ?? S.of(context).yes,
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
          isSoftDeleteRequested: timebankModel.requestedSoftDelete,
          child: GestureDetector(
            child: Row(
              children: <Widget>[
                getSectionTitle(context, S.of(context).members),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteAddMembers(
                            timebankModel.id,
                            timebankModel.communityId,
                            timebankModel,
                            Theme.of(context).platform),
                      ),
                    );
                  },
          ),
        );
        _membersWidgets.add(gesture);
      } else {
        _membersWidgets.add(
          getSectionTitle(context, S.of(context).members),
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
        getSectionTitle(context, S.of(context).co_ordinators),
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

  // void addToAdmin(TimebankModel model, UserModel user) {
  //   List<String> admins = model.admins.map((s) => s).toList();
  //   List<String> coordinators = model.coordinators.map((s) => s).toList();
  //   admins.add(user.sevaUserID);
  //   coordinators.remove(user.sevaUserID);
  //   _updateTimebank(
  //     model,
  //     admins: admins,
  //     coordinators: coordinators,
  //   );
  // }

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

  void removeMemberGroupFn(
      {BuildContext context,
      UserModel userModel,
      TimebankModel timebankModel,
      bool isFromExit}) async {
    Map<String, dynamic> responseData = await removeMemberFromGroup(
        sevauserid: userModel.sevaUserID, groupId: timebankModel.id);
    if (responseData['deletable'] == true) {
      if (isFromExit) {
        await sendNotificationToAdmin(
            user: userModel,
            timebank: timebankModel,
            communityId: userModel.currentCommunity);
        Navigator.of(parentContext).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePageRouter(),
            ),
            (Route<dynamic> route) => false);
      } else {
        resetAndLoad();
      }
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        setState(() {
          isProgressBarActive = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(S.of(context).cant_exit_group),
              content: Text("${S.of(context).you_have} \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['pendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n "
                  "${S.of(context).clear_transaction} "),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: Text(S.of(context).cancel),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (responseData['softDeleteCheck'] == true &&
          responseData['groupOwnershipCheck'] == false) {
        setState(() {
          isProgressBarActive = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              content: Text(
                  "Cannot remove yourself from the group. Instead, please try deleting the group."),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: Text(S.of(context).close),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void removeMemberTimebankFn(
      {BuildContext context,
      UserModel userModel,
      TimebankModel timebankModel,
      bool isFromExit}) async {
    Map<String, dynamic> responseData = await removeMemberFromTimebank(
        sevauserid: userModel.sevaUserID, timebankId: timebankModel.id);

    if (responseData['deletable'] == true) {
      if (isFromExit) {
        await sendNotificationToAdmin(
            user: userModel,
            timebank: timebankModel,
            communityId: userModel.currentCommunity);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SwitchTimebank(),
          ),
        );
      } else {
        resetAndLoad();
      }
    } else {
      if (responseData['softDeleteCheck'] == false &&
          responseData['groupOwnershipCheck'] == false) {
        setState(() {
          isProgressBarActive = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text(
                  " ${isFromExit ? "You" : "User"} ${S.of(context).cant_exit_timebank}"),
              content: Text("${isFromExit ? "You" : "User"} have \n"
                  "${responseData['pendingProjects']['unfinishedProjects']} ${S.of(context).pending_projects},\n"
                  "${responseData['PendingRequests']['unfinishedRequests']} ${S.of(context).pending_requests},\n"
                  "${responseData['pendingOffers']['unfinishedOffers']} ${S.of(context).pending_offers}.\n "
                  "${S.of(context).clear_transaction} "),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: Text(S.of(context).close),
                  textColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (responseData['softDeleteCheck'] == true &&
          responseData['groupOwnershipCheck'] == false) {
        setState(() {
          isProgressBarActive = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferOwnerShipView(
              timebankId: timebankModel.id,
              responseData: responseData,
              isComingFromExit: isFromExit ? true : false,
              memberSevaUserId: userModel.sevaUserID,
              memberName: userModel.fullname,
              memberPhotUrl: userModel.photoURL,
            ),
          ),
        );
      }
    }
  }
}

enum Actions { Approve, Reject, Remove, Promote, Demote, Exit, Loan }

String actionToStringMapper(BuildContext context, Actions action) {
  S s = S.of(context);
  switch (action) {
    case Actions.Approve:
      return s.approve;
      break;
    case Actions.Reject:
      return s.reject;
      break;
    case Actions.Remove:
      return s.remove;
      break;
    case Actions.Promote:
      return s.promote;
      break;
    case Actions.Demote:
      return s.demote;
      break;
    case Actions.Exit:
      return s.exit;
      break;
    case Actions.Loan:
      return s.donate;
      break;
    default:
      return '';
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
      color: (action == Actions.Approve ||
              action == Actions.Promote ||
              action == Actions.Loan)
          ? null
          : Colors.red,
      child: Text(
        actionToStringMapper(context, action),
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

// move the dialog into it's own stateful widget.
// It's completely independent from your page
// this is good practice
class InputDonateDialog extends StatefulWidget {
  /// initial selection for the slider
  final double donateAmount;
  final double maxAmount;

  const InputDonateDialog({Key key, this.donateAmount, this.maxAmount})
      : super(key: key);

  @override
  _InputDonateDialogState createState() => _InputDonateDialogState();
}

class _InputDonateDialogState extends State<InputDonateDialog> {
  /// current selection of the slider
  double _donateAmount;
  bool donatezeroerror = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _donateAmount = widget.donateAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).loan_seva_credit_to_user),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${S.of(context).timebank_seva_credit} ' +
                widget.maxAmount.toStringAsFixed(2).toString()),
            TextFormField(
              decoration: InputDecoration(
                hintText: S.of(context).number_of_seva_credit,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value.isEmpty) {
                  return S.of(context).empty_credit_loan_error;
                } else if (int.parse(value) > widget.maxAmount) {
                  return S.of(context).insufficient_credits_to_donate;
                } else if (int.parse(value) == 0) {
                  return S.of(context).loan_zero_credit_error;
                } else if (int.parse(value) <= 0) {
                  return S.of(context).negative_credit_loan_error;
                } else {
                  _donateAmount = double.parse(value);
                  return null;
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(S.of(context).timebank_loan_message),
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          child: Text(
            S.of(context).donate,
            style: TextStyle(
              fontSize: dialogButtonSize,
            ),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
//              if (_donateAmount == 0) {
//                setState(() {
//                  donatezeroerror = true;
//                });
//                return;
//              }
              setState(() {
                donatezeroerror = false;
              });
              Navigator.pop(context, _donateAmount);
            }
          },
        ),
        FlatButton(
          child: Text(
            S.of(context).cancel,
            style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class InputDonateSuccessDialog extends StatefulWidget {
  /// initial selection for the slider
  final VoidCallback onComplete;

  const InputDonateSuccessDialog({Key key, this.onComplete}) : super(key: key);

  @override
  _InputDonateSuccessDialogState createState() =>
      _InputDonateSuccessDialogState();
}

class _InputDonateSuccessDialogState extends State<InputDonateSuccessDialog> {
  VoidCallback onComplete;

  /// current selection of the slider
  @override
  void initState() {
    super.initState();
    onComplete = widget.onComplete;
    var _duration = Duration(milliseconds: 2000);
    Timer(_duration, () => {Navigator.pop(context)});
  }

//  Text('Coins successfully donated to timebank')
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).loan_seva_credit_to_user),
      content: Container(
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / 12,
        child: Text(S.of(context).loan_success),
      ),
    );
  }
}
