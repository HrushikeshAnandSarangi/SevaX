import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/change_ownership_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/change_ownership_dialog.dart';

class ChangeOwnershipWidget extends StatelessWidget {
  final ChangeOwnershipModel changeOwnershipModel;
  final NotificationsModel notificationsModel;
  final String notificationId;
  final BuildContext buildContext;
  final String timebankId;
  final String communityId;

  const ChangeOwnershipWidget(
      {Key key,
      this.changeOwnershipModel,
      this.notificationsModel,
      this.notificationId,
      this.buildContext,
      this.timebankId,
      this.communityId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
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
              loggedInUser: SevaCore.of(context).loggedInUser,
              parentContext: context,
            );
          },
        );
      },
      photoUrl: changeOwnershipModel.creatorPhotoUrl,
      title: AppLocalizations.of(context)
          .translate('change_ownership', 'change_ownership_title'),
      subTitle:
          '${changeOwnershipModel.creatorName.toLowerCase()} ${AppLocalizations.of(context).translate('change_ownership', 'notification_msg')} ${changeOwnershipModel.timebank.toLowerCase().replaceAll("timebank", "")} ${AppLocalizations.of(context).translate('members', 'timebank')}',
    );
  }
}
