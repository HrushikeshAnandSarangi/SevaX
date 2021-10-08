import 'dart:developer';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/reducer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card_oneToManyAccept.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card_oneToManySpeakerReclaims.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/request/pages/oneToManySpeakerTimeEntryComplete_page.dart';
import 'package:sevaexchange/ui/screens/transaction_details/dialog/transaction_details_dialog.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/requests/approveBorrowRequest.dart';
import 'package:sevaexchange/views/tasks/my_tasks_list.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';

import '../../../../labels.dart';

class PersonalNotifications extends StatefulWidget {
  @override
  _PersonalNotificationsState createState() => _PersonalNotificationsState();
}

BuildContext dialogContext;

class _PersonalNotificationsState extends State<PersonalNotifications>
    with AutomaticKeepAliveClientMixin {
  final subjectBorrow = ReplaySubject<int>();
  RequestModel requestModelNew;
  OfferModel offerModelNew;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 200));
      subjectBorrow
          .transform(ThrottleStreamTransformer(
              (_) => TimerStream(true, const Duration(seconds: 1))))
          .listen((data) {
        logger.e('COMES BACK HERE PERSONAL Notufications');
        checkForReviewBorrowRequests();
      });
    });
  }

  BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    parentContext = context;
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    final UserModel user = SevaCore.of(context).loggedInUser;

    return StreamBuilder<List<NotificationsModel>>(
      stream: _bloc.personalNotifications,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }
        if (snapshot.data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                S.of(context).no_notifications,
              ),
            ),
          );
        }
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextButton(
                padding: EdgeInsets.zero,
                child: Text(S.of(context).clear_all),
                textColor: Colors.blue,
                onPressed: () async {
                  if (await CustomDialogs.generalConfirmationDialogWithMessage(
                    context,
                    S.of(context).clear_notications,
                  )) {
                    _bloc.clearAllNotification(user.email);
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 20),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  NotificationsModel notification = snapshot.data[index];

                  Future<void> onDismissed() async {
                    await _bloc.clearNotification(
                      notificationId: notification.id,
                      email: user.email,
                    );
                  }

                  switch (notification.type) {
                    case NotificationType.TYPE_DELETION_REQUEST_OUTPUT:
                      return PersonalNotificationReducerForRequests
                          .getWidgetNotificaitonForDeletionrequest(
                        bloc: _bloc,
                        context: context,
                        email: user.email,
                        notification: notification,
                      );

                    case NotificationType.TransactionCredit:
                      return PersonalNotificationReducerForRequests
                          .getWidgetNotificationForTransactionCredit(
                        notification: notification,
                        loggedInUserEmail:
                            SevaCore.of(context).loggedInUser.email,
                      );

                    case NotificationType.TransactionDebit:
                      return PersonalNotificationReducerForRequests
                          .getWidgetNotificationForTransactionDebit(
                        notification: notification,
                        loggedInUserEmail:
                            SevaCore.of(context).loggedInUser.email,
                      );
                    case NotificationType.AcceptedOffer:
                      return PersonalNotificationReducerForRequests
                          .getWidgetForAcceptedOfferNotification(
                        notification: notification,
                      );

                    case NotificationType.TimeOfferInvitationFromCreator:
                      return PersonalNotificationsReducerForOffer
                          .getNotificationFromOfferCreator(
                        notification: notification,
                        context: context,
                        user: user,
                      );

                    case NotificationType.ACKNOWLEDGE_DONOR_DONATION:
                      return PersonalNotificationsRedcerForDonations
                          .getWidgetNotificationForAcknowlegeDonorDonation(
                        notification: notification,
                        context: context,
                        user: user,
                      );
                    case NotificationType.GOODS_DONATION_REQUEST:
                      return PersonalNotificationsRedcerForDonations
                          .getWidgetNotificationForOfferRequestGoods(
                        notification: notification,
                        context: context,
                        user: user,
                      );
                    case NotificationType.GroupJoinInvite:
                      return PersonalNotificationReducerForRequests
                          .getWidgetNotificationForGroupJoinInvite(
                        context: context,
                        notification: notification,
                        user: user,
                      );
                    case NotificationType.JoinRequest:
                      return PersonalNotificationReducerForRequests
                          .getNotificationForJoinRequest(
                        notification: notification,
                      );
                      break;

                    case NotificationType.RequestCompleted:
                      return PersonalNotificationReducerForRequests
                          .getWidgetForRequestCompleted(
                        notification: notification,
                        parentContext: parentContext,
                      );

                    // case NotificationType.OneToManyRequestDoneForSpeaker:
                    //   RequestModel model =
                    //       RequestModel.fromMap(notification.data);
                    //   return NotificationCard(
                    //     isDissmissible: true,
                    //     timestamp: notification.timestamp,
                    //     title: model.title + ' ' + 'request has now ended',
                    //     subTitle:
                    //         S.of(context).hosted_by + ': ' + model.fullName,
                    //     //entityName: '',
                    //     onDismissed: () {
                    //       NotificationsRepository.readUserNotification(
                    //         notification.id,
                    //         user.email,
                    //       );
                    //     },
                    //   );

                    case NotificationType.RequestCompletedApproved:
                      return PersonalNotificationReducerForRequests
                          .getWidgetForRequestCompletedApproved(
                        notification: notification,
                        context: context,
                        user: user,
                      );
                    case NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY:
                    case NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY:
                      DonationModel donationModel =
                          DonationModel.fromMap(notification.data);

                      return PersonalNotificationsRedcerForDonations
                          .getWidgetForSuccessfullDonation(
                        onDismissed: onDismissed,
                        onTap: () async {
                          RequestModel requestModel;
                          TimebankModel timebankModel;
                          CommunityModel communityModel;

                          try {
                            requestModel =
                                await FirestoreManager.getRequestFutureById(
                                    requestId: donationModel.requestId);
                          } catch (error) {
                            logger.e(
                                'ERROR FETCHING MODELS FOR TRANSACTIONS: ' +
                                    error.toString());
                          }
                          timebankModel =
                              await FirestoreManager.getTimeBankForId(
                                  timebankId: donationModel.timebankId);
                          logger.e('TIMEBANK MODEL MONEY DIALOG: ' +
                              timebankModel.name.toString());
                          communityModel = await FirestoreManager
                              .getCommunityDetailsByCommunityId(
                                  communityId: donationModel.communityId);

                          showDialog(
                            context: context,
                            builder: (contextDialog) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              insetPadding: EdgeInsets.zero,
                              child: TransactionDetailsDialog(
                                transactionModel: null,
                                donationModel: donationModel,
                                timebankModel: timebankModel,
                                requestModel: requestModel,
                                communityModel: communityModel,
                                loggedInUserId: SevaCore.of(context)
                                    .loggedInUser
                                    .sevaUserID,
                                loggedInEmail:
                                    SevaCore.of(context).loggedInUser.email,
                              ),
                            ),
                          );
                        },
                        context: context,
                        timestampVal: notification.timestamp,
                      );

                    case NotificationType.CASH_DONATION_MODIFIED_BY_DONOR:
                    case NotificationType.GOODS_DONATION_MODIFIED_BY_DONOR:
                      return PersonalNotificationsRedcerForDonations
                          .getWidgetForDonationsModifiedByDonor(
                        context: context,
                        onDismissed: onDismissed,
                        notificationsModel: notification,
                      );

                    case NotificationType.CASH_DONATION_MODIFIED_BY_CREATOR:
                    case NotificationType.GOODS_DONATION_MODIFIED_BY_CREATOR:
                      return PersonalNotificationsRedcerForDonations
                          .getWidgetForDonationsModifiedByCreator(
                        context: context,
                        onDismissed: onDismissed,
                        notificationsModel: notification,
                        timestampVal: notification.timestamp,
                      );

                    case NotificationType.RequestInvite:
                      RequestModel requestModel = RequestModel.fromMap(
                          notification.data['requestModel']);
                      TimebankModel timebankModel = TimebankModel.fromMap(
                          notification.data['timebankModel']);
                      logger.e(
                          'Here 21.5: ' + requestModel.requestType.toString());
                      if (requestModel.requestType == RequestType.BORROW) {
                        return NotificationCard(
                          entityName: requestModel.fullName,
                          isDissmissible: true,
                          onDismissed: () {
                            NotificationsRepository.readUserNotification(
                              notification.id,
                              user.email,
                            );
                          },
                          photoUrl: requestModel.photoUrl,
                          subTitle:
                              '${requestModel.fullName} ${S.of(context).notifications_requested_join} ${requestModel.title}, ${S.of(context).notifications_tap_to_view}',
                          title: S.of(context).join_borrow_request,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AcceptBorrowRequest(
                                  requestModel: requestModel,
                                  timeBankId: requestModel.timebankId,
                                  userId: SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID,
                                  parentContext: context,
                                  onTap: () async {
                                    //<----------- New Calendar Feature to be added here ----------->

                                    await acceptBorrowRequest(
                                        context: context,
                                        timebankModel: timebankModel,
                                        requestModel: requestModel);
                                    NotificationsRepository
                                        .readUserNotification(
                                      notification.id,
                                      user.email,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            );
                          },
                          timestamp: notification.timestamp,
                        );
                      } else {
                        logger.e('HERE 24');
                        return PersonalNotificationReducerForRequests
                            .getInvitationForRequest(
                          notification: notification,
                          user: user,
                          context: context,
                        );
                      }
                      break;

                    case NotificationType.OfferRequestInvite:
                      return PersonalNotificationReducerForRequests
                          .getOfferRequestInvitation(
                        notification: notification,
                        user: user,
                        context: context,
                      );

                    case NotificationType.RecurringOfferUpdated:
                      return PersonalNotificationReducerForRequests
                          .getNotificationForRecurringOffer(
                        bloc: _bloc,
                        context: context,
                        notification: notification,
                        user: user,
                      );
                      break;
                    case NotificationType.RecurringRequestUpdated:
                      return PersonalNotificationReducerForRequests
                          .getNotificationForRecurringRequestUpdated(
                        bloc: _bloc,
                        context: context,
                        notification: notification,
                        user: user,
                      );
                      break;
                    case NotificationType.RequestAccept:
                      return PersonalNotificationReducerForRequests
                          .getNotificationForRequestAccept(
                              notification: notification);

                    case NotificationType.CASH_DONATION_ACKNOWLEDGED_BY_DONOR:
                    case NotificationType.GOODS_DONATION_ACKNOWLEDGED_BY_DONOR:
                      //NOT SURE WHEATHER TO ADD THIS OR NOT
                      return Container();
                      break;

                    // case NotificationType.TypeChangeOwnership:
                    //   ChangeOwnershipModel ownershipModel =
                    //       ChangeOwnershipModel.fromMap(notification.data);
                    //   return ChangeOwnershipWidget(
                    //     timestamp: notification.timestamp,
                    //     notificationId: notification.id,
                    //     communityId: notification.communityId,
                    //     changeOwnershipModel: ownershipModel,
                    //     timebankId: notification.timebankId,
                    //     notificationsModel: notification,
                    //   );
                    //   break;

                    case NotificationType.OneToManyRequestAccept:
                      // Map oneToManyRequestModel = notification.data;
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return NotificationCardOneToManyAccept(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: false,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressedAccept: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext viewContext) {
                              return AlertDialog(
                                title: Text(S
                                    .of(context)
                                    .oneToManyRequestSpeakerAcceptRequest),
                                actions: <Widget>[
                                  CustomTextButton(
                                    shape: StadiumBorder(),
                                    color: Theme.of(context).primaryColor,
                                    child: Text(
                                      S.of(context).yes,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                    onPressed: () async {
                                      await oneToManySpeakerInviteAcceptedPersonalNotifications(
                                          model, context);

                                      Navigator.of(viewContext).pop();
                                    },
                                  ),
                                  CustomTextButton(
                                    shape: StadiumBorder(),
                                    color: Theme.of(context).accentColor,
                                    child: Text(
                                      S.of(context).no,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: 'Europa',
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(viewContext).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) {
                          //       return OneToManySpeakerTimeEntry(
                          //         requestModel: model,
                          //         onFinish: () async {
                          //           await oneToManySpeakerInviteAcceptedPersonalNotifications(
                          //               oneToManyRequestModel, context);
                          //           await onDismissed();
                          //         },
                          //       );
                          //     },
                          //   ),
                          // );
                        },
                        onPressedReject: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext viewContext) {
                                return AlertDialog(
                                  title: Text(S
                                      .of(context)
                                      .speaker_reject_invite_dialog),
                                  actions: <Widget>[
                                    CustomTextButton(
                                      shape: StadiumBorder(),
                                      color: Theme.of(context).primaryColor,
                                      child: Text(
                                        S.of(context).yes,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'Europa',
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(viewContext).pop();
                                        await oneToManySpeakerInviteRejected(
                                            model, context);
                                        await onDismissed();
                                      },
                                    ),
                                    CustomTextButton(
                                      shape: StadiumBorder(),
                                      color: Theme.of(context).accentColor,
                                      child: Text(
                                        S.of(context).no,
                                        style: TextStyle(
                                          fontFamily: 'Europa',
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(viewContext).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        photoUrl: model.photoUrl,
                        title: model.requestCreatorName,
                        subTitle: S.of(context).speaker_invite_notification +
                            model.title,
                      );
                      break;

                    case NotificationType.OneToManyCreatorRejectedCompletion:
                      Map oneToManyRequestModel = notification.data;
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return NotificationCardOneToManySpeakerRecalims(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressedAccept: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return OneToManySpeakerTimeEntryComplete(
                                  requestModel: model,
                                  onFinish: () async {
                                    await oneToManySpeakerReclaimRejection(
                                        oneToManyRequestModel);
                                    await onDismissed();
                                  },
                                  isFromtasks: false,
                                );
                              },
                            ),
                          );
                        },
                        photoUrl: oneToManyRequestModel['requestorphotourl'],
                        title: S
                            .of(context)
                            .speaker_completion_rejected_notification_1,
                        subTitle:
                            '${S.of(context).notifications_request_rejected_by} ${model.requestCreatorName}',
                      );
                      break;

                    case NotificationType.RequestApprove:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: null,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        // TO BE MADE
                        photoUrl: model.photoUrl,
                        title: model.title,
                        subTitle: model.requestType == RequestType.BORROW
                            ? 'Request has been approved'
                            : '${S.of(context).notifications_approved_by} ${model.fullName}',
                      );
                      break;

                    case NotificationType.TypeMemberAdded:
                      UserAddedModel userAddedModel =
                          UserAddedModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: userAddedModel.adminName,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl: userAddedModel.timebankImage,
                        title: S.of(context).notification_timebank_join,
                        subTitle:
                            '${userAddedModel.adminName.toLowerCase()} ${S.of(context).notifications_added_you} ${userAddedModel.timebankName} ${S.of(context).timebank} ',
                      );
                      break;
                    case NotificationType.MEMBER_ADDED_TO_MESSAGE_ROOM:
                      var data = notification.data;
                      Map<String, dynamic> map =
                          Map<String, dynamic>.from(data['creatorDetails']);
                      ParticipantInfo creatorDetails =
                          ParticipantInfo.fromMap(map);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: creatorDetails.name,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl:
                            creatorDetails.photoUrl ?? defaultUserImageURL,
                        title: S.of(context).message_room_join,
                        subTitle:
                            '${creatorDetails.name.toLowerCase()} ${S.of(context).notifications_added_you} ${data['messageRoomName']} ${S.of(context).messaging_room}.',
                      );
                      break;
                    case NotificationType.MEMBER_REMOVED_FROM_MESSAGE_ROOM:
                      var data = notification.data;
                      Map<String, dynamic> map =
                          Map<String, dynamic>.from(data['creatorDetails']);
                      ParticipantInfo creatorDetails =
                          ParticipantInfo.fromMap(map);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: creatorDetails.name,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl: creatorDetails.photoUrl,
                        title: S.of(context).message_room_remove,
                        subTitle:
                            '${creatorDetails.name.toLowerCase()} removed you from ${data['messageRoomName']}.',
                      );
                      break;
                    case NotificationType.MEMBER_DEMOTED_FROM_ADMIN:
                      bool isGroup = false;
                      String associatedName =
                          notification.data['associatedName'];

                      // bool
                      String timebankTitle = notification.data['timebankName'];
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        title: '${S.of(context).notifications_demoted_title}',
                        subTitle:
                            '$associatedName ${S.of(context).notifications_demoted_subtitle_phrase} ${isGroup ? S.of(context).group : S.of(context).timebank} ${timebankTitle} ',
                        entityName: S.of(context).demoted,
                        onDismissed: () {
                          // Dismiss notification
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                      );

                    case NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER:
                      bool isGroup = false;
                      String associatedName =
                          notification.data['associatedName'];

                      // bool
                      String timebankTitle = notification.data['timebankName'];
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        title:
                            '${S.of(context).notifications_demoted_title.replaceAll(S.of(context).admin, S.of(context).owner)}',
                        subTitle: S
                            .of(context)
                            .owner_demoted_to_admin
                            .replaceAll('associatedName', associatedName)
                            .replaceAll('groupName', timebankTitle)
                            .replaceAll(
                                S.of(context).organizer, S.of(context).owner),
                        entityName: S.of(context).demoted,
                        onDismissed: () {
                          // Dismiss notification
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                      );

                    case NotificationType.MEMBER_PROMOTED_AS_ADMIN:
                      String associatedName =
                          notification.data['associatedName'];
                      bool isGroup = notification.data['isGroup'];
                      String timebankTitle = notification.data['timebankName'];

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        title: '${S.of(context).notifications_promoted_title}',
                        subTitle:
                            '$associatedName ${S.of(context).notifications_promoted_subtitle_phrase} ${isGroup ? S.of(context).group : S.of(context).timebank} ${timebankTitle} ',
                        entityName: S.of(context).promoted,
                        onDismissed: () {
                          // Dismiss notification
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                      );
                    case NotificationType.ADMIN_PROMOTED_AS_ORGANIZER:
                      String associatedName =
                          notification.data['associatedName'];
                      bool isGroup = notification.data['isGroup'];
                      String timebankTitle = notification.data['timebankName'];

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        title:
                            '${S.of(context).notifications_promoted_title.replaceAll(S.of(context).admin, S.of(context).owner)}',
                        subTitle: S
                            .of(context)
                            .admin_promoted_to_owner
                            .replaceAll('creator_name', associatedName)
                            .replaceAll('community_name', timebankTitle),
                        entityName: S.of(context).promoted,
                        onDismissed: () {
                          // Dismiss notification
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                      );

                    case NotificationType.RequestReject:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: model.fullName,
                        title: model.title,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl: model.photoUrl,
                        subTitle:
                            '${S.of(context).notifications_request_rejected_by} ${model.fullName} ',
                      );
                      break;

                    case NotificationType.RequestCompletedRejected:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: model.fullName,
                        title: model.title,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl: model.photoUrl,
                        subTitle:
                            '${S.of(context).notifications_task_rejected_by} ${model.fullName} ',
                      );
                      break;

                    case NotificationType.OfferAccept:
                      return Container();

                    case NotificationType.OfferReject:
                      return Container(
                          width: 50, height: 50, color: Colors.red);
                      break;

                    case NotificationType.TYPE_CREDIT_FROM_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: '',
                        title: S.of(context).notifications_credited,
                        subTitle: UserNotificationMessage.CREDIT_FROM_OFFER
                                .replaceFirst(
                                  '*n',
                                  (data.classDetails.numberOfClassHours +
                                          data.classDetails
                                              .numberOfPreperationHours)
                                      .toString(),
                                )
                                .replaceFirst(
                                    '*class', data.classDetails.classTitle) +
                            " ",
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.TYPE_NEW_MEMBER_SIGNUP_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: data.participantDetails.photourl,
                        title: S.of(context).notifications_new_member_signup,
                        subTitle: UserNotificationMessage
                                .NEW_MEMBER_SIGNUP_OFFER
                                .replaceFirst(
                                  '*name',
                                  data.participantDetails.fullname,
                                )
                                .replaceFirst(
                                    '*class', data.classDetails.classTitle) +
                            " ",
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.TYPE_OFFER_FULFILMENT_ACHIEVED:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: '',
                        title:
                            "${S.of(context).notifications_credits_for} ${data.classDetails.classTitle}",
                        subTitle: UserNotificationMessage
                                .OFFER_FULFILMENT_ACHIEVED
                                .replaceFirst(
                                  '*n',
                                  (data.classDetails.numberOfClassHours +
                                          data.classDetails
                                              .numberOfPreperationHours)
                                      .toString(),
                                )
                                .replaceFirst(
                                    '*class', data.classDetails.classTitle) +
                            " ",
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_DEBIT_FROM_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: data.participantDetails.photourl,
                        title: S.of(context).notifications_debited,
                        subTitle: UserNotificationMessage.DEBIT_FROM_OFFER
                                .replaceFirst(
                                  '*n',
                                  data.classDetails.numberOfClassHours
                                      .toString(),
                                )
                                .replaceFirst(
                                    '*class', data.classDetails.classTitle) +
                            " ",
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_OFFER_SUBSCRIPTION_COMPLETED:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: data.participantDetails.photourl,
                        title: S.of(context).notifications_signed_for_class,
                        subTitle: UserNotificationMessage
                                .OFFER_SUBSCRIPTION_COMPLETED
                                .replaceFirst(
                                  '*class',
                                  data.classDetails.classTitle,
                                )
                                .replaceFirst(
                                    '*class', data.classDetails.classTitle) +
                            " ",
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_FEEDBACK_FROM_SIGNUP_MEMBER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        photoUrl: data.participantDetails.photourl,
                        title: S.of(context).notifications_feedback_request,
                        subTitle: UserNotificationMessage
                                .FEEDBACK_FROM_SIGNUP_MEMBER
                                .replaceFirst(
                              '*class',
                              data.classDetails.classTitle,
                            ) +
                            " ",
                        onPressed: () => _handleFeedBackNotificationAction(
                          context,
                          data,
                          notification.id,
                          user.email,
                        ),
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.ONETOMANY_REQUEST_ATTENDEES_FEEDBACK:
                      RequestModel requestModel =
                          RequestModel.fromMap(notification.data);

                      return NotificationCard(
                        isDissmissible: true,
                        timestamp: notification.timestamp,
                        entityName: 'Feed Back',
                        photoUrl: null,
                        title: S.of(context).notifications_feedback_request,
                        subTitle: UserNotificationMessage
                                .FEEDBACK_FROM_SIGNUP_MEMBER
                                .replaceFirst(
                              '*class',
                              requestModel.title,
                            ) +
                            " ",
                        onPressed: () =>
                            _handleFeedBackNotificationOneToManyAttendees(
                          context,
                          requestModel,
                          notification.id,
                          user.email,
                        ),
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST:
                      var body =
                          WithdrawnRequestBody.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: body.fullName,
                        photoUrl: null,
                        title:
                            "${S.of(context).notifications_approved_withdrawn_title}",
                        subTitle:
                            "${body.fullName} ${S.of(context).notifications_approved_withdrawn_subtitle} ${body.requestTite}.  ",
                        onDismissed: onDismissed,
                      );

                    case NotificationType.OFFER_CANCELLED_BY_CREATOR:
                      // var body = WithdrawnRequestBody.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: "",
                        photoUrl: null,
                        title: "${S.of(context).otm_offer_cancelled_title}",
                        subTitle:
                            "${S.of(context).otm_offer_cancelled_subtitle} ",
                        onDismissed: onDismissed,
                      );

                    case NotificationType.SEVA_COINS_CREDITED:
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: "CR",
                        photoUrl: null,
                        title: S.of(context).credits_credited,
                        subTitle: notification.data['credits'].toString() +
                            " " +
                            S
                                .of(context)
                                .credits_have_been_credited_to_your_account,
                        onDismissed: onDismissed,
                      );

