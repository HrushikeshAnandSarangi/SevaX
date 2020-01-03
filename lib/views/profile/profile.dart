import 'dart:core' as prefix0;
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/views/community/create_community.dart';
import 'package:sevaexchange/views/invitation/OnboardWithTimebankCode.dart';
import 'package:sevaexchange/views/news/overflow_constants.dart';
import 'package:sevaexchange/views/profile/edit_bio.dart';
import 'package:sevaexchange/views/profile/edit_interests.dart';
import 'package:sevaexchange/views/profile/edit_skills.dart';
import 'package:sevaexchange/views/profile/reported_users.dart';
import 'package:sevaexchange/views/timebanks/edit_super_admins_view.dart';
import 'package:sevaexchange/views/timebanks/time_bank_list.dart';
//import 'package:sevaexchange/views/profile/edit_profilepic.dart';
//import 'package:shimmer/shimmer.dart';
//import 'package:sevaexchange/globals.dart';
//import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'dart:math';
import 'dart:async';
import 'package:sevaexchange/flavor_config.dart';

import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebank_admin_view.dart';

import 'package:sevaexchange/views/transaction_history.dart';
import '../app_demo_humanity_first.dart';
import 'edit_name.dart';
import 'edit_profile.dart';
import 'timezone.dart';
import 'package:tree_view/tree_view.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProfilePage();
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  UserModel user;
  double titleOpacity = 0.0;
  ScrollController scrollController;
  TimebankModel timebankModel;
  FirebaseUser firebaseUser;

  double appbarScale = 0.9;
  double flexibleScale = 1.0;

  AnimationController appbarAnimationController;
  AnimationController flexibleAnimationController;
  bool isAdminOrCoordinator = false;
  bool isVerifyAccountPressed = false;

  @override
  void initState() {
    super.initState();

    checkEmailVerified();
    FirestoreManager.getTimeBankForId(
            timebankId: FlavorConfig.values.timebankId)
        .then((model) {
      setState(() {
        timebankModel = model;
      });
    });

    appbarAnimationController = AnimationController(
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        if (mounted)
          setState(() {
            appbarScale = appbarAnimationController.value;
          });
      });

    flexibleAnimationController = AnimationController(
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        flexibleScale = flexibleAnimationController.value;
      });

    scrollController = ScrollController();
    scrollController.addListener(() {
      if (mounted)
        setState(() {
          if (scrollController.offset > 75) {
            if (titleOpacity == 0) {
              appbarAnimationController.forward();
              flexibleAnimationController.reverse();
            }
            titleOpacity = 1;
          } else {
            if (titleOpacity == 1) {
              appbarAnimationController.reverse();
              flexibleAnimationController.forward();
            }
            titleOpacity = 0;
          }
        });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    ).listen((userModel) {
      if (mounted)
        setState(() {
          this.user = userModel;
        });
    });
  }

  @override
  void dispose() {
    appbarAnimationController.dispose();
    flexibleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 260,
              width: double.infinity,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SafeArea(child: pageContent),
        ],
      ),
    );
  }

  Widget get pageContent {
    if (user == null) return Center(child: CircularProgressIndicator());
    return NestedScrollView(
      controller: scrollController,
      headerSliverBuilder: (context, scrolled) {
        return [
          sliverAppbar,
        ];
      },
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 60),
            getSevaCreditsWidget(userModel: user),
            // if (!firebaseUser.isEmailVerified)
            //   verifyBtn,
            //SizedBox(
            //height: 32,
            //),
            // skillsAndInterest,
            SizedBox(
              height: 32,
            ),
            dataWidgets,
            SizedBox(
              height: 16,
            ),
            timezonewidget,
            SizedBox(
              height: 32,
            ),
            logoutButton
          ],
        ),
      ),
    );
  }

  Widget get skillsAndInterest {
//    if (user.skills == null || user.skills.isEmpty) {
//      if (user.interests == null || user.interests.isEmpty) return Container();
//    }
    return Container(
      //padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
      decoration: getContainerDecoration(),
      child: Column(
        children: [
          editInterests,
          editSkills,
          editBio,
          editFullname,
        ],
      ),
    );
  }

  Parent getParentWidget({
    @required ChildList childList,
    @required String title,
  }) {
    return Parent(
      childList: childList,
      parent: ListTile(
        trailing: Icon(
          Icons.navigate_next,
          color: Colors.black,
        ),
        onTap: () {
          //print("Tapped");
          if (title == 'Edit Interests') {
            this.navigateToeditInterests();
          } else if (title == 'Edit Skills') {
            this.navigateToeditskills();
          }
        },
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void navigateToeditskills() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EditSkills();
        },
      ),
    );
  }

  void navigateToeditInterests() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return EditInterests();
        },
      ),
    );
  }

  Widget getDataChip(String value) {
    assert(value != null);
    return Chip(
      label: Text(
        value,
        style: TextStyle(
          color: FlavorConfig.values.buttonTextColor,
        ),
      ),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  Widget get sliverAppbar {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.white),
      pinned: true,
      centerTitle: true,
      expandedHeight: 180,
      backgroundColor: Theme.of(context).primaryColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateCommunity(),
              ),
            );

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => EditProfilePage(
            //       userModel: user,
            //     ),
            //   ),
            // );
          },
        ),
      ],
      title: Transform.scale(
        scale: appbarScale,
        child: AnimatedOpacity(
          opacity: titleOpacity,
          duration: titleOpacity == 1
              ? Duration(milliseconds: 400)
              : Duration(milliseconds: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: 'profilehero',
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: ShapeDecoration(
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(user.photoURL),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                user.fullname,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return Transform.scale(
            scale: flexibleScale,
            child: AnimatedOpacity(
              duration: titleOpacity == 0
                  ? Duration(milliseconds: 400)
                  : Duration(milliseconds: 100),
              opacity: 1 - titleOpacity,
              child: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  padding: EdgeInsets.only(bottom: 16),
                  color: Theme.of(context).primaryColor,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Colors.white,
                                      width: 2.0,
                                    ),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(user.photoURL),
                                  ),
                                ),
                              ),
                              onTap: () {
                                print('Getsure Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      userModel: user,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  user.fullname,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVerificationAndLogoutDialogue() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Signing out"),
          content: Text("Acknowledge the verification mail and login back"),
          actions: <Widget>[
            FlatButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(
                  "No, I'll do it later",
                  style: TextStyle(
                    fontSize: dialogButtonSize,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop()),
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              elevation: 5,
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                "Ok, Sign out",
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                firebaseUser.sendEmailVerification().then((value) {
                  _signOut(context);
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget get logoutButton {
    return Container(
      decoration: getContainerDecoration(color: Theme.of(context).accentColor),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: Theme.of(context).accentColor,
        elevation: 0,
        child: InkWell(
          splashColor: Theme.of(context).accentColor,
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Log Out"),
                  content: new Text("Are you sure you want to logout?"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Log Out"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _signOut(context);
                      },
                    ),
                    new RaisedButton(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      elevation: 5,
                      color: Theme.of(context).accentColor,
                      textColor: FlavorConfig.values.buttonTextColor,
                      child: new Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Spacer(),
                Icon(Icons.exit_to_app,
                    color: FlavorConfig.values.buttonTextColor),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Log Out',
                  style: Theme.of(context).textTheme.button.copyWith(
                        color: FlavorConfig.values.buttonTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getSevaCreditsWidget({@required UserModel userModel}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
      decoration: getContainerDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerLeft,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return ReviewEarningsPage();
                    },
                  ),
                );
              },
              child: Text(
                'Review Earnings >',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor,
                ),
              ),
            ),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              coinCount(userModel),
              Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(left: 8.0),
                  child: coinType),
            ],
          ),
        ],
      ),
    );
  }

  void checkEmailVerified() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser firebaseUser) {
      if (this.firebaseUser != null && this.firebaseUser == firebaseUser) {
        return;
      }
      setState(() {
        print('Is email verified:${firebaseUser.isEmailVerified}');
        this.firebaseUser = firebaseUser;
      });
    });
  }

  Widget get dataWidgets {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      decoration: getContainerDecoration(),
      child: Column(
        children: <Widget>[
          if (!firebaseUser.isEmailVerified) verifyBtn,
          administerTimebanks,
          timebankslist,
          joinViaCode,
          tasksWidget,
          reportsData,
        ],
      ),
    );
  }

  Widget get reportsData {
    if (isAdminOrCoordinator) {
      return getActionCards(
        title: 'Reported users',
        trailingIcon: Icons.navigate_next,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ReportedUsersPage(
                  timebankId: FlavorConfig.values.timebankId,
                );
              },
            ),
          );
        },
      );
    } else {
      return Offstage();
    }
  }

  Widget get tasksWidget {
    return getActionCards(
      title: 'Completed Tasks',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CompletedListPage();
            },
          ),
        );
      },
    );
  }

  Widget get editSkills {
    return getActionCards(
      title: 'Edit Skills',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return EditSkills();
            },
          ),
        );
      },
    );
  }

  Widget get editInterests {
    return getActionCards(
      title: 'Edit Interests',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return EditInterests();
            },
          ),
        );
      },
    );
  }

  Widget get editBio {
    return getActionCards(
      title: 'Edit Bio',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return EditBio(SevaCore.of(context).loggedInUser.bio);
            },
          ),
        );
      },
    );
  }

  Widget get editFullname {
    return getActionCards(
      title: 'Edit name',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              print(
                  "------------------${SevaCore.of(context).loggedInUser.fullname}------------------");

              return EditName(SevaCore.of(context).loggedInUser.fullname);
            },
          ),
        );
      },
    );
  }

  Widget get joinViaCode {
    return getActionCards(
      title: 'Join via ${FlavorConfig.values.timebankTitle} code',
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return OnBoardWithTimebank();
            },
          ),
        );
      },
    );
  }

  Widget get timezonewidget {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      decoration: getContainerDecoration(),
      child: Column(
        children: <Widget>[
          getActionCards(
            title: 'My Timezone',
            trailingIcon: Icons.navigate_next,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return TimezoneView();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget get administerTimebanks {
    print(
        "${timebankModel.admins.contains(SevaCore.of(context).loggedInUser.sevaUserID)}    <---");
    return !timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)
        ? Offstage()
        : getActionCards(
            title: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? 'Humanity First'
                : 'Root Timebank',
            subtitle: timebankModel == null
                ? "loading"
                : FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                    ? null
                    : timebankModel.name,
            trailingIcon: Icons.navigate_next,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TimebankAdminPage(
                      timebankId: FlavorConfig.values.timebankId,
                      userEmail: SevaCore.of(context).loggedInUser.email,
                    );
                  },
                ),
              );
            },
          );
  }

  Widget get timebankslist {
    return getActionCards(
      //title: 'List of ${FlavorConfig.values.timebankTitle}',
      title: FlavorConfig.values.timebankName == "Yang 2020"
          ? "List of Yang Gang Chapters"
          : "${FlavorConfig.values.timebankTitle} list",
      trailingIcon: Icons.navigate_next,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TimeBankList(
                timebankid: FlavorConfig.values.timebankId,
                title: 'Timebanks List',
                superAdminTimebankModel: this.timebankModel,
              );
            },
          ),
        );
      },
    );
  }

  Widget get verifyBtn {
    return getActionCards(
      title: 'Verify account',
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
      isColorRed: true,
      onTap: () {
        _showVerificationAndLogoutDialogue();
      },
    );
  }

  Widget getActionCards({
    @required String title,
    String subtitle,
    @required IconData trailingIcon,
    VoidCallback onTap,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    Color backgroundColor = Colors.white,
    EdgeInsets padding = const EdgeInsets.all(8.0),
    Color splashColor,
    bool isColorRed = false,
  }) {
    Color _splashColor = splashColor ?? Theme.of(context).primaryColor;

    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        splashColor: _splashColor,
        borderRadius: borderRadius,
        child: Container(
          padding: padding,
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isColorRed ? Colors.red : Colors.black,
              ),
            ),
            subtitle: subtitle != null ? Text(subtitle) : null,
            trailing: Icon(
              trailingIcon,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration getContainerDecoration({
    double radius = 12.0,
    Color color = Colors.white,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(10),
            spreadRadius: 4,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: color,
    );
  }

  void launchTransactionHistory({@required UserModel user}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return TransactionHistoryView(userModel: user);
    }));
  }

  Widget get sevaCoinIcon {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(2),
        ),
        color: Color.fromARGB(255, 255, 197, 75),
      ),
      width: 20,
      height: 5,
    );
  }

  Widget coinCount(UserModel userModel) {
    return Row(
      children: <Widget>[
        Text(
          userModel.currentBalance.toString() ?? '0.0',
          style: TextStyle(
              color: userModel.currentBalance >= 0
                  ? userModel.currentBalance > 0 ? Colors.indigo : Colors.black
                  : Colors.red,
              fontSize: 36.0,
              fontWeight: FontWeight.w600),
        ),
        FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
                FlavorConfig.appFlavor == Flavor.APP ||
                FlavorConfig.appFlavor == Flavor.TOM
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: sevaCoinIcon,
                  ),
                  SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: sevaCoinIcon,
                  ),
                  SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: sevaCoinIcon,
                  ),
                ],
              )
            : Padding(
                padding: EdgeInsets.all(4),
                child: SvgPicture.asset(
                  'lib/assets/tulsi_icons/tulsi2020_icons_tulsi-token.svg',
                  height: 18,
                  width: 18,
                ),
              ),
      ],
    );
  }

  Widget get coinType {
    return FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
        ? Text(
            'Yang Bucks',
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w400,
                fontSize: 12),
          )
        : FlavorConfig.appFlavor == Flavor.APP
            ? Text(
                'Seva Coins',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
              )
            : FlavorConfig.appFlavor == Flavor.TOM
                ? Text(
                    'Tom Tokens',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12),
                  )
                : Text(
                    'Tulsi Tokens',
                    style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontWeight: FontWeight.w400,
                        fontSize: 12),
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

  MaterialColor get chipColor {
    List colors = Colors.primaries;

    Random random = Random();
    int selected = random.nextInt(18);

    return colors[selected];
  }
}
