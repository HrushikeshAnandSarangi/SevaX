import 'package:flutter/material.dart';
import 'package:sevaexchange/auth/auth_provider.dart';
import 'package:sevaexchange/auth/auth_router.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/themes/sevatheme.dart';
import 'package:sevaexchange/utils/firestore_manager.dart'
    as FirestoreManager;
import 'package:sevaexchange/views/exchange/createoffer.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/news/newscreate.dart';
import 'package:sevaexchange/views/search_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';

import 'package:sevaexchange/views/news/newslistview.dart';
import 'package:sevaexchange/views/exchange/help.dart';

import 'package:sevaexchange/views/tasks/activity_view.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import '../globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notifications/notifications_page.dart';

class SevaCore extends InheritedWidget {
  final UserModel loggedInUser;

  SevaCore({
    @required this.loggedInUser,
    @required Widget child,
    Key key,
  })  : assert(loggedInUser != null),
        assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(SevaCore oldWidget) {
    return loggedInUser != oldWidget.loggedInUser;
  }

  static SevaCore of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SevaCore) as SevaCore;
  }
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
  }

  @override
  void didChangeDependencies() {
    user = UserModel(
      sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
      email: SevaCore.of(context).loggedInUser.email,
      photoURL: SevaCore.of(context).loggedInUser.photoURL,
    );
    FirestoreManager.getUserForId(sevaUserId: widget.sevaUserID).then((user) {
      if (mounted) {
        setState(() => this.user = user);
      }
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: sevaTheme,
      home: SevaCoreView(user: user),
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

    pages = [
      newsPageProperty,
      exchangePageProperty,
      tasksPageProperty,
      createPageProperty,
      searchPageProperty,
    ];
  }

  bool isAdminOrCoordinator = false;
  bool isNotification = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    FirestoreManager.getTimeBankForId(
            timebankId: 'ajilo297@gmail.com*1559128156543')
        .then((timebank) {
      if (timebank.admins.contains(SevaCore.of(context).loggedInUser.email) ||
          timebank.coordinators
              .contains(SevaCore.of(context).loggedInUser.email)) {
        setState(() {
          isAdminOrCoordinator = true;
        });
      }
      FirestoreManager.isUnreadNotification(
              SevaCore.of(context).loggedInUser.email)
          .then((onValue) {
        isNotification = onValue;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String email = SevaCore.of(context).loggedInUser.email;

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
      appBar: _selectedIndex == 4
          ? null
          : AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              centerTitle: true,
              title: Text(
                pages.elementAt(_selectedIndex).title,
                style: TextStyle(color: Colors.white),
              ),
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
                        image: widget.user.photoURL == null
                            ? AssetImage('lib/assets/images/noimagefound.png')
                            : NetworkImage(widget.user.photoURL),
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
                        userEmail: SevaCore.of(context).loggedInUser.email),
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
              bottom: pages.elementAt(_selectedIndex).bottom,
            ),
      body: pages.elementAt(_selectedIndex).page,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        unselectedItemColor: Colors.grey,
        items: () {
          List<PageProperty> bottomPages = [];

          for (int i = 0; i < pages.length; i++) {
            //if (i != 2)
            bottomPages.add(pages.elementAt(i));
          }

          return bottomPages.map((page) {
            return BottomNavigationBarItem(
              icon: Icon(page.tabIcon),
              title: Text(page.title),
            );
          }).toList();
        }(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: (index) => setState(() {
          if (index == 3) {
            _settingModalBottomSheet(context);
          } else
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

  PageProperty get newsPageProperty {
    return PageProperty(
      tabIcon: Icons.description,
      page: NewsListView(),
      title: 'Feed',
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
      tabIcon: Icons.search,
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

  PageProperty get exchangePageProperty {
    TabController controller = TabController(length: 2, vsync: this);
    return PageProperty(
      tabIcon: Icons.swap_horizontal_circle,
      page: HelpView(controller),
      title: 'Volunteer',
      bottom: TabBar(
        labelColor: Colors.white,
        tabs: [
          Tab(child: Text('Campaign Requests')),
          Tab(child: Text('Volunteer Offers')),
        ],
        controller: controller,
      ),
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
        //     if (globals.orCreateSelector == 0) {
        //       if (isAdminOrCoordinator) {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => CreateRequest(),
        //           ),
        //         );
        //       } else {
        //         print("alert check");

        //         showDialog(
        //           context: context,
        //           builder: (BuildContext context) {
        //             // return object of type Dialog
        //             return AlertDialog(
        //               title: new Text("Permission Denied"),
        //               content: new Text(
        //                   "You need to be an Admin or Coordinator to have permission to create campaigns"),
        //               actions: <Widget>[
        //                 // usually buttons at the bottom of the dialog
        //                 new FlatButton(
        //                   child: new Text("Close"),
        //                   onPressed: () {
        //                     Navigator.of(context).pop();
        //                   },
        //                 ),
        //               ],
        //             );
        //           },
        //         );
        //       }
        //     } else {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CreateOffer(),
        //         ),
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }

  PageProperty get tasksPageProperty {
    TabController controller = TabController(length: 3, vsync: this);
    return PageProperty(
      tabIcon: Icons.playlist_add_check,
      page: MyTaskPage(controller),
      title: 'Tasks',
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
        tabIcon: Icons.add_circle,
        page: SevaCoreView(),
        title: 'Create',
        appBarActions: []);
  }

  Future<void> _signOut(BuildContext context) async {
    var auth = AuthProvider.of(context).auth;
    await auth.signOut();
    SevaCore.of(context).loggedInUser.bio = '';
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
                      leading:
                          new Icon(Icons.description, color: Colors.indigo),
                      title: new Text(
                        'Create Feed',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () => {
                            Navigator.of(context).pop(),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsCreate(),
                              ),
                            )
                          }),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(Icons.swap_horizontal_circle,
                        color: Colors.indigo),
                    title: new Text(
                      'Create Campaign Request',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => {
                      if (isAdminOrCoordinator)
                        {
                          Navigator.of(context).pop(),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRequest(),
                            ),
                          )
                        }
                      else
                        {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Permission Denied"),
                                content: new Text(
                                    "You need to be an Admin or Coordinator to have permission to create campaigns"),
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
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.local_offer,
                      color: Colors.indigo,
                    ),
                    title: new Text(
                      'Create Volunteer Offer',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () => {
                      Navigator.of(context).pop(),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateOffer(),
                        ),
                      )
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class PageProperty {
  Widget page;
  String title;
  List<Widget> appBarActions;
  IconData tabIcon;
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
