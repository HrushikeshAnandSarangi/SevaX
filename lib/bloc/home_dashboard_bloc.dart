import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

class HomeDashBoardBloc extends BlocBase {
  final _communities = PublishSubject<List<CommunityModel>>();
  final _selectedCommunity = PublishSubject<CommunityModel>();

  Stream<CommunityModel> get selectedCommunity => _selectedCommunity.stream;
  Stream<List<CommunityModel>> get communities => _communities.stream;

  getAllCommunities(UserModel user) async {
    List<CommunityModel> c = [];
    if (user.communities != null) {
      user.communities.forEach((id) async {
        var value = await Firestore.instance
            .collection("communities")
            .document(id)
            .get();
        c.add(CommunityModel(value.data));
        if (id == user.currentCommunity) {
          _selectedCommunity.add(CommunityModel(value.data));
        }
        _communities.add(c);
      });
    } else {
      _communities.addError('No Communities');
    }
  }

  void setDefaultCommunity(
      {CommunityModel community, BuildContext context, oldCommunityId}) {
    Firestore.instance
        .collection('users')
        .document(SevaCore.of(context).loggedInUser.email)
        .updateData({
      "currentCommunity": SevaCore.of(context).loggedInUser.currentCommunity
    }).then((onValue) {
      SevaCore.of(context).loggedInUser.currentCommunity = community.id;
      _selectedCommunity.add(community);
    }).catchError((e) {
      SevaCore.of(context).loggedInUser.currentCommunity = oldCommunityId;
    });
  }

  void getPrimaryTimebank() {}

  void dispose() {
    _communities.close();
    _selectedCommunity.close();
  }
}
