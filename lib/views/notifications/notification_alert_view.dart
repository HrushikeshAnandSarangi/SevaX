import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/views/core.dart';

class NotificationAlert extends StatefulWidget {
  @override
  _NotificationAlertState createState() => _NotificationAlertState();
}

class _NotificationAlertState extends State<NotificationAlert> {
  bool isTurnedOn = false;
  final _firestore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)
              .translate('notifications', 'notification_alert'),
          style: TextStyle(fontFamily: 'Europa', fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(
              AppLocalizations.of(context)
                  .translate('notifications', 'turn_on_notification'),
              style: TextStyle(
                fontFamily: 'Europa',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Transform.scale(
              scale: 0.8,
              child: Transform(
                transform: Matrix4.diagonal3Values(0.9, 0.9, 0),
                child: CupertinoSwitch(
                  activeColor: Theme.of(context).primaryColor,
                  value: SevaCore.of(context).loggedInUser.notificationAlerts,
                  onChanged: (value) {
                    setState(() {
                      isTurnedOn = value;
                      SevaCore.of(context).loggedInUser.notificationAlerts =
                          value;
                      _firestore
                          .collection('users')
                          .document(SevaCore.of(context).loggedInUser.email)
                          .updateData({'notificationAlerts': value});
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
