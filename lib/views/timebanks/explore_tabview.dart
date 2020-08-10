import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/join_sub_timebank.dart';
import 'package:shimmer/shimmer.dart';

class ExploreTabView extends StatefulWidget {
  ExploreTabView();

  @override
  _ExploreTabViewState createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends State<ExploreTabView> {
//  CommunityModel communityModel = CommunityModel({});
  @override
  void initState() {
    log("exlpore page init");
    // TODO: implement initState
    super.initState();
//    getModelData();
    setState(() {});
  }

//  void getModelData() async {
//    Future.delayed(Duration.zero, () {
//      FirestoreManager.getCommunityDetailsByCommunityId(
//          communityId: SevaCore.of(context).loggedInUser.currentCommunity)
//          .then((onValue) {
//        communityModel = onValue;
//        print("widget.communityPrimaryTimebankId is --- ${communityModel.id} --- ${communityModel.primary_timebank}");
//      });
//    });
//  }

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
            S.of(context).bottom_nav_explore,
            style: TextStyle(fontSize: 18, fontFamily: 'Europa'),
          ),
        ),
        body: FutureBuilder<CommunityModel>(
            future: FirestoreManager.getCommunityDetailsByCommunityId(
                communityId:
                    SevaCore.of(context).loggedInUser.currentCommunity),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              CommunityModel communityModel = snapshot.data;
              return Column(
                children: <Widget>[
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    unselectedLabelColor: Colors.black,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        text: S.of(context).find_timebanks,
                      ),
                      Tab(
                        text:
                            "${S.of(context).groups_within} ${snapshot.data.name ?? "Timebank"}  ",
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
                          communityPrimaryTimebankId:
                              communityModel.primary_timebank,
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }

  Widget get shimmerWidget {
    return Shimmer.fromColors(
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey.withAlpha(40),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
            title: Container(
              color: Colors.grey.withAlpha(90),
              height: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(90),
            ),
            subtitle: Container(
              color: Colors.grey.withAlpha(90),
              height: 8,
            )),
      ),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
    );
  }
}
