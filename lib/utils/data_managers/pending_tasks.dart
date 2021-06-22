import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../labels.dart';

class PendingTasks {
  static Stream<List<OfferModel>> getAcceptedOffers(
    String loggedInmemberId,
  ) async* {
    yield* Firestore.instance
        .collection('offers')
        .where('offerType', isEqualTo: 'INDIVIDUAL_OFFERS')
        .where('individualOfferDataModel.offerAcceptors',
            arrayContains: loggedInmemberId)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> individualOffers = [];

        data.documents.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data);
          individualOffers.add(offerModel);
        });
        sink.add(individualOffers);
      },
    ));
  }

  static Stream<List<TimeOfferParticipantsModel>> getAcceptedOffersStatus(
      String loggedInmemberId) async* {
    yield* Firestore.instance
        .collectionGroup('offerAcceptors')
        .where('status', isEqualTo: 'ACCEPTED')
        .where('participantDetails.sevauserid',
            isEqualTo: "Q9cfkvDta9S2PVkeOD7l8C7cmID3")
        .snapshots()
        .transform(StreamTransformer<QuerySnapshot,
            List<TimeOfferParticipantsModel>>.fromHandlers(
      handleData: (data, sink) {
        List<TimeOfferParticipantsModel> oneToManyOffers = [];
        data.documents.forEach((element) {
          var participantModel =
              TimeOfferParticipantsModel.fromJSON(element.data);
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
    return CombineLatestStream.combine2(
      FirestoreManager.getNotAcceptedRequestStream(
        userEmail: loggedinMemberEmail,
        userId: loggedInmemberId,
      ),
      // getAcceptedOffers(loggedInmemberId),
      getAcceptedOffersStatus(loggedinMemberEmail),
      (pendingClaims, acceptedIndividualOffers
              // oneToManyOffersCreated,
              ) =>
          [
        pendingClaims,
        acceptedIndividualOffers,
        // oneToManyOffersCreated,
      ],
    );
  }

  static List<Widget> classifyPendingTasks({
    @required List<dynamic> pendingSink,
    @required BuildContext context,
  }) {
    List<Widget> widgetList = [];
    List<RequestModel> requestList = pendingSink[0];
    requestList.forEach((model) {
      widgetList.add(
        ToDoCard(
          title: model.title,
          subTitle: model.description,
          timeInMilliseconds: model.requestStart,
          onTap: null,
          tag: L.of(context).one_to_many_attende,
        ),
      );
    });

    // //Signed up Individual Offers
    List<TimeOfferParticipantsModel> offersList = pendingSink[1];
    offersList.forEach((element) {
      widgetList.add(
        ToDoCard(
          onTap: () => _showMyDialog(context),
          title: 'Some title',
          subTitle: element.requestTitle,
          tag: L.of(context).one_to_many_attende,
          timeInMilliseconds: element.requestEndDate,
        ),
      );
    });

    //Created One to many Offers
    // List<OfferModel> createdOneToManyOffers = pendingSink[2];
    // createdOneToManyOffers.forEach((element) {
    //   widgetList.add(ToDoCard(
    //     onTap: () => _showMyDialog(context),
    //     title: element.groupOfferDataModel.classTitle,
    //     subTitle: element.groupOfferDataModel.classDescription,
    //     tag: L.of(context).one_to_many_speaker,
    //     timeInMilliseconds: element.groupOfferDataModel.startDate,
    //   ));
    // });

    return widgetList;
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

    await Firestore.instance
        .collection('timebanknew')
        .document(notificationModel.timebankId)
        .collection('notifications')
        .document(notificationModel.id)
        .setData(notificationModel.toMap());

    await Firestore.instance
        .collection('requests')
        .document(requestModel.id)
        .updateData({
      'isSpeakerCompleted': true,
    });

    await FirestoreManager
        .readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion(
            requestModel: requestModel,
            userEmail: SevaCore.of(context).loggedInUser.email,
            fromNotification: false);
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
