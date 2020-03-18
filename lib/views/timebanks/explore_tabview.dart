import 'package:flutter/material.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';

class ExploreTabView extends StatefulWidget {
  @override
  _ExploreTabViewState createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            "Explore",
            style: TextStyle(fontSize: 18, fontFamily: 'Europa'),
          ),
        ),
        body: Column(
          children: <Widget>[
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: Colors.black,
              isScrollable: true,
              tabs: [
                Tab(
                  text: "Find Timebanks",
                ),
                Tab(
                  text: "Explore Groups",
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  FindCommunitiesView(
                    keepOnBackPress: true,
                    loggedInUser: SevaCore.of(context).loggedInUser,
                    showBackBtn: true,
                    isFromHome: true,
                  ),
                  JoinSubTimeBankView(
                    isFromDash: true,
                    loggedInUserModel: SevaCore.of(context).loggedInUser,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
