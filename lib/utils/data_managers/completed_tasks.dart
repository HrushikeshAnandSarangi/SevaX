import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/tasks_card_wrapper.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../../../labels.dart';

class CompletedTasks {
  static Stream<List<RequestModel>> getCompletedAttendeesFromOneToManyRequests({
    String loggedInMemberEmail,
  }) async* {
    yield* CollectionRef.requests
        .where('oneToManyRequestAttenders', arrayContains: loggedInMemberEmail)
        .where('request_end', isLessThan: DateTime.now().millisecondsSinceEpoch)
        // .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
                handleData: (data, sink) {
      List<RequestModel> requestList = [];
      data.docs.forEach((element) {
        requestList.add(RequestModel.fromMap(element.data()));
      });
      return sink.add(requestList);
    }));
  }

  static Stream<List<RequestModel>> getCompletedOneToManyRequestsForSpeaker({
    String loggedInMemberEmail,
  }) async* {
    logger.e('SPEAKER COMPLETED CHECKS 1:  ===> ');
    yield* CollectionRef.requests
        .where('approvedUsers', arrayContains: loggedInMemberEmail)
        // .where('request_end', isLessThan: DateTime.now().millisecondsSinceEpoch)
        .where('requestType', isEqualTo: "ONE_TO_MANY_REQUEST")
        .where('accepted', isEqualTo: true)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
                handleData: (data, sink) {
      List<RequestModel> requestListSpeakers = [];
      data.docs.forEach((element) {
        requestListSpeakers.add(RequestModel.fromMap(element.data()));
        logger.e('SPEAKER COMPLETED CHECKS 2:  ===> ' +
            (element.data()['title']).toString());
      });
      return sink.add(requestListSpeakers);
    }));
  }

  static Stream<List<OfferModel>> getCompletedOneToManyOffersCreated(
    String loggedInmemberEmail,
  ) async* {
    yield* CollectionRef.offers
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('email', isEqualTo: loggedInmemberEmail)
        .where('groupOfferDataModel.endDate',
            isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> oneToManyOffers = [];

        data.docs.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data());
          oneToManyOffers.add(offerModel);
        });
        sink.add(oneToManyOffers);
      },
    ));
  }

  static Stream<List<OfferModel>> getCompletedSignedUpOffersStream(
      String loggedInmemberId) async* {
    yield* CollectionRef.offers
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('groupOfferDataModel.signedUpMembers',
            arrayContains: loggedInmemberId)
        .where('groupOfferDataModel.endDate',
            isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> oneToManyOffers = [];

        data.docs.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data());
          oneToManyOffers.add(offerModel);
        });

        sink.add(oneToManyOffers);
      },
    ));
  }

  static Stream<Object> getCompletedTasks({
    loggedinMemberEmail,
    loggedInmemberId,
  }) {
    return CombineLatestStream.combine5(
        FirestoreManager.getCompletedRequestStream(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getCompletedSignedUpOffersStream(loggedInmemberId),
        getCompletedOneToManyOffersCreated(loggedinMemberEmail),
        getCompletedAttendeesFromOneToManyRequests(
            loggedInMemberEmail: loggedinMemberEmail),
        getCompletedOneToManyRequestsForSpeaker(
            loggedInMemberEmail: loggedinMemberEmail),
        (pendingClaims, acceptedOneToManyOffers, oneToManyOffersCreated,
                signedUpOneToManyRequests, completedSpeakerOneToManyRequests) =>
            [
              pendingClaims,
              acceptedOneToManyOffers,
              oneToManyOffersCreated,
              signedUpOneToManyRequests,
              completedSpeakerOneToManyRequests,
            ]);
  }

  static List<Widget> classifyCompletedTasks({
    @required List<dynamic> completedSink,
    @required BuildContext context,
  }) {
    List<TasksCardWrapper> tasksList = [];
    List<RequestModel> requestList = completedSink[0];
    requestList.forEach((model) {
      if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == false) {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              title: model.title,
              subTitle: model.description,
              timeInMilliseconds: model.requestStart,
              onTap: () async {},
              tag: S.of(context).one_to_many_request_speaker,
            ),
            taskTimestamp: model.requestStart,
          ),
        );
      } else if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == true) {
        //
      } else if (model.requestType == RequestType.BORROW &&
          model.accepted == true) {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              title: model.title,
              subTitle: L.of(context).lent_to + model.fullName,
              timeInMilliseconds: model.requestStart,
              onTap: () async {},
              tag: L.of(context).borrow_request_lender,
            ),
            taskTimestamp: model.requestStart,
          ),
        );
      } else {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              timeInMilliseconds: model.requestStart,
              tag: S.of(context).time_request_volunteer,
              subTitle: model.description,
              title: model.title,
              onTap: () async {},
            ),
            taskTimestamp: model.requestStart,
          ),
        );
      }
    });

    //Signed up One to many Offers attendde
    List<OfferModel> offersList = completedSink[1];
    offersList.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {},
            title: element.groupOfferDataModel.classTitle,
            subTitle: element.groupOfferDataModel.classDescription,
            tag: S.of(context).one_to_many_offer_attende,
            timeInMilliseconds: element.groupOfferDataModel.startDate,
          ),
          taskTimestamp: element.groupOfferDataModel.startDate,
        ),
      );
    });

    //Created One to many Offers
    List<OfferModel> createdOneToManyOffers = completedSink[2];
    createdOneToManyOffers.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {},
            title: element.groupOfferDataModel.classTitle,
            subTitle: element.groupOfferDataModel.classDescription,
            tag: S.of(context).one_to_many_offer_speaker,
            timeInMilliseconds: element.groupOfferDataModel.startDate,
          ),
          taskTimestamp: element.groupOfferDataModel.startDate,
        ),
      );
    });

    //Attendee for one to many request
    List<RequestModel> acceptedOneToManyRequests = completedSink[3];
    acceptedOneToManyRequests.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {},
            title: element.title,
            subTitle: element.description,
            tag: S.of(context).one_to_many_request_attende,
            timeInMilliseconds: element.requestStart,
          ),
          taskTimestamp: element.requestStart,
        ),
      );
    });

    //Speakers for completed one to many requests
    List<RequestModel> speakerCompletedOneToManyRequests = completedSink[4];
    speakerCompletedOneToManyRequests.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {},
            title: element.title,
            subTitle: element.description,
            tag: S.of(context).one_to_many_request_attende,
            timeInMilliseconds: element.requestStart,
          ),
          taskTimestamp: element.requestStart,
        ),
      );
    });
    tasksList.sort((a, b) => b.taskTimestamp.compareTo(a.taskTimestamp));
    return tasksList;
  }

  static Future oneToManySpeakerCompletesRequest(
      BuildContext context, RequestModel requestModel) async {
    NotificationsModel notificationModel = NotificationsModel(
        timebankId: requestModel.timebankId,
        targetUserId: requestModel.sevaUserId,
        data: requestModel.toMap(),
        type: NotificationType.OneToManyRequestCompleted,
        id: utils.Utils.getUuid(),
        isRead: false,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: requestModel.communityId,
        isTimebankNotification: true);

    await CollectionRef.timebank
        .doc(notificationModel.timebankId)
        .collection('notifications')
        .doc(notificationModel.id)
        .set(notificationModel.toMap());

    await CollectionRef.requests.doc(requestModel.id).update({
      'isSpeakerCompleted': true,
    });

    await FirestoreManager
        .readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion(
      requestModel: requestModel,
      userEmail: SevaCore.of(context).loggedInUser.email,
      fromNotification: false,
    );
  }

  static Future<void> showMyTaskDialog({
    BuildContext context,
    @required String title,
    @required String subTitle,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(subTitle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).dismiss),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