//! NEW NOTIFICATION BELOW ---------------------------------------------------------->
//Feature name: Create Notification for member receiving donation //1.9 Release Feature
                    case NotificationType.MEMBER_RECEIVED_CREDITS_DONATION:
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: "CR",
                        photoUrl: notification.data['donorPhotoUrl'] ?? null,
                        title: S.of(context).credits_credited,
                        subTitle: L.of(context).you_have_recieved +
                            notification.data['credits'].toString() +
                            " " +
                            S.of(context).seva_credits +
                            " " +
                            (notification.data['donorName'] != null
                                ? (S.of(context).from +
                                    " " +
                                    notification.data[
                                        'communityName']) //or can use notification.data['donorName']
                                : ''),
                        onDismissed: onDismissed,
                      );
//! NEW NOTIFICATION ABOVE ---------------------------------------------------------->

                    case NotificationType.SEVA_COINS_DEBITED:
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: "CR",
                        photoUrl: null,
                        title: S.of(context).credits_debited,
                        subTitle: notification.data['credits'].toString() +
                            " " +
                            S
                                .of(context)
                                .credits_have_been_debited_from_your_account,
                        onDismissed: onDismissed,
                      );

                    case NotificationType.MANUAL_TIME_CLAIM_APPROVED:
                      var body = ManualTimeModel.fromMap(
                          Map<String, dynamic>.from(notification.data));

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: body.userDetails.name,
                        photoUrl: body.userDetails.photoUrl,
                        title: S.of(context).manual_notification_title,
                        subTitle: S
                            .of(context)
                            .manual_time_request_approved
                            .replaceAll('**number', '${body.claimedTime / 60}')
                            .replaceAll(
                                '**communityName', body.communityName ?? ' '),
                        isDissmissible: true,
                        onDismissed: onDismissed,
                      );

                    case NotificationType.MANUAL_TIME_CLAIM_REJECTED:
                      var body = ManualTimeModel.fromMap(
                          Map<String, dynamic>.from(notification.data));

                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: body.userDetails.name,
                        photoUrl: body.userDetails.photoUrl,
                        title: S.of(context).manual_notification_title,
                        subTitle: S
                            .of(context)
                            .manual_time_request_rejected
                            .replaceAll('**number', '${body.claimedTime / 60}')
                            .replaceAll(
                                '**communityName', body.communityName ?? ' '),
                        isDissmissible: true,
                        onDismissed: onDismissed,
                      );

                    case NotificationType
                        .NOTIFICATION_TO_LENDER_RECEIVED_BACK_CHECK:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: false,
                        //onDismissed: onDismissed,
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (_context) => AlertDialog(
                              title: Text(requestModelNew.roomOrTool ==
                                      LendingType.PLACE.readable
                                  ? S
                                      .of(context)
                                      .admin_borrow_request_received_back_check_place
                                  : S
                                      .of(context)
                                      .admin_borrow_request_received_back_check_item),
                              actions: [
                                CustomTextButton(
                                  shape: StadiumBorder(),
                                  color: Theme.of(context).accentColor,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                  onPressed: () {
                                    Navigator.of(_context).pop();
                                  },
                                  child: Text(S.of(context).not_yet,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: 'Europa',
                                          color: Colors.white)),
                                ),
                                CustomTextButton(
                                  shape: StadiumBorder(),
                                  color: Theme.of(context).primaryColor,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                  onPressed: () async {
                                    Navigator.of(_context).pop();

                                    log('timebank ID:  ' +
                                        requestModelNew.timebankId);

                                    //Update request model to complete it
                                    //requestModelNew.approvedUsers = [];
                                    requestModelNew.acceptors = [];
                                    requestModelNew.accepted =
                                        true; //so that we can know that this request has completed
                                    requestModelNew.isNotified =
                                        true; //resets to false otherwise

                                    if (requestModelNew.roomOrTool ==
                                        LendingType.ITEM.readable) {
                                      requestModelNew
                                          .borrowModel.itemsReturned = true;
                                    } else {
                                      requestModelNew.borrowModel.isCheckedOut =
                                          true;
                                    }

                                    await lenderReceivedBackCheck(
                                        notification: notification,
                                        requestModelUpdated: requestModelNew,
                                        context: context);
                                  },
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
                        photoUrl: model.photoUrl,
                        title: '${model.title}',
                        subTitle: S.of(context).request_ended,
                      );
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_LENDER_COMPLETION_RECEIPT:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: onDismissed,
                        onPressed: () =>
                            _handleFeedBackNotificationBorrowRequest(
                                context,
                                requestModelNew,
                                notification.id,
                                user.email,
                                FeedbackType.FOR_BORROW_REQUEST_LENDER),
                        photoUrl: model.photoUrl,
                        title: '${model.title}',
                        subTitle: S.of(context).request_ended_emailsent_msg,
                      );
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_BORROWER_COMPLETION_FEEDBACK:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: onDismissed,
                        onPressed: () =>
                            _handleFeedBackNotificationBorrowRequest(
                                context,
                                requestModelNew,
                                notification.id,
                                user.email,
                                FeedbackType.FOR_BORROW_REQUEST_BORROWER),
                        photoUrl: model.photoUrl,
                        title: '${model.title}',
                        subTitle: S
                            .of(context)
                            .lender_acknowledged_request_completion,
                      );
                      break;

                    case NotificationType.MEMBER_ACCEPT_LENDING_OFFER:
                      return PersonalNotificationsReducerForOffer
                          .getNotificationForLendingOfferAccept(
                        notification: notification,
                      );
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_BORROWER_REJECTED_LENDING_OFFER:
                      OfferModel model = OfferModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: model.fullName,
                        title: model.individualOfferDataModel.title,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: null,
                        photoUrl: model.photoUrlImage,
                        subTitle:
                            '${S.of(context).notifications_request_rejected_by} ${model.fullName} ',
                      );
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_BORROWER_APPROVED_LENDING_OFFER:
                      OfferModel model = OfferModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: model.fullName,
                        title: model.individualOfferDataModel.title,
                        isDissmissible: true,
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () async {
                          LendingOfferAcceptorModel lendingOfferAcceptorModel =
                              await LendingOffersRepo.getBorrowAcceptorModel(
                                  offerId: model.id, acceptorEmail: user.email);
                          await LendingOffersRepo.getDialogForBorrowerToUpdate(
                            offerModel: model,
                            context: context,
                            lendingOfferAcceptorModel:
                                lendingOfferAcceptorModel,
                          );
                        },
                        photoUrl: model.photoUrlImage,
                        subTitle:
                            '${S.of(context).notifications_approved_by} ${model.fullName}. ${S.of(context).tap_to_view_details}',
                      );
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_LENDER_PLACE_CHECKED_IN:
                      var model = OfferModel.fromMap(notification.data);
                      return FutureBuilder<UserModel>(
                          future: UserRepository.fetchUserById(
                              notification.senderUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return NotificationShimmer();
                            }
                            UserModel user = snapshot.data;
                            return user != null && user.fullname != null
                                ? NotificationCard(
                                    timestamp: notification.timestamp,
                                    entityName: 'NAME',
                                    isDissmissible: true,
                                    onPressed: null,
                                    photoUrl: notification.senderPhotoUrl ??
                                        defaultUserImageURL,
                                    title:
                                        '${model.individualOfferDataModel.title}',
                                    subTitle: "${user.fullname} " +
                                        S.of(context).checked_in_text,
                                    onDismissed: () {
                                      NotificationsRepository
                                          .readUserNotification(
                                              notification.id,
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .email);
                                    },
                                  )
                                : Container();
                          });
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_LENDER_PLACE_CHECKED_OUT:
                      var model = OfferModel.fromMap(notification.data);
                      return FutureBuilder<UserModel>(
                          future: UserRepository.fetchUserById(
                              notification.senderUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return NotificationShimmer();
                            }
                            UserModel user = snapshot.data;
                            return user != null && user.fullname != null
                                ? NotificationCard(
                                    timestamp: notification.timestamp,
                                    entityName: 'NAME',
                                    isDissmissible: true,
                                    onPressed: () async {
                                      LendingOfferAcceptorModel
                                          lendingOfferAcceptorModel =
                                          await LendingOffersRepo
                                              .getBorrowAcceptorModel(
                                                  offerId: model.id,
                                                  acceptorEmail: user.email);
                                      handleFeedBackNotificationLendingOffer(
                                          offerModel: model,
                                          notificationId: notification.id,
                                          context: context,
                                          email: SevaCore.of(context)
                                              .loggedInUser
                                              .email,
                                          feedbackType: FeedbackType
                                              .FEEDBACK_FOR_BORROWER_FROM_LENDER,
                                          lendingOfferAcceptorModel:
                                              lendingOfferAcceptorModel);
                                    },
                                    photoUrl: notification.senderPhotoUrl ??
                                        defaultUserImageURL,
                                    title:
                                        '${model.individualOfferDataModel.title}',
                                    subTitle: "${user.fullname} " +
                                        S.of(context).checked_out_text +
                                        '. ' +
                                        S.of(context).tab_to_leave_feedback,
                                    onDismissed: () {
                                      NotificationsRepository
                                          .readUserNotification(
                                              notification.id,
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .email);
                                    },
                                  )
                                : Container();
                          });
                      break;

                    case NotificationType
                        .NOTIFICATION_TO_LENDER_ITEMS_COLLECTED:
                      var model = OfferModel.fromMap(notification.data);
                      return FutureBuilder<UserModel>(
                          future: UserRepository.fetchUserById(
                              notification.senderUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return NotificationShimmer();
                            }
                            UserModel user = snapshot.data;
                            return user != null && user.fullname != null
                                ? NotificationCard(
                                    timestamp: notification.timestamp,
                                    entityName: 'NAME',
                                    isDissmissible: true,
                                    onPressed: null,
                                    photoUrl: notification.senderPhotoUrl ??
                                        defaultUserImageURL,
                                    title:
                                        '${model.individualOfferDataModel.title}',
                                    subTitle: "${user.fullname} " +
                                        S.of(context).collected_items,
                                    onDismissed: () {
                                      NotificationsRepository
                                          .readUserNotification(
                                              notification.id,
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .email);
                                    },
                                  )
                                : Container();
                          });
                      break;

                    case NotificationType.NOTIFICATION_TO_LENDER_ITEMS_RETURNED:
                      var model = OfferModel.fromMap(notification.data);
                      return FutureBuilder<UserModel>(
                          future: UserRepository.fetchUserById(
                              notification.senderUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return NotificationShimmer();
                            }
                            UserModel user = snapshot.data;
                            return user != null && user.fullname != null
                                ? NotificationCard(
                                    timestamp: notification.timestamp,
                                    entityName: 'NAME',
                                    isDissmissible: true,
                                    onPressed: () async {
                                      LendingOfferAcceptorModel
                                          lendingOfferAcceptorModel =
                                          await LendingOffersRepo
                                              .getBorrowAcceptorModel(
                                                  offerId: model.id,
                                                  acceptorEmail: user.email);
                                      handleFeedBackNotificationLendingOffer(
                                          offerModel: model,
                                          notificationId: notification.id,
                                          context: context,
                                          email: SevaCore.of(context)
                                              .loggedInUser
                                              .email,
                                          feedbackType: FeedbackType
                                              .FEEDBACK_FOR_BORROWER_FROM_LENDER,
                                          lendingOfferAcceptorModel:
                                              lendingOfferAcceptorModel);
                                    },
                                    photoUrl: notification.senderPhotoUrl ??
                                        defaultUserImageURL,
                                    title:
                                        '${model.individualOfferDataModel.title}',
                                    subTitle: "${user.fullname} " +
                                        S.of(context).returned_items +
                                        ' ' +
                                        S.of(context).tab_to_leave_feedback,
                                    onDismissed: () {
                                      NotificationsRepository
                                          .readUserNotification(
                                              notification.id,
                                              SevaCore.of(context)
                                                  .loggedInUser
                                                  .email);
                                    },
                                  )
                                : Container();
                          });
                      break;
                    case NotificationType
                        .NOTIFICATION_TO_BORROWER_FOR_LENDING_FEEDBACK:
                      var model = OfferModel.fromMap(notification.data);
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onPressed: () async {
                          LendingOfferAcceptorModel lendingOfferAcceptorModel =
                              await LendingOffersRepo.getBorrowAcceptorModel(
                                  offerId: model.id, acceptorEmail: user.email);
                          handleFeedBackNotificationLendingOffer(
                              offerModel: model,
                              notificationId: notification.id,
                              context: context,
                              email: SevaCore.of(context).loggedInUser.email,
                              feedbackType: FeedbackType
                                  .FEEDBACK_FOR_LENDER_FROM_BORROWER,
                              lendingOfferAcceptorModel:
                                  lendingOfferAcceptorModel);
                        },
                        photoUrl:
                            notification.senderPhotoUrl ?? defaultUserImageURL,
                        title: '${model.individualOfferDataModel.title}',
                        subTitle:
                            "${model.lendingOfferDetailsModel.lendingModel.lendingType == LendingType.PLACE ? S.of(context).borrower_departed_provide_feedback : S.of(context).borrower_returned_items_feedback}",
                        onDismissed: () {
                          NotificationsRepository.readUserNotification(
                              notification.id, user.email);
                        },
                      );

                      break;
                    case NotificationType.LendingOfferIdleFirstWarning:
                      OfferModel model = OfferModel.fromMap(notification.data);
                      offerModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrlImage,
                        title: model.individualOfferDataModel.title +
                            S.of(context).idle_for_2_weeks,
                        subTitle: S
                            .of(context)
                            .idle_lending_offer_first_warning
                            .replaceAll('***', '2'),
                      );
                      break;

                    case NotificationType.LendingOfferIdleSecondWarning:
                      OfferModel model = OfferModel.fromMap(notification.data);
                      offerModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrlImage,
                        title: model.individualOfferDataModel.title +
                            S.of(context).idle_for_4_weeks,
                        subTitle: S
                            .of(context)
                            .idle_lending_offer_second_warning
                            .replaceAll('***', '4'),
                      );
                      break;

                    case NotificationType.LendingOfferIdleSoftDeleted:
                      OfferModel model = OfferModel.fromMap(notification.data);
                      offerModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrlImage,
                        title: model.individualOfferDataModel.title +
                            ' ' +
                            S
                                .of(context)
                                .notifications_was_deleted
                                .replaceAll('!', ''),
                        subTitle: S
                            .of(context)
                            .idle_lending_offer_third_warning_deleted,
                      );
                      break;

                    case NotificationType.BorrowRequestIdleFirstWarning:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrl,
                        title: model.title + S.of(context).idle_for_2_weeks,
                        subTitle: S
                            .of(context)
                            .idle_borrow_request_first_warning
                            .replaceAll('***', '2'),
                      );
                      break;

                    case NotificationType.BorrowRequestIdleSecondWarning:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrl,
                        title: model.title + S.of(context).idle_for_4_weeks,
                        subTitle: S
                            .of(context)
                            .idle_borrow_request_second_warning
                            .replaceAll('***', '4'),
                      );
                      break;

                    case NotificationType.BorrowRequestIdleSoftDeleted:
                      var model = RequestModel.fromMap(notification.data);
                      requestModelNew = model;
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: 'NAME',
                        isDissmissible: true,
                        onDismissed: () async {
                          NotificationsRepository.readUserNotification(
                            notification.id,
                            user.email,
                          );
                        },
                        onPressed: () {},
                        photoUrl: model.photoUrl,
                        title: model.title +
                            ' ' +
                            S
                                .of(context)
                                .notifications_was_deleted
                                .replaceAll('!', ''),
                        subTitle: S
                            .of(context)
                            .idle_borrow_request_third_warning_deleted,
                      );
                      break;

                    default:
                      log("Unhandled user notification type ${notification.type} ${notification.id}");
                      // FirebaseCrashlytics.instance.log(
                      //     "Unhandled notification type ${notification.type} ${notification.id}");
                      return Container();
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future oneToManySpeakerReclaimRejection(requestModel) async {
    NotificationsModel notificationModel = NotificationsModel(
        timebankId: requestModel['timebankId'],
        targetUserId: requestModel['sevaUserId'],
        data: requestModel,
        type: NotificationType.OneToManyRequestCompleted,
        id: utils.Utils.getUuid(),
        isRead: false,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        communityId: requestModel['communityId'],
        isTimebankNotification: true);

    await CollectionRef.timebank
        .doc(notificationModel.timebankId)
        .collection('notifications')
        .doc(notificationModel.id)
        .set(notificationModel.toMap());

    await CollectionRef.requests.doc(requestModel['id']).update({
      'isSpeakerCompleted': true,
    });
  }

  void _handleFeedBackNotificationAction(
    BuildContext context,
    OneToManyNotificationDataModel data,
    String notificationId,
    String email,
  ) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewFeedback(
          feedbackType: FeedbackType.FOR_ONE_TO_MANY_OFFER,
        ),
      ),
    );

    if (results != null && results.containsKey('selection')) {
      CollectionRef.reviews.add(
        {
          "reviewer": SevaCore.of(context).loggedInUser.email,
          "reviewed": data.classDetails.classTitle,
          "ratings": results['selection'],
          "requestId": "testId",
          "comments":
              results['didComment'] ? results['comment'] : "No comments",
          'liveMode': !AppConfig.isTestCommunity,
        },
      );
      await sendMessageOfferCreator(
          loggedInUser: SevaCore.of(context).loggedInUser,
          message: results['didComment'] ? results['comment'] : "No comments",
          creatorId: data.classDetails.sevauserid,
          isFromOfferRequest: true);
      NotificationsRepository.readUserNotification(notificationId, email);
    }
  }

  void _handleFeedBackNotificationOneToManyAttendees(
    BuildContext context,
    RequestModel requestModel,
    String notificationId,
    String email,
  ) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewFeedback(
          feedbackType: FeedbackType
              .FOR_ONE_TO_MANY_REQUEST_ATTENDEE, //if new questions then have to change this and update
        ),
      ),
    );

    if (results != null && results.containsKey('selection')) {
      CollectionRef.reviews.add(
        {
          "reviewer": SevaCore.of(context).loggedInUser.email,
          "reviewed": requestModel.title,
          "ratings": results['selection'],
          "requestId": "testId",
          "comments":
              results['didComment'] ? results['comment'] : "No comments",
          'liveMode': !AppConfig.isTestCommunity,
        },
      );

      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          FeedbackType.FOR_ONE_TO_MANY_REQUEST_ATTENDEE,
          results,
          requestModel,
          SevaCore.of(context).loggedInUser);

      await sendMessageOfferCreator(
          loggedInUser: SevaCore.of(context).loggedInUser,
          message: results['didComment'] ? results['comment'] : "No comments",
          creatorId: requestModel.sevaUserId,
          offerTitle: requestModel.title,
          isFromOfferRequest: requestModel.isFromOfferRequest);
      NotificationsRepository.readUserNotification(notificationId, email);
    }
  }

  void _handleFeedBackNotificationBorrowRequest(
      BuildContext context,
      RequestModel requestModel,
      String notificationId,
      String email,
      FeedbackType feedbackType) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewFeedback(
          feedbackType:
              feedbackType, //if new questions then have to change this and update
        ),
      ),
    );

    if (results != null && results.containsKey('selection')) {
      CollectionRef.reviews.add(
        {
          "reviewer": SevaCore.of(context).loggedInUser.email,
          "reviewed": feedbackType == FeedbackType.FOR_BORROW_REQUEST_LENDER
              ? requestModel.email
              : requestModel.approvedUsers.first,
          "ratings": results['selection'],
          "requestId": "testId",
          "comments":
              results['didComment'] ? results['comment'] : "No comments",
          'liveMode': !AppConfig.isTestCommunity,
        },
      );

      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          feedbackType,
          results,
          requestModel,
          SevaCore.of(context).loggedInUser);
