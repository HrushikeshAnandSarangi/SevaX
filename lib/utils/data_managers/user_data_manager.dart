import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:meta/meta.dart';

import 'package:sevaexchange/models/user_model.dart';

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

Future<void> updateUserAvailability({
  @required UserModel user,
}) async {
  print("upadte user availability feature");

//  return await Firestore.instance.collection("seva_stage").add({
//    "Availability" : "abcd"
//  });
//  return await Firestore.instance
//      .collection('users')
//      .document(user.email)
//      .updateData(user.availability.toMap());
  // return await Firestore.instance
  //     .collection('users')
  //     .document(user.email)
  //     .setData({"Availability":user.availability.toMap()});
}

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

  // DocumentSnapshot walletSnapshot = await Firestore.instance
  //     .collection('wallet')
  //     .document(userModel.email)
  //     .get();

  // num currentBalance;

  // if (walletSnapshot != null && walletSnapshot.data != null) {
  //   currentBalance = walletSnapshot.data['currentBalance'];
  // }

  // userModel.currentBalance = currentBalance;

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
        model.sevaUserID = snapshot.documentID;
        userSink.add(model);
      },
    ),
  );
}
