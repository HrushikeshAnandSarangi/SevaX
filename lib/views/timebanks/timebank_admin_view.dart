import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:shimmer/shimmer.dart';

import 'edit_super_admins_view.dart';

class TimebankAdminPage extends StatefulWidget {
  final String timebankId;
  final String userEmail;
  HashMap<String, UserModel> listOfMembers = HashMap();

  TimebankAdminPage({@required this.timebankId, @required this.userEmail});

  @override
  _TimebankAdminPageState createState() => _TimebankAdminPageState();
}

class _TimebankAdminPageState extends State<TimebankAdminPage> {
  ScrollController _listController;
  ScrollController _pageScrollController;
  var _indexSoFar = 0;
  var _pageIndex = 1;
  var currSelectedState = false;
  var selectedUserModelIndex = -1;
  var _isLoading = false;
  var _lastReached = false;
  var _membersTitleDone = false;
  var adminsNotLoaded = true;
  var timebankModel = TimebankModel({});
  var _admins = List<Widget>();
  var _coordinators = List<Widget>();
  var _members = List<Widget>();
  var _adminEmails = List<String>();
  HashMap<String, int> emailIndexMap = HashMap();
  HashMap<int, UserModel> indexToModelMap = HashMap();
  HashMap<String, bool> adminToModelMap = HashMap();
  var nullCount = 0;

