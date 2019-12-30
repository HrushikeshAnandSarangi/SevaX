import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';

import 'chat_data_manager.dart';

Future<void> createJoinRequest({@required JoinRequestModel model}) async {
  Query query = Firestore.instance
      .collection('join_requests')
      .where('entity_id', isEqualTo: model.entityId)
      .where('user_id', isEqualTo: model.userId);
  QuerySnapshot snapshot = await query.getDocuments();
  DocumentSnapshot document =
      snapshot.documents?.length > 0 && snapshot.documents != null
          ? snapshot.documents.first
          : null;
  if (document != null)
    return await Firestore.instance
        .collection('join_requests')
        .document(document.documentID)
        .setData(model.toMap(), merge: true);

  //create a notification

  return await Firestore.instance
      .collection('join_requests')
      .document()
      .setData(model.toMap(), merge: true);
}

Stream<List<JoinRequestModel>> getTimebankJoinRequest({
  @required String timebankID,
}) async* {
  var data = Firestore.instance
      .collection('join_requests')
      .where('entity_type', isEqualTo: 'Timebank')
      .where('entity_id', isEqualTo: timebankID)
      //.where('accepted', isEqualTo: null)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
      handleData: (snapshot, joinrequestSink) {
        List<JoinRequestModel> joinrequestList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            JoinRequestModel model =
                JoinRequestModel.fromMap(documentSnapshot.data);
            if (model.accepted == null) joinrequestList.add(model);
          },
        );
        joinrequestSink.add(joinrequestList);
      },
    ),
  );
}

//Get chats for a user
Stream<List<UserModel>> getRequestDetailsStream({
  @required String requestId,
}) async* {
  var data =
      Firestore.instance.collection('requests').document(requestId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, List<UserModel>>.fromHandlers(
      handleData: (snapshot, chatSink) async {
        var futures = <Future>[];
        List<UserModel> userModelList = [];
        userModelList.clear();

        // snapshot.da
        RequestModel model = RequestModel.fromMap(snapshot.data);
        model.acceptors.forEach((member) {
          futures.add(getUserInfo(member));
        });

        // snapshot.documents.forEach(
        //   (documentSnapshot) async {
        //     ChatModel model = ChatModel.fromMap(documentSnapshot.data);

        //     if ((model.user1 == email || model.user2 == email) &&
        //         model.lastMessage != null &&
        //         model.rootTimebank == FlavorConfig.values.timebankId &&
        //         !model.softDeletedBy.contains(
        //           email,
        //         )) {
        //       if (model.user1 == email) {
        //         futures.add(getUserInfo(model.user2));
        //       }
        //       if (model.user2 == email) {
        //         futures.add(getUserInfo(model.user1));
        //       }
        //       chatlist.add(model);
        //       // print("Chat list size ${chatlist.length}");
        //     }

        //     // email = "anitha.beberg@gmail.com";
        //     // if ((model.user1 == "anitha.beberg@gmail.com" ||
        //     //         model.user2 == "anitha.beberg@gmail.com") &&
        //     //     model.lastMessage != null &&
        //     //     model.rootTimebank == FlavorConfig.values.timebankId) {
        //     //   if (model.user1 == email) {
        //     //     futures.add(getUserInfo(model.user2));
        //     //   }
        //     //   if (model.user2 == email) {
        //     //     futures.add(getUserInfo(model.user1));
        //     //   }
        //     //   chatlist.add(model);
        //     // }
        //   },
        // );
        await Future.wait(futures).then((onValue) {
          var i = 0;
          while (i < userModelList.length) {
            userModelList.add(UserModel.fromDynamic(onValue[i]));
            i++;
          }

          chatSink.add(userModelList);
        });
      },
    ),
  );
}

// Stream<List<UserModel>> getRequestStatusStream({
//   @required String requestId,
// }) async {
//   Firestore.instance.collection('requests').document(requestId).get().then(
//     (requestDetails) async {
//       var futures = <Future>[];
//       RequestModel model = RequestModel.fromMap(
//         requestDetails.data,
//       );

//       model.approvedUsers.forEach((membersId) {
//         futures.add(
//           Firestore.instance
//               .collection("users")
//               .document(membersId)
//               .get()
//               .then((onValue) {
//             return onValue;
//           }),
//         );
//       });

//       List<UserModel> usersRequested = List();
//       await Future.wait(futures).then((onValue) {
//         for (int i = 0; i < model.approvedUsers.length; i++) {
//           var user = UserModel.fromDynamic(onValue[i]);
//           usersRequested.add(user);
//         }
//         print(
//             "return 0 ----------------------------------- ${usersRequested.length}");
//         return usersRequested;
//       });

//       return usersRequested;
//     },
//   );
//   // 9797799469
//   List<UserModel> usersRequested = List();
//   return usersRequested;
// }
