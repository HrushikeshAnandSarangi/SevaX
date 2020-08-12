import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/claimedRequestStatus.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
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
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';
import '../core.dart';

class RequestAcceptedSpendingView extends StatefulWidget {
  RequestModel requestModel;

  final TimebankModel timebankModel;
  RequestAcceptedSpendingView(
      {@required this.requestModel, this.timebankModel});

  @override
  _RequestAcceptedSpendingState createState() =>
      _RequestAcceptedSpendingState();
}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {
  List<Widget> _avtars = [];
  bool noTransactionAvailable = false;
  List<Widget> _pendingAvtars = [];
  List<NotificationsModel> pendingRequests = [];
  // RequestModel requestModel;
//  bool shouldReload = true;
  bool isProgressBarActive = false;
  bool isRemoving = false;

  _RequestAcceptedSpendingState() {}

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      RequestManager.getRequestStreamById(requestId: widget.requestModel.id)
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
        title: Text(isRemoving
            ? AppLocalizations.of(context).translate('requests', 'redirection')
            : AppLocalizations.of(context)
                .translate('requests', 'completing_task')),
        content: LinearProgressIndicator(),
      );
    }
    return Scaffold(
      body: listItems,
    );
  }

  Widget get listItems {
    if (_avtars.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
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
//    shouldReload = false;
//    var notifications = await FirestoreManager.getCompletedNotifications(
//        SevaCore.of(context).loggedInUser.email,
//        SevaCore.of(context).loggedInUser.currentCommunity);
//    pendingRequests = [];
//    _pendingAvtars = [];
//    for (var i = 0; i < notifications.length; i++) {
//      if (notifications[i].type == NotificationType.RequestCompleted) {
//        pendingRequests.add(notifications[i]);
//      }
//    }
//    _pendingAvtars = [];
//    for (int i = 0; i < pendingRequests.length; i++) {
//      NotificationsModel notification = pendingRequests[i];
//      RequestModel model = RequestModel.fromMap(notification.data);
//      Widget item = await getNotificationRequestCompletedWidget(
//        model,
//        notification.senderUserId,
//        notification.id,
//      );
//      _pendingAvtars.add(item);
//    }
    await getUserModel();
//    setState(() {});
  }

  Widget completedRequestWidget(RequestModel model) {
    return Card(
      child: ListTile(
        title: Text(model.title),
        leading: FutureBuilder(
          future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return CircleAvatar();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar();
            }
            UserModel user = snapshot.data;
            if (user == null) {
              return CircleAvatar(
                backgroundImage: NetworkImage(defaultUserImageURL),
              );
            }
            return CircleAvatar(
              backgroundImage:
                  NetworkImage(user.photoURL ?? defaultUserImageURL),
            );
          },
        ),
        trailing: () {
          TransactionModel transmodel =
              model.transactions.firstWhere((transaction) {
            return transaction.to ==
                SevaCore.of(context).loggedInUser.sevaUserID;
          });
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('${transmodel.credits}'),
              Text(
                  AppLocalizations.of(context)
                      .translate('requests', 'seva_credits'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  )),
            ],
          );
        }(),
        subtitle: FutureBuilder(
          future: FirestoreManager.getUserForId(sevaUserId: model.sevaUserId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('');
            }
            UserModel user = snapshot.data;
            if (user == null) {
              return Text('');
            }
            return Text('${user.fullname}');
          },
        ),
      ),
    );
  }

  Future getUserModel() async {
    var totalCredits = 0.0;
    _avtars = [];
    List<Widget> _localAvtars = [];
    if (widget.requestModel.transactions != null) {
      for (var i = 0; i < widget.requestModel.transactions.length; i++) {
        var transaction = widget.requestModel.transactions[i];
        if (transaction != null && transaction.to != null) {
          Widget item = Offstage();
          var _userModel = await getUserForId(sevaUserId: transaction.to);
          if (transaction.isApproved) {
            totalCredits = totalCredits + transaction.credits;
            item = getCompletedResultView(
              context,
              _userModel,
              transaction,
            );
          } else {
//            totalCredits = totalCredits + transaction.credits;
            item = getPendingResultView(
              context,
              _userModel,
              transaction,
            );
          }
          _localAvtars.add(item);
        }
      }
    }
    totalCredits = num.parse(totalCredits.toStringAsFixed(2));
    _avtars.add(getTotalSpending("$totalCredits"));
    _avtars.addAll(_pendingAvtars);
    _avtars.addAll(_localAvtars);
    setState(() {});
  }

  Widget getTotalSpending(String credits) {
    var spendingWidget = Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('requests', 'total_spent'),
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontFamily: 'Europa',
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.monetization_on,
                size: 40,
                color: Colors.yellow,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                credits,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Europa',
                  color: Colors.black,
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
    return DateFormat('MMMM dd, yyyy @ h:mm a',
            Locale(AppConfig.prefs.getString('language_code')).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(
              widget.requestModel.postTimestamp),
          timezoneAbb: user.timezone),
    );
  }

  Widget getCompletedResultView(BuildContext parentContext, UserModel usermodel,
      TransactionModel transactionModel) {
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
                    image: defaultUserImageURL != null
                        ? usermodel.photoURL
                        : defaultUserImageURL,
                  ),
                ),
              ),
              Container(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      usermodel.fullname,
                      style: Theme.of(parentContext).textTheme.subhead,
                    ),
                    Text(
                      formattedDate(
                        usermodel,
                      ),
                      style:
                          TextStyle(color: Colors.grey, fontFamily: 'Europa'),
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
                      fontFamily: 'Europa',
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
    if (user == null || user.sevaUserID == null) return Offstage();
    return Slidable(
        delegate: SlidableBehindDelegate(),
        actions: <Widget>[],
        secondaryActions: <Widget>[],
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
              title: Text(user.fullname),
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
                child: RaisedButton(
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
                          await FirestoreManager.hasSufficientCredits(
                        credits: transactionModel.credits,
                        userId: SevaCore.of(context).loggedInUser.sevaUserID,
                      );
                      // Navigator.pop(linearProgressForBalanceCheck);

                      if (!canApproveTransaction) {
                        showDiologForMessage(
                          AppLocalizations.of(context)
                              .translate('requests', 'insufficient'),
                          context,
                        );
                        return;
                      }
                    }

                    showMemberClaimConfirmation(
                        context: context,
                        notificationId: notificationId,
                        requestModel: widget.requestModel,
                        userId: user.sevaUserID,
                        userModel: user,
                        credits: transactionModel.credits);
                  },
                  child: Text(
                      AppLocalizations.of(context)
                          .translate('requests', 'pending'),
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
        ));
  }

  BuildContext linearProgressForBalanceCheck;

  void showLinearProgress() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          linearProgressForBalanceCheck = createDialogContext;
          return AlertDialog(
            title: Text(
                AppLocalizations.of(context).translate('requests', 'hangon')),
            content: LinearProgressIndicator(),
          );
        });
  }

  Future<Widget> getNotificationRequestCompletedWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) async {
    TransactionModel transactionModel = null;
    for (int i = 0; i < model.transactions.length; i++) {
      if (model.transactions[i].to == userId) {
        transactionModel = model.transactions[i];
      }
    }
    if (transactionModel == null) {
      return Offstage();
    }
    UserModel user = await FirestoreManager.getUserForId(sevaUserId: userId);
    if (user == null || user.sevaUserID == null) return Offstage();
    return Slidable(
        delegate: SlidableBehindDelegate(),
        actions: <Widget>[],
        secondaryActions: <Widget>[],
        child: GestureDetector(
          onTap: () async {
            if (model.requestMode == RequestMode.PERSONAL_REQUEST) {
              //here credits are approved

            }
            showMemberClaimConfirmation(
                context: context,
                notificationId: notificationId,
                requestModel: model,
                userId: userId,
                userModel: user,
                credits: transactionModel.credits);
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
                          '${user.fullname} ${AppLocalizations.of(context).translate('requests', 'completed_task_in')} ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return '${transactionModel.credits} ${AppLocalizations.of(context).translate('requests', 'hours')}';
                      }(),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return ', ${AppLocalizations.of(context).translate('requests', 'waiting_for_approval')}';
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
  }

  void showDiologForMessage(String dialogText, BuildContext dialogContext) {
    showDialog(
        context: dialogContext,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogText),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context).translate('requests', 'ok'),
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

  Future<Widget> showMemberClaimConfirmation({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
    String userId,
    num credits,
  }) async {
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
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          userModel.photoURL ?? defaultUserImageURL),
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
                        "${AppLocalizations.of(context).translate('requests', 'about')} ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "${AppLocalizations.of(context).translate('requests', 'by_approving_that')} ${userModel.fullname} ${AppLocalizations.of(context).translate('requests', 'worked_for')} $credits ${AppLocalizations.of(context).translate('requests', 'hours')}",
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
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('requests', 'approve'),
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Europa'),
                          ),
                          onPressed: () async {
                            // Once approved take for feeddback
                            Navigator.pop(viewContext);
                            setState(() {
                              isProgressBarActive = true;
                              isRemoving = false;
                            });
                            approveMemberClaim(
                              context: context,
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                              userId: userId,
                              credits: credits,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('requests', 'reject'),
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Europa'),
                          ),
                          onPressed: () async {
                            // reject the claim
                            Navigator.pop(viewContext);
                            setState(() {
                              isRemoving = true;
                              isProgressBarActive = true;
                            });
                            await rejectMemberClaimForEvent(
                              context: context,
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                              userId: userId,
                              credits: credits,
                              timebankModel: widget.timebankModel,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future rejectMemberClaimForEvent({
    RequestModel model,
    String userId,
    BuildContext context,
    UserModel user,
    String notificationId,
    num credits,
    TimebankModel timebankModel,
  }) async {
    List<TransactionModel> transactions =
        model.transactions.map((t) => t).toList();
    transactions.removeWhere((t) => t.to == userId);

    model.transactions = transactions.map((t) {
      return t;
    }).toList();
    await FirestoreManager.rejectRequestCompletion(
      model: model,
      userId: userId,
      communityid: SevaCore.of(context).loggedInUser.currentCommunity,
    );

    var loggedInUser = SevaCore.of(context).loggedInUser;

    setState(() {
      isProgressBarActive = false;
    });

    ParticipantInfo sender, reciever;
    switch (widget.requestModel.requestMode) {
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
          id: timebankModel.id,
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
      id: user.sevaUserID,
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

    createAndOpenChat(
      isTimebankMessage:
          widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST,
      context: context,
      timebankId: model.timebankId,
      communityId: loggedInUser.currentCommunity,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
      onChatCreate: () {
        FirestoreManager.saveRequestFinalAction(
          model: claimedRequestStatus,
        );

        if (widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
          FirestoreManager.readUserNotification(
              notificationId, SevaCore.of(context).loggedInUser.email);
        } else {
          readTimeBankNotification(
            notificationId: notificationId,
            timebankId: widget.requestModel.timebankId,
          );
        }

        Navigator.pop(context);
      },
    );
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio.length < 100) {
        return Center(
          child: Text(userModel.bio),
        );
      }
      return Container(
        height: 100,
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
      child: Text(
          AppLocalizations.of(context).translate('requests', 'not_updated')),
    );
  }

  Future approveMemberClaim(
      {String userId,
      UserModel user,
      BuildContext context,
      RequestModel model,
      String notificationId,
      num credits}) async {
    //request for feedback;
    await checkForFeedback(
      userId: userId,
      user: user,
      context: context,
      model: model,
      notificationId: notificationId,
      sevaCore: SevaCore.of(context),
      credits: credits,
    );
  }

  Future checkForFeedback(
      {String userId,
      UserModel user,
      RequestModel model,
      String notificationId,
      BuildContext context,
      SevaCore sevaCore,
      num credits}) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback(
          feedbackType: FeedbackType.FOR_REQUEST_VOLUNTEER,
        );
      },
    ));

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
        credits: credits,
        reciever: user,
      );
    } else {}
  }

  Future updateUserData(String reviewerEmail, String reviewedEmail) async {
    var user2 =
        await FirestoreManager.getUserForEmail(emailAddress: reviewedEmail);
    var user1 =
        await FirestoreManager.getUserForEmail(emailAddress: reviewerEmail);
    if (user1.pastHires == null) {
      user1.pastHires = List<String>();
    }
    var hired = user2.sevaUserID.trim();
    if (!user1.pastHires.contains(hired)) {
      var reportedUsersList = List<String>();
      for (var i = 0; i < user1.pastHires.length; i++) {
        reportedUsersList.add(user1.pastHires[i]);
      }
      reportedUsersList.add(hired);
      user1.pastHires = reportedUsersList;
      await FirestoreManager.updateUser(user: user1);
    }
  }

  Future onActivityResult(
      {SevaCore sevaCore,
      RequestModel requestModel,
      String userId,
      String notificationId,
      BuildContext context,
      Map results,
      String reviewer,
      String reviewed,
      String requestId,
      UserModel reciever,
      num credits}) async {
    // adds review to firestore
    await Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "device_info": results['device_info'],
      "requestId": requestId,
      "comments": (results['didComment']
          ? results['comment']
          : AppLocalizations.of(context).translate('requests', 'no_comments'))
    });
    await updateUserData(reviewer, reviewed);
    var claimedRequestStatus = ClaimedRequestStatusModel(
        isAccepted: true,
        adminEmail: sevaCore.loggedInUser.email,
        requesterEmail: reviewed,
        id: requestId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        credits: credits);
    await FirestoreManager.saveRequestFinalAction(
      model: claimedRequestStatus,
    );
    await sendMessageToMember(
        loggedInUser: sevaCore.loggedInUser,
        requestModel: requestModel,
        receiver: reciever,
        message: results['comment'] ??
            AppLocalizations.of(context).translate('requests', 'no_comments'));
    await approveTransaction(requestModel, userId, notificationId, sevaCore);
  }

  Future approveTransaction(RequestModel model, String userId,
      String notificationId, SevaCore sevaCore) async {
    await FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity,
    );

    await FirestoreManager.readUserNotification(
        notificationId, sevaCore.loggedInUser.email);

