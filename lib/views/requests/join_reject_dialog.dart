import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class JoinRejectDialogView extends StatefulWidget {
  final RequestInvitationModel requestInvitationModel;
  final String timeBankId;
  final String notificationId;
  final UserModel userModel;

  JoinRejectDialogView(
      {this.requestInvitationModel,
      this.timeBankId,
      this.notificationId,
      this.userModel});

  @override
  _JoinRejectDialogViewState createState() => _JoinRejectDialogViewState(
      requestInvitationModel, timeBankId, notificationId, userModel);
}

class _JoinRejectDialogViewState extends State<JoinRejectDialogView> {
  final RequestInvitationModel requestInvitationModel;
  final String timeBankId;
  final String notificationId;
  final UserModel userModel;

  _JoinRejectDialogViewState(this.requestInvitationModel, this.timeBankId,
      this.notificationId, this.userModel);

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
                    requestInvitationModel.timebankImage ??
                        defaultUserImageURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                requestInvitationModel.requestTitle ?? "Anonymous",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                requestInvitationModel.timebankName ??
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
                requestInvitationModel.requestDesc ??
                    "Description not yet updated",
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                  "By accepting, ${requestInvitationModel.requestTitle} will be added to the tasks.",
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
                      AppLocalizations.of(context)
                          .translate('change_ownership', 'accept'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      //Once approved

                      // showProgressDialog(context, 'Accepting Invitation');
                      approveInvitationForVolunteerRequest(
                          model: requestInvitationModel,
                          notificationId: widget.notificationId,
                          user: userModel);

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
                      AppLocalizations.of(context)
                          .translate('notifications', 'decline'),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      // request declined
                      //   showProgressDialog(context, 'Rejecting Invitation');

                      declineInvitationbRequest(
                          model: requestInvitationModel,
                          notificationId: widget.notificationId,
                          userModel: userModel);

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

  void declineInvitationbRequest({
    RequestInvitationModel model,
    String notificationId,
    UserModel userModel,
  }) {
    rejectInviteRequest(
      requestId: model.requestId,
      rejectedUserId: userModel.sevaUserID,
      notificationId: notificationId,
    );

    FirestoreManager.readUserNotification(notificationId, userModel.email);
  }

  void approveInvitationForVolunteerRequest({
    RequestInvitationModel model,
    String notificationId,
    UserModel user,
  }) {
    acceptInviteRequest(
      requestId: model.requestId,
      acceptedUserEmail: user.email,
      acceptedUserId: user.sevaUserID,
      notificationId: notificationId,
    );

    FirestoreManager.readUserNotification(notificationId, user.email);
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
