import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/project_repository.dart';
import 'package:sevaexchange/repositories/request_repository.dart';

class ExploreCommunityDetailsBloc {
  final _community = BehaviorSubject<CommunityModel>();
  final _requests = BehaviorSubject<List<RequestModel>>();
  final _events = BehaviorSubject<List<ProjectModel>>();

  Stream<CommunityModel> get community => _community.stream;
  Stream<List<RequestModel>> get requests => _requests.stream;
  Stream<List<ProjectModel>> get events => _events.stream;

  void init(String communityId) {
    //get community details
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

    ProjectRepository.getAllProjectsOfCommunity(communityId)
        .then((List<ProjectModel> models) {
      models.isNotEmpty
          ? _events.add(models)
          : _events.addError("Something went wrong");
    });
  }

  void dispose() {
    _community.close();
    _requests.close();
    _events.close();
  }
}
