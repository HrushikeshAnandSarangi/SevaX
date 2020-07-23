import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:sevaexchange/views/timebanks/join_request_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/change_ownership_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/group_join_reject_dialog.dart';
import 'package:shimmer/shimmer.dart';

class NotificationViewHolder extends StatefulWidget {
  final String timebankId;

  NotificationViewHolder({this.timebankId});

  @override
  State<StatefulWidget> createState() {
    return NotificationsView();
  }
}

class NotificationsView extends State<NotificationViewHolder> {
  UserModel user;

  @override
  void initState() {
    log("notification page init");
    Future.delayed(Duration.zero, () {
      user = SevaCore.of(context).loggedInUser;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("notification page build");
    return StreamBuilder<List<NotificationsModel>>(
      stream: FirestoreManager.getNotifications(
        userEmail: SevaCore.of(context).loggedInUser.email,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (contextFirestore, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<NotificationsModel> notifications = snapshot.data;

        SevaCore.of(context).loggedInUser.notificationsRead =
            notifications.length;

        if (notifications.length == 0) {
          return Center(
            child: Text(AppLocalizations.of(context)
                .translate('notifications', 'no_notifications')),
          );
        }

        ClearNotificationModel clearNotificationModel =
            clearNotificationModelFromJson(
                AppConfig.remoteConfig.getString("clear_notification_type"));
        print(clearNotificationModel.notificationType);
        return Column(
          children: <Widget>[
            Offstage(
              offstage: !clearNotificationModel.isClearNotificationEnabled,
              child: FlatButton(
                textColor: Colors.black,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.clear_all),
                    Text(AppLocalizations.of(context)
                        .translate('notifications', 'clear_all')),
                  ],
                ),
                onPressed: () {
                  clearAllNotification(notifications,
                      clearNotificationModel.notificationType, user.email);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(bottom: 20),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  NotificationsModel notification =
                      notifications.elementAt(index);

                  Future<void> onDismissed() async {
                    await _clearNotification(
                      notificationId: notification.id,
                      email: user.email,
                    );
                  }

                  switch (notification.type) {
                    case NotificationType.RecurringRequestUpdated:
                      ReccuringRequestUpdated eventData =
                          ReccuringRequestUpdated.fromMap(notification.data);
                      return NotificationCard(
                        title: "Request Updated",
                        subTitle:
                            "${AppLocalizations.of(context).translate('notifications', 'you_signed_up_for')} ***eventName ${AppLocalizations.of(context).translate('notifications', 'on')} ***eventDate. ${AppLocalizations.of(context).translate('notifications', 'owner_changes')}"
                                .replaceFirst(
                                    '***eventName', eventData.eventName)
                                .replaceFirst(
                                    '***eventDate',
                                    DateTime.fromMillisecondsSinceEpoch(
                                            eventData.eventDate)
                                        .toString()),
                        entityName: "Request Updated",
                        photoUrl: eventData.photoUrl,
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.RequestAccept:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);

                      return FutureBuilder<RequestModel>(
                          future: FirestoreManager.getRequestFutureById(
                            requestId: model.id,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            RequestModel model = snapshot.data;
                            return getNotificationAcceptedWidget(
                              model,
                              notification.senderUserId,
                              notification.id,
                            );
                          });
                      break;

                    case NotificationType.TypeChangeOwnership:
                      ChangeOwnershipModel ownershipModel =
                          ChangeOwnershipModel.fromMap(notification.data);

                      return getChangeOwnershipNotificationWidget(
                          notificationId: notification.id,
                          communityId: notification.communityId,
                          changeOwnershipModel: ownershipModel,
                          timebankId: notification.timebankId,
                          notificationsModel: notification);
                      break;
                    case NotificationType.RequestApprove:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);

                      return getNotificationRequestApprovalWidget(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                      break;

                    case NotificationType.TypeMemberAdded:
                      UserAddedModel userAddedModel =
                          UserAddedModel.fromMap(notification.data);

                      return getUserAddedNotificationWidget(
                          userAddedModel: userAddedModel,
                          timebankId: notification.timebankId,
                          communityId: notification.communityId,
                          buildContext: context,
                          notificationId: notification.id);
                      break;

                    case NotificationType.RequestReject:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return getNotificationRequestRejectWidget(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                      break;

                    case NotificationType.JoinRequest:
                      JoinRequestNotificationModel model =
                          JoinRequestNotificationModel.fromMap(
                              notification.data);
                      return FutureBuilder<UserModel>(
                          future: FirestoreManager.getUserForId(
                              sevaUserId: notification.senderUserId),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return notificationShimmer;
                            }
                            UserModel user = snapshot.data;
                            return user != null && user.fullname != null
                                ? getJoinReuqestsNotificationWidget(
                                    user,
                                    notification.id,
                                    model,
                                    context,
                                  )
                                : Offstage();
                          });
                      break;

                    case NotificationType.RequestCompleted:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return FutureBuilder<RequestModel>(
                          future: FirestoreManager.getRequestFutureById(
                              requestId: model.id),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            RequestModel model = snapshot.data;
                            return getNotificationRequestCompletedWidget(
                              model,
                              notification.senderUserId,
                              notification.id,
                            );
                          });
                      break;
                    case NotificationType.RequestCompletedApproved:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return getNotificationRequestCompletedApproved(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                      break;
                    case NotificationType.RequestCompletedRejected:
                      RequestModel model =
                          RequestModel.fromMap(notification.data);
                      return getNotificationTaskCompletedRejectWidget(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                      break;
                    case NotificationType.TransactionCredit:
                      TransactionModel model =
                          TransactionModel.fromMap(notification.data);

                      return getNotificationCredit(
                          model, notification.senderUserId, notification.id);
                      break;
                    case NotificationType.TransactionDebit:
                      TransactionModel model =
                          TransactionModel.fromMap(notification.data);

                      return getNotificationDebit(
                          model, notification.senderUserId, notification.id);
                      break;
                    case NotificationType.OfferAccept:
                      return Container();

                      break;
                    case NotificationType.OfferReject:
                      return Container(
                          width: 50, height: 50, color: Colors.red);
                      break;

                    case NotificationType.AcceptedOffer:
                      OfferAcceptedNotificationModel acceptedOffer =
                          OfferAcceptedNotificationModel.fromMap(
                              notification.data);
                      return FutureBuilder<UserModel>(
                          future: FirestoreManager.getUserForId(
                              sevaUserId: acceptedOffer.acceptedBy),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return notificationShimmer;
                            }
                            UserModel user = snapshot.data;
                            return getOfferAcceptedNotificationView(
                                user, notification.id, acceptedOffer, context);
                          });

                      break;

                    case NotificationType.RequestInvite:
                      print("notification data ${notification.data}");
                      RequestInvitationModel requestInvitationModel =
                          RequestInvitationModel.fromMap(notification.data);
                      return getInvitedRequestsNotificationWidget(
                        requestInvitationModel,
                        notification.id,
                        context,
                        notification.timebankId,
                        notification.communityId,
                      );
                      break;
                    case NotificationType.GroupJoinInvite:
                      print("notification data ${notification.data}");
                      GroupInviteUserModel groupInviteUserModel =
                          GroupInviteUserModel.fromMap(notification.data);
                      return getGroupInvitationNotificationWidget(
                        groupInviteUserModel,
                        notification.id,
                        context,
                        notification.communityId,
                      );
                      break;

                    case NotificationType.TYPE_CREDIT_FROM_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: '',
                        title: AppLocalizations.of(context)
                            .translate('notifications', 'credited'),
                        subTitle: UserNotificationMessage.CREDIT_FROM_OFFER
                            .replaceFirst(
                              '*n',
                              (data.classDetails.numberOfClassHours +
                                      data.classDetails
                                          .numberOfPreperationHours)
                                  .toString(),
                            )
                            .replaceFirst(
                                '*class', data.classDetails.classTitle),
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.TYPE_NEW_MEMBER_SIGNUP_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: data.participantDetails.photourl,
                        title: AppLocalizations.of(context)
                            .translate('notifications', 'new_member_signup'),
                        subTitle: UserNotificationMessage
                            .NEW_MEMBER_SIGNUP_OFFER
                            .replaceFirst(
                              '*name',
                              data.participantDetails.fullname,
                            )
                            .replaceFirst(
                                '*class', data.classDetails.classTitle),
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.TYPE_OFFER_FULFILMENT_ACHIEVED:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: '',
                        title:
                            "${AppLocalizations.of(context).translate('notifications', 'creditsfor')} ${data.classDetails.classTitle}",
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
                                '*class', data.classDetails.classTitle),
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_DEBIT_FROM_OFFER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: data.participantDetails.photourl,
                        title: AppLocalizations.of(context)
                            .translate('notifications', 'debited'),
                        subTitle: UserNotificationMessage.DEBIT_FROM_OFFER
                            .replaceFirst(
                              '*n',
                              data.classDetails.numberOfClassHours.toString(),
                            )
                            .replaceFirst(
                                '*class', data.classDetails.classTitle),
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_OFFER_SUBSCRIPTION_COMPLETED:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: data.participantDetails.photourl,
                        title: AppLocalizations.of(context)
                            .translate('notifications', 'signup_for_class'),
                        subTitle: UserNotificationMessage
                            .OFFER_SUBSCRIPTION_COMPLETED
                            .replaceFirst(
                              '*class',
                              data.classDetails.classTitle,
                            )
                            .replaceFirst(
                                '*class', data.classDetails.classTitle),
                        onDismissed: onDismissed,
                      );
                      break;
                    case NotificationType.TYPE_FEEDBACK_FROM_SIGNUP_MEMBER:
                      OneToManyNotificationDataModel data =
                          OneToManyNotificationDataModel.fromJson(
                              notification.data);

                      return NotificationCard(
                        photoUrl: data.participantDetails.photourl,
                        title: AppLocalizations.of(context)
                            .translate('notifications', 'feedback_request'),
                        subTitle: UserNotificationMessage
                            .FEEDBACK_FROM_SIGNUP_MEMBER
                            .replaceFirst(
                          '*class',
                          data.classDetails.classTitle,
                        ),
                        onPressed: () => _handleFeedBackNotificationAction(
                          data,
                          notification.id,
                          user.email,
                        ),
                        onDismissed: onDismissed,
                      );
                      break;

                    case NotificationType.TYPE_DELETION_REQUEST_OUTPUT:
                      var requestData = SoftDeleteRequestDataHolder.fromMap(
                          notification.data);

                      return NotificationCard(
                        entityName:
                            requestData.entityTitle ?? "Deletion Request",
                        photoUrl: null,
                        title: requestData.requestAccepted
                            ? "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'was_deleted')}"
                            : "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'could_not_delete')}",
                        subTitle: requestData.requestAccepted
                            ? AppLocalizations.of(context)
                                .translate(
                                    'soft_delete', 'deleted_successfully')
                                .replaceAll(
                                  '***',
                                  requestData.entityTitle,
                                )
                            : "${requestData.entityTitle} ${AppLocalizations.of(context).translate('soft_delete', 'could_not_deleted')}",
                        onPressed: () => !requestData.requestAccepted
                            ? showDialogForIncompleteTransactions(
                                requestData,
                              )
                            : null,
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

  Widget getUserAddedNotificationWidget({
    UserAddedModel userAddedModel,
    String notificationId,
    BuildContext buildContext,
    String timebankId,
    String communityId,
  }) {
    return NotificationCard(
      entityName: userAddedModel.adminName,
      isDissmissible: true,
      onDismissed: () {
        FirestoreManager.readUserNotification(
          notificationId,
          SevaCore.of(context).loggedInUser.email,
        );
      },
      onPressed: null,
      photoUrl: userAddedModel.timebankImage,
      title: AppLocalizations.of(context)
          .translate('notifications', 'timebank_join'),
      subTitle:
          '${userAddedModel.adminName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'added_you')} ${userAddedModel.timebankName} ${AppLocalizations.of(context).translate('members', 'timebank')}',
    );
  }

  Widget getChangeOwnershipNotificationWidget({
    ChangeOwnershipModel changeOwnershipModel,
    NotificationsModel notificationsModel,
    String notificationId,
    BuildContext buildContext,
    String timebankId,
    String communityId,
  }) {
    return NotificationCard(
      entityName: changeOwnershipModel.creatorName,
      isDissmissible: true,
      onDismissed: () {
        FirestoreManager.readUserNotification(
          notificationId,
          SevaCore.of(context).loggedInUser.email,
        );
      },
      onPressed: () {
        showDialog(
            context: context,
            builder: (mContext) {
              return ChangeOwnershipDialog(
                changeOwnershipModel: changeOwnershipModel,
                timeBankId: timebankId,
                notificationId: notificationId,
                notificationModel: notificationsModel,
                loggedInUser: user,
                parentContext: context,
              );
            });
      },
      photoUrl: changeOwnershipModel.creatorPhotoUrl,
      title: AppLocalizations.of(context)
          .translate('change_ownership', 'change_ownership_title'),
      subTitle:
          '${changeOwnershipModel.creatorName.toLowerCase()} ${AppLocalizations.of(context).translate('change_ownership', 'notification_msg')} ${changeOwnershipModel.timebank.toLowerCase().replaceAll("timebank", "")} ${AppLocalizations.of(context).translate('members', 'timebank')}',
    );
  }

  void _handleFeedBackNotificationAction(
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
      _clearNotification(email: email, notificationId: notificationId);
    }
  }

  Future _clearNotification({String email, String notificationId}) {
    return FirestoreManager.readUserNotification(
      notificationId,
      email,
    );
  }

  Widget getNotificationCredit(
    TransactionModel model,
    String userId,
    String notificationId,
  ) {
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
        }
        UserModel user = snapshot.data;

        return NotificationCard(
          entityName: user.fullname,
          isDissmissible: true,
          onDismissed: () {
            FirestoreManager.readUserNotification(
              notificationId,
              SevaCore.of(context).loggedInUser.email,
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
  }

  Widget getNotificationDebit(
    TransactionModel model,
    String userId,
    String notificationId,
  ) {
    return FutureBuilder<UserModel>(
        future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container();
          if (snapshot.connectionState == ConnectionState.waiting) {
            return notificationShimmer;
          }
          UserModel user = snapshot.data;

          return NotificationCard(
            entityName: user.fullname,
            isDissmissible: true,
            onDismissed: () {
              FirestoreManager.readUserNotification(
                notificationId,
                SevaCore.of(context).loggedInUser.email,
              );
            },
            onPressed: null,
            photoUrl: user.photoURL,
            title: AppLocalizations.of(context)
                .translate('notifications', 'debited'),
            subTitle:
                "${model.credits} ${AppLocalizations.of(context).translate('notifications', 'debited_to')}",
          );
        });
  }

  Widget getNotificationRequestCompletedApproved(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    TransactionModel transactionModel =
        model.transactions.firstWhere((transaction) {
      return transaction.to == SevaCore.of(context).loggedInUser.sevaUserID;
    });

    return NotificationCard(
      entityName: model.fullName,
      isDissmissible: true,
      onDismissed: () {
        FirestoreManager.readUserNotification(
          notificationId,
          SevaCore.of(context).loggedInUser.email,
        );
      },
      onPressed: null,
      photoUrl: model.photoUrl,
      subTitle:
          '${model.fullName} ${AppLocalizations.of(context).translate('notifications', 'approved_for')}  ${transactionModel.credits} ${AppLocalizations.of(context).translate('notifications', 'hours')}',
      title: model.title,
    );
  }

  Widget getOfferAcceptNotification(
      OfferModel offermodel,
      String userId,
      String loggedinUserID,
      String notificationId,
      String requestid,
      List<NotificationsModel> notifications) {
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
        }
        UserModel user = snapshot.data;

        return FutureBuilder<Object>(
            future: FirestoreManager.getUserForId(sevaUserId: loggedinUserID),
            builder: (context, snapshot) {
              UserModel loggedinUser = snapshot.data;
              return Slidable(
                delegate: SlidableBehindDelegate(),
                actions: <Widget>[
                  FutureBuilder<Object>(
                      future: FirestoreManager.getRequestFutureById(
                          requestId: requestid),
                      builder: (context, snapshot) {
                        RequestModel model = snapshot.data;
                        if (snapshot.hasError) return Container();
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return notificationShimmer;
                        }
                        return SlideAction(
                          onTap: () {
                            Set<String> acceptorList =
                                Set.from(model.acceptors);
                            acceptorList.add(loggedinUser.email);
                            model.acceptors = acceptorList.toList();
                            FirestoreManager.acceptRequest(
                              requestModel: model,
                              senderUserId: loggedinUserID,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                            );
                            offermodel.associatedRequest = requestid;
                            updateOfferWithRequest(offer: offermodel);
                            notifications.forEach((_notification) {
                              OfferModel _offer =
                                  OfferModel.fromMap(_notification.data);
                              if (_offer.id == offermodel.id) {
                                FirestoreManager.readUserNotification(
                                    _notification.id, loggedinUser.email);
                              }
                            });
                          },
                          child: Container(
                            padding: notificationPadding,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                              color: Colors.green,
                              shadows: shadowList,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                ],
                child: FutureBuilder<Object>(
                    future: FirestoreManager.getRequestFutureById(
                        requestId: requestid),
                    builder: (context, snapshot) {
                      RequestModel model = snapshot.data;
                      if (snapshot.hasError) return Container();
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return notificationShimmer;
                      }
                      return Container(
                        margin: notificationPadding,
                        decoration: notificationDecoration,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL),
                          ),
                          title: Text(model.title),
                          subtitle: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${user.fullname} ${AppLocalizations.of(context).translate('notifications', 'send_request_for')} ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: () {
                                    return '';
                                  }(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            });
      },
    );
  }

  void approveTransaction(RequestModel model, String userId,
      String notificationId, SevaCore sevaCore) {
    FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity,
    );

    FirestoreManager.readUserNotification(
        notificationId, sevaCore.loggedInUser.email);
  }

  void checkForFeedback(
      {String userId,
      UserModel user,
      RequestModel model,
      String notificationId,
      BuildContext context,
      SevaCore sevaCore}) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback(
          feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
        );
      },
    ));

    if (results != null && results.containsKey('selection')) {
      onActivityResult(
        sevaCore: sevaCore,
        requestModel: model,
        userId: userId,
        notificationId: notificationId,
        context: context,
        reviewer: model.email,
        reviewed: user.email,
        requestId: model.id,
        results: results,
      );
    } else {}
  }

  void onActivityResult(
      {SevaCore sevaCore,
      RequestModel requestModel,
      String userId,
      String notificationId,
      BuildContext context,
      Map results,
      String reviewer,
      String reviewed,
      String requestId}) {
    Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "requestId": requestId,
      "comments": (results['didComment']
          ? results['comment']
          : AppLocalizations.of(context)
              .translate('notifications', 'no_comments'))
    });
    approveTransaction(requestModel, userId, notificationId, sevaCore);
  }

  Widget getNotificationRequestCompletedWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
      builder: (_context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
        }
        UserModel user = snapshot.data;
        TransactionModel transactionModel =
            model.transactions?.firstWhere((transaction) {
          return transaction.to == userId;
        });
        return Slidable(
            delegate: SlidableBehindDelegate(),
            actions: <Widget>[],
            secondaryActions: <Widget>[],
            child: GestureDetector(
              onTap: () async {
                var canApproveTransaction =
                    await FirestoreManager.hasSufficientCredits(
                  credits: transactionModel.credits,
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
                );

                if (!canApproveTransaction) {
                  showDiologForMessage(AppLocalizations.of(context)
                      .translate('notifications', 'no_sufficient'));
                  return;
                }

                showMemberClaimConfirmation(
                  context: context,
                  notificationId: notificationId,
                  requestModel: model,
                  userId: userId,
                  userModel: user,
                  credits: transactionModel.credits,
                );
              },
              child: Container(
                margin: notificationPadding,
                decoration: notificationDecoration,
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(user.photoURL ?? defaultUserImageURL)),
                  title: Text(model.title),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${user.fullname} ${AppLocalizations.of(context).translate('notifications', 'completed_in')} ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return '${transactionModel.credits} ${AppLocalizations.of(context).translate('notifications', 'hours')}';
                          }(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return ', ${AppLocalizations.of(context).translate('notifications', 'waiting_for')}';
                          }(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  void showDiologForMessage(String dialogText) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogText),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate('notifications', 'ok'),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  Widget getGroupInvitationNotificationWidget(
      GroupInviteUserModel groupInviteUserModel,
      String notificationId,
      BuildContext buildContext,
      String communityId) {
    return NotificationCard(
      entityName: groupInviteUserModel.timebankName.toLowerCase(),
      isDissmissible: true,
      onDismissed: () {
        String userEmail = SevaCore.of(buildContext).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      onPressed: () {
        showDialog(
            context: buildContext,
            builder: (context) {
              return GroupJoinRejectDialogView(
                groupInviteUserModel: groupInviteUserModel,
                timeBankId: groupInviteUserModel.groupId,
                notificationId: notificationId,
                userModel: SevaCore.of(buildContext).loggedInUser,
              );
            });
      },
      photoUrl: groupInviteUserModel.timebankImage,
      subTitle:
          '${groupInviteUserModel.adminName.toLowerCase()} ${AppLocalizations.of(context).translate('members', 'invited_you')} ${groupInviteUserModel.timebankName}, ${AppLocalizations.of(context).translate('notifications', 'tap_to_view')}',
      title:
          "${AppLocalizations.of(context).translate('notifications', 'group_invite')}",
    );
  }

  void showDialogForIncompleteTransactions(
      SoftDeleteRequestDataHolder deletionRequest) {
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
        });
  }

  Widget getInvitedRequestsNotificationWidget(
      RequestInvitationModel requestInvitationModel,
      String notificationId,
      BuildContext buildContext,
      String timebankId,
      String communityId) {
    return NotificationCard(
      entityName: requestInvitationModel.timebankName.toLowerCase(),
      isDissmissible: true,
      onDismissed: () {
        String userEmail = SevaCore.of(buildContext).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      onPressed: () {
        showDialog(
            context: buildContext,
            builder: (context) {
              return JoinRejectDialogView(
                requestInvitationModel: requestInvitationModel,
                timeBankId: timebankId,
                notificationId: notificationId,
                userModel: SevaCore.of(buildContext).loggedInUser,
              );
            });
      },
      photoUrl: requestInvitationModel.timebankImage,
      subTitle:
          '${requestInvitationModel.timebankName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${requestInvitationModel.requestTitle}, ${AppLocalizations.of(context).translate('notifications', 'tap_toview')}',
      title: AppLocalizations.of(context)
          .translate('notifications', 'join_request'),
    );
  }

  void showMemberClaimConfirmation(
      {BuildContext context,
      UserModel userModel,
      RequestModel requestModel,
      String notificationId,
      String userId,
      double credits}) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.photoURL),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "${AppLocalizations.of(context).translate('notifications', 'by_approving')} ${userModel.fullname} has worked for $credits hours",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('notifications', 'approve'),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            approveMemberClaim(
                                context: context,
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel,
                                userId: userId,
                                credits: credits);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('notifications', 'reject'),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            rejectMemberClaimForEvent(
                              context: context,
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                              userId: userId,
                            );
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio.length < 100) {
        return Center(
          child: Text(userModel.bio),
        );
      }
      return Container(
        height: 150,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            userModel.bio,
            maxLines: null,
            overflow: null,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(AppLocalizations.of(context)
          .translate('notifications', 'bio_notupdated')),
    );
  }

  Future<void> approveMemberClaim({
    String userId,
    UserModel user,
    BuildContext context,
    RequestModel model,
    String notificationId,
    double credits,
  }) async {
    checkForFeedback(
      userId: userId,
      user: user,
      context: context,
      model: model,
      notificationId: notificationId,
      sevaCore: SevaCore.of(context),
    );
  }

  void rejectMemberClaimForEvent(
      {RequestModel model,
      String userId,
      BuildContext context,
      UserModel user,
      String notificationId}) {
    List<TransactionModel> transactions =
        model.transactions.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    model.transactions = transactions.map((t) {
      return t;
    }).toList();
    FirestoreManager.rejectRequestCompletion(
      model: model,
      userId: userId,
      communityid: SevaCore.of(context).loggedInUser.currentCommunity,
    );

    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      name: loggedInUser.fullname,
      photoUrl: loggedInUser.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevaUserID,
      name: user.fullname,
      photoUrl: user.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );
    createAndOpenChat(
      communityId: loggedInUser.currentCommunity,
      context: context,
      timebankId: widget.timebankId,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
    );
    FirestoreManager.readUserNotification(
        notificationId, SevaCore.of(context).loggedInUser.email);
  }

  Widget getJoinReuqestsNotificationWidget(
      UserModel user,
      String notificationId,
      JoinRequestNotificationModel model,
      BuildContext context) {
    return Dismissible(
        background: dismissibleBackground,
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          String userEmail = SevaCore.of(context).loggedInUser.email;
          FirestoreManager.readUserNotification(notificationId, userEmail);
        },
        child: GestureDetector(
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              title: Text(AppLocalizations.of(context)
                  .translate('notifications', 'join_request')),
              leading: user.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL),
                    )
                  : Offstage(),
              subtitle: Text(
                  '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${model.timebankTitle}, ${AppLocalizations.of(context).translate('notifications', 'tap_toview')}'),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => JoinRequestView(
                        timebankId: model.timebankId,
                      )),
            );
          },
        ));
  }

  Widget getOfferAcceptedNotificationView(UserModel user, String notificationId,
      OfferAcceptedNotificationModel model, BuildContext context) {
    return Dismissible(
        background: dismissibleBackground,
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          String userEmail = SevaCore.of(context).loggedInUser.email;
          FirestoreManager.readUserNotification(notificationId, userEmail);
        },
        child: GestureDetector(
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              title: Text(AppLocalizations.of(context)
                  .translate('notifications', 'offer_accepted')),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL),
              ),
              subtitle: Text(
                  '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'show_interest')}'),
            ),
          ),
          onTap: () {},
        ));
  }

  Widget getNotificationRequestApprovalWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model.title),
          leading: CircleAvatar(
              backgroundImage: model.photoUrl != null
                  ? NetworkImage(model.photoUrl)
                  : AssetImage("lib/assets/images/approved.png")),
          subtitle: Text(
              '${AppLocalizations.of(context).translate('notifications', 'approved_by')} ${model.fullName}'),
        ),
      ),
    );
  }

  Widget getNotificationRequestRejectWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model.title),
          leading: CircleAvatar(
              backgroundImage: model.photoUrl != null
                  ? NetworkImage(model.photoUrl)
                  : AssetImage("lib/assets/images/profile.png")),
          subtitle: Text(
              '${AppLocalizations.of(context).translate('notifications', 'rejected_by')} ${model.fullName}'),
        ),
      ),
    );
  }

  Widget getNotificationTaskCompletedRejectWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model.title),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(model.photoUrl),
          ),
          subtitle: Text(
              '${AppLocalizations.of(context).translate('notifications', 'task_rejected_by')} ${model.fullName}'),
          onTap: () {},
        ),
      ),
    );
  }

  Widget getNotificationAcceptedWidget(
      RequestModel model, String userId, String notificationId) {
    print("_____________________${userId}");
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
        }

        UserModel user = snapshot.data;

        return Slidable(
            delegate: SlidableBehindDelegate(),
            actions: <Widget>[],
            secondaryActions: <Widget>[],
            child: GestureDetector(
              onTap: () {
                showDialogForApproval(
                    context: context,
                    userModel: user,
                    notificationId: notificationId,
                    requestModel: model);
              },
              child: Container(
                  margin: notificationPadding,
                  decoration: notificationDecoration,
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(model.title),
                    ),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(user.photoURL ?? defaultUserImageURL),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: Text(
                          '${AppLocalizations.of(context).translate('notifications', 'request_accepted_by')} ${user.fullname}, ${AppLocalizations.of(context).translate('notifications', 'waiting_for')}'),
                    ),
                  )),
            ));
      },
    );
  }

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    FirestoreManager.approveAcceptRequest(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      directToMember: true,
    );
  }

  void showDialogForApproval({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          userModel.photoURL ?? defaultUserImageURL),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Center(
                    child: Text(
                        "${AppLocalizations.of(context).translate('notifications', 'by_approving_short')}, ${userModel.fullname} ${AppLocalizations.of(context).translate('notifications', 'add_to')}.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('notifications', 'approve'),
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Europa'),
                          ),
                          onPressed: () async {
                            approveMemberForVolunteerRequest(
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel);
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('notifications', 'decline'),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            declineRequestedMember(
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Container get dismissibleBackground => Container(
        margin: EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: Colors.red.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: shadowList,
        ),
        child: ListTile(),
      );

  EdgeInsets get notificationPadding => EdgeInsets.fromLTRB(5, 5, 5, 0);

  Decoration get notificationDecoration => ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.white,
        shadows: shadowList,
      );

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  Widget get notificationShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }
}
