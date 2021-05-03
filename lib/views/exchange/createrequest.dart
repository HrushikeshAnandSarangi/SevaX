import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_createRequest.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/new_baseline/models/user_exit_model.dart';
import 'package:sevaexchange/new_baseline/models/user_insufficient_credits_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/request/widgets/skills_for_requests_widget.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/onboarding/skills_view.dart';
import 'package:sevaexchange/views/requests/onetomany_request_instructor_card.dart';
import 'package:sevaexchange/views/requests/requestOfferAgreementForm.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
import 'package:sevaexchange/widgets/select_category.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/utils/utils.dart' as utils;

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  final String projectId;
  final ComingFrom comingFrom;

  CreateRequest({
    Key key,
    @required this.comingFrom,
    this.isOfferRequest,
    this.offer,
    this.timebankId,
    this.userModel,
    this.projectId,
    this.projectModel,
  }) : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
          actions: [
            CommonHelpIconWidget(),
          ],
        ),
        body: StreamBuilder<UserModelController>(
          stream: userBloc.getLoggedInUser,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Text(
                S.of(context).general_stream_error,
              );
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data != null) {
              return RequestCreateForm(
                comingFrom: widget.comingFrom,
                isOfferRequest:
                    widget.offer != null ? widget.isOfferRequest : false,
                offer: widget.offer,
                timebankId: widget.timebankId,
                userModel: widget.userModel,
                loggedInUser: snapshot.data.loggedinuser,
                projectId: widget.projectId,
                projectModel: widget.projectModel,
              );
            }
            return Text('');
          },
        ),
      ),
    );
  }

  String get _title {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
      return S.of(context).create_request;
    }
    return S.of(context).create_project_request;
  }
}

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

