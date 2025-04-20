import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/project_repository.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class ExploreCommunityDetailsBloc {
  final _community = BehaviorSubject<CommunityModel>();
  final _timebank = BehaviorSubject<TimebankModel>();
  final _requests = BehaviorSubject<List<RequestModel>>();
  final _groups = BehaviorSubject<List<TimebankModel>>();
  final _events = BehaviorSubject<List<ProjectModel>>();

  Stream<TimebankModel> get timebank => _timebank.stream;
  Stream<CommunityModel> get community => _community.stream;
  Stream<List<RequestModel>> get requests => _requests.stream;
  Stream<List<TimebankModel>> get groups => _groups.stream;
  Stream<List<ProjectModel>> get events => _events.stream;

  void init(String communityId, bool isSignedUser) {
    //get community details
    if (isSignedUser) {
      CommunityRepository.getCommunity(communityId).then(
        (community) {
          community != null
              ? _community.add(community)
              : _community.addError("something went wrong");
        },
      );

      //get all requests of community
      RequestRepository.getAllRequestsOfCommunity(communityId).then(
        (List<RequestModel> models) {
          models.isNotEmpty
              ? _requests.add(models)
              : _requests.addError("Something went wrong");
        },
      );

      ProjectRepository.getAllProjectsOfCommunity(communityId).then(
        (List<ProjectModel> models) {
          models.isNotEmpty
              ? _events.add(models)
              : _events.addError("Something went wrong");
        },
      );

      FirestoreManager.getAllTheGroups(communityId).then(
        (List<TimebankModel> models) {
          models.isNotEmpty
              ? _groups.add(models)
              : _groups.addError("Something went wrong");
        },
      );
    } else {
      Searches.getCommunityDetails(communityId: communityId).then(
        (CommunityModel model) {
          model != null
              ? _community.add(model)
              : _community.addError("Something went wrong");
        },
      );
      Searches.getGroupsUnderCommunity(communityId: communityId).then(
        (List<TimebankModel> models) {
          models.isNotEmpty
              ? _groups.add(models)
              : _groups.addError("Something went wrong");
        },
      );
      Searches.getPublicRequestsUnderTimebank(communityId: communityId).then(
        (List<RequestModel> models) {
          models.isNotEmpty
              ? _requests.add(models)
              : _requests.addError("Something went wrong");
        },
      );
      Searches.getPublicEventsUnderTimebank(communityId: communityId).then(
        (List<ProjectModel> models) {
          models.isNotEmpty
              ? _events.add(models)
              : _events.addError("Something went wrong");
        },
      );
    }
  }

  TimebankModel primaryTimebankModel() {
    return _groups.value.firstWhere(
      (model) => isPrimaryTimebank(parentTimebankId: model.parentTimebankId),
      orElse: () => TimebankModel('default_timebank_id'),
    );
  }

  void dispose() {
    _community.close();
    _requests.close();
    _events.close();
    _timebank.close();
    _groups.close();
  }
}
