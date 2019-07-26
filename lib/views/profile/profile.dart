import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/globals.dart';
import 'package:sevaexchange/main.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'dart:math';
import 'dart:async';
import 'package:sevaexchange/flavor_config.dart';

import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/timebank_admin_view.dart';

import 'package:sevaexchange/views/transaction_history.dart';
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

  double appbarScale = 0.9;
  double flexibleScale = 1.0;

  AnimationController appbarAnimationController;
  AnimationController flexibleAnimationController;

  @override
  void initState() {
    super.initState();
    FirestoreManager.getTimeBankForId(timebankId: FlavorConfig.timebankId)
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
    return Material(
      child: Stack(
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
            SizedBox(
              height: 32,
            ),
            skillsAndInterest,
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
    if (user.skills == null || user.skills.isEmpty) {
      if (user.interests == null || user.interests.isEmpty) return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
      decoration: getContainerDecoration(),
      child: Column(
        children: [
          if (user.interests != null && user.interests.length != 0)
            // ExpansionTile(
            //   trailing: Icon(
            //     Icons.navigate_next,
            //     color: Colors.black,
            //   ),
            //   title: Text(
            //     'My Interests',
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            //   children: user.interests.map((interest) {
            //     return getDataChip(interest);
            //   }).toList(),
            // ),
            getParentWidget(
              title: 'My Interests',
              childList: ChildList(
                mainAxisSize: MainAxisSize.min,
                children: user.interests.map((interest) {
                  return getDataChip(interest);
                }).toList(),
              ),
            ),
          if (user.interests != null && user.interests.length != 0) Divider(),
          if (user.skills != null && user.skills.length != 0)
            getParentWidget(
              title: 'My Skills',
              childList: ChildList(
                children: user.skills.map((skill) {
                  return getDataChip(skill);
                }).toList(),
              ),
            ),
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

  Widget getDataChip(String value) {
    assert(value != null);
    return Chip(
      label: Text(
        value,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).accentColor,
    );
  }

  Widget get sliverAppbar {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      expandedHeight: 180,
      backgroundColor: Theme.of(context).primaryColor,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          decoration: ShapeDecoration(
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(user.photoURL),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              user.fullname,
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
                            SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ],
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
                      textColor: Colors.white,
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
                Icon(Icons.exit_to_app, color: Colors.white),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Log Out',
                  style: Theme.of(context).textTheme.button.copyWith(
                        color: Colors.white,
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
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
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
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: <Widget>[
                Text(
                  userModel.currentBalance.toString() ?? '0.0',
                  style: TextStyle(
                      color: userModel.currentBalance >= 0
                          ? userModel.currentBalance > 0
                              ? Colors.indigo
                              : Colors.black
                          : Colors.red,
                      fontSize: 32.0,
                      fontWeight: FontWeight.w600),
                ),
                FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
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
                          height: 16,
                          width: 16,
                        ),
                      ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 8.0),
            child: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                ? Text(
                    'Yang Bucks',
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget get dataWidgets {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      decoration: getContainerDecoration(),
      child: Column(
        children: <Widget>[
          administerTimebanks,
          tasksWidget,
        ],
      ),
    );
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
    return getActionCards(
      title: 'Timebank',
      subtitle: timebankModel == null ? "loading" : timebankModel.name,
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
                timebankId: FlavorConfig.timebankId,
              );
            },
          ),
        );
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
