import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/models.dart';
import '../resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class CommunityFindBloc {
  final _repository = Repository();
  final _communitiesFetcher = PublishSubject<CommunityListModel>();
  final searchOnChange = new BehaviorSubject<String>();

  Observable<CommunityListModel> get allCommunities => _communitiesFetcher.stream;

  fetchCommunities(name) async {
    CommunityListModel communityListModel = CommunityListModel();
    communityListModel.loading = true;
    _communitiesFetcher.sink.add(communityListModel);
    communityListModel = await _repository.searchCommunityByName(name, communityListModel);
    communityListModel.loading = false;
    print(communityListModel.communities.length);
    _communitiesFetcher.sink.add(communityListModel);
  }

  dispose() {
    _communitiesFetcher.close();
    searchOnChange.close();
  }
}

class CommunityCreateEditController {
  CommunityModel community = CommunityModel({});
  TimebankModel timebank = TimebankModel({});
  String selectedAddress;
  String timebankAvatarURL = null;
  List addedMembersId = [];
  List addedMembersFullname = [];
  List addedMembersPhotoURL = [];
  HashMap selectedUsers = HashMap();
  CommunityCreateEditController() {
  }
}

class CommunityCreateEditBloc {
  final _repository = Repository();
  final _createEditCommunity = BehaviorSubject<CommunityCreateEditController>();

  Observable<CommunityCreateEditController> get createEditCommunity => _createEditCommunity.stream;

  CommunityCreateEditBloc(){
    _createEditCommunity.add(CommunityCreateEditController());
  }
  onChange(community) {
    _createEditCommunity.add(community);
  }
  dispose() {
    _createEditCommunity.close();
  }
}
final createEditCommunityBloc = CommunityCreateEditBloc();
final communityBloc = CommunityFindBloc();
