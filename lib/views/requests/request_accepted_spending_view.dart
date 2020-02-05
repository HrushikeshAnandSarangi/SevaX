import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:shimmer/shimmer.dart';

import '../core.dart';

class RequestAcceptedSpendingView extends StatefulWidget {
  final RequestModel requestModel;

  RequestAcceptedSpendingView({@required this.requestModel});

  @override
  _RequestAcceptedSpendingState createState() =>
      _RequestAcceptedSpendingState();
}

class _RequestAcceptedSpendingState extends State<RequestAcceptedSpendingView> {
  List<Widget> _avtars = [];
  bool noTransactionAvailable = false;
  List<Widget> _pendingAvtars = [];
  List<NotificationsModel> pendingRequests = [];
  bool shouldReload = true;
  bool isProgressBarActive = false;
  bool isRemoving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isProgressBarActive) {
      return AlertDialog(
        title: Text(isRemoving ? 'Redirecting to messages' : 'Completing task'),
        content: LinearProgressIndicator(),
      );
    }
    if (shouldReload) {
      _updatePendingAvtarWidgets();
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
    pendingRequests = [];
    shouldReload = true;
    noTransactionAvailable = false;
//    setState(() {
//      isProgressBarActive = false;
//    });
  }

  Future _updatePendingAvtarWidgets() async {
    shouldReload = false;
    var notifications = await FirestoreManager.getCompletedNotifications(
        SevaCore.of(context).loggedInUser.email,
        SevaCore.of(context).loggedInUser.currentCommunity);
    pendingRequests = [];
    _pendingAvtars = [];
    for (var i = 0; i < notifications.length; i++) {
      if (notifications[i].type == NotificationType.RequestCompleted) {
        pendingRequests.add(notifications[i]);
      }
    }
    _pendingAvtars = [];
    for (int i = 0; i < pendingRequests.length; i++) {
      NotificationsModel notification = pendingRequests[i];
      RequestModel model = RequestModel.fromMap(notification.data);
      Widget item = await getNotificationRequestCompletedWidget(
        model,
        notification.senderUserId,
        notification.id,
      );
      _pendingAvtars.add(item);
    }
    await getUserModel();
    setState(() {});
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
              backgroundImage: NetworkImage(user.photoURL),
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
              Text('Yang bucks',
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
          var _userModel = await getUserForId(sevaUserId: transaction.to);
          totalCredits = totalCredits + transaction.credits;
          print("All transactions:$transaction");
          Widget item = getSpendingResultView(
            context,
            _userModel,
            transaction,
          );
          _localAvtars.add(item);
        }
      }
    }
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
            'Total spendings',
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

  Widget getSpendingResultView(BuildContext parentContext, UserModel usermodel,
      TransactionModel transactionModel) {
    print("Context bcsvdygdsjbd:$parentContext");
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
                      DateFormat('MMMM dd, yyyy @ h:mm a').format(
                        getDateTimeAccToUserTimezone(
                            dateTime: DateTime.fromMillisecondsSinceEpoch(
                                widget.requestModel.postTimestamp),
                            timezoneAbb: usermodel.timezone),
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

  Future<Widget> getNotificationRequestCompletedWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) async {
    UserModel user = await FirestoreManager.getUserForId(sevaUserId: userId);
    if (user == null || user.sevaUserID == null) return Offstage();
    TransactionModel transactionModel =
        model.transactions?.firstWhere((transaction) {
      return transaction.to == userId;
    });

    return Slidable(
        delegate: SlidableBehindDelegate(),
        actions: <Widget>[],
        secondaryActions: <Widget>[],
        child: GestureDetector(
          onTap: () {
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
                backgroundImage: NetworkImage(user.photoURL),
              ),
              title: Text(model.title),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${user.fullname} completed the task in ',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return '${transactionModel.credits} hours';
                      }(),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return ', waiting for your approval.';
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

  void showMemberClaimConfirmation(
      {BuildContext context,
      UserModel userModel,
      RequestModel requestModel,
      String notificationId,
      String userId,
      double credits}) {
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
                      backgroundImage: NetworkImage(userModel.photoURL),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(userModel.email),
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
//                  Padding(
//                    padding: EdgeInsets.all(8.0),
//                    child: Text(
//                      userModel.bio == null
//                          ? "Bio not yet updated"
//                          : userModel.bio,
//                      maxLines: 5,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//                  ),
                  getBio(userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "By approving, you accept that ${userModel.fullname} has worked for $credits hours",
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          'Reject',
                          style: TextStyle(color: Colors.red),
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
                              userId: userId);
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
                              userId: userId);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future rejectMemberClaimForEvent(
      {RequestModel model,
      String userId,
      BuildContext context,
      UserModel user,
      String notificationId}) async {
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
    // creating chat
    String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    List users = [user.email, loggedInEmail];
//    users.sort();
    ChatModel chatModel = ChatModel();
    chatModel.user1 = users[0];
    chatModel.user2 = users[1];

    await createChat(
      chat: chatModel,
//        communityId: SevaCore.of(context).loggedInUser.currentCommunity
    );

    setState(() {
      isProgressBarActive = false;
    });
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatView(
                useremail: user.email,
                chatModel: chatModel,
                isFromRejectCompletion: true,
              )),
    );

    await FirestoreManager.readUserNotification(
        notificationId, SevaCore.of(context).loggedInUser.email);
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
      child: Text("Bio not yet updated"),
    );
  }

  Future approveMemberClaim({
    String userId,
    UserModel user,
    BuildContext context,
    RequestModel model,
    String notificationId,
  }) async {
    //request for feedback;
    await checkForFeedback(
        userId: userId,
        user: user,
        context: context,
        model: model,
        notificationId: notificationId,
        sevaCore: SevaCore.of(context));
  }

  Future checkForFeedback(
      {String userId,
      UserModel user,
      RequestModel model,
      String notificationId,
      BuildContext context,
      SevaCore sevaCore}) async {
    Map results = await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) {
        return ReviewFeedback.forVolunteer(
          forVolunteer: true,
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

  Future onActivityResult({
    SevaCore sevaCore,
    RequestModel requestModel,
    String userId,
    String notificationId,
    BuildContext context,
    Map results,
    String reviewer,
    String reviewed,
    String requestId,
    UserModel user,
  }) async {
    // adds review to firestore
    await Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "requestId": requestId,
      "comments": (results['didComment'] ? results['comment'] : "No comments")
    });
    await updateUserData(reviewer, reviewed);
    await approveTransaction(requestModel, userId, notificationId, sevaCore);
  }

  Future approveTransaction(RequestModel model, String userId,
      String notificationId, SevaCore sevaCore) async {
    List<TransactionModel> transactions =
        model.transactions.map((t) => t).toList();

    model.transactions = transactions.map((t) {
      if (t.to == userId && t.from == sevaCore.loggedInUser.sevaUserID) {
        TransactionModel editedTransaction = t;
        editedTransaction.isApproved = true;
        return editedTransaction;
      }
      return t;
    }).toList();

    if (model.transactions.where((model) => model.isApproved).length ==
        model.numberOfApprovals) {}

    await FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity,
    );

    await FirestoreManager.readUserNotification(
        notificationId, sevaCore.loggedInUser.email);
    setState(() {
      isProgressBarActive = false;
    });
    Navigator.pop(context);
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
