import 'package:flutter/material.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/join_request_view.dart';

class JoinRequestWidget extends StatelessWidget {
  final UserModel user;
  final String notificationId;
  final JoinRequestNotificationModel model;

  const JoinRequestWidget({Key key, this.user, this.notificationId, this.model})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
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
              ),
            ),
          );
        },
      ),
    );
  }
}
