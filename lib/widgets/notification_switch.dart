import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationWidgetSwitch extends StatefulWidget {
  final bool isTurnedOn;
  final String title;
  final Function onPressed;
  NotificationWidgetSwitch({
    Key key,
    this.isTurnedOn,
    this.title,
    this.onPressed,
  }) : super(key: key);

  @override
  _NotificationWidgetSwitchState createState() =>
      _NotificationWidgetSwitchState();

  static void updateNotificationFormAdmin({
    String timebankId,
    String adminSevaUserId,
    String notificationType,
    bool status,
  }) {
    Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .updateData(
      {
        'notificationSetting.$adminSevaUserId.$notificationType': status,
      },
    );
  }

  static void updatePersonalNotifications({
    String userEmail,
    String notificationType,
    bool status,
  }) {
    Firestore.instance.collection('users').document(userEmail).updateData(
      {
        'notificationSetting.$notificationType': status,
      },
    );
  }
}

class _NotificationWidgetSwitchState extends State<NotificationWidgetSwitch> {
  bool switchStatus;

  @override
  void initState() {
    super.initState();
    switchStatus = widget.isTurnedOn;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
      title: Text(
        widget.title,
        style: TextStyle(
          fontFamily: 'Europa',
          // fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Transform(
          transform: Matrix4.diagonal3Values(0.9, 0.9, 0),
          child: CupertinoSwitch(
            activeColor: Theme.of(context).primaryColor,
            value: switchStatus,
            onChanged: (value) {
              switchStatus = value;
              widget.onPressed(value);
              setState(() {});
            },
          ),
        ),
      ),
            )
          ],
        ),
    );
  }
}
