import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';

class RequestApiProvider {
  Client client = Client();

  Future<List<UserModel>> getUserFromRequest(String requestID) async {
    List<UserModel> usersDataList = [];
    print("uder ${requestID}");

    var query = Firestore.instance
        .collection('users')
        .where("invitedRequests", arrayContains: requestID);

    QuerySnapshot querySnapshot = await query.getDocuments();

    querySnapshot.documents.forEach((documentSnapshot) {
      UserModel model = UserModel.fromMap(documentSnapshot.data);
      usersDataList.add(model);
    });
    return usersDataList;
  }

  Future<List<RequestModel>> getRequestListFuture(String timebankId) async {
    List<RequestModel> requestList = [];
    var query = timebankId == null || timebankId == 'All'
        ? Firestore.instance
            .collection('requests')
            .where('accepted', isEqualTo: false)
            .orderBy("posttimestamp", descending: true)
        : Firestore.instance
            .collection('requests')
            .where('timebankId', isEqualTo: timebankId)
            .where('accepted', isEqualTo: false)
            .orderBy("posttimestamp", descending: true);

    QuerySnapshot querySnapshot = await query.getDocuments();
    print("comm list provider");
    querySnapshot.documents.forEach((documentSnapshot) {
      RequestModel model = RequestModel.fromMap(documentSnapshot.data);
      model.id = documentSnapshot.documentID;
      print("model is : " + model.id);
      if (model.approvedUsers.length <= model.numberOfApprovals) {
        requestList.add(model);
      }
    });
    return requestList;
  }

  Stream<List<RequestModel>> getRequestListStream({String timebankId}) async* {
    var query = timebankId == null || timebankId == 'All'
        ? Firestore.instance
            .collection('requests')
            .where('accepted', isEqualTo: false)
        : Firestore.instance
            .collection('requests')
            .where('timebankId', isEqualTo: timebankId)
            .where('accepted', isEqualTo: false);

    var data = query.snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestList = [];
          snapshot.documents.forEach(
            (documentSnapshot) {
              RequestModel model = RequestModel.fromMap(documentSnapshot.data);
              model.id = documentSnapshot.documentID;
//              if (model.approvedUsers.length <= model.numberOfApprovals){
//                requestList.add(model);
//              }
              if (model.transactions == null) {
                requestList.add(model);
              } else {
                var approvalCount = 0;
                for (var i = 0; i < model.transactions.length; i++) {
                  if (model.transactions[i].isApproved) {
                    approvalCount++;
                  }
                }
                if (approvalCount < model.numberOfApprovals) {
                  requestList.add(model);
                }
              }
//              if (model.approvedUsers.length <= model.numberOfApprovals)
//                requestList.add(model);
            },
          );
          requestSink.add(requestList);
        },
      ),
    );
  }

  Future<void> updateInvitedUsersForRequest(
      String requestID, String sevaUserId) async {
    List<String> list = List();
    list.add(sevaUserId);

    await Firestore.instance
        .collection('requests')
        .document(requestID)
        .updateData({
      'invitedUsers': FieldValue.arrayUnion([sevaUserId])
    }).then((onValue) {
      return "Updated invitedUsers";
    }).catchError((onError) {
      return "Error Updating invitedUsers";
    });

    print('seva ${sevaUserId + requestID}');
  }
}

class CommunityApiProvider {
  Client client = Client();
//  Future<CategoryListModel> fetchCategoryList() async {
//    Response response;
//    if(_apiKey != 'api-key') {
//       response = await client.get("$_baseUrl/popular?api_key=$_apiKey");
//    }else{
//      throw Exception('Please add your API key');
//    }
//    if (response.statusCode == 200) {
//      // If the call to the server was successful, parse the JSON
//      return CategoryListModel.fromJson(json.decode(response.body));
//    } else {
//      // If that call was not successful, throw an error.
//      throw Exception('Failed to load post');
//    }
//  }

  Future<bool> isCommunityFound(String enteredName) async {
    //ommunityBloc.fetchCommunities(enteredName);
    CommunityListModel communities = CommunityListModel();
    var communitiesFound =
        await searchCommunityByName(enteredName, communities);
    if (communitiesFound == null ||
        communitiesFound.communities == null ||
        communitiesFound.communities.length == 0) {
      return false;
    } else {
      return true;
    }
  }

  Future<CommunityListModel> searchCommunityByName(
      String name, CommunityListModel communities) async {
    communities.removeall();
    if (name.isNotEmpty && name.length > 4) {
      await Firestore.instance
          .collection('communities')
          .where('name', isEqualTo: name)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
          var community = CommunityModel(documentSnapshot.data);

          communities.add(community);
        });
      });
    }
    return communities;
  }

  Future<void> updateCommunityWithUserId(communityId, userId) async {
    var response = await Firestore.instance
        .collection("communities")
        .document(communityId)
        .updateData({
      'members': FieldValue.arrayUnion([userId])
    });
    return response;
  }

  Future<void> createCommunityByName(CommunityModel community) async {
    await Firestore.instance
        .collection('communities')
        .document(community.id)
        .setData(community.toMap());
  }

  Future<void> updateUserWithTimeBankIdCommunityId(
      UserModel user, timebankId, communityId) async {
    // if user is already part of community
    var found = false;
    if (user.communities != null) {
      for (var i = 0; i < user.communities.length; i++) {
        if (user.communities[i] == communityId) {
          found = true;
        }
      }
    } else {
      user.communities = [];
    }
    if (!found) {
      user.communities.add(communityId);
    }
    found = false;
    if (user.membershipTimebanks != null) {
      for (var i = 0; i < user.membershipTimebanks.length; i++) {
        if (user.membershipTimebanks[i] == timebankId) {
          found = true;
        }
      }
    } else {
      user.membershipTimebanks = [];
    }
    if (!found) {
      user.membershipTimebanks.add(timebankId);
    }
    await Firestore.instance
        .collection('users')
        .document(user.email)
        .updateData({
      'membershipTimebanks': user.membershipTimebanks,
      'communities': user.communities,
      'currentCommunity': communityId
    }).then((onValue) {
      print("Updating completed");
    }).catchError((onError) {
      print("Error Updating introduction");
    });
  }
}
