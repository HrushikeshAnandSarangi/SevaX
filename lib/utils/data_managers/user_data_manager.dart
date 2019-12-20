import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:http/http.dart' as http;

/// Create a [user]
Future<void> createUser({
  @required UserModel user,
}) async {
  return await Firestore.instance
      .collection('users')
      .document(user.email)
      .setData(user.toMap());
}

Future<void> updateUser({
  @required UserModel user,
}) async {
  //print(user.toMap());

  return await Firestore.instance
      .collection('users')
      .document(user.email)
      .updateData(user.toMap());
}
//Future<void> updateTimebank({
//  @required TimebankModel timebankModel,
//}) async {
//  //print(user.toMap());
//
//  return await Firestore.instance
//      .collection('timebanknew')
//      .document(timebankModel.id)
//      .updateData(timebankModel.toMap());
//}

//Future<void> addReportUser({
//  @required String userId,
//}) async {
////print(user.toMap());
//
//return await Firestore.instance
//    .collection('reportedUsersList')
//.document(user.email)
//.updateData(user.toMap());
//}

//Future<void> updateUserAvailability({
//  @required UserModel user,
//}) async {
//  print("upadte user availability feature");
//  print(user.availability.weekArray);
////  return await Firestore.instance.collection("seva_stage").add({
////    "Availability" : "abcd"
////  });
//  return await Firestore.instance
//      .collection('users')
//      .document(user.email)
//      .updateData({"availability":{
//    "lat_lng":user.availability.lat_lng,
//    "location":user.availability.location,
//    "distnace":user.availability.distnace,
//    "accurance_number":user.availability.accurance_number,
//    "endsData":user.availability.endsData,
//    "endsStatus":user.availability.endsStatus,
//    "repeatAfterStr":user.availability.repeatAfterStr,
//    "repeatNumber":user.availability.repeatNumber,
//    //"weekArray":user.availability.weekArray,
//
//  }});
//  // return await Firestore.instance
//  //     .collection('users')
//  //     .document(user.email)
//  //     .setData({"Availability":user.availability.toMap()});
//}

Future<UserModel> getUserForId({@required String sevaUserId}) async {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");

  UserModel userModel;
  await Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: sevaUserId)
      .getDocuments()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
      userModel = UserModel.fromMap(documentSnapshot.data);
    });
  });

  return userModel;
}

Future<UserModel> getUserForEmail({
  @required String emailAddress,
}) async {
  assert(emailAddress != null && emailAddress.isNotEmpty,
      'User Email cannot be null or empty');

  UserModel userModel;
  DocumentSnapshot documentSnapshot =
      await Firestore.instance.collection('users').document(emailAddress).get();

  if (documentSnapshot == null || documentSnapshot.data == null) {
    return null;
  }
  userModel = UserModel.fromMap(documentSnapshot.data);

  // DocumentSnapshot walletSnapshot = await Firestore.instance
  //     .collection('wallet')
  //     .document(emailAddress)
  //     .get();

  // num currentBalance = 0;

  // if (userModel == null) return null;
  // if (walletSnapshot != null && walletSnapshot.data != null) {
  //   currentBalance = walletSnapshot.data['currentBalance'];
  // }

// 73191597
  // userModel.currentBalance = currentBalance;

  return userModel;
}
class UserModelListMoreStatus{
  var userModelList = List<UserModel>();
  bool lastPage = false;
}

Future<UserModelListMoreStatus> getUsersForAdminsCoordinatorsMembersTimebankId(String timebankId, int index, String email) async {
  var urlLink = 'https://us-central1-sevaexchange.cloudfunctions.net/timebankACM?page=$index&fetchRole=admin&timebankId=$timebankId&userId=$email';
  var res = await http.get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList = rest.map<UserModel>((json) => UserModel.fromMap(json)).toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Future<UserModelListMoreStatus> getUsersForTimebankId(String timebankId, int index, String email) async {
  var urlLink = 'https://us-central1-sevaexchange.cloudfunctions.net/timebankMembers?timebankId=$timebankId&page=$index&userId=$email';
  var res = await http.get(Uri.encodeFull(urlLink), headers: {"Accept": "application/json"});
  if (res.statusCode == 200) {
    var data = json.decode(res.body);
    var rest = data["result"] as List;
    var useModelStatus = UserModelListMoreStatus();
    useModelStatus.userModelList = rest.map<UserModel>((json) => UserModel.fromMap(json)).toList();
    useModelStatus.lastPage = (data["lastPage"] as bool);
    return useModelStatus;
  }
  return UserModelListMoreStatus();
}

Stream<UserModel> getUserForIdStream({@required String sevaUserId}) async* {
  assert(sevaUserId != null && sevaUserId.isNotEmpty,
      "Seva UserId cannot be null or empty");

  var data = Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: sevaUserId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) async {
        DocumentSnapshot documentSnapshot = snapshot.documents[0];
        UserModel model = UserModel.fromMap(documentSnapshot.data);

        DocumentSnapshot walletSnapshot = await Firestore.instance
            .collection('wallet')
            .document(model.email)
            .get();

        model.sevaUserID = sevaUserId;
        userSink.add(model);
      },
    ),
  );
}

Stream<UserModel> getUserForEmailStream(String userEmailAddress) async* {
  assert(userEmailAddress != null && userEmailAddress.isNotEmpty,
      'User Email cannot be null or empty');

  var userDataStream = Firestore.instance
      .collection('users')
      .document(userEmailAddress)
      .snapshots();

  yield* userDataStream.transform(
    StreamTransformer<DocumentSnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, userSink) {
        UserModel model = UserModel.fromMap(snapshot.data);
        // model.sevaUserID = snapshot.documentID;
        userSink.add(model);
      },
    ),
  );
}
