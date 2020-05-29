import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_page.dart';

class ReportedMemberNavigatorWidget extends StatefulWidget {
  final bool isTimebankReport;
  final String timebankId;
  final String communityId;

  const ReportedMemberNavigatorWidget({
    Key key,
    this.isTimebankReport,
    this.timebankId,
    this.communityId,
  }) : super(key: key);

  @override
  _ReportedMemberNavigatorWidgetState createState() =>
      _ReportedMemberNavigatorWidgetState();
}

class _ReportedMemberNavigatorWidgetState
    extends State<ReportedMemberNavigatorWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isAnyMemberReported(),
      builder: (context, snapshot) {
        log("result--> ${snapshot.data}");
        return Offstage(
          offstage: !(snapshot.data ?? false),
          child: Container(
            color: Color(0xFFFFAFAFA),
            child: ListTile(
              title: Text("Reported Users"),
              subtitle:
                  Text("Click here to view reported users of this timebank"),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black),
              onTap: () {
                Navigator.of(context)
                    .push(
                      ReportedMembersPage.route(
                        timebankId: widget.timebankId,
                        communityId: widget.communityId,
                        isFromTimebank: widget.isTimebankReport,
                      ),
                    )
                    .then((_) => setState(() {}));
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> isAnyMemberReported() async {
    bool flag = false;
    QuerySnapshot snapshot = await Firestore.instance
        .collection("reported_users_list")
        .where(
          widget.isTimebankReport ? "communityId" : "timebankIds",
          isEqualTo: widget.isTimebankReport ? widget.communityId : null,
          arrayContains: widget.isTimebankReport ? null : widget.timebankId,
        )
        .getDocuments();
    if (snapshot.documents.length > 0) {
      flag = true;
    } else {
      flag = false;
    }
    return flag;
  }
}
