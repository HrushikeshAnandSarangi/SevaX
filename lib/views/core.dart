import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as prefix0;
import 'package:location/location.dart';
import 'package:location/location.dart' as prefix1;
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/exchange/createoffer.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/views/search_view.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/timebank_admin_listview.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';

import 'package:sevaexchange/views/news/newslistview.dart';
import 'package:sevaexchange/views/exchange/help.dart';

import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/flavor_config.dart';
import '../globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'invitation/InviteMembers.dart';
import 'notifications/notifications_page.dart';
//import 'package:connectivity/connectivity.dart';

class SevaCore extends InheritedWidget {
  UserModel loggedInUser;

  SevaCore({
    @required this.loggedInUser,
    @required Widget child,
    Key key,
  })
      : assert(loggedInUser != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(SevaCore oldWidget) {
    return loggedInUser != oldWidget.loggedInUser;
  }

  static SevaCore of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SevaCore) as SevaCore;
  }

//  Future<bool> check() async {
//    var connectivityResult = await (Connectivity().checkConnectivity());
//    if (connectivityResult == ConnectivityResult.mobile) {
//      return true;
//    } else if (connectivityResult == ConnectivityResult.wifi) {
//      return true;
//    }
//    return false;
//  }
}

class CoreView extends StatefulWidget {
  final String sevaUserID;

  CoreView({@required this.sevaUserID});

  @override
  _CoreViewState createState() => _CoreViewState();
}

class _CoreViewState extends State<CoreView> {
  UserModel user;

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
    UserData.shared.isFromLogin = false;
  }

