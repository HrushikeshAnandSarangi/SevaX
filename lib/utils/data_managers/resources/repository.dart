import 'dart:async';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'community_list_provider.dart';

class Repository {
  final communityApiProvider = CommunityApiProvider();
  final requestApiProvider = RequestApiProvider();

  Future searchCommunityByName(name, communities) => communityApiProvider.searchCommunityByName(name, communities);
  Future createCommunityByName(community) => communityApiProvider.createCommunityByName(community);
  Future updateCommunityWithUserId(communityid, userid) => communityApiProvider.updateCommunityWithUserId(communityid, userid);
  Future createTimebankById(timebank) => createTimebank(timebankModel: timebank);
  Future updateUserWithTimeBankIdCommunityId(user, timebankId, communityId) => communityApiProvider.updateUserWithTimeBankIdCommunityId(user, timebankId, communityId);
  Future getSubTimebanksForUser(communitId) => getSubTimebanksForUserStream(communityId: communitId);
  Future getTimebankDetailsById(timebankId) => getTimeBankForId(timebankId: timebankId);
  Future getCommunityDetailsByCommunityIdrepo(communityId) => getCommunityDetailsByCommunityId(communityId: communityId);


  // functions for request details;
  Future getRequestsFromTimebankId(timebankId) => requestApiProvider.getRequestListStream(timebankId);
  Future getUsersFromRequest(requestID) => requestApiProvider.getUserFromRequest(requestID);
  Future updateInvitedUsersForRequest(requestID, sevauserid)=>requestApiProvider.updateInvitedUsersForRequest(requestID, sevauserid);
//  Future<TrailerModel> fetchTrailers(int movieId) => moviesApiProvider.fetchTrailer(movieId);
}
