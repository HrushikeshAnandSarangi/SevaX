import 'package:flutter/material.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart';

class GetActiveTimebankNotifications extends StatelessWidget {
  final String timebankId;

  const GetActiveTimebankNotifications({Key key, this.timebankId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationsModel>>(
      stream: getNotificationsForTimebank(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Icon(
            Icons.notifications_none,
            color: Colors.black,
          );
        }

        List<NotificationsModel> notifications = snapshot.data;

        notifications.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (notifications.length > 0) {
          return Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Icon(Icons.notifications_active, color: Colors.red),
                ),
                Text(
                  "${notifications == null ? 0 : notifications.length}",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Icon(
            Icons.notifications_none,
            color: Colors.black,
          );
        }
      },
    );
  }
}
