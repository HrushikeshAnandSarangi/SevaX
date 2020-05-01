import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/no_group_placeholder.dart';
import 'package:sevaexchange/ui/screens/home_page/widgets/timebank_card.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/covid/covid_sceen.dart';
import 'package:sevaexchange/views/tasks/completed_list.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/tasks/notAccepted_tasks.dart';
import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

import '../../../../flavor_config.dart';

class TimebankHomePage extends StatefulWidget {
  final SelectedCommuntityGroup selectedCommuntityGroup;

  const TimebankHomePage({Key key, this.selectedCommuntityGroup})
      : super(key: key);
  @override
  _TimebankHomePageState createState() => _TimebankHomePageState();
}

class _TimebankHomePageState extends State<TimebankHomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  HomeDashBoardBloc _homeDashBoardBloc;
  TabController controller;
  ScrollController _scrollController;
  bool isTitleVisible = false;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      print(_scrollController.offset);
      if (_scrollController.offset > 260 && !isTitleVisible) {
        isTitleVisible = true;
        setState(() {});
      }
      if (_scrollController.offset < 250 && isTitleVisible) {
        isTitleVisible = false;
        setState(() {});
      }
    });
    _homeDashBoardBloc = BlocProvider.of<HomeDashBoardBloc>(context);
    super.initState();
  }

  @override
  void dispose() {
    _homeDashBoardBloc.dispose();
    controller.dispose();
    super.dispose();
  }

  void navigateToCreateGroup() {
    createEditCommunityBloc
        .updateUserDetails(SevaCore.of(context).loggedInUser);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimebankCreate(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
        ),
      ),
    );
  }

  // void navigateToCreateProjectGroup() {
  //   createEditCommunityBloc
  //       .updateUserDetails(SevaCore.of(context).loggedInUser);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TimeBankProjectsView(
  //         timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final user = BlocProvider.of<UserDataBloc>(context);
    final covidcheck = json.decode(AppConfig.remoteConfig.getString('covid'));
    super.build(context);
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            child: SliverAppBar(
              title: Text(
                "Your Tasks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isTitleVisible ? Colors.black : Colors.transparent,
                ),
              ),
              titleSpacing: 20,
              backgroundColor: Colors.white,
              pinned: true,
              expandedHeight: covidcheck['show'] ? 480.0 : 370,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    covidcheck['show']
                        ? Container(
                            alignment: Alignment.center,
                            height: 90.0,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.0),
                              gradient: LinearGradient(
                                colors: [Colors.white12, Colors.white12],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[200],
                                ),
                              ],
                            ),
                            child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MyThreeOptions()));
                                },
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "COVID-19 Volunteer",
                                            maxLines: 2,
                                            overflow: TextOverflow.clip,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title
                                                .apply(
                                                    fontWeightDelta: 2,
                                                    color: Colors.black54),
                                          ),
                                        ),
                                        SizedBox(width: 15.0),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.black54,
                                          ),
                                          onTap: () {},
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 5.0),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "Help organisations and communities around you. Get information on COVID-19",
                                            textAlign: TextAlign.left,
                                            maxLines: 2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle
                                                .apply(color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )))
                        : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 110.0,
                          height: 50.0,
                          buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                          child: Stack(
                            fit: StackFit.loose,
                            children: [
                              FlatButton(
                                onPressed: () {},
                                child: Text(
                                  'Your Groups',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                // will be positioned in the top right of the container
                                top: -10,
                                right: -10,
                                // child: IconButton(
                                //   icon: Image.asset(
                                //     'lib/assets/images/info.png',
                                //     color:
                                //         FlavorConfig.values.theme.primaryColor,
                                //     height: 16,
                                //     width: 16,
                                //   ),
                                //   onPressed: () {
                                //     customInfoDialog(context);
                                //     // showInfoOfConcept(
                                //     //     dialogTitle:
                                //     //         infoDetails['groupsInfo'] != null
                                //     //             ? infoDetails['groupsInfo'] ??
                                //     //                 description
                                //     //             : description,
                                //     //     mContext: context);
                                //   },
                                //   tooltip: infoDetails['groupsInfo'] != null
                                //       ? infoDetails['groupsInfo'] ??
                                //           description
                                //       : description,
                                // ),
                                child: infoButton(
                                  context: context,
                                  key: GlobalKey(),
                                  type: InfoType.GROUPS,
                                  // text:
                                  //     infoDetails['groupsInfo'] ?? description,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle),
                          color: FlavorConfig.values.theme.primaryColor,
                          onPressed: navigateToCreateGroup,
                        ),
                        Spacer(),
                        IconButton(
                          icon: Image.asset(
                            'lib/assets/images/help.png',
                          ),
                          color: FlavorConfig.values.theme.primaryColor,
                          iconSize: 24,
                          onPressed: showGroupsWebPage,
                        ),
                      ],
                    ),
                    Container(
                      height: 210,
                      child: getTimebanks(user),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 10,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your Tasks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              forceElevated: false,
              bottom: TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(
                    child: Text('Pending '),
                  ),
                  Tab(
                    child: Text('Not Accepted '),
                  ),
                  Tab(
                    child: Text('Completed '),
                  ),
                ],
                controller: controller,
                isScrollable: false,
                unselectedLabelColor: Colors.black,
              ),
            ),
          ),
          //     SliverPersistentHeader(
          //       delegate: _SliverAppBarDelegate(
          //         TabBar(
          //           labelColor: Theme.of(context).primaryColor,
          //           unselectedLabelStyle: TextStyle(color: Colors.grey),
          //           labelStyle: TextStyle(fontWeight: FontWeight.bold),
          //           indicatorColor: Theme.of(context).primaryColor,
          //           tabs: [
          //             Tab(
          //               child: Text('Pending '),
          //             ),
          //             Tab(
          //               child: Text('Not Accepted '),
          //             ),
          //             Tab(
          //               child: Text('Completed '),
          //             ),
          //           ],
          //           controller: controller,
          //           isScrollable: false,
          //           unselectedLabelColor: Colors.black,
          //         ),
          //       ),
          //       pinned: true,
          //     ),
        ];
      },
      body: SafeArea(
        minimum: EdgeInsets.only(top: 104),
        child: TabBarView(
          controller: controller,
          children: <Widget>[
            MyTasksList(),
            NotAcceptedTaskList(),
            CompletedList()
          ],
        ),
      ),
    );
  }

  Widget getTimebanks(UserDataBloc user) {
//    print("length ==> ${widget.selectedCommuntityGroup.timebanks.length}");
    if (widget.selectedCommuntityGroup.timebanks.length <= 1) {
      return NoGroupPlaceHolder(navigateToCreateGroup: navigateToCreateGroup);
    }
    return FadeAnimation(
      0,
      Container(
        height: MediaQuery.of(context).size.height * 0.25,
        child: ListView.builder(
          itemCount: widget.selectedCommuntityGroup.timebanks.length,
          itemBuilder: (context, index) {
            if (widget.selectedCommuntityGroup.timebanks[index].id !=
                widget.selectedCommuntityGroup.currentCommunity
                    .primary_timebank) {
              return TimeBankCard(
                user: user,
                timebank: widget.selectedCommuntityGroup.timebanks[index],
              );
            }
            return Container();
          },
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 12),
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  void showGroupsWebPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    navigateToWebView(
      aboutMode: AboutMode(
          title: "Groups Help", urlToHit: dynamicLinks['groupsInfoLink']),
      context: context,
    );
  }

  void navigateToWebView({
    BuildContext context,
    AboutMode aboutMode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevaWebView(aboutMode),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
