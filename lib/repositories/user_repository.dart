import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class UserRepository {
  static CollectionReference ref = Firestore.instance.collection("users");
  static CollectionReference timebankRef =
      Firestore.instance.collection("timebanknew");

  //Fetch user details
  static Future<UserModel> fetchUserById(String userId) async {
    QuerySnapshot query =
        await ref.where("sevauserid", isEqualTo: userId).getDocuments();
    if (query.documents.length == 0) {
      throw Exception("No user Found");
    }
    return UserModel.fromMap(query.documents[0].data, 'user_api');
  }

  static Future<String> fetchUserEmailById(String userId) async {
    QuerySnapshot query =
        await ref.where("sevauserid", isEqualTo: userId).getDocuments();
    if (query.documents.length == 0) {
      throw Exception("No user Found");
    }
    return query.documents[0].data["email"];
  }

//Block a member
  static Future<void> blockUser({
    String loggedInUserEmail,
    String userId,
    String blockedUserId,
    String blockedUserEmail,
  }) async {
    String userToBeBlockedEmail;
    userToBeBlockedEmail = blockedUserEmail ??
        await UserRepository.fetchUserEmailById(blockedUserId);
    WriteBatch batch = Firestore.instance.batch();
    batch.setData(
      ref.document(userToBeBlockedEmail),
      {
        'blockedBy': FieldValue.arrayUnion([userId])
      },
      merge: true,
    );

    batch.setData(
      ref.document(loggedInUserEmail),
      {
        'blockedMembers': FieldValue.arrayUnion([blockedUserId])
      },
      merge: true,
    );
    batch.commit();
  }

  static Future<void> unblockUser({
    String loggedInUserEmail,
    String userId,
    String unblockedUserId,
    String unblockedUserEmail,
  }) async {
    String userToBeBlockedEmail;
    userToBeBlockedEmail = unblockedUserEmail ??
        await UserRepository.fetchUserEmailById(unblockedUserId);
    WriteBatch batch = Firestore.instance.batch();
    batch.setData(
      ref.document(userToBeBlockedEmail),
      {
        'blockedBy': FieldValue.arrayRemove([userId])
      },
      merge: true,
    );

    batch.setData(
      ref.document(loggedInUserEmail),
      {
        'blockedMembers': FieldValue.arrayRemove([unblockedUserId])
      },
      merge: true,
    );
    batch.commit();
  }

  static Future<List<ParticipantInfo>> getShortDetailsOfAllMembersOfCommunity(
      String communityId, String userId) async {
    List<ParticipantInfo> members = [];
    bool isAdmin = false;
    TimebankModel timebankModel;
    if (communityId == FlavorConfig.values.timebankId) {
      timebankModel = await getTimeBankForId(timebankId: communityId);
      isAdmin = isAccessAvailable(timebankModel, userId);
    }

    QuerySnapshot querySnapshot = await ref
        .where("communities", arrayContains: communityId)
        .orderBy("fullname")
        .getDocuments();

    querySnapshot.documents.forEach((DocumentSnapshot document) {
      var user = UserModel.fromMap(document.data, 'user chat repo');
      if (!isMemberBlocked(user, userId)) {
        if (timebankModel != null && !isAdmin) {
          if (isAccessAvailable(timebankModel, document.data["sevauserid"]))
            members.add(ParticipantInfo(
              id: document.data["sevauserid"],
              name: document.data["fullname"],
              photoUrl: document.data["photourl"],
            ));
        } else {
          members.add(ParticipantInfo(
            id: document.data["sevauserid"],
            name: document.data["fullname"],
            photoUrl: document.data["photourl"],
          ));
        }
      }
    });

    return members;
  }

  static Stream<QuerySnapshot> getBlockedMembers(String userId) {
    return ref.where("blockedBy", arrayContains: userId).snapshots();
  }

  static Stream<List<UserModel>> getMembersOfCommunity(
      String communityId) async* {
    var data = ref.where("communities", arrayContains: communityId).snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<UserModel>>.fromHandlers(
        handleData: (data, sink) {
          List<UserModel> _users = [];
          data.documents.forEach((element) {
            try {
              _users.add(UserModel.fromMap(element.data, 'User Repository'));
            } catch (e) {
              logger.e(e);
              sink.addError('Something went wrong ${e.toString()}');
            }
          });
          sink.add(_users);
        },
      ),
    );
  }

  static Future<UserModel> fetchUserByEmail(String email) async {
    DocumentSnapshot doc = await ref.document(email).get();
    if (doc?.data != null) {
      throw Exception("No user Found");
    }
    return UserModel.fromMap(doc.data, 'user_api');
  }

  static Future<void> changeUserCommunity(
      String email, String communityId, String timebankId) async {
    await ref.document(email).setData(
      {'currentCommunity': communityId, 'currentTimebank': timebankId},
      merge: true,
    );
  }

  static Future<void> promoteOrDemoteUser(
    String userId,
    String communityId,
    String timebankId,
    bool isPromote,
  ) async {
    WriteBatch batch = Firestore.instance.batch();
    var timebankReference = timebankRef.document(timebankId);
    var communityRef =
        Firestore.instance.collection("communities").document(communityId);

    batch.updateData(
      timebankReference,
      {
        'admins': isPromote
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      },
    );

    batch.updateData(
      communityRef,
      {
        'admins': isPromote
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      },
    );

    await batch.commit();
  }

  static Future<Map<String, dynamic>> removeMember(
    String userId,
    String timebankId,
    bool isTimebank,
  ) async {
    String urlLink = FlavorConfig.values.cloudFunctionBaseURL +
        (isTimebank
            ? "/removeMemberFromTimebank?sevauserid=$userId&timebankId=$timebankId"
            : "/removeMemberFromGroup?sevauserid=$userId&groupId=$timebankId");

    var res = await http
        .get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
    var data = json.decode(res.body);
    return data;
  }
}
