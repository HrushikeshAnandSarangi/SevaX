import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/user_model.dart';

class UserRepository {
  static CollectionReference ref = Firestore.instance.collection("users");

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
    userToBeBlockedEmail =
        blockedUserEmail ?? await UserRepository.fetchUserEmailById(blockedUserId);
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
    userToBeBlockedEmail =
        unblockedUserEmail ?? await UserRepository.fetchUserEmailById(unblockedUserId);
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
      String communityId) async {
    List<ParticipantInfo> members = [];
    QuerySnapshot querySnapshot = await ref
        .where("communities", arrayContains: communityId)
        .orderBy("fullname")
        .getDocuments();

    querySnapshot.documents.forEach((DocumentSnapshot document) {
      members.add(ParticipantInfo(
        id: document.data["sevauserid"],
        name: document.data["fullname"],
        photoUrl: document.data["photourl"],
      ));
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
