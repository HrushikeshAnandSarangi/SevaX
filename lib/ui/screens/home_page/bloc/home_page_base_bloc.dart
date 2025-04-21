import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/timebank_repository.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class HomePageBaseBloc extends BlocBase
    with TimebankRepository, CommunityRepository {
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _timebanks = BehaviorSubject<List<TimebankModel>>();
  final _exploreGroupsDataStream = BehaviorSubject<ExploreGroupDataHolder>();
  final _currentTimebank = BehaviorSubject<TimebankModel>();
  TimebankModel? _oldValue;

  bool isInCommunity = true;
  Stream<List<CommunityModel>> get communitiesOfUser => _communities.stream;
  Stream<List<TimebankModel>> get timebanksOfCommunity => _timebanks.stream;
  Stream<ExploreGroupDataHolder> get exploreGroupsOutputStream =>
      _exploreGroupsDataStream.stream;

  void changeTimebank(TimebankModel timebank) {
    logger.wtf(timebank.name);
    _oldValue = _currentTimebank.value ?? timebank;
    _currentTimebank.sink.add(timebank);
  }

  Stream<TimebankModel> get currentTimebank => _currentTimebank.stream;

  bool isAdmin(String userId) {
    try {
      logger.i(_currentTimebank.value);
      return isMemberAnAdmin(_currentTimebank.value, userId);
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  void switchToPreviousTimebank() {
    if (_oldValue != null) {
      AppConfig.timebankConfigurations =
          _oldValue?.timebankConfigurations ?? AppConfig.timebankConfigurations;
      _currentTimebank.sink.add(_oldValue!);
    }
  }

  Stream<List<TimebankModel>> filteredTimebanksOfCommunity(
      String query) async* {
    if (query == null) {
      query = '';
    }
    yield* _timebanks.transform(
      StreamTransformer<List<TimebankModel>, List<TimebankModel>>.fromHandlers(
        handleData: (data, sink) {
          if (data != null || data.isNotEmpty) {
            sink.add(
              List<TimebankModel>.from(
                data.where(
                  (element) =>
                      element.name.toLowerCase().contains(query.toLowerCase()),
                ),
              ),
            );
          } else {
            sink.addError('primary timebank not found in internal stream');
          }
        },
      ),
    );
  }

  Function(TimebankModel) get changeCurrentTimebank =>
      _currentTimebank.sink.add;

  void init(UserModel user) {
    logger.wtf("homepage base bloc init");
    getAllTimebanksOfCommunity(user.currentCommunity ?? '').listen((event) {
      event.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      _timebanks.add(event);
    });
    getAllCommunitiesOfUser(user.sevaUserID ?? '').listen((event) {
      event.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      _communities.add(event);
    });

    getExploreGroupsDataStream(
      communityId: user.currentCommunity ?? '',
      userId: user.sevaUserID ?? '',
    ).listen((event) {
      _exploreGroupsDataStream.add(event);
    });
  }

  Stream<TimebankModel> primaryTimebank() async* {
    yield* _timebanks.transform(
      StreamTransformer<List<TimebankModel>, TimebankModel>.fromHandlers(
        handleData: (data, sink) {
          if (data != null || data.isNotEmpty) {
            sink.add(data.firstWhere(
                (element) => element.id == FlavorConfig.values.timebankId));
          } else {
            sink.addError('primary timebank not found in internal stream');
          }
        },
      ),
    );
  }

  CombineLatestStream<dynamic, ExploreGroupDataHolder>
      getExploreGroupsDataStream({
    String? communityId,
    String? userId,
  }) {
    return CombineLatestStream.combine2(
      _timebanks.stream,
      getJoinRequestsCretedByUserStream(userID: userId ?? ''),
      (
        List<TimebankModel> listOfSubTimebanks,
        List<JoinRequestModel> listOfJoinRequestsMade,
      ) =>
          ExploreGroupDataHolder(
        joinRequestsMade: listOfJoinRequestsMade,
        listOfSubTimebanks: listOfSubTimebanks,
      ),
    );
  }

  TimebankModel primaryTimebankModel() {
    return _timebanks.value.firstWhere(
      (model) => model.parentTimebankId == FlavorConfig.values.timebankId,
      orElse: () => throw Exception('No primary timebank found'),
    );
  }

  bool isUserCreator(String userId) {
    return userId == primaryTimebankModel().creatorId;
  }

  TimebankModel timebankModel(String timebankId) {
    return _timebanks.value.firstWhere(
      (model) => model.id == timebankId,
      orElse: () => throw Exception('No timebank found with id $timebankId'),
    );
  }

  Stream<TimebankModel> timebank(String timebankId) async* {
    yield* _timebanks.transform(
      StreamTransformer<List<TimebankModel>, TimebankModel>.fromHandlers(
        handleData: (data, sink) {
          if (data != null || data.isNotEmpty) {
            sink.add(data.firstWhere((element) => element.id == timebankId));
          } else {
            sink.addError('$timebankId not found in internal stream');
          }
        },
      ),
    );
  }

  /// returns null if timebank is not found
  TimebankModel getTimebankModelFromCurrentCommunity(String timebankId) {
    return _timebanks.value.firstWhere(
      (model) => model.id == timebankId,
      orElse: () => throw Exception('No timebank found with id $timebankId'),
    );
  }

  List<UserModel> getMembersProfilePicturesArray({
    required String timebankId,
    required MembersBloc membersBloc,
  }) {
    _timebanks.value.forEach((element) {
      logger.i(element.id);
    });
    List<UserModel> profilePictures = [];
    var timebankModel = _timebanks.value.firstWhere(
      (model) => model.id == timebankId,
      orElse: () => throw Exception('No timebank found with id $timebankId'),
    );

    timebankModel.members.forEach((element) {
      if (membersBloc.getMemberFromLocalData(userId: element) != null) {
        profilePictures
            .add(membersBloc.getMemberFromLocalData(userId: element)!);
      }
    });
    return profilePictures;
  }

  Stream<CommunityModel> currentCommunity(String communityId) async* {
    {
      yield* _communities.transform(
        StreamTransformer<List<CommunityModel>, CommunityModel>.fromHandlers(
          handleData: (data, sink) {
            if (data != null || data.isNotEmpty) {
              sink.add(data.firstWhere((element) => element.id == communityId));
            } else {
              sink.addError('$communityId not found in internal stream');
            }
          },
        ),
      );
    }
  }

  //throws exception if community is not initialized
  CommunityModel communtiyModel(String communityId) {
    return _communities.value.firstWhere(
      (element) => element.id == communityId,
      orElse: () => throw Exception('No community found with id $communityId'),
    );
  }

  List<TimebankModel> filterGroupsOfUser(
    List<TimebankModel> timebanks,
    String userId,
  ) {
    return List<TimebankModel>.from(timebanks.where(
      (element) =>
          element.members.contains(userId) &&
          element.parentTimebankId != FlavorConfig.values.timebankId,
    ));
  }

  List<TimebankModel> filterGroupsOfUserWithoutSearch(
    String userId,
  ) {
    return List<TimebankModel>.from(_timebanks.value.where(
      (element) =>
          element.members.contains(userId) &&
          element.parentTimebankId != FlavorConfig.values.timebankId,
    ));
  }

  List<TimebankModel> filterGroupsOfUserViaSearch(
      {
//      List<TimebankModel> timebanks,
      required String userId,
      required String searchText}) {
    return List<TimebankModel>.from(_timebanks.value.where(
      (element) =>
          element.members.contains(userId) &&
          element.parentTimebankId != FlavorConfig.values.timebankId &&
          element.name.toLowerCase().contains(searchText.toLowerCase()),
    ));
  }

  void dispose() {
    _currentTimebank.close();
    _communities.close();
    _timebanks.close();
    // _exploreGroupsDataStream.close();
  }
}

class ExploreGroupDataHolder {
  final List<TimebankModel> listOfSubTimebanks;
  final List<JoinRequestModel> joinRequestsMade;
  ExploreGroupDataHolder({
    required this.joinRequestsMade,
    required this.listOfSubTimebanks,
  });
}
