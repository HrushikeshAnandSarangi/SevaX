import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/enums/plan_ids.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/selectedSpeakerTimeDetails.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/exchange/borrow_request.dart';
import 'package:sevaexchange/views/exchange/cash_request.dart';
import 'package:sevaexchange/views/exchange/create_request/project_selection.dart';
import 'package:sevaexchange/views/exchange/goods_request.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/views/exchange/time_request.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/select_category.dart';

import '../../core.dart';

class RequestCreateForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  final ProjectModel projectModel;
  final String projectId;
  final ComingFrom comingFrom;

  RequestCreateForm({
    this.isOfferRequest = false,
    @required this.comingFrom,
    this.offer,
    this.timebankId,
    this.userModel,
    @required this.loggedInUser,
    this.projectId,
    this.projectModel,
  });

  @override
  RequestCreateFormState createState() {
    return RequestCreateFormState();
  }
}

class RequestCreateFormState extends State<RequestCreateForm> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();
  ProjectModel selectedProjectModel = null;
  RequestModel requestModel;
  End end = End();
  var focusNodes = List.generate(18, (_) => FocusNode());
  List<String> eventsIdsArr = [];
  List<String> selectedCategoryIds = [];
  bool comingFromDynamicLink = false;
  GeoFirePoint location;
  String hoursMessage;
  String selectedAddress;
  int sharedValue = 0;
  final _debouncer = Debouncer(milliseconds: 500);
  String _selectedTimebankId;
  var validItems = [];
  bool isAdmin = false;
  UserModel selectedInstructorModel;
  SelectedSpeakerTimeDetails selectedSpeakerTimeDetails =
      new SelectedSpeakerTimeDetails(speakingTime: 0.0, prepTime: 0);
  DocumentReference speakerNotificationDocRef;
  RequestUtils requestUtils = RequestUtils();

  //Below variable for One to Many Requests
  bool createEvent = false;
  bool instructorAdded = false;
  int roomOrTool = 0;

  Future<TimebankModel> getTimebankAdminStatus;
  Future<List<ProjectModel>> getProjectsByFuture;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();
  CommunityModel communityModel;

  @override
  void initState() {
    super.initState();
    AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;
    WidgetsBinding.instance.addObserver(this);
    _selectedTimebankId = widget.timebankId;
    getProjectsByFuture = FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);
    _initializeRequestModel();
    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );
    fetchRemoteConfig();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedInstructorModel = SevaCore.of(context).loggedInUser;

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

  _initializeRequestModel() {
    requestModel = RequestModel(
        requestType: RequestType.TIME,
        cashModel: CashModel(paymentType: RequestPaymentType.ZELLEPAY, achdetails: new ACHModel()),
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

    if (widget.isOfferRequest ?? false) {
      requestModel.requestType = widget.offer.type;
      requestModel.goodsDonationDetails.requiredGoods =
          widget.offer.goodsDonationDetails.requiredGoods;
    }
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
    if (widget.loggedInUser?.sevaUserID != null)
      FirestoreManager.getUserForIdStream(sevaUserId: widget.loggedInUser.sevaUserID)
          .listen((userModel) {});
    super.didChangeDependencies();
  }

  Widget headerContainer(snapshot) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    timebankModel = snapshot.data;
    if (isAccessAvailable(snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID)) {
      return requestSwitch(
        timebankModel: timebankModel,
      );
    } else {
      this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.e('CREATE EVENT STATUS: ' + createEvent.toString());
    hoursMessage = S.of(context).set_duration;
    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    this.requestModel.email = loggedInUser.email;
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;
    this.requestModel.communityId = loggedInUser.currentCommunity;
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
                  selectedAddress = snapshot.data.address;
                  location = snapshot.data.location;
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
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        isOfferRequest: widget.isOfferRequest,
                                        selectedAddress: selectedAddress,
                                        location: location,
                                        isAdmin: isAdmin,
                                        createEvent: createEvent,
                                        instructorAdded: instructorAdded,
                                        timebankModel: snapshot.data,
                                        projectModelList: projectModelList,
                                        projectId: widget.projectId,
                                        selectedInstructorModel: selectedInstructorModel,
                                        categoryWidget: categoryWidget(),
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        onCreateEventChanged: (value) => createEvent = value,
                                        onDescriptionChanged: (value) =>
                                            getCategoriesFromApi(value),
                                      );
                                      break;
                                    case RequestType.CASH:
                                      return CashRequest(
                                        isOfferRequest: widget.isOfferRequest,
                                        offer: widget.offer,
                                        requestDescription: RequestDescriptionData(
                                            S.of(context).cash_request_data_hint_text),
                                        projectModelList: projectModelList,
                                        requestModel: requestModel,
                                        comingFrom: widget.comingFrom,
                                        timebankId: widget.timebankId,
                                        timebankModel: snapshot.data,
                                        categoryWidget: categoryWidget(),
                                        createEvent: createEvent,
                                        onCreateEventChanged: (value) => createEvent = value,
                                        projectId: widget.projectId,
                                        instructorAdded: instructorAdded,
                                      );
                                      break;
                                    case RequestType.GOODS:
                                      return GoodsRequest(
                                        requestModel: requestModel,
                                        categoryWidget: categoryWidget(),
                                        timebankModel: snapshot.data,
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        isOfferRequest: widget.isOfferRequest,
                                        offer: widget.offer,
                                        instructorAdded: instructorAdded,
                                        projectId: widget.projectId,
                                        createEvent: createEvent,
                                        onCreateEventChanged: (value) => createEvent = value,
                                        projectModelList: projectModelList,
                                        requestDescription: RequestDescriptionData(
                                            S.of(context).goods_request_data_hint_text),
                                      );
                                      break;
                                    case RequestType.BORROW:
                                      return BorrowRequest(
                                        requestDescription: RequestDescriptionData(
                                            S.of(context).request_descrip_hint_text),
                                        selectedAddress: selectedAddress,
                                        location: location,
                                        categoryWidget: categoryWidget(),
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        createEvent: createEvent,
                                        projectId: widget.projectId,
                                        instructorAdded: instructorAdded,
                                        onCreateEventChanged: (value) => createEvent = value,
                                        projectModelList: projectModelList,
                                        timebankModel: snapshot.data,
                                        comingFrom: widget.comingFrom,
                                        timebankId: widget.timebankId,
                                        isOfferRequest: widget.isOfferRequest,
                                      );
                                      break;
                                    case RequestType.ONE_TO_MANY_REQUEST:
                                      return TimeRequest(
                                        requestModel: requestModel,
                                        offer: widget.offer,
                                        isOfferRequest: widget.isOfferRequest,
                                        selectedAddress: selectedAddress,
                                        location: location,
                                        isAdmin: isAdmin,
                                        createEvent: createEvent,
                                        instructorAdded: instructorAdded,
                                        timebankModel: snapshot.data,
                                        projectId: widget.projectId,
                                        projectModelList: projectModelList,
                                        selectedInstructorModel: selectedInstructorModel,
                                        timebankId: widget.timebankId,
                                        comingFrom: widget.comingFrom,
                                        categoryWidget: categoryWidget(),
                                        onCreateEventChanged: (value) => createEvent = value,
                                        onDescriptionChanged: (value) =>
                                            getCategoriesFromApi(value),
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
                                padding: const EdgeInsets.symmetric(vertical: 30.0),
                                child: Center(
                                  child: Container(
                                    child: CustomElevatedButton(
                                      onPressed: createRequest,
                                      child: Text(
                                        S.of(context).create_request.padLeft(10).padRight(10),
                                        style: Theme.of(context).primaryTextTheme.button,
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

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      (requestModel.requestType == RequestType.BORROW && roomOrTool == 1)
          ? Text(
              S.of(context).request_description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            )
          : Text(
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
          if (value != null && value.length > 5) {
            _debouncer.run(() {
              getCategoriesFromApi(value);
            });
          }
          requestUtils.updateExitWithConfirmationValue(context, 9, value);
        },
        focusNode: focusNodes[0],
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(focusNodes[1]);
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: hintTextDesc,
          hintStyle: requestUtils.hintTextStyle,
        ),
        initialValue: widget.offer != null && widget.isOfferRequest
            ? getOfferDescription(
                offerDataModel: widget.offer,
              )
            : "",
        keyboardType: TextInputType.multiline,
        maxLines: 1,
        // ignore: missing_return
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_general_text;
          }
          if (profanityDetector.isProfaneString(value)) {
            return S.of(context).profanity_text_alert;
          }
          requestModel.description = value;
        },
      ),
    ]);
  }

  Widget RequestTypeWidgetCommunityRequests() {
    return requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
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
                  ConfigurationCheck(
                    actionType: 'create_time_request',
                    role: memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                    child: requestUtils.optionRadioButton<RequestType>(
                      title: S.of(context).request_type_time,
                      isEnabled: !widget.isOfferRequest,
                      value: RequestType.TIME,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                        instructorAdded = false;
                        requestModel.selectedInstructor = null;
                        requestModel.requestType = value;
                        AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;
                        setState(() => {});
                      },
                    ),
                  ),
                  TransactionsMatrixCheck(
                    comingFrom: widget.comingFrom,
                    upgradeDetails: AppConfig.upgradePlanBannerModel.goods_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    child: requestUtils.optionRadioButton<RequestType>(
                      title: S.of(context).request_type_goods,
                      isEnabled: !(widget.isOfferRequest ?? false),
                      value: RequestType.GOODS,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.isRecurring = false;
                        requestModel.requestType = value;
                        AppConfig.helpIconContextMember = HelpContextMemberType.goods_requests;

                        //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                        instructorAdded = false;
                        requestModel.selectedInstructor = null;
                        requestModel.requestType = value;
                        setState(() => {});
                      },
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails: AppConfig.upgradePlanBannerModel.cash_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_money_request',
                      role: memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
                      child: requestUtils.optionRadioButton<RequestType>(
                        title: S.of(context).request_type_cash,
                        value: RequestType.CASH,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          requestModel.isRecurring = false;
                          requestModel.requestType = value;
                          AppConfig.helpIconContextMember = HelpContextMemberType.money_requests;

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
                    upgradeDetails: AppConfig.upgradePlanBannerModel.onetomany_requests,
                    transaction_matrix_type: 'onetomany_requests',
                    comingFrom: widget.comingFrom,
                    child: requestUtils.optionRadioButton<RequestType>(
                      title: S.of(context).one_to_many,
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
                          fullname: SevaCore.of(context).loggedInUser.fullname,
                          email: SevaCore.of(context).loggedInUser.email,
                          photoURL: SevaCore.of(context).loggedInUser.photoURL,
                          sevaUserID: SevaCore.of(context).loggedInUser.sevaUserID,
                        );
                        AppConfig.helpIconContextMember =
                            HelpContextMemberType.one_to_many_requests;
                        setState(() => {});
                      },
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails: AppConfig.upgradePlanBannerModel.borrow_requests,
                    transaction_matrix_type: 'borrow_request',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_borrow_request',
                      role: memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
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
                          AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;
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
    return requestModel.requestMode == RequestMode.PERSONAL_REQUEST
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
                      AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;

                      //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                      instructorAdded = false;
                      requestModel.selectedInstructor = null;
                      requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails: AppConfig.upgradePlanBannerModel.cash_request,
                    transaction_matrix_type: 'borrow_request',
                    comingFrom: widget.comingFrom,
                    child: ConfigurationCheck(
                      actionType: 'create_borrow_request',
                      role: memberType(timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
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
                          AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;
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

// Choose Category and Sub Category function
  // get data from Category class
  List<CategoryModel> selectedCategoryModels = [];
  String categoryMode;

  void updateInformation(List<CategoryModel> category) {
    if (category != null && category.length > 0) {
      selectedCategoryModels.addAll(category);
    }
    setState(() {});
  }

  Future<void> getCategoriesFromApi(String query) async {
    try {
      var response = await http.post(
        "https://proxy.sevaexchange.com/" + "http://ai.api.sevaxapp.com/request_categories",
        headers: {
          "Content-Type": "application/json",
          "Access-Control": "Allow-Headers",
          "x-requested-with": "x-requested-by"
        },
        body: jsonEncode({
          "description": query,
        }),
      );
      log('respinse ${response.body}');
      log('respinse ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> bodyMap = json.decode(response.body);
        List<String> categoriesList =
            bodyMap.containsKey('string_vec') ? List.castFrom(bodyMap['string_vec']) : [];
        if (categoriesList != null && categoriesList.length > 0) {
          getCategoryModels(categoriesList);
        }
      } else {
        return null;
      }
    } catch (exception) {
      log(exception.toString());
      return null;
    }
  }

  Future<void> getCategoryModels(List<String> categoriesList) async {
    List<CategoryModel> modelList = [];
    for (int i = 0; i < categoriesList.length; i += 1) {
      CategoryModel categoryModel = await FirestoreManager.getCategoryForId(
        categoryID: categoriesList[i],
      );
      modelList.add(categoryModel);
    }
    if (modelList != null && modelList.length > 0) {
      categoryMode = S.of(context).suggested_categories;

      updateInformation(modelList);
    }
  }

  // Navigat to Category class and geting data from the class
  void moveToCategory() async {
    var category = await Navigator.push(
      context,
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => Category(
                selectedSubCategoriesids: selectedCategoryIds,
              )),
    );
    if (category != null) {
      categoryMode = category[0];
      updateInformation(category[1]);
    }
  }

  //building list of selectedSubCategories
  List<Widget> _buildselectedSubCategories() {
    List<CategoryModel> subCategories = [];
    subCategories = selectedCategoryModels;
    log('lll l ${subCategories.length}');
    subCategories.forEach((item) {});
    final ids = subCategories.map((e) => e.typeId).toSet();
    subCategories.retainWhere((x) => ids.remove(x.typeId));
    log('lll after ${subCategories.length}');

    List<Widget> selectedSubCategories = [];
    selectedCategoryIds.clear();
    subCategories.forEach((item) {
      selectedCategoryIds.add(item.typeId);
      selectedSubCategories.add(
        Padding(
          padding: const EdgeInsets.only(right: 7, bottom: 7),
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 3.5, bottom: 5, left: 9, right: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${item.getCategoryName(context).toString()}",
                      style: TextStyle(color: Colors.white)),
                  SizedBox(width: 3),
                  InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategoryIds.remove(item.typeId);
                        selectedSubCategories.remove(item.typeId);
                        subCategories.removeWhere((category) => category.typeId == item.typeId);
                      });
                    },
                    child: Icon(Icons.cancel_rounded, color: Colors.grey[100], size: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
    return selectedSubCategories;
  }

  Widget categoryWidget() {
    return InkWell(
      child: Column(
        children: [
          Row(
            children: [
              categoryMode == null
                  ? Text(
                      S.of(context).choose_category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "${categoryMode}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
              ),
            ],
          ),
          SizedBox(height: 20),
          selectedCategoryModels != null && selectedCategoryModels.length > 0
              ? Wrap(
                  alignment: WrapAlignment.start,
                  children: _buildselectedSubCategories(),
                )
              : Container(),
        ],
      ),
      onTap: () => moveToCategory(),
    );
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
  }

  Widget requestSwitch({
    TimebankModel timebankModel,
  }) {
    if (widget.projectId == null || widget.projectId.isEmpty || widget.projectId == "") {
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

                  // requestModel.requestType = RequestType.TIME;
                  //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
                  setState(() {
                    instructorAdded = false;
                    requestModel.selectedInstructor = null;
                  });
                  //requestModel.requestType = RequestType.TIME;

                }
                sharedValue = val;
              });
            }
          },
          //groupValue: sharedValue,
        ),
      );
    } else {
      if (widget.projectModel != null) {
        if (widget.projectModel.mode == ProjectMode.TIMEBANK_PROJECT) {
          requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
          // requestModel.requestType = RequestType.TIME;
        }
      }
      return Container();
    }
  }

  BuildContext dialogContext;

  void createRequest() async {
    // verify f the start and end date time is not same
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    DateTime startDate =
        DateTime.fromMillisecondsSinceEpoch(OfferDurationWidgetState.starttimestamp);
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(OfferDurationWidgetState.endtimestamp);

    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel.autoGenerated = false;

    if (requestModel.requestType == RequestType.TIME ||
        requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      requestModel.isRecurring = RepeatWidgetState.isRecurring;
    } else {
      requestModel.isRecurring = false;
    }

    if (requestModel.isRecurring) {
      requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
      requestModel.occurenceCount = 1;
      end.endType = RepeatWidgetState.endType == 0 ? S.of(context).on : S.of(context).after;
      end.on = end.endType == S.of(context).on
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after = (end.endType == S.of(context).after ? int.parse(RepeatWidgetState.after) : null);
      requestModel.end = end;
    }

    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      // validate request start and end date

      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_no_date, context: context);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp == OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_same_start_date_end_date, context: context);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp > OfferDurationWidgetState.endtimestamp) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater, context: context);
        return;
      }

      if (requestModel.requestType == RequestType.GOODS &&
          (requestModel.goodsDonationDetails.requiredGoods == null ||
              requestModel.goodsDonationDetails.requiredGoods.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: S.of(context).goods_validation, context: context);
        return;
      }
      if (requestModel.requestType == RequestType.BORROW &&
          roomOrTool == 1 //because was throwing dialog when creating for place
          &&
          (requestModel.borrowModel.requiredItems == null ||
              requestModel.borrowModel.requiredItems.isEmpty)) {
        requestUtils.showDialogForTitle(
            dialogTitle: L.of(context).items_validation, context: context);
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
              dialogTitle: S.of(context).validation_error_empty_recurring_days, context: context);
          return;
        }
      }

