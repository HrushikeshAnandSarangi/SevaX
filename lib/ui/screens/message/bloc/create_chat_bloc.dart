import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/widgets/APi/timebank_api.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

import '../../../../flavor_config.dart';

class CreateChatBloc extends BlocBase {
  final _members = BehaviorSubject<List<ParticipantInfo>>();
  final _searchText = BehaviorSubject<String>();
  final _timebanksOfUser = BehaviorSubject<List<TimebankModel>>();
  final Map<String, ParticipantInfo> selectedMembers = {};
  final Map<String, ParticipantInfo> allMembers = {};

  Function(String) get onSearchChanged => _searchText.sink.add;

  Stream<String> get searchText => _searchText.stream;
  Stream<List<ParticipantInfo>> get members => _members.stream;
  Stream<List<TimebankModel>> get timebanksOfUser => _timebanksOfUser.stream;

  Future<void> getMembers(String userId, String communityId) async {
    List<ParticipantInfo> users =
        await UserApi.getShortDetailsOfAllMembersOfCommunity(communityId);
    users.removeWhere((ParticipantInfo info) => info.id == userId);
    users.forEach((ParticipantInfo info) => allMembers[info.id] = info);
    List<TimebankModel> timebanks =
        await TimebankApi.getTimebanksWhichUserIsPartOf(userId, communityId);
    timebanks.removeWhere(
      (TimebankModel model) =>
          model.members.length == 1 ||
          model.parentTimebankId == FlavorConfig.values.timebankId,
    );
    _timebanksOfUser.add(timebanks);
    _members.add(users);
  }

  List<ParticipantInfo> getFilteredListOfParticipants(String searchText) {
    List<ParticipantInfo> participants = [];
    if (searchText != null && _members.value != null) {
      _members.value.forEach((ParticipantInfo info) {
        if (info.name.toLowerCase().contains(searchText.toLowerCase())) {
          participants.add(info);
        }
      });
    }
    return participants;
  }

  void dispose() {
    _members.close();
    _timebanksOfUser.close();
    _searchText.close();
  }
}
