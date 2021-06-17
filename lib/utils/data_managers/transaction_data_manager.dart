// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:meta/meta.dart';
// import 'package:sevaexchange/models/request_model.dart';
// import 'package:sevaexchange/models/transaction_model.dart';
// import 'package:sevaexchange/repositories/firestore_keys.dart';

// Future makeTransaction({
//   @required TransactionModel transaction,
// }) async {
//   DocumentSnapshot fromDocument =
//       await CollectionRef.collection('wallet').doc(transaction.from).get();

//   DocumentSnapshot toDocument =
//       await CollectionRef.collection('wallet').doc(transaction.to).get();

//   num fromBalance;
//   if (fromDocument != null && fromDocument.data != null) {
//     fromBalance = fromDocument.data['currentBalance'];
//   }
//   fromBalance = (fromBalance ?? 0) - transaction.credits;

//   num toBalance;
//   if (toDocument != null && toDocument.data != null) {
//     toBalance = toDocument.data['currentBalance'];
//   }
//   toBalance = (toBalance ?? 0) + transaction.credits;

//   await CollectionRef.collection('wallet')
//       .doc(transaction.from)
//       .set({'currentBalance': fromBalance});

//   await CollectionRef.collection('wallet')
//       .doc(transaction.to)
//       .set({'currentBalance': toBalance});
// }

// Stream<List<RequestModel>> getTransactionsForUser({
//   @required String userId,
// }) async* {
//   var credit =
//       await CollectionRef.requests.where('sevauserid', isEqualTo: userId).get();

//   var debit = await CollectionRef.requests
//       .where('approvedUserId', isEqualTo: userId)
//       .get();

//   List<RequestModel> requestModelList = [];

//   // TODO: Fix this hack

// //  credit.docs.forEach((documentSnapshot) {
// //    RequestModel requestModel = RequestModel.fromMap(documentSnapshot.data);
// //    requestModel.id = documentSnapshot.id;
// //    if (requestModel.transaction != null) {
// //      requestModelList.add(requestModel);
// //    }
// //  });
// //
// //  debit.docs.forEach((documentSnapshot) {
// //    RequestModel requestModel = RequestModel.fromMap(documentSnapshot.data);
// //    requestModel.id = documentSnapshot.id;
// //    if (requestModel.transaction != null) {
// //      requestModelList.add(requestModel);
// //    }
// //  });
// //
// //  requestModelList.sort(
// //    (b, a) => a.transaction.timestamp.compareTo(b.transaction.timestamp),
// //  );

//   yield requestModelList;
// }
