import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/user_repository.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/custom_close_button.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notifcation_values.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_shimmer.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/request_accepted_widget.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class RequestCompleteWidget extends StatelessWidget {
  final RequestModel model;
  final String userId;
  final String notificationId;
  final BuildContext parentContext;

  const RequestCompleteWidget({
    Key? key,
    required this.model,
    required this.userId,
    required this.notificationId,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserRepository.fetchUserById(userId),
      builder: (_context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return NotificationShimmer();
        }
        UserModel user = snapshot.data!;
        TransactionModel transactionModel = model.transactions?.firstWhere(
              (transaction) => transaction.to == userId,
              orElse: () => TransactionModel(
                fromEmail_Id:
                    '', // Provide appropriate default or fallback values
                toEmail_Id: userId,
                communityId: model.communityId ?? '',
              ),
            ) ??
            TransactionModel(
              fromEmail_Id:
                  '', // Provide appropriate default or fallback values
              toEmail_Id: userId,
              communityId: model.communityId ?? '',
            );
        return Slidable(
            endActionPane: null,
            startActionPane: null,
            child: GestureDetector(
              onTap: () async {
                var canApproveTransaction =
                    await SevaCreditLimitManager.hasSufficientCredits(
                  email: SevaCore.of(context).loggedInUser.email!,
                  credits: (transactionModel.credits as double),
                  userId: SevaCore.of(context).loggedInUser.sevaUserID!,
                  communityId:
                      SevaCore.of(context).loggedInUser.currentCommunity!,
                );

                if (!canApproveTransaction.hasSuffiientCredits) {
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
                  credits: transactionModel.credits as double,
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
                  title: Text(model.title!),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${user.fullname} ${S.of(context).completed_task_in} ',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return '${transactionModel.credits} ${transactionModel.credits! > 1 ? S.of(context).hours.toLowerCase() : S.of(context).hour.toLowerCase()}';
                          }(),
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        TextSpan(
                          text: () {
                            return ', ${S.of(context).notifications_waiting_for_approval}';
                          }(),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
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
            CustomTextButton(
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

  Widget getBio(BuildContext context, UserModel userModel) {
    if (userModel.bio != null && userModel.bio!.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Text(
          userModel.bio!,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void showMemberClaimConfirmation({
    BuildContext? context,
    UserModel? userModel,
    RequestModel? requestModel,
    String? notificationId,
    String? userId,
    double? credits,
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
                getBio(context, userModel),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "${S.of(context).by_approving_you_accept} ${userModel.fullname} ${S.of(context).has_worked_for_text} $credits ${S.of(context).hours_text}",
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
                      child: CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).approve,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          checkForFeedback(
                            context: parentContext,
                            model: requestModel!,
                            notificationId: notificationId!,
                            user: userModel,
                            userId: userId!,
                            loggedInUser: SevaCore.of(context).loggedInUser,
                          );
                          Navigator.pop(viewContext);
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        elevation: 2.0,
                        textColor: Colors.white,
                        child: Text(
                          S.of(context).reject,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          rejectMemberClaimForEvent(
                            context: parentContext,
                            model: requestModel!,
                            notificationId: notificationId!,
                            user: userModel,
                            userId: userId!,
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
    String? userId,
    UserModel? user,
    RequestModel? model,
    String? notificationId,
    BuildContext? context,
    UserModel? loggedInUser,
  }) async {
    Map results = await Navigator.of(context!).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ReviewFeedback(
            feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
            // requestModel: model,
          );
        },
      ),
    );

    if (results != null && results.containsKey('selection')) {
      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          FeedbackType.FOR_REQUEST_VOLUNTEER, results, model!, user!);
      onActivityResult(
          loggedInUser: loggedInUser!,
          requestModel: model,
          userId: userId!,
          notificationId: notificationId!,
          context: context,
          reviewer: model.email!,
          reviewed: user.email!,
          requestId: model.id!,
          results: results,
          receiverUser: user);
    } else {}
  }

  void onActivityResult({
    UserModel? loggedInUser,
    RequestModel? requestModel,
    String? userId,
    String? notificationId,
    BuildContext? context,
    Map? results,
    String? reviewer,
    String? reviewed,
    String? requestId,
    UserModel? receiverUser,
  }) async {
    try {
      CollectionRef.reviews.add({
        "reviewer": reviewer,
        "reviewed": reviewed,
        "ratings": results!['selection'],
        "requestId": requestId,
        "comments": (results['didComment']
            ? results['comment']
            : S.of(context!).no_comments),
        'liveMode': !AppConfig.isTestCommunity,
      });
      // if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
      //   TransactionModel transmodel =
      //       requestModel.transactions.firstWhere((transaction) {
      //     return transaction.to == receiverUser.sevaUserID;
      //   });
      //   await TransactionBloc().createNewTransaction(
      //     requestModel.timebankId,
      //     requestModel.timebankId,
      //     DateTime.now().millisecondsSinceEpoch,
      //     transmodel.credits ?? 0,
      //     true,
      //     "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
      //     requestModel.id,
      //     requestModel.timebankId,
      //     communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      //     toEmailORId: requestModel.timebankId,
      //     fromEmailORId: requestModel.timebankId,
      //   );
      //   log('success');
      // }
      approveTransaction(requestModel!, userId!, notificationId!, loggedInUser!,
          receiverUser!.email!);

      await sendMessageToMember(
        receiverUser: receiverUser,
        requestModel: requestModel,
        message: (results['didComment']
            ? results['comment']
            : S.of(context!).no_comments),
        loggedInUser: loggedInUser,
      );
    } on Exception catch (e) {
      logger.e(e.toString());
    }
  }

  Future<void> sendMessageToMember(
      {UserModel? loggedInUser,
      UserModel? receiverUser,
      RequestModel? requestModel,
      String? message,
      BuildContext? context}) async {
    TimebankModel? timebankModel =
        requestModel != null && requestModel.timebankId != null
            ? await getTimeBankForId(timebankId: requestModel.timebankId!)
            : null;
    UserModel userModel = await FirestoreManager.getUserForId(
        sevaUserId: requestModel!.sevaUserId!);
    if (userModel != null && timebankModel != null) {
      ParticipantInfo receiver = ParticipantInfo(
        id: receiverUser!.sevaUserID,
        photoUrl: receiverUser.photoURL,
        name: receiverUser.fullname,
        type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );

      ParticipantInfo sender = ParticipantInfo(
        id: loggedInUser!.sevaUserID,
        photoUrl: loggedInUser.photoURL,
        name: loggedInUser.fullname,
        type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? ChatType.TYPE_PERSONAL
            : timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? ChatType.TYPE_TIMEBANK
                : ChatType.TYPE_GROUP,
      );
      await sendBackgroundMessage(
          messageContent: getReviewMessage(
            isForCreator: false,
            requestTitle: requestModel.title,
            context: context,
            userName: loggedInUser.fullname,
            reviewMessage: message,
          ),
          reciever: receiver,
          isTimebankMessage:
              requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                  ? false
                  : true,
          timebankId: requestModel.timebankId!,
          communityId: loggedInUser.currentCommunity!,
          sender: sender);
    }
  }

  void approveTransaction(
    RequestModel model,
    String userId,
    String notificationId,
    UserModel loggedInUser,
    String email,
  ) {
    FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: loggedInUser.currentCommunity!,
      memberCommunityId: model.participantDetails![email] != null
          ? model.participantDetails![email]['communityId']
          : model.communityId,
    );
    log('clearing notification');
    FirestoreManager.readUserNotification(
      notificationId,
      loggedInUser.email!,
    );
  }

  void rejectMemberClaimForEvent(
      {RequestModel? model,
      String? userId,
      BuildContext? context,
      UserModel? user,
      String? notificationId}) {
    List<TransactionModel> transactions =
        model!.transactions!.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    model.transactions = transactions.map((t) {
      return t;
    }).toList();
    FirestoreManager.rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: userId!,
      notificationId: notificationId!,
      communityId: model.participantDetails![user!.email] != null
          ? model.participantDetails![user.email]['communityId']
          : model.communityId!,
    );

    UserModel loggedInUser = SevaCore.of(context!).loggedInUser;
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

    createAndOpenChat(
      communityId: loggedInUser.currentCommunity!,
      context: context,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
      showToCommunities:
          showToCommunities.isNotEmpty ? showToCommunities : null!,
      interCommunity: showToCommunities.isNotEmpty,
      timebankId: model.timebankId ?? '',
      feedId: '',
      entityId: model.id ?? '',
      onChatCreate: () {},
    );
    FirestoreManager.readUserNotification(
      notificationId,
      SevaCore.of(context).loggedInUser.email!,
    );
  }
}
