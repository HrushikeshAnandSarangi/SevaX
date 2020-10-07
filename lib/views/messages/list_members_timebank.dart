import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

// Widget getTimebankMembers() {
//   var context;
//   FirestoreManager.getTimeBankForId(
//           timebankId: SevaCore.of(context).loggedInUser.currentTimebank)
//       .then((timebank) {
//     return Text("From then");
//   });
// }

// Widget getUserWidget(UserModel user) {
//   return Card(
//     child: ListTile(
//       leading: CircleAvatar(
//         backgroundImage: NetworkImage(
//           user.photoURL ?? defaultUserImageURL,
//         ),
//       ),
//       title: Text(user.fullname),
//       subtitle: Text(user.email),
//     ),
//   );
// }

Stream<List<TimebankModel>> getTimebankDetails({
  String timebankId,
}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('timebankId', isEqualTo: timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (querySnapshot, timebankCodeSink) {
        List<TimebankModel> timebanks = [];
        querySnapshot.documents.forEach((documentSnapshot) {
          timebanks.add(TimebankModel.fromMap(
            documentSnapshot.data,
          ));
        });
        timebankCodeSink.add(timebanks);
      },
    ),
  );
}

Future<TimebankModel> getTimebankDetailsbyFuture({
  String timebankId,
}) async {
  return Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get()
      .then((timebankModel) {
    return TimebankModel.fromMap(timebankModel.data);
  }).catchError((onError) {
    return onError;
  });
}
