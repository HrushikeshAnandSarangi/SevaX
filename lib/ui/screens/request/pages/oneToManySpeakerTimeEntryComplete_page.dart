import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';

class OneToManySpeakerTimeEntryComplete extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onFinish;
  final UserModel userModel;
  // TODO needs flow correction to tasks model
  OneToManySpeakerTimeEntryComplete(
      {@required this.requestModel, @required this.onFinish, this.userModel});

  @override
  OneToManySpeakerTimeEntryCompleteState createState() =>
      OneToManySpeakerTimeEntryCompleteState();
}

class OneToManySpeakerTimeEntryCompleteState
    extends State<OneToManySpeakerTimeEntryComplete> {
  int prepTime = 0;
  int speakingTime = 0;

  RequestModel requestModel;

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
  }

  final _formKey = GlobalKey<FormState>();

  TextEditingController hoursController = TextEditingController();
  TextEditingController selectedHoursPrepTimeController =
      TextEditingController();
  TextEditingController selectedHoursDeliveryTimeController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    log('preptime:  ' + prepTime.toString());
    log('speakingTime:  ' + speakingTime.toString());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          requestModel.title,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              SingleChildScrollView(
            child: Container(
              alignment: Alignment.topCenter,
              width: constraints.maxWidth * 0.84,
              padding:
                  EdgeInsets.only(top: 50.0, left: constraints.maxWidth * 0.07),
              color: requestModel.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Container(
                      width: constraints.maxWidth * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.4,
                                child: Text(
                                  'How much prep time did you need for the request?',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: constraints.maxWidth * 0.7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        controller:
                                            selectedHoursPrepTimeController,
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          BlacklistingTextInputFormatter(
                                            RegExp('[\\.|\\,|\\ |\\-]'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                          //errorText: S.of(context).enter_hours,
                                          contentPadding:
                                              EdgeInsets.only(bottom: 5),
                                          hintText: 'Prep time in hours',
                                          hintStyle: TextStyle(fontSize: 13),
                                        ),
                                        validator: (value) {
                                          if (value == null || value == '') {
                                            return S.of(context).enter_hours;
                                          }
                                          if (value.isEmpty) {
                                            S.of(context).select_hours;
                                          }
                                          this.prepTime = int.parse(value);
                                          return null;
                                        },
                                        onChanged: (val1) {
                                          setState(() {
                                            prepTime = int.parse(val1);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 25),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  'How much time did you need to fulfill the request?',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: constraints.maxWidth * 0.7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TextFormField(
                                        controller:
                                            selectedHoursDeliveryTimeController,
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          BlacklistingTextInputFormatter(
                                            RegExp('[\\.|\\,|\\ |\\-]'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.only(bottom: 5),
                                          //errorText: S.of(context).enter_hours,
                                          hintText: 'Time in hours',
                                          hintStyle: TextStyle(fontSize: 13),
                                        ),
                                        validator: (value) {
                                          if (value == null || value == '') {
                                            return S.of(context).enter_hours;
                                          }
                                          if (value.isEmpty) {
                                            S.of(context).select_hours;
                                          }
                                          this.speakingTime = int.parse(value);
                                          return null;
                                        },
                                        onChanged: (val2) {
                                          setState(() {
                                            speakingTime = int.parse(val2);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.8,
                                child: Text(
                                  'I acknowledge that I have completed the session for the request.',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 35),
                          Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.55,
                                child: Text(
                                  'Note: Based on the preparation hours and time to fulfill the request combined hours will be added upon completing the request.',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: constraints.maxWidth * 0.55,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5.0),
                          child: RaisedButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                LinearProgressIndicator();
                                //store form input to map in requestModel
                                requestModel.selectedSpeakerTimeDetails
                                    .prepTime = prepTime;
                                requestModel.selectedSpeakerTimeDetails
                                    .speakingTime = speakingTime;

                                Set<String> approvedUsersList =
                                    Set.from(requestModel.approvedUsers);
                                approvedUsersList.add(widget.userModel.email);
                                requestModel.approvedUsers =
                                    approvedUsersList.toList();

                                await Firestore.instance
                                    .collection('requests')
                                    .document(requestModel.id)
                                    .updateData(requestModel.toMap());

                                //Navigator.of(creditRequestDialogContext).pop();

                                widget.onFinish();

                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }
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
                              ParticipantInfo sender = ParticipantInfo(
                                id: SevaCore.of(context)
                                    .loggedInUser
                                    .sevaUserID,
                                name:
                                    SevaCore.of(context).loggedInUser.fullname,
                                photoUrl:
                                    SevaCore.of(context).loggedInUser.photoURL,
                                type: ChatType.TYPE_PERSONAL,
                              );

                              ParticipantInfo reciever = ParticipantInfo(
                                id: requestModel.sevaUserId,
                                name: requestModel.fullName,
                                photoUrl: requestModel.photoUrl,
                                type: ChatType.TYPE_TIMEBANK,
                              );

                              createAndOpenChat(
                                isTimebankMessage: true,
                                context: context,
                                communityId: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity,
                                timebankId: requestModel.timebankId,
                                sender: sender,
                                reciever: reciever,
                                isFromRejectCompletion: false,
                                //openFullScreen: true,
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
