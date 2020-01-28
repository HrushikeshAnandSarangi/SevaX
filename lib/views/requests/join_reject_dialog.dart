/*
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';

import '../core.dart';

class JoinRejectDialogView extends StatefulWidget {

  final RequestInvitationModel requestInvitationModel;
  final String timeBankId;


  JoinRejectDialogView({this.requestInvitationModel, this.timeBankId});

  @override
  _JoinRejectDialogViewState createState() => _JoinRejectDialogViewState();
}

class _JoinRejectDialogViewState extends State<JoinRejectDialogView> {



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
                backgroundImage: NetworkImage(userModel.photoURL),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                userModel.fullname == null
                    ? "Anonymous"
                    : userModel.fullname,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Text(
                userModel.email == null
                    ? "User email not updated"
                    : userModel.email,
              ),
            ),
            if (userModel.bio != null)
              Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  "About ${userModel.fullname}",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                userModel.bio == null
                    ? "Bio not yet updated"
                    : userModel.bio,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Center(
              child: Text(
                  "By approving, ${userModel.fullname} will be added to the event.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    'Decline',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () async {
                    // request declined

                    declineRequestedMember(
                        model: requestModel,
                        notificationId: notificationId,
                        user: userModel);

                    Navigator.pop(viewContext);
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                RaisedButton(
                  child: Text(
                    'Approve',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () async {
                    // Once approved
                    approveMemberForVolunteerRequest(
                        model: requestModel,
                        notificationId: notificationId,
                        user: userModel);
                    Navigator.pop(viewContext);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void declineRequestedMember({
    RequestInvitationModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestInvitationModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    approveAcceptRequest(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
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
*/
