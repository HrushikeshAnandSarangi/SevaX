import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/manual_time_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/reported_member_notification_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/reducer.dart';
import 'package:sevaexchange/ui/screens/notifications/pages/personal_notifications.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/manual_time_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/sponser_group_request_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_join_request_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_complete_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_widget.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_member_insufficent_credits_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_user_exit_dialog.dart';

class TimebankNotifications extends StatefulWidget {
  final TimebankModel timebankModel;
  final ScrollPhysics physics;

  const TimebankNotifications({Key key, this.timebankModel, this.physics})
      : super(key: key);
  @override
  _TimebankNotificationsState createState() => _TimebankNotificationsState();
}

class _TimebankNotificationsState extends State<TimebankNotifications> {
  BuildContext parentContext;
  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final _bloc = BlocProvider.of<NotificationsBloc>(context);
    return StreamBuilder(
      stream: _bloc.timebankNotifications,
      builder: (_, AsyncSnapshot<TimebankNotificationData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return LoadingIndicator();
        }

        List<NotificationsModel> notifications =
            snapshot.data.notifications[widget.timebankModel.id] ?? [];

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
            double creditsNeeded = 10;
            NotificationsModel notification = notifications.elementAt(index);
            switch (notification.type) {
              case NotificationType.TYPE_MEMBER_HAS_INSUFFICENT_CREDITS:
                UserExitModel userExitModel =
                    UserExitModel.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  title: "${userExitModel.userName}" " Has Insufficient Credits To Create Requests",
                  subTitle: "Credits Needed: " "${creditsNeeded} \n${S.of(context).tap_to_view_details}",
                  photoUrl: userExitModel.userPhotoUrl,
                  entityName: userExitModel.userName,
                  onPressed: (){
                      showDialog(
                      context: context,
                      builder: (_context) {
                        return TimebankUserInsufficientCreditsDialog(
                          userExitModel: userExitModel,
                          timeBankId: notification.timebankId,
                          notificationId: notification.id,
                          userModel: SevaCore.of(context).loggedInUser,
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
                    UserAddedModel.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
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
                      '**communityName**', userAddedModel.timebankName),
                  subTitle: S
                      .of(context)
                      .member_joined_via_code_subtitle
                      .replaceAll(
                          '**communityName**', userAddedModel.timebankName)
                      .replaceAll(
                          '**fullName**', userAddedModel.addedMemberName),
                );
                break;
              case NotificationType.RequestAccept:
                RequestModel model = RequestModel.fromMap(notification.data);
                return TimebankRequestWidget(
                  model: model,
                  notification: notification,
                );
                break;
              case NotificationType.ACKNOWLEDGE_DONOR_DONATION:
                DonationModel donationModel =
                    DonationModel.fromMap(notification.data);
                var amount;
                if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.REQUESTED) {
                  amount = donationModel.cashDetails.cashDetails.amountRaised;
                } else if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.PLEDGED) {
                  donationModel.notificationId = notification.id;
                } else {
                  amount = donationModel.cashDetails.pledgedAmount;
                }
                return NotificationCard(
                  timestamp: notification.timestamp,
                  entityName: donationModel.donorDetails.name,
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
                            notificationId: notification.id,
                          );
                        },
                      ),
                    );
                  },
                  photoUrl: donationModel.donorDetails.photoUrl,
                  subTitle:
                      "${donationModel.donorDetails.name}  ${S.of(context).pledged_to_donate} ${donationModel.donationType == RequestType.CASH ? "\$${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
                  title: S.of(context).donations_received,
                );
                break;
              case NotificationType.GOODS_DONATION_REQUEST:
                DonationModel donationModel =
                    DonationModel.fromMap(notification.data);
                var amount;
                if (donationModel.requestIdType == 'offer' &&
                    donationModel.donationStatus == DonationStatus.REQUESTED) {
                  amount = donationModel.cashDetails.cashDetails.amountRaised;
                } else {
                  amount = donationModel.cashDetails.pledgedAmount;
                }
                logger.i("==============<<<<<<<<<<<<<<<>>>>>>>>> $amount");
                return NotificationCard(
                  timestamp: notification.timestamp,
                  entityName: donationModel.donorDetails.name,
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
                            notificationId: notification.id,
                          );
                        },
                      ),
                    );
                  },
                  photoUrl: donationModel.donorDetails.photoUrl,
                  subTitle:
                      "${donationModel.donorDetails.name}  ${S.of(context).requested.toLowerCase()} ${donationModel.donationType == RequestType.CASH ? "\$${amount}" : "goods/supplies"}, ${S.of(context).tap_to_view_details}",
                  title: S.of(context).donations_requested,
                );
                break;

              case NotificationType.TypeMemberExitTimebank:
                UserExitModel userExitModel =
                    UserExitModel.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  title: S.of(context).timebank_exit,
                  subTitle:
                      '${userExitModel.userName.toLowerCase()} ${S.of(context).has_exited_from} ${userExitModel.timebank}, ${S.of(context).tap_to_view_details}',
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
                return TimebankJoinRequestWidget(notification: notification);

              case NotificationType.APPROVE_SPONSORED_GROUP_REQUEST:
                return SponsorGroupRequestWidget(notification: notification);
                break;

              case NotificationType.RequestCompleted:
                return TimebankRequestCompletedWidget(
                  notification: notification,
                  timebankModel: widget.timebankModel,
                  parentContext: parentContext,
                );

              case NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  title: S.of(context).notifications_debited,
                  subTitle:
                      TimebankNotificationMessage.DEBIT_FULFILMENT_FROM_TIMEBANK
                          .replaceFirst(
                            '*n',
                            (data.classDetails.numberOfClassHours +
                                    data.classDetails.numberOfPreperationHours)
                                .toString(),
                          )
                          .replaceFirst('*name', data.classDetails.classHost)
                          .replaceFirst('*class', data.classDetails.classTitle),
                  entityName: data.classDetails.classHost,
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
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  title: S.of(context).notifications_credited,
                  subTitle: TimebankNotificationMessage
                      .CREDIT_FROM_OFFER_APPROVED
                      .replaceFirst(
                          '*n', data.classDetails.numberOfClassHours.toString())
                      .replaceFirst('*class', data.classDetails.classTitle),
                  // photoUrl: data.participantDetails.photourl,
                  entityName: data.participantDetails.fullname,
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
                    SoftDeleteRequestDataHolder.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  entityName: requestData.entityTitle ?? "Deletion Request",
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
                    ReportedMemberNotificationModel.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
                  title: S.of(context).member_reported_title,
                  subTitle: TimebankNotificationMessage.MEMBER_REPORT
                      .replaceFirst('*name', data.reportedUserName),
                  photoUrl: data.reportedUserImage,
                  entityName: data.reportedUserName,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );

              case NotificationType.APPROVED_MEMBER_WITHDRAWING_REQUEST:
                var body = WithdrawnRequestBody.fromMap(notification.data);
                return NotificationCard(
                  timestamp: notification.timestamp,
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
                return PersonalNotificationsRedcerForDonations
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
                  timestamp: notification.timestamp,
                  title: S.of(context).seva_coins_debited,
                  subTitle: S.of(context).seva_coins_debited,
                  photoUrl: null,
                  entityName: S.of(context).debited,
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
                  },
                );

              case NotificationType.MANUAL_TIME_CLAIM:
                var body = ManualTimeModel.fromMap(
                    Map<String, dynamic>.from(notification.data));

                return NotificationCard(
                  timestamp: notification.timestamp,
                  entityName: body.userDetails.name,
                  photoUrl: body.userDetails.photoUrl,
                  title: S.of(context).manual_notification_title,
                  subTitle: S
                      .of(context)
                      .manual_notification_subtitle
                      .replaceAll('**name', body.userDetails.name)
                      .replaceAll('**number', '${body.claimedTime / 60}')
                      .replaceAll('**communityName', body.communityName ?? ' '),
                  isDissmissible: false,
                  onPressed: () {
                    manualTimeActionDialog(
                      context,
                      notification.id,
                      notification.timebankId,
                      body,
                    );
                  },
                );

              default:
                log("Unhandled timebank notification type ${notification.type} ${notification.id}");
                Crashlytics().log(
                    "Unhandled timebank notification type ${notification.type} ${notification.id}");
                return Container();
                break;
            }
          },
        );
      },
    );
  }
}
