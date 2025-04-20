import 'dart:async';

import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
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
  Stream getRequestsStreamFromTimebankId(timebankId, String userId) =>
      requestApiProvider.getRequestListStream(
          timebankId: timebankId, userId: userId);
  Future getUsersFromRequest(requestID) =>
      requestApiProvider.getUserFromRequest(requestID);
  Future updateInvitedUsersForRequest(requestID, sevauserid, email) =>
      requestApiProvider.updateInvitedUsersForRequest(
          requestID, sevauserid, email);

  // functions for payments
  Future storeCard(
          {token, timebankid, user, planName, bool? isNegotiatedPlan}) =>
      paymentsApiProvider.addCard(
          token, timebankid, isNegotiatedPlan!, user, planName);
  // token, timebankid, user, planName

  Future searchUserByName(name, UserListModel userListModel) {
    // TODO: implement searchUserByName
    throw UnimplementedError('searchUserByName is not implemented yet');
  }

  Future searchTimebankSiblingsByParentId(id, TimebankListModel timebanks) =>
      communityApiProvider.searchTimebankSiblingsByParentId(id, timebanks);
//  Future<TrailerModel> fetchTrailers(int movieId) => moviesApiProvider.fetchTrailer(movieId);
}
