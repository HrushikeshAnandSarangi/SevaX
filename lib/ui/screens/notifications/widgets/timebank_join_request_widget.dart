import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';

class TimebankJoinRequestWidget extends StatelessWidget {
  final NotificationsModel notification;

  const TimebankJoinRequestWidget({Key key, this.notification})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    JoinRequestModel model = JoinRequestModel.fromMap(notification.data);
    return FutureBuilder<UserModel>(
      future:
          FirestoreManager.getUserForId(sevaUserId: notification.senderUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data;
        return user != null && user.fullname != null
            ? NotificationCard(
                timestamp: notification.timestamp,
                title: S.of(context).notifications_join_request,
                subTitle:
                    '${user.fullname.toLowerCase()} ${S.of(context).notifications_requested_join} ${model.timebankTitle}.',
                photoUrl: user.photoURL,
                entityName: user.fullname,
                onDismissed: () {
                  dismissTimebankNotification(
                      timebankId: model.entityId,
                      notificationId: notification.id);
                },
                onPressed: () {
                  showDialogForJoinRequestApproval(
                    context: context,
                    userModel: user,
                    model: model,
                    notificationId: notification.id,
                  );
                },
              )
            : Container();
      },
    );
  }

  void showDialogForJoinRequestApproval({
    BuildContext context,
    UserModel userModel,
    JoinRequestModel model,
    String notificationId,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          content: Form(
            //key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomCloseButton(onTap: () => Navigator.of(viewContext).pop()),
                Container(
                  height: 70,
                  width: 70,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      userModel.photoURL ?? defaultUserImageURL,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    userModel.fullname,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(""),
                ),
                if (userModel.bio != null)
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                      "${S.of(context).about} ${userModel.fullname}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                getBio(context, userModel),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "${S.of(context).reason_to_join}:",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    model.reason ?? S.of(context).reason_not_mentioned,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  //mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: FlavorConfig.values.theme.primaryColor,
                        child: Text(
                          S.of(context).allow,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(viewContext);
                          showProgressForOnboardingUser(context);

                          await addMemberToTimebank(
                            timebankId: model.entityId,
                            joinRequestId: model.id,
                            memberJoiningSevaUserId: model.userId,
                            notificaitonId: notificationId,
                            communityId: SevaCore.of(context)
                                .loggedInUser
                                .currentCommunity,
                            newMemberJoinedEmail: userModel.email,
                            isFromGroup: model.isFromGroup,
                          ).commit();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          S.of(context).reject,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(viewContext);
                          showProgressForOnboardingUser(context);
                          await rejectMemberJoinRequest(
                            timebankId: model.entityId,
                            joinRequestId: model.id,
                            notificaitonId: notificationId,
                          ).commit();

                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showProgressForOnboardingUser(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        return AlertDialog(
          title: Text(
            S.of(context).updating_timebank,
          ),
          content: LinearProgressIndicator(),
        );
      },
    );
  }

  WriteBatch addMemberToTimebank({
    String timebankId,
    String memberJoiningSevaUserId,
    String joinRequestId,
    String communityId,
    String newMemberJoinedEmail,
    String notificaitonId,
    bool isFromGroup,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(newMemberJoinedEmail);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.updateData(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
      });

      var addToCommunityRef =
          Firestore.instance.collection('communities').document(communityId);
      batch.updateData(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  WriteBatch rejectMemberJoinRequest({
    String timebankId,
    String joinRequestId,
    String notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }
}
