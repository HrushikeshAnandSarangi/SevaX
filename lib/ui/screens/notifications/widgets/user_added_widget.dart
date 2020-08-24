import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';

class UserAddedWidget extends StatelessWidget {
  final UserAddedModel userAddedModel;
  final String notificationId;
  final BuildContext buildContext;
  final String timebankId;
  final String communityId;

  const UserAddedWidget(
      {Key key,
      this.userAddedModel,
      this.notificationId,
      this.buildContext,
      this.timebankId,
      this.communityId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NotificationCard(
      entityName: userAddedModel.adminName,
      isDissmissible: true,
      onDismissed: () {
        NotificationsRepository.readUserNotification(
          notificationId,
          SevaCore.of(context).loggedInUser.email,
        );
      },
      onPressed: null,
      photoUrl: userAddedModel.timebankImage,
      title: S.of(context).notification_timebank_join,
      subTitle:
          '${userAddedModel.adminName.toLowerCase()} ${S.of(context).notifications_added_you} ${userAddedModel.timebankName} ${S.of(context).timebank}',
    );
  }
}
