import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/reported_member_notification_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/data_managers/chat_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/chatview.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:shimmer/shimmer.dart';

class AdminNotificationViewHolder extends StatefulWidget {
  final String timebankId;

  AdminNotificationViewHolder({this.timebankId});

  @override
  State<StatefulWidget> createState() {
    return AdminNotificationsView();
  }
}

class AdminNotificationsView extends State<AdminNotificationViewHolder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationsModel>>(
      stream: FirestoreManager.getNotificationsForTimebank(
        timebankId: widget.timebankId,
        // communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      ),
      builder: (context_firestore, snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<NotificationsModel> notifications = snapshot.data;

        SevaCore.of(context).loggedInUser.notificationsRead =
            notifications.length;

        print(
            "Unread notifications ${SevaCore.of(context).loggedInUser.notificationsRead}");

        if (notifications.length == 0) {
          return Center(
            child: Text('No Notifications'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(bottom: 20),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            NotificationsModel notification = notifications.elementAt(index);
            switch (notification.type) {
              case NotificationType.RequestAccept:
                RequestModel model = RequestModel.fromMap(notification.data);
                return FutureBuilder<RequestModel>(
                    future: FirestoreManager.getRequestFutureById(
                      requestId: model.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // return Container();
                        return Container();
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      RequestModel model = snapshot.data;
                      return getNotificationAcceptedWidget(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                    });
                break;

              case NotificationType.RequestApprove:
                RequestModel model = RequestModel.fromMap(notification.data);
                return Offstage();
                // return getNotificationRequestApprovalWidget(
                //   model,
                //   notification.senderUserId,
                //   notification.id,
                //   context
                // );
                break;

              case NotificationType.RequestReject:
                RequestModel model = RequestModel.fromMap(notification.data);
                return Text("NotificationType.RequestReject");
                break;

              case NotificationType.JoinRequest:
                JoinRequestModel model =
                    JoinRequestModel.fromMap(notification.data);
                return FutureBuilder<UserModel>(
                    future: FirestoreManager.getUserForId(
                        sevaUserId: notification.senderUserId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container();
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return notificationShimmer;
                      }
                      UserModel user = snapshot.data;
                      return user != null && user.fullname != null
                          ? getJoinReuqestsNotificationWidget(
                              user,
                              notification.id,
                              model,
                              context,
                            )
                          : Offstage();
                    });
                break;

              case NotificationType.RequestCompleted:
                RequestModel model = RequestModel.fromMap(notification.data);
                return FutureBuilder<RequestModel>(
                    future: FirestoreManager.getRequestFutureById(
                        requestId: model.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container();
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      RequestModel model = snapshot.data;
                      return getNotificationRequestCompletedWidget(
                        model,
                        notification.senderUserId,
                        notification.id,
                      );
                    });
                break;
              case NotificationType.RequestCompletedApproved:
                RequestModel model = RequestModel.fromMap(notification.data);
                return Offstage();
                break;
              case NotificationType.RequestCompletedRejected:
                RequestModel model = RequestModel.fromMap(notification.data);
                return Text("NotificationType.RequestCompletedRejected");

                break;
              case NotificationType.TransactionCredit:
                // TODO: Handle this case.
                // TransactionModel model =
                //     TransactionModel.fromMap(notification.data);
                return Offstage();

              case NotificationType.TransactionDebit:
                TransactionModel model =
                    TransactionModel.fromMap(notification.data);
                return Offstage();
                // getNotificationDebit(
                //     model, notification.senderUserId, notification.id);
                break;
              case NotificationType.OfferAccept:
                OfferModel offerModel = OfferModel.fromMap(notification.data);
                return Text("NotificationType.OfferAccept");
                break;
              case NotificationType.OfferReject:
                return Text("NotificationType.OfferReject");
                break;
              case NotificationType.AcceptedOffer:
                return Text("NotificationType.AcceptedOffer");
                break;

              case NotificationType.RequestInvite:
                return Text("NotificationType.RequestInvite");
                break;

              //One to many timebank notification

              case NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  title: "Debited",
                  subTitle:
                      TimebankNotificationMessage.DEBIT_FULFILMENT_FROM_TIMEBANK
                          .replaceFirst(
                            '*n',
                            (data.classDetails.numberOfClassHours +
                                    data.classDetails.numberOfPreperationHours)
                                .toString(),
                          )
                          .replaceFirst('*name', data.classDetails.classHost)
                          .replaceFirst('*class', data.classDetails.classTitle),
                  entityName: data.classDetails.classHost,
                  onDismissed: () {
                    _clearNotification(
                        notification.timebankId, notification.id);
                  },
                );
                break;
              case NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  title: "Credited",
                  subTitle: TimebankNotificationMessage
                      .CREDIT_FROM_OFFER_APPROVED
                      .replaceFirst(
                          '*n', data.classDetails.numberOfClassHours.toString())
                      .replaceFirst('*class', data.classDetails.classTitle),
                  // photoUrl: data.participantDetails.photourl,
                  entityName: data.participantDetails.fullname,
                  onDismissed: () {
                    _clearNotification(
                        notification.timebankId, notification.id);
                  },
                );
                break;

              case NotificationType.TYPE_REPORT_MEMBER:
                ReportedMemberNotificationModel data =
                    ReportedMemberNotificationModel.fromMap(notification.data);
                return NotificationCard(
                  title: "Member Reported",
                  subTitle: TimebankNotificationMessage.MEMBER_REPORT
                      .replaceFirst('*name', data.reportedUserName),
                  photoUrl: data.reportedUserImage,
                  entityName: data.reportedUserName,
                  onDismissed: () {
                    _clearNotification(
                      notification.timebankId,
                      notification.id,
                    );
                  },
                );

              default:
                log("Unhandled timebank notification type ${notification.type} ${notification.id}");
                Crashlytics().log(
                    "Unhandled timebank notification type ${notification.type} ${notification.id}");
                return Container(
                    // child: Text(
                    //   "Unhandled notification type ${notification.type} ${notification.id}",
                    // ),
                    // color: Colors.red,
                    );
                break;
            }
          },
        );
      },
    );
  }

  void _clearNotification(String timebankId, String notificationId) {
    Firestore.instance
        .collection("timebanknew")
        .document(timebankId)
        .collection("notifications")
        .document(notificationId)
        .updateData(
      {"isRead": true},
    );
  }

  Widget getNotificationCredit(
    TransactionModel model,
    String userId,
    String notificationId,
  ) {
    return StreamBuilder<UserModel>(
        stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container();
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return notificationShimmer;
            return Text("getNotificationCredit");
          }
          UserModel user = snapshot.data;
          return Dismissible(
              key: Key(Utils.getUuid()),
              background: dismissibleBackground,
              onDismissed: (direction) {},
              child: GestureDetector(
                child: Container(
                  margin: notificationPadding,
                  decoration: notificationDecoration,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(user.photoURL ?? defaultUserImageURL),
                    ),
                    title: Text('Credited'),
                    subtitle: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            // text: 'Congrats, ${user.fullname} has credited ',
                            text: 'Congrats,  ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: () {
                              return FlavorConfig.appFlavor ==
                                      Flavor.HUMANITY_FIRST
                                  ? '${model.credits} Yang Bucks'
                                  : FlavorConfig.appFlavor == Flavor.TULSI
                                      ? '${model.credits} Tulsi Tokens'
                                      : '${model.credits} Seva Credits';
                            }(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: () {
                              return " have been credited to your account.";
                            }(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Europa',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                onTap: () {},
              ));
        });
  }

  Widget getNotificationDebit(
    TransactionModel model,
    String userId,
    String notificationId,
  ) {
    return StreamBuilder<UserModel>(
        stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container();
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return notificationShimmer;
            return Text('getNotificationDebit');
          }
          UserModel user = snapshot.data;
          return Dismissible(
            key: Key(Utils.getUuid()),
            background: dismissibleBackground,
            onDismissed: (direction) {
              FirestoreManager.readUserNotification(
                notificationId,
                SevaCore.of(context).loggedInUser.email,
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
                title: Text('Debited'),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: () {
                          return FlavorConfig.appFlavor == Flavor.HUMANITY_FIRST
                              ? '${model.credits} Yang Bucks '
                              : FlavorConfig.appFlavor == Flavor.TULSI
                                  ? '${model.credits} Tulsi TOkens '
                                  : '${model.credits} Seva Credits ';
                        }(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Europa',
                        ),
                      ),
                      TextSpan(
                        text: 'has been debited to ${user.fullname}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Europa',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget getNotificationRequestCompletedApproved(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    return StreamBuilder<UserModel>(
      stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return notificationShimmer;
          return Offstage();
        }
        UserModel user = snapshot.data;
        TransactionModel transactionModel =
            model.transactions.firstWhere((transaction) {
          return transaction.to == SevaCore.of(context).loggedInUser.sevaUserID;
        });
        return Dismissible(
          key: Key(Utils.getUuid()),
          background: dismissibleBackground,
          onDismissed: (direction) {
            FirestoreManager.readUserNotification(
              notificationId,
              SevaCore.of(context).loggedInUser.email,
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
                          '${user.fullname} approved the task completion for ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Europa',
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return '${transactionModel.credits} hours';
                      }(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Europa',
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getOfferAcceptNotification(
      OfferModel offermodel,
      String userId,
      String loggedinUserID,
      String notificationId,
      String requestid,
      List<NotificationsModel> notifications) {
    return StreamBuilder<UserModel>(
      stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return notificationShimmer;
          return Text('getOfferAcceptNotification');
        }
        UserModel user = snapshot.data;
        //bool fromOffer;

        return FutureBuilder<Object>(
            future: FirestoreManager.getUserForId(sevaUserId: loggedinUserID),
            builder: (context, snapshot) {
              UserModel loggedinUser = snapshot.data;
              return Slidable(
                delegate: SlidableBehindDelegate(),
                actions: <Widget>[
                  FutureBuilder<Object>(
                      future: FirestoreManager.getRequestFutureById(
                          requestId: requestid),
                      builder: (context, snapshot) {
                        RequestModel model = snapshot.data;
                        if (snapshot.hasError) return Container();
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // return notificationShimmer;
                          return Text('getOfferAcceptNotification');
                        }
                        return SlideAction(
                          onTap: () {
                            //fromOffer = true;
                            Set<String> acceptorList =
                                Set.from(model.acceptors);
                            acceptorList.add(loggedinUser.email);
                            model.acceptors = acceptorList.toList();
                            FirestoreManager.acceptRequest(
                              requestModel: model,
                              senderUserId: loggedinUserID,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                            );
                            offermodel.associatedRequest = requestid;
                            updateOfferWithRequest(offer: offermodel);

                            notifications.forEach((_notification) {
                              OfferModel _offer =
                                  OfferModel.fromMap(_notification.data);
                              if (_offer.id == offermodel.id) {
                                FirestoreManager.readUserNotification(
                                    _notification.id, loggedinUser.email);
                              }
                            });
                          },
                          child: Container(
                            padding: notificationPadding,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                              color: Colors.green,
                              shadows: shadowList,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                ],
                child: FutureBuilder<Object>(
                    future: FirestoreManager.getRequestFutureById(
                        requestId: requestid),
                    builder: (context, snapshot) {
                      RequestModel model = snapshot.data;
                      if (snapshot.hasError) return Container();
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // return notificationShimmer;
                        return Text('getOfferAcceptNotification');
                      }
                      return Container(
                        margin: notificationPadding,
                        decoration: notificationDecoration,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                user.photoURL ?? defaultUserImageURL),
                          ),
                          title: Text(model.title),
                          subtitle: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${user.fullname} sent request for your offer: ${getOfferTitle(offerDataModel: offermodel)} ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Europa',
                                  ),
                                ),
                                TextSpan(
                                  text: () {
                                    return '';
                                  }(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Europa',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            });
      },
    );
  }

  void approveTransaction(RequestModel model, String userId,
      String notificationId, SevaCore sevaCore) {
    FirestoreManager.approveRequestCompletion(
      model: model,
      userId: userId,
      communityId: sevaCore.loggedInUser.currentCommunity,
    );

    print("request completion chain ends here");

    // return;
    FirestoreManager.readTimeBankNotification(
      notificationId: notificationId,
      timebankId: model.timebankId,
    );
    //
  }

  void checkForFeedback({
    String userId,
    UserModel user,
    RequestModel model,
    String notificationId,
    BuildContext context,
    SevaCore sevaCore,
  }) async {
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
    // adds review to firestore
    Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "requestId": requestId,
      "comments": (results['didComment'] ? results['comment'] : "No comments")
    });
    approveTransaction(requestModel, userId, notificationId, sevaCore);
  }

  Widget getNotificationRequestCompletedWidget(
    RequestModel model,
    String userId,
    String notificationId,
  ) {
    TransactionModel transactionModel = model.transactions?.firstWhere(
        (transaction) => transaction.to == userId,
        orElse: () => null);
    return StreamBuilder<UserModel>(
      stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Container();
        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
        }
        UserModel user = snapshot.data;
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
                          text: '${user.fullname} completed the task in ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Europa',
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return '${transactionModel.credits ?? "0"} hours';
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
                            fontFamily: 'Europa',
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

  Widget getInvitedRequestsNotificationWidget(
      RequestInvitationModel requestInvitationModel,
      String notificationId,
      BuildContext buildContext,
      String timebankId,
      String communityId) {
    // assert(user != null);

    return Dismissible(
        background: dismissibleBackground,
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          String userEmail = SevaCore.of(buildContext).loggedInUser.email;
          FirestoreManager.readUserNotification(notificationId, userEmail);
        },
        child: GestureDetector(
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              title: Text("Join request"),
              leading: requestInvitationModel.timebankImage != null
                  ? CircleAvatar(
                      backgroundImage:
                          NetworkImage(requestInvitationModel.timebankImage),
                    )
                  : Offstage(),
              subtitle: Text(
                  '${requestInvitationModel.timebankName.toLowerCase()} has requested to join ${requestInvitationModel.requestTitle}, Tap to view join request'),
            ),
          ),
          onTap: () {
            showDialog(
                context: buildContext,
                builder: (context) {
                  return JoinRejectDialogView(
                    requestInvitationModel: requestInvitationModel,
                    timeBankId: timebankId,
                    notificationId: notificationId,
                    userModel: SevaCore.of(buildContext).loggedInUser,
                  );
                });
          },
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
                        fontFamily: 'Europa',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "About ${userModel.fullname}",
                        style: TextStyle(
                            fontFamily: 'Europa',
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "By approving, you accept that ${userModel.fullname} has worked for $credits hours",
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
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            'Approve',
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
                                notificationId: notificationId,
                                user: userModel,
                                userId: userId);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Reject',
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
                                notificationId: notificationId,
                                user: userModel,
                                userId: userId);
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
        });
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio.length < 100) {
        return Center(
          child: Text(
            userModel.bio,
            textAlign: TextAlign.center,
          ),
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
      child: Text("Bio not yet updated"),
    );
  }

  void approveMemberClaim({
    String userId,
    UserModel user,
    BuildContext context,
    RequestModel model,
    String notificationId,
  }) {
    //request for feedback;
    checkForFeedback(
      userId: userId,
      user: user,
      context: context,
      model: model,
      notificationId: notificationId,
      sevaCore: SevaCore.of(context),
    );
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
    // creating chat with a timebank
    String timebankId = model.timebankId;

    // String loggedInEmail = SevaCore.of(context).loggedInUser.email;
    List users = [user.email, timebankId];
    users.sort();
    ChatModel chatModel = ChatModel();
    chatModel.communityId = SevaCore.of(context).loggedInUser.currentCommunity;
    chatModel.user1 = users[0];
    chatModel.user2 = users[1];
    chatModel.timebankId = widget.timebankId;
    createChat(chat: chatModel);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatView(
                useremail: user.email,
                chatModel: chatModel,
                isFromRejectCompletion: true,
              )),
    );

    FirestoreManager.readTimeBankNotification(
      notificationId: notificationId,
      timebankId: widget.timebankId,
    );
  }

  Widget getJoinReuqestsNotificationWidget(
    UserModel user,
    String notificationId,
    JoinRequestModel model,
    BuildContext context,
  ) {
    return Dismissible(
        background: dismissibleBackground,
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          String userEmail = SevaCore.of(context).loggedInUser.email;
          FirestoreManager.readUserNotification(notificationId, userEmail);
        },
        child: GestureDetector(
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              title: Text("Join request"),
              leading: user.photoURL != null
                  ? CircleAvatar(
                      backgroundImage:
                          NetworkImage(user.photoURL ?? defaultUserImageURL),
                    )
                  : Offstage(),
              subtitle: Text(
                  '${user.fullname.toLowerCase()} has requested to join ${model.timebankTitle}.'),
            ),
          ),
          onTap: () {
            showDialogForJoinRequestApproval(
              context: context,
              userModel: user,
              model: model,
              notificationId: notificationId,
            );
          },
        ));
  }

  BuildContext showProgressForOnboardingUserContext;

  void showProgressForOnboardingUser() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          showProgressForOnboardingUserContext = createDialogContext;
          return AlertDialog(
            title: Text('Updating timebank..'),
            content: LinearProgressIndicator(),
          );
        });
  }

  void showDialogForJoinRequestApproval({
    BuildContext context,
    UserModel userModel,
    JoinRequestModel model,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    // child: Text(userModel.email),
                    child: Text(""),
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
                  getBio(userModel),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Reason to join:",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(model.reason ?? "Reason not mentioned"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            'Allow',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.pop(viewContext);
                            showProgressForOnboardingUser();

                            await addMemberToTimebank(
                              timebankId: model.entityId,
                              joinRequestId: model.id,
                              memberJoiningSevaUserId: model.userId,
                              notificaitonId: notificationId,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                              newMemberJoinedEmail: userModel.email,
                              isFromGroup: model.isFromGroup,
                            ).commit();

                            Navigator.pop(showProgressForOnboardingUserContext);
                            //update user community
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Reject',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.pop(viewContext);
                            showProgressForOnboardingUser();
                            await rejectMemberJoinRequest(
                              timebankId: model.entityId,
                              joinRequestId: model.id,
                              notificaitonId: notificationId,
                            ).commit();

                            Navigator.pop(showProgressForOnboardingUserContext);
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

  WriteBatch addMemberToTimebank({
    String timebankId,
    String memberJoiningSevaUserId,
    String joinRequestId,
    String communityId,
    String newMemberJoinedEmail,
    String notificaitonId,
    bool isFromGroup,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(newMemberJoinedEmail);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.updateData(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
      });

      var addToCommunityRef =
          Firestore.instance.collection('communities').document(communityId);
      batch.updateData(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  WriteBatch rejectMemberJoinRequest({
    String timebankId,
    String joinRequestId,
    String notificaitonId,
  }) {
    //add to timebank members

    WriteBatch batch = Firestore.instance.batch();
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch;
  }

  Future<JoinRequestModel> getJoinRequestMadeFrom({
    String timebankId,
    String sevaUserId,
  }) async {
    print("$timebankId ---- $sevaUserId");
    return Firestore.instance
        .collection('join_requests')
        .where('entity_id', isEqualTo: timebankId)
        .where('user_id', isEqualTo: sevaUserId)
        .getDocuments()
        .then((snapshot) {
      DocumentSnapshot documentSnapshot = snapshot.documents[0];
      JoinRequestModel model = JoinRequestModel.fromMap(documentSnapshot.data);
      return model;
    }).catchError((onError) {
      return onError;
    });
  }

  Widget getOfferAcceptedNotificationView(UserModel user, String notificationId,
      OfferAcceptedNotificationModel model, BuildContext context) {
    return Dismissible(
        background: dismissibleBackground,
        key: Key(Utils.getUuid()),
        onDismissed: (direction) {
          String userEmail = SevaCore.of(context).loggedInUser.email;
          FirestoreManager.readUserNotification(notificationId, userEmail);
        },
        child: GestureDetector(
          child: Container(
            margin: notificationPadding,
            decoration: notificationDecoration,
            child: ListTile(
              title: Text("Offer Accepted"),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(user.photoURL ?? defaultUserImageURL),
              ),
              subtitle: Text(
                  '${user.fullname.toLowerCase()} has shown interest in your offer'),
            ),
          ),
          onTap: () {},
        ));
  }

  Widget c(
    RequestModel model,
    String userId,
    String notificationId,
    BuildContext context,
  ) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model.title),
          leading: CircleAvatar(
            backgroundImage: model.photoUrl != null
                ? NetworkImage(model.photoUrl)
                : AssetImage("lib/assets/images/approved.png"),
          ),
          subtitle: Text('Request approved by ${model.fullName.toLowerCase()}'),
        ),
      ),
    );
  }

