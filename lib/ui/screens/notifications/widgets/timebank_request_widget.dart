import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';

class TimebankRequestWidget extends StatelessWidget {
  final RequestModel model;
  final NotificationsModel notification;

  const TimebankRequestWidget({
    Key key,
    this.model,
    this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RequestModel>(
      future: FirestoreManager.getRequestFutureById(
        requestId: model.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return NotificationShimmer();
        }
        RequestModel model = snapshot.data;
        return FutureBuilder<UserModel>(
          future: FirestoreManager.getUserForIdFuture(
              sevaUserId: notification.senderUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return NotificationShimmer();
            }
            UserModel user = snapshot.data;
            return NotificationCard(
              timestamp: notification.timestamp,
              isDissmissible: false,
              title: model.title,
              subTitle:
                  '${S.of(context).notifications_request_accepted_by} ${user.fullname}, ${S.of(context).notifications_waiting_for_approval}',
              photoUrl: user.photoURL,
              entityName: user.fullname,
              onPressed: () {
                showDialogForApproval(
                  context: context,
                  userModel: user,
                  notificationId: notification.id,
                  requestModel: model,
                );
              },
            );
          },
        );
      },
    );
  }

  void showDialogForApproval({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
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
                  padding: EdgeInsets.all(5),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: requestModel.requestType == RequestType.BORROW ? 
                      Text(
                          "${S.of(context).notifications_by_approving} ${userModel.fullname}, you will go ahead with them for the request.",   
                          style: TextStyle(                                        //LABEL NEEDED FROM CLIENT FOR ABOVE TEXT
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center)
                          :
                          Text(
                          "${S.of(context).notifications_by_approving}, ${userModel.fullname} ${S.of(context).notifications_will_be_added_to}.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center)
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: FlavorConfig.values.theme.primaryColor,
                        child: Text(
                          S.of(context).approve,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          approveMemberForVolunteerRequest(
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            context: context,
                          );
                          Navigator.pop(viewContext);
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          S.of(context).decline,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          declineRequestedMember(
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            context: context,
                          );
                          Navigator.pop(viewContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
    @required BuildContext context,
  }) async {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    FirestoreManager.approveAcceptRequestForTimebank(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
    BuildContext context,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }
}