class RequestCreateFormState extends State<RequestCreateForm>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();
  ProjectModel selectedProjectModel = null;
  RequestModel requestModel;
  bool isPulicCheckboxVisible = false;
  End end = End();
  var focusNodes = List.generate(16, (_) => FocusNode());
  List<String> eventsIdsArr = [];
  List<String> selectedCategoryIds = [];
  bool comingFromDynamicLink = false;
  GeoFirePoint location;

  double sevaCoinsValue = 0;
  String hoursMessage;
  String selectedAddress;
  int sharedValue = 0;
  final _debouncer = Debouncer(milliseconds: 500);

  String _selectedTimebankId;

  final TextEditingController searchTextController = TextEditingController();
  final searchOnChange = BehaviorSubject<String>();
  final _textUpdates = StreamController<String>();
  var validItems = List<String>();
  bool isAdmin = false;
  UserModel selectedInstructorModel;

  //Below variable for One to Many Requests
  //bool createEvent = false;
  bool instructorAdded = false;

  //Borrow request fields below
  // String borrowAgreementLinkFinal = '';
  // String documentName = '';

  //Below variable for Borrow Requests
  int roomOrTool = 0;

  Future<TimebankModel> getTimebankAdminStatus;
  Future<List<ProjectModel>> getProjectsByFuture;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();

  RegExp regExp = RegExp(
    r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
    caseSensitive: false,
    multiLine: false,
  );

  CommunityModel communityModel;

  @override
  void initState() {
    super.initState();

    String _searchText = "";

    AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;

    WidgetsBinding.instance.addObserver(this);
    _selectedTimebankId = widget.timebankId;

    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    requestModel = RequestModel(
        requestType: RequestType.TIME,
        cashModel: CashModel(
            paymentType: RequestPaymentType.ZELLEPAY,
            achdetails: new ACHModel()),
        goodsDonationDetails: GoodsDonationDetails(),
        communityId: widget.loggedInUser.currentCommunity,
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

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );
    fetchRemoteConfig();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    searchTextController
        .addListener(() => _textUpdates.add(searchTextController.text));

    Observable(_textUpdates.stream)
        .debounceTime(Duration(milliseconds: 400))
        .forEach((s) {
      if (s.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        volunteerUsersBloc.fetchUsers(s);
        setState(() {
          _searchText = s;
        });
      }
    });

    // if ((FlavorConfig.appFlavor == Flavor.APP ||
    //     FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
    // _fetchCurrentlocation;
    // }
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
      FirestoreManager.getUserForIdStream(
              sevaUserId: widget.loggedInUser.sevaUserID)
          .listen((userModel) {});
    super.didChangeDependencies();
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );
  Widget addToProjectContainer(snapshot, projectModelList, requestModel) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    timebankModel = snapshot.data;
    if (isAccessAvailable(
            snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID) &&
        requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
      return ProjectSelection(
          requestModel: requestModel,
          projectModelList: projectModelList,
          selectedProject: null,
          admin: isAccessAvailable(
              snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID));
    } else {
      return Container();
      // this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      // this.requestModel.requestType = RequestType.TIME;
      // return ProjectSelection(
      //   requestModel: requestModel,
      //   projectModelList: projectModelList,
      //   selectedProject: null,
      //   admin: false,
      // );
    }
  }

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  Widget headerContainer(snapshot) {
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
      //this.requestModel.requestType = RequestType.TIME;
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                List<ProjectModel> projectModelList = projectListSnapshot.data;
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
//                            TransactionsMatrixCheck(transaction_matrix_type: "cash_goods_requests", child: RequestTypeWidget()),

                            RequestTypeWidgetCommunityRequests(),

                            RequestTypeWidgetPersonalRequests(),

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
                              // inputFormatters: <TextInputFormatter>[
                              //   WhitelistingTextInputFormatter(
                              //       RegExp("[a-zA-Z0-9_ ]*"))
                              // ],
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                hintText: requestModel.requestType ==
                                        RequestType.TIME
                                    ? S.of(context).request_title_hint
                                    : requestModel.requestType ==
                                            RequestType.CASH
                                        ? "Ex: Fundraiser for women’s shelter..."
                                        : requestModel.requestType ==
                                                RequestType.BORROW
                                            ? S.of(context).request_title_hint
                                            : "Ex: Non-perishable goods for Food Bank...",
                                hintStyle: hintTextStyle,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              initialValue:
                                  widget.offer != null && widget.isOfferRequest
                                      ? getOfferTitle(
                                          offerDataModel: widget.offer,
                                        )
                                      : "",
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).request_subject;
                                } else if (profanityDetector
                                    .isProfaneString(value)) {
                                  return S.of(context).profanity_text_alert;
                                } else if (value
                                        .substring(0, 1)
                                        .contains('_') &&
                                    !AppConfig.testingEmails
                                        .contains(AppConfig.loggedInEmail)) {
                                  return 'Creating request with "_" is not allowed';
                                } else {
                                  requestModel.title = value;
                                  return null;
                                }
                              },
                            ),

                            //Below is for testing purpose

                            // SizedBox(height: 20),
                            // requestModel.requestType == RequestType.BORROW
                            //     ? Row(
                            //         children: [
                            //           GestureDetector(
                            //             child: Text(
                            //               'Go to agreement page',
                            //               style: TextStyle(fontSize: 15),
                            //             ),
                            //             onTap: () {
                            //               Navigator.push(
                            //                 context,
                            //                 MaterialPageRoute(
                            //                     fullscreenDialog: true,
                            //                     builder: (context) =>
                            //                         RequestOfferAgreementForm(
                            //                           isRequest: true,
                            //                           roomOrTool:
                            //                               roomOrTool == 1
                            //                                   ? 'TOOL'
                            //                                   : 'ROOM',
                            //                           requestModel:
                            //                               requestModel,
                            //                           communityId: requestModel
                            //                               .communityId,
                            //                           timebankId:
                            //                               widget.timebankId,
                            //                           onPdfCreated: (pdfLink,
                            //                               documentNameFinal) {
                            //                             borrowAgreementLinkFinal =
                            //                                 pdfLink;
                            //                             documentName =
                            //                                 documentNameFinal;
                            //                             requestModel
                            //                                     .borrowAgreementLink =
                            //                                 pdfLink;
                            //                             // when request is created check if above value is stored in document
                            //                             setState(() => {});
                            //                           },
                            //                         )),
                            //               );
                            //             },
                            //           ),
                            //         ],
                            //       )
                            //     : Container(),
                            // SizedBox(height: 12),

                            // requestModel.requestType == RequestType.BORROW
                            //     ? GestureDetector(
                            //         child: Row(
                            //           children: [
                            //             Text(documentName != ''
                            //                 ? 'view '
                            //                 : ''), //Label to be created
                            //             Text(
                            //                 documentName != ''
                            //                     ? documentName
                            //                     : 'No Agreement Selected',
                            //                 style: TextStyle(
                            //                     fontWeight: FontWeight.w600,
                            //                     color: documentName != ''
                            //                         ? Theme.of(context)
                            //                             .primaryColor
                            //                         : Colors.grey)),
                            //           ],
                            //         ),
                            //         onTap: () async {
                            //           if (documentName != '') {
                            //             await openPdfViewer(
                            //                 borrowAgreementLinkFinal,
                            //                 'test document',
                            //                 context);
                            //           } else {
                            //             return null;
                            //           }
                            //         },
                            //       )
                            //     : Container(),



                            requestModel.requestType == RequestType.BORROW
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 12),
                                      Text(
                                        "Borrow", //Label to be created (client approval)
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Europa',
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      CupertinoSegmentedControl<int>(
                                        unselectedColor: Colors.grey[200],
                                        selectedColor:
                                            Theme.of(context).primaryColor,
                                        children: {
                                          0: Padding(
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                            child: Text(
                                              'Need a place', //Label to be created
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ),
                                          1: Padding(
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                            child: Text(
                                              'Goods', //Label to be created
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ),
                                        },
                                        borderColor: Colors.grey,
                                        padding: EdgeInsets.only(
                                            left: 0.0, right: 0.0),
                                        groupValue: roomOrTool,
                                        onValueChanged: (int val) {
                                          if (val != roomOrTool) {
                                            setState(() {
                                              if (val == 0) {
                                                roomOrTool = 0;
                                              } else {
                                                roomOrTool = 1;
                                              }
                                              roomOrTool = val;
                                            });
                                            log('Room or Tool: ' +
                                                roomOrTool.toString());
                                          }
                                        },
                                        //groupValue: sharedValue,
                                      ),
                                    ],
                                  )
                                : Container(),

                            SizedBox(height: 30),
                            OfferDurationWidget(
                              title: "${S.of(context).request_duration} *",
                            ),

                            requestModel.requestType == RequestType.TIME
                                ? TimeRequest(snapshot, projectModelList)
                                : requestModel.requestType == RequestType.CASH
                                    ? CashRequest(snapshot, projectModelList)
                                    : requestModel.requestType ==
                                            RequestType.BORROW
                                        ? BorrowRequest(
                                            snapshot, projectModelList)
                                        : GoodsRequest(
                                            snapshot, projectModelList),

                            HideWidget(
                              hide: AppConfig.isTestCommunity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: ConfigurationCheck(
                                  actionType: 'create_virtual_request',
                                  role: memberType(
                                      timebankModel,
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .sevaUserID),
                                  child: OpenScopeCheckBox(
                                      infoType: InfoType.VirtualRequest,
                                      isChecked: requestModel.virtualRequest,
                                      checkBoxTypeLabel:
                                          CheckBoxType.type_VirtualRequest,
                                      onChangedCB: (bool val) {
                                        if (requestModel.virtualRequest !=
                                            val) {
                                          this.requestModel.virtualRequest =
                                              val;

                                          if (!val) {
                                            requestModel.public = false;
                                            isPulicCheckboxVisible = false;
                                          } else {
                                            isPulicCheckboxVisible = true;
                                          }

                                          setState(() {});
                                        }
                                      }),
                                ),
                              ),
                            ),
                            HideWidget(
                              hide: !isPulicCheckboxVisible ||
                                  requestModel.requestMode ==
                                      RequestMode.PERSONAL_REQUEST ||
                                  widget.timebankId ==
                                      FlavorConfig.values.timebankId,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ConfigurationCheck(
                                  actionType: 'create_public_request',
                                  role: memberType(
                                      timebankModel,
                                      SevaCore.of(context)
                                          .loggedInUser
                                          .sevaUserID),
                                  child: OpenScopeCheckBox(
                                      infoType: InfoType.OpenScopeEvent,
                                      isChecked: requestModel.public,
                                      checkBoxTypeLabel:
                                          CheckBoxType.type_Requests,
                                      onChangedCB: (bool val) {
                                        if (requestModel.public != val) {
                                          this.requestModel.public = val;
                                          setState(() {});
                                        }
                                      }),
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30.0),
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
                );
              });
        });
  }

  void function(OfferModel offerModel) {
    switch (offerModel.type) {
      case RequestType.CASH:
        //radio button cash
        //prefrill offer title, offer description, pleged amount,

        // TODO: Handle this case.
        break;

      case RequestType.TIME:
        // TODO: Handle this case.
        break;
      case RequestType.GOODS:
        //radio button goods
        //prefrill offer title, offer description, pleged amount,

        // TODO: Handle this case.
        break;
    }
  }

  Widget RequestGoodsDescriptionData() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).request_goods_description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          GoodsDynamicSelection(
            selectedGoods: requestModel.goodsDonationDetails.requiredGoods,
            onSelectedGoods: (goods) =>
                {requestModel.goodsDonationDetails.requiredGoods = goods},
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_goods_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          Text(
            S.of(context).request_goods_address_hint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 2, value);
            },
            focusNode: focusNodes[8],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[8]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).request_goods_address_inputhint,
              hintStyle: hintTextStyle,
            ),
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                requestModel.goodsDonationDetails.address = value;
//                setState(() {});
              }
              return null;
            },
          ),
        ]);
  }

  Widget RequestPaymentACH(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_name,
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
              updateExitWithConfirmationValue(context, 3, value);
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[13]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.bank_name = value;
              } else {
                return S.of(context).enter_valid_bank_name;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_address,
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
              updateExitWithConfirmationValue(context, 4, value);
            },
            focusNode: focusNodes[13],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[14]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.bank_address = value;
              } else {
                return S.of(context).enter_valid_bank_address;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_routing_number,
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
              updateExitWithConfirmationValue(context, 5, value);
            },
            focusNode: focusNodes[14],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.routing_number = value;
              } else {
                return S.of(context).enter_valid_routing_number;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_account_no,
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
              updateExitWithConfirmationValue(context, 6, value);
            },
            focusNode: focusNodes[15],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.account_number = value;
              } else {
                return S.of(context).enter_valid_account_number;
              }
              return null;
            },
          )
        ]);
  }

  Widget RequestPaymentZellePay(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 7, value);
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText:
                  S.of(context).request_payment_descriptionZelle_inputhint,
              hintStyle: hintTextStyle,
            ),
            // initialValue: widget.offer != null && widget.isOfferRequest
            //     ? getOfferDescription(
            //         offerDataModel: widget.offer,
            //       )
            //     : "",
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              requestModel.cashModel.zelleId = value;
            },
            validator: (value) {
              requestModel.cashModel.zelleId = value;
              return _validateEmailAndPhone(value);
            },
          )
        ]);
  }

  String _validateEmailAndPhone(String value) {
    String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
  }

  String _validateEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return S.of(context).validation_error_general_text;
    if (!emailPattern.hasMatch(value))
      return S.of(context).validation_error_invalid_email;
    return null;
  }

  Widget RequestPaymentPaypal(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 8, value);
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).email_hint,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              requestModel.cashModel.paypalId = value;
            },
            validator: (value) {
              requestModel.cashModel.paypalId = value;
              return _validateEmailId(value);
            },
          )
        ]);
  }

  Widget RequestPaymentVenmo(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {},
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).venmo_hint,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                requestModel.cashModel.venmoId = value;
                return null;
              }
            },
          )
        ]);
  }

  Widget RequestPaymentDescriptionData(RequestModel requestModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).request_payment_description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        Text(
          S.of(context).request_payment_description_hint_new,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_paypal,
          value: RequestPaymentType.PAYPAL,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: 'Venmo',
          value: RequestPaymentType.VENMO,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_zellepay,
          value: RequestPaymentType.ZELLEPAY,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        requestModel.cashModel.paymentType == RequestPaymentType.ACH
            ? RequestPaymentACH(requestModel)
            : requestModel.cashModel.paymentType == RequestPaymentType.PAYPAL
                ? RequestPaymentPaypal(requestModel)
                : requestModel.cashModel.paymentType == RequestPaymentType.VENMO
                    ? RequestPaymentVenmo(requestModel)
                    : RequestPaymentZellePay(requestModel),
      ],
    );
  }

  // Widget BorrowToolTitleField(hintTextDesc) {
  //   return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text(
  //           "Request tools description*", //Label to be created
  //           style: TextStyle(
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //             fontFamily: 'Europa',
  //             color: Colors.black,
  //           ),
  //         ),
  //         TextFormField(
  //           autovalidateMode: AutovalidateMode.onUserInteraction,
  //           onChanged: (value) {
  //             // if (value != null && value.length > 5) {
  //             //   _debouncer.run(() {
  //             //     getCategoriesFromApi(value);
  //             //   });
  //             // }
  //             updateExitWithConfirmationValue(context, 9, value);
  //           },
  //           focusNode: focusNodes[3],
  //           onFieldSubmitted: (v) {
  //             FocusScope.of(context).requestFocus(focusNodes[3]);
  //           },
  //           textInputAction: TextInputAction.next,
  //           decoration: InputDecoration(
  //             errorMaxLines: 2,
  //             hintText: hintTextDesc,
  //             hintStyle: hintTextStyle,
  //           ),
  //           initialValue: "",
  //           keyboardType: TextInputType.multiline,
  //           maxLines: 1,
  //           validator: (value) {
  //             if (value.isEmpty) {
  //               return S.of(context).validation_error_general_text;
  //             }
  //             if (profanityDetector.isProfaneString(value)) {
  //               return S.of(context).profanity_text_alert;
  //             }
  //             requestModel.borrowRequestToolName = value;
  //           },
  //         ),
  //       ]);
  // }

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (requestModel.requestType == RequestType.BORROW && roomOrTool == 1)
              ? Text(
                  "Request tools description*",
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
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
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
                    role: memberType(timebankModel,
                        SevaCore.of(context).loggedInUser.sevaUserID),
                    child: _optionRadioButton<RequestType>(
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
                  ),
                  TransactionsMatrixCheck(
                    comingFrom: widget.comingFrom,
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.goods_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    child: _optionRadioButton<RequestType>(
                      title: S.of(context).request_type_goods,
                      isEnabled: !(widget.isOfferRequest ?? false),
                      value: RequestType.GOODS,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.isRecurring = false;
                        requestModel.requestType = value;
                        AppConfig.helpIconContextMember =
                            HelpContextMemberType.goods_requests;
                        setState(() => {});
                      },
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
                      child: _optionRadioButton<RequestType>(
                        title: S.of(context).request_type_cash,
                        value: RequestType.CASH,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          requestModel.isRecurring = false;
                          requestModel.requestType = value;
                          AppConfig.helpIconContextMember =
                              HelpContextMemberType.money_requests;
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
                      actionType: 'create_goods_request',
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: _optionRadioButton<RequestType>(
                        title: 'Borrow', //Label to be created
                        value: RequestType.BORROW,
                        isEnabled: !widget.isOfferRequest,
                        groupvalue: requestModel.requestType,
                        onChanged: (value) {
                          //requestModel.isRecurring = true;
                          requestModel.requestType = value;
                          //By default instructor for One To Many Requests is the creator
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
                  _optionRadioButton<RequestType>(
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
                      setState(() => {});
                    },
                  ),
                  _optionRadioButton<RequestType>(
                    title: 'Borrow', //Label to be created
                    value: RequestType.BORROW,
                    isEnabled: true,
                    groupvalue: requestModel.requestType,
                    onChanged: (value) {
                      //requestModel.isRecurring = true;
                      requestModel.requestType = value;
                      //By default instructor for One To Many Requests is the creator
                      //instructorAdded = false;
                      //requestModel.selectedInstructor = null;
                      AppConfig.helpIconContextMember = HelpContextMemberType
                          .time_requests; //need to make for Borrow requests
                      setState(() => {});
                    },
                  ),
                ],
              )
            ],
          )
        : Container();
  }

