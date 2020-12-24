import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/reducer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';

class PersonalNotifications extends StatefulWidget {
  @override
  _PersonalNotificationsState createState() => _PersonalNotificationsState();
}

class _PersonalNotificationsState extends State<PersonalNotifications>
    with AutomaticKeepAliveClientMixin {
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
              child: FlatButton(
                padding: EdgeInsets.zero,
                child: Text('Clear All'),
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

                    case NotificationType.RequestCompletedApproved:
                      return PersonalNotificationReducerForRequests
                          .getWidgetForRequestCompletedApproved(
                        notification: notification,
                        context: context,
                        user: user,
                      );
                    case NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY:
                    case NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY:
                      return PersonalNotificationsRedcerForDonations
                          .getWidgetForSuccessfullDonation(
                        onDismissed: onDismissed,
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
                      return PersonalNotificationReducerForRequests
                          .getInvitationForRequest(
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
                        photoUrl: model.photoUrl,
                        title: model.title,
                        subTitle:
                            '${S.of(context).notifications_approved_by} ${model.fullName}',
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
                        title: "${S.of(context).notifications_credited_msg}",
                        subTitle:
                            "${S.of(context).notifications_credited_msg} ",
                        onDismissed: onDismissed,
                      );

                    case NotificationType.SEVA_COINS_DEBITED:
                      return NotificationCard(
                        timestamp: notification.timestamp,
                        entityName: "CR",
                        photoUrl: null,
                        title: "${S.of(context).notifications_debited_msg}",
                        subTitle: "${S.of(context).notifications_debited_msg} ",
                        onDismissed: onDismissed,
                      );

                    default:
                      log("Unhandled user notification type ${notification.type} ${notification.id}");
                      Crashlytics().log(
                          "Unhandled notification type ${notification.type} ${notification.id}");
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
      Firestore.instance.collection("reviews").add(
        {
          "reviewer": SevaCore.of(context).loggedInUser.email,
          "reviewed": data.classDetails.classTitle,
          "ratings": results['selection'],
          "requestId": "testId",
          "comments":
              results['didComment'] ? results['comment'] : "No comments",
        },
      );
      await sendMessageOfferCreator(
          loggedInUser: SevaCore.of(context).loggedInUser,
          message: results['didComment'] ? results['comment'] : "No comments",
          creatorId: data.classDetails.sevauserid);
      NotificationsRepository.readUserNotification(notificationId, email);
    }
  }

  Future<void> sendMessageOfferCreator({
    UserModel loggedInUser,
    String offerTitle,
    String creatorId,
    String message,
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
            isOfferReview: true,
          ),
          reciever: receiver,
          isTimebankMessage: false,
          timebankId: '',
          communityId: loggedInUser.currentCommunity,
          sender: sender);
    }
  }

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
