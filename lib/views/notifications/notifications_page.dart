import 'package:flutter/material.dart';
import 'package:sevaexchange/views/notifications/notifications_view.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: NotificationViewHolder(),
    );
  }
}
