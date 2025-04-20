import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/reported_member_notification_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/new_baseline/models/user_insufficient_credits_model.dart';
import 'package:sevaexchange/repositories/donations_repository.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/reducer.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/personal_notifications.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/manual_time_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card_oneToManyCompletedApproval.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/oneToManyCreatorApproveCompletionCard.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/sponser_group_request_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_join_request_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_complete_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_widget.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManyCreatorCompleteRequestPage.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request/edit_request.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/timebanks/timbank_admin_request_list.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_member_insufficent_credits_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_user_exit_dialog.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../labels.dart';

class TimebankNotifications extends StatefulWidget {
  final TimebankModel? timebankModel;
  final ScrollPhysics? physics;
  final UserModel? userModel;

  const TimebankNotifications(
      {Key? key, this.timebankModel, this.physics, this.userModel})
      : super(key: key);

  @override
  _TimebankNotificationsState createState() => _TimebankNotificationsState();
}

class _TimebankNotificationsState extends State<TimebankNotifications> {
  final subjectBorrow = ReplaySubject<int>();
  RequestModel? requestModelNew;
  OfferModel? offerModelNew;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await Future.delayed(Duration(milliseconds: 200));
    //   subjectBorrow
    //       .transform(ThrottleStreamTransformer(
    //           (_) => TimerStream(true, const Duration(seconds: 1))))
    //       .listen((data) {
    //     logger.e('COMES BACK HERE 1');
    //
    //     checkForReviewBorrowRequests();
    //   });
    // });
  }

  BuildContext? parentContext;

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder(
      stream: _bloc!.timebankNotifications,
      builder: (_, AsyncSnapshot<TimebankNotificationData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }

        List<NotificationsModel> notifications =
            snapshot.data!.notifications[widget.timebankModel!.id] ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                S.of(context).no_notifications,
              ),
            ),
          );
        }
        return ListView.builder(
          physics: widget.physics,
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            NotificationsModel notification = notifications.elementAt(index);
            switch (notification.type) {
              case NotificationType.TYPE_MEMBER_HAS_INSUFFICENT_CREDITS:
                UserInsufficentCreditsModel userInsufficientModel =
                    UserInsufficentCreditsModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: "${userInsufficientModel.senderName}" +
                      S.of(context).adminNotificationInsufficientCredits,
                  subTitle: S
                          .of(context)
                          .adminNotificationInsufficientCreditsNeeded +
                      "${(userInsufficientModel.creditsNeeded ?? 10).truncate()} \n${S.of(context).tap_to_view_details}",
                  photoUrl: userInsufficientModel.senderPhotoUrl,
                  entityName: userInsufficientModel.senderName,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_context) {
                        return TimebankUserInsufficientCreditsDialog(
                          userInsufficientModel: userInsufficientModel,
                          timeBankId: userInsufficientModel.timebankId,
                          notificationId: notification.id,
                          userModel: SevaCore.of(context).loggedInUser,
                          timebankModel: widget.timebankModel,
                          onMessageClick: () {
                            ParticipantInfo sender = ParticipantInfo(
                              id: SevaCore.of(context).loggedInUser.sevaUserID,
                              name: SevaCore.of(context).loggedInUser.fullname,
                              photoUrl:
                                  SevaCore.of(context).loggedInUser.photoURL,
                              type: ChatType.TYPE_TIMEBANK,
                            );

                            ParticipantInfo reciever = ParticipantInfo(
                              id: notification.senderUserId,
                              name: userInsufficientModel.senderName,
                              photoUrl: userInsufficientModel.senderPhotoUrl,
                              type: ChatType.TYPE_PERSONAL,
                            );

                            createAndOpenChat(
                              isTimebankMessage: true,
                              context: context,
                              timebankId: userInsufficientModel.timebankId!,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity!,
                              sender: sender,
                              reciever: reciever,
                              isFromRejectCompletion: false,
                              feedId: '',
                              onChatCreate: () {
                                Navigator.of(context).pop();
                              },
                              showToCommunities: [],
                              entityId: '',
                            );

                            Navigator.pop(_context);
                          },
                          onDonateClick: () async {
                            Navigator.pop(_context);
                            _showFontSizePickerDialog(
                                context,
                                notification.senderUserId!,
                                widget.timebankModel!,
                                userInsufficientModel);
                          },
                        );
                      },
                    );
                  },
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
                break;
              case NotificationType.TypeMemberJoinViaCode:
                UserAddedModel userAddedModel =
                    UserAddedModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: userAddedModel.adminName,
                  isDissmissible: true,
                  onDismissed: () async {
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: null,
                  photoUrl: userAddedModel.timebankImage,
                  title: S.of(context).member_joined_via_code_title.replaceAll(
                      '**communityName**', userAddedModel.timebankName!),
                  subTitle: S
                      .of(context)
                      .member_joined_via_code_subtitle
                      .replaceAll(
                          '**communityName**', userAddedModel.timebankName!)
                      .replaceAll(
                          '**fullName**', userAddedModel.addedMemberName!),
                );
                break;

              //Below is commented out because Community/timebank will not receive Speaker request notification

              // case NotificationType.OneToManyRequestAccept:
              //   Map<dynamic,dynamic> oneToManyModel = notification.data;
              //     return NotificationCard(
              //       timestamp: notification.timestamp,
              //       entityName: 'NAME',
              //       isDissmissible: true,
              //       onDismissed: () {
              //         FirestoreManager.readTimeBankNotification(
              //           notificationId: notification.id,
              //           timebankId: notification.timebankId,
              //         );
              //       },
              //       onPressed: () async {

              //       },
              //       photoUrl: oneToManyModel['requestorphotourl'],
              //       title: 'Invited to instruct a session',
              //       subTitle: '${oneToManyModel['fullname']} - ${oneToManyModel['title']}',
              //     );
              //   break;

              case NotificationType.OneToManyRequestInviteAccepted:
                Map oneToManyRequestModel = notification.data!;
                RequestModel model =
                    new RequestModel.fromMap(notification.data!);
                return NotificationCard(
                    timestamp: notification.timestamp!,
                    entityName: null,
                    isDissmissible: true,
                    onDismissed: () {
                      FirestoreManager.readTimeBankNotification(
                        notificationId: notification.id,
                        timebankId: notification.timebankId,
                      );
                    },
                    onPressed: null,
                    // TO BE MADE
                    photoUrl: oneToManyRequestModel['selectedInstructor']
                        ['photoURL'],
                    title: S.of(context).invitation_accepted,
                    subTitle: S
                        .of(context)
                        .speaker_accepted_invite_notification
                        .replaceAll('**speakerName',
                            model.selectedInstructor!.fullname!));

                break;

              case NotificationType.OneToManyRequestInviteRejected:
                Map oneToManyRequestModel = notification.data!;
                RequestModel model =
                    new RequestModel.fromMap(notification.data!);
                return NotificationCard(
                    timestamp: notification.timestamp!,
                    entityName: null,
                    isDissmissible: true,
                    onDismissed: () async {
                      await FirestoreManager.readTimeBankNotification(
                        notificationId: notification.id,
                        timebankId: notification.timebankId,
                      );
                    },
                    onPressed: () async {
                      RequestModel newRequestModel = RequestModel(
                          communityId: SevaCore.of(context)
                              .loggedInUser
                              .currentCommunity);
                      await CollectionRef.requests
                          .doc(model.id)
                          .get()
                          .then((returnedModel) {
                        newRequestModel = RequestModel.fromMap(
                            returnedModel.data() as Map<String, dynamic>);
                        log("request returned is: ${(returnedModel.data() as Map<String, dynamic>)['title']}");
                        setState(() {});
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRequest(
                            timebankId: SevaCore.of(context)
                                .loggedInUser
                                .currentTimebank,
                            requestModel: newRequestModel,
                          ),
                        ),
                      );

                      await FirestoreManager.readTimeBankNotification(
                        notificationId: notification.id,
                        timebankId: notification.timebankId,
                      );
                    },
                    photoUrl: model.selectedInstructor!.photoURL,
                    title: S.of(context).speaker_rejected,
                    subTitle: model.selectedInstructor!.fullname! +
                        S.of(context).speakerRejectedNotificationLabel +
                        model.title!);

                break;

              case NotificationType.OneToManyRequestCompleted:
                Map oneToManyRequestModel = notification.data!;
                RequestModel model = RequestModel.fromMap(notification.data!);
                return NotificationCardOneToManyCompletedApproval(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: false,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressedApprove: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return OneToManyCreatorCompleteRequestPage(
                            requestModel: model,
                            onFinish: () async {
                              await FirestoreManager.readTimeBankNotification(
                                notificationId: notification.id,
                                timebankId: notification.timebankId,
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  onPressedReject: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext viewContext) {
                          return AlertDialog(
                            title:
                                Text(S.of(context).reject_request_completion),
                            actions: <Widget>[
                              CustomTextButton(
                                color: Theme.of(context).primaryColor,
                                child: Text(
                                  S.of(context).yes,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () async {
                                  Navigator.of(viewContext).pop();
                                  await oneToManyCreatorRequestCompletionRejectedTimebankNotifications(
                                      model,
                                      context,
                                      SevaCore.of(context).loggedInUser,
                                      true);
                                  await FirestoreManager
                                      .readTimeBankNotification(
                                    notificationId: notification.id,
                                    timebankId: notification.timebankId,
                                  );
                                },
                              ),
                              CustomTextButton(
                                color: Theme.of(context).colorScheme.secondary,
                                child: Text(
                                  S.of(context).no,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.of(viewContext).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                  photoUrl: oneToManyRequestModel['selectedInstructor']
                      ['photoURL'],
                  title: model.title!,
                  subTitle:
                      S.of(context).speaker_requested_completion_notification,
                );
                break;

              case NotificationType.OneToManyRequestAccept:
                Map<dynamic, dynamic> oneToManyModel = notification.data!;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () async {},
                  photoUrl: oneToManyModel['requestorphotourl'],
                  title: oneToManyModel['requestCreatorName'],
                  subTitle: 'added you as Speaker for request: ' +
                      oneToManyModel['title'],
                );
                break;

              case NotificationType.NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: false,
                  // onDismissed: () {
                  //   FirestoreManager.readTimeBankNotification(
                  //     notificationId: notification.id,
                  //     timebankId: notification.timebankId,
                  //   );
                  // },
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (_context) => AlertDialog(
                        title: Text(requestModelNew!.roomOrTool ==
                                LendingType.PLACE.readable
                            ? S
                                .of(context)
                                .admin_borrow_request_received_back_check_place
                            : S
                                .of(context)
                                .admin_borrow_request_received_back_check_item),
                        //label to be created later (borrow request)
                        actions: [
                          CustomTextButton(
                            onPressed: () {
                              Navigator.of(_context).pop();
                            },
                            child: Text(
                              S.of(context).not_yet,
                              style: TextStyle(
                                  fontSize: 17,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                          CustomTextButton(
                            onPressed: () async {
                              Navigator.of(_context).pop();

                              //Update request to complete it
                              //requestModelNew.approvedUsers = [];
                              requestModelNew!.acceptors = [];
                              requestModelNew!.accepted =
                                  true; //so that we can know that this request has completed
                              if (requestModelNew?.roomOrTool ==
                                  LendingType.ITEM.readable) {
                                requestModelNew?.borrowModel?.itemsReturned =
                                    true;
                              } else {
                                requestModelNew?.borrowModel?.isCheckedOut =
                                    true;
                              }
                              await lenderReceivedBackCheck(
                                  notification: notification,
                                  requestModelUpdated: requestModelNew!);
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
                  photoUrl: model.photoUrl,
                  title: '${model.title}',
                  subTitle:
                      "This request has now ended. Tap to complete the request.",
                );
                break;

              case NotificationType.NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () async {
                    checkForReviewBorrowRequests(notification);

                    // subjectBorrow.add(0);
                  },
                  photoUrl: model.photoUrl,
                  title: '${model.title}',
                  subTitle:
                      "The request has completed and an email has been sent to you. Tap to leave a feedback.",
                );
                break;

              case NotificationType
                  .NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {
                    logger.e("PRESSED ONE");
                    handleFeedBackNotificationBorrowRequest(
                      context,
                      requestModelNew!,
                      notification.id!,
                    );
                  },
                  photoUrl: model.photoUrl,
                  title: '${model.title}',
                  subTitle: S.of(context).lender_acknowledged_feedback,
                );
                break;

              case NotificationType.RequestAccept:
                RequestModel model = RequestModel.fromMap(notification.data!);
                return TimebankRequestWidget(
                  model: model,
                  notification: notification,
                );
                break;

              case NotificationType.ACKNOWLEDGE_DONOR_DONATION:
                DonationModel donationModel =
                    DonationModel.fromMap(notification.data!);
                double amount = 0;
                if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.REQUESTED) {
                  amount = donationModel.cashDetails!.cashDetails!.amountRaised!
                      .toDouble();
                } else if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.PLEDGED) {
                  donationModel.notificationId = notification.id;
                } else {
                  amount = donationModel.cashDetails!.pledgedAmount!;
                }
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: donationModel.donorDetails!.name,
                  isDissmissible: true,
                  onDismissed: () {
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RequestDonationDisputePage(
                            convertedAmount:
                                donationModel.cashDetails!.pledgedAmount ?? 0.0,
                            convertedAmountRaised: donationModel
                                    .cashDetails!.cashDetails!.amountRaised ??
                                0.0,
                            currency: donationModel.cashDetails!.cashDetails!
                                    .requestCurrencyType ??
                                '',
                            model: donationModel,
                            notificationId: notification.id!,
                          );
                        },
                      ),
                    );
                  },
                  photoUrl: donationModel.donorDetails!.photoUrl,
                  subTitle:
                      "${donationModel.donorDetails!.name}  ${S.of(context).pledged_to_donate} ${donationModel.donationType == RequestType.CASH ? "${donationModel.cashDetails!.cashDetails!.requestCurrencyType} ${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
                  title: S.of(context).donations_received,
                );
                break;
              case NotificationType.GOODS_DONATION_REQUEST:
                DonationModel donationModel =
                    DonationModel.fromMap(notification.data!);
                var amount;
                if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.REQUESTED) {
                  amount =
                      donationModel.cashDetails!.cashDetails!.amountRaised!;
                } else {
                  amount = donationModel.cashDetails!.pledgedAmount;
                }
                logger.i("==============<<<<<<<<<<<<<<<>>>>>>>>> $amount");
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: donationModel.donorDetails!.name,
                  isDissmissible: true,
                  onDismissed: () {
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RequestDonationDisputePage(
                            model: donationModel,
                            notificationId: notification.id!,
                            convertedAmount:
                                donationModel.cashDetails?.pledgedAmount ?? 0.0,
                            convertedAmountRaised: donationModel
                                    .cashDetails?.cashDetails?.amountRaised ??
                                0.0,
                            currency: donationModel.cashDetails?.cashDetails
                                    ?.requestCurrencyType ??
                                '',
                          );
                        },
                      ),
                    );
                  },
                  photoUrl: donationModel.donorDetails!.photoUrl,
                  subTitle:
                      "${donationModel.donorDetails!.name}  ${S.of(context).requested.toLowerCase()} ${donationModel.donationType == RequestType.CASH ? "\$${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
                  title: S.of(context).donations_requested,
                );
                break;

              case NotificationType.TypeMemberExitTimebank:
                UserExitModel userExitModel =
                    UserExitModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: S.of(context).timebank_exit,
                  subTitle:
                      '${userExitModel.userName!.toLowerCase()} ${S.of(context).has_exited_from} ${userExitModel.timebank}, ${S.of(context).tap_to_view_details}',
                  photoUrl: userExitModel.userPhotoUrl ?? defaultUserImageURL,
                  onDismissed: () {
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_context) {
                        return TimebankUserExitDialogView(
                          userExitModel: userExitModel,
                          timeBankId: notification.timebankId,
                          notificationId: notification.id,
                          userModel: SevaCore.of(context).loggedInUser,
                        );
                      },
                    );
                  },
                );
                break;

              case NotificationType.JoinRequest:
                return TimebankJoinRequestWidget(
                    notification: notification,
                    timebankModel: widget.timebankModel);

              case NotificationType.APPROVE_SPONSORED_GROUP_REQUEST:
                return SponsorGroupRequestWidget(notification: notification);
                break;

              case NotificationType.RequestCompleted:
                Map<dynamic, dynamic> oneToManyModel = notification.data!;
                // log('One TO Many Data check:  ' +
                //     oneToManyModel['creatorName']);
                if (oneToManyModel['requestType'] == 'ONE_TO_MANY_REQUEST') {
                  return OneToManyCreatorApproveCompletionCard(
                    timestamp: notification.timestamp!,
                    entityName: 'NAME',
                    isDissmissible: true,
                    onDismissed: () {
                      FirestoreManager.readTimeBankNotification(
                        notificationId: notification.id,
                        timebankId: notification.timebankId,
                      );
                    },
                    onPressedAccept: () async {},
                    onPressedReject: () async {},
                    photoUrl: oneToManyModel['requestorphotourl'],
                    creatorName: oneToManyModel['selectedInstructor']
                        ['fullname'],
                    title: S.of(context).completed_the_request,
                    //subTitle:
                    //    '${oneToManyModel['fullname']} - ${oneToManyModel['title']}',
                  );
                } else {
                  return TimebankRequestCompletedWidget(
                    notification: notification,
                    timebankModel: widget.timebankModel,
                    parentContext: parentContext,
                  );
                }
                break;

              case NotificationType.RequestApprove:
                RequestModel model = RequestModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: null,
                  isDissmissible: true,
                  onDismissed: () {
                    log('REQUEST REJECT:   ' +
                        notification.id! +
                        ' ' +
                        notification.timebankId!);
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: null,
                  // TO BE MADE
                  photoUrl: model.photoUrl,
                  title: model.title!,
                  subTitle:
                      '${S.of(context).notifications_approved_by} ${model.fullName}',
                );
                break;

              case NotificationType.RequestReject:
                RequestModel model = RequestModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: model.fullName,
                  title: model.title!,
                  isDissmissible: true,
                  onDismissed: () {
                    log('REQUEST REJECT:   ' +
                        notification.id! +
                        ' ' +
                        notification.timebankId!);
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: null,
                  photoUrl: model.photoUrl,
                  subTitle:
                      '${S.of(context).notifications_request_rejected_by} ${model.fullName} ',
                );
                break;

              case NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: S.of(context).notifications_debited,
                  subTitle: TimebankNotificationMessage
                      .DEBIT_FULFILMENT_FROM_TIMEBANK
                      .replaceFirst(
                        '*n',
                        (data.classDetails!.numberOfClassHours! +
                                data.classDetails!.numberOfPreperationHours!)
                            .toString(),
                      )
                      .replaceFirst('*name', data.classDetails!.classHost!)
                      .replaceFirst('*class', data.classDetails!.classTitle!),
                  entityName: data.classDetails!.classHost!,
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
                break;

              case NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: S.of(context).notifications_credited,
                  subTitle: TimebankNotificationMessage
                      .CREDIT_FROM_OFFER_APPROVED
                      .replaceFirst('*n',
                          data.classDetails!.numberOfClassHours.toString())
                      .replaceFirst('*class', data.classDetails!.classTitle!),
                  // photoUrl: data.participantDetails.photourl,
                  entityName: data.participantDetails!.fullname,
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
                break;

              case NotificationType.TYPE_DELETION_REQUEST_OUTPUT:
                var requestData =
                    SoftDeleteRequestDataHolder.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName:
                      requestData.entityTitle ?? S.of(context).deletion_request,
                  photoUrl: null,
                  title: requestData.requestAccepted
                      ? "${requestData.entityTitle} ${S.of(context).notifications_was_deleted}"
                      : "${requestData.entityTitle} ${S.of(context).cannot_be_deleted}",
                  subTitle: requestData.requestAccepted
                      ? S
                          .of(context)
                          .delete_request_success
                          .replaceAll('**requestTitle', requestData.entityTitle)
                      : S.of(context).cannot_be_deleted_desc.replaceAll(
                          '**requestData.entityTitle', requestData.entityTitle),
                  onPressed: () => !requestData.requestAccepted
                      ? showDialogForIncompleteTransactions(
                          context: context,
                          deletionRequest: requestData,
                        )
                      : null,
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );

              case NotificationType.TYPE_REPORT_MEMBER:
                ReportedMemberNotificationModel data =
                    ReportedMemberNotificationModel.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: S.of(context).member_reported_title,
                  subTitle: TimebankNotificationMessage.MEMBER_REPORT
                      .replaceFirst('*name', data.reportedUserName!),
                  photoUrl: data.reportedUserImage,
                  entityName: data.reportedUserName,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );

              case NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST:
                var body = WithdrawnRequestBody.fromMap(notification.data!);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: body.fullName,
                  photoUrl: null,
                  title:
                      "${S.of(context).notifications_approved_withdrawn_title}",
                  subTitle:
                      "${body.fullName} ${S.of(context).notifications_approved_withdrawn_subtitle} ${body.requestTite}.  ",
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );
              case NotificationType.CASH_DONATION_MODIFIED_BY_DONOR:
              case NotificationType.GOODS_DONATION_MODIFIED_BY_DONOR:
                return PersonalNotificationsReducerForDonations
                    .getWidgetForDonationsModifiedByDonor(
                  context: context,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                  notificationsModel: notification,
                );

              case NotificationType.DEBITED_SEVA_COINS_TIMEBANK:
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  title: S.of(context).credits_debited,
                  subTitle: S.of(context).credits_debited,
                  photoUrl: null,
                  entityName: S.of(context).debited,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );

              case NotificationType.SEVA_COINS_CREDITED:
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: "CR",
                  photoUrl: null,
                  title: S.of(context).notifications_credited,
                  subTitle: notification.data!['credits'].toString() +
                      " " +
                      S.of(context).seva_credits +
                      ' ' +
                      S.of(context).notifications_credited_to,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );

              case NotificationType.SEVA_COINS_DEBITED:
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: "CR",
                  photoUrl: null,
                  title: S.of(context).credits_debited,
                  subTitle: notification.data!['credits'].toString() +
                      " " +
                      S.of(context).credits_debited_msg,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );
              case NotificationType.MANUAL_TIME_CLAIM:
                var body = ManualTimeModel.fromMap(
                    Map<String, dynamic>.from(notification.data!));

                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: body.userDetails!.name,
                  photoUrl: body.userDetails!.photoUrl,
                  title: S.of(context).manual_notification_title,
                  subTitle: S
                      .of(context)
                      .manual_notification_subtitle
                      .replaceAll('**name', body.userDetails!.name!)
                      .replaceAll('**number', '${body.claimedTime! / 60}')
                      .replaceAll('**communityName', body.communityName ?? ' '),
                  isDissmissible: false,
                  onPressed: () {
                    manualTimeActionDialog(
                      context,
                      notification.id!,
                      notification.timebankId!,
                      body,
                    );
                  },
                );
              case NotificationType.COMMUNITY_ADDED_TO_MESSAGE_ROOM:
                var data = notification.data;
                Map<String, dynamic> map =
                    Map<String, dynamic>.from(data!['creatorDetails']);
                ParticipantInfo creatorDetails = ParticipantInfo.fromMap(map);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: creatorDetails.name,
                  isDissmissible: true,
                  onDismissed: () {
                    dismissTimebankNotification(
                      timebankId: notification.timebankId,
                      notificationId: notification.id,
                    );
                  },
                  onPressed: null,
                  photoUrl: creatorDetails.photoUrl ?? defaultGroupImageURL,
                  title: 'Community chat join',
                  subTitle:
                      '${creatorDetails.name!.toLowerCase()} ${S.of(context).notifications_added_you} ${data['messageRoomName']} ${S.of(context).community_chat}.',
                );
                break;
              case NotificationType.COMMUNITY_REMOVED_FROM_MESSAGE_ROOM:
                var data = notification.data;
                Map<String, dynamic> map =
                    Map<String, dynamic>.from(data!['creatorDetails']);
                ParticipantInfo creatorDetails = ParticipantInfo.fromMap(map);
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: creatorDetails.name,
                  isDissmissible: true,
                  onDismissed: () {
                    dismissTimebankNotification(
                      timebankId: notification.timebankId,
                      notificationId: notification.id,
                    );
                  },
                  onPressed: null,
                  photoUrl: creatorDetails.photoUrl,
                  title: 'Community chat remove',
                  subTitle:
                      '${creatorDetails.name!.toLowerCase()} removed you from ${data['messageRoomName']}.',
                );
                break;

              case NotificationType.LendingOfferIdleFirstWarning:
                OfferModel model = OfferModel.fromMap(notification.data!);
                offerModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrlImage,
                  title: model.individualOfferDataModel!.title +
                      S.of(context).idle_for_2_weeks,
                  subTitle: S
                      .of(context)
                      .idle_lending_offer_first_warning
                      .replaceAll('***', '2'),
                );
                break;

              case NotificationType.LendingOfferIdleSecondWarning:
                OfferModel model = OfferModel.fromMap(notification.data!);
                offerModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrlImage,
                  title: model.individualOfferDataModel!.title +
                      S.of(context).idle_for_4_weeks,
                  subTitle: S
                      .of(context)
                      .idle_lending_offer_second_warning
                      .replaceAll('***', '4'),
                );
                break;

              case NotificationType.LendingOfferIdleSoftDeleted:
                OfferModel model = OfferModel.fromMap(notification.data!);
                offerModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrlImage,
                  title: model.individualOfferDataModel!.title +
                      ' ' +
                      S
                          .of(context)
                          .notifications_was_deleted
                          .replaceAll('!', ''),
                  subTitle:
                      S.of(context).idle_lending_offer_third_warning_deleted,
                );
                break;

              case NotificationType.BorrowRequestIdleFirstWarning:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrl,
                  title: model.title! + S.of(context).idle_for_2_weeks,
                  subTitle: S
                      .of(context)
                      .idle_borrow_request_first_warning
                      .replaceAll('***', '2'),
                );
                break;

              case NotificationType.BorrowRequestIdleSecondWarning:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrl,
                  title: model.title! + S.of(context).idle_for_4_weeks,
                  subTitle: S
                      .of(context)
                      .idle_borrow_request_second_warning
                      .replaceAll('***', '4'),
                );
                break;

              case NotificationType.BorrowRequestIdleSoftDeleted:
                var model = RequestModel.fromMap(notification.data!);
                requestModelNew = model;
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: 'NAME',
                  isDissmissible: true,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {},
                  photoUrl: model.photoUrl,
                  title: model.title! +
                      ' ' +
                      S
                          .of(context)
                          .notifications_was_deleted
                          .replaceAll('!', ''),
                  subTitle:
                      S.of(context).idle_borrow_request_third_warning_deleted,
                );
                break;

