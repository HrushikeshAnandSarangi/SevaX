import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/ui/screens/reported_members/widgets/report_info_card.dart';

enum ACTIONS { REMOVE, MESSAGE }

class ReportedMemberInfo extends StatelessWidget {
  final ReportedMembersModel model;

  const ReportedMemberInfo({Key key, this.model}) : super(key: key);

  static Route<dynamic> route({ReportedMembersModel model}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => ReportedMemberInfo(
        model: model,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report of ${model.reportedUserName}",
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              log(value.toString());
            },
            itemBuilder: (context) => <PopupMenuItem>[
              PopupMenuItem(
                child: Text("Message"),
                value: ACTIONS.MESSAGE,
              ),
              PopupMenuItem(
                child: Text("Remove"),
                value: ACTIONS.REMOVE,
              ),
            ],
          ),
        ],
      ),
      body: Container(
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          itemCount: model.reports.length,
          itemBuilder: (context, index) {
            return ReportInfoCard(
              report: model.reports[index],
            );
          },
          separatorBuilder: (_, __) {
            return Divider(
              thickness: 1,
            );
          },
        ),
      ),
    );
  }
}
