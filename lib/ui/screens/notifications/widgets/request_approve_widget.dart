import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';

class RequestApproveWidget extends StatelessWidget {
  final RequestModel? model;
  final String? userId;
  final String? notificationId;

  const RequestApproveWidget(
      {Key? key, this.model, this.userId, this.notificationId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email!;
        NotificationsRepository.readUserNotification(
            notificationId!, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model!.title!),
          leading: CircleAvatar(
              backgroundImage: model!.photoUrl != null
                  ? NetworkImage(model!.photoUrl!)
                  : AssetImage("lib/assets/images/approved.png")!
                      as ImageProvider),
          subtitle: Text(
              '${S.of(context).notifications_approved_by} ${model!.fullName}'),
        ),
      ),
    );
  }
}
