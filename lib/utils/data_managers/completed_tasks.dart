import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../labels.dart';

class CompletedTasks {
  static Stream<List<RequestModel>> getSignedUpOneToManyRequests({
    String loggedInMemberEmail,
  }) async* {
    yield* CollectionRef.requests
        .where('oneToManyRequestAttenders', arrayContains: loggedInMemberEmail)
        .where('request_end', isLessThan: DateTime.now().millisecondsSinceEpoch)
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
    return CombineLatestStream.combine4(
        FirestoreManager.getCompletedRequestStream(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getCompletedSignedUpOffersStream(loggedInmemberId),
        getCompletedOneToManyOffersCreated(loggedinMemberEmail),
        getSignedUpOneToManyRequests(loggedInMemberEmail: loggedinMemberEmail),
        (
          pendingClaims,
          acceptedOneToManyOffers,
          oneToManyOffersCreated,
          signedUpOneToManyRequests,
        ) =>
            [
              pendingClaims,
              acceptedOneToManyOffers,
              oneToManyOffersCreated,
              signedUpOneToManyRequests,
            ]);
  }

  static List<Widget> classifyCompletedTasks({
    @required List<dynamic> completedSink,
    @required BuildContext context,
  }) {
    List<Widget> widgetList = [];
    List<RequestModel> requestList = completedSink[0];
    requestList.forEach((model) {
      if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == false) {
        widgetList.add(
          ToDoCard(
            title: model.title,
            subTitle: model.description,
            timeInMilliseconds: model.requestStart,
            onTap: () => showMyTaskDialog(
              context: context,
              title: L.of(context).completed_one_to_many_request_speaker_title,
              subTitle:
                  L.of(context).completed_one_to_many_request_speaker_subtitle,
            ),
            tag: L.of(context).one_to_many_request_speaker,
          ),
        );
      } else if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == true) {
        //
      } else {
        widgetList.add(
          ToDoCard(
            timeInMilliseconds: model.requestStart,
            tag: L.of(context).time_request_volunteer,
            subTitle: model.description,
            title: model.title,
            onTap: null,
          ),
        );
      }
    });

    //Signed up One to many Offers attendde
    List<OfferModel> offersList = completedSink[1];
    offersList.forEach((element) {
      widgetList.add(
        ToDoCard(
          onTap: () => showMyTaskDialog(
            context: context,
            title: L.of(context).completed_one_to_many_offer_attende_title,
            subTitle:
                L.of(context).completed_one_to_many_offer_attende_subtitle,
          ),
          title: element.groupOfferDataModel.classTitle,
          subTitle: element.groupOfferDataModel.classDescription,
          tag: L.of(context).one_to_many_offer_attende,
          timeInMilliseconds: element.groupOfferDataModel.startDate,
        ),
      );
    });

    //Created One to many Offers
    List<OfferModel> createdOneToManyOffers = completedSink[2];
    createdOneToManyOffers.forEach((element) {
      widgetList.add(ToDoCard(
        onTap: () => showMyTaskDialog(
          context: context,
          subTitle: L.of(context).completed_one_to_many_offer_speaker_subtitle,
          title: L.of(context).completed_one_to_many_offer_speaker_title,
        ),
        title: element.groupOfferDataModel.classTitle,
        subTitle: element.groupOfferDataModel.classDescription,
        tag: L.of(context).one_to_many_offer_speaker,
        timeInMilliseconds: element.groupOfferDataModel.startDate,
      ));
    });

    //Attendee for one to many request
    List<RequestModel> acceptedOneToManyRequests = completedSink[3];
    acceptedOneToManyRequests.forEach((element) {
      widgetList.add(ToDoCard(
        onTap: () => showMyTaskDialog(
          context: context,
          subTitle:
              L.of(context).completed_one_to_many_request_attende_subtitle,
          title: L.of(context).completed_one_to_many_request_attende_title,
        ),
        title: element.title,
        subTitle: element.description,
        tag: L.of(context).one_to_many_request_attende,
        timeInMilliseconds: element.requestStart,
      ));
    });

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
