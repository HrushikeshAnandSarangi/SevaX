import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/home_dashboard.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/splash_view.dart';

import '../../../../flavor_config.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  // List<Widget> pages;
  int selected = 2;
  UserDataBloc _userBloc = UserDataBloc();
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   pages = [
  //     JoinSubTimeBankView(
  //       isFromDash: true,
  //       loggedInUserModel: SevaCore.of(context).loggedInUser,
  //     ),
  //     NotificationsPage(),
  //     HomeDashBoard(),
  //     ChatListView(),
  //     ProfilePage(),
  //   ];
  // }

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () => _userBloc.getData(
        email: SevaCore.of(context).loggedInUser.email,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
    );
  }

  @override
  void dispose() {
    _userBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: FlavorConfig.values.theme,
      home: BlocProvider(
        bloc: _userBloc,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: StreamBuilder(
            // stream: _userBloc.getUser(SevaCore.of(context).loggedInUser.email),
            stream: CombineLatestStream.combine2(
                _userBloc.userStream, _userBloc.comunityStream, (u, c) => true),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                SevaCore.of(context).loggedInUser = _userBloc.user;

                // if (_userBloc.community.admins
                //         .contains(_userBloc.user.sevaUserID) &&
                //     (_userBloc.community.payment.isEmpty
                //     //     _userBloc.community.payment['payment_success'] ??
                //     // false
                //     )) {
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     Navigator.of(context).pushAndRemoveUntil(
                //         MaterialPageRoute(
                //           builder: (context) => BillingPlanDetails(
                //             user: _userBloc.user,
                //             isPlanActive: false,
                //           ),
                //         ),
                //         ((Route<dynamic> route) => false));
                //   });
                // }

                if (_userBloc.user.communities == null ||
                    _userBloc.user.communities.isEmpty) {
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
                      child: IndexedStack(
                        index: selected,
                        children: <Widget>[
                          ExplorePage(),
//                          JoinSubTimeBankView(
//                            isFromDash: true,
//                            loggedInUserModel: _userBloc.user,
//                          ),
                          NotificationsPage(),
                          HomeDashBoard(),
                          ChatListView(),
                          ProfilePage(),
                        ],
                      ),
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
