import 'dart:developer';

import 'package:doseform/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import 'package:sevaexchange/widgets/custom_buttons.dart';

class OneToManySpeakerTimeEntryComplete extends StatefulWidget {
  final RequestModel requestModel;
  final VoidCallback onFinish;
  final UserModel? userModel;
  final bool isFromtasks;

  OneToManySpeakerTimeEntryComplete(
      {required this.requestModel,
      required this.onFinish,
      this.userModel,
      required this.isFromtasks});

  @override
  OneToManySpeakerTimeEntryCompleteState createState() =>
      OneToManySpeakerTimeEntryCompleteState();
}

class OneToManySpeakerTimeEntryCompleteState
    extends State<OneToManySpeakerTimeEntryComplete> {
  int prepTime = 0;

  // int speakingTime = 0;

  RequestModel? requestModel;
  BuildContext? dialogContext;

  @override
  void initState() {
    super.initState();
    this.requestModel = widget.requestModel;
  }

  final _formKey = GlobalKey<DoseFormState>();

  TextEditingController hoursController = TextEditingController();
  TextEditingController selectedHoursPrepTimeController =
      TextEditingController();
  TextEditingController selectedHoursDeliveryTimeController =
      TextEditingController();
  FocusNode HoursPrepTimeNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    log('preptime:  ' + prepTime.toString());
    // log('speakingTime:  ' + speakingTime.toString());
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          requestModel!.title!,
          style: TextStyle(fontSize: 18),
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
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.only(top: 25.0, left: 35),
              color: requestModel!.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: constraints.maxWidth * 0.9,
                    child: DoseForm(
                      formKey: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.7,
                                child: Text(
                                  S.of(context).speaker_claim_form_field_title,
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
                            width: constraints.maxWidth * 9,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      DoseTextField(
                                        isRequired: true,
                                        controller:
                                            selectedHoursPrepTimeController,
                                        keyboardType: TextInputType.number,
                                        focusNode: HoursPrepTimeNode,
                                        formatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          //errorText: S.of(context).enter_hours,
                                          contentPadding:
                                              EdgeInsets.only(bottom: 5),
                                          hintText: S
                                              .of(context)
                                              .speaker_claim_form_field_title_hint,
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
                          // SizedBox(height: 25),
                          // Row(
                          //   children: [
                          //     Container(
                          //       width: MediaQuery.of(context).size.width * 0.7,
                          //       child: Text(
                          //         'How much time did you need to fulfill the request?',
                          //         style: TextStyle(
                          //             fontSize: 17.0,
                          //             fontWeight: FontWeight.w500),
                          //         textAlign: TextAlign.left,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 15),
                          // Container(
                          //   alignment: Alignment.centerLeft,
                          //   width: constraints.maxWidth * 0.9,
                          //   child: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     children: <Widget>[
                          //       Expanded(
                          //         child: Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: <Widget>[
                          //             TextFormField(
                          //               controller:
                          //                   selectedHoursDeliveryTimeController,
                          //               keyboardType: TextInputType.number,
                          //               inputFormatters: [
                          //                 BlacklistingTextInputFormatter(
                          //                   RegExp('[\\.|\\,|\\ |\\-]'),
                          //                 ),
                          //               ],
                          //               decoration: InputDecoration(
                          //                 contentPadding:
                          //                     EdgeInsets.only(bottom: 5),
                          //                 //errorText: S.of(context).enter_hours,
                          //                 hintText: 'Time in hours',
                          //                 hintStyle: TextStyle(fontSize: 13),
                          //               ),
                          //               validator: (value) {
                          //                 if (value == null || value == '') {
                          //                   return S.of(context).enter_hours;
                          //                 }
                          //                 if (value.isEmpty) {
                          //                   S.of(context).select_hours;
                          //                 }
                          //                 this.speakingTime = int.parse(value);
                          //                 return null;
                          //               },
                          //               onChanged: (val2) {
                          //                 setState(() {
                          //                   speakingTime = int.parse(val2);
                          //                 });
                          //               },
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Container(
                                width: constraints.maxWidth * 0.7,
                                child: Text(
                                  S.of(context).speaker_claim_form_text_1,
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
                                width: constraints.maxWidth * 0.72,
                                child: Text(
                                  S.of(context).speaker_claim_form_text_2,
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
                    width: constraints.maxWidth * 0.62,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5.0),
                          child: CustomElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (createDialogContext) {
                                      dialogContext = createDialogContext;
                                      return AlertDialog(
                                        title: Text(S.of(context).loading),
                                        content: LinearProgressIndicator(
                                          backgroundColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      );
                                    });

                                //store form input to map in requestModel
                                requestModel!.selectedSpeakerTimeDetails!
                                    .prepTime = prepTime;
                                // requestModel.selectedSpeakerTimeDetails
                                //     .speakingTime = speakingTime;

                                Set<String> approvedUsersList =
                                    Set.from(requestModel!.approvedUsers!);
                                approvedUsersList.add(
                                    SevaCore.of(context).loggedInUser.email!);
                                requestModel!.approvedUsers =
                                    approvedUsersList.toList();

                                await CollectionRef.requests
                                    .doc(requestModel!.id)
                                    .update(requestModel!.toMap());

                                //Navigator.of(creditRequestDialogContext).pop();

                                Navigator.of(dialogContext!)
                                    .pop(); //this is to pop loader

                                widget.onFinish();

                                if (widget.isFromtasks) {
                                  await FirestoreManager
                                      .readUserNotificationOneToManyWhenSpeakerIsRejectedCompletion(
                                          requestModel: requestModel!,
                                          userEmail: SevaCore.of(context)
                                              .loggedInUser
                                              .email!,
                                          fromNotification: false);

                                  // Navigator.of(context).pop();
                                }

                                Navigator.of(context).pop();
                                //Navigator.of(context).pop();
                                // if (!widget.fromNotification) {
                                //   Navigator.of(context).pop();
                                // }
                              }
                            },
                            child: Text(
                              S.of(context).accept,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            elevation: 0,
                            color: Colors.grey[200]!,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            textColor: Colors.black,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8.0),
                          child: CustomElevatedButton(
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
                                id: requestModel!.sevaUserId,
                                name: requestModel!.fullName,
                                photoUrl: requestModel!.photoUrl,
                                type: ChatType.TYPE_TIMEBANK,
                              );

                              createAndOpenChat(
                                isTimebankMessage: true,
                                context: context,
                                communityId: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity!,
                                timebankId: requestModel!.timebankId!,
                                sender: sender,
                                reciever: reciever,
                                isFromRejectCompletion: false,
                                //openFullScreen: true,
                                onChatCreate: () {
                                  //Navigator.of(context).pop();
                                },
                                feedId: requestModel!
                                    .id!, // or another appropriate value
                                showToCommunities: [], // or another appropriate value
                                entityId: requestModel!
                                    .id!, // or another appropriate value
                              );
                            },
                            child: Text(
                              S.of(context).message,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            elevation: 0,
                            color: Colors.grey[200]!,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            textColor: Colors.black,
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

  BuildContext? creditRequestDialogContext;

  void showProgressForCreditRetrieval() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          creditRequestDialogContext = context;
          return AlertDialog(
            title: Text(S.of(context).please_wait),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
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
