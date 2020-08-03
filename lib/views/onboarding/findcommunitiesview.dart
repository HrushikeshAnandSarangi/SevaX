import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/notification_manager.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';

class FindCommunitiesView extends StatefulWidget {
  final bool keepOnBackPress;
  final UserModel loggedInUser;
  final bool showBackBtn;
  final bool isFromHome;

  FindCommunitiesView(
      {@required this.keepOnBackPress,
      @required this.loggedInUser,
      @required this.showBackBtn,
      @required this.isFromHome});

  @override
  State<StatefulWidget> createState() {
    return FindCommunitiesViewState();
  }
}

enum CompareUserStatus { JOINED, REQUESTED, REJECTED, JOIN }

class FindCommunitiesViewState extends State<FindCommunitiesView> {
  final TextEditingController searchTextController = TextEditingController();
  static String JOIN;
  static String JOINED;
  bool showAppbar = false;
  String nearTimebankText;
  var radius;

  @override
  void initState() {
    gpsCheck();

    super.initState();
    String _searchText = "";

    final _textUpdates = StreamController<String>();
    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));
    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 500))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        communityBloc.fetchCommunities(s);
        setState(() {
          _searchText = s;
        });
      }
    });
  }

  @override
  void dispose() {
    communityBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    JOIN = AppLocalizations.of(context).translate('findtimebank', "join");
    JOINED = AppLocalizations.of(context).translate('findtimebank', "joined");
    nearTimebankText = AppLocalizations.of(context)
        .translate('findtimebank', 'timebanks_near_you');
    bool showBachBtn = widget.showBackBtn;
    showAppbar = widget.isFromHome;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: !showAppbar
          ? AppBar(
              // automaticallyImplyLeading: widget.keepOnBackPress,
              automaticallyImplyLeading: false,
              elevation: 0.5,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                  ),
                  onPressed: () {
                    logOut();
//                      Navigator.of(context).push(MaterialPageRoute(
//                          builder: (context) => ()));
                  },
                ),
              ],
              leading: showBachBtn
                  ? BackButton(
                      onPressed: () => Navigator.pop(context),
                    )
                  : Offstage(),
              title: Text(
                AppLocalizations.of(context)
                    .translate('findtimebank', 'find_your_timebank'),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: searchTeams(),
    ); // );
  }

  void logOut() {
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).translate('shared', 'logout')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)
                  .translate('shared', 'sure_logout')),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Spacer(),
                  FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'logout'),
                      style: TextStyle(fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                      //   statusBarBrightness: Brightness.light,
                      //   statusBarColor: Colors.white,
                      // ));

                      try {
                        await FCMNotificationManager
                            .removeDeviceRegisterationForMember(
                                email: loggedInEmail);
                      } catch (e) {
                        print("Couldn't clear the token");
                      }
                      Navigator.of(context).pop();
                      _signOut(context);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('shared', 'cancel'),
                      style: TextStyle(color: Colors.red, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    // Navigator.pop(context);

    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthRouter(),
      ),
    );
  }

  Widget searchTeams() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        Text(
          AppLocalizations.of(context)
              .translate('findtimebank', 'looking_existing'),
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
        ),
        TextField(
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
              contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
              filled: true,
              fillColor: Colors.grey[300],
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(25.7),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7)),
              hintText: AppLocalizations.of(context)
                  .translate('findtimebank', 'help_text'),
              hintStyle: TextStyle(color: Colors.black45, fontSize: 14)),
        ),
        SizedBox(height: 20),
        Expanded(
          child: buildList(),
        ),
        // This container holds the align
        widget.isFromHome ? Container() : createCommunity(),
      ]),
    );
  }

  Widget buildList() {
//    if (searchTextController.text.length == 0) {
//      print('near by called');
//
//      return nearByTimebanks();

    if (searchTextController.text.trim().length < 1) {
      return Column(
        children: <Widget>[
          getEmptyWidget('Users', nearTimebankText),
          Expanded(child: nearByTimebanks()),
        ],
      );
    }
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder<List<CommunityModel>>(
        stream: SearchManager.searchCommunity(
          queryString: searchTextController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.data.length != 0) {
                List<CommunityModel> communityList = snapshot.data;
//                print("comm list ${communityList}");
//                communityList
//                    .removeWhere((community) => community.private == true);

                return Padding(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 5.0),
                    child: ListView.builder(
                        padding: EdgeInsets.only(
                            bottom:
                                180), //to avoid keyboard overlap //temp fix neeeds to be changed
                        itemCount: communityList.length,
                        itemBuilder: (BuildContext context, int index) {
                          CompareUserStatus status;

                          status = _compareUserStatus(communityList[index],
                              widget.loggedInUser.sevaUserID);

                          return timeBankWidget(
                              communityModel: communityList[index],
                              context: context,
                              status: status);
                        }));
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                  child: Center(
                    child: Text(
                        AppLocalizations.of(context)
                            .translate('findtimebank', 'no_timebanks_found'),
                        style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                  ),
                );
              }
            }
          } else if (snapshot.hasError) {
            return Text(
                AppLocalizations.of(context).translate('shared', 'try_later'));
          }
          /*else if(snapshot.data==null){
            return Expanded(
              child: Center(
                child: Text('No Timebank found'),
              ),
            );
          }*/
          return Text("");
        });
  }

  Widget timeBankWidget(
      {CommunityModel communityModel,
      BuildContext context,
      CompareUserStatus status}) {
    return ListTile(
      // onTap: goToNext(snapshot.data),
      title: Text(communityModel.name,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
      subtitle: FutureBuilder(
        future: getUserForId(sevaUserId: communityModel.created_by),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          if (snapshot.hasError) {
            return Text(
              AppLocalizations.of(context)
                  .translate('findtimebank', 'timebank'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("...");
          } else if (snapshot.hasData) {
            return Text(
              AppLocalizations.of(context)
                      .translate('findtimebank', 'created_by') +
                  snapshot.data.fullname,
            );
          } else {
            return Text(
              AppLocalizations.of(context)
                  .translate('findtimebank', 'community'),
            );
          }
        },
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        RaisedButton(
          onPressed: status == CompareUserStatus.JOIN
              ? () {
                  var communityModell = communityModel;
                  createEditCommunityBloc.selectCommunity(communityModell);
                  createEditCommunityBloc
                      .updateUserDetails(SevaCore.of(context).loggedInUser);
                  // snapshot.data.communities[index].

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (contexts) => OnBoardWithTimebank(
                        communityModel: communityModel,
                        sevauserId: widget.loggedInUser.sevaUserID,
                        user: SevaCore.of(context).loggedInUser,
                      ),
                    ),
                  );
                  print('clicked ${communityModel.id}');
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Text(getUserTimeBankStatusTitle(status) ?? ""),
              ),
            ],
          ),
          color: Theme.of(context).accentColor,
          textColor: FlavorConfig.values.buttonTextColor,
          shape: StadiumBorder(),
        )
      ]),
    );
  }

  void gpsCheck() async {
    try {
      Location templocation = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
    }
  }

  Widget nearByTimebanks() {
    return StreamBuilder<List<CommunityModel>>(
        stream: FirestoreManager.getNearCommunitiesListStream(
          nearbySettings: widget.loggedInUser.nearBySettings,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            print('near by comminities ${snapshot.data}');
            if (snapshot.data.length != 0) {
              List<CommunityModel> communityList = snapshot.data;

              return ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: 180,
                    top: 5.0,
                  ), //to avoid keyboard overlap //temp fix neeeds to be changed

                  shrinkWrap: true,
                  itemCount: communityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    CompareUserStatus status;
                    status = _compareUserStatus(
                      communityList[index],
                      widget.loggedInUser.sevaUserID,
                    );

                    return timeBankWidget(
                      communityModel: communityList[index],
                      context: context,
                      status: status,
                    );
                  });
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 100, horizontal: 60),
                child: Center(
                  child: Text(
                      AppLocalizations.of(context)
                          .translate('findtimebank', 'no_timebanks_found'),
                      style: TextStyle(fontFamily: "Europa", fontSize: 14)),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                child: Text(AppLocalizations.of(context)
                    .translate('findtimebank', 'timebanks_around_you')));
            // return Text("Couldn't load results");
          }
          /*else if(snapshot.data==null){
            return Expanded(
              child: Center(
                child: Text('No Timebank found'),
              ),
            );
          }*/
          return Text("");
        });
  }

  String getUserTimeBankStatusTitle(CompareUserStatus status) {
    switch (status) {
      case CompareUserStatus.JOIN:
        return JOIN;

      case CompareUserStatus.JOINED:
        return JOINED;

      default:
        return JOIN;
    }
  }

  CompareUserStatus _compareUserStatus(
    CommunityModel communityModel,
    String seveaUserId,
  ) {
    if (communityModel.members.contains(widget.loggedInUser.sevaUserID)) {
      print('u r joined user');
      return CompareUserStatus.JOINED;
    } else if (communityModel.admins.contains(widget.loggedInUser.sevaUserID)) {
      // print('u rrr joined user');

      return CompareUserStatus.JOINED;
    } else {
      //  print('u r not joined user');

      return CompareUserStatus.JOIN;
    }
  }

  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        // style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  Widget createCommunity() {
    return Container(
      // This align moves the children to the bottom
      child: Align(
        alignment: FractionalOffset.bottomCenter,
        // This container holds all the children that will be aligned
        // on the bottom and should not scroll with the above ListView
        child: Container(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('findtimebank', 'create_timebank'),
                  style: Theme.of(context).primaryTextTheme.button,
                ),
                onPressed: () async {
                  var timebankAdvisory = AppLocalizations.of(context)
                      .translate('findtimebank', 'create_timebank_warn');
                  Map<String, bool> onActivityResult =
                      await showTimebankAdvisory(dialogTitle: timebankAdvisory);
                  if (onActivityResult['PROCEED']) {
                    print("YES PROCEED WITH TIMEBANK CREATION");
                    createEditCommunityBloc
                        .updateUserDetails(SevaCore.of(context).loggedInUser);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context1) => SevaCore(
                          loggedInUser: SevaCore.of(context).loggedInUser,
                          child: CreateEditCommunityView(
                            isCreateTimebank: true,
                            timebankId: FlavorConfig.values.timebankId,
                            isFromFind: true,
                          ),
                        ),
                      ),
                    );
                  } else {
                    print("NO CANCEL MY PLAN OF CREATING A TIMEBANK");
                  }
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map> showTimebankAdvisory({String dialogTitle}) {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
//            title: Text(
//              dialogTitle,
//              style: TextStyle(
//                fontSize: 16,
//              ),
//            ),
            content: Form(
              child: Container(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    dialogTitle,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('shared', 'capital_cancel'),
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
