import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class ChangeOwnershipWidget extends StatelessWidget {
  final int timestamp;
  final ChangeOwnershipModel changeOwnershipModel;
  final NotificationsModel notificationsModel;
  final String notificationId;
  final BuildContext buildContext;
  final String timebankId;
  final String communityId;

  const ChangeOwnershipWidget(
      {Key? key,
      required this.timestamp,
      required this.changeOwnershipModel,
      required this.notificationsModel,
      required this.notificationId,
      required this.buildContext,
      required this.timebankId,
      required this.communityId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      timestamp: timestamp,
      entityName: changeOwnershipModel.creatorName!,
      isDissmissible: true,
      onDismissed: () {
        FirestoreManager.readUserNotification(
          notificationId,
          SevaCore.of(context).loggedInUser.email!,
        );
      },
      onPressed: () {
        // showDialog(
        //   context: context,
        //   builder: (mContext) {
        //     return ChangeOwnershipDialog(
        //       changeOwnershipModel: changeOwnershipModel,
        //       timeBankId: timebankId,
        //       notificationId: notificationId,
        //       notificationModel: notificationsModel,
        //       loggedInUser: SevaCore.of(context).loggedInUser,
        //       parentContext: context,
        //     );
        //   },
        // );
      },
      photoUrl: changeOwnershipModel.creatorPhotoUrl!,
      title: S.of(context).change_ownership,
      subTitle:
          '${changeOwnershipModel.creatorName!.toLowerCase()} ${S.of(context).change_ownership_invite} ${changeOwnershipModel.timebank!.toLowerCase().replaceAll("timebank", "")} ${S.of(context).timebank}',
    );
  }
}
