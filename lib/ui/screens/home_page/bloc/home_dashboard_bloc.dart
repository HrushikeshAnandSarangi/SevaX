import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';

class HomeDashBoardBloc extends BlocBase {
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _selectedCommunity = BehaviorSubject<CommunityModel>();

  Stream<SelectedCommuntityGroup> getCurrentGroups(UserModel user) {
    return CombineLatestStream.combine2(
      FirestoreManager.getTimebanksForUserStream(
        userId: user.sevaUserID ?? '',
        communityId: user.currentCommunity ?? '',
      ),
      _selectedCommunity.debounceTime(Duration.zero),
      (x, y) => SelectedCommuntityGroup(
          timebanks: x as List<TimebankModel>,
          currentCommunity: y as CommunityModel),
    );
  }

  Stream<CommunityModel> get selectedCommunityStream =>
      _selectedCommunity.stream;

  CommunityModel get selectedCommunityModel => _selectedCommunity.value;

  Stream<List<CommunityModel>> get communities => _communities.stream;

  void getAllCommunities(UserModel user) async {
    Set<String> communitiesList = Set.from(user.communities ?? []);

//    if (await communitiesList.contains(FlavorConfig.values.timebankId)) {
//      await communitiesList.remove(FlavorConfig.values.timebankId);
//    }
    List<CommunityModel> c = [];
    if (communitiesList != null) {
      communitiesList.forEach((id) async {
        var value = await CollectionRef.communities.doc(id).get();
        if (value.exists) {
          c.add(CommunityModel(value.data() as Map<String, dynamic>));
          if (id == user.currentCommunity) {
            _selectedCommunity.drain();
            _selectedCommunity
                .add(CommunityModel(value.data() as Map<String, dynamic>));
          }
          c.sort(
            (a, b) => a.name.toLowerCase().compareTo(
                  b.name.toLowerCase(),
                ),
          );
          if (!_communities.isClosed) _communities.add(c);
        }
      });
    } else {
      _communities.addError('No Communities');
    }
  }

  Future<bool> setDefaultCommunity(
      {required CommunityModel community, required BuildContext context}) {
    CollectionRef.users.doc(SevaCore.of(context).loggedInUser.email).update({
      "currentCommunity": SevaCore.of(context).loggedInUser.currentCommunity,
      "currentTimebank": community.primary_timebank
    });
    return Future.value(true);
  }

  // void getPrimaryTimebank() {}

  void dispose() {
    _communities.close();
    _selectedCommunity.close();
  }
}

class SelectedCommuntityGroup {
  final List<TimebankModel> timebanks;
  final CommunityModel currentCommunity;

  SelectedCommuntityGroup(
      {required this.timebanks, required this.currentCommunity});
}
