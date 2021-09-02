import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/components/lending_borrow_widgets/approve_lending_offer.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/module/index.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_complete_widget.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/create_offer_request.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:sevaexchange/views/requests/offer_join_request.dart';
import 'package:sevaexchange/views/timebanks/join_request_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/group_join_reject_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavor_config.dart';
import 'notifications_bloc.dart';

class PersonalNotificationReducerForRequests {
  static void showDialogForIncompleteTransactions(
      BuildContext context, SoftDeleteRequestDataHolder deletionRequest) {
    var reason = S
            .of(context)
            .notifications_incomplete_transaction
            .replaceAll('***', deletionRequest.entityTitle) +
        '\n';
    if (deletionRequest.noOfOpenOffers > 0) {
      reason +=
          '${deletionRequest.noOfOpenOffers} ${S.of(context).one_to_many_offers}\n';
    }
    if (deletionRequest.noOfOpenProjects > 0) {
      reason +=
          '${deletionRequest.noOfOpenProjects} ${S.of(context).projects}\n';
    }
    if (deletionRequest.noOfOpenRequests > 0) {
      reason +=
          '${deletionRequest.noOfOpenRequests} ${S.of(context).open_requests}\n';
    }

    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          title: Text(deletionRequest.entityTitle.trim()),
          content: Text(reason),
          actions: <Widget>[
            CustomTextButton(
              child: Text(
                S.of(context).dismiss,
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

  static Widget getWidgetNotificaitonForDeletionrequest({
    NotificationsModel notification,
    BuildContext context,
    NotificationsBloc bloc,
    String email,
  }) {
    var requestData = SoftDeleteRequestDataHolder.fromMap(notification.data);

    return NotificationCard(
      timestamp: notification.timestamp,
      entityName: requestData.entityTitle ?? "Deletion Request",
      photoUrl: null,
      title: requestData.requestAccepted
          ? "${requestData.entityTitle} ${S.of(context).notifications_was_deleted}"
          : "${requestData.entityTitle} ${S.of(context).notifications_could_not_delete}",
      subTitle: requestData.requestAccepted
          ? S.of(context).notifications_successfully_deleted.replaceAll(
                    '***',
                    requestData.entityTitle,
                  ) +
              " "
          : "${requestData.entityTitle} ${S.of(context).notifications_could_not_deleted}  ",
      onPressed: () => !requestData.requestAccepted
          ? showDialogForIncompleteTransactions(
              context,
              requestData,
            )
          : null,
      onDismissed: () {
        onDismissed(
          bloc: bloc,
          notificationId: notification.id,
          userEmail: email,
        );
      },
    );
  }

  static Widget getWidgetNotificationForTransactionDebit({
    NotificationsModel notification,
    String loggedInUserEmail,
  }) {
    TransactionModel model = TransactionModel.fromMap(notification.data);

    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(notification.senderUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        UserModel user = snapshot.data;

        return NotificationCard(
          timestamp: notification.timestamp,
          entityName: user.fullname,
          isDissmissible: true,
          onDismissed: () {
            NotificationsRepository.readUserNotification(
              notification.id,
              loggedInUserEmail,
            );
          },
          onPressed: null,
          photoUrl: user.photoURL,
          title: S.of(context).notifications_debited,
          subTitle:
              "${model.credits} ${S.of(context).seva_credits} ${S.of(context).notifications_debited_to} ",
        );
      },
    );
  }

  static Widget getWidgetNotificationForGroupJoinInvite({
    NotificationsModel notification,
    BuildContext context,
    UserModel user,
  }) {
    GroupInviteUserModel groupInviteUserModel =
        GroupInviteUserModel.fromMap(notification.data);

    return NotificationCard(
      timestamp: notification.timestamp,
      entityName: groupInviteUserModel.timebankName.toLowerCase(),
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
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
          '${groupInviteUserModel.adminName.toLowerCase()} ${S.of(context).notifications_invited_to_join} ${groupInviteUserModel.timebankName}, ${S.of(context).notifications_tap_to_view} ',
      title: "${S.of(context).notifications_group_join_invite}",
    );
  }

  static Widget getWidgetNotificationForTransactionCredit({
    NotificationsModel notification,
    String loggedInUserEmail,
  }) {
    TransactionModel model = TransactionModel.fromMap(notification.data);

    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(notification.senderUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        UserModel user = snapshot.data;

        return NotificationCard(
          timestamp: notification.timestamp,
          entityName: user.fullname,
          isDissmissible: true,
          onDismissed: () {
            NotificationsRepository.readUserNotification(
              notification.id,
              loggedInUserEmail,
            );
          },
          onPressed: null,
          photoUrl: user.photoURL,
          title: S.of(context).notifications_credited,
          subTitle:
              ' ${S.of(context).congrats}! ${model.credits} ${S.of(context).seva_credits} ${S.of(context).notifications_credited_to}. ',
        );
      },
    );
  }

  static Widget getWidgetForRequestCompletedApproved({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    RequestModel model = RequestModel.fromMap(notification.data);
    TransactionModel transactionModel = model.transactions.firstWhere(
      (transaction) => transaction.to == user.sevaUserID,
    );
    return NotificationCard(
      timestamp: notification.timestamp,
      entityName: model.fullName,
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
          '${model.fullName} ${S.of(context).notifications_approved_for}  ${transactionModel.credits} ${transactionModel.credits > 1 ? S.of(context).hours : S.of(context).hour} ',
      //plural here
      title: model.title,
    );
  }

  static Widget getWidgetForRequestCompleted({
    NotificationsModel notification,
    BuildContext parentContext,
  }) {
    RequestModel model = RequestModel.fromMap(notification.data);
    return FutureBuilder<RequestModel>(
      future: RequestRepository.getRequestFutureById(model.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        RequestModel model = snapshot.data;
        return RequestCompleteWidget(
          parentContext: parentContext,
          model: model,
          userId: notification.senderUserId,
          notificationId: notification.id,
        );
      },
    );
  }

  static void _settingModalBottomSheet(
      BuildContext context,
      RequestInvitationModel requestInvitationModel,
      String timebankId,
      String id,
      UserModel user) {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": []
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    S.of(context).calendars_popup_desc,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Home,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/googlecal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return JoinRejectDialogView(
                                    requestInvitationModel:
                                        requestInvitationModel,
                                    timeBankId: timebankId,
                                    notificationId: id,
                                    userModel: user,
                                  );
                                },
                              );
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Home,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/outlookcal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return JoinRejectDialogView(
                                    requestInvitationModel:
                                        requestInvitationModel,
                                    timeBankId: timebankId,
                                    notificationId: id,
                                    userModel: user,
                                  );
                                },
                              );
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Home,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset("lib/assets/images/ical.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return JoinRejectDialogView(
                                    requestInvitationModel:
                                        requestInvitationModel,
                                    timeBankId: timebankId,
                                    notificationId: id,
                                    userModel: user,
                                  );
                                },
                              );
                            }),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    CustomTextButton(
                      child: Text(
                        S.of(context).do_it_later,
                        style: TextStyle(
                            color: FlavorConfig.values.theme.primaryColor),
                      ),
                      onPressed: () async {
                        Navigator.of(bc).pop();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return JoinRejectDialogView(
                              requestInvitationModel: requestInvitationModel,
                              timeBankId: timebankId,
                              notificationId: id,
                              userModel: user,
                            );
                          },
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  static Widget getWidgetForAcceptedOfferNotification({
    NotificationsModel notification,
  }) {
    OfferAcceptedNotificationModel acceptedOffer =
        OfferAcceptedNotificationModel.fromMap(notification.data);
    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(acceptedOffer.acceptedBy),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data;

        return NotificationCard(
          timestamp: notification.timestamp,
          entityName: user.fullname,
          isDissmissible: true,
          onDismissed: () {
            NotificationsRepository.readUserNotification(
              notification.id,
              user.email,
            );
          },
          onPressed: null,
          photoUrl: user.photoURL,
          title: S.of(context).notifications_offer_accepted,
          subTitle:
              '${user.fullname.toLowerCase()} ${S.of(context).notifications_shown_interest} ',
        );
      },
    );
  }

  static Widget getOfferRequestInvitation({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    TimeOfferParticipantsModel timeOfferParticipantsModel =
        TimeOfferParticipantsModel.fromJSON(notification.data);

    return _getNotificationCardForOfferRequestInvitationRequest(
      notification: notification,
      user: user,
      context: context,
      timeOfferParticipantsModel: timeOfferParticipantsModel,
    );
  }

  static Widget getInvitationForRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    RequestInvitationModel requestInvitationModel =
        RequestInvitationModel.fromMap(notification.data);

    switch (requestInvitationModel.requestModel.requestType) {
      case RequestType.TIME:
        return _getNotificationCardForTimeInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );

      case RequestType.GOODS:
        return _getNotificationCardForGoodsInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );
        break;

      case RequestType.CASH:
        return _getNotificationCardForCashInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );

      case RequestType.ONE_TO_MANY_REQUEST:
        return _getNotificationCardForOneToManyInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );

      default:
        return _getNotificationCardForTimeInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );
    }
  }

  static Widget _getNotificationCardForOneToManyInvitationRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
    RequestInvitationModel requestInvitationModel,
  }) {
    return NotificationCard(
      entityName: requestInvitationModel.timebankModel.name,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      photoUrl: requestInvitationModel.timebankModel.photoUrl,
      subTitle:
          '${requestInvitationModel.timebankModel.name} ${S.of(context).notifications_requested_join} ${requestInvitationModel.requestModel.title}, ${S.of(context).notifications_tap_to_view}',
      title: S.of(context).join_webinar,
      onPressed: () {
        //TODO calendar updated please test.
        // if (SevaCore.of(context).loggedInUser.calendarId == null) {
        //   _settingModalBottomSheet(context, requestInvitationModel,
        //       notification.timebankId, notification.id, user);
        // } else {}

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
        ).then((value) => {
              KloudlessWidgetManager<ApplyMode, RequestModel>().syncCalendar(
                context: context,
                builder: KloudlessWidgetBuilder()
                    .fromContext<ApplyMode, RequestModel>(
                  context: context,
                  id: requestInvitationModel.requestModel.id,
                  model: requestInvitationModel.requestModel,
                ),
              )
            });
      },
      timestamp: notification.timestamp,
    );
  }

  static Widget _getNotificationCardForGoodsInvitationRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
    RequestInvitationModel requestInvitationModel,
  }) {
    return NotificationCard(
      entityName: requestInvitationModel.timebankModel.name,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      photoUrl: requestInvitationModel.timebankModel.photoUrl,
      subTitle:
          '${requestInvitationModel.timebankModel.name} ${S.of(context).goods_donation_invite}',
      title:
          "${requestInvitationModel.timebankModel.name} ${S.of(context).has_goods_donation}",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DonationView(
                requestModel: requestInvitationModel.requestModel,
                timabankName: requestInvitationModel.timebankModel.name,
                notificationId: notification.id,
              );
            },
          ),
        );
      },
      timestamp: notification.timestamp,
    );
  }

  static Widget _getNotificationCardForCashInvitationRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
    RequestInvitationModel requestInvitationModel,
  }) {
    return NotificationCard(
      entityName: requestInvitationModel.timebankModel.name,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      photoUrl: requestInvitationModel.timebankModel.photoUrl,
      subTitle:
          '${requestInvitationModel.timebankModel.name} ${S.of(context).cash_donation_invite}',
      title:
          "${requestInvitationModel.timebankModel.name} ${S.of(context).has_cash_donation}",
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DonationView(
            notificationId: notification.id,
            requestModel: requestInvitationModel.requestModel,
            timabankName: requestInvitationModel.timebankModel.name,
          );
        }));
      },
      timestamp: notification.timestamp,
    );
  }

  static Widget getNotificationForRequestAccept({
    NotificationsModel notification,
  }) {
    RequestModel model = RequestModel.fromMap(notification.data);

    return FutureBuilder<RequestModel>(
        future: RequestRepository.getRequestFutureById(model.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('Error request accept');
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }

          log('request type: ' + model.requestType.toString());

          return RequestAcceptedWidget(
            model: snapshot.data,
            userId: notification.senderUserId,
            notificationId: notification.id,
          );
        });
  }

  static Widget getNotificationForRecurringOffer({
    NotificationsModel notification,
    NotificationsBloc bloc,
    BuildContext context,
    UserModel user,
  }) {
    ReccuringOfferUpdated eventData =
        ReccuringOfferUpdated.fromMap(notification.data);
    return NotificationCard(
      timestamp: notification.timestamp,
      title: S.of(context).offer_updated,
      subTitle:
          "${S.of(context).notifications_signed_up_for} ***eventName ${S.of(context).on} ***eventDate. ${S.of(context).notifications_event_modification} "
              .replaceFirst('***eventName', eventData.eventName)
              .replaceFirst(
                  '***eventDate',
                  DateTime.fromMillisecondsSinceEpoch(
                    eventData.eventDate,
                  ).toString()),
      entityName: S.of(context).request_updated,
      photoUrl: eventData.photoUrl,
      onDismissed: () {
        onDismissed(
          bloc: bloc,
          notificationId: notification.id,
          userEmail: user.email,
        );
      },
    );
  }

  static Widget getNotificationForRecurringRequestUpdated({
    NotificationsModel notification,
    NotificationsBloc bloc,
    BuildContext context,
    UserModel user,
  }) {
    ReccuringRequestUpdated eventData =
        ReccuringRequestUpdated.fromMap(notification.data);
    return NotificationCard(
      timestamp: notification.timestamp,
      title: S.of(context).request_updated,
      subTitle:
          "${S.of(context).notifications_signed_up_for} ***eventName ${S.of(context).on} ***eventDate. ${S.of(context).notifications_event_modification} "
              .replaceFirst('***eventName', eventData.eventName)
              .replaceFirst(
                '***eventDate',
                DateTime.fromMillisecondsSinceEpoch(
                  eventData.eventDate,
                ).toString(),
              ),
      entityName: S.of(context).request_updated,
      photoUrl: eventData.photoUrl,
      onDismissed: () {
        onDismissed(
          bloc: bloc,
          notificationId: notification.id,
          userEmail: user.email,
        );
      },
    );
  }

  static Future<void> onDismissed({
    String notificationId,
    String userEmail,
    NotificationsBloc bloc,
  }) async {
    await bloc.clearNotification(
      notificationId: notificationId,
      email: userEmail,
    );
  }

  static Widget getNotificationForJoinRequest({
    NotificationsModel notification,
  }) {
    JoinRequestNotificationModel model =
        JoinRequestNotificationModel.fromMap(notification.data);
    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(notification.senderUserId),
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
                timestamp: notification.timestamp,
                entityName: user.fullname,
                title: S.of(context).notifications_join_request,
                isDissmissible: true,
                onDismissed: () {
                  NotificationsRepository.readUserNotification(
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
                    '${user.fullname.toLowerCase()} ${S.of(context).notifications_requested_join} ${model.timebankTitle}, ${S.of(context).notifications_tap_to_view} ',
              )
            : Container();
      },
    );
  }

  //

  static Widget _getNotificationCardForTimeInvitationRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
    RequestInvitationModel requestInvitationModel,
  }) {
    return NotificationCard(
      entityName: requestInvitationModel.timebankModel.name,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      photoUrl: requestInvitationModel.timebankModel.photoUrl,
      subTitle:
          '${requestInvitationModel.timebankModel.name} ${S.of(context).notifications_requested_join} ${requestInvitationModel.requestModel.title}, ${S.of(context).notifications_tap_to_view}',
      title: S.of(context).notifications_join_request,
      onPressed: () {
        // if (SevaCore.of(context).loggedInUser.calendarId == null) {
        //   _settingModalBottomSheet(context, requestInvitationModel,
        //       notification.timebankId, notification.id, user);
        // } else {}

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
        ).then((value) => {
              KloudlessWidgetManager<ApplyMode, RequestModel>().syncCalendar(
                context: context,
                builder: KloudlessWidgetBuilder()
                    .fromContext<ApplyMode, RequestModel>(
                  context: context,
                  id: requestInvitationModel.requestModel.id,
                  model: requestInvitationModel.requestModel,
                ),
              )
            });
      },
      timestamp: notification.timestamp,
    );
  }

  static Widget _getNotificationCardForOfferRequestInvitationRequest({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
    TimeOfferParticipantsModel timeOfferParticipantsModel,
  }) {
    return NotificationCard(
      entityName: timeOfferParticipantsModel.participantDetails.fullname,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      photoUrl: timeOfferParticipantsModel.participantDetails.photourl,
      subTitle: timeOfferParticipantsModel.participantDetails.fullname +
          S.of(context).invitation_accepted_subtitle,
      title: S.of(context).invitation_accepted,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return OfferJoinRequestDialog(
              offerId: timeOfferParticipantsModel.offerId,
              requestId: timeOfferParticipantsModel.requestId,
              requestStartDate: timeOfferParticipantsModel.requestStartDate,
              requestEndDate: timeOfferParticipantsModel.requestEndDate,
              requestTitle: timeOfferParticipantsModel.requestTitle,
              timeBankId: notification.timebankId,
              notificationId: notification.id,
              userModel: user,
              timeOfferParticipantsModel: timeOfferParticipantsModel,
            );
          },
        );
      },
      timestamp: notification.timestamp,
    );
  }
}