/*
      await sendMessageOfferCreator(
          loggedInUser: SevaCore.of(context).loggedInUser,
          message: results['didComment'] ? results['comment'] : "No comments",
          creatorId: requestModel.sevaUserId,
          offerTitle: requestModel.title,
          isFromOfferRequest: requestModel.isFromOfferRequest);*/
      NotificationsRepository.readUserNotification(notificationId, email);
    }
  }

  Future<void> sendMessageOfferCreator({
    UserModel loggedInUser,
    String offerTitle,
    String creatorId,
    String message,
    bool isFromOfferRequest,
  }) async {
    UserModel userModel =
        await FirestoreManager.getUserForId(sevaUserId: creatorId);
    if (userModel != null) {
      ParticipantInfo receiver = ParticipantInfo(
        id: userModel.sevaUserID,
        photoUrl: userModel.photoURL,
        name: userModel.fullname,
        type: ChatType.TYPE_PERSONAL,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: ChatType.TYPE_PERSONAL,
      );
      await sendBackgroundMessage(
          messageContent: getReviewMessage(
            reviewMessage: message,
            userName: loggedInUser.fullname,
            context: context,
            requestTitle: offerTitle,
            isForCreator: true,
            isOfferReview: isFromOfferRequest,
          ),
          reciever: receiver,
          isTimebankMessage: false,
          timebankId: '',
          communityId: loggedInUser.currentCommunity,
          sender: sender);
    }
  }

  void checkForReviewBorrowRequests() async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return BorrowRequestFeedBackView(requestModel: requestModelNew);
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      log('after feedback here 2');
      showProgressForCreditRetrieval();
      onActivityResult(results, SevaCore.of(context).loggedInUser);
    } else {}
  }

  Future<void> onActivityResult(Map results, UserModel loggedInUser) async {
    // adds review to firestore
    try {
      logger.i('here 1');
      await CollectionRef.reviews.add({
        "reviewer": SevaCore.of(context).loggedInUser.email,
        "reviewed": requestModelNew.email,
        "ratings": results['selection'],
        "device_info": results['device_info'],
        "requestId": requestModelNew.id,
        "comments": (results['didComment'] ? results['comment'] : "No comments")
      });
      logger.i('here 2');
      await sendMessageToMember(
          message: results['didComment'] ? results['comment'] : "No comments",
          loggedInUser: loggedInUser);
      logger.i('here 3');
      startTransaction();
    } on Exception catch (e) {
      // TODO
    }
  }

  Future<void> sendMessageToMember({
    UserModel loggedInUser,
    String message,
  }) async {
    TimebankModel timebankModel =
        await getTimeBankForId(timebankId: requestModelNew.timebankId);
    UserModel userModel = await FirestoreManager.getUserForId(
        sevaUserId: requestModelNew.sevaUserId);
    if (userModel != null && timebankModel != null) {
      ParticipantInfo receiver = ParticipantInfo(
        id: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.sevaUserID
            : requestModelNew.timebankId,
        photoUrl: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.photoURL
            : timebankModel.photoUrl,
        name: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? userModel.fullname
            : timebankModel.name,
        type: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );
      await sendBackgroundMessage(
          messageContent: utils.getReviewMessage(
            requestTitle: requestModelNew.title,
            context: context,
            userName: loggedInUser.fullname,
            isForCreator: true,
            reviewMessage: message,
          ),
          reciever: receiver,
          isTimebankMessage:
              requestModelNew.requestMode == RequestMode.PERSONAL_REQUEST
                  ? false
                  : true,
          timebankId: requestModelNew.timebankId,
          communityId: loggedInUser.currentCommunity,
          sender: sender);
    }
  }

  void startTransaction() async {
    // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)

    //doing below since in RequestModel if != null nothing happens
    //so manually removing user from task
    // requestModelNew.approvedUsers = [];
    // requestModelNew.acceptors = [];
    // requestModelNew.accepted =
    //     true; //so that we can know that this request has completed

    if (requestModelNew.requestType == RequestType.BORROW) {
      if (SevaCore.of(context).loggedInUser.sevaUserID ==
          requestModelNew.sevaUserId) {
        FirestoreManager.borrowRequestFeedbackBorrowerUpdate(
            model: requestModelNew);
      } else {
        FirestoreManager.borrowRequestFeedbackLenderUpdate(
            model: requestModelNew);
      }
    }

    //requestModelNew.accepted = false;

    //FirestoreManager.borrowRequestComplete(model: requestModelNew);

    // FirestoreManager.createTaskCompletedNotification(
    //   model: NotificationsModel(
    //     isTimebankNotification: requestModelNew.requestMode == RequestMode.TIMEBANK_REQUEST,
    //     id: utils.Utils.getUuid(),
    //     data: requestModelNew.toMap(),
    //     type: NotificationType.RequestCompleted,
    //     senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
    //     targetUserId: requestModelNew.sevaUserId,
    //     communityId: requestModelNew.communityId,
    //     timebankId: requestModelNew.timebankId,
    //     isRead: false,
    //   ),
    // );

    Navigator.of(creditRequestDialogContext).pop();
    //Navigator.of(context).pop();
  }

  BuildContext creditRequestDialogContext;

  void showProgressForCreditRetrieval() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(),
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

  // //Send receipt mail to LENDER for end of Borrow Request
  // Future<bool> sendReceiptMailToLender({
  //   String senderEmail,
  //   String receiverEmail,
  //   String communityName,
  //   String requestName,
  //   String requestCreatorName,
  //   String receiverName,
  //   int startDate,
  //   int endDate,
  // }) async {
  //   return await SevaMailer.createAndSendEmail(
  //       mailContent: MailContent.createMail(
  //     mailSender: senderEmail,
  //     mailReciever: receiverEmail,
  //     mailSubject: 'Receipt' + ' for ' + requestName + ' from' + communityName,
  //     mailContent: requestName +
  //         " has completed." +
  //         "\n" +
  //         "here is the receipt"
  //             "\n\n" +
  //         "Thanks," +
  //         "\n" +
  //         "SevaX Team.",
  //   ));
  // } //to be given by client for email content

  @override
  bool get wantKeepAlive => true;
}

