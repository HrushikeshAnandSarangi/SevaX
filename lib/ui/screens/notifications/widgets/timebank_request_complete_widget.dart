import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/screens/offers/pages/bookmarked_offers.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class TimebankRequestCompletedWidget extends StatelessWidget {
  final NotificationsModel? notification;
  final TimebankModel? timebankModel;
  final BuildContext? parentContext;

  const TimebankRequestCompletedWidget(
      {Key? key, this.notification, this.timebankModel, this.parentContext})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    RequestModel model = RequestModel.fromMap(notification!.data!);
    return FutureBuilder<RequestModel>(
      future: FirestoreManager.getRequestFutureById(requestId: model.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return NotificationShimmer();
        }
        RequestModel model = snapshot.data!;
        return getNotificationRequestCompletedWidget(
          model,
          notification!.senderUserId!,
          notification!.id!,
        );
      },
    );
  }

  Widget getNotificationRequestCompletedWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    TransactionModel? transactionModel = model.transactions
        ?.firstWhere((transaction) => transaction.to == userId,
            orElse: () => TransactionModel(
                  fromEmail_Id: model.email,
                  toEmail_Id: userId,
                  communityId: model.communityId,
                ));
    return StreamBuilder<UserModel>(
      stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data!;

        return NotificationCard(
          isDissmissible: false,
          title: model.title!,
          subTitle: model.requestType == RequestType.BORROW
              ? '${user.fullname} ${S.of(context).has_reviewed_this_request_text}. \n${S.of(context).tap_to_share_feedback_text}.'
              : '${user.fullname} ${S.of(context).completed_task_in} ${(transactionModel!.credits)!.toStringAsFixed(2) ?? "0.0"} ${transactionModel.credits! > 1 ? S.of(context).hours : S.of(context).hour}, ${S.of(context).notifications_waiting_for_approval}.',
          photoUrl: user.photoURL,
          entityName: user.fullname,
          onPressed: () {
            //How to Integrate for borrow request from here, check and complete

            showMemberClaimConfirmation(
              context: parentContext!,
              notificationId: notificationId,
              requestModel: model,
              userId: userId,
              userModel: user,
              credits: model.requestType == RequestType.BORROW
                  ? 0.0
                  : (transactionModel?.credits ?? 0.0).toDouble(),
            );
          },
          timestamp: notification!.timestamp!,
        );
      },
    );
  }

  void showMemberClaimConfirmation(
      {BuildContext? context,
      UserModel? userModel,
      RequestModel? requestModel,
      String? notificationId,
      String? userId,
      double? credits}) {
    showDialog(
      context: context!,
      builder: (BuildContext viewContext) {
        if (requestModel!.requestType == RequestType.BORROW) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              //key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomCloseButton(
                      onTap: () => Navigator.of(viewContext).pop()),
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
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "${S.of(context).about} ${userModel.fullname}",
                        style: TextStyle(
                            fontFamily: 'Europa',
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(context, userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          S.of(context).click_button_below_to_review +
                              ' ${userModel.fullname} ' +
                              S.of(context).and_complete_task,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Europa',
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          elevation: 2.0,
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            S.of(context).review,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () async {
                            // Once approved take for feeddback
                            approveMemberClaim(
                                context: context,
                                model: requestModel,
                                notificationId: notificationId!,
                                user: userModel,
                                userId: userId!);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          elevation: 2.0,
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: Text(
                            S.of(context).close,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () async {
                            // reject the claim
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
        } else {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              //key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomCloseButton(
                      onTap: () => Navigator.of(viewContext).pop()),
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
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "${S.of(context).about} ${userModel.fullname}",
                        style: TextStyle(
                            fontFamily: 'Europa',
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(context, userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: requestModel.requestType == RequestType.BORROW
                            ? Text(
                                userModel.fullname! +
                                    ' has reviewed you for this request. Click button below to review and complete the task',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Text(
                                "${S.of(context).by_approving_you_accept} ${userModel.fullname} ${S.of(context).has_worked_for_text} $credits ${S.of(context).hours_text}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      )),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          elevation: 2.0,
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            S.of(context).approve,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () async {
                            // Once approved take for feeddback
                            approveMemberClaim(
                                context: context,
                                model: requestModel,
                                notificationId: notificationId!,
                                user: userModel,
                                userId: userId!);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          elevation: 2.0,
                          textColor: Colors.white,
                          color: Theme.of(context).colorScheme.secondary,
                          child: Text(
                            S.of(context).reject,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () async {
                            // reject the claim
                            rejectMemberClaimForEvent(
                                context: context,
                                model: requestModel,
                                notificationId: notificationId!,
                                user: userModel,
                                userId: userId!);
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
        }
      },
    );
  }

  Future<void> rejectMemberClaimForEvent(
      {RequestModel? model,
      String? userId,
      BuildContext? context,
      UserModel? user,
      String? notificationId}) async {
    List<TransactionModel> transactions =
        model!.transactions!.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    model.transactions = transactions.map((t) {
      return t;
    }).toList();
    FirestoreManager.updateAcceptBorrowRequest(
      requestModel: model,
      userEmail: user?.email ?? "",
      // status: "rejected",
      // communityId: (user != null && model.participantDetails[user.email] != null)
      //     ? model.participantDetails[user.email]['communityId']
      //     : model.communityId,
    );

    UserModel loggedInUser = SevaCore.of(context!).loggedInUser;
    ParticipantInfo sender = ParticipantInfo(
      id: model.timebankId,
      name: timebankModel!.name,
      photoUrl: timebankModel!.photoUrl,
      type: timebankModel!.parentTimebankId == FlavorConfig.values.timebankId
          ? ChatType.TYPE_TIMEBANK
          : ChatType.TYPE_GROUP,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user!.sevaUserID!,
      photoUrl: user.photoURL!,
      name: user.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    List<String> showToCommunities = [];
    try {
      String communityId1 = model.communityId!;

      String communityId2 =
          model.participantDetails![user.email]['communityId'];

      if (communityId1 != null &&
          communityId2 != null &&
          communityId1.isNotEmpty &&
          communityId2.isNotEmpty &&
          communityId1 != communityId2) {
        showToCommunities.add(communityId1);
        showToCommunities.add(communityId2);
      }
    } catch (e) {
      logger.e(e);
    }

    await createAndOpenChat(
      context: context,
      showToCommunities:
          showToCommunities.isNotEmpty ? showToCommunities : <String>[],
      interCommunity: showToCommunities.isNotEmpty,
      communityId: loggedInUser.currentCommunity!,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
      isTimebankMessage: true,
      timebankId: timebankModel!.id,
      feedId: '',
      entityId: model.id!,
      onChatCreate: () {
        FirestoreManager.readTimeBankNotification(
          notificationId: notificationId,
          timebankId: timebankModel!.id!,
        );
      },
    );
  }

  void approveTransaction(
    RequestModel model,
    String userId,
    String notificationId,
    SevaCore sevaCore,
    String email,
  ) {
    if (model.requestType != RequestType.BORROW) {
      FirestoreManager.approveRequestCompletion(
        model: model,
        userId: userId,
        communityId: sevaCore.loggedInUser.currentCommunity!,
        memberCommunityId: model.participantDetails![email] != null
            ? model.participantDetails![email]['communityId']
            : model.communityId,
      );
    }

    FirestoreManager.readTimeBankNotification(
      notificationId: notificationId,
      timebankId: model.timebankId,
    );
  }

  void approveMemberClaim({
    String? userId,
    UserModel? user,
    BuildContext? context,
    RequestModel? model,
    String? notificationId,
  }) {
    //request for feedback;
    checkForFeedback(
      userId: userId!,
      user: user!,
      context: context!,
      model: model!,
      notificationId: notificationId!,
      sevaCore: SevaCore.of(context),
    );
  }

  Future<void> sendMessageToMember({
    UserModel? loggedInUser,
    UserModel? receiver,
    RequestModel? requestModel,
    String? message,
    BuildContext? context,
  }) async {
    ParticipantInfo sender = ParticipantInfo(
      id: requestModel!.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.sevaUserID
          : requestModel.timebankId,
      photoUrl: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.photoURL
          : timebankModel!.photoUrl,
      name: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.fullname
          : timebankModel!.name,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : timebankModel!.parentTimebankId == FlavorConfig.values.timebankId
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: receiver!.sevaUserID,
      photoUrl: receiver.photoURL,
      name: receiver.fullname,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : timebankModel!.parentTimebankId == FlavorConfig.values.timebankId
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );
    await sendBackgroundMessage(
        messageContent: getReviewMessage(
          isForCreator: false,
          requestTitle: requestModel.title,
          context: context,
          userName: loggedInUser!.fullname,
          reviewMessage: message,
        ),
        reciever: reciever,
        isTimebankMessage:
            requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                ? false
                : true,
        timebankId: requestModel.timebankId!,
        communityId: loggedInUser.currentCommunity!,
        sender: sender);
  }

  void checkForFeedback({
    String? userId,
    UserModel? user,
    RequestModel? model,
    String? notificationId,
    BuildContext? context,
    SevaCore? sevaCore,
  }) async {
    Map results = {};

    if (model!.requestType == RequestType.BORROW) {
      results = await Navigator.of(context!).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return ReviewFeedback(
            feedbackType: FeedbackType.FOR_BORROW_REQUEST_BORROWER,
            // requestModel: model,
          );
        },
      ));
    } else {
      results = await Navigator.of(context!).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return ReviewFeedback(
            feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
          );
        },
      ));
    }

    if (results != null && results.containsKey('selection')) {
      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          FeedbackType.FOR_REQUEST_VOLUNTEER, results, model, user!);
      onActivityResult(
          sevaCore: sevaCore!,
          requestModel: model,
          userId: userId!,
          notificationId: notificationId!,
          context: context,
          reviewer: model.email!,
          reviewed: user.email!,
          requestId: model.id!,
          results: results,
          reciever: user);
    } else {}

    log('RESULTS:  ' + results.toString());
  }

  void onActivityResult(
      {SevaCore? sevaCore,
      RequestModel? requestModel,
      String? userId,
      String? notificationId,
      BuildContext? context,
      Map? results,
      String? reviewer,
      String? reviewed,
      UserModel? reciever,
      String? requestId}) async {
    // adds review to firestore
    CollectionRef.reviews.add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results!['selection'],
      "ratingsonquestions": results['ratings'],
      "requestId": requestId,
      "comments": (results['didComment']
          ? results['comment']
          : S.of(context!).no_comments),
      'liveMode': !AppConfig.isTestCommunity,
    });
    // if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
    //   log('inside credit');
    //   TransactionModel transmodel =
    //       requestModel.transactions.firstWhere((transaction) {
    //     return transaction.to == reciever.sevaUserID;
    //   });
    //   await TransactionBloc().createNewTransaction(
    //       requestModel.timebankId,
    //       requestModel.timebankId,
    //       DateTime.now().millisecondsSinceEpoch,
    //       transmodel.credits ?? 0,
    //       true,
    //       "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
    //       requestModel.id,
    //       requestModel.timebankId,
    //       communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    //       fromEmailORId: requestModel.timebankId,
    //       toEmailORId: requestModel.timebankId);
    //   log('success');
    // }
    await sendMessageToMember(
        context: context,
        loggedInUser: sevaCore!.loggedInUser,
        requestModel: requestModel,
        receiver: reciever,
        message: results['comment'] ?? S.of(context!).no_comments);
    approveTransaction(
        requestModel!, userId!, notificationId!, sevaCore, reciever!.email!);

    if (requestModel.requestType == RequestType.BORROW && results != null) {
      if (SevaCore.of(context!).loggedInUser.sevaUserID ==
          requestModel.sevaUserId) {
        requestModel.borrowerReviewed = true;
      }
    }

    FirestoreManager.approveAcceptRequestForTimebank(
      requestModel: requestModel,
      approvedUserId: requestModel.sevaUserId!,
      notificationId: notificationId,
      communityId: SevaCore.of(context!).loggedInUser.currentCommunity!,
    );

    // void approveTransaction(RequestModel model, String userId,
    //     String notificationId, SevaCore sevaCore) {
    //   if (model.requestType != RequestType.BORROW) {
    //     FirestoreManager.approveRequestCompletion(
    //       model: model,
    //       userId: userId,
    //       communityId: sevaCore.loggedInUser.currentCommunity,
    //     );
    //   }
  }
}