//! NEW NOTIFICATION BELOW ---------------------------------------------------------->
//Feature name: Create Notification for community receiving donation //1.9 Release Feature
              case NotificationType.COMMUNITY_RECEIVED_CREDITS_DONATION:
                return NotificationCard(
                  timestamp: notification.timestamp!,
                  entityName: "CR",
                  photoUrl: notification.data!['donorPhotoUrl'] ?? null,
                  title: S.of(context).seva_credits_donated_text,
                  subTitle: S.of(context).you_have_recieved +
                      notification.data!['credits'].toStringAsFixed(1) +
                      " " +
                      S.of(context).seva_credits_from_text +
                      " " +
                      (notification.data!['donorName'] != null
                          ? (notification.data![
                              'donorName']) //or can use notification.data['communityName']
                          : '') +
                      " " +
                      S.of(context).as_a_donation_text,
                  onDismissed: () async {
                    await FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
//! NEW NOTIFICATION ABOVE ---------------------------------------------------------->

              default:
                log("Unhandled timebank notification type ${notification.type} ${notification.id}");
                // FirebaseCrashlytics.instance.log(
                //     "Unhandled timebank notification type ${notification.type} ${notification.id}");
                return Container();
                break;
            }
          },
        );
      },
    );
  }

  void _showFontSizePickerDialog(
      BuildContext context,
      String userId,
      TimebankModel model,
      UserInsufficentCreditsModel userInsufficientModel) async {
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (widget.timebankModel!.balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).insufficient_credits_to_donate),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    // <-- note the async keyword here
    double donateAmount = 0;
