import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/groupinvite_user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class GroupJoinRejectDialogView extends StatefulWidget {
  final GroupInviteUserModel groupInviteUserModel;
  final String timeBankId;
  final String notificationId;
  final UserModel userModel;
  final String invitationId;

  GroupJoinRejectDialogView(
      {this.groupInviteUserModel,
      this.timeBankId,
      this.notificationId,
      this.userModel,
      this.invitationId});

  @override
  _GroupJoinRejectDialogViewState createState() =>
      _GroupJoinRejectDialogViewState(groupInviteUserModel, timeBankId,
          notificationId, userModel, invitationId);
}

class _GroupJoinRejectDialogViewState extends State<GroupJoinRejectDialogView> {
  final GroupInviteUserModel groupInviteUserModel;
  final String timeBankId;
  final String notificationId;
  final UserModel userModel;
  final String invitationId;

  _GroupJoinRejectDialogViewState(this.groupInviteUserModel, this.timeBankId,
      this.notificationId, this.userModel, this.invitationId);

  BuildContext progressContext;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Container(
              height: 70,
              width: 70,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    groupInviteUserModel.timebankImage ?? defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Group Join',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                groupInviteUserModel.timebankName ??
                    "Timebank name not updated",
              ),
            ),
//              Padding(
//                padding: EdgeInsets.all(0.0),
//                child: Text(
//                  "About ${requestInvitationModel.}",
//                  style: TextStyle(
//                      fontSize: 13, fontWeight: FontWeight.bold),
//                ),
//              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                groupInviteUserModel.aboutTimebank ??
                    "Description not yet updated",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                  "By accepting, you will be added to ${groupInviteUserModel.timebankName}.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: RaisedButton(
                    color: FlavorConfig.values.theme.primaryColor,
                    child: Text(
                      'Accept',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      addMemberToGroup().commit();
                      if (progressContext != null) {
                        Navigator.pop(progressContext);
                      }

                      Navigator.of(context).pop();
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
                      'Decline',
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      declineInvitationRequest(
                          userEmail: userModel.email,
                          notificationId: notificationId);

                      if (progressContext != null) {
                        Navigator.pop(progressContext);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  WriteBatch addMemberToGroup() {
    WriteBatch batch = Firestore.instance.batch();
    var timebankRef = Firestore.instance
        .collection('timebanknew')
        .document(groupInviteUserModel.groupId);

    var userNotificationReference = Firestore.instance
        .collection('users')
        .document(userModel.email)
        .collection("notifications")
        .document(notificationId);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([userModel.sevaUserID]),
    });
    batch.updateData(userNotificationReference, {'isRead': true});
    return batch;
  }

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void declineInvitationRequest({
    String notificationId,
    String userEmail,
  }) async {
    await Firestore.instance
        .collection('invitations')
        .document(invitationId)
        .updateData({
      'isDeclined': true,
      'declinedTimestamp': DateTime.now().millisecondsSinceEpoch
    });

    FirestoreManager.readUserNotification(notificationId, userEmail);
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
