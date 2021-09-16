import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class UserProfileBloc {
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _communityLoaded = BehaviorSubject<bool>.seeded(false);

  UserProfileBloc();

  Stream<List<CommunityModel>> get communities => _communities.stream;
  Stream<bool> get communityLoaded => _communityLoaded.stream;

  StreamSink<bool> get changeCommunity => _communityLoaded.sink;

  void getAllCommunities(context, UserModel userModel) async {
    FirestoreManager.getUserForIdStream(
      sevaUserId: userModel?.sevaUserID,
    ).listen((userModel) {
      CollectionRef.communities
          .where("members", arrayContains: userModel.sevaUserID)
          .get()
          .then((results) {
        List<CommunityModel> models = [];
        results.docs.forEach((element) {
          models.add(CommunityModel(element.data()));
        });
        models.sort((a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ));

        if (!_communities.isClosed) _communities.add(models);
        Future.delayed(
          Duration(milliseconds: 300),
          () {
            if (!_communityLoaded.isClosed) _communityLoaded.add(true);
          },
        );
      });
    });
    // Set<String> communitiesList = Set.from(userModel?.communities ?? []);
    // if (userModel?.sevaUserID != null)
    //   FirestoreManager.getUserForIdStream(
    //     sevaUserId: userModel.sevaUserID,
    //   ).listen((userModel) {
    //     if (communitiesList != null) {
    //       var futures = communitiesList.map(
    //         (e) async => await CollectionRef.communities.doc(e).get(),
    //       );
    //       Future.wait(futures).then((value) {
    //         var models = value
    //             .map<CommunityModel>(
    //               (e) => CommunityModel(e.data()),
    //             )
    //             .toList();
    //         models.sort(
    //           (a, b) => a.name.toLowerCase().compareTo(
    //                 b.name.toLowerCase(),
    //               ),
    //         );
    //         if (!_communities.isClosed) _communities.add(models);
    //       });
    //     } else {
    //       if (!_communities.isClosed) _communities.addError('No Communities');
    //     }
    //     Future.delayed(
    //       Duration(milliseconds: 300),
    //       () {
    //         if (!_communityLoaded.isClosed) _communityLoaded.add(true);
    //       },
    //     );
    //   });
  }

  void setDefaultCommunity(
      String email, CommunityModel community, BuildContext context) {
    _communityLoaded.add(false);

    if (community != null)
      SevaCore.of(context).loggedInUser.currentTimebank =
          community.primary_timebank;
    SevaCore.of(context).loggedInUser.associatedWithTimebanks =
        community.timebanks.length;
    CollectionRef.users.doc(email).update({
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
