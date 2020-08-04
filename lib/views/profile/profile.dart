import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/blocked_members/pages/blocked_members_page.dart';
import 'package:sevaexchange/utils/animations/fade_route.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/community/about_app.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_alert_view.dart';
import 'package:sevaexchange/views/profile/language.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:sevaexchange/views/profile/widgets/seva_coin_widget.dart';

import 'edit_profile.dart';
import 'timezone.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProfilePage(userModel: SevaCore.of(context).loggedInUser);
  }
}

class ProfilePage extends StatefulWidget {
  final UserModel userModel;
  const ProfilePage({Key key, this.userModel}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel user;
  TimebankModel timebankModel;
  bool isAdminOrCoordinator = false;
  bool isUserLoaded = false;
  bool isCommunityLoaded = false;
  int selected = 0;
  double sevaCoinsValue = 0.0;

  UserProfileBloc _profileBloc;

  List<CommunityModel> communities = [];

  @override
  void initState() {
    log("profile page init");
    _profileBloc = UserProfileBloc(context);
    super.initState();
    _profileBloc.getAllCommunities(context, widget.userModel);

    FirestoreManager.getTimeBankForId(
            timebankId: FlavorConfig.values.timebankId)
        .then((model) {
      setState(() {
        timebankModel = model;
      });
    });

    _profileBloc.communityLoaded.listen((value) {
      isCommunityLoaded = value;
      setState(() {});
    });

    Future.delayed(Duration.zero, () {
      FirestoreManager.getTimeBankForId(
              timebankId: SevaCore.of(context).loggedInUser.currentTimebank)
          .then((timebank) {
        if (timebank.admins
                .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
            timebank.coordinators
                .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
          setState(() {
            print("Admin access granted");
            isAdminOrCoordinator = true;
          });
        } else {
          // print("Admin access Revoked");
          // isAdminOrCoordinator = false;
        }
      });

      FirestoreManager.getUserForIdStream(
        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      ).listen((UserModel userModel) {
        if (mounted) isUserLoaded = true;
        print("userMOde ->>>>>    >>>> ${userModel.currentCommunity}");
        _profileBloc.getAllCommunities(context, userModel);
        this.user = userModel;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _profileBloc.dispose();
    super.dispose();
  }

  void navigateToSettings() {
    Navigator.push(
      context,
      FadeRoute(
        page: EditProfilePage(
          userModel: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log("profile page build");
    return Scaffold(
      backgroundColor: Colors.white,
      body: isUserLoaded
          ? SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  getAppBar(),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: navigateToSettings,
                          child: Hero(
                            tag: AppLocalizations.of(context)
                                .translate('profile', 'image_hint'),
                            child: Container(
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.photoURL ?? defaultUserImageURL,
                                ),
                                backgroundColor: Colors.white,
                                radius: MediaQuery.of(context).size.width / 4.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          user.fullname ?? "",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Europa',
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        SizedBox(height: 20),
                        SevaCoinWidget(
                          amount: this.user.currentBalance != null
                              ? double.parse(
                                  this.user.currentBalance.toStringAsFixed(2))
                              : 0.0,
                          onTap: () async {
                            var connResult =
                                await Connectivity().checkConnectivity();
                            if (connResult == ConnectivityResult.none) {
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)
                                      .translate('shared', 'check_internet')),
                                  action: SnackBarAction(
                                    label: AppLocalizations.of(context)
                                        .translate('shared', 'dismiss'),
                                    onPressed: () => Scaffold.of(context)
                                        .hideCurrentSnackBar(),
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ReviewEarningsPage(
                                      type: "user", timebankid: "");
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: <Widget>[
                        Divider(
                          thickness: 0.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('profile', 'select_timebank'),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                var timebankAdvisory =
                                    AppLocalizations.of(context)
                                        .translate('profile', 'dialog_text');
                                Map<String, bool> onActivityResult =
                                    await showTimebankAdvisory(
                                        dialogTitle: timebankAdvisory);
                                if (onActivityResult['PROCEED']) {
                                  print("YES PROCEED WITH TIMEBANK CREATION");
                                  createEditCommunityBloc.updateUserDetails(
                                      SevaCore.of(context).loggedInUser);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context1) => SevaCore(
                                        loggedInUser:
                                            SevaCore.of(context).loggedInUser,
                                        child: CreateEditCommunityView(
                                          isCreateTimebank: true,
                                          timebankId:
                                              FlavorConfig.values.timebankId,
                                          isFromFind: false,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  print(
                                      "NO CANCEL MY PLAN OF CREATING A TIMEBANK");
                                }
                              },
                            ),
                          ],
                        ),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: StreamBuilder<List<Widget>>(
                            stream: _profileBloc.communities,
                            builder: (context, snapshot) {
                              if (snapshot.data != null)
                                return Column(children: snapshot.data);

                              if (snapshot.hasError)
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12.0, 12.0, 12.0, 0),
                                    child: Text(snapshot.error),
                                  ),
                                );
                              return Container(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        ProfileSettingsCard(
                          title: AppLocalizations.of(context)
                              .translate('profile', 'help'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return AboutApp();
                                },
                              ),
                            );
                          },
                        ),
                        ProfileSettingsCard(
                          title: AppLocalizations.of(context)
                              .translate('profile', 'notifications'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => NotificationAlert(
                                  SevaCore.of(context).loggedInUser.sevaUserID,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileSettingsCard(
                          title: AppLocalizations.of(context)
                              .translate('blocked_members', 'blocked_members'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlockedMembersPage(),
                              ),
                            );
                          },
                        ),
                        ProfileSettingsCard(
                          title: AppLocalizations.of(context)
                              .translate('profile', 'timezone'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return TimezoneView();
                                },
                              ),
                            );
                          },
                        ),
                        ProfileSettingsCard(
                          title: AppLocalizations.of(context)
                              .translate('settings', 'language'),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return LanguageView();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 5),
                  Text(AppLocalizations.of(context)
                      .translate('profile', 'loading')),
                ],
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
                  AppLocalizations.of(context).translate('profile', 'proceed'),
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

  AppBar getAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actions: <Widget>[
        IconButton(
          color: Colors.black,
          icon: Icon(Icons.settings),
          onPressed: navigateToSettings,
        ),
      ],
    );
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.pop(context);
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthRouter(),
      ),
    );
  }
}

class ProfileSettingsCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const ProfileSettingsCard({
    Key key,
    this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          height: 60,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              Spacer(),
              Icon(Icons.navigate_next),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  const CommunityCard({
    Key key,
    this.selected,
    this.onTap,
    @required this.community,
  }) : super(key: key);

  final CommunityModel community;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 15),
          selected
              ? Icon(Icons.check)
              : SizedBox(
                  width: 24,
                ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image:
                      NetworkImage(community.logo_url ?? defaultUserImageURL),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              community.name[0].toUpperCase() +
                  community.name.substring(1).toLowerCase(),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
