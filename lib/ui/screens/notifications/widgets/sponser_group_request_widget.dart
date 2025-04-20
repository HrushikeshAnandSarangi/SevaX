import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/sponsored_group_request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class SponsorGroupRequestWidget extends StatelessWidget {
  final NotificationsModel? notification;

  const SponsorGroupRequestWidget({Key? key, this.notification})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    SponsoredGroupModel model =
        SponsoredGroupModel.fromMap(notification!.data!);
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForId(
          sevaUserId: notification!.senderUserId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data!;
        return user != null && user.fullname != null
            ? NotificationCard(
                timestamp: notification!.timestamp!,
                title: S.of(context).endorsed_notification_title,
                subTitle: S
                    .of(context)
                    .endorsed_notification_desc
                    .replaceAll('user_name', user.fullname!.toLowerCase())
                    .replaceAll('group_name', model.timebankTitle!),
                photoUrl: user.photoURL,
                entityName: user.fullname,
                onDismissed: () {
                  dismissTimebankNotification(
                      timebankId: notification!.timebankId,
                      notificationId: notification!.id);
                },
                onPressed: () async {
                  await showDialogForJoinRequestApproval(
                    context: context,
                    userModel: user,
                    model: model,
                    notificationId: notification!.id!,
                  ).then((value) async {
                    if (value == null) {
                      return;
                    }
                    if (value) {
                      await approveSponsorRequest(
                        parenttimebankId: notification!.timebankId!,
                        groupId: model.timebankId!,
                        notificaitonId: notification!.id!,
                      ).commit();
                    } else {
                      await showProgressForOnboardingUser(context);
                      rejectSponsorRequest(
                        parenttimebankId: notification!.timebankId!,
                        notificaitonId: notification!.id!,
                      ).commit();

                      Navigator.of(context, rootNavigator: true).pop();
                    }
                  });
                },
              )
            : Container();
      },
    );
  }

  Future<bool> showDialogForJoinRequestApproval({
    BuildContext? context,
    UserModel? userModel,
    SponsoredGroupModel? model,
    String? notificationId,
  }) async {
    return await showDialog(
      context: context!,
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
                      model!.timebankPhotUrl ?? defaultGroupImageURL,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    model.timebankTitle!,
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
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text(
                    S
                        .of(context)
                        .endorsed_group_request_desc
                        .replaceAll(
                            'user_name', userModel!.fullname!.toLowerCase())
                        .replaceAll('group_name', model.timebankTitle!),
                    style: TextStyle(
                      fontSize: 14,
                    ),
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
                      child: CustomElevatedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          S.of(context).approve,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(viewContext, true);
                          // showProgressForOnboardingUser(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: CustomElevatedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
                        color: Theme.of(context).colorScheme.secondary,
                        child: Text(
                          S.of(context).reject,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          Navigator.pop(viewContext, false);
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

  Future<void> showProgressForOnboardingUser(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (createDialogContext) {
        return AlertDialog(
          title: Text(
            S.of(context).updating_timebank,
          ),
          content: LinearProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        );
      },
    );
  }

  WriteBatch approveSponsorRequest({
    String? parenttimebankId,
    String? groupId,
    String? notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = CollectionRef.batch;
    var timebankRef = CollectionRef.timebank.doc(groupId);

    var timebankNotificationReference = CollectionRef.timebank
        .doc(parenttimebankId)
        .collection("notifications")
        .doc(notificaitonId);

    batch.update(timebankRef, {
      'sponsored': true,
    });

    batch.update(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  WriteBatch rejectSponsorRequest({
    String? parenttimebankId,
    String? notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = CollectionRef.batch;

    var timebankNotificationReference = CollectionRef.timebank
        .doc(parenttimebankId)
        .collection("notifications")
        .doc(notificaitonId);

    batch.update(timebankNotificationReference, {'isRead': true});

    return batch;
  }
}
