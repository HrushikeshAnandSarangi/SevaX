import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class UserRepository {
  static CollectionReference ref = CollectionRef.users;
  static CollectionReference timebankRef = CollectionRef.timebank;

  //Fetch user details
  static Future<UserModel> fetchUserById(String userId) async {
    QuerySnapshot query =
        await ref.where("sevauserid", isEqualTo: userId).get();
    if (query.docs.length == 0) {
      throw Exception("No user Found");
    }
    return UserModel.fromMap(
        query.docs[0].data() as Map<String, dynamic>, 'user_api');
  }

  static Future<String> fetchUserEmailById(String userId) async {
    QuerySnapshot query =
        await ref.where("sevauserid", isEqualTo: userId).get();
    if (query.docs.length == 0) {
      throw Exception("No user Found");
    }
    return (query.docs[0].data() as Map<String, dynamic>)["email"];
  }

//Block a member
  static Future<void> blockUser({
    String? loggedInUserEmail,
    String? userId,
    String? blockedUserId,
    String? blockedUserEmail,
  }) async {
    String userToBeBlockedEmail;
    userToBeBlockedEmail = blockedUserEmail ??
        await UserRepository.fetchUserEmailById(blockedUserId!);
    WriteBatch batch = CollectionRef.batch;
    batch.set(
      ref.doc(userToBeBlockedEmail),
      {
        'blockedBy': FieldValue.arrayUnion([userId])
      },
      SetOptions(merge: true),
    );

    batch.set(
      ref.doc(loggedInUserEmail),
      {
        'blockedMembers': FieldValue.arrayUnion([blockedUserId])
      },
      SetOptions(merge: true),
    );
    batch.commit();
  }

  static Future<void> unblockUser({
    String? loggedInUserEmail,
    String? userId,
    String? unblockedUserId,
    String? unblockedUserEmail,
  }) async {
    String userToBeBlockedEmail;
    userToBeBlockedEmail = unblockedUserEmail ??
        await UserRepository.fetchUserEmailById(unblockedUserId!);
    WriteBatch batch = CollectionRef.batch;
    batch.set(
      ref.doc(userToBeBlockedEmail),
      {
        'blockedBy': FieldValue.arrayRemove([userId])
      },
      SetOptions(merge: true),
    );

    batch.set(
      ref.doc(loggedInUserEmail),
      {
        'blockedMembers': FieldValue.arrayRemove([unblockedUserId])
      },
      SetOptions(merge: true),
    );
    batch.commit();
  }

  static Future<List<ParticipantInfo>> getShortDetailsOfAllMembersOfCommunity(
      String communityId, String userId) async {
    List<ParticipantInfo> members = [];
    bool isAdmin = false;
    TimebankModel? timebankModel;
    if (communityId == FlavorConfig.values.timebankId) {
      timebankModel = await getTimeBankForId(timebankId: communityId);
      isAdmin = isAccessAvailable(timebankModel!, userId);
    }

    QuerySnapshot querySnapshot = await ref
        .where("communities", arrayContains: communityId)
        .orderBy("fullname")
        .get();

    querySnapshot.docs.forEach((DocumentSnapshot document) {
      var user = UserModel.fromMap(
          document.data() as Map<String, dynamic>, 'user chat repo');
      if (!isMemberBlocked(user, userId)) {
        if (timebankModel != null && !isAdmin) {
          var data = document.data() as Map<String, dynamic>;
          if (isAccessAvailable(timebankModel, data["sevauserid"]))
            members.add(ParticipantInfo(
              id: data["sevauserid"],
              name: data["fullname"],
              photoUrl: data["photourl"],
            ));
        } else {
          var data = document.data() as Map<String, dynamic>;
          members.add(ParticipantInfo(
            id: data["sevauserid"],
            name: data["fullname"],
            photoUrl: data["photourl"],
          ));
        }
      }
    });

    return members;
  }

  static Stream<UserModel> getUserStream(String email) async* {
    var data = CollectionRef.users.doc(email).snapshots();
    yield* data.transform(
      StreamTransformer<DocumentSnapshot, UserModel>.fromHandlers(
        handleData: (snapshot, sink) {
          sink.add(UserModel.fromMap(
              snapshot.data() as Map<String, dynamic>, 'User Repository'));
        },
        handleError: (error, _, sink) => sink.addError(error),
      ),
    );
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
          data.docs.forEach((element) {
            try {
              _users.add(UserModel.fromMap(
                  element.data() as Map<String, dynamic>, 'User Repository'));
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
    DocumentSnapshot doc = await ref.doc(email).get();
    if (doc.data() == null) {
      throw Exception("No user Found");
    }
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, 'user_api');
  }

  static Future<void> changeUserCommunity(
      String email, String communityId, String timebankId) async {
    await ref.doc(email).set(
      {'currentCommunity': communityId, 'currentTimebank': timebankId},
      SetOptions(merge: true),
    );
  }

  static Future<void> promoteOrDemoteUser(
    String userId,
    String communityId,
    String timebankId,
    bool isPromote,
  ) async {
    WriteBatch batch = CollectionRef.batch;
    var timebankReference = timebankRef.doc(timebankId);
    var communityRef = CollectionRef.communities.doc(communityId);

    batch.update(
      timebankReference,
      {
        'admins': isPromote
            ? FieldValue.arrayUnion([userId])
            : FieldValue.arrayRemove([userId]),
      },
    );

    batch.update(
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
        .get(Uri.parse(urlLink), headers: {"Accept": "application/json"});
    var data = json.decode(res.body);
    return data;
  }
}
