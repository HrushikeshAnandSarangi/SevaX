import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/timebank_model.dart';
import 'package:sevaexchange/models/user_model.dart';

class AddMembersBloc {
  HashSet selectedMembers = HashSet<String>();
  final _members = BehaviorSubject<List<UserModel>>();

  Stream<List<UserModel>> get members => _members.stream;

  void getCommunityMembersExcludingTimebankMembers(
      String communityId, String timebankId) {
    CombineLatestStream.combine2(
        Firestore.instance
            .collection('users')
            .where('communities', arrayContains: communityId)
            .snapshots(),
        Firestore.instance
            .collection('timebanknew')
            .document(timebankId)
            .snapshots(),
        (u, t) => AddMemberModel(u, t)).listen((AddMemberModel model) {
      TimebankModel timebank = TimebankModel(model.timebank.data);
      HashSet timebankMembers = HashSet.from(timebank.members);
      List<UserModel> users = [];
      model.users.documents.forEach((DocumentSnapshot snap) {
        UserModel user = UserModel.fromMap(snap.data);
        if (!timebankMembers.contains(user.sevaUserID)) users.add(user);
      });
      _members.add(users);
    });
  }

  void getCommunityMembers(String communityId) {
    Firestore.instance
        .collection('users')
        .where('communities', arrayContains: communityId)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<UserModel> users = [];
      snapshot.documents.forEach((DocumentSnapshot snap) {
        UserModel user = UserModel.fromMap(snap.data);
        users.add(user);
      });
      _members.add(users);
    });
  }

  void selectMember(String userId) {
    if (selectedMembers.contains(userId)) {
      selectedMembers.remove(userId);
    } else {
      selectedMembers.add(userId);
    }
    print(selectedMembers);
  }

  bool isMemberSelected(String userId) {
    return selectedMembers.contains(userId);
  }

  void addMemberToTimebank(String communityId, String timebankId) {
    if (selectedMembers.isNotEmpty) {
      Firestore.instance
          .collection("timebanknew")
          .document(timebankId)
          .updateData(
        {
          "members": FieldValue.arrayUnion(
            selectedMembers.toList(),
          ),
        },
      );
    }
  }

  void dispose() {
    _members.close();
  }
}

class AddMemberModel {
  final QuerySnapshot users;
  final DocumentSnapshot timebank;
  AddMemberModel(this.users, this.timebank);
}