class WithdrawnRequestBody {
  String fullName;
  String requestId;
  String requestTite;

  WithdrawnRequestBody.fromMap(Map<dynamic, dynamic> body) {
    if (body.containsKey('fullName')) {
      this.fullName = body['fullName'];
    }
    if (body.containsKey('requestId')) {
      this.requestId = body['requestId'];
    }
    if (body.containsKey('requestTite')) {
      this.requestTite = body['requestTite'];
    }
  }
}

Future oneToManySpeakerInviteAcceptedPersonalNotifications(
    RequestModel oneToManyRequestModel, BuildContext context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        dialogContext = createDialogContext;
        return AlertDialog(
          title: Text(S.of(context).loading),
          content: LinearProgressIndicator(),
        );
      });

  Set<String> approvedUsersList = Set.from(oneToManyRequestModel.approvedUsers);
  approvedUsersList.add(SevaCore.of(context).loggedInUser.email);
  // oneToManyRequestModel.approvedUsers = approvedUsersList.toList();

  await CollectionRef.requests.doc(oneToManyRequestModel.id).update({
    'approvedUsers': approvedUsersList.toList(),
  });

  NotificationsModel notificationModel = NotificationsModel(
      timebankId: oneToManyRequestModel.timebankId,
      targetUserId: oneToManyRequestModel.sevaUserId,
      data: oneToManyRequestModel.toMap(),
      type: NotificationType.OneToManyRequestInviteAccepted,
      id: utils.Utils.getUuid(),
      isRead: false,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: oneToManyRequestModel.communityId,
      isTimebankNotification: true);

  await CollectionRef.timebank
      .doc(notificationModel.timebankId)
      .collection('notifications')
      .doc(notificationModel.id)
      .set(notificationModel.toMap());

  await FirestoreManager.readUserNotificationOneToManyWhenSpeakerIsInvited(
    requestModel: oneToManyRequestModel,
    userEmail: SevaCore.of(context).loggedInUser.email,
    fromNotification: false,
  );

  if (dialogContext != null) {
    Navigator.of(dialogContext).pop();
  }
}

