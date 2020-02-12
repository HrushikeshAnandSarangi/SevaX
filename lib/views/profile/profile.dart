import 'dart:async';
import 'dart:core' as prefix0;
import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/animations/fade_route.dart';
import 'package:sevaexchange/utils/data_managers/blocs/user_profile_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/community/communitycreate.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';

import 'edit_profile.dart';
import 'timezone.dart';

//TODO fetch the communities from home dashboard

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

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  UserModel user;
  double titleOpacity = 0.0;
  // ScrollController scrollController;
  TimebankModel timebankModel;
  FirebaseUser firebaseUser;

  // double appbarScale = 0.9;
  // double flexibleScale = 1.0;

  // AnimationController appbarAnimationController;
  // AnimationController flexibleAnimationController;
  bool isAdminOrCoordinator = false;
  bool isVerifyAccountPressed = false;
  bool isUserLoaded = false;
  bool isCommunityLoaded = false;
  int selected = 0;
  double sevaCoinsValue = 0.0;

  UserProfileBloc _profileBloc = UserProfileBloc();

  List<CommunityModel> communities = [];
  Stream<List<RequestModel>> requestStream;

  @override
  void initState() {
    super.initState();
    _profileBloc.getAllCommunities(context, widget.userModel);
    checkEmailVerified();
    FirestoreManager.getTimeBankForId(
            timebankId: FlavorConfig.values.timebankId)
        .then((model) {
      setState(() {
        timebankModel = model;
      });
    });

    Future.delayed(Duration.zero, () {
      user = SevaCore.of(context).loggedInUser;
      setState(() {
        isUserLoaded = true;
      });
      FirestoreManager.getCompletedRequestStream(
              userEmail: SevaCore.of(context).loggedInUser.email,
              userId: SevaCore.of(context).loggedInUser.sevaUserID)
          .listen(
        (requestList) {
          if (!mounted) return;
          requestList.forEach((requestObj) {
            requestObj.transactions?.forEach((transaction) {
              if (transaction.isApproved &&
                  transaction.to ==
                      SevaCore.of(context).loggedInUser.sevaUserID)
                sevaCoinsValue += transaction.credits;
            });
          });
        },
      );
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
        setState(() {});
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
    // appbarAnimationController.dispose();
    // flexibleAnimationController.dispose();
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
                            tag: "ProfileImage",
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                user.photoURL,
                              ),
                              backgroundColor: Colors.white,
                              radius: MediaQuery.of(context).size.width / 4.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          user.fullname,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Europa',
                          ),
                        ),
                        SizedBox(height: 5),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            children: [
                              !firebaseUser.isEmailVerified
                                  ? TextSpan(
                                      text: '\nVerify Email',
                                      style: TextStyle(
                                        color: firebaseUser.isEmailVerified
                                            ? Colors.black
                                            : Colors.red,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap =
                                            _showVerificationAndLogoutDialogue)
                                  : TextSpan(),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 60,
                          padding: EdgeInsets.all(5),
                          child: RaisedButton(
                            shape: StadiumBorder(),
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2.0),
                                      child: sevaCoinIcon,
                                    ),
                                    SizedBox(height: 1),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: sevaCoinIcon,
                                    ),
                                    SizedBox(height: 1),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: sevaCoinIcon,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '${sevaCoinsValue} Seva Coins',
                                  style: TextStyle(
                                    color: user.currentBalance > 0
                                        ? Colors.blue
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ReviewEarningsPage();
                                  },
                                ),
                              );
                            },
                          ),
                        )
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
                            Text(
                              'Select a timebank',
                              style: TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateEditCommunityView(
                                      timebankId: timebankModel.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //         builder: (context) => CreateEditCommunityView(
                        //           timebankId: timebankModel.id,
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   child: Card(
                        //     elevation: 2,
                        //     child: Container(
                        //       height: 60,
                        //       child: Row(
                        //         children: <Widget>[
                        //           Padding(
                        //             padding: const EdgeInsets.only(left: 15),
                        //             child: Text(
                        //               'Create Timebank',
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.w500,
                        //                 color: Colors.black,
                        //                 fontSize: 16,
                        //               ),
                        //             ),
                        //           ),
                        //           Spacer(),
                        //           Icon(Icons.navigate_next),
                        //           SizedBox(
                        //             width: 10,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            // child: ListView.separated(
                            //   padding: EdgeInsets.all(0),
                            //   shrinkWrap: true,
                            //   itemCount: communities.length,
                            //   physics: NeverScrollableScrollPhysics(),
                            //   itemBuilder: (context, index) {
                            //     return CommunityCard(
                            //       community: communities[index],
                            //       selected: communities[index].id ==
                            //           user.currentCommunity,
                            //     );
                            //   },
                            //   separatorBuilder: (context, index) {
                            //     return Divider();
                            //   },
                          ),
                          child: StreamBuilder<List<Widget>>(
                            stream: _profileBloc.communities,
                            builder: (context, snapshot) {
                              if (snapshot.data != null)
                                return Column(children: snapshot.data);

                              if (snapshot.hasError)
                                return Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(snapshot.error),
                                ));
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
                        // InkWell(
                        //   onTap: () {
                        //     Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //         builder: (context) {
                        //           return FindCommunitiesView(
                        //             keepOnBackPress: true,
                        //             loggedInUser: user,
                        //           );
                        //         },
                        //       ),
                        //     );
                        //   },
                        //   child: Card(
                        //     elevation: 2,
                        //     child: Container(
                        //       height: 60,
                        //       child: Row(
                        //         children: <Widget>[
                        //           Padding(
                        //             padding: const EdgeInsets.only(left: 15),
                        //             child: Text(
                        //               'Discover Timebanks',
                        //               style: TextStyle(
                        //                 fontWeight: FontWeight.w500,
                        //                 color: Colors.black,
                        //                 fontSize: 16,
                        //               ),
                        //             ),
                        //           ),
                        //           Spacer(),
                        //           Icon(Icons.navigate_next),
                        //           SizedBox(
                        //             width: 10,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              // TextSpan(
                              //   text: 'or \n\n',
                              //   style: TextStyle(
                              //     color: Colors.black,
                              //   ),
                              // ),
                              TextSpan(
                                text: 'Discover more Timebanks',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    //Navigate to discover teams
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return FindCommunitiesView(
                                            keepOnBackPress: true,
                                            loggedInUser: SevaCore.of(context)
                                                .loggedInUser,
                                          );
                                        },
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return TimezoneView();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            child: Container(
                              height: 60,
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      'My Timezone',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.navigate_next),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 5),
                  Text('Loading ...'),
                ],
              ),
            ),
    );
  }

  AppBar getAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      // leading: IconButton(
      //   color: Colors.black,
      //   icon: Icon(Icons.arrow_back),
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      actions: <Widget>[
        IconButton(
          color: Colors.black,
          icon: Icon(Icons.settings),
          onPressed: navigateToSettings,
        ),
      ],
    );
  }

  // Widget get pageContent {
  //   if (user == null) return Center(child: CircularProgressIndicator());
  //   return NestedScrollView(
  //     controller: scrollController,
  //     headerSliverBuilder: (context, scrolled) {
  //       return [
  //         // sliverAppbar,
  //       ];
  //     },
  //     body: SingleChildScrollView(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           SizedBox(height: 60),
  //           getSevaCreditsWidget(userModel: user),
  //           // if (!firebaseUser.isEmailVerified)
  //           //   verifyBtn,
  //           //SizedBox(
  //           //height: 32,
  //           //),
  //           // skillsAndInterest,
  //           SizedBox(
  //             height: 32,
  //           ),
  //           // dataWidgets,
  //           SizedBox(
  //             height: 16,
  //           ),
  //           timezonewidget,
  //           SizedBox(
  //             height: 32,
  //           ),
  //           logoutButton
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget get skillsAndInterest {
//    if (user.skills == null || user.skills.isEmpty) {
//      if (user.interests == null || user.interests.isEmpty) return Container();
//    }
  //   return Container(
  //     //padding: EdgeInsets.all(5),
  //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
  //     decoration: getContainerDecoration(),
  //     child: Column(
  //       children: [
  //         // editInterests,
  //         // editSkills,
  //         editBio,
  //         editFullname,
  //       ],
  //     ),
  //   );
  // }

  // Parent getParentWidget({
  //   @required ChildList childList,
  //   @required String title,
  // }) {
  //   return Parent(
  //     childList: childList,
  //     parent: ListTile(
  //       trailing: Icon(
  //         Icons.navigate_next,
  //         color: Colors.black,
  //       ),
  //       onTap: () {
  //         //print("Tapped");
  //         if (title == 'Edit Interests') {
  //           this.navigateToeditInterests();
  //         } else if (title == 'Edit Skills') {
  //           this.navigateToeditskills();
  //         }
  //       },
  //       title: Text(
  //         title,
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void navigateToeditskills() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return EditSkills();
  //       },
  //     ),
  //   );
  // }

  // void navigateToeditInterests() {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         return EditInterests();
  //       },
  //     ),
  //   );
  // }

  // Widget getDataChip(String value) {
  //   assert(value != null);
  //   return Chip(
  //     label: Text(
  //       value,
  //       style: TextStyle(
  //         color: FlavorConfig.values.buttonTextColor,
  //       ),
  //     ),
  //     backgroundColor: Theme.of(context).accentColor,
  //   );
  // }

  // Widget get sliverAppbar {
  //   return SliverAppBar(
  //     iconTheme: IconThemeData(color: Colors.white),
  //     pinned: true,
  //     centerTitle: true,
  //     expandedHeight: 180,
  //     backgroundColor: Theme.of(context).primaryColor,
  //     actions: <Widget>[
  //       IconButton(
  //         icon: Icon(
  //           Icons.settings,
  //           color: Colors.white,
  //         ),
  //         onPressed: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => EditProfilePage(
  //                 userModel: user,
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ],
  //     title: Transform.scale(
  //       scale: appbarScale,
  //       child: AnimatedOpacity(
  //         opacity: titleOpacity,
  //         duration: titleOpacity == 1
  //             ? Duration(milliseconds: 400)
  //             : Duration(milliseconds: 100),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             Hero(
  //               tag: 'profilehero',
  //               child: Container(
  //                 height: 30,
  //                 width: 30,
  //                 decoration: ShapeDecoration(
  //                   shape: CircleBorder(
  //                     side: BorderSide(
  //                       color: Colors.white,
  //                       width: 1,
  //                     ),
  //                   ),
  //                   image: DecorationImage(
  //                     image: NetworkImage(user.photoURL),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: 8),
  //             Text(
  //               user.fullname,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //     flexibleSpace: LayoutBuilder(
  //       builder: (context, constraints) {
  //         return Transform.scale(
  //           scale: flexibleScale,
  //           child: AnimatedOpacity(
  //             duration: titleOpacity == 0
  //                 ? Duration(milliseconds: 400)
  //                 : Duration(milliseconds: 100),
  //             opacity: 1 - titleOpacity,
  //             child: FlexibleSpaceBar(
  //               collapseMode: CollapseMode.pin,
  //               background: Container(
  //                 padding: EdgeInsets.only(bottom: 16),
  //                 color: Theme.of(context).primaryColor,
  //                 child: Align(
  //                   alignment: Alignment.bottomCenter,
  //                   child: Padding(
  //                     padding: EdgeInsets.only(top: 50),
  //                     child: Center(
  //                       child: Column(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: <Widget>[
  //                           GestureDetector(
  //                             child: Container(
  //                               height: 60,
  //                               width: 60,
  //                               decoration: ShapeDecoration(
  //                                 shape: CircleBorder(
  //                                   side: BorderSide(
  //                                     color: Colors.white,
  //                                     width: 2.0,
  //                                   ),
  //                                 ),
  //                                 image: DecorationImage(
  //                                   image: NetworkImage(user.photoURL),
  //                                 ),
  //                               ),
  //                             ),
  //                             onTap: () {
  //                               print('Getsure Pressed');
  //                               Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                   builder: (context) => EditProfilePage(
  //                                     userModel: user,
  //                                   ),
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                           SizedBox(
  //                             width: 16,
  //                           ),
  //                           Padding(
  //                             padding: EdgeInsets.only(top: 5.0),
  //                           ),
  //                           Column(
  //                             mainAxisAlignment: MainAxisAlignment.start,
  //                             //crossAxisAlignment: CrossAxisAlignment.start,
  //                             mainAxisSize: MainAxisSize.min,
  //                             children: <Widget>[
  //                               Text(
  //                                 user.fullname,
  //                                 textAlign: TextAlign.center,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 22,
  //                                 ),
  //                               ),
  //                               Text(
  //                                 user.email,
  //                                 overflow: TextOverflow.ellipsis,
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 12,
  //                                 ),
  //                               ),
  //                               getSevaCreditsWidget(userModel: user),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

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
            RaisedButton(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              elevation: 5,
              color: Theme.of(context).accentColor,
              textColor: FlavorConfig.values.buttonTextColor,
              child: Text(
                "Ok, Sign out",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                firebaseUser.sendEmailVerification().then((value) {
                  _signOut(context);
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(
                  "No, I'll do it later",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
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

  // Widget get logoutButton {
  //   return Container(
  //     decoration: getContainerDecoration(color: Theme.of(context).accentColor),
  //     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     child: Card(
  //       color: Theme.of(context).accentColor,
  //       elevation: 0,
  //       child: InkWell(
  //         splashColor: Theme.of(context).accentColor,
  //         onTap: () {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               // return object of type Dialog
  //               return AlertDialog(
  //                 title: new Text("Log Out"),
  //                 content: new Text("Are you sure you want to logout?"),
  //                 actions: <Widget>[
  //                   // usually buttons at the bottom of the dialog
  //                   new FlatButton(
  //                     child: new Text("Log Out"),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                       _signOut(context);
  //                     },
  //                   ),
  //                   new RaisedButton(
  //                     padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
  //                     elevation: 5,
  //                     color: Theme.of(context).accentColor,
  //                     textColor: FlavorConfig.values.buttonTextColor,
  //                     child: new Text("Cancel"),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         },
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: <Widget>[
  //               Spacer(),
  //               Icon(Icons.exit_to_app,
  //                   color: FlavorConfig.values.buttonTextColor),
  //               SizedBox(
  //                 width: 8,
  //               ),
  //               Text(
  //                 'Log Out',
  //                 style: Theme.of(context).textTheme.button.copyWith(
  //                       color: FlavorConfig.values.buttonTextColor,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //               ),
  //               Spacer(),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget getSevaCreditsWidget({@required UserModel userModel}) {
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
  //     decoration: getContainerDecoration(),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: <Widget>[
  //         Container(
  //           margin: EdgeInsets.all(0),
  //           padding: EdgeInsets.all(0),
  //           alignment: Alignment.centerLeft,
  //           child: FlatButton(
  //             onPressed: () {
  //               Navigator.of(context).push(
  //                 MaterialPageRoute(
  //                   builder: (context) {
  //                     return ReviewEarningsPage();
  //                   },
  //                 ),
  //               );
  //             },
  //             child: Text(
  //               'Review Earnings >',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.w500,
  //                 color: Theme.of(context).accentColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Spacer(),
  //         // Column(
  //         //   crossAxisAlignment: CrossAxisAlignment.end,
  //         //   children: <Widget>[
  //         //     coinCount(userModel),
  //         //     Container(
  //         //         alignment: Alignment.centerRight,
  //         //         padding: EdgeInsets.only(left: 8.0),
  //         //         child: coinType),
  //         //   ],
  //         // ),
  //       ],
  //     ),
  //   );
  // }

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

  // Widget get dataWidgets {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     width: double.infinity,
  //     decoration: getContainerDecoration(),
  //     child: Column(
  //       children: <Widget>[
  //         if (!firebaseUser.isEmailVerified) verifyBtn,
  //         administerTimebanks,
  //         timebankslist,
  //         // joinViaCode,
  //         // tasksWidget,
  //         // reportsData,
  //       ],
  //     ),
  //   );
  // }

  // Widget get reportsData {
  //   if (isAdminOrCoordinator) {
  //     return getActionCards(
  //       title: 'Reported users',
  //       trailingIcon: Icons.navigate_next,
  //       borderRadius: BorderRadius.only(
  //         bottomRight: Radius.circular(12),
  //         bottomLeft: Radius.circular(12),
  //       ),
  //       onTap: () {
  //         Navigator.of(context).push(
  //           MaterialPageRoute(
  //             builder: (context) {
  //               return ReportedUsersPage(
  //                 timebankId: FlavorConfig.values.timebankId,
  //               );
  //             },
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return Offstage();
  //   }
  // }

  // Widget get tasksWidget {
  //   return getActionCards(
  //     title: 'Completed Tasks',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       bottomRight: Radius.circular(12),
  //       bottomLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return CompletedListPage();
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get editSkills {
  //   return getActionCards(
  //     title: 'Edit Skills',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       bottomRight: Radius.circular(12),
  //       bottomLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return EditSkills();
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get editInterests {
  //   return getActionCards(
  //     title: 'Edit Interests',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       topRight: Radius.circular(12),
  //       topLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //          builder: (context) {
  //             return EditInterests("");
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get editBio {
  //   return getActionCards(
  //     title: 'Edit Bio',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       topRight: Radius.circular(12),
  //       topLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return EditBio(SevaCore.of(context).loggedInUser.bio);
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get editFullname {
  //   return getActionCards(
  //     title: 'Edit name',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       topRight: Radius.circular(12),
  //       topLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) {
  //             print(
  //                 "------------------${SevaCore.of(context).loggedInUser.fullname}------------------");

  //             return EditName(SevaCore.of(context).loggedInUser.fullname);
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get joinViaCode {
  //   return getActionCards(
  //     title: 'Join via ${FlavorConfig.values.timebankTitle} code',
  //     trailingIcon: Icons.navigate_next,
  //     borderRadius: BorderRadius.only(
  //       bottomRight: Radius.circular(12),
  //       bottomLeft: Radius.circular(12),
  //     ),
  //     onTap: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) {
  //             return OnBoardWithTimebank();
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget get verifyBtn {
  //   return getActionCards(
  //     title: 'Verify account',
  //     borderRadius: BorderRadius.only(
  //       topRight: Radius.circular(12),
  //       topLeft: Radius.circular(12),
  //     ),
  //     isColorRed: true,
  //     onTap: () {
  //       ;
  //     },
  //   );
  // }

  // void launchTransactionHistory({@required UserModel user}) {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //     return TransactionHistoryView(userModel: user);
  //   }));
  // }

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
                  image: NetworkImage(community.logo_url),
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
          Icon(Icons.navigate_next),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}
