import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';

import '../../../../flavor_config.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  List<Widget> pages;
  int selected = 2;

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
  void initState() {
    super.initState();
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
                height: 55,
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
              child: CustomBottomNavigationBar(
                selected: selected,
                onChanged: (index) {
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
