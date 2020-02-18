import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';

import '../../../../flavor_config.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  List<Widget> pages;

  int selected = 2;

  UserDataBloc _userBloc = UserDataBloc();

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
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: FlavorConfig.values.theme,
      home: BlocProvider(
        bloc: _userBloc,
        child: Scaffold(
          body: StreamBuilder(
            // stream: _userBloc.getUser(SevaCore.of(context).loggedInUser.email),
            stream: Firestore.instance
                .collection("users")
                .document(SevaCore.of(context).loggedInUser.email)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                UserModel user = UserModel.fromMap(snapshot.data.data);
                // _userBloc.updateUser.add(user);
                SevaCore.of(context).loggedInUser = user;

                if (user.communities == null || user.communities.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SplashView()),
                        ((Route<dynamic> route) => false));
                  });
                }
                return Stack(
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
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