//  _getCurrentLocation() {
//    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//
//    geolocator
//        .getCurrentPosition(desiredAccuracy: prefix0.LocationAccuracy.best)
//        .then((Position position) {
//      // setState(() {
//      SevaCore.of(context).loggedInUser.currentPosition = position;
//      //});
//    }).catchError((e) {
//      print(e);
//    });
//  }

  @override
  void didChangeDependencies() {
    // SevaCore.of(context).loggedInUser.sevaUserID = "qgc7oclcyhXP6jjnFG1rXmVZ7Bp2";
    user = UserModel(
      sevaUserID: SevaCore
          .of(context)
          .loggedInUser
          .sevaUserID,
      email: SevaCore
          .of(context)
          .loggedInUser
          .email,
      photoURL: SevaCore
          .of(context)
          .loggedInUser
          .photoURL,
    );

    if (user.blockedMembers != null) {
      SevaCore
          .of(context)
          .loggedInUser
          .blockedMembers = user.blockedMembers;
      print("Updated blocked");
    } else {
      print("blocked users not init");
    }

    print("Seva Core User -> ${user.toString()}");

    FirestoreManager.getUserForId(sevaUserId: widget.sevaUserID).then((user) {
      if (mounted) {
        setState(() => this.user = user);
        print("mounting data ");
      } else {
        print("skipping mount as data is already mounted");
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return
      //AnnotatedRegion<SystemUiOverlayStyle>(
      //child:
      MaterialApp(
        theme: FlavorConfig.values.theme,
        home: SevaCoreView(user: user),
        // ),
        // value: SystemUiOverlayStyle(
        //   statusBarBrightness: Brightness.dark,
        //   //statusBarColor: Theme.of(context).primaryColor,
        //   systemNavigationBarIconBrightness: Brightness.dark,
        //   statusBarIconBrightness: Brightness.dark
        // ),
      );
  }
}

class SevaCoreView extends StatefulWidget {
  final UserModel user;

  SevaCoreView({Key key, this.user}) : super(key: key);

  @override
  _SevaCoreViewState createState() => _SevaCoreViewState();
}

class _SevaCoreViewState extends State<SevaCoreView>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<PageProperty> pages = [];

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
    pages = [
      newsPageProperty,
      exchangePageProperty,
      tasksPageProperty,
      //createPageProperty,
      searchPageProperty,
    ];
  }

  bool isAdminOrCoordinator = false;
  bool isNotification = false;

  @override
  void didChangeDependencies() {
    print("didChangeDependencies called");
    // TODO: implement didChangeDependencies
    FirestoreManager.getTimeBankForId(
        timebankId: SevaCore
            .of(context)
            .loggedInUser
            .currentTimebank)
        .then((timebank) {
      if (timebank.admins
          .contains(SevaCore
          .of(context)
          .loggedInUser
          .sevaUserID) ||
          timebank.coordinators
              .contains(SevaCore
              .of(context)
              .loggedInUser
              .sevaUserID)) {
        setState(() {
          print("Admin access granted");
          isAdminOrCoordinator = true;
        });
      } else {
        // print("Admin access Revoked");
        // isAdminOrCoordinator = false;
      }
      FirestoreManager.isUnreadNotification(
          SevaCore
              .of(context)
              .loggedInUser
              .email)
          .then((onValue) {
        isNotification = onValue;
      });
    });
    super.didChangeDependencies();
  }

  fetchCurrentLocation() async {
    print("STARTING LOCATION SERVICE");
    var location = Location();
    location.changeSettings(
        accuracy: prefix1.LocationAccuracy.POWERSAVE,
        interval: 1000,
        distanceFilter: 500);
    if (!await location.hasPermission()) {
      await location.requestPermission();
    }

    try {
      await location.onLocationChanged().listen((LocationData currentLocation) {
        print(currentLocation.latitude);
        print(currentLocation.longitude);
        //_getCurrentLocation();
        setState(() {
          SevaCore
              .of(context)
              .loggedInUser
              .currentPosition = currentLocation;
        });
      });
    } catch (error) {
      location = null;
    }
  }

  int sharedValue = 0;
  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text(
      'All Feeds',
      style: TextStyle(fontSize: 10.0),
    ),
    1: Text(
      'NearMe Feeds',
      style: TextStyle(fontSize: 10.0),
    ),
  };

  @override
  Widget build(BuildContext context) {
    String email = SevaCore
        .of(context)
        .loggedInUser
        .email;

    if (email != null) {
      FirebaseMessaging().getToken().then(
            (token) {
          Firestore.instance.collection('users').document(email).updateData({
            'tokens': token,
          });
        },
      );
    }

    return Scaffold(
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        centerTitle: true,
        title:
//        Text(
//          'Feeds',
//          style: TextStyle(color: Colors.white),
//        ),
        Text(
          pages.elementAt(_selectedIndex).title,
          style: TextStyle(color: Colors.white),
        ),
//              Container(
//                width: 200,
//                child: CupertinoSegmentedControl<int>(
//                  children: logoWidgets,
//                  selectedColor: Colors.deepOrange,
//                  //pressedColor: Colors.white,
//                  //unselectedColor: Colors.white,
//                  padding: EdgeInsets.only(left: 5.0,right: 5.0),
//                  groupValue: globals.sharedValue,
//                  onValueChanged: (int val) {
//                    print(val);
//                    if(val == 0) {
//                      setState(() {
//                        globals.isNearme = false;
//                      });
//                    } else {
//                      setState(() {
//                        globals.isNearme = true;
//                      });
//                    }
//
//                    setState(() {
//                      globals.sharedValue = val;
//                    });
//                  },
//                ),
//              ),

        leading: IconButton(
          icon: Hero(
            tag: 'profilehero',
            child: Container(
              height: 36,
              width: 36,
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                      SevaCore
                          .of(context)
                          .loggedInUser
                          .photoURL),
                ),
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileView(),
              ),
            );
          },
        ),
        actions: [
          StreamBuilder<Object>(
              stream: FirestoreManager.getNotifications(
                  userEmail: SevaCore
                      .of(context)
                      .loggedInUser
                      .email),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  );
                }

                List<NotificationsModel> notifications = snapshot.data;
                if (notifications.length > 0) {
                  return IconButton(
                    icon: Icon(Icons.notifications_active),
                    color: Colors.red,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  );
                } else {
                  return IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(),
                        ),
                      );
                    },
                  );
                }
              }),
          IconButton(
            icon: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListView(),
                ),
              );
            },
          ),

          //...pages.elementAt(_selectedIndex).appBarActions,
        ],
        bottom: pages
            .elementAt(_selectedIndex)
            .bottom,
      ),
      floatingActionButton: getFloatingBtn(),
      body: pages
          .elementAt(_selectedIndex)
          .page,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme
            .of(context)
            .bottomAppBarColor,
        type: BottomNavigationBarType.fixed,
        elevation: 26,
        unselectedItemColor: Colors.grey[500],
        items: () {
          List<PageProperty> bottomPages = [];

          for (int i = 0; i < pages.length; i++) {
            //if (i != 2)
            bottomPages.add(pages.elementAt(i));
          }

          return bottomPages.map((page) {
            return BottomNavigationBarItem(
              icon: page.tabIcon,
              title: Text(page.title),
            );
          }).toList();
        }(),
        currentIndex: _selectedIndex,
        selectedItemColor: FlavorConfig.appFlavor == Flavor.TOM
            ? Colors.white
            : Theme
            .of(context)
            .primaryColor,
        onTap: (index) =>
            setState(() {
              _selectedIndex = index;
            }),
      ),
      // floatingActionButton: GestureDetector(
      //   onTap: () {
      //     setState(() {
      //       _selectedIndex = 2;
      //     });
      //   },
      //   child: AnimatedPhysicalModel(
      //     duration: Duration(milliseconds: 300),
      //     curve: Curves.easeIn,
      //     shape: BoxShape.circle,
      //     color: _selectedIndex == 2
      //         ? Theme.of(context).accentColor
      //         : Theme.of(context).primaryColor,
      //     shadowColor: Colors.black,
      //     elevation: _selectedIndex == 2 ? 0 : 6,
      //     child: AnimatedContainer(
      //       height: _selectedIndex != 2 ? 50 : 40,
      //       width: _selectedIndex != 2 ? 50 : 40,
      //       duration: _selectedIndex != 2
      //           ? Duration(milliseconds: 700)
      //           : Duration(milliseconds: 200),
      //       curve: _selectedIndex != 2 ? Curves.bounceOut : Curves.easeIn,
      //       decoration: ShapeDecoration(
      //         shape: CircleBorder(),
      //       ),
      //       child: Center(
      //         child: Icon(
      //           Icons.list,
      //           color: Colors.white,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  FloatingActionButton getFloatingBtn() {
    if (pages
        .elementAt(_selectedIndex)
        .title == "Feeds") {
      return FloatingActionButton.extended(
          label: Text(
            "Create Feed",
            style: TextStyle(fontSize: 11.0),
          ),
          foregroundColor: FlavorConfig.values.buttonTextColor,
          onPressed: () {
            if (SevaCore
                .of(context)
                .loggedInUser
                .associatedWithTimebanks > 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectTimeBankForNewRequest("Feed"),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NewsCreate(
                        timebankId:
                        SevaCore
                            .of(context)
                            .loggedInUser
                            .currentTimebank,
                      ),
                ),
              );
            }
          });
    } else if (pages
        .elementAt(_selectedIndex)
        .title == "Volunteer") {
      if (this.tabValue == 0) {
        return FloatingActionButton.extended(
            label: Text(
              "Create Volunteer Request",
              style: TextStyle(fontSize: 11.0),
            ),
            foregroundColor: FlavorConfig.values.buttonTextColor,
            onPressed: () {
              if (SevaCore
                  .of(context)
                  .loggedInUser
                  .adminOfYanagGangs > 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SelectTimeBankForNewRequest("Request"),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateRequest(
                          timebankId: SevaCore
                              .of(context)
                              .loggedInUser
                              .timebankIdForYangGangAdmin,
                        ),
                  ),
                );
              }
            });
      } else {
        return FloatingActionButton.extended(
            label: Text(
              "Create Volunteer Offer",
              style: TextStyle(fontSize: 11.0),
            ),
            foregroundColor: FlavorConfig.values.buttonTextColor,
            onPressed: () {
              if (SevaCore
                  .of(context)
                  .loggedInUser
                  .associatedWithTimebanks >
                  1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SelectTimeBankForNewRequest("Offer"),
                  ),
                );
              }
              else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateOffer(
                          timebankId: SevaCore
                              .of(context)
                              .loggedInUser
                              .currentTimebank,
                        ),
                  ),
                );
              }
            });
      }
    } else {
      return null;
    }
  }

  PageProperty get newsPageProperty {
    return PageProperty(
      tabIcon: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
          FlavorConfig.appFlavor == Flavor.APP
          ? Icon(Icons.description)
          : FlavorConfig.appFlavor == Flavor.TOM
          ? Icon(
        Icons.description,
        color: Colors.white,
      )
          : SvgPicture.asset(
        'lib/assets/tulsi_icons/tulsi2020_icons_feed-icon.svg',
        height: 22,
        width: 22,
        color: Colors.white,
      ),
      page: NewsListView(),
      title: 'Feeds',
      appBarActions: [
        // IconButton(
        //   icon: Icon(Icons.notifications_none),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => NotificationsPage(),
        //       ),
        //     );
        //   },
        // ),
        // IconButton(
        //   icon: Icon(Icons.add),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => NewsCreate(),
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }

  PageProperty get searchPageProperty {
    TabController controller = TabController(length: 4, vsync: this);
    return PageProperty(
      tabIcon: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
          FlavorConfig.appFlavor == Flavor.APP
          ? Icon(Icons.search)
          : FlavorConfig.appFlavor == Flavor.TOM
          ? Icon(
        Icons.search,
        color: Colors.white,
      )
          : SvgPicture.asset(
        'lib/assets/tulsi_icons/tulsi2020_icons_search-icon.svg',
        height: 22,
        width: 22,
        color: Colors.white,
      ),
      page: SearchView(controller),
      title: 'Search',
      // bottom: TabBar(
      //   tabs: [
      //     Tab(child: Text('Users')),
      //     Tab(child: Text('News')),
      //     Tab(child: Text('Requests')),
      //     Tab(child: Text('Offers')),
      //   ],
      //   controller: controller,
      //   isScrollable: true,
      // ),
      appBarActions: [],
    );
  }

  int tabValue = 0;

  PageProperty get exchangePageProperty {
    TabController controller = TabController(length: 2, vsync: this);
    return PageProperty(
      tabIcon: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
          FlavorConfig.appFlavor == Flavor.APP
          ? Icon(Icons.swap_horizontal_circle)
          : FlavorConfig.appFlavor == Flavor.TOM
          ? Icon(
        Icons.swap_horizontal_circle,
        color: Colors.white,
      )
          : SvgPicture.asset(
        'lib/assets/tulsi_icons/tulsi2020_icons_volunteer-icon.svg',
        height: 22,
        width: 22,
        color: Colors.white,
      ),
      page: HelpView(controller),
      title: 'Volunteer',
      bottom: TabBar(
        isScrollable: false,
        labelColor: Colors.white,
        tabs: [
          Tab(child: Text('${FlavorConfig.values.requestTitle}s')),
          Tab(child: Text('${FlavorConfig.values.offertitle}s')),
        ],
        controller: controller,
        //dragStartBehavior: Dr,
        onTap: (value) {
          setState(() {
            this.tabValue = value;
          });
          print("tab value $value");
        },
      ),
      appBarActions: [],
    );
  }

  PageProperty get tasksPageProperty {
    TabController controller = TabController(length: 3, vsync: this);
    return PageProperty(
      tabIcon: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
          FlavorConfig.appFlavor == Flavor.APP
          ? Icon(Icons.playlist_add_check)
          : FlavorConfig.appFlavor == Flavor.TOM
          ? Icon(
        Icons.playlist_add_check,
        color: Colors.white,
      )
          : SvgPicture.asset(
        'lib/assets/tulsi_icons/tulsi2020_icons_mytasks-icon.svg',
        height: 22,
        width: 22,
        color: Colors.white,
      ),
      page: MyTaskPage(controller),
      title: 'My Tasks',
      appBarActions: [],
      bottom: TabBar(
        labelColor: Colors.white,
        //labelColor: Colors.white,
        tabs: [
          Tab(child: Text('Pending ')),
          Tab(
              child: Text(
                'Not Accepted ',
              )),
          Tab(
              child: Text(
                'Completed ',
              )),
        ],
        controller: controller,
        isScrollable: true,
      ),
    );
  }

  PageProperty get createPageProperty {
    return PageProperty(
        tabIcon: FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST ||
            FlavorConfig.appFlavor == Flavor.APP
            ? Icon(Icons.add_circle)
            : FlavorConfig.appFlavor == Flavor.TOM
            ? Icon(
          Icons.add_circle,
          color: Colors.white,
        )
            : SvgPicture.asset(
          'lib/assets/tulsi_icons/tulsi2020_icons_add-icon.svg',
          height: 22,
          width: 22,
          color: Colors.white,
        ),
        page: SevaCoreView(),
        title: 'Create',
        appBarActions: []);
  }

  Future<void> _signOut(BuildContext context) async {
    var auth = AuthProvider
        .of(context)
        .auth;
    await auth.signOut();
    SevaCore
        .of(context)
        .loggedInUser
        .bio = '';
    globals.interests = [];
    globals.skills = [];
    await _onSignOutClearLocalData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AuthRouter(),
      ),
    );
  }

  Future<void> _onSignOutClearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullname', '');
    await prefs.setString('bio', '');
    await prefs.setString('email', '');
    await prefs.setStringList('interests', []);
    await prefs.setStringList('skills', []);
    await prefs.setString('sevauserid', '');
    await prefs.setString('photourl', '');
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: Color(0xFF737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.description,
                          color: Theme
                              .of(context)
                              .primaryColor),
                      title: new Text(
                        'Create Feed',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () =>
                      {
                        Navigator.of(context).pop(),

                        if (SevaCore
                            .of(context)
                            .loggedInUser
                            .associatedWithTimebanks >
                            1)
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SelectTimeBankForNewRequest("Feed"),
                              ),
                            ),
                          }
                        else
                          {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NewsCreate(
                                      timebankId: SevaCore
                                          .of(context)
                                          .loggedInUser
                                          .currentTimebank,
                                    ),
                              ),
                            ),
                          },

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         SelectTimeBankForNewRequest("Feed"),
                        //   ),
                        // ),

