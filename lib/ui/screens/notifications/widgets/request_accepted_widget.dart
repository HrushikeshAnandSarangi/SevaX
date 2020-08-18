import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

class RequestAcceptedWidget extends StatelessWidget {
  final String userId;
  final String notificationId;
  final RequestModel model;

  const RequestAcceptedWidget(
      {Key key, this.userId, this.notificationId, this.model})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserApi.fetchUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }

        UserModel user = snapshot.data;

        return Slidable(
          delegate: SlidableBehindDelegate(),
          actions: <Widget>[],
          secondaryActions: <Widget>[],
          child: GestureDetector(
            onTap: () {
              showDialogForApproval(
                context: context,
                userModel: user,
                notificationId: notificationId,
                requestModel: model,
              );
            },
            child: Container(
              margin: notificationPadding,
              decoration: notificationDecoration,
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(model.title),
                ),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user.photoURL ?? defaultUserImageURL),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    '${AppLocalizations.of(context).translate('notifications', 'request_accepted_by')} ${user.fullname}, ${AppLocalizations.of(context).translate('notifications', 'waiting_for')}',
                  ),
                ),
              ),
            ),
          ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomCloseButton(onTap: () => Navigator.of(viewContext).pop()),
                Container(
                  height: 70,
                  width: 70,
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(userModel.photoURL ?? defaultUserImageURL),
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
                      "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                getBio(context, userModel),
                Center(
                  child: Text(
                      "${AppLocalizations.of(context).translate('notifications', 'by_approving_short')}, ${userModel.fullname} ${AppLocalizations.of(context).translate('notifications', 'add_to')}.",
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
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('notifications', 'approve'),
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
                        ),
                        onPressed: () async {
                          approveMemberForVolunteerRequest(
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            communityId: SevaCore.of(context)
                                .loggedInUser
                                .currentCommunity,
                          );
                          Navigator.pop(viewContext);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(3.0),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text(
                          AppLocalizations.of(context)
                              .translate('notifications', 'decline'),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          declineRequestedMember(
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            communityId: SevaCore.of(context)
                                .loggedInUser
                                .currentCommunity,
                          );

                          Navigator.pop(viewContext);
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

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
    String communityId,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: communityId,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
    String communityId,
  }) {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    FirestoreManager.approveAcceptRequest(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: communityId,
      directToMember: true,
    );
  }
}

Widget getBio(BuildContext context, UserModel userModel) {
  if (userModel.bio != null) {
    if (userModel.bio.length < 100) {
      return Center(
        child: Text(userModel.bio),
      );
    }
    return Container(
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Text(
          userModel.bio,
          maxLines: null,
          overflow: null,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Text(AppLocalizations.of(context)
        .translate('notifications', 'bio_notupdated')),
  );
}
