import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/claimedRequestStatus.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import '../utils.dart';

Future<bool> fetchProtectedStatus(String timebankId) async {
  DocumentSnapshot timebank =
      await CollectionRef.timebank.doc(timebankId).get();
  return (timebank.data() as Map<String, dynamic>)['protected'];
}

Future<TimebankModel> fetchTimebankData(String timebankId) async {
  DocumentSnapshot timebank =
      await CollectionRef.timebank.doc(timebankId).get();
  return TimebankModel.fromMap(timebank.data() as Map<String, dynamic>);
}

//Fetch timebank from timebank id
Future<void> createAcceptRequestNotification({
  NotificationsModel? notificationsModel,
}) async {
  if (notificationsModel == null) return;
  var requestModel = RequestModel.fromMap(notificationsModel.data!);
  switch (requestModel.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      UserModel user =
          await getUserForId(sevaUserId: notificationsModel.targetUserId!);
      await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(notificationsModel.id)
          .set(notificationsModel.toMap());
      break;

    case RequestMode.TIMEBANK_REQUEST:
      await CollectionRef.timebank
          .doc(notificationsModel.timebankId)
          .collection('notifications')
          .doc(notificationsModel.id)
          .set(notificationsModel.toMap());
      break;
  }
}

Future<void> withdrawAcceptRequestNotification({
  NotificationsModel? notificationsModel,
  bool? isAlreadyApproved,
  UserModel? loggedInUser,
}) async {
  if (notificationsModel == null) return;
  RequestModel requestModel = RequestModel.fromMap(notificationsModel.data!);
  var withdrawlNotification = getApprovedMemberWithdrawingNotification(
    notificationsModel,
    loggedInUser!,
    requestModel,
  );
  switch (requestModel.requestMode) {
    case RequestMode.TIMEBANK_REQUEST:
      withdrawlNotification.isTimebankNotification = true;
      await CollectionRef.timebank
          .doc(requestModel.timebankId)
          .collection('notifications')
          .doc(withdrawlNotification.id)
          .set(withdrawlNotification.toMap());

      QuerySnapshot snapshotQuery = await CollectionRef.timebank
          .doc(notificationsModel.timebankId)
          .collection('notifications')
          .where('type', isEqualTo: 'RequestAccept')
          .where('data.id', isEqualTo: requestModel.id)
          .where('data.email', isEqualTo: requestModel.email)
          .where('senderUserId', isEqualTo: loggedInUser.sevaUserID)
          .get();
      snapshotQuery.docs.forEach(
        (document) async {
          await CollectionRef.timebank
              .doc(notificationsModel.timebankId)
              .collection('notifications')
              .doc(document.id)
              .delete();
        },
      );

      break;

    case RequestMode.PERSONAL_REQUEST:
      UserModel user =
          await getUserForId(sevaUserId: notificationsModel.targetUserId!);

      withdrawlNotification.isTimebankNotification = false;
      await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(withdrawlNotification.id)
          .set(withdrawlNotification.toMap());

      QuerySnapshot querySnapshot = await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .where('type', isEqualTo: 'RequestAccept')
          .where('data.id', isEqualTo: requestModel.id)
          .where('data.email', isEqualTo: requestModel.email)
          .get();
      querySnapshot.docs.forEach(
        (document) {
          CollectionRef.users
              .doc(user.email)
              .collection('notifications')
              .doc(document.id)
              .delete();
        },
      );

      break;
  }
}

NotificationsModel getApprovedMemberWithdrawingNotification(
  NotificationsModel notificationsModel,
  UserModel loggedInUser,
  RequestModel requestModel,
) {
  return NotificationsModel(
    communityId: notificationsModel.communityId,
    data: {
      'fullName': loggedInUser.fullname,
      'requestTite': requestModel.title,
      'requestId': requestModel.id,
    },
    id: Utils.getUuid(),
    isRead: false,
    senderUserId: notificationsModel.senderUserId,
    targetUserId: notificationsModel.targetUserId,
    timebankId: notificationsModel.timebankId,
    type: NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST,
  );
}