//     this will contain the result from Navigator.pop(context, result)
    final donateAmount_Received = await showDialog<double>(
      context: context,
      builder: (context) => InputDonateDialog(
          donateAmount: donateAmount,
          maxAmount: widget.timebankModel!.balance.toDouble(),
          creditsNeeded: userInsufficientModel.creditsNeeded),
    );

    // execution of this code continues when the dialog was closed (popped)

    // note that the result can also be null, so check it
    // (back button or pressed outside of the dialog)
    if (donateAmount_Received != null) {
      donateAmount = donateAmount_Received;
      widget.timebankModel!.balance =
          widget.timebankModel!.balance - donateAmount_Received;

      //from, to, timestamp, credits, isApproved, type, typeid, timebankid
      TransactionBloc().createNewTransaction(
        model.id,
        userId,
        DateTime.now().millisecondsSinceEpoch,
        donateAmount,
        true,
        "ADMIN_DONATE_TOUSER",
        null,
        model.id,
        communityId: model.communityId,
        toEmailORId: userId,
        fromEmailORId: model.id,
      );

      //SEND DONATION NOTIFICATION TO MEMBER
      UserModel userModel = await FirestoreManager.getUserForId(
          sevaUserId: userInsufficientModel.senderId!);
      final DonationsRepository _donationsRepository = DonationsRepository();
      await _donationsRepository!.donationCreditedNotificationToMember(
        context: context,
        donateAmount: donateAmount,
        model: model,
        user: userModel,
        toMember: true,
      );

      await showDialog<double>(
        context: context,
        builder: (context) => InputDonateSuccessDialog(
            onComplete: () => {Navigator.pop(context)}),
      );
    }
  }

  Future lenderReceivedBackCheck({
    NotificationsModel? notification,
    RequestModel? requestModelUpdated,
  }) async {
    showProgressForCreditRetrieval(parentContext!);

    //Send Receipt Email to Lender & Borrowr
    await MailBorrowRequestReceipts.sendBorrowRequestReceipts(
        requestModelUpdated!);
    log('Sent receipts to lender and borrower api');

    //Send Notification To Lender to let them know it's acknowledged
    await sendNotificationLenderReceipt(
        communityId: requestModelNew!.communityId!,
        timebankId: requestModelNew!.timebankId!,
        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID!,
        userEmail: SevaCore.of(context).loggedInUser.email!,
        requestModel: requestModelNew!);

    //NOTIFICATION_TO_BORROWER _COMPLETION_FEEDBACK
    await sendNotificationBorrowerRequestCompletedFeedback(
        communityId: requestModelNew!.communityId!,
        timebankId: requestModelNew!.timebankId!,
        sevaUserId: requestModelNew!.sevaUserId!,
        userEmail: requestModelNew!.email!,
        requestModel: requestModelNew!);

    //Make this notification isRead: true
    log('notification id:' + notification!.id!);
    log('timebank id:' + notification.timebankId!);

    //Make this notification isRead: true
    FirestoreManager.readTimeBankNotification(
      notificationId: notification.id,
      timebankId: notification.timebankId,
    );

    FirestoreManager.requestComplete(model: requestModelNew!);

    Navigator.of(parentContext!).pop();
  }

  void checkForReviewBorrowRequests(NotificationsModel notification) async {
    logger.e('COMES BACK HERE 2');

    Map results = await Navigator.of(parentContext!).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return BorrowRequestFeedBackView(requestModel: requestModelNew);
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      log('after feedback here 1');
      showProgressForCreditRetrieval(parentContext!);

      onActivityResult(
          results, SevaCore.of(context).loggedInUser, notification);
    } else {}
  }

  Future<void> onActivityResult(
    Map results,
    UserModel loggedInUser,
    NotificationsModel notification,
  ) async {
    // adds review to firestore
    try {
      logger.i('here 1');
      await CollectionRef.reviews.add({
        "reviewer": SevaCore.of(context).loggedInUser.email,
        "reviewed": requestModelNew!.email,
        "ratings": results['selection'],
        "device_info": results['device_info'],
        "requestId": requestModelNew!.id,
        "comments":
            (results['didComment'] ? results['comment'] : "No comments"),
      });
      logger.i('here 2');

      await sendMessageToMember(
          message: results['didComment'] ? results['comment'] : "No comments",
          loggedInUser: loggedInUser);

      logger.i('here 3');
      // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)
      logger.e('comes here 1');

      //doing below since in RequestModel if != null nothing happens
      //so manually removing user from task
      // requestModelNew.approvedUsers = [];
      // requestModelNew.acceptors = [];
      // requestModelNew.accepted =
      //     true; //so that we can know that this request has completed

      if (requestModelNew!.requestType! == RequestType.BORROW) {
        log('UID CHECK borrower:  ' +
            SevaCore.of(context).loggedInUser.sevaUserID! +
            ' | ' +
            requestModelNew!.sevaUserId!);
        if (SevaCore.of(context).loggedInUser.sevaUserID ==
            requestModelNew!.sevaUserId!) {
          FirestoreManager.borrowRequestFeedbackBorrowerUpdate(
              model: requestModelNew!);
        } else {
          FirestoreManager.borrowRequestFeedbackLenderUpdate(
              model: requestModelNew!);
        }
      }

      //requestModelNew.accepted = false;

      // FirestoreManager.borrowRequestComplete(model: requestModelNew);

      // FirestoreManager.createTaskCompletedNotification(
      //   model: NotificationsModel(
      //     id: utils.Utils.getUuid(),
      //     data: requestModelNew.toMap(),
      //     type: NotificationType.RequestCompleted,
      //     senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      //     targetUserId: requestModelNew.sevaUserId,
      //     communityId: requestModelNew.communityId,
      //     timebankId: requestModelNew.timebankId,
      //     isTimebankNotification:
      //         requestModelNew.requestMode == RequestMode.TIMEBANK_REQUEST,
      //     isRead: false,
      //   ),
      // );

      Navigator.pop(parentContext!);
      FirestoreManager.readTimeBankNotification(
        notificationId: notification.id,
        timebankId: notification.timebankId,
      );
      //Navigator.of(context).pop();
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<void> sendMessageToMember({
    UserModel? loggedInUser,
    String? message,
  }) async {
    if (requestModelNew != null && requestModelNew!.timebankId != null) {
      TimebankModel timebankModel =
          (await getTimeBankForId(timebankId: requestModelNew!.timebankId!))
              as TimebankModel;
      UserModel userModel = await FirestoreManager.getUserForId(
          sevaUserId: requestModelNew!.sevaUserId!);
      if (userModel != null && timebankModel != null) {
        ParticipantInfo receiver = ParticipantInfo(
          id: requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
              ? userModel.sevaUserID
              : requestModelNew!.timebankId,
          photoUrl: requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
              ? userModel.photoURL
              : timebankModel.photoUrl,
          name: requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
              ? userModel.fullname
              : timebankModel.name,
          type: requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
              ? ChatType.TYPE_PERSONAL
              : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                  ? ChatType.TYPE_TIMEBANK
                  : ChatType.TYPE_GROUP,
        );

        ParticipantInfo sender = ParticipantInfo(
          id: loggedInUser!.sevaUserID,
          photoUrl: loggedInUser.photoURL,
          name: loggedInUser.fullname,
          type: requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
              ? ChatType.TYPE_PERSONAL
              : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                  ? ChatType.TYPE_TIMEBANK
                  : ChatType.TYPE_GROUP,
        );
        await sendBackgroundMessage(
            messageContent: utils.getReviewMessage(
              requestTitle: requestModelNew!.title,
              userName: loggedInUser!.fullname,
              isForCreator: true,
              reviewMessage: message,
            ),
            reciever: receiver,
            isTimebankMessage:
                requestModelNew!.requestMode == RequestMode.PERSONAL_REQUEST
                    ? false
                    : true,
            timebankId: requestModelNew!.timebankId!,
            communityId: loggedInUser!.currentCommunity!,
            sender: sender);
      }
    }
  }

  BuildContext? creditRequestDialogContext;

  void showProgressForCreditRetrieval(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: parentContext!,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

  String getTime(int timeInMilliseconds, String timezoneAbb) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = DateFormat.jm().format(
      localtime,
    );
    return from;
  }

  String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
    DateFormat dateFormat =
        DateFormat('d MMM hh:mm a ', Locale(getLangTag()).toLanguageTag());
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
    DateTime localtime = getDateTimeAccToUserTimezone(
        dateTime: datetime, timezoneAbb: timezoneAbb);
    String from = dateFormat.format(
      localtime,
    );
    return from;
  }

  Future<void> sendNotificationLenderReceipt(
      {String? communityId,
      String? sevaUserId,
      String? timebankId,
      String? userEmail,
      RequestModel? requestModel}) async {
    NotificationsModel notification = NotificationsModel(
        isTimebankNotification:
            requestModel!.requestMode == RequestMode.TIMEBANK_REQUEST,
        id: Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: requestModel.toMap(),
        isRead: false,
        type: NotificationType.NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: sevaUserId);

    await CollectionRef.users
        .doc(userEmail)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());

    log('WRITTEN TO DB--------------------->>');
  }

  Future<void> sendNotificationBorrowerRequestCompletedFeedback(
      {String? communityId,
      String? sevaUserId,
      String? timebankId,
      String? userEmail,
      RequestModel? requestModel}) async {
    NotificationsModel notification = NotificationsModel(
        isTimebankNotification:
            requestModel!.requestMode == RequestMode.TIMEBANK_REQUEST,
        id: Utils.getUuid(),
        timebankId: timebankId,
        data: requestModel.toMap(),
        isRead: false,
        type: NotificationType.NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: sevaUserId);

    await CollectionRef.users
        .doc(userEmail)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());

    log('WRITTEN TO DB--------------------->>');
  }

  void handleFeedBackNotificationBorrowRequest(BuildContext context,
      RequestModel requestModel, String notificationId) async {
    logger.e("handleFeedBackNotificationBorrowRequest TWO");

    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewFeedback(
          feedbackType: FeedbackType
              .FOR_BORROW_REQUEST_BORROWER, //if new questions then have to change this and update
        ),
      ),
    );

    logger.e("###-------------#### INSIDE ${jsonEncode(results)}");
    if (results != null && results.containsKey('selection')) {
      logger.e("INSIDE IF 1 handleFeedBackNotificationBorrowRequest");
      CollectionRef.reviews.add(
        {
          "reviewer": SevaCore.of(context).loggedInUser.email,
          "reviewed": requestModel.approvedUsers!.first, //TODO
          "ratings": results['selection'],
          "requestId": requestModel.id,
          "comments":
              results['didComment'] ? results['comment'] : "No comments",
          'liveMode': !AppConfig.isTestCommunity,
        },
      );

      logger.e("INSIDE IF 2 handleFeedBackNotificationBorrowRequest");

      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          FeedbackType.FOR_BORROW_REQUEST_BORROWER,
          results,
          requestModel,
          SevaCore.of(context).loggedInUser);

      BorrowAcceptorModel userModel = await getBorrowRequestAcceptorModel(
          requestId: requestModel.id!,
          acceptorEmail: requestModel.approvedUsers!.first);
      if (userModel != null &&
          requestModelNew != null &&
          requestModelNew!.timebankId != null) {
        TimebankModel timebankModel =
            (await getTimeBankForId(timebankId: requestModelNew!.timebankId!))
                as TimebankModel;
        ParticipantInfo sender = ParticipantInfo(
          id: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? loggedInUser!.sevaUserID
              : requestModel.timebankId,
          photoUrl: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? loggedInUser!.photoURL
              : timebankModel.photoUrl,
          name: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? loggedInUser!.fullname
              : timebankModel.name,
          type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? ChatType.TYPE_PERSONAL
              : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                  ? ChatType.TYPE_TIMEBANK
                  : ChatType.TYPE_GROUP,
        );

        ParticipantInfo reciever = ParticipantInfo(
          id: userModel.acceptorId,
          photoUrl: userModel.acceptorphotoURL,
          name: userModel.acceptorName,
          type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
              ? ChatType.TYPE_PERSONAL
              : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                  ? ChatType.TYPE_TIMEBANK
                  : ChatType.TYPE_GROUP,
        );
        await sendBackgroundMessage(
            messageContent: getReviewMessage(
              isForCreator: false,
              requestTitle: requestModel.title,
              userName: loggedInUser!.fullname,
              reviewMessage:
                  results['didComment'] ? results['comment'] : "No comments",
            ),
            reciever: reciever,
            isTimebankMessage:
                requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                    ? false
                    : true,
            timebankId: requestModel.timebankId!,
            communityId: loggedInUser!.currentCommunity!,
            sender: sender);
      }
      FirestoreManager.readTimeBankNotification(
        notificationId: notificationId,
        timebankId: requestModel.timebankId,
      );
    } else {
      logger.e("NOT ADDED");
    }
  }
}