//    if (model.projectId.isNotEmpty &&
//        model.approvedUsers.length <= model.numberOfApprovals) {
//      await FirestoreManager.updateProjectCompletedRequest(
//          projectId: model.projectId, requestId: model.id);
//    }

    setState(() {
      isProgressBarActive = false;
    });
    Navigator.pop(context);
  }

  Future<void> sendMessageToMember({
    UserModel loggedInUser,
    UserModel receiver,
    RequestModel requestModel,
    String message,
  }) async {
    ParticipantInfo sender = ParticipantInfo(
      id: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser.sevaUserID
          : requestModel.timebankId,
      photoUrl: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser.photoURL
          : widget.timebankModel.photoUrl,
      name: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? loggedInUser.fullname
          : widget.timebankModel.name,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : widget.timebankModel.parentTimebankId ==
                  '73d0de2c-198b-4788-be64-a804700a88a4'
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: receiver.sevaUserID,
      photoUrl: receiver.photoURL,
      name: receiver.fullname,
      type: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? ChatType.TYPE_PERSONAL
          : widget.timebankModel.parentTimebankId ==
                  '73d0de2c-198b-4788-be64-a804700a88a4'
              ? ChatType.TYPE_TIMEBANK
              : ChatType.TYPE_GROUP,
    );
    await sendBackgroundMessage(
        messageContent: message,
        reciever: reciever,
        context: context,
        isTimebankMessage:
            requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                ? true
                : false,
        timebankId: requestModel.timebankId,
        communityId: loggedInUser.currentCommunity,
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
