import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

import '../../flavor_config.dart';
/*import 'edit_super_admins_view.dart';
import 'edit_timebank_view.dart';*/

class OnBoardWithTimebank extends StatefulWidget {
  final CommunityModel communityModel;
  final UserModel loggedInUserModel;
  final String timebankId;
  // final UserModel loggedInUserModel;

  OnBoardWithTimebank({
    this.timebankId,
    this.communityModel,
    this.loggedInUserModel,
  }) {
    print("Logged in user $loggedInUserModel");
  }

  @override
  State<StatefulWidget> createState() => OnBoardWithTimebankState();
}

@override
void initState() {
  //SevaCore.of(context).loggedInUser = UserData.shared.user;
  initState();
  //this.getRequestData = new JoinRequestModel();
}

class OnBoardWithTimebankState extends State<OnBoardWithTimebank> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();
  TimebankModel timebankModel;
  //TimebankModel superAdminModel;
  JoinRequestModel joinRequestModel = new JoinRequestModel();
  JoinRequestModel getRequestData = new JoinRequestModel();
  UserModel ownerModel;
  String title = 'Loading';
  String loggedInUser;
  final formkey = GlobalKey<FormState>();

  bool hasError = false;
  String errorMessage1 = '';

  @override
  Widget build(BuildContext context) {
    return timebankStreamBuilder(context);
  }

  StreamBuilder<TimebankModel> timebankStreamBuilder(
      BuildContext buildcontext) {
    var timebankName =
        FlavorConfig.appFlavor == Flavor.APP ? "Timebank" : "Yang Gang";
    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
          timebankId: widget.communityModel.primary_timebank),
      builder: (streamContext, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
              appBar: AppBar(
                title: Text('Loading'),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
            break;
          default:
            this.timebankModel = snapshot.data;
            // globals.timebankAvatarURL = timebankModel.photoUrl;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFFFFFFFF),
                leading: BackButton(color: Colors.black54),
                centerTitle: true,
                title: Text(
                  'Join' + 'Community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
              body: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height - 80,
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            //child: Text(thisText, style: Theme.of(context).textTheme.title),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 50.0,
                                right: 50.0,
                                top: 10.0,
                                bottom: 25.0),
                            child: Text(
                              //'Enter the code you received from your ${FlavorConfig.values.timebankTitle} Coordinator to see the exchange opportunities for your group.',
                              'Enter the code you received from' +
                                  ' team Name ' +
                                  'loc Admin to see the volunteer opportunities.',
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          /* Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                    child: Text(
                      'Enter ${FlavorConfig.values.timebankTitle} code',
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                    ),
                  ),*/
                          Column(
                            children: <Widget>[
                              PinCodeTextField(
                                pinBoxWidth: 50,
                                autofocus: false,
                                controller: controller,
                                hideCharacter: false,
                                highlight: true,
                                keyboardType: TextInputType.text,
                                highlightColor: Colors.blue,
                                defaultBorderColor: Colors.grey,
                                hasTextBorderColor: Colors.green,
                                maxLength: 6,
                                hasError: hasError,
                                maskCharacter: "•",
                                onTextChanged: (text) {
                                  setState(() {
                                    hasError = false;
                                  });
                                },
                                onDone: (text) {
                                  // print("############################ DONE $text");
                                  //widget.onSelectedOtp(controller.text);
                                },
                                pinCodeTextFieldLayoutType:
                                    PinCodeTextFieldLayoutType
                                        .AUTO_ADJUST_WIDTH,
                                wrapAlignment: WrapAlignment.start,
                                pinBoxDecoration: ProvidedPinBoxDecoration
                                    .underlinedPinBoxDecoration,
                                pinTextStyle: TextStyle(fontSize: 20.0),
                                pinTextAnimatedSwitcherTransition:
                                    ProvidedPinBoxTextAnimation
                                        .scalingTransition,
                                pinTextAnimatedSwitcherDuration:
                                    Duration(milliseconds: 100),
                              ),
                              Padding(padding: EdgeInsets.only(top: 10.0)),
                              Visibility(
                                child: Text(
                                  this.errorMessage1,
                                  style: TextStyle(color: Colors.red),
                                ),
                                visible: hasError,
                              ),
                            ],
                          ),
                          Text(
                            'If you dont have a code, Click',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          FlatButton(
                            child: Text(
                              'Request Join Link',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  // return object of type Dialog
                                  return AlertDialog(
                                    title: new Text(
                                        "Why do you want to join the ${FlavorConfig.values.timebankTitle}? "),
                                    content: Form(
                                      key: formkey,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          hintText: 'Reason',
                                          labelText: 'Reason',
                                          // labelStyle: textStyle,
                                          // labelStyle: textStyle,
                                          // labelText: 'Description',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              const Radius.circular(20.0),
                                            ),
                                            borderSide: new BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          joinRequestModel.reason = value;
                                        },
                                      ),
                                    ),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: dialogButtonSize,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                      ),
                                      // usually buttons at the bottom of the dialog
                                      new FlatButton(
                                        child: new Text(
                                          "Send Join Request",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
                                            fontSize: dialogButtonSize,
                                          ),
                                        ),
                                        onPressed: () async {
                                          print(
                                              "Timebank Model $timebankModel");
                                          joinRequestModel.userId = widget
                                              .loggedInUserModel.sevaUserID;
                                          joinRequestModel.timestamp =
                                              DateTime.now()
                                                  .millisecondsSinceEpoch;

                                          joinRequestModel.entityId =
                                              timebankModel.id;
                                          joinRequestModel.entityType =
                                              EntityType.Timebank;
                                          joinRequestModel.accepted = null;

                                          if (formkey.currentState.validate()) {
                                            await createJoinRequest(
                                                model: joinRequestModel);

                                            JoinRequestNotificationModel
                                                joinReqModel =
                                                JoinRequestNotificationModel(
                                                    timebankId:
                                                        timebankModel.id,
                                                    timebankTitle:
                                                        timebankModel.name);

                                            NotificationsModel notification =
                                                NotificationsModel(
                                              id: utils.Utils.getUuid(),
                                              targetUserId:
                                                  timebankModel.creatorId,
                                              senderUserId: widget
                                                  .loggedInUserModel.sevaUserID,
                                              type: prefix0
                                                  .NotificationType.JoinRequest,
                                              data: joinReqModel.toMap(),
                                            );
                                            notification.timebankId =
                                                FlavorConfig.values.timebankId;

                                            UserModel timebankCreator =
                                                await FirestoreManager
                                                    .getUserForId(
                                                        sevaUserId:
                                                            timebankModel
                                                                .creatorId);

                                            await Firestore.instance
                                                .collection('users')
                                                .document(timebankCreator.email)
                                                .collection("notifications")
                                                .document(notification.id)
                                                .setData(notification.toMap());
                                            Navigator.of(dialogContext).pop();
                                            Navigator.of(context).pop();

                                            return;
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 3,
                      ),
                      SizedBox(
                        width: 120,
                        child: RaisedButton(
                          onPressed: () {
                            print('pressed Next');

                            this._checkFields();
                          },
                          child: Text('Join'),
                          color: Theme.of(context).accentColor,
                          textColor: FlavorConfig.values.buttonTextColor,
                          shape: StadiumBorder(),
                        ),
                      ),
                      Spacer(),

                      /* Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(30.0),
                      ),
                      Expanded(
                        child: RaisedButton(

                            child: Text(
                              'Join',
                            ),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              print('pressed Next');

                              this._checkFields();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  )
                ],
              )*/
                    ],
                  ),
                ),
              ),
            );
        }
      },
    );
  }

  void _checkFields() {
    if (controller.text.length == 6) {
      verifyTimebankCode(timebankCode: controller.text);
    } else {
      if (controller.text.length != 6) {
        setError(errorMessage: "Please enter PIN to verify");
      }
    }
  }

  void setError({String errorMessage}) {
    setState(() {
      this.hasError = true;
      this.errorMessage1 = errorMessage;
    });
  }

  void verifyTimebankCode({String timebankCode}) {
    Firestore.instance
        .collection("timebankCodes")
        .where("timebankCode", isEqualTo: timebankCode)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      if (snapshot.documents.length > 0) {
        // timabnk code exists , check its validity
        snapshot.documents.forEach((f) {
          print('${f.data}}');
          if (DateTime.now().millisecondsSinceEpoch > f.data['validUpto']) {
            _showDialog(
                activityContext: context,
                mode: TimeBankResponseModes.CODE_EXPIRED,
                dialogTitle: "Code Expired!",
                dialogSubTitle:
                    "This ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : "Timebank"} code has been expired, please request the admin for a noew one!");
          } else {
            //code matche and is alive

            // add to usersOnBoarded
            Firestore.instance
                .collection("timebankCodes")
                .document(f.documentID)
                .updateData({
              'usersOnboarded':
                  FieldValue.arrayUnion([widget.loggedInUserModel.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .updateData({
              'members':
                  FieldValue.arrayUnion([widget.loggedInUserModel.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .get()
                .then((DocumentSnapshot timeBank) {
              var response = _showDialog(
                  mode: TimeBankResponseModes.ONBOARDED,
                  dialogTitle: "Awesome!",
                  dialogSubTitle:
                      "You have been onboaded to ${timeBank.data['name'].toString()} successfully.\nYou can switch to this ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : "Timebank"}.");
              response.then((onValue) {
                print("onboadrd");
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
                // Navigator.of(context).pop();
              });
            });
          }
        });
      } else {
        var selected = _showDialog(
          mode: TimeBankResponseModes.NO_CODE,
          dialogTitle: "Not found!",
          dialogSubTitle:
              "We were unable to find the ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : "Timebank"} code, please check and try again.",
        );

        selected.then((TimeBankResponseModes data) {
          print("----------------------------------------");
        });
      }
    });
  }

// user defined function
  Future<TimeBankResponseModes> _showDialog(
      {TimeBankResponseModes mode,
      String dialogTitle,
      String dialogSubTitle,
      BuildContext activityContext}) async {
    // flutter defined function
    return await showDialog<TimeBankResponseModes>(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog

        print("init dialog");
        return AlertDialog(
          title: new Text(dialogTitle),
          content: new Text(dialogSubTitle),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Close",
                style: TextStyle(
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () {
                switch (mode) {
                  case TimeBankResponseModes.CODE_EXPIRED:
                    Navigator.pop(context, TimeBankResponseModes.CODE_EXPIRED);
                    break;

                  case TimeBankResponseModes.NO_CODE:
                    Navigator.pop(context, TimeBankResponseModes.NO_CODE);
                    break;

                  case TimeBankResponseModes.ONBOARDED:
                    Navigator.pop(context, TimeBankResponseModes.ONBOARDED);
                    break;
                }
              },
            ),
          ],
        );
      },
    );
  }
}

enum TimeBankResponseModes { ONBOARDED, CODE_EXPIRED, NO_CODE }