Future<QuerySnapshot> _getQueryForNotification({
  RequestModel? requestModel,
}) async {
  switch (requestModel!.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      return await CollectionRef.users
          .doc(requestModel.email)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('type', isEqualTo: 'RequestCompleted')
          .where('data.id', isEqualTo: requestModel.id)
          .get();

    case RequestMode.TIMEBANK_REQUEST:
      return CollectionRef.timebank
          .doc(requestModel.timebankId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('type', isEqualTo: 'RequestCompleted')
          .where('data.id', isEqualTo: requestModel.id)
          .get();

    default:
      return null!;
  }
}

Future<String> getNotificationId(
  UserModel user,
  RequestModel request,
) async {
  QuerySnapshot notifications = await _getQueryForNotification(
    requestModel: request,
  );

  var result = "";
  for (var i = 0; i < notifications.docs.length; i++) {
    var onValue = notifications.docs[i];
    var notification =
        NotificationsModel.fromMap(onValue.data() as Map<String, dynamic>);
    if (notification != null) {
      RequestModel _requestModel = RequestModel.fromMap(notification.data!);
      if (_requestModel != null) {
        if (_requestModel.id == request.id) {
          result = notification.id!;
          break;
        }
      }
    }
  }
  return result;
}

Future<void> removeAcceptRequestNotification({
  NotificationsModel? model,
  String? notificationId,
}) async {
  var requestModel = RequestModel.fromMap(model!.data!);
  switch (requestModel.requestMode) {
    case RequestMode.TIMEBANK_REQUEST:
      await CollectionRef.timebank
          .doc(model.timebankId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
      break;

    case RequestMode.PERSONAL_REQUEST:
      UserModel user = await getUserForId(sevaUserId: model.senderUserId!);
      await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      break;
  }
}

Future<void> createRequestApprovalNotification({
  NotificationsModel? model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model!.targetUserId!);
  CollectionRef.users
      .doc(user.email)
      .collection('notifications')
      .doc(model.id)
      .set(model.toMap());
}

Future<void> createApprovalNotificationForMember({
  NotificationsModel? model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model!.targetUserId!);
  CollectionRef.users
      .doc(user.email)
      .collection('notifications')
      .doc(model.id)
      .set(model.toMap());
}

Future<void> createTaskCompletedNotification(
    {NotificationsModel? model}) async {
  var requestModel = RequestModel.fromMap(model!.data!);
  switch (requestModel.requestMode) {
    case RequestMode.PERSONAL_REQUEST:
      UserModel user = await getUserForId(sevaUserId: model!.targetUserId!);
      log('User Email to Notify : ' + user.email!);
      await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap(), SetOptions(merge: true));
      break;

    case RequestMode.TIMEBANK_REQUEST:
      log('Timabank ID:  ' + model.timebankId!);
      log('Model ID: ' + model.id!);
      await CollectionRef.timebank
          .doc(model.timebankId)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap(), SetOptions(merge: true));
      break;
  }
}

Future<void> processLoans({
  String? timebankId,
  String? userId,
  String? to,
  num? credits,
  required String communityId,
}) async {
  // get all previous loans of this user with in the timebank;
  var loans = await CollectionRef.transactions
      .where('timebankid', isEqualTo: timebankId)
      .where('type', isEqualTo: "ADMIN_DONATE_TOUSER")
      .where('to', isEqualTo: to)
      .get()
      .then(
    (onValue) {
      return onValue.docs;
    },
  ).catchError((onError) {
    return null;
  });
  var loanamount = 0;
  if (loans != null) {
    for (var i = 0; i < loans.length; i++) {
      TransactionModel temp =
          TransactionModel.fromMap(loans[i].data() as Map<String, dynamic>);
      loanamount += temp.credits!.toInt();
    }
  }

  // get all paid loans of this user with in the timebank;
  var paidloans = await CollectionRef.transactions
      .where('timebankid', isEqualTo: timebankId)
      .where('type', isEqualTo: "USER_PAYLOAN_TOTIMEBANK")
      .where('from', isEqualTo: to)
      .get()
      .then(
    (onValue) {
      return onValue.docs;
    },
  ).catchError((onError) {
    return null;
  });
  var paidamount = 0;
  if (paidloans != null) {
    for (var i = 0; i < paidloans.length; i++) {
      TransactionModel temp =
          TransactionModel.fromMap(loans[i].data() as Map<String, dynamic>);
      paidamount += temp.credits!.toInt();
    }
  }
  // pay the pending loan amount
  if (loanamount > paidamount) {
    var tobepaid = loanamount - paidamount;
    var paying = tobepaid > (credits ?? 0) ? credits : tobepaid;

    transactionBloc.createNewTransaction(
        to,
        timebankId,
        DateTime.now().millisecondsSinceEpoch,
        paying,
        true,
        "USER_PAYLOAN_TOTIMEBANK",
        null,
        timebankId,
        communityId: communityId,
        toEmailORId: timebankId!,
        fromEmailORId: to!);
  }
}

