import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import '../resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class CommunityBloc {
  final _repository = Repository();
  final _communitiesFetcher = PublishSubject<CommunityListModel>();
  final searchOnChange = new BehaviorSubject<String>();

  Observable<CommunityListModel> get allCommunities => _communitiesFetcher.stream;

  fetchCommunities(name) async {
    CommunityListModel communityListModel = await _repository.searchCommunityByName(name);
    print(communityListModel.communities.length);
    _communitiesFetcher.sink.add(communityListModel);
  }

  dispose() {
    _communitiesFetcher.close();
    searchOnChange.close();
  }
}

final bloc = CommunityBloc();
