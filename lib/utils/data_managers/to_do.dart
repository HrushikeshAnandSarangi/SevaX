import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/combined_notification_page.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/completed_tasks.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/tasks_card_wrapper.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

import '../../../../flavor_config.dart';
import '../../../../labels.dart';

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

  static Stream<List<RequestModel>> getBorrowRequestLenderReturnAcknowledgment({
    String loggedInMemberEmail,
  }) async* {
    yield* CollectionRef.requests
        .where('approvedUsers', arrayContains: loggedInMemberEmail)
        .where('accepted', isEqualTo: false)
        .where('requestType', isEqualTo: 'BORROW')
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<RequestModel>>.fromHandlers(
                handleData: (data, sink) {
      List<RequestModel> requestList = [];
      data.docs.forEach((element) {
        requestList.add(RequestModel.fromMap(element.data()));
      });
      logger.e('LENGTH CHECK 1:  ' + requestList.length.toString());
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
        .where('isSpeakerCompleted', isEqualTo: false)
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

  static Stream<List<OfferModel>> getLendingOfferApprovedStream(
      {String email}) async* {
    log('pending started');

    yield* CollectionRef.offers
        .where('requestType', isEqualTo: 'LENDING_OFFER')
        .where('lendingOfferDetailsModel.endDate',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .where('lendingOfferDetailsModel.approvedUsers', arrayContains: email)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> lendingOffers = [];

        data.docs.forEach((element) {
          var offerModel = OfferModel.fromMap(element.data());
          lendingOffers.add(offerModel);
          log('pending ${lendingOffers.length}');
        });
        sink.add(lendingOffers);
      },
    ));
  }

  static Stream<Object> getToDoList(
    loggedinMemberEmail,
    loggedInmemberId,
  ) {
    return CombineLatestStream.combine7(
        getTaskStreamForUserWithEmail(
          userEmail: loggedinMemberEmail,
          userId: loggedInmemberId,
        ),
        getSignedUpOffersStream(loggedInmemberId),
        getOneToManyOffersCreated(loggedinMemberEmail),
        getSignedUpOneToManyRequests(
          loggedInMemberEmail: loggedinMemberEmail,
        ),
        getBorrowRequestLenderReturnAcknowledgment(
            loggedInMemberEmail: loggedinMemberEmail),
        FirestoreManager.getBorrowRequestCreatorToCollectReturnItems(
          userId: loggedInmemberId,
          userEmail: loggedinMemberEmail,
        ),
        getLendingOfferApprovedStream(
          email: loggedinMemberEmail,
        ),
        (
          pendingClaims,
          acceptedOneToManyOffers,
          oneToManyOffersCreated,
          acceptedOneToManyRequests,
          borrowRequestLenderReturnAcknowledgment,
          borrowRequestCreatorWaitingReturnConfirmation,
          lendingOfferApprovedFlow,
        ) =>
            [
              pendingClaims,
              acceptedOneToManyOffers,
              oneToManyOffersCreated,
              acceptedOneToManyRequests,
              borrowRequestLenderReturnAcknowledgment,
              borrowRequestCreatorWaitingReturnConfirmation,
              lendingOfferApprovedFlow,
            ]);
  }

  static List<Widget> classifyToDos({
    @required List<dynamic> toDoSink,
    @required ValueChanged<RequestModel> requestCallback,
    @required BuildContext context,
    @required ValueChanged<int> feedbackCallback,
  }) {
    List<TasksCardWrapper> tasksList = [];
    MessageBloc _messageBloc = MessageBloc();
    NotificationsBloc _notificationsBloc = NotificationsBloc();

    List<RequestModel> requestList = toDoSink[0];
    requestList.forEach((model) {
      requestCallback(model);
      if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == false) {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              requestModel: model,
              isSpeaker: true,
              title: model.title,
              subTitle: model.description,
              timeInMilliseconds: model.requestStart,
              onTap: () {
                model.isSpeakerCompleted
                    ? log("")
                    : Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return OneToManySpeakerTimeEntryComplete(
                              userModel: SevaCore.of(context).loggedInUser,
                              requestModel: model,
                              onFinish: () async {
                                await oneToManySpeakerCompletesRequest(
                                  context,
                                  model,
                                );
                              },
                              isFromtasks: true,
                            );
                          },
                        ),
                      );
              },
              tag: S.of(context).one_to_many_request_speaker,
            ),
            taskTimestamp: model.requestStart,
          ),
        );
      } else if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == true) {
        //
      } else {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              timeInMilliseconds: model.requestStart,
              tag: S.of(context).time_request_volunteer,
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
                        userTimezone:
                            SevaCore.of(context).loggedInUser.timezone,
                      ),
                    ),
                  );
                }
              },
            ),
            taskTimestamp: model.requestStart,
          ),
        );
      }
    });

    //Signed up One to many Offers attendee
    List<OfferModel> offersList = toDoSink[1];
    offersList.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () {},
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
    List<OfferModel> createdOneToManyOffers = toDoSink[2];
    createdOneToManyOffers.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () {},
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
    List<RequestModel> acceptedOneToManyRequests = toDoSink[3];
    acceptedOneToManyRequests.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () {},
            title: element.title,
            subTitle: element.description,
            tag: S.of(context).one_to_many_request_attende,
            timeInMilliseconds: element.requestStart,
          ),
          taskTimestamp: element.requestStart,
        ),
      );
    });

    //Lender Borrow Request Pending Acknowledgement of Return of item/place
    List<RequestModel> pendingReturnBorrowRequest = toDoSink[4];
    pendingReturnBorrowRequest.forEach((element) {
      tasksList.add(
        TasksCardWrapper(
          taskCard: ToDoCard(
            onTap: () async {
              showDialog(
                context: context,
                builder: (_context) => AlertDialog(
                  title: Text(S.of(context).item_received_alert_dialouge),
                  actions: [
                    CustomTextButton(
                      onPressed: () {
                        Navigator.of(_context).pop();
                      },
                      child: Text(
                        S.of(context).not_yet,
                        style: TextStyle(
                            fontSize: 17, color: Theme.of(context).accentColor),
                      ),
                    ),
                    CustomTextButton(
                      onPressed: () async {
                        Navigator.of(_context).pop();

                        log('timebank ID:  ' + element.timebankId);

                        //Update request model to complete it
                        //requestModelNew.approvedUsers = [];
                        element.acceptors = [];
                        element.accepted =
                            true; //so that we can know that this request has completed
                        element.isNotified = true; //resets to false otherwise

                        if (element.roomOrTool == LendingType.ITEM.readable) {
                          element.borrowModel.itemsReturned = true;
                        } else {
                          element.borrowModel.isCheckedOut = true;
                        }

                        await lenderReceivedBackCheck(
                            notification: null,
                            notificationId: null,
                            requestModelUpdated: element,
                            context: context);
                        await FirestoreManager
                            .readLenderNotificationIfAcceptedFromTasks(
                          requestModel: element,
                          userEmail: SevaCore.of(context).loggedInUser.email,
                          fromNotification: false,
                        );
                      },
                      child: Text(
                        S.of(context).yes,
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              );
            },
            title: element.title,
            subTitle: element.description,
            tag: L.of(context).borrow_request_lender_pending_return_check,
            timeInMilliseconds: element.requestStart,
          ),
          taskTimestamp: element.requestStart,
        ),
      );
    });

    //for borrow request, request creator / Borrower needs to see in To do when needs to collect or check in
    List<RequestModel> borrowRequestCreatorAwaitingConfirmation = toDoSink[5];
    borrowRequestCreatorAwaitingConfirmation.forEach((model) async {
      // BorrowAcceptorModel borrowAcceptorModel =
      //     await FirestoreManager.getBorrowRequestAcceptorModel(
      //         requestId: model.id, acceptorEmail: model.approvedUsers.first);
      if (model.roomOrTool == LendingType.ITEM.readable) {
        //FOR BORROW ITEMS
        if (!model.borrowModel.itemsCollected) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title,
                subTitle: L.of(context).collect_items,
                timeInMilliseconds: model.requestStart,
                onTap: () async {},
                tag: L.of(context).borrow_request_collect_items_tag,
              ),
              taskTimestamp: model.requestStart,
            ),
          );
        } else if (model
                .borrowModel.itemsCollected && //items to be returned status
            !model.borrowModel.itemsReturned) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title,
                subTitle: L.of(context).return_items,
                timeInMilliseconds: model.requestEnd,
                onTap: () async {},
                tag: L.of(context).borrow_request_return_items_tag,
              ),
              taskTimestamp: model.requestStart,
            ),
          );
        }
        //FOR BORROW PLACE
      } else {
        if (!model.borrowModel.isCheckedIn) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title,
                subTitle: L.of(context).check_in_pending,
                timeInMilliseconds: model.requestStart,
                onTap: () async {},
                tag: L.of(context).check_in,
              ),
              taskTimestamp: model.requestStart,
            ),
          );
        } else if (model
                .borrowModel.isCheckedIn && //items to be returned status
            !model.borrowModel.isCheckedOut) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title,
                subTitle: L.of(context).check_out,
                timeInMilliseconds: model.requestEnd,
                onTap: () async {},
                tag: L.of(context).check_out,
              ),
              taskTimestamp: model.requestStart,
            ),
          );
        }
      }
    });

    //for borrow request, request creator / Borrower needs to see in To do when needs to collect or check in
    List<OfferModel> lendingOfferBorrowerRequestApproved = toDoSink[6];
    lendingOfferBorrowerRequestApproved.forEach((model) async {
      // LendingOfferAcceptorModel lendingOfferAcceptorModel =
      //     await LendingOffersRepo.getBorrowAcceptorModel(
      //         offerId: model.id, acceptorEmail: user.email);

      if (model.lendingOfferDetailsModel.lendingModel.lendingType ==
          LendingType.ITEM) {
        //FOR BORROW ITEMS
        if (!model.lendingOfferDetailsModel.collectedItems) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel.title,
                subTitle:
                    L.of(context).collect_items + model.selectedAdrress != null
                        ? ' at ' + model.selectedAdrress
                        : '',
                timeInMilliseconds: model.lendingOfferDetailsModel.startDate,
                onTap: () async {
                  await LendingOffersRepo.getDialogForBorrowerToUpdate(offerModel: model,context: context,lendingOfferAcceptorModel: );
                },
                tag: L.of(context).lending_offer_collect_items_tag,
              ),
              taskTimestamp: model.lendingOfferDetailsModel.startDate,
            ),
          );
        } else if (model.lendingOfferDetailsModel
                .collectedItems && //items to be returned status
            !model.lendingOfferDetailsModel.returnedItems) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel.title,
                subTitle:
                    L.of(context).return_items + model.selectedAdrress != null
                        ? ' at ' + model.selectedAdrress
                        : '',
                timeInMilliseconds: model.lendingOfferDetailsModel.endDate,
                onTap: () async {
                  await LendingOffersRepo.getDialogForBorrowerToUpdate(offerModel: model,context: context,lendingOfferAcceptorModel: );

                },
                tag: L.of(context).lending_offer_return_items_tag,
              ),
              taskTimestamp: model.lendingOfferDetailsModel.startDate,
            ),
          );
        }
        //FOR BORROW PLACE
      } else {
        if (!model.lendingOfferDetailsModel.checkedIn) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel.title,
                subTitle: L.of(context).arrive + model.selectedAdrress != null
                    ? ' at ' + model.selectedAdrress
                    : '',
                timeInMilliseconds: model.lendingOfferDetailsModel.startDate,
                onTap: () async {
                  await LendingOffersRepo.getDialogForBorrowerToUpdate(offerModel: model,context: context,lendingOfferAcceptorModel: );

                },
                tag: L.of(context).lending_offer_check_in_tag,
              ),
              taskTimestamp: model.lendingOfferDetailsModel.startDate,
            ),
          );
        } else if (model.lendingOfferDetailsModel
                .checkedIn && //items to be returned status
            !model.lendingOfferDetailsModel.checkedOut) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel.title,
                subTitle:
                    L.of(context).departure + model.selectedAdrress != null
                        ? ' at ' + model.selectedAdrress
                        : '',
                timeInMilliseconds: model.lendingOfferDetailsModel.endDate,
                onTap: () async {
                  await LendingOffersRepo.getDialogForBorrowerToUpdate(offerModel: model,context: context,lendingOfferAcceptorModel: );

                },
                tag: L.of(context).lending_offer_check_out_tag,
              ),
              taskTimestamp: model.lendingOfferDetailsModel.startDate,
            ),
          );
        }
      }
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
}

class ToDoTag extends StatelessWidget {
  ToDoTag({
    this.tag,
    this.color,
  });
  final String tag;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).primaryColor,
        ),
        text: tag,
      ),
    );
  }
}

class ToDoCard extends StatelessWidget {
  ToDoCard({
    this.requestModel,
    this.isSpeaker = false,
    this.onTap,
    this.tag,
    this.title,
    this.subTitle,
    this.timeInMilliseconds,
  });
  final RequestModel requestModel;
  final bool isSpeaker;
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              child: Text(
                subTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          HideWidget(
            hide: !isSpeaker,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 12,
              ),
              child: CustomElevatedButton(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    S.of(context).speaker_claim_credits,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return OneToManySpeakerTimeEntryComplete(
                          userModel: SevaCore.of(context).loggedInUser,
                          requestModel: requestModel,
                          onFinish: () async {
                            await ToDo.oneToManySpeakerCompletesRequest(
                                context, requestModel);
                          },
                          isFromtasks: true,
                        );
                      },
                    ),
                  );
                },
              ),
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