Future<void> createTaskCompletedApprovedNotification({
  NotificationsModel? model,
}) async {
  var requestModel = RequestModel.fromMap(model!.data!);

  UserModel user = await getUserForId(sevaUserId: model.targetUserId!);

  // switch (requestModel.requestMode) {
  //   case RequestMode.PERSONAL_REQUEST:
  //     break;
  //   case RequestMode.TIMEBANK_REQUEST:
  //     var timebankModel = await fetchTimebankData(model.timebankId);
  //     requestModel.fullName = timebankModel.name;
  //     requestModel.photoUrl = timebankModel.photoUrl;
  //     model.data = requestModel.toMap();
  //     break;
  // }

  await CollectionRef.users
      .doc(user.email)
      .collection('notifications')
      .doc(model.id)
      .set(model.toMap());
}

// Future<void> createTransactionNotification({
//   NotificationsModel model,
// }) async {
//   var requestModel = RequestModel.fromMap(model.data);

//   switch (requestModel.requestMode) {
//     case RequestMode.TIMEBANK_REQUEST:
//       await CollectionRef
//           .timebank
//           .doc(model.timebankId)
//           .collection('notifications')
//           .doc(model.id)
//           .set(model.toMap());
//       break;
//     case RequestMode.PERSONAL_REQUEST:
//       UserModel user = await getUserForId(sevaUserId: model.targetUserId);
//       await CollectionRef
//           .users
//           .doc(user.email)
//           .collection('notifications')
//           .doc(model.id)
//           .set(model.toMap());
//       break;
//   }
// }

Future saveRequestFinalAction({ClaimedRequestStatusModel? model}) async {
  try {
    await CollectionRef.claimedRequestStatus
        .doc(model!.id)
        .update({model.timestamp.toString(): model.toMap()});
  } on Exception catch (exception) {
    await CollectionRef.claimedRequestStatus
        .doc(model!.id)
        .set({model.timestamp.toString(): model.toMap()});
  }
}

Future<void> offerAcceptNotification({
  NotificationsModel? model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model!.targetUserId!);

  bool isTimeBankNotification = await fetchProtectedStatus(model.timebankId!);
  isTimeBankNotification
      ? await CollectionRef.timebank
          .doc(model.timebankId)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap())
      : await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap());
}

Future<void> offerRejectNotification({
  NotificationsModel? model,
}) async {
  UserModel user = await getUserForId(sevaUserId: model!.targetUserId!);

  bool isTimeBankNotification = await fetchProtectedStatus(model.timebankId!);
  isTimeBankNotification
      ? await CollectionRef.timebank
          .doc(model.timebankId)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap())
      : await CollectionRef.users
          .doc(user.email)
          .collection('notifications')
          .doc(model.id)
          .set(model.toMap());
}

Future<void> readUserNotification(
  String notificationId,
  String userEmail,
) async {
  await CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .doc(notificationId)
      .update({
    'isRead': true,
  });
}

Future<void> unreadUserNotification(
    String notificationId, String userEmail) async {
  await CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .doc(notificationId)
      .update({
    'isRead': false,
  });
}

Future<void> readTimeBankNotification({
  String? notificationId,
  String? timebankId,
}) async {
  await CollectionRef.timebank
      .doc(timebankId)
      .collection('notifications')
      .doc(notificationId)
      .update({
    'isRead': true,
  });
}

