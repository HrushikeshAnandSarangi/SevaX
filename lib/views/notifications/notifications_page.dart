import 'package:flutter/material.dart';
import 'package:sevaexchange/views/notifications/notifications_view.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          )),
      body: NotificationsView(),
    );
  }
}