// Navigat to skills class and geting data from the class
  void selectSkills() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SkillViewNew(
        automaticallyImplyLeading: false,
        userModel: SevaCore.of(context).loggedInUser,
        isFromProfile: false,
        selectedSkills: _selectedSkillsMap,
        onSelectedSkillsMap: (skillMap) {
          Navigator.pop(context);
          if (skillMap.values != null && skillMap.values.length > 0) {
            _selectedSkillsMap = skillMap;
            setState(() {});
          }
        },
        onSelectedSkills: (skills) {
          Navigator.pop(context);
        },
        onSkipped: () {
          Navigator.pop(context);
        },
        languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
        isFromRequests: true,
      );
    }));
  }

// Choose Category and Sub Category function
  // get data from Category class
  List categories;
  Map<String, dynamic> _selectedSkillsMap = {};
  void updateInformation(List category) {
    setState(() => categories = category);
  }

  Future<void> getCategoriesFromApi(String query) async {
    try {
      var response = await http.post(
        "https://proxy.sevaexchange.com/" +
            "http://ai.api.sevaxapp.com/request_categories",
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
        List<String> categoriesList = bodyMap.containsKey('string_vec')
            ? List.castFrom(bodyMap['string_vec'])
            : [];
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
    List<CategoryModel> modelList = List();
    for (int i = 0; i < categoriesList.length; i += 1) {
      CategoryModel categoryModel = await FirestoreManager.getCategoryForId(
        categoryID: categoriesList[i],
      );
      modelList.add(categoryModel);
    }

    updateInformation([S.of(context).suggested_categories, modelList]);
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
    updateInformation(category);
  }

  //building list of selectedSubCategories
  List<Widget> _buildselectedSubCategories(List categories) {
    List<CategoryModel> subCategories = [];
    subCategories = categories[1];
    List<Widget> selectedSubCategories = [];
    selectedCategoryIds.clear();
    subCategories.forEach((item) {
      selectedCategoryIds.add(item.typeId);
      selectedSubCategories.add(
        Padding(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text("${item.title_en.toString()}",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );
    });
    return selectedSubCategories;
  }

  Widget BorrowRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RepeatWidget(),

          SizedBox(height: 20),

          // roomOrTool == 1
          //     ? BorrowToolTitleField('Ex: Hammer or Chair...')
          //     : Container(),
          //Label to be created (need client approval)

          SizedBox(height: 15),

          RequestDescriptionData(
              'Your Request and any #hashtags'), //Label to be created (need client approval)
          SizedBox(height: 20), //Same hint for Room and Tools ?
          // Choose Category and Sub Category
          InkWell(
            child: Column(
              children: [
                Row(
                  children: [
                    categories == null
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
                            "${categories[0]}",
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
                    // Container(
                    //   height: 25,
                    //   width: 25,
                    //   decoration: BoxDecoration(
                    //       color: Theme.of(context).primaryColor,
                    //       borderRadius: BorderRadius.circular(100)),
                    //   child: Icon(
                    //     Icons.arrow_drop_down_outlined,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 20),
                categories != null
                    ? Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: _buildselectedSubCategories(categories),
                      )
                    : Container(),
              ],
            ),
            onTap: () => moveToCategory(),
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),

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

  Widget skillsWidget() {
    return InkWell(
      child: Column(
        children: [
          Row(
            children: [
              _selectedSkillsMap.values.length < 1
                  ? Text(
                      'Choose Skills for request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "Selected Skills",
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
          _selectedSkillsMap.values != null
              ? Wrap(
                  alignment: WrapAlignment.start,
                  children: _selectedSkillsMap.values
                      .toList()
                      .map(
                        (value) => value == null
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, bottom: 10),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                    child: Text(value.toString(),
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                      )
                      .toList(),
                )
              : Container(),
        ],
      ),
      onTap: () => selectSkills(),
    );
  }

  Widget categoryWidget() {
    return InkWell(
      child: Column(
        children: [
          Row(
            children: [
              categories == null
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
                      "${categories[0]}",
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
              // Container(
              //   height: 25,
              //   width: 25,
              //   decoration: BoxDecoration(
              //       color: Theme.of(context).primaryColor,
              //       borderRadius: BorderRadius.circular(100)),
              //   child: Icon(
              //     Icons.arrow_drop_down_outlined,
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 20),
          categories != null
              ? Wrap(
                  alignment: WrapAlignment.start,
                  children: _buildselectedSubCategories(categories),
                )
              : Container(),
        ],
      ),
      onTap: () => moveToCategory(),
    );
  }

  Widget TimeRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RepeatWidget(),

          SizedBox(height: 20),

          RequestDescriptionData(S.of(context).request_description_hint),
          SizedBox(height: 20),
          // Choose Category and Sub Category
          categoryWidget(),
          SizedBox(height: 20),
          Text(
            'Provide the list of Skills that you required for this request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          SkillsForRequests(
            languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
            selectedSkills: _selectedSkillsMap,
            onSelectedSkillsMap: (skillMap) {
              if (skillMap.values != null && skillMap.values.length > 0) {
                _selectedSkillsMap = skillMap;
                // setState(() {});
              }
            },
          ),
          SizedBox(height: 20),

          AddImagesForRequest(
            onLinksCreated: (List<String> imageUrls) {
              requestModel.imageUrls = imageUrls;
            },
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
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

          // requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
          //     ? Row(
          //         children: [
          //           Checkbox(
          //             activeColor: Theme.of(context).primaryColor,
          //             checkColor: Colors.white,
          //             value: createEvent,
          //             onChanged: (val) {
          //               setState(() {
          //                 createEvent = val;
          //               });
          //             },
          //           ),
          //           Text(
          //               'Tick to create an event for this request') // Label to be created
          //         ],
          //       )
          //     : Container(height: 0, width: 0),

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

  void _search(String queryString) {
    if (queryString.length == 3) {
      setState(() {
        searchOnChange.add(queryString);
      });
    } else {
      searchOnChange.add(queryString);
    }
  }

  //  void refresh() {
  //   _firestore
  //       .collection('requests')
  //       .document(widget.requestModelId)
  //       .snapshots()
  //       .listen((reqModel) {
  //     requestModel = RequestModel.fromMap(reqModel.data);
  //     try {
  //       setState(() {
  //         buildWidget();
  //       });
  //     } on Exception catch (error) {
  //       logger.e(error);
  //     }
  //   });
  // }

  Widget CashRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData("Ex: Fundraiser to expand women’s shelter..."),
          // RequestDescriptionData(S.of(context).request_description_hint_cash),
          SizedBox(height: 20),
          categoryWidget(),
          SizedBox(height: 20),
          AddImagesForRequest(
            onLinksCreated: (List<String> imageUrls) {
              requestModel.imageUrls = imageUrls;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_target_donation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getCashDonationAmount(
                    offerDataModel: widget.offer,
                  )
                : "",
            focusNode: focusNodes[5],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 12, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.cashModel.targetAmount = int.parse(v);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).request_target_donation_hint,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_target_donation_count;
              } else if (int.parse(value) < 0) {
                return S
                    .of(context)
                    .validation_error_target_donation_count_negative;
              } else if (int.parse(value) == 0) {
                return S
                    .of(context)
                    .validation_error_target_donation_count_zero;
              } else {
                requestModel.cashModel.targetAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_min_donation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            focusNode: focusNodes[6],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 13, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.cashModel.minAmount = int.parse(v);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).request_min_donation_hint,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_min_donation_count;
              } else if (int.parse(value) < 0) {
                return S
                    .of(context)
                    .validation_error_min_donation_count_negative;
              } else if (int.parse(value) == 0) {
                return S.of(context).validation_error_min_donation_count_zero;
              } else if (requestModel.cashModel.targetAmount != null &&
                  requestModel.cashModel.targetAmount < int.parse(value)) {
                return S.of(context).target_amount_less_than_min_amount;
              } else {
                requestModel.cashModel.minAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestPaymentDescriptionData(requestModel),
        ]);
  }

  Widget GoodsRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData("Ex: Local Food Bank has a shortage..."),
          // RequestDescriptionData(S.of(context).request_description_hint_goods),
          SizedBox(height: 20),
          categoryWidget(),

          SizedBox(height: 10),
          AddImagesForRequest(
            onLinksCreated: (List<String> imageUrls) {
              requestModel.imageUrls = imageUrls;
            },
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestGoodsDescriptionData(),
        ]);
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
  }

  Widget _optionRadioButton<T>({
    String title,
    T value,
    T groupvalue,
    Function onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      key: UniqueKey(),
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: (isEnabled ?? true) ? onChanged : null,
      ),
    );
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

    requestModel.isRecurring = RepeatWidgetState.isRecurring;
    // requestModel.skills = _selectedSkillsMap;
    if (requestModel.requestType == RequestType.CASH ||
        requestModel.requestType == RequestType.GOODS) {
      requestModel.isRecurring = false;
    }

    if (requestModel.isRecurring) {
      requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
      requestModel.occurenceCount = 1;
      end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
      end.on = end.endType == "on"
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after =
          (end.endType == "after" ? int.parse(RepeatWidgetState.after) : null);
      requestModel.end = end;
    }

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

      if (requestModel.requestType == RequestType.GOODS &&
          requestModel.goodsDonationDetails.requiredGoods == null) {
        showDialogForTitle(dialogTitle: S.of(context).goods_validation);
        return;
      }

      if (widget.isOfferRequest && widget.userModel != null) {
        if (requestModel.approvedUsers == null) requestModel.approvedUsers = [];

        List<String> approvedUsers = [];
        approvedUsers.add(widget.userModel.email);
        requestModel.approvedUsers = approvedUsers;
        //TODO
        requestModel.participantDetails = {};
        requestModel.participantDetails[widget.userModel.email] = AcceptorModel(
          communityId: widget.offer.communityId,
          communityName: '',
          memberEmail: widget.userModel.email,
          memberName: widget.userModel.fullname,
          memberPhotoUrl: widget.userModel.photoURL,
          timebankId: widget.offer.timebankId,
        ).toMap();
        //create an invitation for the request
      }

      // if (requestModel.isRecurring &&
      //     (requestModel.requestType == RequestType.TIME ||
      //         requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST)) {
      //   if (requestModel.recurringDays.length == 0) {
      //     showDialogForTitle(
      //         dialogTitle: S.of(context).validation_error_empty_recurring_days);
      //     return;
      //   }
      // }

      // if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      //   List<String> approvedUsers = [];
      //   approvedUsers.add(requestModel.selectedInstructor.email);
      //   requestModel.approvedUsers = approvedUsers;
      // }

      // if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
      //     (requestModel.selectedInstructor.toMap().isEmpty ||
      //         requestModel.selectedInstructor == null ||
      //         instructorAdded == false)) {
      //   showDialogForTitle(
      //       dialogTitle: 'Select an Instructor'); //Label to be created
      //   return;
      // }

//check for tool title/name field is not empty
      // if (requestModel.requestType == RequestType.BORROW &&
      //     roomOrTool == 1 &&
      //     (requestModel.borrowRequestToolName == '' ||
      //         requestModel.borrowRequestToolName == null)) {
      //   showDialogForTitle(
      //       dialogTitle: 'Please enter Tool/s name'); //Label to be created
      //   return;
      // }

//Assigning room or tool for Borrrow Requests
      if (roomOrTool != null &&
          requestModel.requestType == RequestType.BORROW) {
        if (roomOrTool == 1) {
          //CHANGE to use enums
          requestModel.roomOrTool = 'TOOL';
        } else {
          requestModel.roomOrTool = 'ROOM';
        }
      }

//Review done or not to be used to find out if Borrow request is completed or not
      if (requestModel.requestType != RequestType.BORROW) {
        requestModel.lenderReviewed = false;
        requestModel.borrowerReviewed = false;
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
          double creditsNeeded =
                await SevaCreditLimitManager.checkCreditsNeeded(
            email: SevaCore.of(context).loggedInUser.email,
            credits: requestModel.numberOfHours.toDouble(),
            userId: myDetails.sevaUserID,
            communityId: timebankModel.communityId,
          );
          if (!onBalanceCheckResult) {
            showInsufficientBalance();
            await sendInsufficentNotificationToAdmin(creditsNeeded: creditsNeeded);
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel.fullName = timebankModel.name;
          requestModel.photoUrl = timebankModel.photoUrl;
          break;
      }
      //}

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String timestampString = timestamp.toString();
      requestModel.id = '${requestModel.email}*$timestampString';
      if (requestModel.isRecurring) {
        requestModel.parent_request_id = requestModel.id;
      } else {
        requestModel.parent_request_id = null;
      }
      communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
      );
      requestModel.liveMode = AppConfig.isTestCommunity;
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
      requestModel.categories = selectedCategoryIds;
      requestModel.address = selectedAddress;
      requestModel.location = location;
      requestModel.root_timebank_id = FlavorConfig.values.timebankId;
      requestModel.softDelete = false;
      requestModel.creatorName = SevaCore.of(context).loggedInUser.fullname;
      requestModel.minimumCredits = 0;

      if (SevaCore.of(context).loggedInUser.calendarId != null) {
        // calendar  integrated!
        if (communityModel.payment['planId'] !=
            SevaBillingPlans.NEIGHBOUR_HOOD_PLAN) {
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

        // await createProjectOneToManyRequest();

        // if (selectedInstructorModel != null &&
        //     selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
        //     requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        //   if (selectedInstructorModel.communities
        //       .contains(requestModel.communityId)) {
        //     await sendNotificationToMember(
        //         communityId: requestModel.communityId,
        //         timebankId: requestModel.timebankId,
        //         sevaUserId: selectedInstructorModel.sevaUserID,
        //         userEmail: selectedInstructorModel.email);
        //   } else {
        //     // trigger email for user who is not part of the community for this request
        //     await sendMailToInstructor(
        //         senderEmail: requestModel.email,
        //         receiverEmail: selectedInstructorModel.email,
        //         communityName: requestModel.fullName,
        //         requestName: requestModel.title,
        //         requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
        //         receiverName: selectedInstructorModel.fullname,
        //         startDate: requestModel.requestStart,
        //         endDate: requestModel.requestEnd);
        //   }
        // }

        await continueCreateRequest(confirmationDialogContext: null);
      } else {
        linearProgressForCreatingRequest();

        // await createProjectOneToManyRequest();

        // if (selectedInstructorModel != null &&
        //     selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
        //     requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
        //   if (selectedInstructorModel.communities
        //       .contains(requestModel.communityId)) {
        //     await sendNotificationToMember(
        //         communityId: requestModel.communityId,
        //         timebankId: requestModel.timebankId,
        //         sevaUserId: selectedInstructorModel.sevaUserID,
        //         userEmail: selectedInstructorModel.email);
        //     log('SENT NOTIF');
        //   } else {
        //     // trigger email for user who is not part of the community for this request
        //     await sendMailToInstructor(
        //         senderEmail: requestModel.email,
        //         receiverEmail: selectedInstructorModel.email,
        //         communityName: requestModel.fullName,
        //         requestName: requestModel.title,
        //         requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
        //         receiverName: selectedInstructorModel.fullname,
        //         startDate: requestModel.requestStart,
        //         endDate: requestModel.requestEnd);
        //   }
        // }

        eventsIdsArr = await _writeToDB();
        await _updateProjectModel();

        Navigator.pop(dialogContext);
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

  Future openPdfViewer(
      String pdfURL, String documentName, BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: true,
    );
    progressDialog.show();
    createFileOfPdfUrl(pdfURL, documentName).then((f) {
      progressDialog.hide();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  docName: documentName,
                  pathPDF: f.path,
                  isFromFeeds: false,
                  isDownloadable: false,
                )),
      );
    });
  }

  // Future createProjectOneToManyRequest() async {
  //   //Create new Event/Project for ONE TO MANY Request
  //   if (widget.projectModel == null &&
  //       //createEvent &&
  //       requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
  //     String newProjectId = Utils.getUuid();
  //     requestModel.projectId = newProjectId;
  //     List<String> pendingRequests = [requestModel.selectedInstructor.email];

  //     ProjectModel newProjectModel = ProjectModel(
  //       id: newProjectId,
  //       name: requestModel.title,
  //       communityId: requestModel.communityId,
  //       photoUrl: requestModel.photoUrl,
  //       creatorId: requestModel.sevaUserId,
  //       mode: ProjectMode.TIMEBANK_PROJECT,
  //       timebankId: requestModel.timebankId,
  //       associatedMessaginfRoomId: '',
  //       requestedSoftDelete: false,
  //       softDelete: false,
  //       createdAt: DateTime.now().millisecondsSinceEpoch,
  //       pendingRequests: pendingRequests,
  //       startTime: requestModel.requestStart,
  //       endTime: requestModel.requestEnd,
  //       description: requestModel.description,
  //     );

  //     await createProject(projectModel: newProjectModel);
  //   }
  // }

  bool hasRegisteredLocation() {
    return location != null;
  }

  Future<void> sendNotificationToMember(
      {String communityId,
      String sevaUserId,
      String timebankId,
      String userEmail}) async {
    UserAddedModel userAddedModel = UserAddedModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        adminName: SevaCore.of(context).loggedInUser.fullname);

    NotificationsModel notification = NotificationsModel(
        id: Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: requestModel.toMap(),
        isRead: false,
        type: NotificationType.OneToManyRequestAccept,
        communityId: communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: sevaUserId);

    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());

    log('WRITTEN TO DB--------------------->>');
  }

//Sending only if instructor is not part of the community of the request
  Future<bool> sendMailToInstructor({
    String senderEmail,
    String receiverEmail,
    String communityName,
    String requestName,
    String requestCreatorName,
    String receiverName,
    int startDate,
    int endDate,
  }) async {
    return await SevaMailer.createAndSendEmail(
        mailContent: MailContent.createMail(
      mailSender: senderEmail,
      mailReciever: receiverEmail,
      mailSubject:
          requestCreatorName + ' from ' + communityName + ' has invited you',
      mailContent: 'You have been invited to instruct ' +
          requestName +
          ' from ' +
          DateTime.fromMillisecondsSinceEpoch(startDate)
              .toString()
              .substring(0, 11) +
          ' to ' +
          DateTime.fromMillisecondsSinceEpoch(endDate)
              .toString()
              .substring(0, 11) +
          "\n\n" +
          'Thanks,' +
          "\n" +
          'SevaX Team.',
    ));
  } //Label to be given by client for email content

  void continueCreateRequest({BuildContext confirmationDialogContext}) async {
    linearProgressForCreatingRequest();

    List<String> resVar = await _writeToDB();
    eventsIdsArr = resVar;
    await _updateProjectModel();
    Navigator.pop(dialogContext);

    if (resVar.length == 0 && requestModel.requestType != RequestType.BORROW) {
      showInsufficientBalance();
    }
    if (confirmationDialogContext != null) {
      Navigator.pop(confirmationDialogContext);
    }
    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
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

  Map<String, UserModel> selectedUsers;
  Map onActivityResult;

  String memberAssignment;

  Widget addVolunteersForAdmin() {
    if (selectedUsers == null) {
      selectedUsers = HashMap();
    }

    if (widget.userModel != null) {
      Map<String, UserModel> map = HashMap();
      map[widget.userModel.email] = widget.userModel;
      selectedUsers.addAll(map);
    }
    memberAssignment = S.of(context).assign_to_volunteers;
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(selectedUsers != null && selectedUsers.length > 0
            ? "${selectedUsers.length} ${S.of(context).members_selected(selectedUsers.length)}"
            : memberAssignment),
        onPressed: () async {
          onActivityResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectMembersInGroup(
                timebankId: widget.loggedInUser.currentTimebank,
                userEmail: widget.loggedInUser.email,
                userSelected: selectedUsers,
                listOfalreadyExistingMembers: [],
              ),
            ),
          );

          if (onActivityResult != null &&
              onActivityResult.containsKey("membersSelected")) {
            selectedUsers = onActivityResult['membersSelected'];
            setState(() {
              if (selectedUsers != null && selectedUsers.length == 0)
                memberAssignment = S.of(context).assign_to_volunteers;
              else
                memberAssignment =
                    "${selectedUsers.length ?? ''} ${S.of(context).volunteers_selected(selectedUsers.length)}";
            });
          } else {
            //no users where selected
          }
          // SelectMembersInGroup
        },
      ),
    );
  }

  Future<void> fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    log("<<<<<<<<<<<<<<<<<<<< $link");
    // buildContext = context;
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    FirebaseDynamicLinks.instance.onLink(
        onError: (_) async {},
        onSuccess: (PendingDynamicLinkData dynamicLink) async {});

    // This will handle incoming links if the application is already opened
  }

  String getTimeInFormat(int timeStamp) {
    return DateFormat(
            'EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
    );
  }

  bool hasSufficientBalance() {
    var requestCoins = requestModel.numberOfHours;
    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
    return requestCoins <= finalbalance;
  }

  Future<List<String>> _writeToDB() async {
    if (requestModel.id == null) return [];
    // credit the timebank the required credits before the request creation
    if (requestModel.requestType != RequestType.BORROW) {
      log('Comes Here');
      await TransactionBloc().createNewTransaction(
        requestModel.timebankId,
        requestModel.timebankId,
        DateTime.now().millisecondsSinceEpoch,
        requestModel.numberOfHours ?? 0,
        true,
        "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
        requestModel.id,
        requestModel.timebankId,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        toEmailORId: requestModel.timebankId,
        fromEmailORId: FlavorConfig.values.timebankId,
      );
    }

    List<String> resultVar = [];
    if (!requestModel.isRecurring) {
      await FirestoreManager.createRequest(requestModel: requestModel);
      //create invitation if its from offer only for cash and goods
      try {
        await OfferInvitationManager
            .handleInvitationNotificationForRequestCreatedFromOffer(
          currentCommunity: widget.userModel.currentCommunity,
          offerModel: widget.offer,
          requestModel: requestModel,
          senderSevaUserID: requestModel.sevaUserId,
          timebankModel: timebankModel,
        );
      } on Exception catch (exception) {
        //Log to crashlytics
      }

      resultVar.add(requestModel.id);
      return resultVar;
    } else {
      resultVar = await FirestoreManager.createRecurringEvents(
        requestModel: requestModel,
        communityId: SevaCore.of(context).loggedInUser.currentCommunity,
        timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
      );
      return resultVar;
    }
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty && !requestModel.isRecurring) {
      ProjectModel projectModel = widget.projectModel;
//      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
//      if (!projectModel.members.contains(userSevaUserId)) {
//        projectModel.members.add(userSevaUserId);
//      }
      projectModel.pendingRequests.add(requestModel.id);
      await FirestoreManager.updateProject(projectModel: projectModel);
    }
  }

  Future<Map> showTimebankAdvisory() {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
              S.of(context).select_project,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            content: Form(
              child: Container(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    S.of(context).projects_here,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              FlatButton(
                child: Text(
                  S.of(context).proceed,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
//                  return Navigator.of(viewContext).pop({'PROCEED': true});
                },
              ),
            ],
          );
        });
  }

  void sendInsufficentNotificationToAdmin({
    double creditsNeeded,
  }) async {

    log('creditsNeeded:  '  + creditsNeeded.toString());

    UserInsufficentCreditsModel userInsufficientModel = UserInsufficentCreditsModel(
      senderName: SevaCore.of(context).loggedInUser.fullname,
      senderId: SevaCore.of(context).loggedInUser.sevaUserID,
      senderPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
      timebankId: timebankModel.id,
      timebankName: timebankModel.name,
      creditsNeeded: creditsNeeded,
    );

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: timebankModel.id,
        data: userInsufficientModel.toMap(),
        isRead: false,
        type: NotificationType.TYPE_MEMBER_HAS_INSUFFICENT_CREDITS,
        communityId: timebankModel.communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: timebankModel.creatorId);

    await Firestore.instance
        .collection('timebanknew')
        .document(timebankModel.id)
        .collection("notifications")
        .document(notification.id)
        .setData((notification..isTimebankNotification = true).toMap());

    log('writtent to DB');
  }
}

