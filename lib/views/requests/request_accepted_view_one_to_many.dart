import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/claimedRequestStatus.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart'
    as RequestNotificationManager;
import 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as RequestManager;
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';
import '../core.dart';

class RequestAcceptedSpendingViewOneToMany extends StatefulWidget {
  RequestModel requestModel;
  final TimebankModel? timebankModel;

  RequestAcceptedSpendingViewOneToMany(
      {required this.requestModel, this.timebankModel});

  @override
  _RequestAcceptedSpendingViewOneToManyState createState() =>
      _RequestAcceptedSpendingViewOneToManyState();
}

class _RequestAcceptedSpendingViewOneToManyState
    extends State<RequestAcceptedSpendingViewOneToMany> {
  List<Widget> _avtars = [];
  bool noTransactionAvailable = false;
  List<Widget> _pendingAvtars = [];
  List<NotificationsModel> pendingRequests = [];
  bool isProgressBarActive = false;
  bool isRemoving = false;

  _RequestAcceptedSpendingViewOneToManyState() {}

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      RequestManager.getRequestStreamById(requestId: widget.requestModel.id!)
          .listen((_requestModel) {
        widget.requestModel = _requestModel;
        reset();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isProgressBarActive) {
      return AlertDialog(
        title: Text(
          isRemoving
              ? S.of(context).redirecting_to_messages
              : S.of(context).updating_users,
        ),
        content: LinearProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 10, left: 10),
        child: listItems,
      ),
    );
  }

  Widget get listItems {
    if (_avtars.length == 0) {
      return LoadingIndicator();
    }
    return ListView.builder(
        itemCount: _avtars.length,
        itemBuilder: (context, index) {
          return _avtars[index];
        });
  }

  void reset() {
    _avtars = [];
    _pendingAvtars = [];
    noTransactionAvailable = false;
    _updatePendingAvtarWidgets();
    setState(() {
      isProgressBarActive = false;
    });
  }

  Future _updatePendingAvtarWidgets() async {
    await getUserModel();
//    setState(() {});
  }

  Future getUserModel() async {
    var totalCredits = 0.0;
    _avtars = [];
    List<Widget> _transactions = [];
    List<TransactionModel> _transactionsFromDB = [];

    await CollectionRef.transactions
        .where("isApproved", isEqualTo: true)
        .where('transactionbetween',
            arrayContains: widget.requestModel.timebankId)
        .where('timebankid',
            isEqualTo: widget.requestModel
                .id) //because for one to many when transactions are created,
        //we are passing request id as the timebankid field in transactions model
        .orderBy("timestamp", descending: true)
        .get()
        .then(
          (value) => {
            logger.i(
                "==========================>>>>>>>>>> TRANSACTIONS RETURN CHECK " +
                    value.docs.length.toString()),
            value.docs.forEach((map) {
              var model =
                  TransactionModel.fromMap(map.data() as Map<String, dynamic>);
              _transactionsFromDB.add(model);
            })
          },
        );

    for (var i = 0; i < _transactionsFromDB.length; i++) {
      var transaction = _transactionsFromDB[i];
      if (transaction != null && transaction.to != null) {
        Widget item = Offstage();
        var _userModel;

        if (transaction.type != 'SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE') {
          if (transaction.to != null) {
            _userModel = await getUserForId(sevaUserId: transaction.to!);
          }
          totalCredits = totalCredits + (transaction.credits ?? 0);
          item = getCompletedResultView(
            context,
            _userModel,
            transaction,
          );
        }

        _transactions.add(item);
      }
    }

    totalCredits = double.parse(totalCredits.toStringAsFixed(2));
    _avtars.add(getTotalSpending("$totalCredits"));
    //_avtars.addAll(_pendingAvtars);
    _avtars.addAll(_transactions);
    setState(() {});
  }

  Widget getTotalSpending(String credits) {
    var spendingWidget = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              S.of(context).total_spent,
              style: TextStyle(
                  fontSize: 16,
                  color: HexColor('#606670'),
                  fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              //lib/assets/images/coins.png
              Container(
                height: 25,
                width: 25,
                child: Image.asset('lib/assets/images/coins.png'),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                credits,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: HexColor('#9B9B9B'),
                ),
              ),
              Text(
                " " + S.of(context).seva_credits,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: HexColor('#9B9B9B'),
                ),
              ),
            ],
          )
        ],
      ),
    );
    return Column(
      children: <Widget>[
        spendingWidget,
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  String formattedDate(UserModel user) {
    return DateFormat(
            'MMMM dd, yyyy @ h:mm a', Locale(getLangTag()).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(
              widget.requestModel.postTimestamp!),
          timezoneAbb: user.timezone!),
    );
  }

  Widget getCompletedResultView(
    BuildContext parentContext,
    UserModel usermodel,
    TransactionModel transactionModel,
  ) {
    return Container(
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                child: Container(
                  height: 45,
                  width: 45,
                  child: FadeInImage.assetNetwork(
                    placeholder: 'lib/assets/images/profile.png',
                    image: usermodel.photoURL ?? defaultUserImageURL,
                  ),
                ),
              ),
              Container(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      usermodel.fullname!,
                      style: Theme.of(parentContext).textTheme.titleMedium,
                    ),
                    Text(
                      formattedDate(
                        usermodel,
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8, 5, 8),
                    child: Icon(
                      Icons.monetization_on,
                      size: 25,
                      color: Colors.yellow,
                    ),
                  ),
                  Text(
                    transactionModel.credits.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPendingResultView(BuildContext parentContext, UserModel user,
      TransactionModel transactionModel) {
    if (user.sevaUserID == null) return Offstage();
    return Slidable(
        key: ValueKey(user.sevaUserID),
        endActionPane: ActionPane(
          motion: BehindMotion(),
          children: <Widget>[],
        ),
        startActionPane: ActionPane(
          motion: BehindMotion(),
          children: <Widget>[],
        ),
        child: GestureDetector(
          onTap: () {
            // setState(() {
            //   isProgressBarActive = true;
            // });

            // var notificationId =
            //     await RequestNotificationManager.getNotificationId(
            //         user, requestModel);
            //     notificationId);
            // setState(() {
            //   isProgressBarActive = false;
            // });
            // showMemberClaimConfirmation(
            //     context: context,
            //     notificationId: notificationId,
            //     requestModel: requestModel,
            //     userId: user.sevaUserID,
            //     userModel: user,
            //     credits: transactionModel.credits);
          },
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(user.photoURL ?? defaultUserImageURL),
              ),
              title: Text(user.fullname!),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: formattedDate(
                        user,
                      ),
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Container(
                height: 40,
                padding: EdgeInsets.only(bottom: 10),
                child: CustomElevatedButton(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: StadiumBorder(),
                  color: Colors.indigo,
                  textColor: Colors.white,
                  elevation: 5,
                  onPressed: () async {
                    var notificationId =
                        await RequestNotificationManager.getNotificationId(
                      user,
                      widget.requestModel,
                    );

                    if (widget.requestModel.requestMode ==
                        RequestMode.PERSONAL_REQUEST) {
                      // showLinearProgress();
                      var canApproveTransaction =
                          await SevaCreditLimitManager.hasSufficientCredits(
                        credits: transactionModel.credits!.toDouble(),
                        userId: SevaCore.of(context).loggedInUser.sevaUserID!,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity!,
                        email: SevaCore.of(context).loggedInUser.email!,
                      );

                      if (!canApproveTransaction.hasSuffiientCredits) {
                        showDiologForMessage(
                          S.of(context).notifications_insufficient_credits,
                          context,
                        );
                        return;
                      }
                    }

                    showMemberClaimConfirmation(
                      context: context,
                      notificationId: notificationId,
                      requestModel: widget.requestModel,
                      userId: user.sevaUserID!,
                      userModel: user,
                      credits: transactionModel.credits!,
                    );
                  },
                  child: Text(S.of(context).pending,
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
        ));
  }

  late BuildContext linearProgressForBalanceCheck;

  void showLinearProgress() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          linearProgressForBalanceCheck = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).hang_on),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }
//
//  Future<Widget> getNotificationRequestCompletedWidget(
//    RequestModel model,
//    String userId,
//    String notificationId,
//  ) async {
//    TransactionModel transactionModel = null;
//    for (int i = 0; i < model.transactions.length; i++) {
//      if (model.transactions[i].to == userId) {
//        transactionModel = model.transactions[i];
//      }
//    }
//    if (transactionModel == null) {
//      return Offstage();
//    }
//    UserModel user = await FirestoreManager.getUserForId(sevaUserId: userId);
//    if (user == null || user.sevaUserID == null) return Offstage();
//    return Slidable(
//      actionPane: SlidableBehindActionPane(),
//      actions: <Widget>[],
//      secondaryActions: <Widget>[],
//      child: GestureDetector(
//        onTap: () async {
//          if (model.requestMode == RequestMode.PERSONAL_REQUEST) {
//            //here credits are approved
//
//          }
//          showMemberClaimConfirmation(
//              context: context,
//              notificationId: notificationId,
//              requestModel: model,
//              userId: userId,
//              userModel: user,
//              credits: transactionModel.credits);
//        },
//        child: Container(
//          margin: notificationPadding,
//          decoration: notificationDecoration,
//          child: ListTile(
//            leading: CircleAvatar(
//              backgroundImage:
//                  NetworkImage(user.photoURL ?? defaultUserImageURL),
//            ),
//            title: Text(model.title),
//            subtitle: RichText(
//              text: TextSpan(
//                children: [
//                  TextSpan(
//                    text:
//                        '${user.fullname} ${S.of(context).completed_task_in} ',
//                    style: TextStyle(
//                      color: Colors.grey,
//                    ),
//                  ),
//                  TextSpan(
//                    text: () {
//                      return '${transactionModel.credits} ${S.of(context).hour(transactionModel.credits)}';
//                    }(),
//                    style: TextStyle(
//                      color: Colors.black,
//                    ),
//                  ),
//                  TextSpan(
//                    text: () {
//                      return ', ${S.of(context).notifications_waiting_for_approval}';
//                    }(),
//                    style: TextStyle(
//                      color: Colors.grey,
//                    ),
//                  )
//                ],
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }

  void showDiologForMessage(String dialogText, BuildContext dialogContext) {
    showDialog(
        context: dialogContext,
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
        });
  }

  Future<void> showMemberClaimConfirmation({
    BuildContext? context,
    UserModel? userModel,
    RequestModel? requestModel,
    String? notificationId,
    String? userId,
    num? credits,
  }) async {
    await showDialog(
        context: context!,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: SizedBox(
              width: 400,
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _getCloseButton(viewContext),
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
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Center(child: getBio(userModel)),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "${S.of(context).by_approving_you_accept} ${userModel.fullname} ${S.of(context).has_worked_for} $credits ${credits! > 1 ? S.of(context).hours : S.of(context).hour}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 5,
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: Text(
                              S.of(context).approve,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              // Once approved take for feeddback
                              Navigator.of(viewContext).pop();
                              setState(() {
                                isProgressBarActive = true;
                                isRemoving = false;
                              });
                              await checkForFeedback(
                                userId: userId!,
                                user: userModel,
                                context: context,
                                model: requestModel!,
                                notificationId: notificationId!,
                                credits: credits,
                              );
                              // approveMemberClaim(
                              //   context: context,
                              //   model: requestModel,
                              //   notificationId: notificationId,
                              //   user: userModel,
                              //   userId: userId,
                              //   credits: credits,
                              // );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CustomElevatedButton(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 5,
                            textColor: Colors.white,
                            color: Theme.of(context).colorScheme.secondary,
                            child: Text(
                              S.of(context).reject,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              // reject the claim
                              Navigator.of(viewContext).pop();

                              setState(() {
                                isRemoving = true;
                                isProgressBarActive = true;
                              });
                              await rejectMemberClaimForEvent(
                                context: context,
                                model: requestModel!,
                                notificationId: notificationId!,
                                user: userModel,
                                userId: userId!,
                                credits: credits,
                                timebankModel: widget.timebankModel!,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future rejectMemberClaimForEvent({
    RequestModel? model,
    String? userId,
    BuildContext? context,
    UserModel? user,
    String? notificationId,
    num? credits,
    TimebankModel? timebankModel,
  }) async {
    List<TransactionModel> transactions =
        model!.transactions!.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    // model.transactions = transactions.map((t) {
    //   return t;
    // }).toList();
    // await FirestoreManager.rejectRequestCompletion(
    //   model: model,
    //   userId: userId!,
    //   communityid: model.participantDetails?[user!.email] != null
    //       ? model.participantDetails![user!.email!]['communityId']
    //       : model.communityId,
    // );

    var loggedInUser = SevaCore.of(context!).loggedInUser;

    setState(() {
      isProgressBarActive = false;
    });

    ParticipantInfo sender, reciever;
    switch (widget.requestModel.requestMode ?? RequestMode.PERSONAL_REQUEST) {
      case RequestMode.PERSONAL_REQUEST:
        sender = ParticipantInfo(
          id: loggedInUser.sevaUserID,
          name: loggedInUser.fullname,
          photoUrl: loggedInUser.photoURL,
          type: ChatType.TYPE_PERSONAL,
        );
        break;

      case RequestMode.TIMEBANK_REQUEST:
        sender = ParticipantInfo(
          id: timebankModel!.id,
          type: timebankModel.parentTimebankId ==
                  FlavorConfig
                      .values.timebankId //check if timebank is primary timebank
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
          name: timebankModel.name,
          photoUrl: timebankModel.photoUrl,
        );
        break;
    }

    reciever = ParticipantInfo(
      id: user!.sevaUserID!,
      name: user.fullname,
      photoUrl: user.photoURL,
      type: ChatType.TYPE_PERSONAL,
    );

    var claimedRequestStatus = ClaimedRequestStatusModel(
      isAccepted: false,
      adminEmail: SevaCore.of(context).loggedInUser.email,
      requesterEmail: user.email,
      id: model.id,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      credits: credits,
    );

    List<String> showToCommunities = [];
    try {
      String communityId1 =
          widget.requestModel.participantDetails![user.email]['communityId'];
      String communityId2 = widget.requestModel.communityId!;

      if (communityId1 != null &&
          communityId2 != null &&
          communityId1.isNotEmpty &&
          communityId2.isNotEmpty &&
          communityId1 != communityId2) {
        showToCommunities = [communityId1, communityId2];
      }
    } on Exception catch (e) {
      logger.e(e);
    }
    if (widget.requestModel.participantDetails![sender])
      createAndOpenChat(
        showToCommunities:
            showToCommunities.isNotEmpty ? showToCommunities : null!,
        interCommunity: showToCommunities.isNotEmpty,
        isTimebankMessage:
            widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST,
        context: context,
        timebankId: model.timebankId!,
        communityId: loggedInUser.currentCommunity!,
        sender: sender,
        reciever: reciever,
        isFromRejectCompletion: true,
        feedId: widget.requestModel.id!, // Added required feedId
        entityId: user.sevaUserID!, // Added required entityId
        // openFullScreen: ,
        onChatCreate: () {
          FirestoreManager.saveRequestFinalAction(
            model: claimedRequestStatus,
          );

          if (widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
            FirestoreManager.readUserNotification(
                notificationId!, SevaCore.of(context).loggedInUser.email!);
          } else {
            readTimeBankNotification(
              notificationId: notificationId!,
              timebankId: widget.requestModel.timebankId!,
            );
          }

          Navigator.of(context).pop();
        },
      );
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio!.length < 100) {
        return Text(
          userModel.bio!,
          textAlign: TextAlign.center,
        );
      }
      return Container(
        height: 100,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            userModel.bio!,
            maxLines: null,
            overflow: null,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(S.of(context).email_not_updated),
    );
  }

  // Future approveMemberClaim(
  //     {String userId,
  //     UserModel user,
  //     BuildContext context,
  //     RequestModel model,
  //     String notificationId,
  //     num credits}) async {
  //   //request for feedback;
  //   await checkForFeedback(
  //     userId: userId,
  //     user: user,
  //     context: context,
  //     model: model,
  //     notificationId: notificationId,
  //     sevaCore: SevaCore.of(context),
  //     credits: credits,
  //   );
  // }

  // Future<Map> responseFromFeedback() async {
  //   Map results;
  //   switch (Provider.of<RequestDetailsEnroute>(context, listen: false)
  //       .requestRoutePath) {
  //     case RequestRoutePath.ProjectRequestRoute:
  //       results = await Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (BuildContext context) {
  //             return ReviewFeedback(
  //               feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
  //             );
  //           },
  //         ),
  //       );
  //       break;
  //     case RequestRoutePath.ElasticSearchRoute:
  //       results = await ExtendedNavigator.ofRouter<RequestsRouter>()
  //           .pushReviewFeedbackFromRequests(
  //         feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
  //       );
  //       break;
  //     case RequestRoutePath.RequestsRoute:
  //       results = await ExtendedNavigator.ofRouter<RequestsRouter>()
  //           .pushReviewFeedbackFromRequests(
  //         feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
  //       );
  //       break;
  //   }
  //   return results;
  // }

  Future checkForFeedback({
    String? userId,
    UserModel? user,
    RequestModel? model,
    String? notificationId,
    BuildContext? context,
    num? credits,
  }) async {
    // Map results = await ExtendedNavigator.ofRouter<inRoutePrefix.Router>()
    //     .pushReviewFeedback(
    //   feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
    // );

    // widget.tim

    Map results = await Navigator.of(context!).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback(
          feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
        );
      },
    ));

    // await ExtendedNavigator.ofRouter<RequestsRouter>()
    //     .pushReviewFeedbackFromRequests(
    //   feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
    // );

    if (results != null && results.containsKey('selection')) {
      log("???????????????????????????" +
          results.containsKey('selection').toString());

      await handleVolunterFeedbackForTrustWorthynessNRealiablityScore(
          FeedbackType.FOR_REQUEST_VOLUNTEER, results, model!, user!);
      onActivityResult(
        requestModel: model,
        userId: userId!,
        notificationId: notificationId!,
        context: context,
        reviewer: model.email!,
        reviewed: user.email!,
        requestId: model.id!,
        results: results,
        credits: credits!,
        reciever: user,
      );
    } else {
      setState(() {
        isProgressBarActive = false;
      });
    }
  }

  Future updateUserData(String reviewerEmail, String reviewedEmail) async {
    var user2 =
        await FirestoreManager.getUserForEmail(emailAddress: reviewedEmail);
    var user1 =
        await FirestoreManager.getUserForEmail(emailAddress: reviewerEmail);
    if (user1.pastHires == null) {
      user1.pastHires = [];
    }
    var hired = user2.sevaUserID!.trim();
    if (!user1.pastHires!.contains(hired)) {
      var reportedUsersList = [];
      for (var i = 0; i < user1.pastHires!.length; i++) {
        reportedUsersList.add(user1.pastHires![i]);
      }
      reportedUsersList.add(hired);
      user1.pastHires = List<String>.from(reportedUsersList);
      await FirestoreManager.updateUser(user: user1);
    }
  }

  Future onActivityResult(
      {SevaCore? sevaCore,
      RequestModel? requestModel,
      String? userId,
      String? notificationId,
      BuildContext? context,
      Map? results,
      String? reviewer,
      String? reviewed,
      String? requestId,
      UserModel? reciever,
      num? credits}) async {
    // adds review to firestore
    await CollectionRef.reviews.add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results!['selection'],
      "device_info": results['device_info'],
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
    await updateUserData(reviewer!, reviewed!);
    var claimedRequestStatus = ClaimedRequestStatusModel(
        isAccepted: true,
        adminEmail: sevaCore!.loggedInUser.email,
        requesterEmail: reviewed,
        id: requestId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        credits: credits);
    await FirestoreManager.saveRequestFinalAction(
      model: claimedRequestStatus,
    );
    await sendMessageToMember(
        loggedInUser: sevaCore.loggedInUser,
        requestModel: requestModel!,
        receiver: reciever!,
        message: results['comment'] ?? S.of(context!).no_comments);
    await approveTransaction(
        requestModel, userId!, notificationId!, sevaCore, reciever.email!);
  }

  Future approveTransaction(RequestModel model, String userId,
      String notificationId, SevaCore sevaCore, String email) async {
    await FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity!,
      memberCommunityId: model.participantDetails![email] != null
          ? model.participantDetails![email]['communityId']
          : model.communityId,
    );

    if (model.requestMode == RequestMode.PERSONAL_REQUEST) {
      await FirestoreManager.readUserNotification(
          notificationId, sevaCore.loggedInUser.email!);
    } else {
      await FirestoreManager.readTimeBankNotification(
        notificationId: notificationId,
        timebankId: model.timebankId!,
      );
    }
    setState(() {
      isProgressBarActive = false;
    });
    Navigator.pop(context);
  }

  Future<void> sendMessageToMember({
    UserModel? loggedInUser,
    UserModel? receiver,
    RequestModel? requestModel,
    String? message,
  }) async {
    ParticipantInfo sender = ParticipantInfo(
      id: requestModel!.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.sevaUserID
          : requestModel.timebankId,
      photoUrl: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.photoURL
          : widget.timebankModel!.photoUrl,
      name: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser!.fullname
          : widget.timebankModel!.name,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : widget.timebankModel!.parentTimebankId ==
                  FlavorConfig.values.timebankId
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: receiver!.sevaUserID,
      photoUrl: receiver.photoURL,
      name: receiver.fullname,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : widget.timebankModel!.parentTimebankId ==
                  FlavorConfig.values.timebankId
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );
    await sendBackgroundMessage(
        messageContent: getReviewMessage(
            reviewMessage: message,
            userName: loggedInUser!.fullname!,
            context: context,
            requestTitle: requestModel.title,
            isForCreator: false),
        reciever: reciever,
        isTimebankMessage:
            requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                ? false
                : true,
        timebankId: requestModel!.timebankId!,
        communityId: loggedInUser.currentCommunity!,
        sender: sender);
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

  EdgeInsets get notificationPadding => EdgeInsets.fromLTRB(5, 5, 5, 0);

  Decoration get notificationDecoration => ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        color: Colors.white,
        shadows: shadowList,
      );

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  Widget get notificationShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }
}