  @override
  void initState() {
    _listController = ScrollController();
    _pageScrollController = ScrollController();
    _pageScrollController.addListener(_scrollListener);
    super.initState();
  }

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
    return Scaffold(
      body: getTimebackList(context, widget.timebankId),
    );
  }

  Widget get circularBar {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getTimebackList(BuildContext context, String timebankId) {
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
          return Center(
            child: CircularProgressIndicator(),
          );
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
    return CustomScrollView(
      controller: _pageScrollController,
      slivers: <Widget>[
        getAppBar(context, timebankModel),
        SliverList(
          delegate: SliverChildListDelegate(
            getContent(context, timebankModel),
          ),
        ),
      ],
    );
  }

  Widget getAppBar(BuildContext context, TimebankModel timebankModel) {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      expandedHeight: 250,
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
      loadNextAdmins().then((onValue) {
        adminsNotLoaded = false;
        if (_coordinators.length == 0 &&
            (FlavorConfig.appFlavor == Flavor.APP ||
                FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
          loadNextCoordinators().then((onValue) {
            if (_members.length == 0) {
              loadNextMembers();
            }
          });
        } else {
          if (_members.length == 0) {
            loadNextMembers();
          }
        }
      });
    }
  }

  void resetVariables() {
    _pageIndex = 1;
    _indexSoFar = 0;
    currSelectedState = false;
    selectedUserModelIndex = -1;
    _isLoading = false;
    _lastReached = false;
    _membersTitleDone = false;
    adminsNotLoaded = true;
    _admins = [];
    _members = [];
    _adminEmails = [];
    _coordinators = [];
    emailIndexMap = HashMap();
    indexToModelMap = HashMap();
    adminToModelMap = HashMap();
    nullCount = 0;
  }

  void resetAndLoad() {
    resetVariables();
    loadItems().then((onValue) {
      setState(() {});
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
    _avtars.addAll(_admins);
    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      _avtars.addAll(_coordinators);
    }
    _avtars.addAll(_members);
    return _avtars;
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

  Future loadNextAdmins() async {
    if (timebankModel.admins == null) {
      timebankModel.admins = List<String>();
    }
    if (timebankModel.admins.length != 0) {
      bool isAdmin = timebankModel.admins.contains(
        SevaCore.of(context).loggedInUser.sevaUserID,
      );

      print(timebankModel.admins);
      FirestoreManager.getUserForUserModels(admins: timebankModel.admins)
          .then((onValue) {
        _admins = [];
        _adminEmails = [];
        _admins.add(getSectionTitle(context,
            AppLocalizations.of(context).translate('members', 'admins')));
        SplayTreeMap<String, dynamic>.from(onValue, (a, b) => a.compareTo(b))
            .forEach((key, user) {
          _adminEmails.add(user.email);
          if (isAdmin) {
            var widget = Slidable(
              delegate: SlidableDrawerDelegate(),
              actions: <Widget>[
                IconSlideAction(
                  icon: Icons.close,
                  color: Colors.red,
                  caption: AppLocalizations.of(context)
                      .translate('members', 'remove'),
                  onTap: () async {
                    List<String> admins =
                        timebankModel.admins.map((s) => s).toList();
                    admins.remove(user.sevaUserID);
                    updateTimebank(timebankModel, admins: admins);
                  },
                ),
              ],
              secondaryActions: <Widget>[
                IconSlideAction(
                  icon: Icons.arrow_downward,
                  color: Colors.orange,
                  caption: AppLocalizations.of(context)
                      .translate('members', 'coordinator'),
                  onTap: () {
                    List<String> admins =
                        timebankModel.admins.map((s) => s).toList();
                    List<String> coordinators =
                        timebankModel.coordinators.map((s) => s).toList();
                    coordinators.add(user.sevaUserID);
                    admins.remove(user.sevaUserID);
                    updateTimebank(
                      timebankModel,
                      coordinators: coordinators,
                      admins: admins,
                    );
                  },
                ),
              ],
              child: getUserWidget(user, context, timebankModel),
            );
            _admins.add(widget);
          }
        });
        setState(() {});
      });
    }
  }

  Future loadNextCoordinators() async {
    if (timebankModel.admins == null) {
      timebankModel.coordinators = List<String>();
    }
    if (timebankModel.coordinators.length != 0) {
      bool isCoordinator = timebankModel.coordinators.contains(
        SevaCore.of(context).loggedInUser.sevaUserID,
      );

      FirestoreManager.getUserForUserModels(admins: timebankModel.admins)
          .then((onValue) {
        _admins = [];
        _adminEmails = [];
        _admins.add(getSectionTitle(context,
            AppLocalizations.of(context).translate('members', 'coordinators')));
        SplayTreeMap<String, dynamic>.from(onValue, (a, b) => a.compareTo(b))
            .forEach((key, user) {
          _adminEmails.add(user.email);
          if (isCoordinator) {
            var widget = Slidable(
              delegate: SlidableDrawerDelegate(),
              actions: <Widget>[
                IconSlideAction(
                  icon: Icons.close,
                  color: Colors.red,
                  caption: AppLocalizations.of(context)
                      .translate('members', 'remove'),
                  onTap: () {
                    List<String> coordinators =
                        user.coordinators.map((s) => s).toList();
                    coordinators.remove(user.sevaUserID);
                    updateTimebank(user, coordinators: coordinators);
                  },
                ),
              ],
//                secondaryActions: <Widget>[
//                IconSlideAction(
//                  icon: Icons.arrow_downward,
//                  color: Colors.orange,
//                  caption: 'Coordinator',
//                  onTap: () {
//                    List<String> admins =
//                    timebankModel.admins.map((s) => s).toList();
//                    List<String> coordinators =
//                    timebankModel.coordinators.map((s) => s).toList();
//                    coordinators.add(user.sevaUserID);
//                    admins.remove(user.sevaUserID);
//                    updateTimebank(
//                      timebankModel,
//                      coordinators: coordinators,
//                      admins: admins,
//                    );
//                  },
//                ),
//              ],
              child: getUserWidget(user, context, timebankModel),
            );
            _coordinators.add(widget);
          }
        });
        setState(() {});
      });
    }
  }

  Future loadNextMembers() async {
    if (!_isLoading && !_lastReached) {
      _isLoading = true;
      FirestoreManager.getUsersForAdminsCoordinatorsMembersTimebankId(
              widget.timebankId, _pageIndex, widget.userEmail)
          .then((onValue) {
        var userModelList = onValue.userModelList;
        if (userModelList == null || userModelList.length == 0) {
//          if (userModelList == null) {
          nullCount++;
//          }
          _isLoading = false;
          _pageIndex = _pageIndex + 1;
          if (nullCount < 3) {
            loadNextMembers();
          } else {
            setState(() {
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
              return getUserWidget(
                  widget.listOfMembers[member], context, timebankModel);
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
                return getUserWidget(user, context, timebankModel);
              },
            );
          }).toList();
          if (!_membersTitleDone) {
            var memberTitle = getSectionTitle(context,
                AppLocalizations.of(context).translate('members', 'members'));
            _members.add(memberTitle);
            _membersTitleDone = true;
          }
          if (addItems.length > 0) {
            var lastIndex = _members.length;
            setState(() {
              var iterationCount = 0;
              for (int i = 0; i < addItems.length; i++) {
                if (emailIndexMap[userModelList[i].email] == null &&
                    !_adminEmails.contains(userModelList[i].email.trim())) {
                  // Filtering duplicates
                  _members.add(addItems[i]);
                  indexToModelMap[lastIndex] = userModelList[i];
                  emailIndexMap[userModelList[i].email] = lastIndex++;
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
            _lastReached = onValue.lastPage;
          });
        }
      });
    }
  }

  Widget getCoordinationList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );
    if (model.coordinators == null || model.coordinators.isEmpty)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context,
            AppLocalizations.of(context).translate('members', 'coordinators')),
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
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: AppLocalizations.of(context)
                          .translate('members', 'remove'),
                      onTap: () {
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        coordinators.remove(user.sevaUserID);
                        updateTimebank(model, coordinators: coordinators);
                      },
                    ),
                  ],
                  child: getUserWidget(user, context, model),
                );
              }
              return getUserWidget(user, context, model);
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
    updateTimebank(
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
    updateTimebank(
      model,
      members: members,
      admins: admins,
      coordinators: coordinators,
    );
  }

  Widget getUserWidget(
      UserModel user, BuildContext context, TimebankModel model) {
    user.photoURL = user.photoURL == null ? defaultUserImageURL : user.photoURL;
    user.fullname = user.fullname == null ? defaultUsername : user.fullname;
    return Card(
      elevation: 0.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoURL ?? defaultUserImageURL),
        ),
        title: Text(user.fullname),
        subtitle: Text(user.email),
        onTap: () {
          // Push to profile in
          handleAction(
            context: context,
            model: model,
            user: user,
          );
        },
        onLongPress: () {
          handleAction(
            context: context,
            model: model,
            user: user,
          );
        },
      ),
    );
  }

  void handleAction({
    TimebankModel model,
    BuildContext context,
    UserModel user,
  }) {
    if (!model.admins.contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileViewer(
            userEmail: user.email,
          ),
        ),
      );
    } else {
      showDialogForAdminAccess(
        model: model,
        context: context,
        isAdmin: model.admins.contains(user.sevaUserID),
        userModel: user,
      );
    }
  }