class ProjectSelection extends StatefulWidget {
  ProjectSelection({
    Key key,
    this.requestModel,
    this.admin,
    this.projectModelList,
    this.selectedProject,
    this.timebankModel,
    this.userModel,
  }) : super(key: key);
  final bool admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;
  TimebankModel timebankModel;
  UserModel userModel;

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    List<dynamic> list = [
      {"name": S.of(context).unassigned, "code": "None"}
    ];
    for (var i = 0; i < widget.projectModelList.length; i++) {
      list.add({
        "name": widget.projectModelList[i].name,
        "code": widget.projectModelList[i].id,
        "timebankproject":
            widget.projectModelList[i].mode == ProjectMode.TIMEBANK_PROJECT,
      });
    }
    return MultiSelect(
      timebankModel: widget.timebankModel,
      userModel: widget.userModel,
      autovalidate: true,
      initialValue: ['None'],
      titleText: S.of(context).assign_to_project,
      maxLength: 1, // optional
      hintText: S.of(context).tap_to_select,
      validator: (dynamic value) {
        if (value == null) {
          return S.of(context).assign_to_one_project;
        }
        return null;
      },
      errorText: S.of(context).assign_to_one_project,
      dataSource: list,
      admin: widget.admin,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        if (value != null && value[0] != 'None') {
          widget.requestModel.projectId = value[0];
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }
}

Future<Map<String, String>> getGoodsFuture() async {
  Map<String, String> goodsVar = {};
  QuerySnapshot querySnapshot = await Firestore.instance
      .collection('donationCategories')
      .orderBy('goodTitle')
      .getDocuments();
  querySnapshot.documents.forEach((DocumentSnapshot docData) {
    goodsVar[docData.documentID] = docData.data['goodTitle'];
  });
  log("goodsVar length ${goodsVar.length.toString()}");
  return goodsVar;
}

enum BorrowRequestType {
  TOOL,
  ROOM,
}
