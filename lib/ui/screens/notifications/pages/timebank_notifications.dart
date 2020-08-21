import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/reported_member_notification_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/bloc/notifications_bloc.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_join_request_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_complete_widget.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/timebank_request_widget.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/views/requests/donations/approve_donation_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
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
            NotificationsModel notification = notifications.elementAt(index);
            switch (notification.type) {
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

                return NotificationCard(
                  entityName: donationModel.donorDetails.name,
                  isDissmissible: true,
                  onDismissed: () {
                    FirestoreManager.readTimeBankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return RequestDonationDisputePage(
                            model: donationModel,
                          );
                        },
                      ),
                    );
                  },
                  photoUrl: donationModel.donorDetails.photoUrl,
                  subTitle:
                      '${donationModel.donorDetails.name + ' ${S.of(context).donated} ' + donationModel.donationType.toString().split('.')[1]}, ${S.of(context).tap_to_view_details}',
                  title: S.of(context).donation_acknowledge,
                );
                break;

              case NotificationType.TypeMemberExitTimebank:
                UserExitModel userExitModel =
                    UserExitModel.fromMap(notification.data);
                return NotificationCard(
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
                      builder: (context) {
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
                break;

              case NotificationType.RequestCompleted:
                return TimebankRequestCompletedWidget(
                  notification: notification,
                  timebankModel: widget.timebankModel,
                );
                break;

              case NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
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
                  entityName: requestData.entityTitle ?? "Deletion Request",
                  photoUrl: null,
                  title: requestData.requestAccepted
                      ? "${requestData.entityTitle} was deleted!"
                      : "${requestData.entityTitle} cannot be deleted!",
                  subTitle: requestData.requestAccepted
                      ? "${requestData.entityTitle} you requested to delete has been successfully deleted!"
                      : "Your request to delete ${requestData.entityTitle} cannot be completed at this time. There are pending transactions. Tap here to view the details:",
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
                  title: "Member Reported",
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

              case NotificationType.DEBITED_SEVA_COINS_TIMEBANK:
                return NotificationCard(
                  title: "Seva Coins debited",
                  subTitle: "Seva coins debited",
                  photoUrl: null,
                  entityName: "Debited",
                  onDismissed: () {
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
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
