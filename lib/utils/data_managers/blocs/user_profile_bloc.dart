import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/profile.dart';

class UserProfileBloc {
  final _communities = BehaviorSubject<List<Widget>>();

  Stream<List<Widget>> get communities => _communities.stream;

  void getAllCommunities(context, UserModel userModel) async {
    FirestoreManager.getUserForIdStream(
      sevaUserId: userModel.sevaUserID,
    ).listen((userModel) {
      if (userModel.communities != null) {
        List<Widget> community = [];
        userModel.communities.forEach((id) async {
          var value = await Firestore.instance
              .collection("communities")
              .document(id)
              .get();
          print('${value.documentID}   ${userModel.currentCommunity}');
          community.add(
            CommunityCard(
              selected: userModel.currentCommunity == value.documentID,
              community: CommunityModel(value.data),
              onTap: () =>
                  setDefaultCommunity(userModel.email, value.documentID),
            ),
          );
          _communities.add(community);
        });
      } else {
        _communities.addError('No Communities');
      }
    });
  }

  void setDefaultCommunity(String email, String communityId) {
    Firestore.instance
        .collection('users')
        .document(email)
        .updateData({"currentCommunity": communityId}).then((onValue) {
      //TODO navigate to community page
      // print(onValue.data);
    });
  }

  void dispose() {
    _communities.close();
  }
}