class PersonalNotificationsReducerForOffer {
  static Widget getNotificationFromOfferCreator({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    OfferModel model = OfferModel.fromMap(notification.data);
    return NotificationCard(
      isDissmissible: true,
      timestamp: notification.timestamp,
      entityName: model.fullName,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notification.id,
          user.email,
        );
      },
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (parentContext) => CreateOfferRequest(
              offer: model,
              timebankId: model.timebankId,
            ),
          ),
        );
      },
      photoUrl: model.photoUrlImage ?? defaultUserImageURL,
      subTitle:
          model.fullName + S.of(context).offer_invitation_notification_subtitle,
      title: S.of(context).offer_invitation_notification_title,
    );
  }

  static Widget getNotificationForLendingOfferAccept({
    NotificationsModel notification,
  }) {
    var model = OfferModel.fromMap(notification.data);

    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(notification.senderUserId),
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
                timestamp: notification.timestamp,
                entityName: 'NAME',
                isDissmissible: true,
                onPressed: () async {
                  //Implemented by lending offer team
                  LendingOfferAcceptorModel lendingOfferAcceptorModel =
                      await LendingOffersRepo.getBorrowAcceptorModel(
                          offerId: model.id, acceptorEmail: user.email);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // fullscreenDialog: true,
                      builder: (context) => ApproveLendingOffer(
                        offerModel: model,
                        lendingOfferAcceptorModel: lendingOfferAcceptorModel,
                      ),
                    ),
                  );
                },
                photoUrl: notification.senderPhotoUrl ?? defaultUserImageURL,
                title: '${model.individualOfferDataModel.title}',
                subTitle:
                    "${user.fullname} ${S.of(context).accepted} ${model.individualOfferDataModel.title}",
                onDismissed: () {
                  NotificationsRepository.readUserNotification(
                    notification.id,
                    notification.targetUserId,
                  );
                },
              )
            : Container();
      },
    );
  }
}

