import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/reported_members/pages/reported_member_page.dart';

class ReportedMemberNavigatorWidget extends StatefulWidget {
  final bool? isTimebankReport;
  final TimebankModel? timebankModel;
  final String? communityId;

  const ReportedMemberNavigatorWidget({
    Key? key,
    this.isTimebankReport,
    this.timebankModel,
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
          offstage: !((snapshot.data as bool?) ?? false),
          child: Container(
            color: Color(0xFFFFAFAFA),
            child: ListTile(
              title: Text(S.of(context).reported_users),
              subtitle: Text(S.of(context).reported_member_click_to_view),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black),
              onTap: () {
                Navigator.of(context)
                    .push(
                      ReportedMembersPage.route(
                        timebankModel: widget.timebankModel!,
                        communityId: widget.communityId!,
                        isFromTimebank: widget.isTimebankReport!,
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
    QuerySnapshot snapshot = await CollectionRef.reportedUsersList
        .where(
          widget.isTimebankReport! ? "communityId" : "timebankIds",
          isEqualTo: widget.isTimebankReport! ? widget.communityId : null,
          arrayContains:
              widget.isTimebankReport! ? null : widget.timebankModel!.id,
        )
        .get();
    if (snapshot.docs.length > 0) {
      flag = true;
    } else {
      flag = false;
    }
    return flag;
  }
}
