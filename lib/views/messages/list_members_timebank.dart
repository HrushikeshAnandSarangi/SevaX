import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class ListMambersForNewChat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ListMambersForNewChatState();
  }
}

class ListMambersForNewChatState extends State<ListMambersForNewChat> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Title"),
        ),
        body: getTimebankMembers(),
      ),
    );
  }
}

Widget getTimebankMembers() {
  var context;
  FirestoreManager.getTimeBankForId(
          timebankId: SevaCore.of(context).loggedInUser.currentTimebank)
      .then((timebank) {
    print("successfully fetched timebank data");

    return Text("From then");
  });
}

Widget getUserWidget(UserModel user) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          user.photoURL ?? defaultUserImageURL,
        ),
      ),
      title: Text(user.fullname),
      subtitle: Text(user.email),
    ),
  );
}

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
