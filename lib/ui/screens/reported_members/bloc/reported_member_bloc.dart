import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/reported_members_model.dart';

class ReportedMembersBloc {
  final _reportedMembers = BehaviorSubject<List<ReportedMembersModel>>();

  Stream<List<ReportedMembersModel>> get reportedMembers =>
      _reportedMembers.stream;

  void fetchReportedMembers(String timebankId) {
    log("fetching members for timebank $timebankId");
    Firestore.instance
        .collection("reported_users_list")
        .where("timebankId", isEqualTo: timebankId)
        .snapshots()
        .listen((QuerySnapshot event) {
      List<ReportedMembersModel> members = [];
      event.documents.forEach((DocumentSnapshot element) {
        ReportedMembersModel member =
            ReportedMembersModel.fromMap(element.data);
        members.add(member);
        log(member.reportedId);
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
