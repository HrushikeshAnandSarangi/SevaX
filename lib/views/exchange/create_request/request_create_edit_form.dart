import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
import 'package:sevaexchange/components/calendar_events/module/index.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/selectedSpeakerTimeDetails.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/exchange/borrow_request.dart';
import 'package:sevaexchange/views/exchange/cash_request.dart';
import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
import 'package:sevaexchange/views/exchange/goods_request.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/views/exchange/time_request.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../core.dart';

class RequestCreateEditForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  final ProjectModel projectModel;
  final String projectId;
  final ComingFrom comingFrom;
  final RequestModel requestModel;
  final RequestFormType formType;

  RequestCreateEditForm({
    this.isOfferRequest = false,
    @required this.comingFrom,
    this.offer,
    this.timebankId,
    this.userModel,
    @required this.loggedInUser,
    this.projectId,
    this.projectModel,
    this.requestModel,
    this.formType,
  });

  @override
  RequestCreateEditFormState createState() {
    return RequestCreateEditFormState();
  }
}

class RequestCreateEditFormState extends State<RequestCreateEditForm>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();
  ProjectModel selectedProjectModel = null;
  RequestModel requestModel;
  var focusNodes = List.generate(18, (_) => FocusNode());
  List<String> eventsIdsArr = [];
  List<String> selectedCategoryIds = [];
  bool comingFromDynamicLink = false;
  String hoursMessage;
  int sharedValue = 0;
  String _selectedTimebankId;
  var validItems = [];
  bool isAdmin = false;
  UserModel selectedInstructorModel;
  SelectedSpeakerTimeDetails selectedSpeakerTimeDetails =
      new SelectedSpeakerTimeDetails(speakingTime: 0.0, prepTime: 0);
  DocumentReference speakerNotificationDocRef;
  RequestUtils requestUtils = RequestUtils();

  String initialRequestTitle = '';
  String initialRequestDescription = '';
  var startDate;
  var endDate;
  int tempCredits = 0;
  int tempNoOfVolunteers = 0;
  String tempProjectId = '';

  // BasicUserDetails selectedInstructorModelTemp;
  int oldHours = 0;
  int oldTotalRecurrences = 0;
  bool isPublicCheckboxVisible = false;

  //Below variable for One to Many Requests
  bool createEvent = false;
  bool instructorAdded = false;
  Future<TimebankModel> getTimebankAdminStatus;
  Future<List<ProjectModel>> getProjectsByFuture;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();
  CommunityModel communityModel;
  Location location = Location();
  @override
  void initState() {
    super.initState();
    AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;
    WidgetsBinding.instance.addObserver(this);
    _selectedTimebankId = widget.timebankId;
    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    //create or edit initialization
    widget.formType == RequestFormType.CREATE
        ? _initializeCreateRequestModel()
        : _initializeEditRequestModel();

    getTimebankAdminStatus =
        getTimebankDetailsbyFuture(timebankId: _selectedTimebankId);
    fetchRemoteConfig();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedInstructorModel = SevaCore.of(context).loggedInUser;
      UserModel loggedInUser = SevaCore.of(context).loggedInUser;
      this.requestModel.email = loggedInUser.email;
      this.requestModel.sevaUserId = loggedInUser.sevaUserID;
      this.requestModel.communityId = loggedInUser.currentCommunity;

      FirestoreManager.getAllTimebankIdStream(
        timebankId: widget.timebankId,
      ).then((onValue) {
        setState(() {
          validItems = onValue.listOfElement;
          timebankModel = onValue.timebankModel;
        });
        if (isAccessAvailable(timebankModel, widget.loggedInUser.sevaUserID)) {
          isAdmin = true;
        }
      });
      // executes after build
    });
  }

  _initializeCreateRequestModel() {
    requestModel = RequestModel(
        requestType: RequestType.TIME,
        cashModel: CashModel(
            paymentType: RequestPaymentType.ZELLEPAY,
            achdetails: new ACHModel()),
        goodsDonationDetails: GoodsDonationDetails(),
        borrowModel: BorrowModel(),
        communityId: widget.loggedInUser.currentCommunity,
        oneToManyRequestAttenders: [],
        timebankId: widget.timebankId);
    this.requestModel.virtualRequest = false;
    this.requestModel.public = false;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.public = false;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = widget.projectId;
    this.requestModel.end = End();

    if (widget.isOfferRequest ?? false) {
      requestModel.requestType = widget.offer.type;
      requestModel.goodsDonationDetails.requiredGoods =
          widget.offer.goodsDonationDetails.requiredGoods;
    }

    tempProjectId = requestModel.projectId;
  }

  _initializeEditRequestModel() {
    requestModel = widget.requestModel;

    // selectedInstructorModelTemp = widget.requestModel.selectedInstructor;
    requestModel.timebankId = _selectedTimebankId;

    logger.d(requestModel.location.toString() +
        "From Database =====================");
    this.oldHours = requestModel.numberOfHours;
    if (requestModel.categories != null && requestModel.categories.length > 0) {
      getCategoryModels(
        widget.requestModel.categories,
      );
    }
    getTimebankAdminStatus =
        getTimebankDetailsbyFuture(timebankId: _selectedTimebankId);
    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    //will be true because a One to many request when editing should have an instructor
    if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      instructorAdded = true;
    }

    startDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: widget.loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestStart));
    endDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: widget.loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestEnd));

    logger.d("REQUEST CREATE WIDGET HASHCODE ${widget.requestModel.hashCode}");
    logger.d("REQUEST CREATE NEW HASHCODE ${requestModel.hashCode}");

    log('Instructor Data:  ' +
        widget.requestModel.selectedInstructor.toString());
    log('Instructor Data:  ' + widget.requestModel.approvedUsers.toString());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && comingFromDynamicLink) {
      Navigator.of(context).pop();
    }
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  @override
  void didChangeDependencies() {
    if (widget.formType == RequestFormType.EDIT) {
      requestModel.email = widget.requestModel.email;
      requestModel.fullName = widget.requestModel.fullName;
      requestModel.photoUrl = widget.requestModel.photoUrl;
      requestModel.sevaUserId = widget.requestModel.sevaUserId;
    }

    if (widget.loggedInUser?.sevaUserID != null)
      FirestoreManager.getUserForIdStream(
              sevaUserId: widget.loggedInUser.sevaUserID)
          .listen((userModel) {});
    super.didChangeDependencies();
  }

  Widget headerContainer(snapshot) {
    if (widget.formType == RequestFormType.CREATE) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (isAccessAvailable(
          snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID)) {
        return requestSwitch(
          timebankModel: timebankModel,
        );
      } else {
        this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        return Container();
      }
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.e('CREATE EVENT STATUS: ' + createEvent.toString());
    log("=========>>>>>>>  FROM CREATE STATE ${this.requestModel.communityId} ");

    log('REQUEST TYPE:  ' + requestModel.requestType.toString());
    log('ID timebank ' + requestModel.timebankId.toString());

    return FutureBuilder<TimebankModel>(
        future: getTimebankAdminStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          return FutureBuilder<List<ProjectModel>>(
              future: getProjectsByFuture,
              builder: (projectscontext, projectListSnapshot) {
                if (!projectListSnapshot.hasData) {
                  return Container();
                }
                List<ProjectModel> projectModelList = projectListSnapshot.data;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(S.of(context).error_loading_data);
                } else {
                  return Form(
                    key: _formKey,
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              headerContainer(snapshot),
                              RequestTypeWidgetCommunityRequests(),
                              RequestTypeWidgetPersonalRequests(),
                              SizedBox(height: 14),
                              Builder(
                                builder: (_) {
                                  switch (requestModel.requestType) {
                                    case RequestType.TIME:
                                      return TimeRequest(
                                        formType: widget.formType,
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        isOfferRequest: widget.isOfferRequest,
                                        isAdmin: isAdmin,
                                        createEvent: createEvent,
                                        instructorAdded: instructorAdded,
                                        timebankModel: snapshot.data,
                                        projectModelList: projectModelList,
                                        projectId: widget.projectId,
                                        selectedInstructorModel:
                                            selectedInstructorModel,
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        onCreateEventChanged: (value) =>
                                            createEvent = value,
                                      );
                                      break;
                                    case RequestType.CASH:
                                      return CashRequest(
                                        formType: widget.formType,
                                        isOfferRequest: widget.isOfferRequest,
                                        offer: widget.offer,
                                        projectModelList: projectModelList,
                                        requestModel: requestModel,
                                        comingFrom: widget.comingFrom,
                                        timebankId: widget.timebankId,
                                        timebankModel: snapshot.data,
                                        createEvent: createEvent,
                                        onCreateEventChanged: (value) =>
                                            createEvent = value,
                                        projectId: widget.projectId,
                                        instructorAdded: instructorAdded,
                                      );
                                      break;
                                    case RequestType.GOODS:
                                      return GoodsRequest(
                                        formType: widget.formType,
                                        requestModel: requestModel,
                                        timebankModel: snapshot.data,
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        isOfferRequest: widget.isOfferRequest,
                                        offer: widget.offer,
                                        instructorAdded: instructorAdded,
                                        projectId: widget.projectId,
                                        createEvent: createEvent,
                                        onCreateEventChanged: (value) =>
                                            createEvent = value,
                                        projectModelList: projectModelList,
                                      );
                                      break;
                                    case RequestType.BORROW:
                                      return BorrowRequest(
                                        formType: widget.formType,
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        createEvent: createEvent,
                                        projectId: widget.projectId,
                                        instructorAdded: instructorAdded,
                                        onCreateEventChanged: (value) =>
                                            createEvent = value,
                                        projectModelList: projectModelList,
                                        timebankModel: snapshot.data,
                                        comingFrom: widget.comingFrom,
                                        timebankId: widget.timebankId,
                                        isOfferRequest: widget.isOfferRequest,
                                      );
                                      break;
                                    case RequestType.ONE_TO_MANY_REQUEST:
                                      return TimeRequest(
                                        formType: widget.formType,
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        isOfferRequest: widget.isOfferRequest,
                                        isAdmin: isAdmin,
                                        createEvent: createEvent,
                                        instructorAdded: instructorAdded,
                                        timebankModel: snapshot.data,
                                        projectId: widget.projectId,
                                        projectModelList: projectModelList,
                                        selectedInstructorModel:
                                            selectedInstructorModel,
                                        selectedInstructorModelChanged:
                                            (value) {
                                          selectedInstructorModel = value;
                                        },
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        onCreateEventChanged: (value) =>
                                            createEvent = value,
                                      );
                                      break;
                                    case RequestType.LENDING_OFFER:
                                      return Container();
                                      break;
                                    case RequestType.ONE_TO_MANY_OFFER:
                                      return Container();
                                      break;
                                  }
                                  return Container();
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30.0),
                                child: Center(
                                  child: Container(
                                    child: CustomElevatedButton(
                                      onPressed: widget.formType ==
                                              RequestFormType.EDIT
                                          ? editRequest
                                          : createRequest,
                                      child: Text(
                                        widget.formType == RequestFormType.EDIT
                                            ? S
                                                .of(context)
                                                .update_request
                                                .padLeft(10)
                                                .padRight(10)
                                            : S
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
                  );
                }
              });
        });
  }

  Widget RequestTypeWidgetCommunityRequests() {
    return (widget.formType == RequestFormType.CREATE &&
            requestModel.requestMode == RequestMode.TIMEBANK_REQUEST)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).request_type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
              Column(
                children: <Widget>[
                  requestUtils.optionRadioButton<RequestType>(
                    title: S.of(context).request_type_time,
                    isEnabled: !widget.isOfferRequest,
                    value: RequestType.TIME,
                    groupvalue: requestModel.requestType,
                    onChanged: (value) {
                      //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                      instructorAdded = false;
                      requestModel.selectedInstructor = null;
                      requestModel.requestType = value;
                      AppConfig.helpIconContextMember =
                          HelpContextMemberType.time_requests;
                      setState(() => {});
                    },
                  ),
                  TransactionsMatrixCheck(
                    comingFrom: widget.comingFrom,
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.goods_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    child: ConfigurationCheck(
                      actionType: 'create_goods_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).request_type_goods,
                        isEnabled: !(widget.isOfferRequest ?? false),
                        value: RequestType.GOODS,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          requestModel.isRecurring = false;
                          requestModel.requestType = value;
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.goods_requests;

                          //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                          instructorAdded = false;
                          requestModel.selectedInstructor = null;
                          requestModel.requestType = value;
                          setState(() => {});
                        },
                      ),
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.cash_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_money_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).request_type_cash,
                        value: RequestType.CASH,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          requestModel.isRecurring = false;
                          requestModel.requestType = value;
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.money_requests;

                          //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                          instructorAdded = false;
                          requestModel.selectedInstructor = null;
                          requestModel.requestType = value;
                          setState(() => {});
                        },
                      ),
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.borrow_requests,
                    transaction_matrix_type: 'borrow_request',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_borrow_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).borrow,
                        value: RequestType.BORROW,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          //requestModel.isRecurring = true;
                          requestModel.requestType = value;
                          instructorAdded = false;
                          requestModel.selectedInstructor = null;
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.time_requests;
                          setState(() => {});
                        },
                      ),
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.onetomany_requests,
                    transaction_matrix_type: 'onetomany_requests',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_onetomany_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).one_to_many.sentenceCase(),
                        // TODO => sentence case
                        value: RequestType.ONE_TO_MANY_REQUEST,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          //requestModel.isRecurring = true;
                          requestModel.requestType = value;
                          //By default instructor for One To Many Requests is the creator
                          instructorAdded = true;
                          requestModel.selectedInstructor = BasicUserDetails(
                            fullname:
                                SevaCore.of(context).loggedInUser.fullname,
                            email: SevaCore.of(context).loggedInUser.email,
                            photoURL:
                                SevaCore.of(context).loggedInUser.photoURL,
                            sevaUserID:
                                SevaCore.of(context).loggedInUser.sevaUserID,
                          );
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.one_to_many_requests;
                          setState(() => {});
                        },
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        : Container();
  }

  Widget RequestTypeWidgetPersonalRequests() {
    return (widget.formType == RequestFormType.CREATE &&
            requestModel.requestMode == RequestMode.PERSONAL_REQUEST)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).request_type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
              Column(
                children: <Widget>[
                  requestUtils.optionRadioButton<RequestType>(
                    title: S.of(context).request_type_time,
                    isEnabled: !widget.isOfferRequest,
                    value: RequestType.TIME,
                    groupvalue: requestModel.requestType,
                    onChanged: (value) {
                      //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                      //instructorAdded = false;
                      //requestModel.selectedInstructor = null;
                      requestModel.requestType = value;
                      AppConfig.helpIconContextMember =
                          HelpContextMemberType.time_requests;

                      //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                      instructorAdded = false;
                      requestModel.selectedInstructor = null;
                      requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.cash_request,
                    transaction_matrix_type: 'borrow_request',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_borrow_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).borrow,
                        value: RequestType.BORROW,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          //requestModel.isRecurring = true;
                          requestModel.requestType = value;
                          instructorAdded = false;
                          requestModel.selectedInstructor = null;
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.time_requests;
                          setState(() => {});
                        },
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
        : Container();
  }

  Widget requestSwitch({
    TimebankModel timebankModel,
  }) {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: double.infinity,
        child: CupertinoSegmentedControl<int>(
          selectedColor: Theme.of(context).primaryColor,
          children: {
            0: Text(
              timebankModel.parentTimebankId == FlavorConfig.values.timebankId
                  ? S.of(context).timebank_request(1)
                  : S.of(context).seva +
                      " ${timebankModel.name}" +
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
                  setState(() {
                    instructorAdded = false;
                    requestModel.selectedInstructor = null;
                  });
                }
                sharedValue = val;
              });
            }
          },
        ),
      );
    } else {
      if (widget.projectModel != null) {
        if (widget.projectModel.mode == ProjectMode.TIMEBANK_PROJECT) {
          requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        }
      }
      return Container();
    }
  }

  // BuildContext dialogContext;
  bool hasRegisteredLocation() {
    return location != null;
  }

  void createRequest() async {
    // verify f the start and end date time is not same
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
        OfferDurationWidgetState.starttimestamp);
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
        OfferDurationWidgetState.endtimestamp);

    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel.autoGenerated = false;

    if (requestModel.requestType == RequestType.TIME ||
        requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      requestModel.isRecurring = RepeatWidgetState.isRecurring;
    } else {
      requestModel.isRecurring = false;
    }

    //recurring for creat events
    if (requestModel.isRecurring) {
      requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
      requestModel.occurenceCount = 1;
      requestModel.end.endType = RepeatWidgetState.endType == 0
          ? S.of(context).on
          : S.of(context).after;
      requestModel.end.on = requestModel.end.endType == S.of(context).on
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      requestModel.end.after = (requestModel.end.endType == S.of(context).after
          ? int.parse(RepeatWidgetState.after)
          : null);
    }

    // logger.d("END DATA  ${requestModel.end.after}");
    // logger.d("END TYPE  ${requestModel.end.endType}");

    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      // validate request start and end date

      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_no_date,
            context: context);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date,
            context: context);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp >
          OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater,
            context: context);
        return;
      }

      if (DateTime.fromMillisecondsSinceEpoch(
              OfferDurationWidgetState.starttimestamp)
          .isBefore(DateTime.now())) {
        requestUtils.showDialogForTitle(
            context: context, dialogTitle: S.of(context).past_time_selected);
        return;
      }

      if (requestModel.requestType == RequestType.GOODS &&
          (requestModel.goodsDonationDetails.requiredGoods.values == null ||
              requestModel.goodsDonationDetails.requiredGoods.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).goods_validation, context: context);
        return;
      }
      if (requestModel.requestType == RequestType.BORROW &&
          requestModel.roomOrTool ==
              LendingType.ITEM
                  .readable //because was throwing dialog when creating for place
          &&
          (requestModel.borrowModel.requiredItems == null ||
              requestModel.borrowModel.requiredItems.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).items_validation, context: context);
        return;
      }
      if (requestModel.requestType == RequestType.BORROW &&
          requestModel.location == null) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_location,
            context: context);
        return;
      }
      communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      );
      if (widget.isOfferRequest && widget.userModel != null) {
        //TODO
        requestModel.participantDetails = {};
        requestModel.participantDetails[widget.userModel.email] = AcceptorModel(
          communityId: widget.offer.communityId,
          communityName: timebankModel.name ?? '',
          memberEmail: widget.userModel.email,
          memberName: widget.userModel.fullname,
          memberPhotoUrl: widget.userModel.photoURL,
          timebankId: widget.offer.timebankId,
        ).toMap();
        //create an invitation for the request
      }

      if (requestModel.isRecurring &&
          (requestModel.requestType == RequestType.TIME ||
              requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST)) {
        if (requestModel.recurringDays.length == 0) {
          requestUtils.showDialogForTitle(
              dialogTitle: S.of(context).validation_error_empty_recurring_days,
              context: context);
          return;
        }
      }
