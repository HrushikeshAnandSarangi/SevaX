import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

class CreateOfferRequest extends StatefulWidget {
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;

  CreateOfferRequest({
    Key key,
    this.offer,
    this.timebankId,
    this.userModel,
  }) : super(key: key);

  @override
  _CreateOfferRequestState createState() => _CreateOfferRequestState();
}

class _CreateOfferRequestState extends State<CreateOfferRequest>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  RequestModel requestModel;
  var focusNodes = List.generate(3, (_) => FocusNode());
  List<String> eventsIdsArr = [];
  GeoFirePoint location;
  String selectedAddress = '';
  int sharedValue = 0;
  String _selectedTimebankId;
  bool isAdmin = false;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();
  CommunityModel communityModel;
  @override
  void initState() {
    super.initState();

    AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;

    _selectedTimebankId = widget.timebankId;
    Future.delayed(Duration.zero, () {
      requestModel = RequestModel(
          requestType: RequestType.TIME,
          goodsDonationDetails: GoodsDonationDetails(),
          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
          timebankId: widget.timebankId,
          email: SevaCore.of(context).loggedInUser.email,
          sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID);
      this.requestModel.virtualRequest = false;
      this.requestModel.public = false;
      this.requestModel.timebankId = _selectedTimebankId;
      this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
      requestModel.requestType = widget.offer.type;
      fetchRemoteConfig();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirestoreManager.getTimeBankForId(
          timebankId: widget.timebankId,
        ).then((onValue) {
          setState(() {
            timebankModel = onValue;
          });
          // if (isAccessAvailable(
          //     timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)) {
          //   isAdmin = true;
          // }
        });
        // executes after build
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Create Offer Request',
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            CommonHelpIconWidget(),
          ],
        ),
        body: timebankModel == null
            ? LoadingIndicator()
            : Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          headerContainer(),
                          SizedBox(height: 14),
                          Text(
                            "${S.of(context).request_title}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                              color: Colors.black,
                            ),
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (value) {
                              updateExitWithConfirmationValue(
                                  context, 1, value);
                            },
                            onFieldSubmitted: (v) {
                              FocusScope.of(context)
                                  .requestFocus(focusNodes[0]);
                            },
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              hintText: S.of(context).request_title_hint,
                              hintStyle: hintTextStyle,
                            ),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            initialValue: getOfferTitle(
                              offerDataModel: widget.offer,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value.isEmpty) {
                                return S.of(context).request_subject;
                              }
                              if (profanityDetector.isProfaneString(value)) {
                                return S.of(context).profanity_text_alert;
                              }
                              requestModel.title = value;
                            },
                          ),
                          SizedBox(height: 30),
                          OfferDurationWidget(
                            title: "${S.of(context).request_duration} *",
                          ),
                          TimeRequest(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: Center(
                              child: Container(
                                child: RaisedButton(
                                  onPressed: createRequest,
                                  child: Text(
                                    S
                                        .of(context)
                                        .create_request
                                        .padLeft(10)
                                        .padRight(10),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .button,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  Widget headerContainer() {
    if (isAccessAvailable(
        timebankModel, SevaCore.of(context).loggedInUser.sevaUserID)) {
      return requestSwitch(
        timebankModel: timebankModel,
      );
    } else {
      this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      //this.requestModel.requestType = RequestType.TIME;
      return Container();
    }
  }

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${S.of(context).request_description}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              if (value != null && value.length > 5) {}
              updateExitWithConfirmationValue(context, 9, value);
            },
            focusNode: focusNodes[0],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[1]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: hintTextDesc,
              hintStyle: hintTextStyle,
            ),
            initialValue: getOfferDescription(
              offerDataModel: widget.offer,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              }
              if (profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              }
              requestModel.description = value;
              return null;
            },
          ),
        ]);
  }

  Widget TimeRequest() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RequestDescriptionData(S.of(context).request_description_hint),
          SizedBox(height: 20),
          Text(
            S.of(context).max_credits,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: focusNodes[1],
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[2]);
                  },
                  onChanged: (v) {
                    updateExitWithConfirmationValue(context, 10, v);
                    if (v.isNotEmpty && int.parse(v) >= 0) {
                      requestModel.maxCredits = int.parse(v);
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    hintText: S.of(context).max_credit_hint,
                    hintStyle: hintTextStyle,
                    // labelText: 'No. of volunteers',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).enter_max_credits;
                    } else if (int.parse(value) < 0) {
                      return S.of(context).enter_max_credits;
                    } else if (int.parse(value) == 0) {
                      return S.of(context).enter_max_credits;
                    } else {
                      requestModel.maxCredits = int.parse(value);
                      setState(() {});
                      return null;
                    }
                  },
                ),
              ),
              infoButton(
                context: context,
                key: GlobalKey(),
                type: InfoType.MAX_CREDITS,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).number_of_volunteers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            focusNode: focusNodes[2],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 11, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.numberOfApprovals = int.parse(v);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).number_of_volunteers,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_volunteer_count;
              } else if (int.parse(value) < 0) {
                return S.of(context).validation_error_volunteer_count_negative;
              } else if (int.parse(value) == 0) {
                return S.of(context).validation_error_volunteer_count_zero;
              } else {
                requestModel.numberOfApprovals = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 10),
          CommonUtils.TotalCredits(
            context: context,
            requestModel: requestModel,
            requestCreditsMode: TotalCreditseMode.CREATE_MODE,
          ),
          SizedBox(height: 15),
          Center(
            child: LocationPickerWidget(
              selectedAddress: selectedAddress,
              location: location,
              onChanged: (LocationDataModel dataModel) {
                log("received data model");
                setState(() {
                  location = dataModel.geoPoint;
                  this.selectedAddress = dataModel.location;
                });
              },
            ),
          )
        ]);
  }

  Widget requestSwitch({
    TimebankModel timebankModel,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: {
          0: Text(
            timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                ? S.of(context).timebank_request(1)
                : "Seva " +
                    timebankModel.name +
                    " ${S.of(context).group} " +
                    S.of(context).request,
            style: TextStyle(fontSize: 12.0),
          ),
          1: Text(
            S.of(context).personal_request(1),
            style: TextStyle(fontSize: 12.0),
          ),
        },
        borderColor: Colors.grey,
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        groupValue: sharedValue,

        onValueChanged: (int val) {
          if (val != sharedValue) {
            setState(() {
              if (val == 0) {
                requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
              } else {
                requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
                //requestModel.requestType = RequestType.TIME;
              }
              sharedValue = val;
            });
          }
        },
        //groupValue: sharedValue,
      ),
    );
  }

  BuildContext dialogContext;

  void createRequest() async {
    // verify f the start and end date time is not same
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }
    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel.autoGenerated = false;

    requestModel.isRecurring = false;
    if (_formKey.currentState.validate()) {
      // validate request start and end date

      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp >
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater);
        return;
      }
      requestModel.approvedUsers = [];
      requestModel.participantDetails = {};

      requestModel.participantDetails[widget.offer.email] = AcceptorModel(
        communityId: widget.offer.communityId,
        communityName: '',
        memberEmail: widget.offer.email,
        memberName: widget.offer.fullName,
        memberPhotoUrl: widget.offer.photoUrlImage ?? widget.userModel.photoURL,
        timebankId: widget.offer.timebankId,
      ).toMap();

      switch (requestModel.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          var myDetails = SevaCore.of(context).loggedInUser;
          this.requestModel.fullName = myDetails.fullname;
          this.requestModel.photoUrl = myDetails.photoURL;
          var onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            credits: requestModel.numberOfHours.toDouble(),
            userId: myDetails.sevaUserID,
            communityId: timebankModel.communityId,
          );
          if (!onBalanceCheckResult) {
            showInsufficientBalance();
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel.fullName = timebankModel.name;
          requestModel.photoUrl = timebankModel.photoUrl;
          break;
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String timestampString = timestamp.toString();
      requestModel.id = '${requestModel.email}*$timestampString';
      requestModel.parent_request_id = null;
      communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      );
      requestModel.timebanksPosted = [timebankModel.id];
      requestModel.communityId =
          SevaCore.of(context).loggedInUser.currentCommunity;
      requestModel.softDelete = false;
      requestModel.postTimestamp = timestamp;
      requestModel.accepted = false;
      requestModel.acceptors = [];
      requestModel.invitedUsers = [];
      requestModel.recommendedMemberIdsForRequest = [];
      requestModel.categories = [];
      requestModel.address = selectedAddress;
      requestModel.location = location;
      requestModel.root_timebank_id = FlavorConfig.values.timebankId;
      requestModel.softDelete = false;
      requestModel.creatorName = SevaCore.of(context).loggedInUser.fullname;
      requestModel.isFromOfferRequest = true;
      linearProgressForCreatingRequest();

      await FirestoreManager.createRequest(requestModel: requestModel);
      //create invitation if its from offer only for cash and goods
      try {
        await sendNotification(
            offerModel: widget.offer,
            timebankModel: timebankModel,
            currentCommunity: widget.offer.communityId,
            requestModel: requestModel,
            sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
            targetUserId: widget.offer.sevaUserId,
            targetUserEmail: widget.offer.email);
      } on Exception catch (exception) {
        //Log to crashlytics

      }
      Navigator.pop(dialogContext);
      Navigator.pop(context);

      // if (SevaCore.of(context).loggedInUser.calendarId != null) {
      //   // calendar  integrated!
      //   if (communityModel.payment['planId'] !=
      //       SevaBillingPlans.NEIGHBOUR_HOOD_PLAN) {
      //     List<String> acceptorList = [widget.offer.email, requestModel.email];
      //     requestModel.allowedCalenderUsers = acceptorList.toList();
      //   } else {
      //     requestModel.allowedCalenderUsers = [];
      //   }
      //
      //   await continueCreateRequest(confirmationDialogContext: null);
      // } else {
      //
      //   eventsIdsArr = await _writeToDB();
      //
      //   Navigator.pop(dialogContext);
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) {
      //         return AddToCalendar(
      //             isOfferRequest: true,
      //             offer: widget.offer,
      //             requestModel: requestModel,
      //             userModel: widget.userModel,
      //             eventsIdsArr: eventsIdsArr);
      //       },
      //     ),
      //   );
      //   // await _settingModalBottomSheet(context);
      // }
    }
  }

  void continueCreateRequest({BuildContext confirmationDialogContext}) async {
    linearProgressForCreatingRequest();

    List<String> resVar = await _writeToDB();
    eventsIdsArr = resVar;
    Navigator.pop(dialogContext);

    if (resVar.length == 0 && requestModel.requestType != RequestType.BORROW) {
      showInsufficientBalance();
    }
    if (confirmationDialogContext != null) {
      Navigator.pop(confirmationDialogContext);
    }
    Navigator.pop(context, {'response': 'ACCEPTED'});
  }

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).creating_request),
            content: LinearProgressIndicator(),
          );
        });
  }

  void showInsufficientBalance() {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(S.of(context).insufficient_credits_for_request),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  void showDialogForTitle({String dialogTitle}) async {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  Future<List<String>> _writeToDB() async {
    List<String> resultVar = [];
    await FirestoreManager.createRequest(requestModel: requestModel);
    //create invitation if its from offer only for cash and goods
    try {
      await sendNotification(
          offerModel: widget.offer,
          timebankModel: timebankModel,
          currentCommunity: widget.offer.communityId,
          requestModel: requestModel,
          sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
          targetUserId: widget.offer.sevaUserId,
          targetUserEmail: widget.offer.email);
    } on Exception catch (exception) {
      //Log to crashlytics

    }
    resultVar.add(requestModel.id);
    return resultVar;
  }

  Future<void> sendNotification({
    RequestModel requestModel,
    String currentCommunity,
    String sevaUserID,
    String targetUserId,
    String targetUserEmail,
    TimebankModel timebankModel,
    OfferModel offerModel,
  }) async {
    WriteBatch batchWrite = Firestore.instance.batch();

    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
        requestModel: requestModel,
        timebankModel: timebankModel,
        offerModel: offerModel);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: offerModel.timebankId,
        data: requestInvitationModel.toMap(),
        isRead: false,
        type: NotificationType.OfferRequestInvite,
        communityId: currentCommunity,
        senderUserId: sevaUserID,
        targetUserId: targetUserId,
        isTimebankNotification: false);
    batchWrite.updateData(
        Firestore.instance.collection('requests').document(requestModel.id), {
      'invitedUsers': FieldValue.arrayUnion([offerModel.sevaUserId])
    });
    batchWrite.setData(
      Firestore.instance
          .collection('users')
          .document(targetUserEmail)
          .collection("notifications")
          .document(notification.id),
      notification.toMap(),
    );
    return await batchWrite
        .commit()
        .then((value) => true)
        .catchError((onError) => false);
  }
}