//to remove the notification if creator completes from request about page
//or approves from completion page instead
Future<void> readTimeBankNotificationOneToManyCreatorRejectedCompletion({
  required RequestModel requestModel,
  required bool fromNotification,
}) async {
  if (!fromNotification) {
    logger
        .e('-------------RequestModel id 1: ${requestModel.id}--------------');
    logger.e(
        '-------------Timebank ID 1: ${requestModel.timebankId}--------------');
    QuerySnapshot<Map<String, dynamic>> snapshotQuery = await CollectionRef
        .timebank
        .doc(requestModel.timebankId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('type', isEqualTo: 'OneToManyRequestCompleted')
        .where('data.id', isEqualTo: requestModel.id)
        .get();
    for (var document in snapshotQuery.docs) {
      await CollectionRef.timebank
          .doc(requestModel.timebankId)
          .collection('notifications')
          .doc(document.id)
          .update({
        'isRead': true,
      });
    }
  }
}

//to remove the notification if speaker accepts from request about page instead
Future<void> readUserNotificationOneToManyWhenSpeakerIsInvited({
  required RequestModel requestModel,
  required String userEmail,
  required bool fromNotification,
}) async {
  if (!fromNotification) {
    logger.e('-------------User Email: ${userEmail}--------------');
    logger.e('-------------RequestModel id: ${requestModel.id}--------------');
    QuerySnapshot snapshotQuery = await CollectionRef.users
        .doc(userEmail)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('type', isEqualTo: 'OneToManyRequestAccept')
        .where('data.id', isEqualTo: requestModel.id)
        .get();
    snapshotQuery.docs.forEach(
      (document) async {
        await CollectionRef.users
            .doc(userEmail)
            .collection('notifications')
            .doc(document.id)
            .update({
          'isRead': true,
        });
      },
    );
  } else {
    return null;
  }
}

//to remove the notification if speaker gets rejected notification and
//accepts from tasks or request about
Future<void> readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion({
  required RequestModel requestModel,
  required String userEmail,
  required bool fromNotification,
}) async {
  logger.e('HEREEE 0');
  if (!fromNotification) {
    logger.e('HEREEE 1');
    logger.e('-------------User Email: ${userEmail}--------------');
    logger.e('-------------RequestModel id: ${requestModel.id}--------------');
    try {
      QuerySnapshot snapshotQuery = await CollectionRef.users
          .doc(userEmail)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .where('type', isEqualTo: 'OneToManyCreatorRejectedCompletion')
          .where('data.id', isEqualTo: requestModel.id)
          .get();
      snapshotQuery.docs.forEach(
        (document) async {
          await CollectionRef.users
              .doc(userEmail)
              .collection('notifications')
              .doc(document.id)
              .update({
            'isRead': true,
          });
        },
      );
    } catch (error) {
      logger.e('Error:' + error.toString());
    }
  } else {
    logger.e('No OneToManyCreatorRejectedCompletion notification to delete');
  }
}

//Borrow Requests - to remove the notification if Lender acknowledges item/place received back from tasks page
Future<void> readLenderNotificationIfAcceptedFromTasks({
  required RequestModel requestModel,
  required String userEmail,
  required bool fromNotification,
}) async {
  if (!fromNotification) {
    logger.e('-------------User Email: ${userEmail}--------------');
    logger.e('-------------RequestModel id: ${requestModel.id}--------------');
    QuerySnapshot snapshotQuery = await CollectionRef.users
        .doc(userEmail)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('type', isEqualTo: 'NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK')
        .where('data.id', isEqualTo: requestModel.id)
        .get();
    snapshotQuery.docs.forEach(
      (document) async {
        await CollectionRef.users
            .doc(userEmail)
            .collection('notifications')
            .doc(document.id)
            .update({
          'isRead': true,
        });
      },
    );
  } else {
    return null;
  }
}

//Borrow Request - reads it if accepted from request details page
Future<String> readBorrowerRequestAcceptNotification({
  required RequestModel requestModel,
  required BorrowAcceptorModel borrowAcceptorModel,
  required bool fromNotification,
}) async {
  if (!fromNotification) {
    logger.e(
        '-------------User Email: ${borrowAcceptorModel.acceptorEmail}--------------');
    logger.e('-------------RequestModel id: ${requestModel.id}--------------');
    QuerySnapshot snapshotQuery = await CollectionRef.timebank
        .doc(requestModel.timebankId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .where('type', isEqualTo: 'RequestAccept')
        .where('data.id', isEqualTo: requestModel.id)
        .where('senderUserId', isEqualTo: borrowAcceptorModel.acceptorId)
        .get();
    // snapshotQuery.docs.forEach(
    //   (document) async {
    //     await CollectionRef.timebank
    //         .doc(requestModel.timebankId)
    //         .collection('notifications')
    //         .doc(document.id)
    //         .update({
    //       'isRead': true,
    //     });
    //   },
    // );
    if (snapshotQuery.docs.length >= 1) {
      return snapshotQuery.docs[0].id;
    } else {
      return '';
    }
  } else {
    return null!;
  }
}

Stream<List<NotificationsModel>> getNotifications({
  String? userEmail,
  required String communityId,
}) async* {
  var data = CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];
        querySnapshot.docs.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          notifications.add(model);
        });
        notifications
            .sort((a, b) => (b.timestamp ?? 0) > (a.timestamp ?? 0) ? 1 : -1);
        notificationSink.add(notifications);
      },
    ),
  );
}

