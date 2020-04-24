import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';

class ExploreTabView extends StatefulWidget {
  ExploreTabView();

  @override
  _ExploreTabViewState createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
  CommunityModel communityModel = CommunityModel({});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getModelData();
    setState(() {});
  }

  void getModelData() async {
    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: SevaCore.of(context).loggedInUser.currentCommunity)
          .then((onValue) {
        communityModel = onValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final _bloc = BlocProvider.of<UserDataBloc>(context);
    // print("in explore ==> ${_bloc.user.email}");
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                  text: "Groups within ${communityModel.name ?? "Timebank"}",
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
                    communityId: communityModel.id,
                    communityPrimaryTimebankId: communityModel.primary_timebank,
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
