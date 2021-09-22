import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/blocked_members/pages/blocked_members_page.dart';
import 'package:sevaexchange/ui/screens/transaction_details/view/transaction_details_view.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/donations_details_view.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/user_donations.dart';
import 'package:sevaexchange/ui/screens/user_info/pages/user_donations_list.dart';
import 'package:sevaexchange/utils/animations/fade_route.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/about_app.dart';
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_alert_view.dart';
import 'package:sevaexchange/views/profile/language.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:sevaexchange/views/profile/widgets/seva_coin_widget.dart';
import 'package:sevaexchange/views/requests/custom_request_categories_view.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/add_new_request_category.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
  bool isUserLoaded = false;
  bool isCommunityLoaded = false;
  int selected = 0;
  double sevaCoinsValue = 0.0;

  UserProfileBloc _profileBloc;

  List<CommunityModel> communities = [];
  double balance = 0;
  @override
  void initState() {
    log("profile page init");
    _profileBloc = UserProfileBloc();
    super.initState();
    _profileBloc.getAllCommunities(context, widget.userModel);
    _profileBloc.communityLoaded.listen((value) {
      isCommunityLoaded = value;
      setState(() {});
    });

    Future.delayed(Duration.zero, () {
      FirestoreManager.getUserForIdStream(
        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      ).listen((UserModel userModel) {
        if (mounted) isUserLoaded = true;

        _profileBloc.getAllCommunities(context, userModel);
        this.user = userModel;
        logger.i("_____>> " + AppConfig.isTestCommunity.toString());
        balance = AppConfig.isTestCommunity
            ? user.sandboxCurrentBalance ?? 0
            : user.currentBalance;
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
                            tag: 'ProfileImage',
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
                          amount: balance != null
                              ? double.parse(balance.toStringAsFixed(2))
                              : 0.0,
                          onTap: () async {
                            var connResult =
                                await Connectivity().checkConnectivity();
                            if (connResult == ConnectivityResult.none) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).check_internet),
                                  action: SnackBarAction(
                                    label: S.of(context).dismiss,
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
                                  return TransactionDetailsView(
                                    id: user.sevaUserID,
                                    userId: user.sevaUserID,
                                    userEmail: user.email,
                                    totalBalance: balance != null
                                        ? balance.toStringAsFixed(2)
                                        : '0.0',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Container(
                        //     height:50,
                        //     padding: EdgeInsets.fromLTRB(5, 5, 0, 5),
                        //     child: CustomElevatedButton(
                        //         shape:StadiumBorder(),
                        //         onPressed: () async {
                        //             Navigator.of(context).push(
                        //                 MaterialPageRoute(
                        //                     builder: (context) => AddManualTimeWidget(
                        //                         userModel: SevaCore.of(context).loggedInUser,
                        //                     ),
                        //                 ),
                        //             );
                        //         },
                        //         color: Theme.of(context).primaryColor,
                        //         child: Text("Add Manual time", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),),

                        //     )
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        GoodsAndAmountDonations(
                            isGoods: false,
                            isTimeBank: false,
                            userId: user.sevaUserID,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonationsDetailsView(
                                    id: '',
                                    totalBalance:
                                        '', //change this to total of cash donated
                                    timebankModel: null,
                                    fromTimebank: false,
                                    isGoods: false,
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 15,
                        ),
                        GoodsAndAmountDonations(
                            isGoods: true,
                            isTimeBank: false,
                            userId: user.sevaUserID,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonationsDetailsView(
                                    id: '',
                                    totalBalance:
                                        '', //change this to total of goods donated
                                    timebankModel: null,
                                    fromTimebank: false,
                                    isGoods: true,
                                  ),
                                ),
                              );
                              // Na
                            }),
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
                                S.of(context).select_timebank,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                globals.isFromOnBoarding = false;

                                var timebankAdvisory =
                                    S.of(context).create_timebank_confirmation;
                                Map<String, bool> onActivityResult =
                                    await showTimebankAdvisory(
                                        dialogTitle: timebankAdvisory);
                                if (onActivityResult['PROCEED']) {
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
                          child: StreamBuilder<List<CommunityModel>>(
                            stream: _profileBloc.communities,
                            builder: (context, snapshot) {
                              if (snapshot.data != null)
                                return Column(
                                  children: snapshot.data
                                      .map(
                                        (model) => CommunityCard(
                                          selected:
                                              user.currentCommunity == model.id,
                                          community: model,
                                          onTap: () {
                                            _profileBloc.setDefaultCommunity(
                                                user.email, model, context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    SwitchTimebank(),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                                );

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
                                child: LoadingIndicator(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        ProfileSettingsCard(
                          title: S.of(context).help,
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
                          title: S.of(context).notification_alerts,
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
                          title: S.of(context).blocked_members,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlockedMembersPage(
                                  timebankId: SevaCore.of(context)
                                      .loggedInUser
                                      .currentTimebank,
                                ),
                              ),
                            );
                          },
                        ),
                        ProfileSettingsCard(
                          title: S.of(context).my_request_categories,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return CustomRequestCategories();
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 20),
                        ProfileSettingsCard(
                          title: S.of(context).my_timezone,
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
                          title: S.of(context).my_language,
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
                  Text(S.of(context).loading + '...'),
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

            actionsPadding: EdgeInsets.only(right: 20),
            content: Form(
              child: Container(
                height: 200,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    dialogTitle,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              CustomTextButton(
                shape: StadiumBorder(),
                color: HexColor("#d2d2d2"),
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).accentColor,
                child: Text(
                  S.of(context).proceed,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Europa',
                    color: Colors.white,
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
          icon: Icon(Icons.edit),
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
              community.name,
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
