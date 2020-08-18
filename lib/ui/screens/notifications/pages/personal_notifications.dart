import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/change_ownership_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_approve_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_complete_widget.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:sevaexchange/views/timebanks/join_request_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/group_join_reject_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/APi/notifications_api.dart';
import 'package:sevaexchange/widgets/APi/request_api.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

class PersonalNotifications extends StatefulWidget {
  @override
  _PersonalNotificationsState createState() => _PersonalNotificationsState();
}

class _PersonalNotificationsState extends State<PersonalNotifications>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    final UserModel user = SevaCore.of(context).loggedInUser;
    return StreamBuilder<List<NotificationsModel>>(
      stream: _bloc.personalNotifications,
      builder: (_, snapshot) {
        print(snapshot.error);
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }
        if (snapshot.data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                AppLocalizations.of(context)
                    .translate('notifications', 'no_notifications'),
              ),
            ),
          );
        }
        return ListView.builder(
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

            print("========== ======" + notification.type.toString());
            switch (notification.type) {
              case NotificationType.RecurringRequestUpdated:
                ReccuringRequestUpdated eventData =
                    ReccuringRequestUpdated.fromMap(notification.data);
                return NotificationCard(
                  title: "Request Updated",
                  subTitle:
                      "${AppLocalizations.of(context).translate('notifications', 'you_signed_up_for')} ***eventName ${AppLocalizations.of(context).translate('notifications', 'on')} ***eventDate. ${AppLocalizations.of(context).translate('notifications', 'owner_changes')}"
                          .replaceFirst('***eventName', eventData.eventName)
                          .replaceFirst(
                              '***eventDate',
                              DateTime.fromMillisecondsSinceEpoch(
                                eventData.eventDate,
                              ).toString()),
                  entityName: "Request Updated",
                  photoUrl: eventData.photoUrl,
                  onDismissed: onDismissed,
                );
                break;
              case NotificationType.RequestAccept:
                RequestModel model = RequestModel.fromMap(notification.data);

                return FutureBuilder<RequestModel>(
                  future: RequestApi.getRequestFutureById(model.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    RequestModel model = snapshot.data;
                    return RequestAcceptedWidget(
                      model: model,
                      userId: notification.senderUserId,
                      notificationId: notification.id,
                    );
                  },
                );
                break;

              case NotificationType.TypeChangeOwnership:
                ChangeOwnershipModel ownershipModel =
                    ChangeOwnershipModel.fromMap(notification.data);

                return ChangeOwnershipWidget(
                  notificationId: notification.id,
                  communityId: notification.communityId,
                  changeOwnershipModel: ownershipModel,
                  timebankId: notification.timebankId,
                  notificationsModel: notification,
                );
                break;
              case NotificationType.RequestApprove:
                RequestModel model = RequestModel.fromMap(notification.data);

                return RequestApproveWidget(
                  model: model,
                  userId: notification.senderUserId,
                  notificationId: notification.id,
                );
                break;

              case NotificationType.TypeMemberAdded:
                UserAddedModel userAddedModel =
                    UserAddedModel.fromMap(notification.data);
                return NotificationCard(
                  entityName: userAddedModel.adminName,
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                  onPressed: null,
                  photoUrl: userAddedModel.timebankImage,
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'timebank_join'),
                  subTitle:
                      '${userAddedModel.adminName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'added_you')} ${userAddedModel.timebankName} ${AppLocalizations.of(context).translate('members', 'timebank')}',
                );
                break;

              case NotificationType.MEMBER_DEMOTED_FROM_ADMIN:
                bool isGroup = false;
                String associatedName = notification.data['associatedName'];

                // bool
                String timebankTitle = notification.data['timebankName'];
                return NotificationCard(
                  title: 'You have been demoted from Admin',
                  subTitle:
                      '$associatedName has demoted you from being an Admin for the ${isGroup ? 'Group' : 'Timebank'} ${timebankTitle}',
                  entityName: 'DEMOTED',
                  onDismissed: () {
                    // Dismiss notification
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                );

              case NotificationType.MEMBER_PROMOTED_AS_ADMIN:
                String associatedName = notification.data['associatedName'];
                bool isGroup = notification.data['isGroup'];
                String timebankTitle = notification.data['timebankName'];

                return NotificationCard(
                  title: 'You have been promoted to Admin',
                  subTitle:
                      '$associatedName has promoted you to be the Admin for the ${isGroup ? 'Group' : 'Timebank'} ${timebankTitle}',
                  entityName: 'PROMOTED',
                  onDismissed: () {
                    // Dismiss notification
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                );

              case NotificationType.RequestReject:
                RequestModel model = RequestModel.fromMap(notification.data);
                return NotificationCard(
                  entityName: model.fullName,
                  title: model.title,
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                  onPressed: null,
                  photoUrl: model.photoUrl,
                  subTitle:
                      '${AppLocalizations.of(context).translate('notifications', 'rejected_by')} ${model.fullName}',
                );

                break;

              case NotificationType.JoinRequest:
                JoinRequestNotificationModel model =
                    JoinRequestNotificationModel.fromMap(notification.data);
                return FutureBuilder<UserModel>(
                  future: UserApi.fetchUserById(notification.senderUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return NotificationShimmer();
                    }
                    UserModel user = snapshot.data;
                    return user != null && user.fullname != null
                        ? NotificationCard(
                            entityName: user.fullname,
                            title: AppLocalizations.of(context)
                                .translate('notifications', 'join_request'),
                            isDissmissible: true,
                            onDismissed: () {
                              NotificationsApi.readUserNotification(
                                notification.id,
                                user.email,
                              );
                            },
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JoinRequestView(
                                    timebankId: model.timebankId,
                                  ),
                                ),
                              );
                            },
                            photoUrl: user.photoURL,
                            subTitle:
                                '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${model.timebankTitle}, ${AppLocalizations.of(context).translate('notifications', 'tap_toview')}',
                          )
                        : Container();
                  },
                );
                break;

              case NotificationType.RequestCompleted:
                RequestModel model = RequestModel.fromMap(notification.data);
                return FutureBuilder<RequestModel>(
                  future: RequestApi.getRequestFutureById(model.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    RequestModel model = snapshot.data;
                    return RequestCompleteWidget(
                      model: model,
                      userId: notification.senderUserId,
                      notificationId: notification.id,
                    );
                  },
                );
                break;
              case NotificationType.RequestCompletedApproved:
                RequestModel model = RequestModel.fromMap(notification.data);
                TransactionModel transactionModel =
                    model.transactions.firstWhere(
                  (transaction) => transaction.to == user.sevaUserID,
                );
                return NotificationCard(
                  entityName: model.fullName,
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                  onPressed: null,
                  photoUrl: model.photoUrl,
                  subTitle:
                      '${model.fullName} ${AppLocalizations.of(context).translate('notifications', 'approved_for')}  ${transactionModel.credits} ${AppLocalizations.of(context).translate('notifications', 'hours')}',
                  title: model.title,
                );
                break;
              case NotificationType.RequestCompletedRejected:
                RequestModel model = RequestModel.fromMap(notification.data);
                return NotificationCard(
                  entityName: model.fullName,
                  title: model.title,
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                  onPressed: null,
                  photoUrl: model.photoUrl,
                  subTitle:
                      '${AppLocalizations.of(context).translate('notifications', 'task_rejected_by')} ${model.fullName}',
                );
                break;

              case NotificationType.TransactionCredit:
                TransactionModel model =
                    TransactionModel.fromMap(notification.data);

                return FutureBuilder<UserModel>(
                  future: UserApi.fetchUserById(notification.senderUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Container();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingIndicator();
                    }
                    UserModel user = snapshot.data;

                    return NotificationCard(
                      entityName: user.fullname,
                      isDissmissible: true,
                      onDismissed: () {
                        NotificationsApi.readUserNotification(
                          notification.id,
                          user.email,
                        );
                      },
                      onPressed: null,
                      photoUrl: user.photoURL,
                      title: AppLocalizations.of(context)
                          .translate('notifications', 'credited'),
                      subTitle:
                          ' ${AppLocalizations.of(context).translate('notifications', 'congrats')}! ${model.credits} ${AppLocalizations.of(context).translate('notifications', 'credited_to')}.',
                    );
                  },
                );
                break;
              case NotificationType.TransactionDebit:
                TransactionModel model =
                    TransactionModel.fromMap(notification.data);

                return FutureBuilder<UserModel>(
                  future: UserApi.fetchUserById(notification.senderUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Container();
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingIndicator();
                    }
                    UserModel user = snapshot.data;

                    return NotificationCard(
                      entityName: user.fullname,
                      isDissmissible: true,
                      onDismissed: () {
                        NotificationsApi.readUserNotification(
                          notification.id,
                          user.email,
                        );
                      },
                      onPressed: null,
                      photoUrl: user.photoURL,
                      title: AppLocalizations.of(context)
                          .translate('notifications', 'debited'),
                      subTitle:
                          "${model.credits} ${AppLocalizations.of(context).translate('notifications', 'debited_to')}",
                    );
                  },
                );
                break;
              case NotificationType.OfferAccept:
                return Container();

                break;
              case NotificationType.OfferReject:
                return Container(width: 50, height: 50, color: Colors.red);
                break;

              case NotificationType.AcceptedOffer:
                OfferAcceptedNotificationModel acceptedOffer =
                    OfferAcceptedNotificationModel.fromMap(notification.data);
                return FutureBuilder<UserModel>(
                  future: UserApi.fetchUserById(acceptedOffer.acceptedBy),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return NotificationShimmer();
                    }
                    UserModel user = snapshot.data;

                    return NotificationCard(
                      entityName: user.fullname,
                      isDissmissible: true,
                      onDismissed: () {
                        NotificationsApi.readUserNotification(
                          notification.id,
                          user.email,
                        );
                      },
                      onPressed: null,
                      photoUrl: user.photoURL,
                      title: AppLocalizations.of(context)
                          .translate('notifications', 'offer_accepted'),
                      subTitle:
                          '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'show_interest')}',
                    );
                  },
                );
                break;

              case NotificationType.RequestInvite:
                print("notification data ${notification.data}");
                RequestInvitationModel requestInvitationModel =
                    RequestInvitationModel.fromMap(notification.data);

                return NotificationCard(
                  entityName: requestInvitationModel.timebankName.toLowerCase(),
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                      notification.id,
                      user.email,
                    );
                  },
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return JoinRejectDialogView(
                          requestInvitationModel: requestInvitationModel,
                          timeBankId: notification.timebankId,
                          notificationId: notification.id,
                          userModel: user,
                        );
                      },
                    );
                  },
                  photoUrl: requestInvitationModel.timebankImage,
                  subTitle:
                      '${requestInvitationModel.timebankName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${requestInvitationModel.requestTitle}, ${AppLocalizations.of(context).translate('notifications', 'tap_toview')}',
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'join_request'),
                );
                break;
              case NotificationType.GroupJoinInvite:
                print("notification data ${notification.data}");
                GroupInviteUserModel groupInviteUserModel =
                    GroupInviteUserModel.fromMap(notification.data);

                return NotificationCard(
                  entityName: groupInviteUserModel.timebankName.toLowerCase(),
                  isDissmissible: true,
                  onDismissed: () {
                    NotificationsApi.readUserNotification(
                        notification.id, user.email);
                  },
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return GroupJoinRejectDialogView(
                          groupInviteUserModel: groupInviteUserModel,
                          timeBankId: groupInviteUserModel.groupId,
                          notificationId: notification.id,
                          userModel: user,
                        );
                      },
                    );
                  },
                  photoUrl: groupInviteUserModel.timebankImage,
                  subTitle:
                      '${groupInviteUserModel.adminName.toLowerCase()} ${AppLocalizations.of(context).translate('members', 'invited_you')} ${groupInviteUserModel.timebankName}, ${AppLocalizations.of(context).translate('notifications', 'tap_to_view')}',
                  title:
                      "${AppLocalizations.of(context).translate('notifications', 'group_invite')}",
                );
                break;

              case NotificationType.TYPE_CREDIT_FROM_OFFER:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: '',
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'credited'),
                  subTitle: UserNotificationMessage.CREDIT_FROM_OFFER
                      .replaceFirst(
                        '*n',
                        (data.classDetails.numberOfClassHours +
                                data.classDetails.numberOfPreperationHours)
                            .toString(),
                      )
                      .replaceFirst('*class', data.classDetails.classTitle),
                  onDismissed: onDismissed,
                );
                break;
              case NotificationType.TYPE_NEW_MEMBER_SIGNUP_OFFER:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: data.participantDetails.photourl,
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'new_member_signup'),
                  subTitle: UserNotificationMessage.NEW_MEMBER_SIGNUP_OFFER
                      .replaceFirst(
                        '*name',
                        data.participantDetails.fullname,
                      )
                      .replaceFirst('*class', data.classDetails.classTitle),
                  onDismissed: onDismissed,
                );
                break;
              case NotificationType.TYPE_OFFER_FULFILMENT_ACHIEVED:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: '',
                  title:
                      "${AppLocalizations.of(context).translate('notifications', 'creditsfor')} ${data.classDetails.classTitle}",
                  subTitle: UserNotificationMessage.OFFER_FULFILMENT_ACHIEVED
                      .replaceFirst(
                        '*n',
                        (data.classDetails.numberOfClassHours +
                                data.classDetails.numberOfPreperationHours)
                            .toString(),
                      )
                      .replaceFirst('*class', data.classDetails.classTitle),
                  onDismissed: onDismissed,
                );
                break;

              case NotificationType.TYPE_DEBIT_FROM_OFFER:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: data.participantDetails.photourl,
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'debited'),
                  subTitle: UserNotificationMessage.DEBIT_FROM_OFFER
                      .replaceFirst(
                        '*n',
                        data.classDetails.numberOfClassHours.toString(),
                      )
                      .replaceFirst('*class', data.classDetails.classTitle),
                  onDismissed: onDismissed,
                );
                break;

              case NotificationType.TYPE_OFFER_SUBSCRIPTION_COMPLETED:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: data.participantDetails.photourl,
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'signup_for_class'),
                  subTitle: UserNotificationMessage.OFFER_SUBSCRIPTION_COMPLETED
                      .replaceFirst(
                        '*class',
                        data.classDetails.classTitle,
                      )
                      .replaceFirst('*class', data.classDetails.classTitle),
                  onDismissed: onDismissed,
                );
                break;
              case NotificationType.TYPE_FEEDBACK_FROM_SIGNUP_MEMBER:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);

                return NotificationCard(
                  photoUrl: data.participantDetails.photourl,
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'feedback_request'),
                  subTitle: UserNotificationMessage.FEEDBACK_FROM_SIGNUP_MEMBER
                      .replaceFirst(
                    '*class',
                    data.classDetails.classTitle,
                  ),
                  onPressed: () => _handleFeedBackNotificationAction(
                    context,
                    data,
                    notification.id,
                    user.email,
                  ),
                  onDismissed: onDismissed,
                );
                break;

              case NotificationType.TYPE_DELETION_REQUEST_OUTPUT:
                var requestData =
                    SoftDeleteRequestDataHolder.fromMap(notification.data);

                return NotificationCard(
                  entityName: requestData.entityTitle ?? "Deletion Request",
                  photoUrl: null,
                  title: requestData.requestAccepted
                      ? "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'was_deleted')}"
                      : "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'could_not_delete')}",
                  subTitle: requestData.requestAccepted
                      ? AppLocalizations.of(context)
                          .translate('soft_delete', 'deleted_successfully')
                          .replaceAll(
                            '***',
                            requestData.entityTitle,
                          )
                      : "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'could_not_deleted')}",
                  onPressed: () => !requestData.requestAccepted
                      ? showDialogForIncompleteTransactions(
                          context,
                          requestData,
                        )
                      : null,
                  onDismissed: onDismissed,
                );

              case NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST:
                var body = WithdrawnRequestBody.fromMap(notification.data);
                return NotificationCard(
                  entityName: body.fullName,
                  photoUrl: null,
                  title: "Member withdrawn",
                  subTitle:
                      "${body.fullName} has withdrawn from ${body.requestTite}.",
                  onDismissed: onDismissed,
                );

              case NotificationType.OFFER_CANCELLED_BY_CREATOR:
                // var body = WithdrawnRequestBody.fromMap(notification.data);
                return NotificationCard(
                  entityName: "",
                  photoUrl: null,
                  title: "One to many offer Cancelled",
                  subTitle: "Offer cancelled by Creator",
                  onDismissed: onDismissed,
                );

              case NotificationType.SEVA_COINS_CREDITED:
                return NotificationCard(
                  entityName: "CR",
                  photoUrl: null,
                  title: "Seva coins has been creited to your account",
                  subTitle: "Seva coins has been credited to your account",
                  onDismissed: onDismissed,
                );

              case NotificationType.SEVA_COINS_DEBITED:
                return NotificationCard(
                  entityName: "CR",
                  photoUrl: null,
                  title: "Seva coins has been debited from your account",
                  subTitle: "Seva coins has been debited from your account",
                  onDismissed: onDismissed,
                );

              default:
                log("Unhandled user notification type ${notification.type} ${notification.id}");
                Crashlytics().log(
                    "Unhandled notification type ${notification.type} ${notification.id}");
                return Container();
            }
          },
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
    print("results ==> $results");
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
      NotificationsApi.readUserNotification(notificationId, email);
    }
  }

  void showDialogForIncompleteTransactions(
      BuildContext context, SoftDeleteRequestDataHolder deletionRequest) {
    var reason = AppLocalizations.of(context)
        .translate('soft_delete', 'incomplete_transaction')
        .replaceAll('***', deletionRequest.entityTitle);
    if (deletionRequest.noOfOpenOffers > 0) {
      reason +=
          '${deletionRequest.noOfOpenOffers} ${AppLocalizations.of(context).translate('soft_delete', 'one_to_many_offers')}';
    }
    if (deletionRequest.noOfOpenProjects > 0) {
      reason +=
          '${deletionRequest.noOfOpenProjects} ${AppLocalizations.of(context).translate('soft_delete', 'projects')}';
    }
    if (deletionRequest.noOfOpenRequests > 0) {
      reason +=
          '${deletionRequest.noOfOpenRequests} ${AppLocalizations.of(context).translate('soft_delete', 'open_requests')}';
    }

    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          title: Text(deletionRequest.entityTitle.trim()),
          content: Text(reason),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context)
                    .translate('soft_delete', 'dismiss'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
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