//Assigning room or tool for Borrrow Requests
      if (roomOrTool != null && requestModel.requestType == RequestType.BORROW) {
        if (roomOrTool == 1) {
          //CHANGE to use enums
          requestModel.roomOrTool = 'ITEM';
        } else {
          requestModel.roomOrTool = 'PLACE';
        }
      }
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
            dialogTitle: S.of(context).select_a_speaker_dialog, context: context);
        return;
      }

      //Calculate session duration of one to many request using request start and request end time
      if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        if (startDate != null && endDate != null) {
          Duration sessionDuration = endDate.difference(startDate);
          double sixty = 60;

          selectedSpeakerTimeDetails.speakingTime =
              double.parse((sessionDuration.inMinutes / sixty).toStringAsPrecision(3));

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
          var onBalanceCheckResult = await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            credits: requestModel.numberOfHours.toDouble(),
            userId: myDetails.sevaUserID,
            communityId: timebankModel.communityId,
          );
          if (!onBalanceCheckResult.hasSuffiientCredits) {
            requestUtils.showInsufficientBalance(onBalanceCheckResult.credits, context);
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
        requestModel.timebanksPosted = [timebankModel.id, FlavorConfig.values.timebankId];
      } else {
        requestModel.timebanksPosted = [timebankModel.id];
      }

      requestModel.communityId = SevaCore.of(context).loggedInUser.currentCommunity;
      requestModel.softDelete = false;
      requestModel.postTimestamp = timestamp;
      requestModel.accepted = false;
      requestModel.acceptors = [];
      requestModel.invitedUsers = [];
      requestModel.recommendedMemberIdsForRequest = [];
      requestModel.categories = selectedCategoryIds;
      requestModel.address = selectedAddress;
      requestModel.location = location;
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

        requestModel.requestCreatorName = SevaCore.of(context).loggedInUser.fullname;

        log('ADDED ACCEPTOR');
      }

      if (SevaCore.of(context).loggedInUser.calendarId != null) {
        // calendar  integrated!
        if (communityModel.payment['planId'] != PlanIds.neighbourhood_plan.name) {
          List<String> acceptorList = widget.isOfferRequest
              ? widget.offer.creatorAllowedCalender == null ||
                      widget.offer.creatorAllowedCalender == false
                  ? [requestModel.email]
                  : [widget.offer.email, requestModel.email]
              : [requestModel.email];
          requestModel.allowedCalenderUsers = acceptorList.toList();
        } else {
          requestModel.allowedCalenderUsers = [];
        }

        await requestUtils.createProjectOneToManyRequest(
          context: context,
          requestModel: requestModel,
          projectModel: widget.projectModel,
          createEvent: createEvent,
        );

        if (selectedInstructorModel != null &&
            //selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
            requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
          if (selectedInstructorModel.sevaUserID == requestModel.sevaUserId) {
            requestModel.approvedUsers = [];
            List<String> approvedUsers = [];
            approvedUsers.add(requestModel.email);
            requestModel.approvedUsers = approvedUsers;
            log('speaker is creator');
          } else if (selectedInstructorModel.communities.contains(requestModel.communityId) &&
              selectedInstructorModel.sevaUserID != requestModel.sevaUserId) {
            speakerNotificationDocRef = await sendNotificationToMemberOneToManyRequest(
                communityId: requestModel.communityId,
                timebankId: requestModel.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email,
                context: context,
                requestModel: requestModel);
          } else {
            // send sevax global notification for user who is not part of the community for this request
            speakerNotificationDocRef = await sendNotificationToMemberOneToManyRequest(
                communityId: FlavorConfig.values.timebankId,
                timebankId: FlavorConfig.values.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email,
                context: context,
                requestModel: requestModel);

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

        await continueCreateRequest(confirmationDialogContext: null);

        //below is to add speaker to inivited members when request is created
        if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
          await updateInvitedSpeakerForRequest(
              requestModel.id,
              selectedInstructorModel.sevaUserID, //sevauserid null
              selectedInstructorModel.email,
              speakerNotificationDocRef);
        }
      } else {
        requestUtils.linearProgressForCreatingRequest(context);

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
          } else if (selectedInstructorModel.communities.contains(requestModel.communityId) &&
              selectedInstructorModel.sevaUserID != requestModel.sevaUserId) {
            speakerNotificationDocRef = await sendNotificationToMemberOneToManyRequest(
                communityId: requestModel.communityId,
                timebankId: requestModel.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email,
                context: context,
                requestModel: requestModel);
          } else {
            // send sevax global notification for user who is not part of the community for this request
            speakerNotificationDocRef = await sendNotificationToMemberOneToManyRequest(
                communityId: FlavorConfig.values.timebankId,
                timebankId: FlavorConfig.values.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email,
                context: context,
                requestModel: requestModel);

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
        Navigator.of(context, rootNavigator: true).pop();

        // Navigator.pop(dialogContext);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddToCalendar(
                  isOfferRequest: widget.isOfferRequest,
                  offer: widget.offer,
                  requestModel: requestModel,
                  userModel: widget.userModel,
                  eventsIdsArr: eventsIdsArr);
            },
          ),
        );
        // await _settingModalBottomSheet(context);
      }
    }
  }

  void continueCreateRequest({BuildContext confirmationDialogContext}) async {
    requestUtils.linearProgressForCreatingRequest(context);

    List<String> resVar = await writeToDB(
        context: context,
        timebankModel: timebankModel,
        requestModel: requestModel,
        offer: widget.offer);
    eventsIdsArr = resVar;
    await _updateProjectModel();
    Navigator.pop(dialogContext);

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
}
