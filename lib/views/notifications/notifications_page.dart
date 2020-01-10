import 'package:flutter/material.dart';
import 'package:sevaexchange/views/notifications/notifications_view.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.black),
          )),
      body: NotificationViewHolder(),
    );
  }
}