///// utility functions for bio starts here

  ////// utiliy functions for bio ends

  Widget getNotificationRequestRejectWidget(
    RequestModel model,
    String userId,
    String notificationId,
    @required BuildContext context,
  ) {
    return Dismissible(
      background: dismissibleBackground,
      key: Key(Utils.getUuid()),
      onDismissed: (direction) {
        String userEmail = SevaCore.of(context).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      child: Container(
        margin: notificationPadding,
        decoration: notificationDecoration,
        child: ListTile(
          title: Text(model.title),
          leading: CircleAvatar(
              backgroundImage: model.photoUrl != null
                  ? NetworkImage(model.photoUrl)
                  : AssetImage("lib/assets/images/profile.png")),
          subtitle: Text('Request rejected by ${model.fullName.toLowerCase()}'),
        ),
      ),
    );

    // return StreamBuilder<UserModel>(
    //   stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Container(),
    //       );
    //     }
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return notificationShimmer;
    //     }

    //     UserModel user = snapshot.data;
    //   },
    // );
  }

  // Widget getNotificationTaskCompletedRejectWidget(
  //   RequestModel model,
  //   String userId,
  //   String notificationId,
  // ) {
  //   return StreamBuilder<UserModel>(
  //     stream: FirestoreManager.getUserForIdStream(sevaUserId: userId),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Center(
  //           child: Container(),
  //         );
  //       }

  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Text('getNotificationDebit');
  //       }

  //       UserModel user = snapshot.data;
  //       return Dismissible(
  //         background: dismissibleBackground,
  //         key: Key(Utils.getUuid()),
  //         onDismissed: (direction) {
  //           String userEmail = SevaCore.of(context).loggedInUser.email;
  //           FirestoreManager.readUserNotification(notificationId, userEmail);
  //         },
  //         child: Container(
  //           margin: notificationPadding,
  //           decoration: notificationDecoration,
  //           child: ListTile(
  //             title: Text(model.title),
  //             leading: CircleAvatar(
  //               backgroundImage: NetworkImage(user.photoURL),
  //             ),
  //             subtitle: Text('Task completion rejected by ${user.fullname}'),
  //             onTap: () {
  //               String loggedInEmail = SevaCore.of(context).loggedInUser.email;
  //               List users = [user.email, loggedInEmail];
  //               users.sort();
  //               ChatModel chatModel = ChatModel();
  //               chatModel.user1 = users[0];
  //               chatModel.user2 = users[1];
  //               chatModel.timebankId = widget.timebankId;

  //               createChat(chat: chatModel);
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => ChatView(
  //                           useremail: user.email,
  //                           chatModel: chatModel,
  //                         )),
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<http.Response> scheduleNotification(
      {RequestModel model, UserModel userModel}) {
    var url =
        "https://us-central1-sevaexchange.cloudfunctions.net/sendNotifications";

    var body = jsonEncode({
      "request_start": model.requestStart,
      "notification": {
        "title": "${model.title} event is about to start sometime",
        "body": "${model.title} would be starting in less than two hours",
        "icon": "firebase-icon.png"
      },
      "data": {"message": "Enter your message here"},
      "to": userModel.tokens
    });

    return http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
  }

  Widget getNotificationAcceptedWidget(
      RequestModel model, String userId, String notificationId) {
    return FutureBuilder<UserModel>(
      future: FirestoreManager.getUserForIdFuture(sevaUserId: userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Container(),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return notificationShimmer;
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
                  requestModel: model);
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
                  backgroundImage: NetworkImage(user.photoURL),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Text(
                      'Request accepted by ${user.fullname}, waiting for your approval'),
                ),
              ),
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

// crate dialog for approval or rejection
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
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "About ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                            "By approving, ${userModel.fullname} will be added to the event.",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            'Approve',
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
                            'Decline',
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
//                  Padding(
//                    padding: EdgeInsets.all(8.0),
//                  )
                ],
              ),
            ),
          );
        });
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

  Container get dismissibleBackground => Container(
        margin: EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: Colors.red.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          shadows: shadowList,
        ),
        child: ListTile(),
      );

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

