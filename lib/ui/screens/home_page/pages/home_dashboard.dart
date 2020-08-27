import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/timebank_home_page.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_router.dart';
import 'package:sevaexchange/ui/screens/search/pages/search_page.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/project_view/timebank_projects_view.dart';
import 'package:sevaexchange/views/switch_timebank.dart';
import 'package:sevaexchange/views/timebank_content_holder.dart';
import 'package:sevaexchange/views/timebank_modules/timebank_requests.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/timebank_manage_seva.dart';
import 'package:sevaexchange/views/timebanks/timebank_view_latest.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class HomeDashBoard extends StatefulWidget {
  @override
  _HomeDashBoardState createState() => _HomeDashBoardState();
}

class _HomeDashBoardState extends State<HomeDashBoard>
    with TickerProviderStateMixin {
  TimebankModel primaryTimebank;
  HomeDashBoardBloc _homeDashBoardBloc = HomeDashBoardBloc();
  CommunityModel selectedCommunity;
  TimeBankModelSingleton timeBankModelSingleton = TimeBankModelSingleton();
  List<Widget> pages = [];
  bool isAdmin = false;
  int tabLength = 7;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _homeDashBoardBloc.getAllCommunities(SevaCore.of(context).loggedInUser);
    });
  }

  @override
  void dispose() {
    _homeDashBoardBloc.dispose();
    super.dispose();
  }

  void setCurrentCommunity(List<CommunityModel> data) async {
    if (data != null)
      data.forEach((model) {
        if (model.id == SevaCore.of(context).loggedInUser.currentCommunity) {
          selectedCommunity = model;
          SevaCore.of(context).loggedInUser.currentTimebank =
              model.primary_timebank;
          SevaCore.of(context).loggedInUser.associatedWithTimebanks =
              model.timebanks.length;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final _user = BlocProvider.of<UserDataBloc>(context);
    List<String> _tabsNames = [
      S.of(context).timebank,
      S.of(context).feeds,
      S.of(context).projects,
      S.of(context).requests,
      S.of(context).offers,
      S.of(context).about,
      S.of(context).members,
      S.of(context).manage,
    ];

    return BlocProvider(
      bloc: _homeDashBoardBloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          title: StreamBuilder<List<CommunityModel>>(
            stream: _homeDashBoardBloc.communities,
            builder: (context, snapshot) {
              setCurrentCommunity(snapshot.data);
              return snapshot.data != null
                  ? Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).primaryColor,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<CommunityModel>(
                          style: TextStyle(color: Colors.white),
                          focusColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          value: selectedCommunity,
                          onChanged: (v) {
                            if (v.id != selectedCommunity.id) {
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity = v.id;
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentTimebank = v.primary_timebank;
                              _homeDashBoardBloc
                                  .setDefaultCommunity(
                                context: context,
                                community: v,
                              )
                                  .then((_) {
                                SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity = v.id;
                                SevaCore.of(context)
                                    .loggedInUser
                                    .currentTimebank = v.primary_timebank;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SwitchTimebank(),
                                  ),
                                );
                              });
                            }
                          },
                          items: List.generate(
                            snapshot.data.length,
                            (index) => DropdownMenuItem(
                              value: snapshot.data[index],
                              child: Text(
                                snapshot.data[index].name,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text(S.of(context).loading);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Builder(builder: (context) {
                      return BlocProvider(
                        bloc: _user,
                        child: SearchPage(
                          bloc: _homeDashBoardBloc,
                          user: SevaCore.of(context).loggedInUser,
                          timebank: primaryTimebank,
                          community: selectedCommunity,
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<SelectedCommuntityGroup>(
          stream: _homeDashBoardBloc
              .getCurrentGroups(SevaCore.of(context).loggedInUser),
          builder: (context, snapshot) {
            if (snapshot.data == null || !snapshot.hasData) {
              return LoadingIndicator();
            }
            if (snapshot.hasData && snapshot.data != null) {
              snapshot.data.timebanks.forEach(
                (TimebankModel data) {
                  if (data.id ==
                      snapshot.data.currentCommunity.primary_timebank) {
                    primaryTimebank = data;
                    timeBankModelSingleton.model = primaryTimebank;
                  }
                },
              );

              if (primaryTimebank != null &&
                  primaryTimebank.admins
                      .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
                isAdmin = true;
              }
            }
            return DefaultTabController(
              length: isAdmin ? tabLength + 1 : tabLength,
              child: Column(
                children: <Widget>[
                  ShowLimitBadge(),
                  TabBar(
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    // controller: _timebankController,
                    indicatorColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.black,
                    labelColor: Theme.of(context).primaryColor,
                    isScrollable: true,
                    tabs: List.generate(
                      isAdmin ? tabLength + 1 : tabLength,
                      (index) => Tab(
                        text: _tabsNames[index],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        TimebankHomePage(
                          selectedCommuntityGroup: snapshot.data,
                          primaryTimebankModel: primaryTimebank,
                        ),
                        DiscussionList(
                          timebankId: primaryTimebank.id,
                          timebankModel: primaryTimebank,
                        ),
                        TimeBankProjectsView(
                          timebankId: primaryTimebank.id,
                          timebankModel: primaryTimebank,
                        ),
                        RequestsModule.of(
                          timebankId: primaryTimebank.id,
                          timebankModel: primaryTimebank,
                          isFromSettings: false,
                        ),
                        OfferRouter(
                          timebankId: primaryTimebank.id,
                          timebankModel: primaryTimebank,
                        ),
                        TimeBankAboutView.of(
                          timebankModel: primaryTimebank,
                          email: SevaCore.of(context).loggedInUser.email,
                        ),
                        TimebankRequestAdminPage(
                          isUserAdmin: primaryTimebank.admins.contains(
                            SevaCore.of(context).loggedInUser.sevaUserID,
                          ),
                          timebankId: primaryTimebank.id,
                          userEmail: SevaCore.of(context).loggedInUser.email,
                          isCommunity: true,
                          isFromGroup: false,
                        ),
                        ...isAdmin
                            ? [
                                ManageTimebankSeva.of(
                                  timebankModel: primaryTimebank,
                                ),
                              ]
                            : []
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
