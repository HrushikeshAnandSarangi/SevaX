import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
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
    return CollectionRef.users.doc(email).snapshots();
  }

  void getData({String email, String communityId}) {
    if (!_user.isClosed && !_community.isClosed)
      CombineLatestStream.combine2(
        CollectionRef.users.doc(email).snapshots(),
        CollectionRef.communities.doc(communityId).snapshots(),
        (u, c) => HomeRouterModel(user: u, community: c),
      ).listen((HomeRouterModel model) {
        if (!_user.isClosed) {
          _user.add(UserModel.fromMap(model.user.data(), 'user_data_bloc'));
        }
        if (!_community.isClosed) {
          _community.add(CommunityModel(model.community.data()));
          AppConfig.paymentStatusMap = _community.value.payment;
          //AppConfig.isTestCommunity = _community.value.testCommunity;
          log('test ${AppConfig.isTestCommunity}');
        }
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
