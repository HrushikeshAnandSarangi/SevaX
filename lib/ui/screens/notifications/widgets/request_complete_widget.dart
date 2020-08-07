import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/widgets/APi/user_api.dart';

class RequestCompleteWidget extends StatelessWidget {
  final RequestModel model;
  final String userId;
  final String notificationId;

  const RequestCompleteWidget(
      {Key key, this.model, this.userId, this.notificationId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserApi.fetchUserById(userId),
      builder: (_context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data;
        TransactionModel transactionModel =
            model.transactions?.firstWhere((transaction) {
          return transaction.to == userId;
        });
        return Slidable(
            delegate: SlidableBehindDelegate(),
            actions: <Widget>[],
            secondaryActions: <Widget>[],
            child: GestureDetector(
              onTap: () async {
                var canApproveTransaction =
                    await FirestoreManager.hasSufficientCredits(
                  credits: transactionModel.credits,
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
                );

                if (!canApproveTransaction) {
                  showDiologForMessage(
                    context,
                    S.of(context).notifications_insufficient_credits,
                  );
                  return;
                }

                showMemberClaimConfirmation(
                  context: context,
                  notificationId: notificationId,
                  requestModel: model,
                  userId: userId,
                  userModel: user,
                  credits: transactionModel.credits,
                );
              },
              child: Container(
                margin: notificationPadding,
                decoration: notificationDecoration,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(user.photoURL ?? defaultUserImageURL),
                  ),
                  title: Text(model.title),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${user.fullname} ${S.of(context).completed_task_in} ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return '${transactionModel.credits} ${S.of(context).hour(transactionModel.credits).toLowerCase()}';
                          }(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return ', ${S.of(context).notifications_waiting_for_approval}';
                          }(),
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  void showDiologForMessage(BuildContext context, String dialogText) {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return AlertDialog(
          title: Text(dialogText),
          actions: <Widget>[
            FlatButton(
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(viewContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showMemberClaimConfirmation({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
    String userId,
    double credits,
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
                      "${S.of(context).about} ${userModel.fullname}",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                getBio(context, userModel),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "${S.of(context).by_approving_you_accept} ${userModel.fullname} has worked for $credits hours",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                      child: RaisedButton(
                        child: Text(
                          S.of(context).approve,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          checkForFeedback(
                            context: context,
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            userId: userId,
                            sevaCore: SevaCore.of(context),
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
                          S.of(context).reject,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          rejectMemberClaimForEvent(
                            context: context,
                            model: requestModel,
                            notificationId: notificationId,
                            user: userModel,
                            userId: userId,
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

  void checkForFeedback({
    String userId,
    UserModel user,
    RequestModel model,
    String notificationId,
    BuildContext context,
    SevaCore sevaCore,
  }) async {
    Map results = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ReviewFeedback(
            feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
          );
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      onActivityResult(
        sevaCore: sevaCore,
        requestModel: model,
        userId: userId,
        notificationId: notificationId,
        context: context,
        reviewer: model.email,
        reviewed: user.email,
        requestId: model.id,
        results: results,
      );
    } else {}
  }

  void onActivityResult(
      {SevaCore sevaCore,
      RequestModel requestModel,
      String userId,
      String notificationId,
      BuildContext context,
      Map results,
      String reviewer,
      String reviewed,
      String requestId}) {
    Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "requestId": requestId,
      "comments": (results['didComment']
          ? results['comment']
          : S.of(context).no_comments)
    });
    approveTransaction(requestModel, userId, notificationId, sevaCore);
  }

  void approveTransaction(
    RequestModel model,
    String userId,
    String notificationId,
    SevaCore sevaCore,
  ) {
    FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity,
    );

    FirestoreManager.readUserNotification(
        notificationId, sevaCore.loggedInUser.email);
  }

  void rejectMemberClaimForEvent(
      {RequestModel model,
      String userId,
      BuildContext context,
      UserModel user,
      String notificationId}) {
    List<TransactionModel> transactions =
        model.transactions.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    model.transactions = transactions.map((t) {
      return t;
    }).toList();
    FirestoreManager.rejectRequestCompletion(
      model: model,
      userId: userId,
      communityid: SevaCore.of(context).loggedInUser.currentCommunity,
    );

    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      name: loggedInUser.fullname,
      photoUrl: loggedInUser.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevaUserID,
      name: user.fullname,
      photoUrl: user.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );
    createAndOpenChat(
      communityId: loggedInUser.currentCommunity,
      context: context,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
    );
    FirestoreManager.readUserNotification(
      notificationId,
      SevaCore.of(context).loggedInUser.email,
    );
  }
}
