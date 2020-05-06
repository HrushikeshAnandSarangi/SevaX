import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatlist_view.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/explore_tabview.dart';

import '../../../../app_localizations.dart';
import '../../../../flavor_config.dart';
import 'home_dashboard.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  int selected = 2;
  UserDataBloc _userBloc = UserDataBloc();
  List<Widget> pages = [
    ExploreTabView(),
    NotificationsPage(),
    HomeDashBoard(),
    ChatListView(),
    ProfilePage(),
  ];

  @override
  void initState() {
    log("home page router init");
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
      // List all of the app's supported locales here
      supportedLocales: [
        Locale('en', 'US'),
        Locale('sk', 'SK'),
      ],
      localizationsDelegates: [
        // A class which loads the translations from JSON files
        AppLocalizations.delegate,
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        // Built-in localization for text direction LTR/RTL
        GlobalWidgetsLocalizations.delegate,
      ],
      // Returns a locale which will be used by the app
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home: BlocProvider<UserDataBloc>(
        bloc: _userBloc,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                      child: pages[selected],
                      //   child: IndexedStack(
                      //     index: selected,
                      //     children: <Widget>[
                      //       ExploreTabView(),
                      //       NotificationsPage(),
                      //       HomeDashBoard(),
                      //       ChatListView(),
                      //       ProfilePage(),
                      //     ],
                      //   ),
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