Future updateUserCommunity({
  String? communityId,
  String? userEmail,
}) async {
  if (userEmail != null) {
    await CollectionRef.users.doc(userEmail).update({
      'communities': FieldValue.arrayUnion([communityId]),
    });
  }
}

Future addMemberToTimebank({
  String? timebankId,
  String? newUserSevaId,
}) async {
  await CollectionRef.timebank.doc(timebankId).update({
    'members': FieldValue.arrayUnion([newUserSevaId]),
  });
}

Stream<List<NotificationsModel>> getNotificationsForTimebank({
  String? timebankId,
}) async* {
  var data = CollectionRef.timebank
      .doc(timebankId)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .orderBy('timestamp', descending: true)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];

        querySnapshot.docs.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          if (FlavorConfig.appFlavor != Flavor.APP) {
            if (model.type != NotificationType.TransactionDebit)
              // for other falvour of the app except
              notifications.add(model);
          } else {
            if (model.type == NotificationType.RequestAccept ||
                model.type == NotificationType.JoinRequest ||
                model.type == NotificationType.TypeMemberExitTimebank ||
                model.type == NotificationType.RequestCompleted ||
                model.type ==
                    NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED ||
                model.type ==
                    NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK ||
                model.type == NotificationType.TYPE_DELETION_REQUEST_OUTPUT ||
                model.type == NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER ||
                model.type == NotificationType.ADMIN_PROMOTED_AS_ORGANIZER ||
                model.type == NotificationType.MEMBER_PROMOTED_AS_ADMIN ||
                model.type == NotificationType.MEMBER_DEMOTED_FROM_ADMIN) {
              notifications.add(model);
            }
          }
        });
        notifications
            .sort((a, b) => (b.timestamp ?? 0) > (a.timestamp ?? 0) ? 1 : -1);

        notificationSink.add(notifications);
      },
    ),
  );
}

Future<bool> isUnreadNotification(String userEmail) async {
  bool isNotification = false;
  List<NotificationsModel> notifications = [];
  await CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      NotificationsModel model = NotificationsModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>,
      );
      if (model.type != NotificationType.TransactionDebit)
        notifications.add(model);
    });
    if (notifications.length > 0) isNotification = true;
  });
  return isNotification;
}

Future updateNotificationStatusByAdmin(
    notificationType, timebankId, userModel) async {}

Future<List<NotificationsModel>> getCompletedNotifications(
  String userEmail,
  String communityId,
) async {
  List<NotificationsModel> res = [];
  await CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
      NotificationsModel model = NotificationsModel.fromMap(
        documentSnapshot.data() as Map<String, dynamic>,
      );
      if (model.type == NotificationType.RequestCompleted) res.add(model);
    });
  });
  return res;
}

Stream<List<NotificationsModel>> getCompletedNotificationsStream(
  String userEmail,
  String communityId,
) async* {
  var data = CollectionRef.users
      .doc(userEmail)
      .collection('notifications')
      .where('isRead', isEqualTo: false)
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .where(
        'communityId',
        isEqualTo: communityId,
      )
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
        List<NotificationsModel>>.fromHandlers(
      handleData: (querySnapshot, notificationSink) {
        List<NotificationsModel> notifications = [];

        querySnapshot.docs.forEach((documentSnapshot) {
          NotificationsModel model = NotificationsModel.fromMap(
            documentSnapshot.data() as Map<String, dynamic>,
          );
          if (model.type == NotificationType.RequestCompletedApproved) {
            notifications.add(model);
          }
        });
        notificationSink.add(notifications);
      },
    ),
  );
}

Future<String> getQueryOfferPersonalNotification(
    {String? offerId, String? email, String? notificationType}) async {
  String? notifId = '';

  await CollectionRef.userNotification(email!)
      .where('isRead', isEqualTo: false)
      .where('type', isEqualTo: notificationType)
      .where('data.id', isEqualTo: offerId)
      .get()
      .then((value) {
    NotificationsModel nModel = NotificationsModel.fromMap(
        value.docs.first?.data() as Map<String, dynamic>);
    // logger.e("${nModel.toString()}");
    notifId = nModel?.id;
  });

  return notifId!;
}
