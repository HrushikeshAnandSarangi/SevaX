import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavor_config.dart';

class PersonalNotificationReducerForRequests {
  static void _settingModalBottomSheet(
      BuildContext context,
      RequestInvitationModel requestInvitationModel,
      String timebankId,
      String id,
      UserModel user) {
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
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
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
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child:
                                Image.asset("lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
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
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset("lib/assets/images/ical.png"),
                          ),
                          onTap: () async {
                            String redirectUrl =
                                "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl =
                                "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
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
                          })
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
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

      default:
        return _getNotificationCardForTimeInvitationRequest(
          notification: notification,
          user: user,
          context: context,
          requestInvitationModel: requestInvitationModel,
        );
    }
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
      title: S.of(context).has_goods_donation,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return DonationView(
                requestModel: requestInvitationModel.requestModel,
                timabankName: requestInvitationModel.timebankModel.name,
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
      title: S.of(context).has_cash_donation,
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return DonationView(
            requestModel: requestInvitationModel.requestModel,
            timabankName: requestInvitationModel.timebankModel.name,
          );
        }));

        // if (SevaCore.of(context).loggedInUser.calendarId == null) {
        //   _settingModalBottomSheet(context, requestInvitationModel,
        //       notification.timebankId, notification.id, user);
        // } else {
        //   showDialog(
        //     context: context,
        //     builder: (context) {
        //       return JoinRejectDialogView(
        //         requestInvitationModel: requestInvitationModel,
        //         timeBankId: notification.timebankId,
        //         notificationId: notification.id,
        //         userModel: user,
        //       );
        //     },
        //   );
        // }
      },
      timestamp: notification.timestamp,
    );
  }

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
        if (SevaCore.of(context).loggedInUser.calendarId == null) {
          _settingModalBottomSheet(context, requestInvitationModel,
              notification.timebankId, notification.id, user);
        } else {
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
        }
      },
      timestamp: notification.timestamp,
    );
  }
}

class PersonalNotificationsRedcerForDonations {
  static Widget getWidgetForDonationsModifiedByDonor({
    Function onDismissed,
    BuildContext context,
    NotificationsModel notificationsModel,
    int timestampVal,
  }) {
    final holder = DonationModel.fromMap(notificationsModel.data);

    return NotificationCard(
      entityName: S.of(context).pledge_modified_by_donor,
      title: S.of(context).tap_to_view_details,
      subTitle: "${S.of(context).pledge_modified_by_donor}",
      onDismissed: onDismissed,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              model: holder,
            ),
          ),
        );
      },
      timestamp: timestampVal,
    );
  }

  static Widget getWidgetForSuccessfullDonation(
      {Function onDismissed, int timestampVal, BuildContext context}) {
    return NotificationCard(
      entityName: S.of(context).donation_completed,
      title: S.of(context).donation_completed,
      subTitle: "${S.of(context).donation_completed_desc}",
      onDismissed: onDismissed,
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

    return NotificationCard(
      entityName: S.of(context).pledge_modified,
      title: S.of(context).tap_to_view_details,
      subTitle: "${S.of(context).pledge_modified}",
      onDismissed: onDismissed,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestDonationDisputePage(
              model: holder,
            ),
          ),
        );
      },
      timestamp: timestampVal,
    );
  }
}
