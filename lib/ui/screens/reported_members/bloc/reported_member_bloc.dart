import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/reported_members_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

class ReportedMembersBloc {
  final _reportedMembers = BehaviorSubject<List<ReportedMembersModel>>();

  Stream<List<ReportedMembersModel>> get reportedMembers =>
      _reportedMembers.stream;

  void fetchReportedMembers(
      String timebankId, String communityId, bool isFromTimebank) {
    log("fetching members for Seva Community $timebankId");
    Query query = isFromTimebank
        ? CollectionRef.reportedUsersList.where(
            "communityId",
            isEqualTo: communityId,
          )
        : CollectionRef.reportedUsersList.where(
            "timebankIds",
            arrayContains: timebankId,
          );

    query.snapshots().listen((QuerySnapshot event) {
      List<ReportedMembersModel> members = [];
      event.docs.forEach((DocumentSnapshot element) {
        ReportedMembersModel member = ReportedMembersModel.fromMap(
            element.data() as Map<String, dynamic>);
        members.add(member);
        log(member.reportedId!);
      });
      if (!_reportedMembers.isClosed) {
        _reportedMembers.add(members);
      }
    });
  }

  void dispose() {
    _reportedMembers.close();
  }
}