//   Widget completedRequestWidget(RequestModel model) {
//     return Card(
//       child: ListTile(
//         title: Text(model.title + 'Onetomanycheck'),
//         leading: FutureBuilder(
//           future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return CircleAvatar();
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircleAvatar();
//             }
//             UserModel user = snapshot.data;
//             if (user == null) {
//               return CircleAvatar(
//                 backgroundImage: NetworkImage(defaultUserImageURL),
//               );
//             }
//             return UserProfileImage(
//               timebankModel: widget.timebankModel,
//               userId: user.sevaUserID,
//               width: 40,
//               height: 40,
//               email: user.email,
//               photoUrl: user.photoURL,
//             );
// //              CircleAvatar(
// //              backgroundImage:
// //                  NetworkImage(user.photoURL ?? defaultUserImageURL),
// //            );
//           },
//         ),
//         trailing: () {
//           TransactionModel transmodel =
//               model.transactions.firstWhere((transaction) {
//             return transaction.to ==
//                 BlocProvider.of<AuthBloc>(context).user.sevaUserID;
//           });
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Text('${transmodel.credits}'),
//               Text(S.of(context).seva_credits,
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: -0.2,
//                   )),
//             ],
//           );
//         }(),
//         subtitle: FutureBuilder(
//           future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Text('');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Text('');
//             }
//             UserModel user = snapshot.data;
//             if (user == null) {
//               return Text('');
//             }
//             return Text('${user.fullname}');
//           },
//         ),
//       ),
//     );
//   }
