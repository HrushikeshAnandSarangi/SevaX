import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';

class OneToManyCreatorCompleteRequestPage extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onFinish;
  // TODO needs flow correction to tasks model
  OneToManyCreatorCompleteRequestPage(
      {@required this.requestModel, @required this.onFinish});

  @override
  OneToManyCreatorCompleteRequestPageState createState() =>
      OneToManyCreatorCompleteRequestPageState();
}

class OneToManyCreatorCompleteRequestPageState
    extends State<OneToManyCreatorCompleteRequestPage> {
  RequestModel requestModel;

  List tempAttendeesList = [];
  List attendeesList = [];

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;

    Future.delayed(Duration(milliseconds: 500));

    Firestore.instance
        .collection("requests")
        .document(widget.requestModel.id)
        .collection('oneToManyAttendeesDetails')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((doc) {
        attendeesList.add(doc.data);
        tempAttendeesList.add(doc.data);
      });
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  TextEditingController hoursController = TextEditingController();
  TextEditingController selectedHoursPrepTimeController =
      TextEditingController();
  TextEditingController selectedHoursDeliveryTimeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    log('A ' + attendeesList.length.toString());
    log('T' + tempAttendeesList.length.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          requestModel.title,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Container(
              padding: EdgeInsets.only(top: 25.0, left: 5, right: 5),
              color: requestModel.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 40),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(9.0),
                                  ),
                                ),
                                elevation: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  (requestModel.selectedInstructor
                                                                  .photoURL ==
                                                              '' ||
                                                          requestModel
                                                                  .selectedInstructor
                                                                  .photoURL ==
                                                              null)
                                                      ? defaultUserImageURL
                                                      : requestModel
                                                          .selectedInstructor
                                                          .photoURL),
                                              minRadius: 32.0),
                                        ],
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 12),

                                            Text(
                                                (requestModel.selectedInstructor
                                                                .fullname ==
                                                            '' ||
                                                        requestModel
                                                                .selectedInstructor
                                                                .fullname ==
                                                            null)
                                                    ? 'Name not available'
                                                    : requestModel
                                                        .selectedInstructor
                                                        .fullname,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600),
                                                overflow:
                                                    TextOverflow.ellipsis),

                                            SizedBox(height: 13),

                                            //Label to be created for below hard coded texts

                                            Text(
                                              requestModel.selectedSpeakerTimeDetails
                                                          .speakingTime ==
                                                      null
                                                  ? '0'
                                                  : 'Session duration: ' +
                                                      requestModel
                                                          .selectedSpeakerTimeDetails
                                                          .speakingTime
                                                          .toString() +
                                                      ' hours',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            ),

                                            SizedBox(height: 5),

                                            Text(
                                              requestModel.selectedSpeakerTimeDetails
                                                          .prepTime ==
                                                      null
                                                  ? '0'
                                                  : 'Prep time: ' +
                                                      requestModel
                                                          .selectedSpeakerTimeDetails
                                                          .prepTime
                                                          .toString() +
                                                      ' hours',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.circle,
                                    size: 78, color: Colors.indigo[300]),
                                Icon(Icons.done, size: 36, color: Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.88,
                          padding: EdgeInsets.only(
                              left: 8, right: 8, top: 5, bottom: 6),
                          color: Colors.grey[350],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Label to be created for below

                              Text(
                                'Attended by',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),

                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    tempAttendeesList =
                                        List.from(attendeesList);
                                  });
                                },
                                child: Text(
                                  'Reset list',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 17, right: 17),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.88,
                        height: MediaQuery.of(context).size.width * 0.40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: tempAttendeesList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(),
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                tempAttendeesList[index]
                                                            ['photoURL'] ==
                                                        null
                                                    ? defaultUserImageURL
                                                    : tempAttendeesList[index]
                                                        ['photoURL']),
                                            minRadius: 25.0),
                                        SizedBox(width: 10),
                                        Text(
                                          tempAttendeesList[index]
                                                  ['fullname'] ??
                                              S.of(context).name_not_available,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        log('tap');
                                        if (tempAttendeesList.length > 0) {
                                          setState(() {
                                            tempAttendeesList.removeAt(index);
                                          });
                                        }
                                      },
                                      child: Icon(Icons.cancel_rounded,
                                          color: Colors.grey, size: 32),
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          children: [
                            Text(
                                'I acknowldge that ${requestModel.selectedInstructor.fullname} has completed the request and the above list of members attended the request.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                            SizedBox(height: 15),
                            Text(
                                'Note: The hours will be credited to the speaker and attendees on your approval. Ensure aboe members have attended. You cannot modify the list after approval.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.93,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5.0),
                          child: RaisedButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext viewContext) {
                                    return AlertDialog(
                                      title: Text(
                                          'Are you sure you want to accept and complete this request?'), //Label to be created
                                      actions: <Widget>[
                                        FlatButton(
                                          color: Theme.of(context).primaryColor,
                                          child: Text(
                                            S.of(context).yes,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          onPressed: () async {

                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder: (createDialogContext) {
                                                  viewContext =
                                                      createDialogContext;
                                                  return AlertDialog(
                                                    title: Text(S
                                                        .of(context)
                                                        .loading),
                                                    content:
                                                        LinearProgressIndicator(),
                                                  );
                                                });

                                            //give credits to timebank, then to speaker and attendees
                                            int totalCredits = ((requestModel
                                                        .maxCredits *
                                                    tempAttendeesList.length) +
                                                requestModel
                                                    .selectedSpeakerTimeDetails
                                                    .prepTime +
                                                requestModel
                                                    .selectedSpeakerTimeDetails
                                                    .speakingTime);

                                            log('Total Credits: ' +
                                                totalCredits.toString());

                                            int creditsToSpeaker = requestModel
                                                    .selectedSpeakerTimeDetails
                                                    .prepTime +
                                                requestModel
                                                    .selectedSpeakerTimeDetails
                                                    .speakingTime;

                                            //Sevax global to timebank
                                            await TransactionBloc()
                                                .createNewTransaction(
                                              FlavorConfig.values
                                                  .timebankId, //sevax global timebank id
                                              requestModel
                                                  .timebankId, //timebank to be sent to id
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              totalCredits,
                                              true,
                                              "SEVAX_TO_TIMEBANK_ONETOMANY_COMPLETE",
                                              null,
                                              requestModel.id,
                                              communityId:
                                                  requestModel.communityId,
                                            );

                                            //to speaker and attendees
                                            await TransactionBloc()
                                                .createNewTransaction(
                                              requestModel.timebankId,
                                              requestModel.selectedInstructor
                                                  .sevaUserID, //speaker user id
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                              creditsToSpeaker,
                                              true,
                                              "TIMEBANK_TO_SPEAKER_ONETOMANY_COMPLETE",
                                              null,
                                              requestModel.id,
                                              communityId:
                                                  requestModel.communityId,
                                            );

                                            for (var attendee
                                                in tempAttendeesList) {
                                              await TransactionBloc()
                                                  .createNewTransaction(
                                                requestModel.timebankId,
                                                attendee[
                                                    'sevaUserID'], //each attendee
                                                DateTime.now()
                                                    .millisecondsSinceEpoch,
                                                requestModel.maxCredits,
                                                true,
                                                "TIMEBANK_TO_ATTENDEES_ONETOMANY_COMPLETE",
                                                null,
                                                requestModel.id,
                                                communityId:
                                                    requestModel.communityId,
                                              );
                                              log('Sent credit to:  ' +
                                                  attendee['fullname']);
                                            }

                                            //make request accepted true
                                            await Firestore.instance
                                                .collection('requests')
                                                .document(requestModel.id)
                                                .updateData({
                                              'accepted': true,
                                            });

                                            Navigator.pop(viewContext);
                                            Navigator.of(viewContext).pop();
                                            Navigator.of(context).pop();

                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          color: Theme.of(context).accentColor,
                                          child: Text(
                                            S.of(context).no,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                          onPressed: () {
                                            Navigator.of(viewContext).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });

                              widget.onFinish();
                            },
                            child: Text(
                              S.of(context).accept,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            elevation: 0,
                            color: Colors.grey[200],
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8.0),
                          child: RaisedButton(
                            onPressed: () {
                              UserModel loggedInUser =
                                  SevaCore.of(context).loggedInUser;

                              ParticipantInfo sender = ParticipantInfo(
                                id: loggedInUser.sevaUserID,
                                name: loggedInUser.fullname,
                                photoUrl: loggedInUser.photoURL,
                                type: ChatType.TYPE_TIMEBANK,
                              );

                              ParticipantInfo reciever = ParticipantInfo(
                                id: requestModel.selectedInstructor.sevaUserID,
                                name: requestModel.selectedInstructor.fullname,
                                photoUrl:
                                    requestModel.selectedInstructor.photoURL,
                                type: ChatType.TYPE_PERSONAL,
                              );

                              createAndOpenChat(
                                isTimebankMessage: true,
                                context: context,
                                communityId: loggedInUser.currentCommunity,
                                sender: sender,
                                reciever: reciever,
                                onChatCreate: () {
                                  //Navigator.of(context).pop();
                                },
                              );
                            },
                            child: Text(
                              S.of(context).message,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            elevation: 0,
                            color: Colors.grey[200],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BuildContext creditRequestDialogContext;
  void showProgressForCreditRetrieval() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(),
          );
        });
  }

  //void startTransaction() async {
  //  if (_formKey.currentState.validate()) {
  // TODO needs flow correction to tasks model (currently reliying on requests collection for changes which will be huge instead tasks have to be individual to users)
  // int totalMinutes = 0;

  // if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
  //     requestModel.selectedInstructor.sevaUserID ==
  //         SevaCore.of(context).loggedInUser.sevaUserID) {
  //   totalMinutes = int.parse(selectedMinutesPrepTime) +
  //       int.parse(selectedMinutesDeliveryTime) +
  //       (int.parse(selectedHoursPrepTimeController.text) * 60) +
  //       (int.parse(selectedHoursDeliveryTimeController.text) * 60);
  // } else {
  //   totalMinutes = int.parse(selectedMinuteValue) +
  //       (int.parse(selectedHourValue) * 60);
  //   // TODO needs flow correction need to be removed when tasks introduced- Eswar
  // }

  // this.requestModel.durationOfRequest = totalMinutes;

  // TransactionModel transactionModel = TransactionModel(
  //   from: requestModel.sevaUserId,
  //   to: SevaCore.of(context).loggedInUser.sevaUserID,
  //   credits: totalMinutes / 60,
  //   timestamp: DateTime.now().millisecondsSinceEpoch,
  //   communityId: requestModel.communityId,
  // );

  // if (requestModel.transactions == null) {
  //   requestModel.transactions = [transactionModel];
  // } else if (!requestModel.transactions
  //     .any((model) => model.to == transactionModel.to)) {
  //   requestModel.transactions.add(transactionModel);
  // }

  //FirestoreManager.requestComplete(model: requestModel);

  // END OF CODE correction mentioned above
  // await transactionBloc.createNewTransaction(
  //   requestModel.requestMode == RequestMode.PERSONAL_REQUEST
  //       ? requestModel.sevaUserId
  //       : requestModel.timebankId,
  //   SevaCore.of(context).loggedInUser.sevaUserID,
  //   DateTime.now().millisecondsSinceEpoch,
  //   totalMinutes / 60,
  //   false,
  //   this.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
  //       ? RequestMode.TIMEBANK_REQUEST.toString()
  //       : RequestMode.PERSONAL_REQUEST.toString(),
  //   this.requestModel.id,
  //   this.requestModel.timebankId,
  //   communityId: requestModel.communityId,
  // );

  // FirestoreManager.createTaskCompletedNotification(
  //   model: NotificationsModel(
  //     id: utils.Utils.getUuid(),
  //     data: requestModel.toMap(),
  //     type: NotificationType.RequestCompleted,
  //     senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
  //     targetUserId: requestModel.sevaUserId,
  //     communityId: requestModel.communityId,
  //     timebankId: requestModel.timebankId,
  //     isTimebankNotification:
  //         requestModel.requestMode == RequestMode.TIMEBANK_REQUEST,
  //     isRead: false,
  //   ),
  // );
  // Navigator.of(creditRequestDialogContext).pop();
  // Navigator.of(context).pop();
  // }
  //}

}
