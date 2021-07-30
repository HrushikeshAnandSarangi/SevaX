import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/notifications_model.dart' as prefix0;
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
//  JoinRequestModel getRequestData = JoinRequestModel();
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

    isDataLoaded = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    JOIN = S.of(context).join.toUpperCase();
    JOINED = S.of(context).joined.toUpperCase();
    REQUESTED = S.of(context).requested.toUpperCase();
    REJECTED = S.of(context).rejected.toUpperCase();
    return isDataLoaded
        ? Scaffold(
            key: _scaffold,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                S.of(context).join + ' ' + S.of(context).timebank,
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
            body: LoadingIndicator(),
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
                child: LoadingIndicator(),
              );
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
                  S.of(context).join_timebank_code_message,
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
                    pinBoxWidth: 45,
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
                          S.of(context).join_timebank_request_invite_hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        CustomTextButton(
                          child: Text(
                            S.of(context).join_timebank_request_invite,
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
                      S.of(context).join_timbank_already_requested,
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
            child: CustomElevatedButton(
              onPressed: () {
                this._checkFields();
              },
              child: Text(
                S.of(context).join,
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
                        child: CustomElevatedButton(

                            child: Text(
                              'Join',
                            ),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {

                              this._checkFields();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
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
    return JoinRequestModel(
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
    return NotificationsModel(
      timebankId: timebankModel.id,
      id: joinRequestModel.notificationId,
      targetUserId: timebankModel.creatorId,
      senderUserId: userIdForNewMember,
      type: prefix0.NotificationType.JoinRequest,
      isRead: false,
      isTimebankNotification: true,
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
          title: Text(S.of(context).join_timebank_question +
              " ${FlavorConfig.values.timebankTitle}? "),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: formkey,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: S.of(context).reason,
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 1,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).validation_error_general_text;
                    }
                    reasonToJoin = value;
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Colors.grey,
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  CustomTextButton(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    color: Theme.of(context).accentColor,
                    textColor: FlavorConfig.values.buttonTextColor,
                    child: Text(
                      S.of(context).send_request,
                      style: TextStyle(
                        fontSize: dialogButtonSize,
                        fontFamily: 'Europa',
                        color: Colors.white,
                      ),
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
    WriteBatch batchWrite = CollectionRef.batch;
    batchWrite.set(
        CollectionRef.timebank
            .doc(
              primaryTimebankId,
            )
            .collection("notifications")
            .doc(notification.id),
        (notification..isTimebankNotification = true).toMap());
    batchWrite.set(CollectionRef.joinRequests.doc(joinRequestModel.id),
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
                    dialogTitle: S.of(context).code_not_found,
                    dialogSubTitle:
                        "${S.of(context).timebank} ${S.of(context).validation_error_wrong_timebank_code}")
              }
            else if (state == 'code_expired')
              {
                _showDialog(
                  activityContext: context,
                  mode: TimeBankResponseModes.CODE_EXPIRED,
                  dialogTitle: S.of(context).code_expired,
                  dialogSubTitle:
                      "${S.of(context).timebank}  ${S.of(context).join_code_expired_hint}",
                )
              }
            else if (state == 'code_already_redeemed')
              {
                _showDialog(
                  activityContext: context,
                  mode: TimeBankResponseModes.CODE_ALREADY_REDEEMED,
                  dialogTitle: S
                      .of(context)
                      .validation_error_timebank_join_code_redeemed,
                  dialogSubTitle: S
                      .of(context)
                      .validation_error_timebank_join_code_redeemed_self,
                )
              }
            else
              {
                response = _showDialog(
                    mode: TimeBankResponseModes.ONBOARDED,
                    dialogTitle: S.of(context).awesome,
                    dialogSubTitle:
                        "${S.of(context).timebank_onboarding_message} ${state.toString()} ${S.of(context).successfully}"),
                response.then((onValue) async {
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.));
                  // Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                  // Navigator.of(context).pop();

                  //widget.communityModel.id
                  //here is the thing

                  await onBoardMember(
                    communityId: widget.communityModel.id,
                    onBaordingMemberSevaId: widget.user.sevaUserID,
                    onBoardingMemberEmail: widget.user.email,
                    userModel: widget.user,
                    adminEmail: SevaCore.of(context).loggedInUser.email,
                    adminId: SevaCore.of(context).loggedInUser.sevaUserID,
                    adminFullName: SevaCore.of(context).loggedInUser.fullname,
                    adminPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
                    timebankModel: timebankModel,
                    timebankTitle: timebankModel.name,
                  ).commit();

                  setState(() {
                    widget.user.communities.add(widget.communityModel.id);
                    widget.user.currentCommunity = widget.communityModel.id;
                    widget.user.currentTimebank =
                        widget.communityModel.primary_timebank;
                  });
                  // Phoenix.rebirth(context);
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
        setError(errorMessage: S.of(context).enter_code_to_verify);
      }
    }
  }

  WriteBatch onBoardMember({
    String onBoardingMemberEmail,
    String communityId,
    String onBaordingMemberSevaId,
    UserModel userModel,
    String adminEmail,
    String adminId,
    String adminFullName,
    String adminPhotoUrl,
    TimebankModel timebankModel,
    String timebankTitle,
  }) {
    var batchUpdate = CollectionRef.batch;

    var userUpdateRef = CollectionRef.users.doc(onBoardingMemberEmail);

    var communityMembersRef = CollectionRef.communities.doc(communityId);

    UserAddedModel userAddedModel = UserAddedModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        addedMemberName: SevaCore.of(context).loggedInUser.fullname,
        adminName: "");

    NotificationsModel notificationModel = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: timebankModel.id,
        data: userAddedModel.toMap(),
        isRead: false,
        type: NotificationType.TypeMemberJoinViaCode,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: timebankModel.id,
        isTimebankNotification: true);

    var notificationRef = CollectionRef.timebank
        .doc(timebankModel.id)
        .collection("notifications")
        .doc(notificationModel.id);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankModel.id)
        .collection('entryExitLogs')
        .doc();

    batchUpdate.set(notificationRef, notificationModel.toMap());

    batchUpdate.update(userUpdateRef, {
      'communities': FieldValue.arrayUnion([communityId]),
      'currentCommunity': communityId,
      'currentTimebank': timebankModel.id
    });

    batchUpdate.update(communityMembersRef, {
      'members': FieldValue.arrayUnion([onBaordingMemberSevaId])
    });

    logger.e('JOINED VIA CODE START');
    batchUpdate.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.JOINED_VIA_CODE.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': onBoardingMemberEmail,
        'id': onBaordingMemberSevaId,
        'fullName': userModel.fullname,
        'photoUrl': userModel.photoURL,
      },
      // 'adminDetails': {
      //   'email': adminEmail,
      //   'id': adminId,
      //   'fullName': adminFullName,
      //   'photoUrl': adminPhotoUrl,
      // },
      'associatedTimebankDetails': {
        'timebankId': timebankModel.id,
        'timebankTitle': timebankTitle,
        'missionStatement': timebankModel.missionStatement,
      },
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

        return AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogSubTitle),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            CustomTextButton(
              child: Text(
                S.of(context).dismiss,
                style: TextStyle(
                  fontSize: dialogButtonSize,
                  color: Colors.red,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, mode);
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
            title: Text(S.of(context).creating_join_request),
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
