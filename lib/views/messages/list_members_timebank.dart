import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

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
  var data = CollectionRef.timebank
      .where('timebankId', isEqualTo: timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (querySnapshot, timebankCodeSink) {
        List<TimebankModel> timebanks = [];
        querySnapshot.docs.forEach((documentSnapshot) {
          timebanks.add(TimebankModel.fromMap(
            documentSnapshot.data(),
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
  return CollectionRef.timebank.doc(timebankId).get().then((timebankModel) {
    return TimebankModel.fromMap(timebankModel.data());
  }).catchError((onError) {
    return onError;
  });
}
