import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/one_to_many_notification_data_model.dart';
import 'package:sevaexchange/models/reported_member_notification_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/ui/screens/notifications/widgets/notification_card.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/ui/utils/notification_message.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/notifications/notification_utils.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/requests/join_reject_dialog.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/timebank_user_exit_dialog.dart';
import 'package:shimmer/shimmer.dart';

class AdminNotificationViewHolder extends StatefulWidget {
  final TimebankModel timebankModel;

  AdminNotificationViewHolder({this.timebankModel});

  @override
  AdminNotificationsView createState() => AdminNotificationsView();
}

class AdminNotificationsView extends State<AdminNotificationViewHolder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationsModel>>(
      stream: FirestoreManager.getNotificationsForTimebank(
        timebankId: widget.timebankModel.id,
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
            child: Text(AppLocalizations.of(context)
                .translate('notifications', 'no_notifications')),
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
                return Text(AppLocalizations.of(context)
                    .translate('notifications', 'request_reject'));
                break;

              case NotificationType.TypeMemberExitTimebank:
                print("notification data ${notification.data}");
                UserExitModel userExitModel =
                    UserExitModel.fromMap(notification.data);
                return getUserExitNotificationWidget(
                  userExitModel,
                  notification.id,
                  context,
                  notification.timebankId,
                  notification.communityId,
                );
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
                          ? getJoinRequestsNotificationWidget(
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
                return Text(AppLocalizations.of(context)
                    .translate('notifications', 'request_completed_rejected'));

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
                return Text(AppLocalizations.of(context).translate(
                    'notifications', 'notificationtype_offeraccept'));
                break;
              case NotificationType.OfferReject:
                return Text(AppLocalizations.of(context).translate(
                    'notifications', 'notificationtype_offerreject'));
                break;
              case NotificationType.AcceptedOffer:
                return Text(AppLocalizations.of(context).translate(
                    'notifications', 'notificationtype_acceptedoffer'));
                break;

              case NotificationType.RequestInvite:
                return Text(AppLocalizations.of(context).translate(
                    'notifications', 'notificationtype_requestinvite'));
                break;

              //One to many timebank notification

              case NotificationType.TYPE_DEBIT_FULFILMENT_FROM_TIMEBANK:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'debited'),
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
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
                break;
              case NotificationType.TYPE_CREDIT_FROM_OFFER_APPROVED:
                OneToManyNotificationDataModel data =
                    OneToManyNotificationDataModel.fromJson(notification.data);
                return NotificationCard(
                  title: AppLocalizations.of(context)
                      .translate('notifications', 'credited'),
                  subTitle: TimebankNotificationMessage
                      .CREDIT_FROM_OFFER_APPROVED
                      .replaceFirst(
                          '*n', data.classDetails.numberOfClassHours.toString())
                      .replaceFirst('*class', data.classDetails.classTitle),
                  // photoUrl: data.participantDetails.photourl,
                  entityName: data.participantDetails.fullname,
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );
                break;

              case NotificationType.TYPE_DELETION_REQUEST_OUTPUT:
                var requestData =
                    SoftDeleteRequestDataHolder.fromMap(notification.data);
                print("---------------> " + requestData.toMap().toString());

                return NotificationCard(
                  entityName: requestData.entityTitle ?? "Deletion Request",
                  photoUrl: null,
                  title: requestData.requestAccepted
                      ? "${requestData.entityTitle} was deleted!"
                      : "${requestData.entityTitle} cannot be deleted!",
                  subTitle: requestData.requestAccepted
                      ? "${requestData.entityTitle} you requested to delete has been successfully deleted!"
                      : "Your request to delete ${requestData.entityTitle} cannot be completed at this time. There are pending transactions. Tap here to view the details:",
                  onPressed: () => !requestData.requestAccepted
                      ? showDialogForIncompleteTransactions(
                          context: context,
                          deletionRequest: requestData,
                        )
                      : null,
                  onDismissed: () {
                    dismissTimebankNotification(
                      notificationId: notification.id,
                      timebankId: notification.timebankId,
                    );
                  },
                );

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
                    dismissTimebankNotification(
                        timebankId: notification.timebankId,
                        notificationId: notification.id);
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

  Widget getNotificationCredit(
    //no need of notification card widget here
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
                    title: Text(AppLocalizations.of(context)
                        .translate('notifications', 'credited')),
                    subtitle: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            // text: 'Congrats, ${user.fullname} has credited ',
                            text:
                                '${AppLocalizations.of(context).translate('notifications', 'congrats')},  ',
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: () {
                              return '${model.credits} ${AppLocalizations.of(context).translate('notifications', 'bucks_Seva_Credits')}';
                            }(),
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Europa',
                            ),
                          ),
                          TextSpan(
                            text: () {
                              return " ${AppLocalizations.of(context).translate('notifications', 'credited_to')}.";
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
    //no need of notification card widget here
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
            return Text(AppLocalizations.of(context)
                .translate('notifications', 'notification_debit'));
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
                title: Text(AppLocalizations.of(context)
                    .translate('notifications', 'debited')),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: () {
                          return '${model.credits} ${AppLocalizations.of(context).translate('notifications', 'bucks_Seva_Credits')}';
                        }(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Europa',
                        ),
                      ),
                      TextSpan(
                        text:
                            '${AppLocalizations.of(context).translate('notifications', 'debited_to_so')} ${user.fullname}',
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
                          '${user.fullname} ${AppLocalizations.of(context).translate('notifications', 'approved_for')} ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Europa',
                      ),
                    ),
                    TextSpan(
                      text: () {
                        return '${transactionModel.credits} ${AppLocalizations.of(context).translate('notifications', 'hours')}';
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
          return Text(AppLocalizations.of(context)
              .translate('notifications', 'getofferacceptnotification'));
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
                          return Text(AppLocalizations.of(context).translate(
                              'notifications', 'getofferacceptnotification'));
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
                        return Text(AppLocalizations.of(context).translate(
                            'notifications', 'getofferacceptnotification'));
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
                                      '${user.fullname} ${AppLocalizations.of(context).translate('notifications', 'send_request_for')}: ${getOfferTitle(offerDataModel: offermodel)} ',
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

  Widget getUserExitNotificationWidget(
      UserExitModel userExitModel,
      String notificationId,
      BuildContext buildContext,
      String timebankId,
      String communityId) {
    // assert(user != null);
    return NotificationCard(
      title: AppLocalizations.of(context)
          .translate('notifications', 'timebank_exit'),
      subTitle:
          '${userExitModel.userName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'exited_from')} ${userExitModel.timebank}, ${AppLocalizations.of(context).translate('notifications', 'tap_to_view')}',
      photoUrl: userExitModel.userPhotoUrl ?? defaultUserImageURL,
      onDismissed: () {
        FirestoreManager.readTimeBankNotification(
          notificationId: notificationId,
          timebankId: widget.timebankModel.id,
        );
      },
      onPressed: () {
        showDialog(
            context: buildContext,
            builder: (context) {
              return TimebankUserExitDialogView(
                userExitModel: userExitModel,
                timeBankId: timebankId,
                notificationId: notificationId,
                userModel: SevaCore.of(buildContext).loggedInUser,
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
          reciever: user);
    } else {}
  }

  void onActivityResult(
      {SevaCore sevaCore,
      RequestModel requestModel,
      UserModel reciever,
      String userId,
      String notificationId,
      BuildContext context,
      Map results,
      String reviewer,
      String reviewed,
      String requestId}) async {
    // adds review to firestore
    Firestore.instance.collection("reviews").add({
      "reviewer": reviewer,
      "reviewed": reviewed,
      "ratings": results['selection'],
      "device_info": results['device_info'],
      "requestId": requestId,
      "comments": (results['didComment']
          ? results['comment']
          : AppLocalizations.of(context)
              .translate('notifications', 'no_comments'))
    });
    await sendMessageToMember(
        loggedInUser: sevaCore.loggedInUser,
        requestModel: requestModel,
        receiver: reciever,
        message: results['comment'] ??
            AppLocalizations.of(context).translate('requests', 'no_comments'));
    approveTransaction(requestModel, userId, notificationId, sevaCore);
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
                          text:
                              '${user.fullname} ${AppLocalizations.of(context).translate('notifications', 'completed_in')} ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Europa',
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return '${transactionModel.credits ?? "0"} ${AppLocalizations.of(context).translate('notifications', 'hours')}';
                          }(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: () {
                            return ', ${AppLocalizations.of(context).translate('notifications', 'waiting_for')}.';
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
    return NotificationCard(
      title: AppLocalizations.of(context)
          .translate('notifications', 'join_request'),
      subTitle:
          '${requestInvitationModel.timebankName.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${requestInvitationModel.requestTitle}, ${AppLocalizations.of(context).translate('notifications', 'tap_toview')}',
      photoUrl: requestInvitationModel.timebankImage ?? defaultUserImageURL,
      onDismissed: () {
        String userEmail = SevaCore.of(buildContext).loggedInUser.email;
        FirestoreManager.readUserNotification(notificationId, userEmail);
      },
      onPressed: () {
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
    );
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
                        "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
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
                          "${AppLocalizations.of(context).translate('notifications', 'by_approving_that')} ${userModel.fullname} has worked for $credits hours",
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'approve'),
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'reject'),
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
      child: Text(AppLocalizations.of(context).translate('offers', 'no_bio')),
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

  Future<void> rejectMemberClaimForEvent(
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
    FirestoreManager.rejectRequestCompletion(
      model: model,
      userId: userId,
      communityid: SevaCore.of(context).loggedInUser.currentCommunity,
    );

    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    ParticipantInfo sender = ParticipantInfo(
      id: model.timebankId,
      name: widget.timebankModel.name,
      photoUrl: widget.timebankModel.photoUrl,
      type: widget.timebankModel.parentTimebankId ==
              '73d0de2c-198b-4788-be64-a804700a88a4'
          ? ChatType.TYPE_TIMEBANK
          : ChatType.TYPE_GROUP,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevaUserID,
      photoUrl: user.photoURL,
      name: user.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    await createAndOpenChat(
      context: context,
      timebankId: widget.timebankModel.id,
      communityId: loggedInUser.currentCommunity,
      sender: sender,
      reciever: reciever,
      isFromRejectCompletion: true,
      isTimebankMessage: true,
      onChatCreate: () {
        FirestoreManager.readTimeBankNotification(
          notificationId: notificationId,
          timebankId: widget.timebankModel.id,
        );
      },
    );
  }

  Widget getJoinRequestsNotificationWidget(
    UserModel user,
    String notificationId,
    JoinRequestModel model,
    BuildContext context,
  ) {
    return NotificationCard(
      title: AppLocalizations.of(context)
          .translate('notifications', 'join_request'),
      subTitle:
          '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'requested_join')} ${model.timebankTitle}.',
      photoUrl: user.photoURL ?? defaultUserImageURL,
      onDismissed: () {
        dismissTimebankNotification(
            timebankId: model.entityId, notificationId: notificationId);
      },
      onPressed: () {
        showDialogForJoinRequestApproval(
          context: context,
          userModel: user,
          model: model,
          notificationId: notificationId,
        );
      },
    );
  }

  BuildContext showProgressForOnboardingUserContext;

  void showProgressForOnboardingUser() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          showProgressForOnboardingUserContext = createDialogContext;
          return AlertDialog(
            title: Text(AppLocalizations.of(context)
                .translate('notifications', 'updating_timebank')),
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
                        "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "${AppLocalizations.of(context).translate('notifications', 'reason_to_join')}:",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(model.reason ??
                        AppLocalizations.of(context)
                            .translate('notifications', 'not_mentioned')),
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'allow'),
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'reject'),
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
              title: Text(AppLocalizations.of(context)
                  .translate('notifications', 'offer_accepted')),
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(user.photoURL ?? defaultUserImageURL),
              ),
              subtitle: Text(
                  '${user.fullname.toLowerCase()} ${AppLocalizations.of(context).translate('notifications', 'show_interest')}'),
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
          subtitle: Text(
              '${AppLocalizations.of(context).translate('notifications', 'approved_by')} ${model.fullName.toLowerCase()}'),
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
          subtitle: Text(
              '${AppLocalizations.of(context).translate('notifications', 'rejected_by')} ${model.fullName.toLowerCase()}'),
        ),
      ),
    );
  }

  Future<http.Response> scheduleNotification(
      {RequestModel model, UserModel userModel}) {
    var url =
        "https://us-central1-sevaexchange.cloudfunctions.net/sendNotifications";

    var body = jsonEncode({
      "request_start": model.requestStart,
      "notification": {
        "title":
            "${model.title} ${AppLocalizations.of(context).translate('notifications', 'event_about_to')}",
        "body":
            "${model.title} ${AppLocalizations.of(context).translate('notifications', 'would_be_starting')}",
        "icon": "firebase-icon.png"
      },
      "data": {
        "message": AppLocalizations.of(context)
            .translate('notifications', 'enter_message')
      },
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
                      '${AppLocalizations.of(context).translate('notifications', 'request_accepted_by')} ${user.fullname}, ${AppLocalizations.of(context).translate('notifications', 'waiting_for')}'),
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
                        "${AppLocalizations.of(context).translate('notifications', 'about')} ${userModel.fullname}",
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
                            "${AppLocalizations.of(context).translate('notifications', 'by_approving_short')}, ${userModel.fullname} ${AppLocalizations.of(context).translate('notifications', 'add_to')}.",
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'approve'),
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
                            AppLocalizations.of(context)
                                .translate('notifications', 'decline'),
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
