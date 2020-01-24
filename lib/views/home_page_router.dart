import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/animations/bottom_nav_data.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';

import '../flavor_config.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  int selected = 2;

  List<Widget> pages;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pages = [
      JoinSubTimeBankView(
        isFromDash: true,
        loggedInUserModel: SevaCore.of(context).loggedInUser,
      ),
      NotificationsPage(),
      HomeDashBoard(),
      ChatListView(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FlavorConfig.values.theme,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height - 65,
              child: pages[selected],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 100.0,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CurvedNavigationBar(
                animationDuration: Duration(milliseconds: 300),
                index: selected,
                backgroundColor: Colors.transparent,
                buttonBackgroundColor: Colors.orange,
                height: 60,
                items: List.generate(
                  5,
                  (index) => CustomBottomNavigationItem(
                    selected: selected == index,
                    index: index,
                  ),
                ),
                onTap: (index) {
                  selected = index;
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavigationItem extends StatelessWidget {
  const CustomBottomNavigationItem({
    Key key,
    @required this.selected,
    this.index,
  }) : super(key: key);

  final bool selected;

  final int index;
  final double selectedSize = 40;
  final double unSelectedSize = 30;

  @override
  Widget build(BuildContext context) {
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarBrightness: Brightness.light,
    //   statusBarColor: Color(0x0FF766FE0),
    // ));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        getWidgetFromIndex(context, index),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        selected ? Container() : SizedBox(height: 8),
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            selected
                ? bottomNavigationData[index].icon
                : bottomNavigationData[index].iconOutline,
            color: selected ? Colors.white : Theme.of(context).primaryColor,
            // size: 40,
          ),
        ),
        selected
            ? Container()
            : Text(
                bottomNavigationData[index].title,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
        StreamBuilder<Object>(
          stream: FirestoreManager.getNotifications(
            userEmail: SevaCore.of(context).loggedInUser.email,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('hello');
              // IconButton(
              //   icon: Icon(
              //     Icons.notifications,
              //     color: Colors.grey,
              //   ),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => NotificationsPage(),
              //       ),
              //     );
              //   },
              // );
            }

            var notificationsRead =
                SevaCore.of(context).loggedInUser.notificationsRead != null
                    ? SevaCore.of(context).loggedInUser.notificationsRead
                    : 0;

            List<NotificationsModel> notifications = snapshot.data;
            var unreadNotifications = 0;
            notifications.forEach((notification) {
              !notification.isRead ? unreadNotifications += 1 : print("Read");
            });

            unreadNotifications = unreadNotifications - notificationsRead;
            return Container();
            //   if (unreadNotifications > 0) {
            //     return Container(
            //       width: 50.0,
            //       height: 50.0,
            //       child: new Stack(
            //         children: <Widget>[
            //           Center(
            //             child: IconButton(
            //               icon:
            //                   Icon(Icons.notifications_active, color: Colors.red),
            //               onPressed: () async {
            //                 var loggedUser = SevaCore.of(context).loggedInUser;
            //                 await Firestore.instance
            //                     .collection("users")
            //                     .document(loggedUser.email)
            //                     .updateData({
            //                   "notificationsRead":
            //                       unreadNotifications + notificationsRead
            //                 }).then((onValue) {
            //                   // setState(() {
            //                   //   SevaCore.of(context)
            //                   //       .loggedInUser
            //                   //       .notificationsRead = unreadNotifications;
            //                   // });
            //                   Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                       builder: (context) => NotificationsPage(),
            //                     ),
            //                   );
            //                 });
            //               },
            //             ),
            //           ),
            //           new Align(
            //             alignment: Alignment.topRight,
            //             child: Container(
            //               margin: EdgeInsets.all(7),
            //               child: Text(
            //                 "$unreadNotifications",
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 10,
            //                 ),
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     );
            //   } else {
            //     return IconButton(
            //       icon: Icon(
            //         Icons.notifications,
            //         color: Colors.white,
            //       ),
            //       onPressed: () {
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => NotificationsPage(),
            //           ),
            //         );
            //       },
            //     );
            //   }
          },
        ),
      ],
    );
  }

  Widget exploreIcon(BuildContext context, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            Icons.search,
            color: selected ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        selected
            ? Container()
            : Text(
                'Explore',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }

  Widget notificationsWidget(BuildContext context, bool selected) {
    return Column(
      children: <Widget>[
        Container(
            height: selected ? selectedSize : unSelectedSize,
            child: getActiveNotifications(context, selected)
            // Icon(
            //   selected ? Icons.notifications : Icons.notifications_none,
            //   color: selected ? Colors.white : Theme.of(context).primaryColor,
            // ),
            ),
        selected
            ? Container()
            : Text(
                'Notifications',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }

  Widget homeWidget(BuildContext context, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            Icons.home,
            color: selected ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        selected
            ? Container()
            : Text(
                'Home',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }

  Widget chatsWidget(BuildContext context, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            selected ? Icons.chat_bubble : Icons.chat_bubble_outline,
            color: selected ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        selected
            ? Container()
            : Text(
                'Chats',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }

  Widget settingsWidget(BuildContext context, bool selected) {
    return Column(
      children: <Widget>[
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            selected ? Icons.settings : Icons.settings,
            color: selected ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        selected
            ? Container()
            : Text(
                'Profile',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }

  Widget getWidgetFromIndex(BuildContext context, int index) {
    switch (index) {
      case NavigaionIndicator.EXPLORE_WIDGET:
        return exploreIcon(context, selected);
        break;

      case NavigaionIndicator.NOTIFICATIONS_WIDGET:
        return notificationsWidget(context, selected);
        break;

      case NavigaionIndicator.HOME_WIDGET:
        return homeWidget(context, selected);
        break;

      case NavigaionIndicator.CHATS_WIDGET:
        return chatsWidget(context, selected);
        break;

      case NavigaionIndicator.PROFILE_WIDGET:
        return settingsWidget(context, selected);
        break;

      default:
        return exploreIcon(context, selected);
    }
  }

  Widget getActiveNotifications(BuildContext context, bool selected) {
    return StreamBuilder<Object>(
      stream: FirestoreManager.getNotifications(
        userEmail: SevaCore.of(context).loggedInUser.email,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return
              // Icon(
              //   selected ? Icons.notifications : Icons.notifications_none,
              //   color: selected ? Colors.white : Theme.of(context).primaryColor,
              // ),

              IconButton(
            icon: selected
                ? Icon(
                    Icons.notifications,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                  ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NotificationsPage(),
              //   ),
              // );
            },
          );
        }

        var notificationsRead =
            SevaCore.of(context).loggedInUser.notificationsRead != null
                ? SevaCore.of(context).loggedInUser.notificationsRead
                : 0;

        List<NotificationsModel> notifications = snapshot.data;
        var unreadNotifications = 0;
        notifications.forEach((notification) {
          !notification.isRead ? unreadNotifications += 1 : print("Read");
        });

        unreadNotifications = unreadNotifications - notificationsRead;
        if (unreadNotifications > 0) {
          return Container(
            // width: 50.0,
            // height: 50.0,
            child: new Stack(
              children: <Widget>[
                Center(
                  child: selected
                      ? IconButton(
                          icon: Icon(Icons.notifications, color: Colors.white),
                          onPressed: null,
                        )
                      : IconButton(
                          icon: Icon(Icons.notifications_active,
                              color: Colors.red),
                          onPressed: () async {
                            var loggedUser = SevaCore.of(context).loggedInUser;
                            await Firestore.instance
                                .collection("users")
                                .document(loggedUser.email)
                                .updateData({
                              "notificationsRead":
                                  unreadNotifications + notificationsRead
                            }).then((onValue) {
                              // setState(() {
                              //   SevaCore.of(context)
                              //       .loggedInUser
                              //       .notificationsRead = unreadNotifications;
                              // });
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => NotificationsPage(),
                              //   ),
                              // );
                            });
                          },
                        ),
                ),
                selected
                    ? Container()
                    : new Align(
                        alignment: Alignment.center,
                        child: Container(
                          margin: EdgeInsets.only(left: 35),
                          child: Text(
                            "$unreadNotifications",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
              ],
            ),
          );
        } else {
          return IconButton(
            icon: Icon(
              Icons.notifications,
              color: selected ? Colors.white : Theme.of(context).primaryColor,
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => NotificationsPage(),
              //   ),
              // );
            },
          );
        }
      },
    );
  }
}

class NavigaionIndicator {
  static const int EXPLORE_WIDGET = 0;
  static const int NOTIFICATIONS_WIDGET = 1;
  static const int HOME_WIDGET = 2;
  static const int CHATS_WIDGET = 3;
  static const int PROFILE_WIDGET = 4;
}