class PersonalNotificationsRedcerForDonations {
  static Widget getWidgetNotificationForAcknowlegeDonorDonation({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    DonationModel donationModel = DonationModel.fromMap(notification.data);
    return FutureBuilder<double>(
        future: donationModel.requestIdType == 'offer'
            ? currencyConversion(
                fromCurrency:
                    donationModel.cashDetails.cashDetails.offerCurrencyType,
                toCurrency: donationModel
                    .cashDetails.cashDetails.offerDonatedCurrencyType,
                amount: donationModel.cashDetails.pledgedAmount)
            : currencyConversion(
                fromCurrency: donationModel
                    .cashDetails.cashDetails.requestDonatedCurrency,
                toCurrency:
                    donationModel.cashDetails.cashDetails.requestCurrencyType,
                amount: donationModel.cashDetails.pledgedAmount),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              S.of(context).error_loading_data,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Transform.scale(
              scale: 0.5,
              child: LoadingIndicator(),
            );
          }
          double amount = snapshot.data;
          return NotificationCard(
            isDissmissible: false,
            timestamp: notification.timestamp,
            entityName: donationModel.requestTitle.toLowerCase(),
            onDismissed: () {
              NotificationsRepository.readUserNotification(
                notification.id,
                user.email,
              );
            },
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RequestDonationDisputePage(
                    convertedAmount: amount,
                    currency: donationModel.requestIdType == 'offer'
                        ? donationModel
                            .cashDetails.cashDetails.offerDonatedCurrencyType
                        : donationModel
                            .cashDetails.cashDetails.requestCurrencyType,
                    notificationId: notification.id,
                    model: donationModel,
                  ),
                ),
              );
            },
            photoUrl: donationModel.donorDetails.photoUrl,
            subTitle:
                "${donationModel.donorDetails.name} ${S.of(context).pledged_to_donate} ${donationModel.donationType == RequestType.CASH ? "${donationModel.requestIdType == 'offer' ? donationModel.cashDetails.cashDetails.offerDonatedCurrencyType : donationModel.cashDetails.cashDetails.requestCurrencyType} ${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
            title: S.of(context).donations_received,
          );
        });
  }

  static Widget getWidgetNotificationForOfferRequestGoods({
    NotificationsModel notification,
    UserModel user,
    BuildContext context,
  }) {
    DonationModel donationModel = DonationModel.fromMap(notification.data);
    return FutureBuilder<double>(
        future: currencyConversion(
            fromCurrency:
                donationModel.cashDetails.cashDetails.offerDonatedCurrencyType,
            toCurrency: donationModel.cashDetails.cashDetails.offerCurrencyType,
            amount: donationModel.cashDetails.cashDetails.amountRaised),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(
              S.of(context).error_loading_data,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Transform.scale(
              scale: 0.5,
              child: LoadingIndicator(),
            );
          }

          double amount;
          if (donationModel.requestIdType == 'offer' &&
              donationModel.donationStatus == DonationStatus.REQUESTED) {
            amount = snapshot.data;
          } else {
            amount = donationModel.cashDetails.pledgedAmount;
          }
          return NotificationCard(
            isDissmissible: false,
            timestamp: notification.timestamp,
            entityName: donationModel.requestTitle.toLowerCase(),
            onDismissed: () {
              NotificationsRepository.readUserNotification(
                notification.id,
                user.email,
              );
            },
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RequestDonationDisputePage(
                    notificationId: notification.id,
                    model: donationModel,
                    convertedAmountRaised: amount,
                    currency:
                        donationModel.cashDetails.cashDetails.offerCurrencyType,
                  ),
                ),
              );
            },
            photoUrl: donationModel.receiverDetails.photoUrl,
            subTitle:
                "${donationModel.receiverDetails.name} ${S.of(context).requested.toLowerCase()} ${donationModel.donationType == RequestType.CASH ? "${donationModel.cashDetails.cashDetails.offerCurrencyType} ${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
            title: S.of(context).donations_requested,
          );
        });
  }

  static Widget getWidgetForDonationsModifiedByDonor({
    Function onDismissed,
    BuildContext context,
    NotificationsModel notificationsModel,
  }) {
    final holder = DonationModel.fromMap(notificationsModel.data);
    bool invertGoodsLabel = false;
    if (holder.donationType == RequestType.GOODS &&
        holder.requestIdType == 'offer' &&
        holder.donorDetails.email != SevaCore.of(context).loggedInUser.email) {
      invertGoodsLabel = true;
    }
    double amount;
    return NotificationCard(
      isDissmissible: false,
      photoUrl: holder.donorDetails.photoUrl ?? defaultUserImageURL,
      entityName: holder.donationType == RequestType.CASH
          ? S.of(context).pledge_modified_by_donor
          : invertGoodsLabel
              ? holder.donorDetails.name + S.of(context).pledge_goods_supplies
              : S.of(context).goods_modified_by_donor,
      title: holder.donationType == RequestType.CASH
          ? S.of(context).pledge_modified_by_donor
          : invertGoodsLabel
              ? S.of(context).acknowledge
              : S.of(context).goods_modified_by_donor,
      subTitle: holder.donationType == RequestType.CASH
          ? S.of(context).amount_modified_by_donor_desc
          : invertGoodsLabel
              ? holder.donorDetails.name + S.of(context).pledge_goods_supplies
              : S.of(context).goods_modified_by_donor_desc,
      onDismissed: onDismissed,
      onPressed: () async {
        if (holder.donationType == RequestType.CASH) {
          amount = await currencyConversion(
              fromCurrency: holder.cashDetails.cashDetails.offerCurrencyType,
              toCurrency:
                  holder.cashDetails.cashDetails.offerDonatedCurrencyType,
              amount: holder.cashDetails.pledgedAmount);
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              convertedAmount: holder.requestIdType == 'offer'
                  ? amount
                  : holder.cashDetails.pledgedAmount,
              currency: holder.requestIdType == 'offer'
                  ? holder.cashDetails.cashDetails.offerDonatedCurrencyType
                  : holder.cashDetails.cashDetails.requestCurrencyType,
              notificationId: notificationsModel.id,
              model: holder,
            ),
          ),
        );
      },
      timestamp: notificationsModel.timestamp,
    );
  }

  static Widget getWidgetForSuccessfullDonation(
      {Function onDismissed,
      Function onTap,
      int timestampVal,
      BuildContext context}) {
    return NotificationCard(
      entityName: S.of(context).donation_completed,
      title: S.of(context).donation_completed,
      subTitle: S.of(context).donation_completed_desc,
      onDismissed: onDismissed,
      onPressed: onTap,
      timestamp: timestampVal,
    );
  }

  static getWidgetForDonationsModifiedByCreator({
    Function onDismissed,
    BuildContext context,
    NotificationsModel notificationsModel,
    int timestampVal,
  }) {
    final holder = DonationModel.fromMap(notificationsModel.data);
    double amount;
    return NotificationCard(
      isDissmissible: false,
      photoUrl: holder.donationAssociatedTimebankDetails.timebankPhotoURL ??
          defaultGroupImageURL,
      entityName: holder.donationType == RequestType.CASH
          ? S.of(context).pledge_modified
          : S.of(context).goods_modified_by_creator,
      title: holder.donationType == RequestType.CASH
          ? S.of(context).pledge_modified
          : S.of(context).goods_modified_by_creator,
      subTitle: holder.donationType == RequestType.CASH
          ? S.of(context).amount_modified_by_creator_desc
          : S.of(context).goods_modified_by_creator_desc,
      onDismissed: onDismissed,
      onPressed: () async {
        if (holder.donationType == RequestType.CASH) {
/*          progressDialog = ProgressDialog(context,
              customBody: Container(
                height: 100,
                width: 100,
                child: LoadingIndicator(),
              ));*/
          // progressDialog.show();
          // progressDialog.hide();
          amount = await currencyConversion(
              fromCurrency: holder.requestIdType == 'offer'
                  ? holder.cashDetails.cashDetails.offerDonatedCurrencyType
                  : holder.cashDetails.cashDetails.requestCurrencyType,
              toCurrency: holder.requestIdType == 'offer'
                  ? holder.cashDetails.cashDetails.offerCurrencyType
                  : holder.cashDetails.cashDetails.requestDonatedCurrency,
              amount: holder.cashDetails.pledgedAmount);
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              convertedAmount: holder.requestIdType == 'offer'
                  ? holder.cashDetails.pledgedAmount
                  : amount,
              currency: holder.requestIdType == 'offer'
                  ? holder.cashDetails.cashDetails.offerCurrencyType
                  : holder.cashDetails.cashDetails.requestDonatedCurrency,
              notificationId: notificationsModel.id,
              model: holder,
            ),
          ),
        );
      },
      timestamp: timestampVal,
    );
  }
}
