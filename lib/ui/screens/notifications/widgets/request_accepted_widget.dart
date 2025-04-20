import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/creatorApproveAcceptorAgreement.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class RequestAcceptedWidget extends StatelessWidget {
  final String? userId;
  final String? notificationId;
  final RequestModel? model;

  const RequestAcceptedWidget(
      {Key? key, this.userId, this.notificationId, this.model})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(userId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }

        UserModel user = snapshot.data!;

        return Slidable(
          endActionPane: null,
          startActionPane: null,
          child: GestureDetector(
            onTap: () {
              if (model!.requestType == RequestType.BORROW) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreatorApproveAcceptorAgreeement(
                      requestModel: model!,
                      timeBankId: model!.timebankId!,
                      userId: SevaCore.of(context).loggedInUser.sevaUserID!,
                      parentContext: context,
                      acceptorUserModel: user,
                      notificationId: notificationId!,
                      //onTap: () async {},
                    ),
                  ),
                );
              } else {
                showDialogForApproval(
                  context: context,
                  userModel: user,
                  notificationId: notificationId!,
                  requestModel: model!,
                );
              }
            },
            child: Container(
              margin: notificationPadding,
              decoration: notificationDecoration,
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(model!.title!),
                ),
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(user.photoURL ?? defaultUserImageURL),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                    '${S.of(context).notifications_request_accepted_by} ${user.fullname}, ${S.of(context).notifications_waiting_for_approval}',
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
    BuildContext? context,
    UserModel? userModel,
    RequestModel? requestModel,
    String? notificationId,
  }) {
    showDialog(
      context: context!,
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
                    backgroundImage: NetworkImage(
                        userModel!.photoURL ?? defaultUserImageURL),
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
                if (userModel.bio != null)
                  Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Text(
                      "${S.of(context).about} ${userModel.fullname}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                Center(child: getBio(context, userModel)),
                Center(
                  child: model!.requestType == RequestType.BORROW
                      ? Text(
                          "${S.of(context).notifications_by_approving}, ${userModel.fullname} " +
                              S.of(context).will_be_added_to_request,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          "${S.of(context).notifications_by_approving}, ${userModel.fullname} ${S.of(context).notifications_will_be_added_to}.",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          CustomElevatedButton(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            elevation: 2.0,
                            textColor: Colors.white,
                            child: Text(
                              S.of(context).approve,
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Europa'),
                            ),
                            onPressed: () async {
                              if (requestModel!.requestType ==
                                  RequestType.BORROW) {
                                approveMemberForBorrowRequest(
                                  model: requestModel,
                                  notificationId: notificationId!,
                                  user: userModel,
                                  communityId: SevaCore.of(context)
                                      .loggedInUser
                                      .currentCommunity!,
                                );
                                log('approved member for borrow request');
                              } else {
                                approveMemberForVolunteerRequest(
                                  model: requestModel,
                                  notificationId: notificationId!,
                                  user: userModel,
                                  communityId: SevaCore.of(context)
                                      .loggedInUser
                                      .currentCommunity!,
                                );
                              }
                              Navigator.pop(viewContext);
                            },
                          ),
                          SizedBox(height: 8.0),
                          CustomElevatedButton(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            elevation: 2.0,
                            textColor: Colors.white,
                            child: Text(
                              S.of(context).decline,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              declineRequestedMember(
                                model: requestModel!,
                                notificationId: notificationId!,
                                user: userModel,
                                communityId: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity!,
                              );

                              Navigator.pop(viewContext);
                            },
                          ),
                        ],
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
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    String? communityId,
  }) {
    List<String> acceptedUsers = model!.acceptors!;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user!.email);
    model.acceptors = usersSet.toList();

    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID!,
      notificationId: notificationId!,
      communityId: communityId!,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    String? communityId,
  }) {
    List<String> approvedUsers = model!.approvedUsers!;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user!.email!);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals! <= model.approvedUsers!.length) {
      model.accepted = true;
      FirestoreManager.approveAcceptRequest(
        requestModel: model,
        approvedUserId: user.sevaUserID!,
        notificationId: notificationId!,
        communityId: communityId!,
        directToMember: true,
      );
    }
  }

  void approveMemberForBorrowRequest({
    RequestModel? model,
    UserModel? user,
    String? notificationId,
    String? communityId,
  }) {
    log('TWO' + ' ' + model!.approvedUsers!.length.toString());

    List<String> approvedUsers = model.approvedUsers!;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user!.email!);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals! <= model.approvedUsers!.length) {
      //approved
      log('THREE');
      model.accepted = true;
      FirestoreManager.approveAcceptRequest(
        requestModel: model,
        approvedUserId: user.sevaUserID!,
        notificationId: notificationId!,
        communityId: communityId!,
        directToMember: true,
      );
    }
  }

  Widget getBio(BuildContext context, UserModel userModel,
      {bool isScrollable = true}) {
    if (userModel.bio != null) {
      if (userModel.bio!.trim().length < 100) {
        return Text(
          userModel.bio!.trim(),
          textAlign: TextAlign.center,
        );
      }
      var child = Text(
        userModel.bio!,
        maxLines: null,
        overflow: null,
        textAlign: TextAlign.center,
      );
      return isScrollable
          ? Container(
              height: 150,
              child: SingleChildScrollView(
                physics: isScrollable ? null : NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: child,
              ),
            )
          : child;
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(S.of(context).bio_not_updated),
    );
  }
}