/*
//Assigning room or tool for Borrrow Requests
      if ( requestModel.roomOrTool != null && requestModel.requestType == RequestType.BORROW) {
        if (roomOrTool == 1) {
          //CHANGE to use enums
          requestModel.roomOrTool = 'ITEM';
        } else {
          requestModel.roomOrTool = 'PLACE';
        }
      }*/
//Review done or not to be used to find out if Borrow request is completed or not
      if (requestModel.requestType != RequestType.BORROW) {
        requestModel.lenderReviewed = false;
        requestModel.borrowerReviewed = false;
      }

      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          (requestModel.selectedInstructor.toMap().isEmpty ||
              requestModel.selectedInstructor == null ||
              instructorAdded == false)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).select_a_speaker_dialog,
            context: context);
        return;
      }

      //Calculate session duration of one to many request using request start and request end time
      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        if (startDate != null && endDate != null) {
          Duration sessionDuration = endDate.difference(startDate);
          double sixty = 60;

          selectedSpeakerTimeDetails.speakingTime = double.parse(
              (sessionDuration.inMinutes / sixty).toStringAsPrecision(3));

          //prep time will be entered by speaker when he/she is completing the request
          selectedSpeakerTimeDetails.prepTime = 0;

          requestModel.selectedSpeakerTimeDetails = selectedSpeakerTimeDetails;

          setState(() {});
        }
      }

      //Form and date is valid
      //if(requestModel.requestType != RequestType.BORROW) {
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
          if (!onBalanceCheckResult.hasSuffiientCredits) {
            requestUtils.showInsufficientBalance(
                onBalanceCheckResult.credits, context);
            await sendInsufficentNotificationToAdmin(
                creditsNeeded: onBalanceCheckResult.credits,
                context: context,
                timebankModel: timebankModel);
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel.fullName = timebankModel.name;
          requestModel.photoUrl = timebankModel.photoUrl;
          break;
      }
      //}

      //create Request starts after validation and type
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String timestampString = timestamp.toString();
      requestModel.id = '${requestModel.email}*$timestampString';
      if (requestModel.isRecurring) {
        requestModel.parent_request_id = requestModel.id;
      } else {
        requestModel.parent_request_id = null;
      }

      requestModel.liveMode = !AppConfig.isTestCommunity;
      if (requestModel.public) {
        requestModel.timebanksPosted = [
          timebankModel.id,
          FlavorConfig.values.timebankId
        ];
      } else {
        requestModel.timebanksPosted = [timebankModel.id];
      }

      requestModel.communityId =
          SevaCore.of(context).loggedInUser.currentCommunity;
      requestModel.softDelete = false;
      requestModel.postTimestamp = timestamp;
      requestModel.accepted = false;
      requestModel.acceptors = [];
      requestModel.invitedUsers = [];
      requestModel.recommendedMemberIdsForRequest = [];
      // requestModel.categories = selectedCategoryIds;
      // requestModel.address = selectedAddress;
      // requestModel.location = location;
      requestModel.root_timebank_id = FlavorConfig.values.timebankId;
      requestModel.softDelete = false;
      requestModel.creatorName = SevaCore.of(context).loggedInUser.fullname;
      requestModel.minimumCredits = 0;
      requestModel.communityName = communityModel.name;
      if (selectedInstructorModel != null &&
          requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        //speaker put in acceptors array, later when accepts through notification put into approved users
        List<String> acceptorsList = [];
        acceptorsList.add(selectedInstructorModel.email);
        requestModel.acceptors = acceptorsList;

        requestModel.requestCreatorName =
            SevaCore.of(context).loggedInUser.fullname;

        log('ADDED ACCEPTOR');
      }

      linearProgressForCreatingRequest(context, S.of(context).creating_request);

      await requestUtils.createProjectOneToManyRequest(
          context: context,
          requestModel: requestModel,
          projectModel: widget.projectModel,
          createEvent: createEvent);

      if (selectedInstructorModel != null &&
          //selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
          requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        if (selectedInstructorModel.sevaUserID == requestModel.sevaUserId) {
          requestModel.approvedUsers = [];
          List<String> approvedUsers = [];
          approvedUsers.add(requestModel.email);
          requestModel.approvedUsers = approvedUsers;
          log('speaker is creator');
        } else if (selectedInstructorModel.communities
                .contains(requestModel.communityId) &&
            selectedInstructorModel.sevaUserID != requestModel.sevaUserId) {
          speakerNotificationDocRef =
              await sendNotificationToMemberOneToManyRequest(
                  communityId: requestModel.communityId,
                  timebankId: requestModel.timebankId,
                  sevaUserId: selectedInstructorModel.sevaUserID,
                  userEmail: selectedInstructorModel.email,
                  context: context,
                  requestModel: requestModel,
                  formType: widget.formType);
        } else {
          // send sevax global notification for user who is not part of the community for this request
          speakerNotificationDocRef =
              await sendNotificationToMemberOneToManyRequest(
                  communityId: FlavorConfig.values.timebankId,
                  timebankId: FlavorConfig.values.timebankId,
                  sevaUserId: selectedInstructorModel.sevaUserID,
                  userEmail: selectedInstructorModel.email,
                  context: context,
                  requestModel: requestModel,
                  formType: widget.formType);

          //Sending only if instructor is not part of the community of the request
          await sendMailToInstructor(
              senderEmail: 'noreply@sevaexchange.com', //requestModel.email,
              receiverEmail: selectedInstructorModel.email,
              communityName: timebankModel.name,
              requestName: requestModel.title,
              requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
              receiverName: selectedInstructorModel.fullname,
              startDate: requestModel.requestStart,
              endDate: requestModel.requestEnd);
        }
      }

      eventsIdsArr = await writeToDB(
        context: context,
        offer: widget.offer,
        requestModel: requestModel,
        timebankModel: timebankModel,
      );
      await _updateProjectModel();

      //below is to add speaker to inivted members when request is created
      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        await updateInvitedSpeakerForRequest(
            requestModel.id,
            selectedInstructorModel.sevaUserID, //sevauserid null
            selectedInstructorModel.email,
            speakerNotificationDocRef);
      }
      // Navigator.of(context, rootNavigator: true).pop();
      if (dialogContext != null) Navigator.pop(dialogContext);

      KloudlessWidgetManager<CreateMode, RequestModel>().syncCalendar(
        context: context,
        builder: KloudlessWidgetBuilder().fromContext<CreateMode, RequestModel>(
          context: context,
          model: requestModel,
          id: requestModel.id,
        ),
      );
      Navigator.of(context).pop();

      // logger.d("PROJET ID ${requestModel?.projectId}");

    }
  }

  void continueCreateRequest({BuildContext confirmationDialogContext}) async {
    linearProgressForCreatingRequest(context, S.of(context).creating_request);

    List<String> resVar = await writeToDB(
        context: context,
        timebankModel: timebankModel,
        requestModel: requestModel,
        offer: widget.offer);
    eventsIdsArr = resVar;
    await _updateProjectModel();
    // Navigator.of(context, rootNavigator: true).pop();
    if (dialogContext != null) Navigator.pop(dialogContext);

    if (confirmationDialogContext != null) {
      Navigator.pop(confirmationDialogContext);
    }
    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty && !requestModel.isRecurring) {
      ProjectModel projectModel = widget.projectModel;
      projectModel.pendingRequests.add(requestModel.id);
      await FirestoreManager.updateProject(projectModel: projectModel);
    }
  }

  //=====================================================

  void editRequest() async {
    logger.e('Project ID:  ' + tempProjectId.toString());
    // verify f the start and end date time is not same

    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    if (_formKey.currentState.validate()) {
      if (requestModel.public) {
        requestModel.timebanksPosted = [
          requestModel.timebankId,
          FlavorConfig.values.timebankId
        ];
      } else {
        requestModel.timebanksPosted = [requestModel.timebankId];
      }

      if (requestModel.requestType == RequestType.GOODS &&
          (requestModel.goodsDonationDetails.requiredGoods == null ||
              requestModel.goodsDonationDetails.requiredGoods.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).goods_validation, context: context);
        return;
      }
      if (requestModel.requestType == RequestType.BORROW &&
          requestModel.roomOrTool ==
              LendingType.ITEM
                  .readable && //because was throwing dialog when creating for place
          (requestModel.borrowModel.requiredItems == null ||
              requestModel.borrowModel.requiredItems.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).items_validation);
        return;
      }
      if (requestModel.isRecurring == true ||
          requestModel.autoGenerated == true) {
        //TODO handle error here for editing reccuring request
        // EditRepeatWidgetState.recurringDays = EditRepeatWidgetState.getRecurringdays();
      }

      if (requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
        var onBalanceCheckResult;
        if (requestModel.isRecurring == true ||
            requestModel.autoGenerated == true) {
          int recurrences = requestModel.end.endType == "after"
              ? (requestModel.end.after - requestModel.occurenceCount).abs()
              : calculateRecurrencesOnMode(requestModel);
          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            credits: requestModel.isRecurring
                ? requestModel.numberOfHours.toDouble() * recurrences
                : requestModel.numberOfHours.toDouble(),
            communityId: requestModel.communityId,
          );
        } else {
          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            credits: requestModel.isRecurring
                ? requestModel.numberOfHours.toDouble() * 0
                : requestModel.numberOfHours.toDouble(),
            communityId: requestModel.communityId,
          );
        }

        if (!onBalanceCheckResult.hasSuffiientCredits) {
          requestUtils.showInsufficientBalance(
              onBalanceCheckResult.credits, context);
          return;
        }
      }

      logger.i("=============||||||===============");

      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp == 0 ||
          OfferDurationWidgetState.endtimestamp == 0) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_no_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp >
          OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater);
        return;
      }

      // if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      //   List<String> approvedUsers = [];
      //   approvedUsers.add(widget.requestModel.selectedInstructor.email);
      //   widget.requestModel.approvedUsers = approvedUsers;
      // }

      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          (selectedInstructorModel == {} ||
              selectedInstructorModel == null ||
              instructorAdded == false)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).select_a_speaker);
        return;
      }

      //Calculate session duration of one to many request using request start and request end time
      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        if (OfferDurationWidgetState.starttimestamp != null &&
            OfferDurationWidgetState.endtimestamp != null) {
          DateTime startDateNew = DateTime.fromMillisecondsSinceEpoch(
              OfferDurationWidgetState.starttimestamp);
          DateTime endDateNew = DateTime.fromMillisecondsSinceEpoch(
              OfferDurationWidgetState.endtimestamp);

          Duration sessionDuration = endDateNew.difference(startDateNew);
          double sixty = 60;

          logger.e('----------> Speaking Minutes: ' +
              sessionDuration.inMinutes.toString());

          selectedSpeakerTimeDetails.speakingTime = double.parse(
              (sessionDuration.inMinutes / sixty).toStringAsPrecision(3));

          //prep time will be entered by speaker when he/she is completing the request
          // selectedSpeakerTimeDetails.prepTime = 0;

          requestModel.selectedSpeakerTimeDetails = selectedSpeakerTimeDetails;

          setState(() {});
        }
      }

      //comparing the recurring days List

      //TODO should there be comparison since repeat is not editable
      /*Function eq = const ListEquality().equals;
      bool recurrinDaysListsMatch =
          eq(requestModel.recurringDays, EditRepeatWidgetState.recurringDays);
      log('Days Match:  ' + recurrinDaysListsMatch.toString());
      String tempSelectedEndType =
          EditRepeatWidgetState.endType == 0 ? S.of(context).on : S.of(context).after;
*/
      if (requestModel.isRecurring == true ||
          requestModel.autoGenerated == true) {
        /*   if (widget.requestModel.title != initialRequestTitle ||
            startDate.millisecondsSinceEpoch != OfferDurationWidgetState.starttimestamp ||
            endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp ||
            widget.requestModel.description != initialRequestDescription ||
            tempCredits != widget.requestModel.maxCredits ||
            tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
            location != widget.requestModel.location ||
            widget.requestModel.projectId != tempProjectId ||
            !widget.requestModel.acceptors.contains(selectedInstructorModel?.email)) {*/
        //setState(() {
        /*   widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.location = location;
          widget.requestModel.projectId = tempProjectId;
          widget.requestModel.address = selectedAddress;
          widget.requestModel.categories = selectedCategoryIds.toList();

          widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
          widget.requestModel.maxCredits = tempCredits;*/
        //});

        startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetState.starttimestamp
            ? requestModel.requestStart =
                OfferDurationWidgetState.starttimestamp
            : null;

        endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp
            ? requestModel.requestEnd = OfferDurationWidgetState.endtimestamp
            : null;

        if (selectedInstructorModel != null &&
            selectedInstructorModel.sevaUserID !=
                widget.requestModel.sevaUserId &&
            !widget.requestModel.acceptors
                .contains(selectedInstructorModel.email) &&
            widget.requestModel.requestType ==
                RequestType.ONE_TO_MANY_REQUEST) {
          //below is to update the invited speaker to inivted members list when speaker is changed
          await reUpdateInvitedSpeakerForRequest(
            requestID: requestModel.id,
            sevaUserIdPrevious:
                widget.requestModel.selectedInstructor.sevaUserID,
            emailPrevious: widget.requestModel.selectedInstructor.email,
            sevaUserIdNew: selectedInstructorModel.sevaUserID,
            emailNew: selectedInstructorModel.email,
          );

          List<String> acceptorsList = [];
          Set<String> invitedUsersList =
              Set.from(widget.requestModel.invitedUsers);
          //remove old speaker from invitedUsers and add new speaker to invited users
          invitedUsersList
              .remove(widget.requestModel.selectedInstructor.sevaUserID);
          invitedUsersList.add(selectedInstructorModel.sevaUserID);
          //assign updated list to request model invited users
          requestModel.invitedUsers = invitedUsersList.toList();

          acceptorsList.add(selectedInstructorModel.email);
          requestModel.acceptors = acceptorsList;
          requestModel.requestCreatorName =
              SevaCore.of(context).loggedInUser.fullname;
          log('ADDED ACCEPTOR');

          if (selectedInstructorModel.communities
              .contains(requestModel.communityId)) {
            speakerNotificationDocRef =
                await sendNotificationToMemberOneToManyRequest(
                    context: context,
                    requestModel: requestModel,
                    communityId: requestModel.communityId,
                    timebankId: requestModel.timebankId,
                    sevaUserId: selectedInstructorModel.sevaUserID,
                    userEmail: selectedInstructorModel.email,
                    speakerNotificationDocRefOld:
                        widget.requestModel.speakerInviteNotificationDocRef,
                    formType: widget.formType);
          } else {
            speakerNotificationDocRef =
                await sendNotificationToMemberOneToManyRequest(
                    context: context,
                    requestModel: requestModel,
                    communityId: FlavorConfig.values.timebankId,
                    timebankId: FlavorConfig.values.timebankId,
                    sevaUserId: selectedInstructorModel.sevaUserID,
                    userEmail: selectedInstructorModel.email,
                    speakerNotificationDocRefOld:
                        widget.requestModel.speakerInviteNotificationDocRef,
                    formType: widget.formType);
            // send sevax global notification for user who is not part of the community for this request
            await sendMailToInstructor(
                senderEmail: 'noreply@sevaexchange.com',
                //requestModel.email,
                receiverEmail: selectedInstructorModel.email,
                communityName: requestModel.fullName,
                requestName: requestModel.title,
                requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
                receiverName: selectedInstructorModel.fullname,
                startDate: requestModel.requestStart,
                endDate: requestModel.requestEnd);
          }
        }

        // requestModel.isRecurring = EditRepeatWidgetState.isRecurring;
        // requestModel.end.after = int.parse(EditRepeatWidgetState.after);
        // requestModel.end.endType = tempSelectedEndType;
        // requestModel.recurringDays = EditRepeatWidgetState.recurringDays;
        // requestModel.end.on = EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch;

        return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext viewContext) {
            return WillPopScope(
              onWillPop: () {},
              child: AlertDialog(
                title: Text("${S.of(context).this_is_a_repeating_request}."),
                actions: [
                  CustomTextButton(
                    child: Text(
                      "${S.of(context).edit_this_request_only}.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                      linearProgressForCreatingRequest(
                          context, S.of(context).updating_request);
                      await updateRequest(requestModel: requestModel);
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                  ),
                  CustomTextButton(
                    child: Text(
                      "${S.of(context).edit_subsequent_requests}.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                      linearProgressForCreatingRequest(
                          context, S.of(context).updating_request);
                      await updateRequest(requestModel: requestModel);
                      await updateRecurrenceRequestsFrontEnd(
                        updatedRequestModel: requestModel,
                        communityId:
                            SevaCore.of(context).loggedInUser.currentCommunity,
                        timebankId:
                            SevaCore.of(context).loggedInUser.currentTimebank,
                      );
                      logger.i("OUTSIDE BEFORE POP");

                      Navigator.pop(dialogContext);
                      logger.i("OUTSIDE AFTER POP");

                      Navigator.pop(context);
                    },
                  ),
                  CustomTextButton(
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
        // }

        logger.i("=============////////===============");

        /*  if (tempSelectedEndType != widget.requestModel.end.endType ||
            widget.requestModel.end.after != int.parse(EditRepeatWidgetState.after) ||
            widget.requestModel.end.on !=
                EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch ||
            recurrinDaysListsMatch == false) {
          //setState(() {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.isRecurring = EditRepeatWidgetState.isRecurring;
          widget.requestModel.end.after = int.parse(EditRepeatWidgetState.after);
          widget.requestModel.end.endType = tempSelectedEndType;
          widget.requestModel.recurringDays = EditRepeatWidgetState.recurringDays;
          widget.requestModel.end.on = EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch;
          //});

          logger.i("=============IF===============");

          linearProgressForCreatingRequest(context);
          await updateRequest(requestModel: widget.requestModel);
          await updateRecurrenceRequestsFrontEnd(
            updatedRequestModel: widget.requestModel,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          );

          Navigator.pop(dialogContext);
          Navigator.pop(context);
        } else {
          Navigator.of(context).pop();
        }*/
      } else if (requestModel.isRecurring == false &&
          requestModel.autoGenerated == false) {
        // if (widget.requestModel.title != initialRequestTitle ||
        //     startDate.millisecondsSinceEpoch !=
        //         OfferDurationWidgetState.starttimestamp ||
        //     endDate.millisecondsSinceEpoch !=
        //         OfferDurationWidgetState.endtimestamp ||
        //     widget.requestModel.description != initialRequestDescription ||
        //     tempCredits != widget.requestModel.maxCredits ||
        //     tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
        //     location != widget.requestModel.location) {
        log('HERE 1');

        if (selectedInstructorModel != null &&
            selectedInstructorModel.sevaUserID !=
                widget.requestModel.sevaUserId &&
            !widget.requestModel.acceptors
                .contains(selectedInstructorModel.email) &&
            widget.requestModel.requestType ==
                RequestType.ONE_TO_MANY_REQUEST) {
          //below is to update the invited speaker to inivted members list when speaker is changed
          await reUpdateInvitedSpeakerForRequest(
            requestID: requestModel.id,
            sevaUserIdPrevious:
                widget.requestModel.selectedInstructor.sevaUserID,
            emailPrevious: widget.requestModel.selectedInstructor.email,
            sevaUserIdNew: selectedInstructorModel.sevaUserID,
            emailNew: selectedInstructorModel.email,
          );

          List<String> acceptorsList = [];
          Set<String> invitedUsersList =
              Set.from(widget.requestModel.invitedUsers);
          //remove old speaker from invitedUsers and add new speaker to invited users
          invitedUsersList
              .remove(widget.requestModel.selectedInstructor.sevaUserID);
          invitedUsersList.add(selectedInstructorModel.sevaUserID);
          //assign updated list to request model invited users
          requestModel.invitedUsers = invitedUsersList.toList();

          acceptorsList.add(selectedInstructorModel.email);
          requestModel.acceptors = acceptorsList;
          requestModel.requestCreatorName =
              SevaCore.of(context).loggedInUser.fullname;
          log('ADDED ACCEPTOR');

          if (selectedInstructorModel.communities
              .contains(widget.requestModel.communityId)) {
            speakerNotificationDocRef =
                await sendNotificationToMemberOneToManyRequest(
                    context: context,
                    formType: widget.formType,
                    requestModel: requestModel,
                    communityId: requestModel.communityId,
                    timebankId: requestModel.timebankId,
                    sevaUserId: selectedInstructorModel.sevaUserID,
                    userEmail: selectedInstructorModel.email,
                    speakerNotificationDocRefOld:
                        widget.requestModel.speakerInviteNotificationDocRef);
          } else {
            // send sevax global notification for user who is not part of the community for this request
            speakerNotificationDocRef =
                await sendNotificationToMemberOneToManyRequest(
                    context: context,
                    formType: widget.formType,
                    requestModel: requestModel,
                    communityId: FlavorConfig.values.timebankId,
                    timebankId: FlavorConfig.values.timebankId,
                    sevaUserId: selectedInstructorModel.sevaUserID,
                    userEmail: selectedInstructorModel.email,
                    speakerNotificationDocRefOld:
                        widget.requestModel.speakerInviteNotificationDocRef);
            await sendMailToInstructor(
                senderEmail: 'noreply@sevaexchange.com',
                receiverEmail: selectedInstructorModel.email,
                communityName: requestModel.fullName,
                requestName: requestModel.title,
                requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
                receiverName: selectedInstructorModel.fullname,
                startDate: requestModel.requestStart,
                endDate: requestModel.requestEnd);
          }
        }

        //update current speaker notification document reference
        requestModel.speakerInviteNotificationDocRef =
            speakerNotificationDocRef;

        startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetState.starttimestamp
            ? requestModel.requestStart =
                OfferDurationWidgetState.starttimestamp
            : null;
        endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp
            ? requestModel.requestEnd = OfferDurationWidgetState.endtimestamp
            : null;

        linearProgressForCreatingRequest(
            context, S.of(context).updating_request);
        await updateRequest(requestModel: requestModel);

        Navigator.pop(dialogContext);
        Navigator.pop(context);
      } else {
        Navigator.of(context).pop();
      }
      //}
    }
  }

  int calculateRecurrencesOnMode(RequestModel requestModel) {
    DateTime eventStartDate =
        DateTime.fromMillisecondsSinceEpoch(requestModel.requestStart);
    int recurrenceCount = 0;
    bool lastRound = false;
    while (lastRound == false) {
      eventStartDate = DateTime(
          eventStartDate.year,
          eventStartDate.month,
          eventStartDate.day + 1,
          eventStartDate.hour,
          eventStartDate.minute,
          eventStartDate.second);
      if (eventStartDate.millisecondsSinceEpoch <= requestModel.end.on &&
          recurrenceCount < 11) {
        if (requestModel.recurringDays.contains(eventStartDate.weekday % 7)) {
          recurrenceCount++;
        }
      } else {
        lastRound = true;
      }
    }
    log("on mode recurrence count isss $recurrenceCount");
    return recurrenceCount;
  }
}
