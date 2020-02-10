import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/join_req_model.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/home_page_router.dart';

import '../../flavor_config.dart';
import '../core.dart';
/*import 'edit_super_admins_view.dart';
import 'edit_timebank_view.dart';*/

class OnBoardWithTimebank extends StatefulWidget {
  final CommunityModel communityModel;
  final String sevauserId;

  OnBoardWithTimebank({this.communityModel, this.sevauserId});

  @override
  State<StatefulWidget> createState() => OnBoardWithTimebankState();
}

enum CompareToTimeBank { JOINED, REQUESTED, REJECTED, JOIN }

class OnBoardWithTimebankState extends State<OnBoardWithTimebank> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();
  TimebankModel timebankModel;

  static const String JOIN = "Join";
  static const String JOINED = "Joined";
  static const String REQUESTED = "Requested";
  static const String REJECTED = "Rejected";
  bool isDataLoaded = false;

  List<JoinRequestModel> _joinRequestModelList;

  //TimebankModel superAdminModel;
  JoinRequestModel joinRequestModel = new JoinRequestModel();
//  JoinRequestModel getRequestData = new JoinRequestModel();
  UserModel ownerModel;
  String title = 'Loading';
  //String loggedInUser;
  final formkey = GlobalKey<FormState>();

  bool hasError = false;
  String errorMessage1 = '';
  GlobalKey _scaffold = GlobalKey();
  BuildContext dialogLoadingContext;

  void initState() {
    super.initState();
    createEditCommunityBloc.getCommunityPrimaryTimebank();

    getRequestList();
  }

  void getRequestList() async {
    _joinRequestModelList = await getFutureUserTimeBankRequest(
        userID: widget.sevauserId,
        primaryTimebank: widget.communityModel.primary_timebank);
    //   print("sevauser id ${_joinRequestModelList[0].entityId}");
    //   print("sevauser community ${widget.communityModel.id}");

    isDataLoaded = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isDataLoaded
        ? Scaffold(
            key: _scaffold,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Join Timebank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  // fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(child: timebankStreamBuilder(context)),
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  Widget timebankStreamBuilder(context) {
    // ListView contains a group of widgets that scroll inside the drawer
    return StreamBuilder(
        stream: createEditCommunityBloc.createEditCommunity,
        builder: (context,
            AsyncSnapshot<CommunityCreateEditController>
                communityCreateEditSnapshot) {
          if (communityCreateEditSnapshot.hasData) {
            if (communityCreateEditSnapshot.data != null &&
                communityCreateEditSnapshot.data.loading) {
              return Expanded(
                  child: Center(child: CircularProgressIndicator()));
            } else {
              return timebankStreamBuilderJoin(
                  communityCreateEditSnapshot.data, context);
            }
          } else if (communityCreateEditSnapshot.hasError) {
            return Text(communityCreateEditSnapshot.error.toString());
          }
          return Text("");
        });
  }

  Widget timebankStreamBuilderJoin(
      CommunityCreateEditController communityCreateEditSnapshot,
      BuildContext context) {
    this.timebankModel = communityCreateEditSnapshot.timebank;
    // globals.timebankAvatarURL = timebankModel.photoUrl;
    CompareToTimeBank requestStatus;
    requestStatus = compareTimeBanks(_joinRequestModelList, timebankModel,
        SevaCore.of(context).loggedInUser.sevaUserID);

    return Container(
      height: MediaQuery.of(context).size.height - 90,
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
                    left: 50.0, right: 50.0, top: 10.0, bottom: 25.0),
                child: Text(
                  //'Enter the code you received from your ${FlavorConfig.values.timebankTitle} Coordinator to see the exchange opportunities for your group.',
                  'Enter the code you received from your admin to see the volunteer opportunities.',
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
                    wrapAlignment: WrapAlignment.center,
                    pinBoxDecoration:
                        ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                    pinTextStyle: TextStyle(fontSize: 20.0),
                    pinTextAnimatedSwitcherTransition:
                        ProvidedPinBoxTextAnimation.scalingTransition,
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
              requestStatus == CompareToTimeBank.JOIN
                  ? Column(
                      children: <Widget>[
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
                            'Request Invite',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              fontSize: 17,
                            ),
                          ),
                          onPressed: () {
                            myDialog(context, communityCreateEditSnapshot);
                          },
                        ),
                      ],
                    )
                  : Text(
                      'You already requested to this timebank. Please wait untill request is accepted',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ],
          ),
          Spacer(
            flex: 3,
          ),
          SizedBox(
            width: 134,
            child: RaisedButton(
              onPressed: () {
                print('pressed Next');

                this._checkFields();
              },
              child: Text(
                'Join',
                style: Theme.of(context).primaryTextTheme.button,
              ),
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
    );
  }

  Future<AlertDialog> myDialog(BuildContext context,
      CommunityCreateEditController communityCreateEditSnapshot) {
    showDialog<AlertDialog>(
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
                  borderRadius: const BorderRadius.all(
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
                Navigator.of(dialogContext, rootNavigator: true).pop();
              },
            ),
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Send Join Request",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: dialogButtonSize,
                ),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                showProgressDialog();

                print("Timebank Model $timebankModel");
                joinRequestModel.userId =
                    communityCreateEditSnapshot.loggedinuser.sevaUserID;
                joinRequestModel.timestamp =
                    DateTime.now().millisecondsSinceEpoch;

                joinRequestModel.entityId = timebankModel.id;
                joinRequestModel.entityType = EntityType.Timebank;
                joinRequestModel.accepted = false;

                if (formkey.currentState.validate()) {
                  await createJoinRequest(model: joinRequestModel);

                  JoinRequestNotificationModel joinReqModel =
                      JoinRequestNotificationModel(
                          timebankId: timebankModel.id,
                          timebankTitle: timebankModel.name);
                  NotificationsModel notification = NotificationsModel(
                    timebankId: timebankModel.id,
                    id: utils.Utils.getUuid(),
                    targetUserId: timebankModel.creatorId,
                    senderUserId:
                        communityCreateEditSnapshot.loggedinuser.sevaUserID,
                    type: prefix0.NotificationType.JoinRequest,
                    data: joinReqModel.toMap(),
                  );

                  notification.timebankId = FlavorConfig.values.timebankId;

                  UserModel timebankCreator =
                      await FirestoreManager.getUserForId(
                          sevaUserId: timebankModel.creatorId);

                  await Firestore.instance
                      .collection('users')
                      .document(timebankCreator.email)
                      .collection("notifications")
                      .document(notification.id)
                      .setData(notification.toMap());

                  if (dialogLoadingContext != null) {
                    Navigator.pop(dialogLoadingContext);
                  }
                  Navigator.of(context).pop();

                  return;
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _checkFields() {
    if (controller.text.length == 6) {
      var response;
      var func = (state) => {
            if (state == 'no_code')
              {
                _showDialog(
                    activityContext: context,
                    mode: TimeBankResponseModes.NO_CODE,
                    dialogTitle: "Code not found",
                    dialogSubTitle:
                        "This ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : "Timebank"} code was not registered, please check the code and try again!")
              }
            else if (state == 'code_expired')
              {
                _showDialog(
                    activityContext: context,
                    mode: TimeBankResponseModes.CODE_EXPIRED,
                    dialogTitle: "Code Experired!",
                    dialogSubTitle:
                        "This ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : "Timebank"} code has been expired, please request the admin for a new one!")
              }
            else
              {
                response = _showDialog(
                    mode: TimeBankResponseModes.ONBOARDED,
                    dialogTitle: "Awesome!",
                    dialogSubTitle:
                        "You have been onboarded to ${state.toString()} successfully."),
                response.then((onValue) async {
                  print("onboadrd");
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.));
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                  // Navigator.of(context).pop();
                  // print(SevaCore.of(context).loggedInUser);

                  //widget.communityModel.id
                  //here is the thing

                  await Firestore.instance
                      .collection("users")
                      .document(SevaCore.of(context).loggedInUser.email)
                      .updateData({
                    'communities':
                        FieldValue.arrayUnion([widget.communityModel.id]),
                    'currentCommunity': widget.communityModel.id
                  });

                  setState(() {
                    SevaCore.of(context).loggedInUser.currentCommunity =
                        widget.communityModel.id;
                  });

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context1) => SevaCore(
                          loggedInUser: SevaCore.of(context).loggedInUser,
                          child: HomePageRouter(),
                        ),
                      ),
                      (Route<dynamic> route) => false);

                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (context1) => HomePageRouter(
                  //         // sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
                  //         ),
                  //   ),
                  // );
                })
              }
          };
      createEditCommunityBloc.VerifyTimebankWithCode(
        controller.text,
        func,
        widget.communityModel.id,
      );
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

  CompareToTimeBank compareTimeBanks(List<JoinRequestModel> joinRequestModels,
      TimebankModel timeBank, String sevaUserId) {
    // CompareToTimeBank status;
    print("inside compareTimeBanks " + joinRequestModels.length.toString());
    for (int i = 0; i < joinRequestModels.length; i++) {
      JoinRequestModel requestModel = joinRequestModels[i];

      /*if (requestModel.entityId == timeBank.id &&
          joinRequestModels[i].accepted == true) {
        return CompareToTimeBank.JOINED;
      } else if (timeBank.admins
          .contains(sevaUserId)) {
        return CompareToTimeBank.JOINED;
      } else if (timeBank.coordinators
          .contains(sevaUserId)) {
        return CompareToTimeBank.JOINED;
      } else if (timeBank.members
          .contains(sevaUserId)) {
        return CompareToTimeBank.JOINED;
      }*/

      if (requestModel.entityId == timeBank.id &&
          requestModel.operationTaken == false) {
        return CompareToTimeBank.REQUESTED;
      } else if (requestModel.entityId == timeBank.id &&
          requestModel.operationTaken == true &&
          requestModel.accepted == false) {
        return CompareToTimeBank.REJECTED;
      } else {
        return CompareToTimeBank.JOIN;
      }
    }
    return CompareToTimeBank.JOIN;
  }

  void showProgressDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogLoadingContext = createDialogContext;
          return AlertDialog(
            title: Text('Creating Request'),
            content: LinearProgressIndicator(),
          );
        });
  }
}

enum TimeBankResponseModes { ONBOARDED, CODE_EXPIRED, NO_CODE }
