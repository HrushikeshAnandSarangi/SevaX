import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class CreateOfferRequest extends StatefulWidget {
  final OfferModel? offer;
  final String? timebankId;

  CreateOfferRequest({
    Key? key,
    this.offer,
    this.timebankId,
  }) : super(key: key);

  @override
  _CreateOfferRequestState createState() => _CreateOfferRequestState();
}

class _CreateOfferRequestState extends State<CreateOfferRequest>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  RequestModel? requestModel;
  var focusNodes = List.generate(3, (_) => FocusNode());
  List<String> eventsIdsArr = [];
  GeoFirePoint? location;
  String selectedAddress = '';
  int sharedValue = 0;
  String? _selectedTimebankId;
  TimebankModel? timebankModel;
  final profanityDetector = ProfanityDetector();
  CommunityModel? communityModel;
  @override
  void initState() {
    super.initState();

    AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;

    _selectedTimebankId = widget.timebankId;
    Future.delayed(Duration.zero, () {
      requestModel = RequestModel(
        requestType: RequestType.TIME,
        goodsDonationDetails: GoodsDonationDetails(
          donors: [],
          address: '',
          requiredGoods: {},
        ),
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        timebankId: widget.timebankId,
        email: SevaCore.of(context).loggedInUser.email,
        sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID,
      );
      this.requestModel!.virtualRequest = false;
      this.requestModel!.public = false;
      this.requestModel!.timebankId = _selectedTimebankId;
      this.requestModel!.requestMode = RequestMode.TIMEBANK_REQUEST;
      requestModel!.requestType = widget.offer!.type;
      requestModel!.offerId = widget.offer!.id;
      this.requestModel!.title = widget.offer!.individualOfferDataModel!.title;
      this.requestModel!.description =
          widget.offer!.individualOfferDataModel!.description;

      fetchRemoteConfig();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FirestoreManager.getTimeBankForId(
          timebankId: widget.timebankId!,
        ).then((onValue) {
          setState(() {
            timebankModel = onValue;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.i("message");
    return ExitWithConfirmation(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            S.of(context).accept_offer,
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
                          OfferDurationWidget(
                            title: "${S.of(context).offer_duration} *",
                          ),
                          TimeRequest(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: Center(
                              child: Container(
                                child: CustomElevatedButton(
                                  onPressed: createRequest,
                                  color: Theme.of(context).primaryColor,
                                  shape: StadiumBorder(),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  elevation: 2.0,
                                  textColor: Colors.white,
                                  child: Text(
                                    S
                                        .of(context)
                                        .accept_offer
                                        .padLeft(10)
                                        .padRight(10),
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .labelLarge,
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
    AppConfig.remoteConfig = FirebaseRemoteConfig.instance;
    await AppConfig.remoteConfig!.fetchAndActivate();
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  Widget headerContainer() {
    if (isAccessAvailable(
        timebankModel!, SevaCore.of(context).loggedInUser.sevaUserID!)) {
      return requestSwitch(
        timebankModel: timebankModel!,
      );
    } else {
      this.requestModel!.requestMode = RequestMode.PERSONAL_REQUEST;
      this.requestModel!.requestType = RequestType.TIME;
      return Container();
    }
  }

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[]);
  }

  Widget TimeRequest() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RequestDescriptionData(S.of(context).request_description_hint),
          SizedBox(height: 15),
        ]);
  }

  Widget requestSwitch({
    TimebankModel? timebankModel,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 0),
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: {
          0: Text(
            timebankModel!.parentTimebankId == FlavorConfig.values.timebankId
                ? S.of(context).timebank_request(1)
                : S.of(context).seva +
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
                requestModel!.requestMode = RequestMode.TIMEBANK_REQUEST;
              } else {
                requestModel!.requestMode = RequestMode.PERSONAL_REQUEST;
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

  BuildContext? dialogContext;

  void createRequest() async {
    logger.i("Inside create Request ======");
    requestModel!.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel!.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel!.autoGenerated = false;

    requestModel!.isRecurring = false;
    if (_formKey.currentState!.validate()) {
      // validate request start and end date

      if (requestModel!.requestStart == 0 || requestModel!.requestEnd == 0) {
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
      requestModel!.approvedUsers = [];
      requestModel!.participantDetails = {};

      requestModel!.participantDetails![widget.offer!.email] = AcceptorModel(
        communityId: widget.offer!.communityId,
        communityName: '',
        memberEmail: widget.offer!.email,
        memberName: widget.offer!.fullName,
        memberPhotoUrl: widget.offer!.photoUrlImage ?? defaultUserImageURL,
        timebankId: widget.offer!.timebankId,
      ).toMap();

      switch (requestModel!.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          var myDetails = SevaCore.of(context).loggedInUser;
          this.requestModel!.fullName = myDetails.fullname;
          this.requestModel!.photoUrl = myDetails.photoURL;
          CreditResult onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email!,
            credits: widget.offer!.individualOfferDataModel!.minimumCredits
                .toDouble(),
            userId: myDetails.sevaUserID!,
            communityId: timebankModel!.communityId,
          );
          if (!onBalanceCheckResult.hasSuffiientCredits) {
            showInsufficientBalance();
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel!.fullName = timebankModel!.name;
          requestModel!.photoUrl = timebankModel!.photoUrl;
          break;
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String timestampString = timestamp.toString();
      requestModel!.id = '${requestModel!.email}*$timestampString';
      requestModel!.parent_request_id = null;
      communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity!,
      );
      requestModel!.timebanksPosted = [timebankModel!.id];
      requestModel!.communityId =
          SevaCore.of(context).loggedInUser.currentCommunity;
      requestModel!.softDelete = false;
      requestModel!.postTimestamp = timestamp;
      requestModel!.accepted = false;
      requestModel!.acceptors = [];
      requestModel!.invitedUsers = [];
      requestModel!.recommendedMemberIdsForRequest = [];
      requestModel!.categories = [];
      requestModel!.address = selectedAddress;

      requestModel!.location = location;
      requestModel!.root_timebank_id = FlavorConfig.values.timebankId;
      requestModel!.softDelete = false;
      requestModel!.creatorName = SevaCore.of(context).loggedInUser.fullname;
      requestModel!.isFromOfferRequest = true;

      requestModel!.numberOfApprovals = 1;
      requestModel!.minimumCredits =
          widget.offer!.individualOfferDataModel!.minimumCredits ?? 0;
      requestModel!.maxCredits = 0;
      logger.i('========= send notifiction');
      linearProgressForCreatingRequest();

      await FirestoreManager.createRequest(requestModel: requestModel!);
      //create invitation if its from offer only for cash and goods
      try {
        await sendNotification(
          offerModel: widget!.offer!,
          timebankModel: timebankModel!,
          currentCommunity: widget.offer!.communityId!,
          requestModel: requestModel!,
          sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID!,
          targetUserId: widget.offer!.sevaUserId!,
          targetUserEmail: widget.offer!.email!,
        );
      } on Exception catch (exception) {
        //Log to crashlytics
      }
      Navigator.pop(dialogContext!);
      Navigator.pop(context);
    }
  }

  Map<String, Object> getOfferAcceptorDocument({
    TimebankModel? timebankModel,
    String? offerId,
    String? notifictionId,
  }) {
    var status = 'REQUESTED';

    var timebankId = timebankModel!.id;
    var communityId = SevaCore.of(context).loggedInUser.currentCommunity;

    var fullName = SevaCore.of(context).loggedInUser.fullname;
    var photoURL = SevaCore.of(context).loggedInUser.photoURL;
    var acceptorEmail = SevaCore.of(context).loggedInUser.email;
    var acceptorSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
    var acceptorBio = SevaCore.of(context).loggedInUser.bio;

    return {
      'requestId': requestModel!.id!,
      'requestStartDate': requestModel!.requestStart!,
      'requestEndDate': requestModel!.requestEnd!,
      'requestTitle': requestModel!.title!,
      'status': status,
      'offerId': offerId!,
      'timebankId': timebankId,
      'acceptorNotificationId': notifictionId!,
      'id': notifictionId,
      'communityId': communityId!,
      'mode': requestModel!.requestMode.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'participantDetails': {
        'fullname': requestModel!.requestMode == RequestMode.PERSONAL_REQUEST
            ? fullName
            : timebankModel.name,
        'photourl': requestModel!.requestMode == RequestMode.PERSONAL_REQUEST
            ? photoURL
            : timebankModel.photoUrl,
        'email': acceptorEmail,
        'sevauserid': acceptorSevaUserId,
        'bio': acceptorBio,
      }
    };
  }

  // Future<void> createOfferAcceptorDocument({

  // }) async {

  // }

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
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

  void showInsufficientBalance() {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(S.of(context).insufficient_credits_for_request),
            actions: <Widget>[
              CustomTextButton(
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

  void showDialogForTitle({String? dialogTitle}) async {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle!),
            actions: <Widget>[
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
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
    await FirestoreManager.createRequest(requestModel: requestModel!);
    //create invitation if its from offer only for cash and goods
    try {
      await sendNotification(
          offerModel: widget.offer!,
          timebankModel: timebankModel!,
          currentCommunity: widget.offer!.communityId!,
          requestModel: requestModel!,
          sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID!,
          targetUserId: widget.offer!.sevaUserId!,
          targetUserEmail: widget.offer!.email!);
    } on Exception catch (exception) {
      //Log to crashlytics
    }
    resultVar.add(requestModel!.id!);
    return resultVar;
  }

  Future<bool> sendNotification({
    RequestModel? requestModel,
    String? currentCommunity,
    String? sevaUserID,
    String? targetUserId,
    String? targetUserEmail,
    TimebankModel? timebankModel,
    OfferModel? offerModel,
  }) async {
    var notificationId = utils.Utils.getUuid();
    WriteBatch batchWrite = CollectionRef.batch;

    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
        requestModel: requestModel,
        timebankModel: timebankModel,
        offerModel: offerModel);

    var offerAcceptorDocument = getOfferAcceptorDocument(
      timebankModel: timebankModel,
      offerId: widget.offer!.id,
      notifictionId: notificationId,
    );

    NotificationsModel notification = NotificationsModel(
      id: notificationId,
      timebankId: offerModel!.timebankId,
      data: offerAcceptorDocument,
      isRead: false,
      type: NotificationType.OfferRequestInvite,
      communityId: currentCommunity,
      senderUserId: sevaUserID,
      targetUserId: targetUserId,
      isTimebankNotification: false,
    );

    batchWrite.update(CollectionRef.requests.doc(requestModel!.id), {
      'invitedUsers': FieldValue.arrayUnion([offerModel.sevaUserId])
    });
    batchWrite.set(
      CollectionRef.users
          .doc(targetUserEmail)
          .collection("notifications")
          .doc(notification.id),
      notification.toMap(),
    );

    batchWrite.set(
        CollectionRef.offers
            .doc(widget.offer!.id)
            .collection('offerAcceptors')
            .doc(notificationId),
        offerAcceptorDocument);

    // await createOfferAcceptorDocument(
    //   timebankModel: timebankModel,
    //   offerId: widget.offer.id,
    //   notifictionId: notificationId,
    // );
    return await batchWrite
        .commit()
        .then((value) => true)
        .catchError((onError) => false);
  }
}