// crate dialog for approval or rejection
  void showDialogForAdminAccess(
      {TimebankModel model,
      BuildContext context,
      UserModel userModel,
      bool isAdmin}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            content: Form(
              //key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // _getCloseButton(viewContext),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: isAdmin && model.admins.length > 1
                            ? FlatButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('members', 'remove_as_admin'),
                                ),
                                onPressed: () async {
                                  // request declined
                                  if (isAdmin) {
                                    removeAsAdmin(
                                      model,
                                      userModel,
                                    );
                                  } else {
                                    print("Add as admin");
                                    addToAdmin(
                                      model,
                                      userModel,
                                    );
                                  }
                                  Navigator.pop(viewContext);
                                },
                              )
                            : isAdmin
                                ? Offstage()
                                : FlatButton(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate('members', 'add_as_admin'),
                                    ),
                                    onPressed: () async {
                                      // request declined
                                      if (isAdmin) {
                                        removeAsAdmin(
                                          model,
                                          userModel,
                                        );
                                      } else {
                                        print("Add as admin");
                                        addToAdmin(
                                          model,
                                          userModel,
                                        );
                                      }
                                      Navigator.pop(viewContext);
                                    },
                                  ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('members', 'view_profile'),
                          ),
                          onPressed: () async {
                            // Once approved
                            print("View profile");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileViewer(
                                  userEmail: userModel.email,
                                ),
                              ),
                            );
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: isAdmin
                            ? Offstage()
                            : FlatButton(
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('members', 'remove_member'),
                                ),
                                onPressed: () async {
                                  //Remove a member
                                  Map<String, bool> onActivityResult =
                                      await showAdvisory(
                                          dialogTitle:
                                              "${AppLocalizations.of(context).translate('members', 'sure_a')} ${userModel.fullname ?? "member"} ${AppLocalizations.of(context).translate('members', 'timebank_members')}");
                                  if (onActivityResult['PROCEED']) {
                                    removeFromTimebank(model, userModel);
                                  } else {
                                    return;
                                  }
                                  Navigator.pop(viewContext);
                                },
                              ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('shared', 'proceed'),
                          ),
                          onPressed: () async {
                            // Once approved
                            Navigator.pop(viewContext);
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void addToAdmin(TimebankModel model, UserModel user) {
    List<String> admins = model.admins.map((s) => s).toList();
    List<String> coordinators = model.coordinators.map((s) => s).toList();
    admins.add(user.sevaUserID);
    coordinators.remove(user.sevaUserID);
    updateTimebank(
      model,
      admins: admins,
      coordinators: coordinators,
    );
  }

  Widget getSectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle,
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

  Future updateTimebank(
    TimebankModel model, {
    List<String> admins,
    List<String> coordinators,
    List<String> members,
  }) async {
    if (admins != null) {
      model.admins = admins;
    }
    if (coordinators != null) {
      model.coordinators = coordinators;
    }
    if (members != null) {
      model.members = members;
    }
    await FirestoreManager.updateTimebank(timebankModel: model).then((onValue) {
      resetAndLoad();
    });
  }

  Future<Map> showAdvisory({String dialogTitle}) {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
              dialogTitle,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate('shared', 'cancel'),
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
                  AppLocalizations.of(context).translate('shared', 'proceed'),
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
}
