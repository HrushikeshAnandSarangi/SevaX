import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
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
  Stream<UserModel>? settingsStreamer;
  Map<dynamic, dynamic>? notificationSetting;
  @override
  void initState() {
    super.initState();
    settingsStreamer =
        FirestoreManager.getUserDetails(userId: widget.sevaUserId)
            as Stream<UserModel>;
  }

  bool getCurrentStatus(String key) {
    if (notificationSetting != null) {
      return notificationSetting!.containsKey(key)
          ? notificationSetting![key]
          : true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).notification_alerts,
          style: TextStyle(fontFamily: 'Europa', fontSize: 18),
        ),
      ),
      body: StreamBuilder<UserModel>(
          stream: settingsStreamer!,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LoadingIndicator();
            }
            notificationSetting = snapshot.data!.notificationSetting;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('RequestAccept'),
                    title: S.of(context).request_accepted,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'RequestAccept',
                        status: status,
                      );
                    },
                  ),
                  lineDivider,
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('RequestCompleted'),
                    title: S.of(context).request_completed,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'RequestCompleted',
                        status: status,
                      );
                    },
                  ),
                  lineDivider,
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('TYPE_DEBIT_FROM_OFFER'),
                    title: S.of(context).offer_debit,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'TYPE_DEBIT_FROM_OFFER',
                        status: status,
                      );
                    },
                  ),
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus(
                        'TYPE_CREDIT_NOTIFICATION_FROM_TIMEBANK'),
                    title: S.of(context).recieved_credits_one_to_many,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
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
                    title: S.of(context).feedback_one_to_many_offer,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'TYPE_FEEDBACK_FROM_SIGNUP_MEMBER',
                        status: status,
                      );
                    },
                  ),
                  lineDivider,
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('MEMBER_PROMOTED_AS_ADMIN'),
                    title: S.of(context).promotion_to_admin_from_member,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'MEMBER_PROMOTED_AS_ADMIN',
                        status: status,
                      );
                    },
                  ),
                  lineDivider,
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('MEMBER_DEMOTED_FROM_ADMIN'),
                    title: S.of(context).demotion_from_admin_to_member,
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'MEMBER_DEMOTED_FROM_ADMIN',
                        status: status,
                      );
                    },
                  ),

                  //messages
                  lineDivider,
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('TYPE_MESSAGING_NOTIFICATION'),
                    title: "${S.of(context).notification_for_new_messages}.",
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'TYPE_MESSAGING_NOTIFICATION',
                        status: status,
                      );
                    },
                  ),

                  lineDivider,
                  //feeds
                  NotificationWidgetSwitch(
                    isTurnedOn: getCurrentStatus('TYPE_FEEDS_NOTIFICATION'),
                    title: "${S.of(context).feeds_notification_text}",
                    onPressed: (bool status) {
                      NotificationWidgetSwitch.updatePersonalNotifications(
                        userEmail: SevaCore.of(context).loggedInUser.email!,
                        notificationType: 'TYPE_FEEDS_NOTIFICATION',
                        status: status,
                      );
                    },
                  ),
                ],
              ),
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
