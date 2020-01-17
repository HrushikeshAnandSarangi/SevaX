import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/animations/bottom_nav_data.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        selected ? Container() : SizedBox(height: 8),
        Container(
          height: selected ? selectedSize : unSelectedSize,
          child: Icon(
            bottomNavigationData[index].icon,
            color: selected ? Colors.white : Colors.grey,
            // size: 40,
          ),
        ),
        selected
            ? Container()
            : Text(
                bottomNavigationData[index].title,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
      ],
    );
  }
}
