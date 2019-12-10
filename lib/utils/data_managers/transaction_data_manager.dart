import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:meta/meta.dart';

Future makeTransaction({
  @required TransactionModel transaction,
}) async {
  DocumentSnapshot fromDocument = await Firestore.instance
      .collection('wallet')
      .document(transaction.from)
      .get();

  DocumentSnapshot toDocument = await Firestore.instance
      .collection('wallet')
      .document(transaction.to)
      .get();

  num fromBalance;
  if (fromDocument != null && fromDocument.data != null) {
    fromBalance = fromDocument.data['currentBalance'];
  }
  fromBalance = (fromBalance ?? 0) - transaction.credits;

  num toBalance;
  if (toDocument != null && toDocument.data != null) {
    toBalance = toDocument.data['currentBalance'];
  }
  toBalance = (toBalance ?? 0) + transaction.credits;

  await Firestore.instance
      .collection('wallet')
      .document(transaction.from)
      .setData({'currentBalance': fromBalance});

  await Firestore.instance
      .collection('wallet')
      .document(transaction.to)
      .setData({'currentBalance': toBalance});
}

Stream<List<RequestModel>> getTransactionsForUser({
  @required String userId,
}) async* {
  var credit = await Firestore.instance
      .collection('requests')
      .where('sevauserid', isEqualTo: userId)
      .getDocuments();

  var debit = await Firestore.instance
      .collection('requests')
      .where('approvedUserId', isEqualTo: userId)
      .getDocuments();

  List<RequestModel> requestModelList = [];

  // TODO: Fix this hack

//  credit.documents.forEach((documentSnapshot) {
//    RequestModel requestModel = RequestModel.fromMap(documentSnapshot.data);
//    requestModel.id = documentSnapshot.documentID;
//    if (requestModel.transaction != null) {
//      requestModelList.add(requestModel);
//    }
//  });
//
//  debit.documents.forEach((documentSnapshot) {
//    RequestModel requestModel = RequestModel.fromMap(documentSnapshot.data);
//    requestModel.id = documentSnapshot.documentID;
//    if (requestModel.transaction != null) {
//      requestModelList.add(requestModel);
//    }
//  });
//
//  requestModelList.sort(
//    (b, a) => a.transaction.timestamp.compareTo(b.transaction.timestamp),
//  );

  yield requestModelList;
}