Future oneToManySpeakerInviteRejectedPersonalNotifications(
    RequestModel oneToManyRequestModel, BuildContext context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        dialogContext = createDialogContext;
        return AlertDialog(
          title: Text(S.of(context).loading),
          content: LinearProgressIndicator(),
        );
      });

  NotificationsModel notificationModel = NotificationsModel(
      timebankId: oneToManyRequestModel.timebankId,
      targetUserId: oneToManyRequestModel.sevaUserId,
      data: oneToManyRequestModel.toMap(),
      type: NotificationType.OneToManyRequestInviteRejected,
      id: utils.Utils.getUuid(),
      isRead: false,
      senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      communityId: oneToManyRequestModel.communityId,
      isTimebankNotification: true);

  await CollectionRef.timebank
      .doc(notificationModel.timebankId)
      .collection('notifications')
      .doc(notificationModel.id)
      .set(notificationModel.toMap())
      .then((e) async {
    Set<String> acceptorsList = Set.from(oneToManyRequestModel.acceptors);
    acceptorsList.remove(SevaCore.of(context).loggedInUser.email);
    acceptorsList.add(oneToManyRequestModel.email);
    oneToManyRequestModel.acceptors = acceptorsList.toList();
    oneToManyRequestModel.selectedInstructor = BasicUserDetails(
      fullname: oneToManyRequestModel.requestCreatorName,
      email: oneToManyRequestModel.email,
      photoURL: oneToManyRequestModel.photoUrl,
      sevaUserID: oneToManyRequestModel.sevaUserId,
    );

    await CollectionRef.requests
        .doc(oneToManyRequestModel.id)
        .update(oneToManyRequestModel.toMap());
  });

  if (dialogContext != null) {
    Navigator.of(dialogContext).pop();
  }

  log('sent timebank notif to 1 to many creator abt rejection!');
}