//                            Navigator.of(context).pop(),
//                            Navigator.push(
//                              context,
//                              MaterialPageRoute(
//                                builder: (context) => NewsCreate(
//                                  timebankId: SevaCore.of(context)
//                                      .loggedInUser
//                                      .currentTimebank,
//                                ),
//                              ),
//                            )
                      }),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.swap_horizontal_circle,
                        color: Theme
                            .of(context)
                            .primaryColor),
                    title: new Text(
                      'Create ${FlavorConfig.values.requestTitle}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () =>
                    {
                      if (SevaCore
                          .of(context)
                          .loggedInUser
                          .adminOfYanagGangs >
                          1)
                        {
                          Navigator.of(context).pop(),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectTimeBankForNewRequest("Request"),
                            ),
                          ),
                        }
                      else
                        {
                          Navigator.of(context).pop(),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateRequest(
                                    timebankId: SevaCore
                                        .of(context)
                                        .loggedInUser
                                        .timebankIdForYangGangAdmin,
                                  ),
                            ),
                          ),
                        }

//                      FirestoreManager.getTimeBankForId(
//                              timebankId: SevaCore.of(context)
//                                  .loggedInUser
//                                  .currentTimebank)
//                          .then((timebank) {
//                        if (timebank.admins.contains(
//                                SevaCore.of(context).loggedInUser.sevaUserID) ||
//                            timebank.coordinators.contains(
//                                SevaCore.of(context).loggedInUser.sevaUserID)) {
//                          Navigator.of(context).pop();
//                          Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                              builder: (context) => CreateRequest(
//                                timebankId: SevaCore.of(context)
//                                    .loggedInUser
//                                    .currentTimebank,
//                              ),
//                            ),
//                          );
//                        } else {
//                          showDialog(
//                            context: context,
//                            builder: (BuildContext context) {
//                              // return object of type Dialog
//                              return AlertDialog(
//                                title: new Text("Permission Denied"),
//                                content: new Text(
//                                    "You need to be an Admin or Coordinator to have permission to create campaigns"),
//                                actions: <Widget>[
//                                  // usually buttons at the bottom of the dialog
//                                  new FlatButton(
//                                    child: new Text("Close"),
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                    },
//                                  ),
//                                ],
//                              );
//                            },
//                          );
//                        }
//                      }),
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.local_offer,
                      color: Theme
                          .of(context)
                          .primaryColor,
                    ),
                    title: new Text(
                      'Create ${FlavorConfig.values.offertitle}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () =>
                    {
                      Navigator.of(context).pop(),
                      if (SevaCore
                          .of(context)
                          .loggedInUser
                          .associatedWithTimebanks >
                          1)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectTimeBankForNewRequest("Offer"),
                            ),
                          ),
                        }
                      else
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateOffer(
                                    timebankId: SevaCore
                                        .of(context)
                                        .loggedInUser
                                        .currentTimebank,
                                  ),
                            ),
                          ),
                        },
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.timeline,
                        color: Theme
                            .of(context)
                            .primaryColor),
                    title: new Text(
                      'Create a ${FlavorConfig.values.timebankTitle}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () =>
                    {
                      if (FlavorConfig.appFlavor != Flavor.APP)
                        {createSubTimebank(context)}
                      else
                        {
                          if (isAdminOrCoordinator)
                            {createSubTimebank(context)}
                          else
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: new Text("Permission Denied"),
                                    content: new Text(
                                        "You need to be an Admin or Coordinator to have permission to create timebanks"),
                                    actions: <Widget>[
                                      // usually buttons at the bottom of the dialog
                                      new FlatButton(
                                        child: new Text("Close"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              )
                            }
                        }
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.link,
                        color: Theme
                            .of(context)
                            .primaryColor),
                    title: new Text(
                      'Invite members via code',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () =>
                    {
                      Navigator.of(context).pop(),

                      if (SevaCore
                          .of(context)
                          .loggedInUser
                          .adminOfYanagGangs >
                          1)
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SelectTimeBankForNewRequest("Invite"),
                            ),
                          ),
                        }
                      else
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InviteMembers(
                                    SevaCore
                                        .of(context)
                                        .loggedInUser
                                        .timebankIdForYangGangAdmin,
                                  ),
                            ),
                          ),
                        },

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => InviteMembers(),
                      //   ),
                      // ),

                      // FirestoreManager.getTimebanksForAdmins(
                      //         userId:  SevaCore.of(context)
                      //             .loggedInUser
                      //             .sevaUserID)
                      //     .then((timebank) {
                      //   if (timebank.admins.contains(
                      //           SevaCore.of(context).loggedInUser.sevaUserID) ||
                      //       timebank.coordinators.contains(
                      //           SevaCore.of(context).loggedInUser.sevaUserID)) {
                      //     // Navigator.of(context).pop();

                      //   } else {
                      //     // showDialog(
                      //     //   context: context,
                      //     //   builder: (BuildContext context) {
                      //     //     // return object of type Dialog
                      //     //     return AlertDialog(
                      //     //       title: new Text("Permission Denied"),
                      //     //       content: new Text(
                      //     //           "You need to be an Admin or Coordinator to have permission to invite users"),
                      //     //       actions: <Widget>[
                      //     //         // usually buttons at the bottom of the dialog
                      //     //         new FlatButton(
                      //     //           child: new Text("Close"),
                      //     //           onPressed: () {
                      //     //             Navigator.of(context).pop();
                      //     //           },
                      //     //         ),
                      //     //       ],
                      //     //     );
                      //     //   },
                      //     // );
                      //   }
                      // }
                      // ),
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Future<String>

  void createSubTimebank(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TimebankCreate(
              timebankId: FlavorConfig.values.timebankId,
            ),
      ),
    );
  }
}

class PageProperty {
  Widget page;
  String title;
  List<Widget> appBarActions;
  Widget tabIcon;
  FloatingActionButton fab;
  PreferredSizeWidget bottom;

  PageProperty({
    @required this.page,
    @required this.title,
    @required this.appBarActions,
    @required this.tabIcon,
    this.fab,
    this.bottom,
  });
}
