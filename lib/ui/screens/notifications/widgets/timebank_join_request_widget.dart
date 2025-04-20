import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/screens/offers/pages/bookmarked_offers.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class TimebankJoinRequestWidget extends StatelessWidget {
  final NotificationsModel? notification;
  final TimebankModel? timebankModel;

  const TimebankJoinRequestWidget(
      {Key? key, this.notification, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    JoinRequestModel model = JoinRequestModel.fromMap(notification?.data ?? {});
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
                title: S.of(context).notifications_join_request,
                subTitle:
                    '${user.fullname!.toLowerCase()} ${S.of(context).notifications_requested_join} ${model.timebankTitle}.',
                photoUrl: user.photoURL,
                entityName: user.fullname,
                onDismissed: () {
                  dismissTimebankNotification(
                      timebankId: model.entityId,
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
                      await addMemberToTimebank(
                        timebankModel: timebankModel!,
                        timebankId: model.entityId!,
                        timebankTitle: model.timebankTitle,
                        joinRequestId: model.id,
                        memberJoiningSevaUserId: model.userId!,
                        user: user,
                        notificaitonId: notification!.id!,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity!,
                        newMemberJoinedEmail: user.email!,
                        isFromGroup: model.isFromGroup,
                        adminEmail: SevaCore.of(context).loggedInUser.email!,
                        adminId: SevaCore.of(context).loggedInUser.sevaUserID!,
                        adminFullName:
                            SevaCore.of(context).loggedInUser.fullname!,
                        adminPhotoUrl:
                            SevaCore.of(context).loggedInUser.photoURL!,
                      ).commit();
                    } else {
                      await showProgressForOnboardingUser(context);
                      rejectMemberJoinRequest(
                        timebankModel: timebankModel!,
                        timebankId: model.entityId!,
                        joinRequestId: model.id,
                        notificaitonId: notification!.id!,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity!,
                        newMemberJoinedEmail: user.email!,
                        memberJoiningSevaUserId: model.userId!,
                        user: user,
                        adminEmail: SevaCore.of(context).loggedInUser.email!,
                        adminId: SevaCore.of(context).loggedInUser.sevaUserID!,
                        adminFullName:
                            SevaCore.of(context).loggedInUser.fullname!,
                        adminPhotoUrl:
                            SevaCore.of(context).loggedInUser.photoURL!,
                        timebankTitle: model.timebankTitle,
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
    JoinRequestModel? model,
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
                      userModel!.photoURL ?? defaultUserImageURL,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                ),
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    userModel.fullname!,
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      if (userModel.bio != null)
                        Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Text(
                            "${S.of(context).about} ${userModel.fullname}",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
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
                          model!.reason ?? S.of(context).reason_not_mentioned,
                        ),
                      ),
                    ],
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
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).allow,
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
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2.0,
                        textColor: Colors.white,
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

  WriteBatch addMemberToTimebank({
    required String timebankId,
    required String timebankTitle,
    required String memberJoiningSevaUserId,
    required UserModel user,
    required String joinRequestId,
    required String communityId,
    required String newMemberJoinedEmail,
    required String notificaitonId,
    required bool isFromGroup,
    required String adminEmail,
    required String adminId,
    required String adminFullName,
    required String adminPhotoUrl,
    required TimebankModel timebankModel,
  }) {
    //add to timebank members

    WriteBatch batch = CollectionRef.batch;
    var timebankRef = CollectionRef.timebank.doc(timebankId);
    var joinRequestReference = CollectionRef.joinRequests.doc(joinRequestId);

    var newMemberDocumentReference =
        CollectionRef.users.doc(newMemberJoinedEmail);

    var timebankNotificationReference = CollectionRef.timebank
        .doc(timebankId)
        .collection("notifications")
        .doc(notificaitonId);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankId)
        .collection('entryExitLogs')
        .doc();

    batch.update(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.update(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
      });
      if (user.communities != null &&
          user.communities!.length == 1 &&
          user.communities!.elementAt(0) == FlavorConfig.values.timebankId) {
        batch.update(
            newMemberDocumentReference, {'currentCommunity': communityId});
      }
      var addToCommunityRef = CollectionRef.communities.doc(communityId);
      batch.update(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.update(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.update(timebankNotificationReference, {'isRead': true});

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.APPROVED_BY_ADMIN.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': newMemberJoinedEmail,
        'id': memberJoiningSevaUserId,
        'fullName': user.fullname,
        'photoUrl': user.photoURL,
      },
      'adminDetails': {
        'email': adminEmail,
        'id': adminId,
        'fullName': adminFullName,
        'photoUrl': adminPhotoUrl,
      },
      'associatedTimebankDetails': {
        'timebankId': timebankId,
        'timebankTitle': timebankTitle,
      },
    });

    return batch;
  }

  WriteBatch rejectMemberJoinRequest({
    required String timebankId,
    required String joinRequestId,
    required String notificaitonId,
    required String communityId,
    required String newMemberJoinedEmail,
    required String memberJoiningSevaUserId,
    required UserModel user,
    required String adminEmail,
    required String adminId,
    required String adminFullName,
    required String adminPhotoUrl,
    required String timebankTitle,
    required TimebankModel timebankModel,
  }) {
    //add to timebank members

    WriteBatch batch = CollectionRef.batch;
    var joinRequestReference = CollectionRef.joinRequests.doc(joinRequestId);

    var timebankNotificationReference = CollectionRef.timebank
        .doc(timebankId)
        .collection("notifications")
        .doc(notificaitonId);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankId)
        .collection('entryExitLogs')
        .doc();

    batch.update(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.update(timebankNotificationReference, {'isRead': true});

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.REJECTED_BY_ADMIN.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': newMemberJoinedEmail,
        'id': memberJoiningSevaUserId,
        'fullName': user.fullname,
        'photoUrl': user.photoURL,
      },
      'adminDetails': {
        'email': adminEmail,
        'id': adminId,
        'fullName': adminFullName,
        'photoUrl': adminPhotoUrl,
      },
      'associatedTimebankDetails': {
        'timebankId': timebankId,
        'timebankTitle': timebankTitle,
        'missionStatement': timebankModel.missionStatement,
      },
    });

    return batch;
  }
}
