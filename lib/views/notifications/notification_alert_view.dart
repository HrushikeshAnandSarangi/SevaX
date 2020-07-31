import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import 'package:sevaexchange/widgets/notification_switch.dart';

class NotificationAlert extends StatefulWidget {
  final String sevaUserId;

  NotificationAlert(this.sevaUserId);

  @override
  _NotificationAlertState createState() => _NotificationAlertState();
}

class _NotificationAlertState extends State<NotificationAlert> {
  bool isTurnedOn = false;
  final _firestore = Firestore.instance;
  Stream settingsStreamer;
  Map<dynamic, dynamic> notificationSetting;
  @override
  void initState() {
    super.initState();
    settingsStreamer =
        FirestoreManager.getUserDetails(userId: widget.sevaUserId);
  }

  bool getCurrentStatus(String key) {
    if (notificationSetting != null) {
      return notificationSetting.containsKey(key)
          ? notificationSetting[key]
          : true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('profile', 'notifications'),
          style: TextStyle(fontFamily: 'Europa', fontSize: 18),
        ),
      ),
      body: StreamBuilder<UserModel>(
          stream: settingsStreamer,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LoadingIndicator();
            }
            notificationSetting = snapshot.data.notificationSetting;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                NotificationWidgetSwitch(
                  isTurnedOn: getCurrentStatus('RequestAccept'),
                  title: AppLocalizations.of(context)
                      .translate('external_notifications', 'request_accepted'),
                  onPressed: (bool status) {
                    NotificationWidgetSwitch.updatePersonalNotifications(
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      notificationType: 'RequestAccept',
                      status: status,
                    );
                  },
                ),
                lineDivider,
                NotificationWidgetSwitch(
                  isTurnedOn: getCurrentStatus('RequestCompleted'),
                  title: AppLocalizations.of(context)
                      .translate('external_notifications', 'request_completed'),
                  onPressed: (bool status) {
                    NotificationWidgetSwitch.updatePersonalNotifications(
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      notificationType: 'RequestCompleted',
                      status: status,
                    );
                  },
                ),
                lineDivider,
                NotificationWidgetSwitch(
                  isTurnedOn: getCurrentStatus('TYPE_DEBIT_FROM_OFFER'),
                  title: AppLocalizations.of(context)
                      .translate('external_notifications', 'offer_debit'),
                  onPressed: (bool status) {
                    NotificationWidgetSwitch.updatePersonalNotifications(
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      notificationType: 'TYPE_DEBIT_FROM_OFFER',
                      status: status,
                    );
                  },
                ),
                NotificationWidgetSwitch(
                  isTurnedOn: getCurrentStatus(
                      'TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK'),
                  title: AppLocalizations.of(context)
                      .translate('external_notifications', 'credit_request'),
                  onPressed: (bool status) {
                    NotificationWidgetSwitch.updatePersonalNotifications(
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      notificationType:
                          'TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK',
                      status: status,
                    );
                  },
                ),
                lineDivider,
                NotificationWidgetSwitch(
                  isTurnedOn:
                      getCurrentStatus('TYPE_FEEDBACK_FROM_SIGNUP_MEMBER'),
                  title: "Feedback for one to many offer",
                  onPressed: (bool status) {
                    NotificationWidgetSwitch.updatePersonalNotifications(
                      userEmail: SevaCore.of(context).loggedInUser.email,
                      notificationType: 'TYPE_FEEDBACK_FROM_SIGNUP_MEMBER',
                      status: status,
                    );
                  },
                ),
                lineDivider
              ],
            );
          }),
    );
  }

  Widget get lineDivider {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      height: 1,
      color: Color.fromARGB(100, 233, 233, 233),
    );
  }
}
