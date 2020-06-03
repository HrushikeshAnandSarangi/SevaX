import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/internationalization/applanguage.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/message_page_router.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notifications_page.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/explore_tabview.dart';

import '../../../../flavor_config.dart';
import 'home_dashboard.dart';

class HomePageRouter extends StatefulWidget {
  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  final AppLanguage appLanguage = AppLanguage();
  int selected = 2;
  UserDataBloc _userBloc = UserDataBloc();
  MessageBloc _messageBloc = MessageBloc();
  List<Widget> pages = [
    ExploreTabView(),
    NotificationsPage(),
    HomeDashBoard(),
    MessagePageRouter(),
    // ChatListView(),
    ProfilePage(),
  ];

  @override
  void initState() {
    log("home page router init");
    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        _userBloc.getData(
          email: SevaCore.of(context).loggedInUser.email,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        );
        _messageBloc.fetchAllMessage(
          SevaCore.of(context).loggedInUser.currentCommunity,
          SevaCore.of(context).loggedInUser.sevaUserID,
        );
      },
    );
  }

  @override
  void dispose() {
    _userBloc.dispose();
    _messageBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => appLanguage,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          return MaterialApp(
            locale: model.appLocal,
            supportedLocales: [
              Locale('en', 'US'),
              Locale('pt', 'PT'),
              Locale('es', 'ES'),
              Locale('fr', 'FR'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: FlavorConfig.values.theme,
            home: BlocProvider<UserDataBloc>(
              bloc: _userBloc,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                body: StreamBuilder(
                  // stream: _userBloc.getUser(SevaCore.of(context).loggedInUser.email),
                  stream: CombineLatestStream.combine2(_userBloc.userStream,
                      _userBloc.comunityStream, (u, c) => true),
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      SevaCore.of(context).loggedInUser = _userBloc.user;
                      if (_userBloc.user.communities == null ||
                          _userBloc.user.communities.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => SplashView()),
                              ((Route<dynamic> route) => false));
                        });
                      }
                      return Stack(
                        children: <Widget>[
                          BlocProvider<MessageBloc>(
                            bloc: _messageBloc,
                            child: Container(
                              height: MediaQuery.of(context).size.height - 65,
                              child: pages[selected],
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
                            child: BlocProvider(
                              bloc: _messageBloc,
                              child: CustomBottomNavigationBar(
                                selected: selected,
                                onChanged: (index) {
                                  selected = index;
                                  setState(() {});
                                },
                              ),
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
        },
      ),
    );
  }
}
