import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/completed_tasks.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import '../../flavor_config.dart';
import '../../labels.dart';

class ToDo {
  static Stream<List<RequestModel>> getSignedUpOneToManyRequests({
    String loggedInMemberEmail,
  }) async* {
    yield* CollectionRef.requests
        .where('oneToManyRequestAttenders', arrayContains: loggedInMemberEmail)
        .where('request_end',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
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

  static Stream<List<RequestModel>> getTaskStreamForUserWithEmail({
    @required String userEmail,
    @required String userId,
    BuildContext context,
  }) async* {
    var data = CollectionRef.requests
        .where('approvedUsers', arrayContains: userEmail)
        .where("root_timebank_id", isEqualTo: FlavorConfig.values.timebankId)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
        handleData: (snapshot, requestSink) {
          log('REQUESTS LIST:  ' + snapshot.docs.length.toString());
          List<RequestModel> requestModelList = [];
          snapshot.docs.forEach((documentSnapshot) {
            RequestModel model = RequestModel.fromMap(documentSnapshot.data());
            model.id = documentSnapshot.id;
            bool isCompletedByUser = false;

            model.transactions?.forEach((transaction) {
              if (transaction.to == userId) isCompletedByUser = true;
            });
            if ((!isCompletedByUser &&
                (model.requestType == RequestType.TIME ||
                    model.requestType == RequestType.ONE_TO_MANY_REQUEST))) {
              requestModelList.add(model);
            }
          });

          requestSink.add(requestModelList);
        },
      ),
    );
    // END OF CODE correction mentioned above
  }

  static Stream<List<OfferModel>> getOneToManyOffersCreated(
    String loggedInmemberEmail,
  ) async* {
    yield* CollectionRef.offers
        .where('offerType', isEqualTo: 'GROUP_OFFER')
        .where('email', isEqualTo: loggedInmemberEmail)
        .where('groupOfferDataModel.endDate',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
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

  static Stream<List<OfferModel>> getSignedUpOffersStream(
      String loggedInmemberId) async* {
    yield* CollectionRef.offers
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

        data.docs.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data());
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
    return CombineLatestStream.combine4(
        getTaskStreamForUserWithEmail(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getSignedUpOffersStream(loggedInmemberId),
        getOneToManyOffersCreated(loggedinMemberEmail),
        getSignedUpOneToManyRequests(
          loggedInMemberEmail: loggedinMemberEmail,
        ),
        (
          pendingClaims,
          acceptedOneToManyOffers,
          oneToManyOffersCreated,
          acceptedOneToManyRequests,
        ) =>
            [
              pendingClaims,
              acceptedOneToManyOffers,
              oneToManyOffersCreated,
              acceptedOneToManyRequests,
            ]);
  }

  static List<Widget> classifyToDos({
    @required List<dynamic> toDoSink,
    @required ValueChanged<RequestModel> requestCallback,
    @required BuildContext context,
    @required ValueChanged<int> feedbackCallback,
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
            onTap: () {
              model.isSpeakerCompleted
                  ? CompletedTasks.showMyTaskDialog(
                      context: context,
                      title:
                          L.of(context).to_do_one_to_many_request_speaker_title,
                      subTitle: L
                          .of(context)
                          .to_do_one_to_many_request_speaker_subtitle,
                    )
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
                    };
            },
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
            onTap: () {
              if (model.requestType == RequestType.BORROW) {
                feedbackCallback(0);
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

    //Signed up One to many Offers attendee
    List<OfferModel> offersList = toDoSink[1];
    offersList.forEach((element) {
      widgetList.add(
        ToDoCard(
          onTap: () => CompletedTasks.showMyTaskDialog(
            context: context,
            title: L.of(context).to_do_one_to_many_offer_attende_title,
            subTitle: L.of(context).to_do_one_to_many_offer_attende_subtitle,
          ),
          title: element.groupOfferDataModel.classTitle,
          subTitle: element.groupOfferDataModel.classDescription,
          tag: L.of(context).one_to_many_offer_attende,
          timeInMilliseconds: element.groupOfferDataModel.startDate,
        ),
      );
    });

    //Created One to many Offers
    List<OfferModel> createdOneToManyOffers = toDoSink[2];
    createdOneToManyOffers.forEach((element) {
      widgetList.add(ToDoCard(
        onTap: () => CompletedTasks.showMyTaskDialog(
          context: context,
          title: L.of(context).to_do_one_to_many_offer_speaker_title,
          subTitle: L.of(context).to_do_one_to_many_offer_speaker_subtitle,
        ),
        title: element.groupOfferDataModel.classTitle,
        subTitle: element.groupOfferDataModel.classDescription,
        tag: L.of(context).one_to_many_offer_speaker,
        timeInMilliseconds: element.groupOfferDataModel.startDate,
      ));
    });

    //Attendee for one to many request
    List<RequestModel> acceptedOneToManyRequests = toDoSink[3];
    acceptedOneToManyRequests.forEach((element) {
      widgetList.add(ToDoCard(
        onTap: () => CompletedTasks.showMyTaskDialog(
          context: context,
          title: L.of(context).to_do_one_to_many_request_attende_title,
          subTitle: L.of(context).to_do_one_to_many_request_attende_subtitle,
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
          HideWidget(
            hide: subTitle.isEmpty,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 12,
              ),
              child: Text(subTitle),
            ),
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
