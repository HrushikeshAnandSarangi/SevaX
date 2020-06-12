import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/user_model.dart';

class UserApi {
  //Fetch user details
  static Future<UserModel> fetchUserById(String userId) async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .where("sevauserid", isEqualTo: userId)
        .getDocuments();
    if (query.documents.length == 0) {
      throw Exception("No user Found");
    }
    return UserModel.fromMap(query.documents[0].data);
  }

  static Future<String> fetchUserEmailById(String userId) async {
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .where("sevauserid", isEqualTo: userId)
        .getDocuments();
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
        blockedUserEmail ?? await UserApi.fetchUserEmailById(blockedUserId);
    WriteBatch batch = Firestore.instance.batch();
    batch.setData(
      Firestore.instance.collection("users").document(userToBeBlockedEmail),
      {
        'blockedBy': FieldValue.arrayUnion([userId])
      },
      merge: true,
    );

    batch.setData(
      Firestore.instance.collection("users").document(loggedInUserEmail),
      {
        'blockedMembers': FieldValue.arrayUnion([blockedUserId])
      },
      merge: true,
    );
    batch.commit();
  }
}
