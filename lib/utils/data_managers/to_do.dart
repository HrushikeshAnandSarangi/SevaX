import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/message/bloc/message_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
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
import 'package:sevaexchange/utils/extensions.dart';

class ToDo {
  static Stream<List<RequestModel>> getSignedUpOneToManyRequests({
    String? loggedInMemberEmail,
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
        requestList
            .add(RequestModel.fromMap(element.data() as Map<String, dynamic>));
      });
      return sink.add(requestList);
    }));
  }

  static Stream<List<RequestModel>> getBorrowRequestLenderReturnAcknowledgment({
    String? loggedInMemberEmail,
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
        requestList
            .add(RequestModel.fromMap(element.data() as Map<String, dynamic>));
      });
      logger.e('LENGTH CHECK 1:  ' + requestList.length.toString());
      return sink.add(requestList);
    }));
  }

  static Stream<List<RequestModel>> getTaskStreamForUserWithEmail({
    required String userEmail,
    required String userId,
    BuildContext? context,
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
            RequestModel model = RequestModel.fromMap(
                documentSnapshot.data() as Map<String, dynamic>);
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
          var offerModel =
              OfferModel.fromMap(element.data() as Map<String, dynamic>);
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
          var offerModel =
              OfferModel.fromMap(element.data() as Map<String, dynamic>);
          oneToManyOffers.add(offerModel);
        });
        sink.add(oneToManyOffers);
      },
    ));
  }

  static Stream<List<OfferModel>> getLendingOfferApprovedStream(
      {String? email}) async* {
    yield* CollectionRef.offers
        .where('requestType', isEqualTo: 'LENDING_OFFER')
        // .where('lendingOfferDetailsModel.endDate',
        //     isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .where('lendingOfferDetailsModel.approvedUsers', arrayContains: email)
        .snapshots()
        .transform(
            StreamTransformer<QuerySnapshot, List<OfferModel>>.fromHandlers(
      handleData: (data, sink) {
        List<OfferModel> lendingOffers = [];

        data.docs.forEach((element) {
          var offerModel =
              OfferModel.fromMap(element.data() as Map<String, dynamic>);
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
        //
        getBorrowRequestLenderReturnAcknowledgment(
            loggedInMemberEmail: loggedinMemberEmail),
        FirestoreManager.getBorrowRequestCreatorToCollectReturnItems(
          userId: loggedInmemberId,
          userEmail: loggedinMemberEmail,
        ),
        //
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
    required List<dynamic> toDoSink,
    required ValueChanged<RequestModel> requestCallback,
    required BuildContext context,
    required ValueChanged<int> feedbackCallback,
    required String email,
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
              title: model.title!,
              subTitle: model.description!,
              timeInMilliseconds: model.requestStart!,
              onTap: () {
                model.isSpeakerCompleted!
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
            taskTimestamp: model.requestStart!,
          ),
        );
      } else if (model.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          model.accepted == true) {
        //
      } else {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              timeInMilliseconds: model.requestStart!,
              tag: S.of(context).time_request_volunteer,
              subTitle: model.description!,
              title: model.title!,
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
                            SevaCore.of(context).loggedInUser.timezone!,
                      ),
                    ),
                  );
                }
              },
            ),
            taskTimestamp: model.requestStart!,
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
            title: element.groupOfferDataModel!.classTitle!,
            subTitle: element.groupOfferDataModel!.classDescription!,
            tag: S.of(context).one_to_many_offer_attende,
            timeInMilliseconds: element.groupOfferDataModel!.startDate!,
          ),
          taskTimestamp: element.groupOfferDataModel!.startDate!,
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
            title: element.groupOfferDataModel!.classTitle!,
            subTitle: element.groupOfferDataModel!.classDescription!,
            tag: S.of(context).one_to_many_offer_speaker,
            timeInMilliseconds: element.groupOfferDataModel!.startDate!,
          ),
          taskTimestamp: element.groupOfferDataModel!.startDate!,
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
            title: element.title!,
            subTitle: element.description!,
            tag: S.of(context).one_to_many_request_attende,
            timeInMilliseconds: element.requestStart!,
          ),
          taskTimestamp: element.requestStart!,
        ),
      );
    });

    //Lender Borrow Request Pending Acknowledgement of Return of item/place
    List<RequestModel> pendingReturnBorrowRequest = toDoSink[4];
    pendingReturnBorrowRequest.forEach((element) {
      if (element.borrowModel!.isCheckedIn! == true ||
          element.borrowModel!.itemsCollected! == true) {
        tasksList.add(
          TasksCardWrapper(
            taskCard: ToDoCard(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (_context) => AlertDialog(
                    title: Text(element.roomOrTool == LendingType.PLACE.readable
                        ? S
                            .of(context)
                            .admin_borrow_request_received_back_check_place
                        : S
                            .of(context)
                            .admin_borrow_request_received_back_check_item),
                    actions: [
                      CustomTextButton(
                        shape: StadiumBorder(),
                        color: Theme.of(context).colorScheme.secondary,
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        onPressed: () {
                          Navigator.of(_context).pop();
                        },
                        child: Text(
                          S.of(context).not_yet.sentenceCase(),
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Europa',
                              color: Colors.white),
                        ),
                      ),
                      CustomTextButton(
                        onPressed: () async {
                          Navigator.of(_context).pop();

                          log('timebank ID:  ' + (element.timebankId ?? ''));

                          //Update request model to complete it
                          //requestModelNew.approvedUsers = [];
                          element.acceptors = [];
                          element.accepted =
                              true; //so that we can know that this request has completed
                          element.isNotified = true; //resets to false otherwise

                          if (element.roomOrTool == LendingType.ITEM.readable) {
                            element.borrowModel!.itemsReturned = true;
                          } else {
                            element.borrowModel!.isCheckedOut = true;
                          }

                          await lenderReceivedBackCheck(
                              notification: NotificationsModel(
                                // Provide appropriate values for the required fields
                                timebankId: element.timebankId,
                                targetUserId: element.sevaUserId,
                                data: element.toMap(),
                                type: NotificationType
                                    .BorrowRequestIdleFirstWarning,
                                id: utils.Utils.getUuid(),
                                isRead: false,
                                senderUserId: SevaCore.of(context)
                                    .loggedInUser
                                    .sevaUserID,
                                communityId: element.communityId,
                                isTimebankNotification: true,
                              ),
                              notificationId:
                                  '', // Provide an empty string or a valid String id
                              requestModelUpdated: element,
                              context: context);
                          await FirestoreManager
                              .readLenderNotificationIfAcceptedFromTasks(
                            requestModel: element,
                            userEmail: SevaCore.of(context).loggedInUser.email!,
                            fromNotification: false,
                          );
                        },
                        shape: StadiumBorder(),
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                        child: Text(
                          S.of(context).yes,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Europa',
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
              title: element.title ?? '',
              subTitle: element.description ?? '',
              tag: S.of(context).borrow_request_lender_pending_return_check,
              timeInMilliseconds: element.requestStart ?? 0,
            ),
            taskTimestamp: element.requestStart ?? 0,
          ),
        );
      }
    });

    //for borrow request, request creator / Borrower needs to see in To do when needs to collect or check in
    List<RequestModel> borrowRequestCreatorAwaitingConfirmation = toDoSink[5];
    borrowRequestCreatorAwaitingConfirmation.forEach((model) async {
      if (model.roomOrTool == LendingType.ITEM.readable) {
        //FOR BORROW ITEMS
        if (model.borrowModel != null &&
            model.borrowModel!.itemsCollected != true) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title ?? '',
                subTitle: S.of(context).collect_items,
                timeInMilliseconds: model.requestStart ?? 0,
                onTap: () async {},
                tag: S.of(context).borrow_request_collect_items_tag,
              ),
              taskTimestamp: model.requestStart ?? 0,
            ),
          );
        } else if (model.borrowModel != null &&
            model.borrowModel!.itemsCollected == true &&
            model.borrowModel!.itemsReturned != true) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title ?? '',
                subTitle: S.of(context).return_items,
                timeInMilliseconds: model.requestEnd ?? 0,
                onTap: () async {},
                tag: S.of(context).borrow_request_return_items_tag,
              ),
              taskTimestamp: model.requestStart ?? 0,
            ),
          );
        }
        //FOR BORROW PLACE
      } else {
        if (model.borrowModel != null &&
            model.borrowModel!.isCheckedIn != true) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title ?? '',
                subTitle: S.of(context).check_in_pending,
                timeInMilliseconds: model.requestStart ?? 0,
                onTap: () async {},
                tag: S.of(context).check_in_text,
              ),
              taskTimestamp: model.requestStart ?? 0,
            ),
          );
        } else if (model.borrowModel != null &&
            model.borrowModel!.isCheckedIn == true &&
            model.borrowModel!.isCheckedOut != true) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.title ?? '',
                subTitle: S.of(context).check_out_text,
                timeInMilliseconds: model.requestEnd ?? 0,
                onTap: () async {},
                tag: S.of(context).check_out_text,
              ),
              taskTimestamp: model.requestStart ?? 0,
            ),
          );
        }
      }
    });

    //for borrow request, request creator / Borrower needs to see in To do when needs to collect or check in
    List<OfferModel> lendingOfferBorrowerRequestApproved = toDoSink[6];
    lendingOfferBorrowerRequestApproved.forEach((model) async {
      logger.e('LENGTH OF APPROVED: ' +
          lendingOfferBorrowerRequestApproved.length.toString());

      if (model.lendingOfferDetailsModel != null &&
          model.lendingOfferDetailsModel!.lendingModel != null &&
          model.lendingOfferDetailsModel!.lendingModel!.lendingType ==
              LendingType.ITEM) {
        //FOR BORROW ITEMS
        if (model.lendingOfferDetailsModel!.collectedItems != true) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel?.title ?? '',
                subTitle: model.selectedAdrress != null &&
                        model.selectedAdrress!.isNotEmpty
                    ? '${S.of(context).collect_items} at ${model.selectedAdrress}'
                    : S.of(context).collect_items,
                timeInMilliseconds:
                    model.lendingOfferDetailsModel!.approvedStartDate ??
                        DateTime.now().millisecondsSinceEpoch,
                onTap: () async {
                  LendingOfferAcceptorModel lendingOfferAcceptorModel =
                      await LendingOffersRepo.getBorrowAcceptorModel(
                          offerId: model.id ?? '', acceptorEmail: email);
                  LendingOffersRepo.getDialogForBorrowerToUpdate(
                      offerModel: model,
                      context: context,
                      lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                },
                tag: S.of(context).lending_offer_collect_items_tag,
              ),
              taskTimestamp:
                  model.lendingOfferDetailsModel!.approvedStartDate ??
                      DateTime.now().millisecondsSinceEpoch,
            ),
          );
        } else if (model.lendingOfferDetailsModel!.collectedItems == true &&
            model.lendingOfferDetailsModel!.returnedItems != true) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel?.title ?? '',
                subTitle: model.selectedAdrress != null &&
                        model.selectedAdrress!.isNotEmpty
                    ? '${S.of(context).return_items} at ${model.selectedAdrress}'
                    : S.of(context).return_items,
                timeInMilliseconds: model
                        .lendingOfferDetailsModel!.approvedEndDate ??
                    ((model.lendingOfferDetailsModel!.lendingOfferTypeMode ==
                            'ONE_TIME')
                        ? (model.lendingOfferDetailsModel!.endDate ?? 0)
                        : 0),
                onTap: () async {
                  LendingOfferAcceptorModel lendingOfferAcceptorModel =
                      await LendingOffersRepo.getBorrowAcceptorModel(
                          offerId: model.id ?? '', acceptorEmail: email);
                  LendingOffersRepo.getDialogForBorrowerToUpdate(
                      offerModel: model,
                      context: context,
                      lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                },
                tag: S.of(context).lending_offer_return_items_tag,
              ),
              taskTimestamp:
                  model.lendingOfferDetailsModel!.approvedStartDate ??
                      DateTime.now().millisecondsSinceEpoch,
            ),
          );
        }
        //FOR BORROW PLACE
      } else if (model.lendingOfferDetailsModel != null) {
        if (model.lendingOfferDetailsModel!.checkedIn != true) {
          //items to be collected status
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel?.title ?? '',
                subTitle: model.selectedAdrress != null &&
                        model.selectedAdrress!.isNotEmpty
                    ? '${S.of(context).check_in_text} at ${model.selectedAdrress}'
                    : S.of(context).check_in_text,
                timeInMilliseconds:
                    model.lendingOfferDetailsModel!.approvedStartDate ??
                        DateTime.now().millisecondsSinceEpoch,
                onTap: () async {
                  LendingOfferAcceptorModel lendingOfferAcceptorModel =
                      await LendingOffersRepo.getBorrowAcceptorModel(
                          offerId: model.id ?? '', acceptorEmail: email);
                  LendingOffersRepo.getDialogForBorrowerToUpdate(
                      offerModel: model,
                      context: context,
                      lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                },
                tag: S.of(context).lending_offer_check_in_tag,
              ),
              taskTimestamp:
                  model.lendingOfferDetailsModel!.approvedStartDate ??
                      DateTime.now().millisecondsSinceEpoch,
            ),
          );
        } else if (model.lendingOfferDetailsModel!.checkedIn == true &&
            model.lendingOfferDetailsModel!.checkedOut != true) {
          tasksList.add(
            TasksCardWrapper(
              taskCard: ToDoCard(
                title: model.individualOfferDataModel?.title ?? '',
                subTitle: model.selectedAdrress != null &&
                        model.selectedAdrress!.isNotEmpty
                    ? '${S.of(context).check_out_text} at ${model.selectedAdrress}'
                    : S.of(context).check_out_text,
                timeInMilliseconds: model
                        .lendingOfferDetailsModel!.approvedEndDate ??
                    ((model.lendingOfferDetailsModel!.lendingOfferTypeMode ==
                            'ONE_TIME')
                        ? (model.lendingOfferDetailsModel!.endDate ?? 0)
                        : 0),
                onTap: () async {
                  LendingOfferAcceptorModel lendingOfferAcceptorModel =
                      await LendingOffersRepo.getBorrowAcceptorModel(
                          offerId: model.id ?? '', acceptorEmail: email);
                  LendingOffersRepo.getDialogForBorrowerToUpdate(
                      offerModel: model,
                      context: context,
                      lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                },
                tag: S.of(context).lending_offer_check_out_tag,
              ),
              taskTimestamp:
                  model.lendingOfferDetailsModel!.approvedStartDate ??
                      DateTime.now().millisecondsSinceEpoch,
            ),
          );
        }
      }
    });

    tasksList.sort((a, b) => b.taskTimestamp.compareTo(a.taskTimestamp));
    logger.e('Tasks Length Last: ' + tasksList.length.toString());

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
            userEmail: SevaCore.of(context).loggedInUser.email!,
            fromNotification: false);
  }
}

class ToDoTag extends StatelessWidget {
  ToDoTag({
    this.tag,
    this.color,
  });
  final String? tag;
  final Color? color;

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
    required this.onTap,
    required this.tag,
    required this.title,
    required this.subTitle,
    required this.timeInMilliseconds,
  });
  final RequestModel? requestModel;
  final bool isSpeaker;
  final VoidCallback onTap;
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
            secondChild: const SizedBox.shrink(),
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
                color: Theme.of(context).colorScheme.secondary,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2.0,
                textColor: Colors.white,
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
                          requestModel: requestModel!,
                          onFinish: () async {
                            await ToDo.oneToManySpeakerCompletesRequest(
                                context, requestModel!);
                          },
                          isFromtasks: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            secondChild: const SizedBox.shrink(),
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
