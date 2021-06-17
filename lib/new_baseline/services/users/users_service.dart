// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'dart:async';
// import 'package:meta/meta.dart';
// import 'package:sevaexchange/base/base_service.dart';

// import 'package:sevaexchange/models/user_model.dart';

// class UsersService {
//   /// Create a [user]
//   Future<void> createUser({
//     @required UserModel user,
//   }) async {
//     // log.i('createUser: UserModel: $user');
//     return await CollectionRef
//         .users
//         .doc(user.email)
//         .set(user.toMap());
//   }

//   /// update a [user]
//   Future<void> updateUser({
//     @required UserModel user,
//   }) async {
//     // log.i('updateUser: UserModel: $user');
//     return await CollectionRef
//         .users
//         .doc(user.email)
//         .update(user.toMap());
//   }

//   /// get user by seva ID [sevaUserId] as future
//   Future<UserModel> getUserForId({@required String sevaUserId}) async {
//     // log.i('getUserForId: SevaUserID: $sevaUserId');
//     assert(sevaUserId != null && sevaUserId.isNotEmpty,
//         "Seva UserId cannot be null or empty");

//     UserModel userModel;
//     await CollectionRef
//         .users
//         .where('sevauserid', isEqualTo: sevaUserId)
//         .get()
//         .then((QuerySnapshot querySnapshot) {
//       querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
//         userModel = UserModel.fromMap(documentSnapshot.data);
//       });
//     });

//     return userModel;
//   }

//   /// get user by email ID [emailAddress] as future
//   Future<UserModel> getUserForEmail({
//     @required String emailAddress,
//   }) async {
//     // log.i('getUserForEmail: EmailID: $emailAddress');
//     assert(emailAddress != null && emailAddress.isNotEmpty,
//         'User Email cannot be null or empty');

//     UserModel userModel;
//     DocumentSnapshot documentSnapshot = await CollectionRef
//         .users
//         .doc(emailAddress)
//         .get();

//     if (documentSnapshot == null || documentSnapshot.data == null) {
//       return null;
//     }
//     userModel = UserModel.fromMap(documentSnapshot.data);

//     return userModel;
//   }

//   /// get user by seva ID [sevaUserId] as stream
//   Stream<UserModel> getUserForIdStream({@required String sevaUserId}) async* {
//     // log.i('getUserForIdStream: SevaUserID: $sevaUserId');
//     assert(sevaUserId != null && sevaUserId.isNotEmpty,
//         "Seva UserId cannot be null or empty");

//     var data = CollectionRef
//         .users
//         .where('sevauserid', isEqualTo: sevaUserId)
//         .snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
//         handleData: (snapshot, userSink) async {
//           DocumentSnapshot documentSnapshot = snapshot.documents[0];
//           UserModel model = UserModel.fromMap(documentSnapshot.data);

//           DocumentSnapshot walletSnapshot = await CollectionRef
//               .collection('wallet')
//               .doc(model.email)
//               .get();

//           model.sevaUserID = sevaUserId;
//           userSink.add(model);
//         },
//       ),
//     );
//   }

//   /// get user by email ID [userEmailAddress] as stream
//   Stream<UserModel> getUserForEmailStream(String userEmailAddress) async* {
//     // log.i('getUserForEmailStream: EmailID: $userEmailAddress');
//     assert(userEmailAddress != null && userEmailAddress.isNotEmpty,
//         'User Email cannot be null or empty');

//     var userDataStream = CollectionRef
//         .users
//         .doc(userEmailAddress)
//         .snapshots();

//     yield* userDataStream.transform(
//       StreamTransformer<DocumentSnapshot, UserModel>.fromHandlers(
//         handleData: (snapshot, userSink) {
//           UserModel model = UserModel.fromMap(snapshot.data);
//           model.sevaUserID = snapshot.id;
//           userSink.add(model);
//         },
//       ),
//     );
//   }
// }