Future oneToManySpeakerInviteAccepted(
    RequestModel requestModel, BuildContext context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        dialogContext = createDialogContext;
        return AlertDialog(
          title: Text(S.of(context).loading),
          content: LinearProgressIndicator(),
        );
      });

  //make the relevant notification is read true
  await FirestoreManager.readUserNotificationOneToManyWhenSpeakerIsInvited(
    requestModel: requestModel,
    userEmail: SevaCore.of(context).loggedInUser.email,
    fromNotification: false,
  );

  Set<String> approvedUsersList = Set.from(requestModel.approvedUsers);
  approvedUsersList.add(SevaCore.of(context).loggedInUser.email);
  // requestModel.approvedUsers = approvedUsersList.toList();

  await CollectionRef.requests.doc(requestModel.id).update({
    'approvedUsers': approvedUsersList.toList(),
  });

  NotificationsModel notificationModel = NotificationsModel(
      timebankId: requestModel.timebankId,
      targetUserId: requestModel.sevaUserId,
      data: requestModel.toMap(),
      type: NotificationType.OneToManyRequestInviteAccepted,
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

  logger.e(
      '-------------COMES HERE TO CLEAR NOTIFICATION Accepted Scenario--------------');
  //make the relevant notification is read true
  await FirestoreManager.readUserNotificationOneToManyWhenSpeakerIsInvited(
    requestModel: requestModel,
    userEmail: SevaCore.of(context).loggedInUser.email,
    fromNotification: false,
  );

  if (dialogContext != null) {
    Navigator.of(dialogContext).pop();
  }
}

