import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/localization/applanguage.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/bottom_nav_bar.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/message/pages/message_page_router.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/combined_notification_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/splash_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/customise_community/theme_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../../../../flavor_config.dart';
import 'home_dashboard.dart';

class HomePageRouter extends StatefulWidget {
  // final UserModel userModel;

  const HomePageRouter({
    Key key,
    // @required this.userModel
  }) : super(key: key);

  @override
  _BottomNavBarRouterState createState() => _BottomNavBarRouterState();
}

class _BottomNavBarRouterState extends State<HomePageRouter> {
  final AppLanguage appLanguage = AppLanguage();
  int selected = 2;
  UserDataBloc _userBloc = UserDataBloc();
  MessageBloc _messageBloc = MessageBloc();
  NotificationsBloc _notificationsBloc = NotificationsBloc();
  List<Widget> pages = [
    ExplorePage(
      isUserSignedIn: true,
    ),
    // ExploreTabView(),
    CombinedNotificationsPage(),
    HomeDashBoard(),
    MessagePageRouter(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    setState(() {});

    Future.delayed(
      Duration.zero,
      () {
        _userBloc.getData(
          email: SevaCore.of(context).loggedInUser.email,
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        );
        Provider.of<HomePageBaseBloc>(context, listen: false)
            .init(SevaCore.of(context).loggedInUser);
        _userBloc.userStream.listen((UserModel user) async {
          Provider.of<MembersBloc>(context, listen: false)
              .init(user.currentCommunity);

          _notificationsBloc.init(
            user.email,
            user.sevaUserID,
            user.currentCommunity,
          );

          // var membersList =
          //     await Provider.of<MembersBloc>(context, listen: false)
          //         .members
          //         .first;

          _messageBloc.fetchAllMessage(
            user.currentCommunity,
            user,
            // membersList,
          );
          CommunityModel communityModel =
              await FirestoreManager.getCommunityDetailsByCommunityId(
                  communityId: user.currentCommunity);
          Provider.of<ThemeBloc>(context, listen: false).changeColor(HexColor(
              communityModel.theme_color == ''
                  ? '766FE0'
                  : communityModel.theme_color));
          logger.e(communityModel.toString());
        });
      },
    );
  }

  @override
  void dispose() {
    _userBloc.dispose();
    _messageBloc.dispose();
    super.dispose();
    _notificationsBloc.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: ChangeNotifierProvider<AppLanguage>(
        create: (_) => appLanguage,
        child: Consumer<AppLanguage>(
          builder: (context, model, child) {
            return StreamBuilder<Color>(
                initialData: Color(0xFF766FE0),
                stream: Provider.of<ThemeBloc>(context).color,
                builder: (context, snapshot) {
                  logger.e("Here is the color " + snapshot.data.toString());
                  return MaterialApp(
                    builder: (context, child) {
                      return GestureDetector(
                        child: child,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                    locale: model.appLocal,
                    supportedLocales: S.delegate.supportedLocales,
                    localizationsDelegates: [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    title: AppConfig.appName,
                    debugShowCheckedModeBanner: false,
                    theme: FlavorConfig.values.theme.copyWith(
                        primaryColor: snapshot.data,
                        buttonTheme:
                            ButtonThemeData(buttonColor: snapshot.data)),
                    home: BlocProvider<UserDataBloc>(
                      bloc: _userBloc,
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        body: StreamBuilder(
                          stream: CombineLatestStream.combine2(
                              _userBloc.userStream,
                              _userBloc.comunityStream,
                              (u, c) => true),
                          builder: (context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              UserModel loggedInUser = _userBloc.user;
                              loggedInUser.currentTimebank =
                                  _userBloc.community.primary_timebank;
                              loggedInUser.associatedWithTimebanks =
                                  _userBloc.user.communities.length;

                              SevaCore.of(context).loggedInUser = loggedInUser;

                              if (_userBloc.user.communities == null ||
                                  _userBloc.user.communities.isEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => SplashView()),
                                      ((Route<dynamic> route) => false));
                                });
                              }
                              return Stack(
                                children: <Widget>[
                                  BlocProvider<NotificationsBloc>(
                                    bloc: _notificationsBloc,
                                    child: BlocProvider<MessageBloc>(
                                      bloc: _messageBloc,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height -
                                                65,
                                        child: pages[selected],
                                      ),
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
                                      bloc: _notificationsBloc,
                                      child: BlocProvider<MessageBloc>(
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
                                  ),
                                ],
                              );
                            } else {
                              return LoadingIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
