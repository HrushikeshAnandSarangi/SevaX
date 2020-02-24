import 'dart:async';

import 'package:sevaexchange/utils/data_managers/resources/payments_api_provider.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';

import 'community_list_provider.dart';

class Repository {
  final communityApiProvider = CommunityApiProvider();
  final requestApiProvider = RequestApiProvider();
  final paymentsApiProvider = PaymentsApiProvider();

  Future searchCommunityByName(name, communities) =>
      communityApiProvider.searchCommunityByName(name, communities);
  Future createCommunityByName(community) =>
      communityApiProvider.createCommunityByName(community);
  Future updateCommunityWithUserId(communityid, userid) =>
      communityApiProvider.updateCommunityWithUserId(communityid, userid);
  Future createTimebankById(timebank) =>
      createTimebank(timebankModel: timebank);
  Future updateUserWithTimeBankIdCommunityId(user, timebankId, communityId) =>
      communityApiProvider.updateUserWithTimeBankIdCommunityId(
          user, timebankId, communityId);
  Future getSubTimebanksForUser(communitId) =>
      getSubTimebanksForUserStream(communityId: communitId);
  Future getTimebankDetailsById(timebankId) =>
      getTimeBankForId(timebankId: timebankId);
  Future getCommunityDetailsByCommunityIdrepo(communityId) =>
      getCommunityDetailsByCommunityId(communityId: communityId);

  // functions for request details;
  Future getRequestsFromTimebankId(timebankId) =>
      requestApiProvider.getRequestListFuture(timebankId);
  Stream getRequestsStreamFromTimebankId(timebankId) =>
      requestApiProvider.getRequestListStream(timebankId: timebankId);
  Future getUsersFromRequest(requestID) =>
      requestApiProvider.getUserFromRequest(requestID);
  Future updateInvitedUsersForRequest(requestID, sevauserid) =>
      requestApiProvider.updateInvitedUsersForRequest(requestID, sevauserid);

  // functions for payments
  Future storeCard(token, timebankid, user) => paymentsApiProvider.addCard(token, timebankid, user);
//  Future<TrailerModel> fetchTrailers(int movieId) => moviesApiProvider.fetchTrailer(movieId);
}