Future oneToManySpeakerInviteRejected(
    RequestModel requestModel, BuildContext context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        dialogContext = createDialogContext;
        return AlertDialog(
          title: Text(S.of(context).loading),
          content: LinearProgressIndicator(),
        );
      });

  NotificationsModel notificationModel = NotificationsModel(
      timebankId: requestModel.timebankId,
      targetUserId: requestModel.sevaUserId,
      data: requestModel.toMap(),
      type: NotificationType.OneToManyRequestInviteRejected,
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

  Set<String> acceptorsList = Set.from(requestModel.acceptors);
  acceptorsList.remove(SevaCore.of(context).loggedInUser.email);
  acceptorsList.add(requestModel.email);
  requestModel.acceptors = acceptorsList.toList();

  //if already approved
  Set<String> approvedUsersList = Set.from(requestModel.approvedUsers);
  approvedUsersList.remove(SevaCore.of(context).loggedInUser.email);
  requestModel.approvedUsers = approvedUsersList.toList();

  //So that if a speaker withdraws and a new speaker is invited, before they accept,
  //it will show previously invited speakers time details
  requestModel.selectedSpeakerTimeDetails.prepTime = null;
  // requestModel.selectedSpeakerTimeDetails.speakingTime = null;

  //below is to fetch creator of request details and set as speaker by default
  var creatorUserModel =
      await FirestoreManager.getUserForEmail(emailAddress: requestModel.email);

  requestModel.selectedInstructor = BasicUserDetails(
    fullname: creatorUserModel.fullname,
    email: creatorUserModel.email,
    photoURL: creatorUserModel.photoURL,
    sevaUserID: creatorUserModel.sevaUserID,
  );

  await CollectionRef.requests
      .doc(requestModel.id)
      .update(requestModel.toMap());

  logger.e(
      '-------------COMES HERE TO CLEAR NOTIFICATION Rejected Scenario--------------');
  //make the relevant notification is read true
  await FirestoreManager.readUserNotificationOneToManyWhenSpeakerIsInvited(
    requestModel: requestModel,
    userEmail: SevaCore.of(context).loggedInUser.email,
    fromNotification: false,
  );

  if (dialogContext != null) {
    Navigator.of(dialogContext).pop();
  }

  log('sends timebank notif to 1 to many creator abt rejection!');
}

Future oneToManySpeakerRequestCompleted(
    RequestModel requestModel, BuildContext context) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        dialogContext = createDialogContext;
        return AlertDialog(
          title: Text(S.of(context).loading),
          content: LinearProgressIndicator(),
        );
      });

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

  if (dialogContext != null) {
    Navigator.of(dialogContext).pop();
  }

  await FirestoreManager
      .readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion(
    requestModel: requestModel,
    userEmail: SevaCore.of(context).loggedInUser.email,
    fromNotification: false,
  );
}
