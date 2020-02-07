import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/notification_message.dart';

class TimeBankNotificationView extends StatefulWidget {
  final String timebankId;

  const TimeBankNotificationView({Key key, this.timebankId}) : super(key: key);
  @override
  _TimeBankNotificationViewState createState() =>
      _TimeBankNotificationViewState();
}

class _TimeBankNotificationViewState extends State<TimeBankNotificationView>
    with AutomaticKeepAliveClientMixin {
  List<NotificationsModel> notifications;
  Map<String, UserModel> users = {};

  @override
  void initState() {
    super.initState();
    Firestore.instance
        .collection('timebanknew')
        .document(widget.timebankId)
        .collection('notifications')
        .snapshots()
        .listen((QuerySnapshot data) {
      notifications = [];
      data.documents.forEach((DocumentSnapshot n) {
        NotificationsModel notification = NotificationsModel.fromMap(n.data);
        if (!users.containsKey(notification.senderUserId)) {
          setUserData(notification.senderUserId);
        }
        notifications.add(notification);
      });
      if (notifications != null && users.length == notifications.length) {
        setState(() {});
      }
    });
  }

  Future<void> setUserData(String userId) async {
    users[userId] = await FirestoreManager.getUserForId(sevaUserId: userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: notifications == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? Center(
                  child: Text('No Notifications'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    UserModel u = users[notifications[index].senderUserId];
                    return u != null
                        ? NotificationCard(
                            notificationModel: notifications[index],
                            user: u,
                          )
                        : Container();
                  },
                ),
    );
    // return Container(
    //   color: Colors.white,
    //   child: StreamBuilder<QuerySnapshot>(
    //     stream: Firestore.instance
    //         .collection('timebanknew')
    //         .document(widget.timebankId)
    //         .collection('notifications')
    //         .snapshots(),
    //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return Center(child: CircularProgressIndicator());
    //       }
    //       if (snapshot.hasError) {
    //         return Center(
    //           child: Text('Failed to load data'),
    //         );
    //       }
    //       if (snapshot.hasData && snapshot.data != null) {
    //         if (snapshot.data.documents.length == 0) {
    //           return Center(
    //             child: Text('No Notifications'),
    //           );
    //         }
    //         return Container(
    //           child: ListView.builder(
    //             shrinkWrap: true,
    //             itemCount: snapshot.data.documents.length,
    //             itemBuilder: (context, index) {
    //               NotificationsModel model = NotificationsModel.fromMap(
    //                 snapshot.data.documents[index].data,
    //               );
    //               return NotificationCard(
    //                 notificationModel: model,
    //               );
    //             },
    //           ),
    //         );
    //       }
    //       return Center(
    //         child: Text('Failed to load data'),
    //       );
    //     },
    //   ),
    // );
  }

  @override
  bool get wantKeepAlive => true;
}

class NotificationCard extends StatelessWidget {
  final NotificationsModel notificationModel;
  final UserModel user;
  const NotificationCard({
    Key key,
    this.notificationModel,
    this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: Firestore.instance
            .collection('users')
            .document(notificationModel.senderUserId)
            .get(),
        builder: (context, snapshot) {
          return Dismissible(
            direction: DismissDirection.endToStart,
            key: Key(notificationModel.id),
            onDismissed: (DismissDirection direction) {
              print('dismissed');
            },
            background: Container(
              padding: EdgeInsets.only(right: 20),
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            dismissThresholds: <DismissDirection, double>{
              DismissDirection.endToStart: 0.25,
              DismissDirection.startToEnd: 0.25,
            },
            child: Container(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL),
                ),
                title: Text(user.fullname),
                subtitle: Text(
                  getAdminNotificationMessage(notificationModel.type),
                ),
              ),
            ),
          );
        });
  }
}
