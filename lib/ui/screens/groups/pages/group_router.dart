import 'dart:js';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/utils.dart';

enum UserType { GROUP_ADMIN, GROUP_MEMBER, NOT_MEMBER }

class GroupRouter extends StatefulWidget {
  final TimebankModel timebankModel;
  final String userId;

  const GroupRouter(
      {Key? key, required this.timebankModel, required this.userId})
      : super(key: key);
  @override
  _GroupRouterState createState() => _GroupRouterState();
}

class _GroupRouterState extends State<GroupRouter>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  UserType? userType;

  @override
  void initState() {
    userType = checkUserRole(
      userId: widget.userId,
      timeBankModel: widget.timebankModel,
    );
    tabController = TabController(length: getTabLength(userType!), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TabBar(
            controller: tabController,
            labelPadding: EdgeInsets.symmetric(horizontal: 10),
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            unselectedLabelColor: Colors.black,
            isScrollable: true,
            tabs: [
              ...userType != UserType.NOT_MEMBER
                  ? [
                      Tab(
                        text: S.of(context).feeds,
                      ),
                      Tab(
                        text: S.of(context).projects,
                      ),
                      Tab(
                        text: S.of(context).requests,
                      ),
                      Tab(
                        text: S.of(context).offers,
                      )
                    ]
                  : [],
              Tab(
                text: S.of(context).about,
              ),
              Tab(
                text: S.of(context).members,
              ),
              ...userType == UserType.GROUP_ADMIN
                  ? [
                      Tab(
                        text: S.of(context).manage,
                      ),
                      Container(
                        width: 20,
                      ),
                      Container(
                        width: 20,
                      ),
                    ]
                  : [],
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                ...userType != UserType.NOT_MEMBER
                    ? [
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                        Container(color: Colors.red),
                      ]
                    : [],
                Container(color: Colors.green),
                Container(color: Colors.green),
                ...userType == UserType.GROUP_ADMIN
                    ? [
                        Container(color: Colors.purple),
                        Container(width: 20, color: Colors.purple),
                        Container(width: 20, color: Colors.purple),
                      ]
                    : [],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

UserType checkUserRole({
  String? userId,
  TimebankModel? timeBankModel,
}) {
  if (isAccessAvailable(timeBankModel!, userId!)) {
    return UserType.GROUP_ADMIN;
  } else if (timeBankModel.members.contains(userId)) {
    return UserType.GROUP_MEMBER;
  } else {
    return UserType.NOT_MEMBER;
  }
}

int getTabLength(UserType userType) {
  if (userType == UserType.GROUP_ADMIN) {
    return 9;
  } else if (userType == UserType.GROUP_MEMBER) {
    return 6;
  } else {
    return 2;
  }
}
