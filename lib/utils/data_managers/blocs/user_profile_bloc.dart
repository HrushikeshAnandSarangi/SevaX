import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profile.dart';
import 'package:sevaexchange/views/switch_timebank.dart';

class UserProfileBloc {
  final BuildContext context;
  final _communities = BehaviorSubject<List<Widget>>();
  final _communityLoaded = BehaviorSubject<bool>.seeded(false);

  UserProfileBloc(this.context);

  Stream<List<Widget>> get communities => _communities.stream;
  Stream<bool> get communityLoaded => _communityLoaded.stream;

  StreamSink<bool> get changeCommunity => _communityLoaded.sink;

  void getAllCommunities(context, UserModel userModel) async {
    Set<String> communitiesList = Set.from(userModel?.communities ?? []);

//    if (await communitiesList.contains(FlavorConfig.values.timebankId)) {
//      await communitiesList.remove(FlavorConfig.values.timebankId);
//    }

    if (userModel?.sevaUserID != null)
      FirestoreManager.getUserForIdStream(
        sevaUserId: userModel.sevaUserID,
      ).listen((userModel) {
        if (communitiesList != null) {
          List<Widget> community = [];
          communitiesList.forEach((id) async {
            var value = await Firestore.instance
                .collection("communities")
                .document(id)
                .get();
            community.add(
              CommunityCard(
                selected: userModel.currentCommunity == value.documentID,
                community: CommunityModel(value.data),
                onTap: () {
                  setDefaultCommunity(
                      userModel.email, CommunityModel(value.data), context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SwitchTimebank(),
                    ),
                  );
                },
              ),
            );
            if (!_communities.isClosed) _communities.add(community);
          });
        } else {
          if (!_communities.isClosed) _communities.addError('No Communities');
        }
        Future.delayed(
          Duration(milliseconds: 300),
          () {
            if (!_communityLoaded.isClosed) _communityLoaded.add(true);
          },
        );
      });
  }

  void setDefaultCommunity(
      String email, CommunityModel community, BuildContext context) {
    _communityLoaded.add(false);

    if (community != null)
      SevaCore.of(context).loggedInUser.currentTimebank =
          community.primary_timebank;
    SevaCore.of(context).loggedInUser.associatedWithTimebanks =
        community.timebanks.length;
    Firestore.instance.collection('users').document(email).updateData({
      "currentCommunity": community.id,
      "currentTimebank": community.primary_timebank
    }).then((onValue) {
      //TODO navigate to community page
      SevaCore.of(context).loggedInUser.currentCommunity = community.id;
    });
  }

  void dispose() {
    _communities.close();
    _communityLoaded.close();
  }
}