//class NotificationsView extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return ListView(
//      children: <Widget>[
//        StreamBuilder<List<RequestModel>>(
//          stream: FirestoreManager.getRequestsNotificationsForUser(
//            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            List<RequestModel> requestModelList = snapshot.data;
//
//            List<Widget> requestList = [];
//
//            requestList.add(
//              Padding(
//                padding: const EdgeInsets.only(left: 8.0, top: 16),
//                child: Text(
//                  'Requests',
//                  style: TextStyle(
//                      fontSize: 12.0,
//                      color: Colors.black,
//                      fontWeight: FontWeight.bold),
//                ),
//              ),
//            );
//
//            requestModelList.forEach(
//              (requestModel) {
//                requestList
//                    .add(getNotificationRequest(requestModel: requestModel));
//              },
//            );
//
//            return Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: requestModelList.length > 0 ? requestList : [],
//            );
//          },
//        ),
//        StreamBuilder<List<RequestModel>>(
//          stream: FirestoreManager.getRequestApprovalNotificationForUser(
//            sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            List<RequestModel> requestModelList = snapshot.data;
//
//            List<Widget> notificationList = [];
//
//            notificationList.add(Padding(
//              padding: const EdgeInsets.only(left: 8.0, top: 16),
//              child: Text('Approvals',
//                  style: TextStyle(
//                      fontSize: 12.0,
//                      color: Colors.black,
//                      fontWeight: FontWeight.bold)),
//            ));
//
//            requestModelList.forEach(
//              (requestModel) {
//                if (requestModel.durationOfRequest != null &&
//                    requestModel.durationOfRequest > 0) {
//                  notificationList.add(
//                    getNotificationCompletedWidget(
//                      requestModel: requestModel,
//                    ),
//                  );
//                } else {
//                  notificationList.add(
//                    getNotificationApprovedWidget(
//                      requestModel: requestModel,
//                    ),
//                  );
//                }
//              },
//            );
//
//            return Column(
//              children: requestModelList.length > 0 ? notificationList : [],
//              crossAxisAlignment: CrossAxisAlignment.start,
//            );
//          },
//        ),
//        StreamBuilder<List<RequestModel>>(
//          stream: FirestoreManager.getRequestCompletionNotificationForUser(
//            sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            List<RequestModel> requestModelList = snapshot.data;
//            List<Widget> notificationList = [];
//
//            notificationList.add(
//              Padding(
//                padding: const EdgeInsets.only(left: 8.0, top: 16),
//                child: Text(
//                  'Completed',
//                  style: TextStyle(
//                      fontSize: 12.0,
//                      color: Colors.black,
//                      fontWeight: FontWeight.bold),
//                ),
//              ),
//            );
//
//            requestModelList.forEach((requestModel) {
//              notificationList.add(
//                getApproveDurationWidget(
//                  requestModel: requestModel,
//                ),
//              );
//            });
//
//            return Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: requestModelList.length > 0 ? notificationList : [],
//            );
//          },
//        ),
//        StreamBuilder<List<RequestModel>>(
//          stream: FirestoreManager.getRejectionStream(
//            userId: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            if (snapshot.data == null) {
//              return Text('No Data');
//            }
//            List<RequestModel> rejectionList = snapshot.data;
//            return Column(
//              mainAxisSize: MainAxisSize.min,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                rejectionList.length > 0
//                    ? Padding(
//                        padding: const EdgeInsets.only(left: 8.0, top: 16),
//                        child: Text(
//                          'Rejected',
//                          style: TextStyle(
//                              fontSize: 12.0,
//                              color: Colors.black,
//                              fontWeight: FontWeight.bold),
//                        ),
//                      )
//                    : Container(),
//                ...rejectionList.map((model) {
//                  return getRejectionNotification(
//                    context: context,
//                    requestModel: model,
//                  );
//                }).toList()
//              ],
//            );
//          },
//        ),
//        StreamBuilder<List<OfferModel>>(
//          stream: FirestoreManager.getOfferNotificationStream(
//            userId: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.hasError) return Container();
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            List<OfferModel> offerList = snapshot.data;
//            return Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                offerList.length < 1
//                    ? Container()
//                    : Padding(
//                        padding: const EdgeInsets.only(left: 8.0, top: 16),
//                        child: Text(
//                          'Requests on your offers',
//                          style: TextStyle(
//                              fontSize: 12.0,
//                              color: Colors.black,
//                              fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                ...offerList.map((offer) {
//                  return getOfferRequestWidget(offer: offer);
//                }).toList(),
//              ],
//            );
//          },
//        ),
//        StreamBuilder<List<RequestModel>>(
//          stream: FirestoreManager.getOfferRequestApprovedNotificationStream(
//            userId: SevaCore.of(context).loggedInUser.sevaUserID,
//          ),
//          builder: (context, snapshot) {
//            if (snapshot.hasError) return Container();
//            if (snapshot.connectionState == ConnectionState.waiting) {
//              return Container();
//            }
//            List<RequestModel> requestList = snapshot.data;
//            return Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                requestList.length < 1
//                    ? Container()
//                    : Padding(
//                        padding: const EdgeInsets.only(left: 8.0, top: 16),
//                        child: Text(
//                          'Request approved on offer',
//                          style: TextStyle(
//                              fontSize: 12.0,
//                              color: Colors.black,
//                              fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                ...requestList.map((model) {
//                  return Slidable(
//                    delegate: SlidableDrawerDelegate(),
//                    actions: <Widget>[
//                      IconSlideAction(
//                        icon: Icons.delete,
//                        onTap: () {
//                          FirestoreManager.deleteOfferRequestApproval(
//                              request: model);
//                        },
//                        caption: 'Dismiss',
//                        color: Colors.red,
//                        foregroundColor: Colors.white,
//                      )
//                    ],
//                    child: ListTile(
//                      title: Text(model.title),
//                      subtitle: FutureBuilder<UserModel>(
//                        future: FirestoreManager.getUserForId(
//                            sevaUserId: model.approvedUserId),
//                        builder: (context, snapshot) {
//                          if (snapshot.hasError) return Text(snapshot.error);
//                          if (snapshot.connectionState ==
//                              ConnectionState.waiting) {
//                            return Container();
//                          }
//                          UserModel user = snapshot.data;
//                          return Text(user.fullname);
//                        },
//                      ),
//                      leading: FutureBuilder<UserModel>(
//                        future: FirestoreManager.getUserForId(
//                            sevaUserId: model.approvedUserId),
//                        builder: (context, snapshot) {
//                          if (snapshot.hasError)
//                            return CircleAvatar(
//                              backgroundColor: Colors.red,
//                            );
//                          if (snapshot.connectionState ==
//                              ConnectionState.waiting) {
//                            return CircleAvatar(
//                              backgroundColor: Colors.grey,
//                            );
//                          }
//                          UserModel user = snapshot.data;
//                          return CircleAvatar(
//                            backgroundImage: NetworkImage(
//                              user.photoURL,
//                            ),
//                          );
//                        },
//                      ),
//                    ),
//                  );
//                }).toList(),
//              ],
//            );
//          },
//        ),
//      ],
//    );
//  }
//
//  Widget getOfferRequestWidget({@required OfferModel offer}) {
//    return Container(
//      padding: EdgeInsets.all(16.0),
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Text(offer.title),
//          ...offer.requestList.map((requestId) {
//            return StreamBuilder<RequestModel>(
//              stream:
//                  FirestoreManager.getRequestStreamById(requestId: requestId),
//              builder: (context, snapshot) {
//                if (snapshot.hasError) return Text(snapshot.error);
//                if (snapshot.connectionState == ConnectionState.waiting) {
//                  return Container();
//                }
//                RequestModel request = snapshot.data;
//                return Slidable(
//                  child: Card(
//                    child: ListTile(
//                      dense: true,
//                      title: Text(request.title),
//                      subtitle: Text(request.description),
//                      leading: FutureBuilder<UserModel>(
//                          future: FirestoreManager.getUserForId(
//                            sevaUserId: request.sevaUserId,
//                          ),
//                          builder: (context, snapshot) {
//                            if (snapshot.hasError) return Text(snapshot.error);
//                            if (snapshot.connectionState ==
//                                ConnectionState.waiting) {
//                              return CircleAvatar(backgroundColor: Colors.grey);
//                            }
//                            UserModel user = snapshot.data;
//                            return CircleAvatar(
//                              backgroundImage: NetworkImage(user.photoURL),
//                            );
//                          }),
//                    ),
//                  ),
//                  delegate: SlidableDrawerDelegate(),
//                  actions: <Widget>[
//                    IconSlideAction(
//                      icon: Icons.check,
//                      foregroundColor: Colors.white,
//                      color: Colors.green,
//                      caption: 'Approve',
//                      onTap: () {
//                        RequestModel updatedRequest = request;
//                        updatedRequest.accepted = true;
//                        List<String> approvedUsers =
//                            request.approvedUsers.map((s) => s).toList();
//                        approvedUsers
//                            .add(SevaCore.of(context).loggedInUser.sevaUserID);
//                        updatedRequest.approvedUsers = approvedUsers;
//
//                        OfferModel updatedOffer = offer;
//                        updatedOffer.associatedRequest = updatedRequest.id;
//
//                        FirestoreManager.acceptOfferRequest(
//                          offer: updatedOffer,
//                          request: updatedRequest,
//                        );
//                      },
//                    )
//                  ],
//                );
//              },
//            );
//          }).toList(),
//        ],
//      ),
//    );
//  }
//
//  Widget getApproveDurationWidget({@required RequestModel requestModel}) {
//    return StreamBuilder<UserModel>(
//      stream: FirestoreManager.getUserForIdStream(
//        sevaUserId: requestModel.approvedUserId,
//      ),
//      builder: (context, snapshot) {
//        if (snapshot.connectionState == ConnectionState.waiting) {
//          return Container();
//        }
//        UserModel user = snapshot.data;
//        return Slidable(
//          delegate: SlidableScrollDelegate(),
//          actions: [
//            Padding(
//              padding: EdgeInsets.only(
//                top: 8,
//                bottom: 8,
//              ),
//              child: IconSlideAction(
//                icon: Icons.check,
//                color: Colors.green,
//                caption: 'Approve',
//                onTap: () {
//                  FirestoreManager.approveRequestCompletion(
//                      requestModel: requestModel);
//                },
//                foregroundColor: Colors.white,
//              ),
//            ),
//          ],
//          secondaryActions: [
//            Padding(
//              padding: EdgeInsets.only(
//                top: 8,
//                bottom: 8,
//              ),
//              child: IconSlideAction(
//                icon: Icons.close,
//                color: Colors.red,
//                caption: 'Reject',
//                onTap: () {
//                  _showRequestCompletionRejectAlertDialog(
//                    context: context,
//                    requestModel: requestModel,
//                  );
//                },
//                foregroundColor: Colors.white,
//              ),
//            ),
//          ],
//          child: Card(
//            child: ListTile(
//              title: Text(requestModel.title),
//              subtitle: Text('Approve for ${getHoursAndMinutes(
//                timeInMinutes: requestModel.durationOfRequest,
//              )}'),
//              trailing: Column(
//                children: <Widget>[
//                  CircleAvatar(
//                    backgroundImage: NetworkImage(user.photoURL),
//                  )
//                ],
//              ),
//            ),
//          ),
//        );
//      },
//    );
//  }
//
//  void _showRequestCompletionRejectAlertDialog({
//    @required BuildContext context,
//    @required RequestModel requestModel,
//  }) {
//    final GlobalKey<FormState> _formKey = GlobalKey();
//    String rejectReason = '';
//
//    showDialog(
//      context: context,
//      barrierDismissible: true,
//      builder: (context) {
//        return GestureDetector(
//          onTap: () {
//            FocusScope.of(context).requestFocus(FocusNode());
//          },
//          child: Container(
//            width: double.infinity,
//            child: AlertDialog(
//              title: Text('Reject Request'),
//              actions: <Widget>[
//                FlatButton(
//                  onPressed: () => Navigator.of(context).pop(),
//                  child: Text('Cancel'),
//                ),
//                RaisedButton(
//                  shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.all(
//                      Radius.circular(12.0),
//                    ),
//                  ),
//                  onPressed: () {
//                    if (!_formKey.currentState.validate()) return;
//                    RequestModel updatedRequest = requestModel;
//                    updatedRequest.rejectedReason = rejectReason;
//                    FirestoreManager.rejectRequestCompletion(
//                        requestModel: updatedRequest);
//                    Navigator.of(context).pop();
//                  },
//                  child: Padding(
//                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                    child: Text(
//                      'Reject',
//                      style: TextStyle(color: Colors.white),
//                    ),
//                  ),
//                  color: Theme.of(context).primaryColor,
//                ),
//              ],
//              content: SingleChildScrollView(
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Form(
//                      key: _formKey,
//                      child: Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: TextFormField(
//                          decoration: InputDecoration(
//                            hasFloatingPlaceholder: true,
//                            labelText: 'Reason for Rejecting',
//                            border: OutlineInputBorder(),
//                          ),
//                          validator: (value) {
//                            if (value.isEmpty)
//                              return 'Provide reason for rejection';
//                            if (value.length < 10) return 'Reason is too short';
//                            rejectReason = value;
//                            return null;
//                          },
//                          autocorrect: true,
//                          maxLength: 100,
//                          textCapitalization: TextCapitalization.sentences,
//                          maxLines: 2,
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
//        );
//      },
//    );
//  }
//
//  Widget getNotificationCompletedWidget({
//    @required RequestModel requestModel,
//  }) {
//    return Slidable(
//      delegate: SlidableDrawerDelegate(),
//      actions: <Widget>[
//        IconSlideAction(
//          icon: Icons.delete,
//          color: Colors.red,
//          foregroundColor: Colors.white,
//          caption: 'Dismiss',
//          onTap: () {
//            FirestoreManager.deleteApprovalNotification(
//              requestModel: requestModel,
//            );
//          },
//        ),
//      ],
//      child: ListTile(
//        title: Text('${requestModel.title}'),
//        subtitle:
//            Text('Approved That the task was completed in ${getHoursAndMinutes(
//          timeInMinutes: requestModel.durationOfRequest,
//        )}'),
//      ),
//    );
//  }
//
//  Widget getNotificationApprovedWidget({@required RequestModel requestModel}) {
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: <Widget>[
//        StreamBuilder<Object>(
//            stream: FirestoreManager.getUserForIdStream(
//              sevaUserId: requestModel.sevaUserId,
//            ),
//            builder: (context, snapshot) {
//              if (snapshot.connectionState == ConnectionState.waiting) {
//                return Center(child: CircularProgressIndicator());
//              }
//              UserModel user = snapshot.data;
//              return Slidable(
//                delegate: SlidableDrawerDelegate(),
//                actions: <Widget>[
//                  IconSlideAction(
//                    icon: Icons.delete,
//                    color: Colors.red,
//                    foregroundColor: Colors.white,
//                    caption: 'Dismiss',
//                    onTap: () {
//                      FirestoreManager.deleteApprovalNotification(
//                        requestModel: requestModel,
//                      );
//                    },
//                  ),
//                ],
//                child: ListTile(
//                  title: Text('${requestModel.title}'),
//                  subtitle: Text('Approved by ${user.fullname}'),
//                  leading: CircleAvatar(
//                    child: Icon(
//                      Icons.check_circle,
//                      color: Colors.green,
//                      size: 32.0,
//                    ),
//                    backgroundColor: Colors.white.withAlpha(0),
//                  ),
//                ),
//              );
//            }),
//      ],
//    );
//  }
//
//  Widget getRejectionNotification({
//    @required BuildContext context,
//    @required RequestModel requestModel,
//  }) {
//    return Card(
//      child: ListTile(
//        onTap: () {
//          requestModel.color = Color.fromRGBO(237, 230, 110, 1.0);
//          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//            return TaskCardView(
//              requestModel: requestModel,
//            );
//          }));
//        },
//        title: Text('${requestModel.title}'),
//        subtitle: Text('${requestModel.rejectedReason}'),
//        leading: CircleAvatar(
//          child: Icon(
//            Icons.error,
//            color: Colors.red,
//            size: 32.0,
//          ),
//          backgroundColor: Colors.white.withAlpha(0),
//        ),
//      ),
//    );
//  }
//
//  Widget getNotificationRequest({@required RequestModel requestModel}) {
//    return requestModel.acceptors.length > 0
//        ? Container(
//            padding: EdgeInsets.only(top: 16.0),
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                  child: Text('${requestModel.title}',
//                      style: TextStyle(
//                        fontSize: 12.0,
//                        color: Colors.grey,
//                      )),
//                ),
//                Column(
//                    children: requestModel.acceptors.map(
//                  (acceptorId) {
//                    return StreamBuilder<UserModel>(
//                      stream: FirestoreManager.getUserForIdStream(
//                        sevaUserId: acceptorId,
//                      ),
//                      builder: (context, modelSnapshot) {
//                        if (modelSnapshot.connectionState ==
//                            ConnectionState.waiting) {
//                          return Container();
//                        }
//                        UserModel user = modelSnapshot.data;
//                        return Slidable(
//                          delegate: SlidableDrawerDelegate(),
//                          actions: <Widget>[
//                            IconSlideAction(
//                              icon: Icons.check_circle,
//                              onTap: () {
//                                RequestModel updatedModel = requestModel;
//                                updatedModel.accepted = true;
//                                updatedModel.approvedUserId = user.sevaUserID;
//
//                                FirestoreManager.approveAcceptRequest(
//                                    requestModel: updatedModel);
//                              },
//                              caption: 'Approve',
//                              color: Colors.green,
//                              foregroundColor: Colors.white,
//                            ),
//                          ],
//                          child: ListTile(
//                            title: Text(user.fullname),
//                            subtitle: Text(user.email),
//                            leading: CircleAvatar(
//                              backgroundImage: NetworkImage(user.photoURL),
//                            ),
//                          ),
//                        );
//                      },
//                    );
//                  },
//                ).toList()),
//              ],
//            ),
//          )
//        : Container();
//  }
//
//  String getHoursAndMinutes({@required int timeInMinutes}) {
//    String hours = (timeInMinutes ~/ 60).toString();
//    int minutes = timeInMinutes - (int.parse(hours) * 60);
//    return minutes <= 0
//        ? '$hours Hours'
//        : '$hours Hours and ${minutes == 1 ? '$minutes Minute' : '$minutes Minutes'}';
//  }
//}

// class AceeptorItem {
//   final String sevaUserID;
//   final bool approved;

//   AceeptorItem({this.sevaUserID, this.approved})

// }

// class GetList {

// void build(BuildContext context ){

//   var acceptors = [];
//   var approvedMembers = [];

//   HashMap<String, AceeptorItem> consildatedList = HashMap();

//   acceptors.map((f){
//     consildatedList[f] = AceeptorItem(approved: false, sevaUserID: f);
//   });

// approvedMembers.map((f){
//     consildatedList[f] = AceeptorItem(approved: true, sevaUserID: f);
//   });

//   Requedtmodel midel=consildatedList[imdex].approved

// }
