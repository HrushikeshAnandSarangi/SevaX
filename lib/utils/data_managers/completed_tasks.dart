import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/data_managers/to_do.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

import '../../labels.dart';

class CompletedTasks {
  static Stream<List<OfferModel>> getCompletedOneToManyOffersCreated(
    String loggedInmemberEmail,
  ) async* {
    yield* Firestore.instance
        .collection('offers')
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('email', isEqualTo: loggedInmemberEmail)
        .where('groupOfferDataModel.endDate',
            isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> oneToManyOffers = [];

        data.documents.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data);
          oneToManyOffers.add(offerModel);
        });
        sink.add(oneToManyOffers);
      },
    ));
  }

  static Stream<List<OfferModel>> getCompletedSignedUpOffersStream(
      String loggedInmemberId) async* {
    yield* Firestore.instance
        .collection('offers')
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

        data.documents.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data);
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
    return CombineLatestStream.combine3(
        FirestoreManager.getCompletedRequestStream(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getCompletedSignedUpOffersStream(loggedInmemberId),
        getCompletedOneToManyOffersCreated(loggedinMemberEmail),
        (
          pendingClaims,
          acceptedOneToManyOffers,
          oneToManyOffersCreated,
        ) =>
            [
              pendingClaims,
              acceptedOneToManyOffers,
              oneToManyOffersCreated,
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
            onTap: null,
            tag: L.of(context).one_to_many_attende,
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

    //Signed up One to many Offers
    List<OfferModel> offersList = completedSink[1];
    offersList.forEach((element) {
      widgetList.add(
        ToDoCard(
          onTap: () => _showMyDialog(context),
          title: element.groupOfferDataModel.classTitle,
          subTitle: element.groupOfferDataModel.classDescription,
          tag: L.of(context).one_to_many_attende,
          timeInMilliseconds: element.groupOfferDataModel.startDate,
        ),
      );
    });

    //Created One to many Offers
    List<OfferModel> createdOneToManyOffers = completedSink[2];
    createdOneToManyOffers.forEach((element) {
      widgetList.add(ToDoCard(
        onTap: () => _showMyDialog(context),
        title: element.groupOfferDataModel.classTitle,
        subTitle: element.groupOfferDataModel.classDescription,
        tag: L.of(context).one_to_many_speaker,
        timeInMilliseconds: element.groupOfferDataModel.startDate,
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
