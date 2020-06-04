import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class UserDataBloc extends BlocBase {
  final _user = BehaviorSubject<UserModel>();
  final _community = BehaviorSubject<CommunityModel>();

  // UserDataBloc({String email, String communityId}) {
  //   getData(email: email, communityId: communityId);
  // }

  Stream<UserModel> get userStream => _user.stream;
  Stream<CommunityModel> get comunityStream => _community.stream;

  StreamSink<UserModel> get updateUser => _user.sink;
  StreamSink<CommunityModel> get updateCommunity => _community.sink;

  UserModel get user => _user.value;
  CommunityModel get community => _community.value;

  Stream<DocumentSnapshot> getUser(String email) {
    return Firestore.instance.collection("users").document(email).snapshots();
  }

  void getData({String email, String communityId}) {
    if (!_user.isClosed && !_community.isClosed)
      CombineLatestStream.combine2(
          Firestore.instance.collection("users").document(email).snapshots(),
          Firestore.instance
              .collection("communities")
              .document(communityId)
              .snapshots(),
          (u, c) =>
              HomeRouterModel(user: u, community: c)).listen(
          (HomeRouterModel model) {
        _user.add(UserModel.fromMap(model.user.data));
        _community.add(CommunityModel(model.community.data));
      });
  }

  @override
  void dispose() {
    _user.close();
    _community.close();
  }
}

class HomeRouterModel {
  final DocumentSnapshot user;
  final DocumentSnapshot community;

  HomeRouterModel({this.user, this.community});
}
