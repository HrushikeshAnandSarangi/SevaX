import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
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

//      timebankModel.admins.forEach((sevauserid) async {
//        QuerySnapshot querySnapshot = await ref
//            .where("sevauserid", isEqualTo: sevauserid)
//            .orderBy("fullname")
//            .getDocuments();
//
//        querySnapshot.documents.forEach((DocumentSnapshot document) {
//          members.add(ParticipantInfo(
//            id: document.data["sevauserid"],
//            name: document.data["fullname"],
//            photoUrl: document.data["photourl"],
//          ));
//        });
//      });
//
//      return members;
//
//    } else {
    QuerySnapshot querySnapshot = await ref
        .where("communities", arrayContains: communityId)
        .orderBy("fullname")
        .getDocuments();

    querySnapshot.documents.forEach((DocumentSnapshot document) {
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
    });

    return members;
  }

  static Stream<QuerySnapshot> getBlockedMembers(String userId) {
    return ref.where("blockedBy", arrayContains: userId).snapshots();
  }

  static Stream<QuerySnapshot> getMembersOfCommunity(String communityId) {
    return ref.where("communities", arrayContains: communityId).snapshots();
  }
}
