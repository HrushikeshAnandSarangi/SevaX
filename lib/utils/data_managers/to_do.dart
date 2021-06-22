import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';

import '../../labels.dart';

class ToDo {
  static Stream<List<OfferModel>> getOneToManyOffersCreated(
    String loggedInmemberEmail,
  ) async* {
    yield* Firestore.instance
        .collection('offers')
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('email', isEqualTo: loggedInmemberEmail)
        .where('groupOfferDataModel.endDate',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
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

  static Stream<List<OfferModel>> getSignedUpOffersStream(
      String loggedInmemberId) async* {
    yield* Firestore.instance
        .collection('offers')
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('groupOfferDataModel.endDate',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .where('groupOfferDataModel.signedUpMembers',
            arrayContains: loggedInmemberId)
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

  static Stream<Object> getToDoList(
    loggedinMemberEmail,
    loggedInmemberId,
  ) {
    return CombineLatestStream.combine3(
        FirestoreManager.getTaskStreamForUserWithEmail(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getSignedUpOffersStream(loggedInmemberId),
        getOneToManyOffersCreated(loggedinMemberEmail),
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

  static List<Widget> classifyToDos({
    @required List<dynamic> toDoSink,
    @required ValueChanged<RequestModel> requestCallback,
    @required BuildContext context,
  }) {
    List<Widget> widgetList = [];
    List<RequestModel> requestList = toDoSink[0];
    requestList.forEach((model) {
      requestCallback(model);
      if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == false) {
        widgetList.add(
          ToDoCard(
            title: model.title,
            subTitle: model.description,
            timeInMilliseconds: model.requestStart,
            onTap: model.isSpeakerCompleted
                ? showDialog(context: context)
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OneToManySpeakerTimeEntryComplete(
                            requestModel: model,
                            onFinish: () async {
                              await oneToManySpeakerCompletesRequest(
                                  context, model);
                            },
                            fromNotification: false,
                          );
                        },
                      ),
                    );
                  },
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
            onTap: () {
              if (model.requestType == RequestType.BORROW) {
                // subjectBorrow.add(0);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskCardView(
                      requestModel: model,
                      userTimezone: SevaCore.of(context).loggedInUser.timezone,
                    ),
                  ),
                );
              }
            },
          ),
        );
      }
    });

    //Signed up One to many Offers
    List<OfferModel> offersList = toDoSink[1];
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
    List<OfferModel> createdOneToManyOffers = toDoSink[2];
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

class ToDoTag extends StatelessWidget {
  ToDoTag({this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        text: tag,
      ),
    );
  }
}

class ToDoCard extends StatelessWidget {
  ToDoCard({
    this.onTap,
    this.tag,
    this.title,
    this.subTitle,
    this.timeInMilliseconds,
  });

  final Function onTap;
  final String tag;
  final String title;
  final String subTitle;
  final int timeInMilliseconds;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToDoTag(tag: tag),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 12,
            ),
            child: Text(subTitle),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 12),
            child: Text(getTimeFormattedString(
              timeInMilliseconds,
              S.of(context).localeName,
            )),
          ),
        ],
      )),
    );
  }
}
