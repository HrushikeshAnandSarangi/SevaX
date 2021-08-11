import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/tasks_card_wrapper.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../../../flavor_config.dart';
import '../../../../labels.dart';

class PendingTasks {
  static Stream<List<OfferModel>> getAcceptedOffers(
    String loggedInmemberId,
  ) async* {
    yield* CollectionRef.offers
        .where('offerType', isEqualTo: 'INDIVIDUAL_OFFERS')
        .where('individualOfferDataModel.offerAcceptors',
            arrayContains: loggedInmemberId)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> individualOffers = [];

        data.docs.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data());
          individualOffers.add(offerModel);
        });
        sink.add(individualOffers);
      },
    ));
  }

  static Stream<List<TimeOfferParticipantsModel>> getAcceptedOffersStatus(
      String loggedInmemberId) async* {
    yield* FirebaseFirestore.instance
        .collectionGroup('offerAcceptors')
        .where('status', isEqualTo: 'ACCEPTED')
        .where('participantDetails.sevauserid', isEqualTo: loggedInmemberId)
        .snapshots()
        .transform(StreamTransformer<QuerySnapshot,
            List<TimeOfferParticipantsModel>>.fromHandlers(
      handleData: (data, sink) {
        List<TimeOfferParticipantsModel> oneToManyOffers = [];
        data.docs.forEach((element) {
          var participantModel =
              TimeOfferParticipantsModel.fromJSON(element.data());
          oneToManyOffers.add(participantModel);
        });
        sink.add(oneToManyOffers);
      },
    ));
  }

  static Stream<Object> getPendingTasks({
    loggedinMemberEmail,
    loggedInmemberId,
  }) {
    return CombineLatestStream.combine4(
      FirestoreManager.getNotAcceptedRequestStream(
        userEmail: loggedinMemberEmail,
        userId: loggedInmemberId,
      ),
      getAcceptedOffersStatus(loggedinMemberEmail),
      FirestoreManager.getSpeakerClaimedCompletionRequestStream(
        userEmail: loggedinMemberEmail,
        userId: loggedInmemberId,
      ),
      getPendingCreditRequests(
        loggedInMemberId: loggedInmemberId,
        loggedInUserEmail: loggedinMemberEmail,
      ),
      (
        pendingClaims,
        acceptedIndividualOffers,
        getSpeakerClaimedCompletionRequestStream,
        pendingCreditRequests,
        // oneToManyOffersCreated,
      ) =>
          [
        pendingClaims,
        acceptedIndividualOffers,
        getSpeakerClaimedCompletionRequestStream,
        pendingCreditRequests,
        // oneToManyOffersCreated,
      ],
    );
  }

  static List<Widget> classifyPendingTasks({
    @required List<dynamic> pendingSink,
    @required BuildContext context,
  }) {
    List<TasksCardWrapper> tasksList = [];
    List<RequestModel> requestList = pendingSink[0];
    requestList.forEach((model) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            title: model.title,
            subTitle: model.description,
            timeInMilliseconds: model.requestStart,
            onTap: () async {},
            tag: model.requestType == RequestType.ONE_TO_MANY_REQUEST
                ? S.of(context).one_to_many_attendee_request
                : model.requestType == RequestType.ONE_TO_MANY_OFFER
                    ? S.of(context).one_to_many_attendee_offer
                    : model.requestType == RequestType.TIME
                        ? S.of(context).time
                        : model.requestType == RequestType.GOODS
                            ? S.of(context).goods
                            : model.requestType == RequestType.CASH
                                ? S.of(context).cash
                                : model.requestType == RequestType.BORROW
                                    ? S.of(context).borrow
                                    : '',
          ),
          taskTimestamp: model.requestStart,
        ),
      );
    });

    // //Signed up Individual Offers
    List<TimeOfferParticipantsModel> offersList = pendingSink[1];
    offersList.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {},
            title: element.requestTitle,
            subTitle: '',
            tag: S.of(context).one_to_many_attendee_offer,
            timeInMilliseconds: element.requestEndDate,
          ),
          taskTimestamp: element.requestEndDate,
        ),
      );
    });

    // Speaker has claimed credits
    List<RequestModel> requestListSpeakerClaimed = pendingSink[2];
    requestListSpeakerClaimed.forEach((model) {
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
    });

    // Created One to many Offers
    // List<OfferModel> createdOneToManyOffers = pendingSink[2];
    // createdOneToManyOffers.forEach((element) {
    //   widgetList.add(ToDoCard(
    //     onTap: () => _showMyDialog(context),
    //     title: element.groupOfferDataModel.classTitle,
    //     subTitle: element.groupOfferDataModel.classDescription,
    //     tag: S.of(context).one_to_many_speaker,
    //     timeInMilliseconds: element.groupOfferDataModel.startDate,
    //   ));
    // });

    // Claims Made to cretor of requests
    List<RequestModel> pendingRequestClaims = pendingSink[3];
    pendingRequestClaims.forEach((model) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            title: model.title,
            subTitle: model.description,
            timeInMilliseconds: model.requestStart,
            onTap: () async {},
            tag: S.of(context).time_request_volunteer,
          ),
          taskTimestamp: model.requestStart,
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
            fromNotification: false);
  }

  static Stream<List<RequestModel>> getPendingCreditRequests({
    String loggedInUserEmail,
    String loggedInMemberId,
  }) async* {
    var data = CollectionRef.requests
        .where('approvedUsers', arrayContains: loggedInUserEmail)
        .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          List<RequestModel> requestModelList = [];
          snapshot.docs.forEach((documentSnapshot) {
            RequestModel model = RequestModel.fromMap(documentSnapshot.data());
            model.id = documentSnapshot.id;

            model.transactions?.forEach((transaction) {
              if (model.requestType == RequestType.TIME &&
                  transaction.to == loggedInMemberId &&
                  !transaction.isApproved) requestModelList.add(model);
            });
          });
          logger.d(requestModelList.length.toString() + "++++++++++++++");

          requestSink.add(requestModelList);
        },
      ),
    );
  }

  static Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
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
