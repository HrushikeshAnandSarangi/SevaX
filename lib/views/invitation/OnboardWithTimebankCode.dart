import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import '../../flavor_config.dart';
import '../core.dart';
/*import 'edit_super_admins_view.dart';
import 'edit_timebank_view.dart';*/

class OnBoardWithTimebank extends StatefulWidget {
  final CommunityModel communityModel;
  final String sevauserId;
  final bool isFromExplore;
  final UserModel user;

  OnBoardWithTimebank(
      {this.communityModel,
      this.sevauserId,
      this.isFromExplore = false,
      this.user});

  @override
  State<StatefulWidget> createState() => OnBoardWithTimebankState();
}

enum CompareToTimeBank { JOINED, REQUESTED, REJECTED, JOIN }

class OnBoardWithTimebankState extends State<OnBoardWithTimebank> {
  // TRUE: register page, FALSE: login page
  TextEditingController controller = TextEditingController();
  TimebankModel timebankModel;

  static String JOIN;
  static String JOINED;
  static String REQUESTED;
  static String REJECTED;
  bool isDataLoaded = false;

  List<JoinRequestModel> _joinRequestModelList;

  String reasonToJoin;

  //TimebankModel superAdminModel;
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
    JOIN = AppLocalizations.of(context).translate('jointimebankcode','join');
    JOINED = AppLocalizations.of(context).translate('jointimebankcode','joined');
    REQUESTED = AppLocalizations.of(context).translate('jointimebankcode','requested');
    REJECTED = AppLocalizations.of(context).translate('jointimebankcode','rejected');
    return isDataLoaded
        ? Scaffold(
            key: _scaffold,
            appBar: !widget.isFromExplore
                ? AppBar(
                    centerTitle: true,
                    title: Text(
                      AppLocalizations.of(context).translate('jointimebankcode','join_timebank'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        // fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : null,
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
    requestStatus = compareTimeBanks(
        _joinRequestModelList, timebankModel, widget.user.sevaUserID);

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
                  AppLocalizations.of(context).translate('jointimebankcode','desc'),
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
              requestStatus == CompareToTimeBank.JOIN ||
                      requestStatus == CompareToTimeBank.REJECTED
                  ? Column(
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('jointimebankcode','request_invite_hint'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            AppLocalizations.of(context).translate('jointimebankcode','request_invite'),
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
                AppLocalizations.of(context).translate('jointimebankcode','already_joined'),
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
                AppLocalizations.of(context).translate('jointimebankcode','join_button'),
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

  JoinRequestModel _assembleJoinRequestModel({
    String userIdForNewMember,
    String communityLabel,
    String communityPrimaryTimebankId,
  }) {
    return new JoinRequestModel(
      timebankTitle: communityLabel,
      accepted: false,
      entityId: communityPrimaryTimebankId,
      entityType: EntityType.Timebank,
      operationTaken: false,
      reason: reasonToJoin,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userId: userIdForNewMember,
      isFromGroup: false,
      notificationId: utils.Utils.getUuid(),
    );
  }

  NotificationsModel _assembleNotificationForJoinRequest({
    String userIdForNewMember,
    JoinRequestModel joinRequestModel,
    String communityLabel,
    String communityPrimaryTimebankId,
  }) {
    return new NotificationsModel(
      timebankId: timebankModel.id,
      id: joinRequestModel.notificationId,
      targetUserId: timebankModel.creatorId,
      senderUserId: userIdForNewMember,
      type: prefix0.NotificationType.JoinRequest,
      data: joinRequestModel.toMap(),
      communityId: widget.communityModel.id,
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
              AppLocalizations.of(context).translate('jointimebankcode','alert_desc') + " ${FlavorConfig.values.timebankTitle}? "),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: formkey,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).translate('jointimebankcode','alert_label'),
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
                      return AppLocalizations.of(context).translate('jointimebankcode','alert_warn');
                    }
                    reasonToJoin = value;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  new FlatButton(
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: new Text(
                      AppLocalizations.of(context).translate('jointimebankcode','send_request'),
                      style: TextStyle(
                          fontSize: dialogButtonSize, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      if (formkey.currentState.validate()) {
                        Navigator.of(dialogContext).pop();
                        showProgressDialog();
                        await _assembleAndSendRequest(
                          communityCreateEditSnapshot,
                        );

                        if (dialogLoadingContext != null) {
                          Navigator.pop(dialogLoadingContext);
                        }
                        Navigator.of(context).pop();

                        return;
                      }
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      AppLocalizations.of(context).translate('shared','cancel'),
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontFamily: 'Europa'),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future _assembleAndSendRequest(
      CommunityCreateEditController communityCreateEditSnapshot) async {
    var joinRequestModel = _assembleJoinRequestModel(
      userIdForNewMember: communityCreateEditSnapshot.loggedinuser.sevaUserID,
      communityLabel: communityCreateEditSnapshot.selectedCommunity.name,
      communityPrimaryTimebankId:
          communityCreateEditSnapshot.selectedCommunity.primary_timebank,
    );

    var notification = _assembleNotificationForJoinRequest(
      joinRequestModel: joinRequestModel,
      userIdForNewMember: communityCreateEditSnapshot.loggedinuser.sevaUserID,
      communityLabel: communityCreateEditSnapshot.selectedCommunity.name,
      communityPrimaryTimebankId:
          communityCreateEditSnapshot.selectedCommunity.primary_timebank,
    );

    await createAndSendJoinJoinRequest(
      joinRequestModel: joinRequestModel,
      notification: notification,
      primaryTimebankId:
          communityCreateEditSnapshot.selectedCommunity.primary_timebank,
    ).commit();
  }

  WriteBatch createAndSendJoinJoinRequest({
    String primaryTimebankId,
    prefix0.NotificationsModel notification,
    JoinRequestModel joinRequestModel,
  }) {
    WriteBatch batchWrite = Firestore.instance.batch();
    batchWrite.setData(
        Firestore.instance
            .collection('timebanknew')
            .document(
              primaryTimebankId,
            )
            .collection("notifications")
            .document(notification.id),
        notification.toMap());
    batchWrite.setData(
        Firestore.instance
            .collection('join_requests')
            .document(joinRequestModel.id),
        joinRequestModel.toMap());

    return batchWrite;
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
                    dialogTitle: AppLocalizations.of(context).translate('jointimebankcode','dialog_title_1'),
                    dialogSubTitle:
                        "${AppLocalizations.of(context).translate('jointimebankcode','this')} ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : AppLocalizations.of(context).translate('jointimebankcode','timebank')} ${AppLocalizations.of(context).translate('jointimebankcode','not_found')}")
              }
            else if (state == 'code_expired')
              {
                _showDialog(
                    activityContext: context,
                    mode: TimeBankResponseModes.CODE_EXPIRED,
                    dialogTitle: AppLocalizations.of(context).translate('jointimebankcode','expired!'),
                    dialogSubTitle:
                        "${AppLocalizations.of(context).translate('jointimebankcode','this')} ${FlavorConfig.values.timebankName == "Yang 2020" ? "Yang Gang" : AppLocalizations.of(context).translate('jointimebankcode','timebank')}} AppLocalizations.of(context).translate('jointimebankcode','request_new_err')}")
              }
            else if (state == 'code_already_redeemed')
              {
                _showDialog(
                    activityContext: context,
                    mode: TimeBankResponseModes.CODE_ALREADY_REDEEMED,
                    dialogTitle: "Timebank code already redeemed",
                    dialogSubTitle:
                        "The Timebank code that you have provided has already been redeemed earlier by you. Please request the Timebank admin for a new code.")
              }
            else
              {
                response = _showDialog(
                    mode: TimeBankResponseModes.ONBOARDED,
                    dialogTitle: AppLocalizations.of(context).translate('jointimebankcode','awesome'),
                    dialogSubTitle:
                        "${AppLocalizations.of(context).translate('jointimebankcode','hint_text_joined')} ${state.toString()} ${AppLocalizations.of(context).translate('jointimebankcode','successfull')}"),
                response.then((onValue) async {
                  print("onboadrd");
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.));
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                  // Navigator.of(context).pop();
                  // print(widget.user);

                  //widget.communityModel.id
                  //here is the thing

                  await onBoardMember(
                    commmunityId: widget.communityModel.id,
                    onBaordingMemberSevaId: widget.user.sevaUserID,
                    onBoardingMemberEmail: widget.user.email,
                  ).commit();

                  setState(() {
                    widget.user.currentCommunity = widget.communityModel.id;
                  });

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context1) => SevaCore(
                          loggedInUser: widget.user,
                          child: HomePageRouter(),
                        ),
                      ),
                      (Route<dynamic> route) => false);

                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (context1) => HomePageRouter(
                  //         // sevaUserID: widget.user.sevaUserID,
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
        setError(errorMessage: AppLocalizations.of(context).translate('jointimebankcode','err_reenter'));
      }
    }
  }

  WriteBatch onBoardMember({
    String onBoardingMemberEmail,
    String commmunityId,
    String onBaordingMemberSevaId,
  }) {
    var batchUpdate = Firestore.instance.batch();

    var userUpdateRef =
        Firestore.instance.collection("users").document(onBoardingMemberEmail);

    var communityMembersRef =
        Firestore.instance.collection("communities").document(commmunityId);

    batchUpdate.updateData(userUpdateRef, {
      'communities': FieldValue.arrayUnion([commmunityId]),
      'currentCommunity': commmunityId
    });

    batchUpdate.updateData(communityMembersRef, {
      'members': FieldValue.arrayUnion([onBaordingMemberSevaId])
    });

    return batchUpdate;
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
            AppLocalizations.of(context).translate('shared','close'),
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.red,
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
                  case TimeBankResponseModes.CODE_ALREADY_REDEEMED:
                    Navigator.pop(
                        context, TimeBankResponseModes.CODE_ALREADY_REDEEMED);
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
            title: Text(AppLocalizations.of(context).translate('jointimebankcode','create_join_request')),
            content: LinearProgressIndicator(),
          );
        });
  }
}

enum TimeBankResponseModes {
  ONBOARDED,
  CODE_EXPIRED,
  NO_CODE,
  CODE_ALREADY_REDEEMED
}
