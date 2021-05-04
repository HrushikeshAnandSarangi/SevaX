import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/equality.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_editRequest.dart';
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/request/widgets/skills_for_requests_widget.dart';
import 'package:sevaexchange/new_baseline/models/user_added_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as RequestManager;
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/mailer.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/svea_credits_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/requests/onetomany_request_instructor_card.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
import 'package:sevaexchange/widgets/select_category.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';
import 'package:usage/uuid/uuid.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';

import '../../flavor_config.dart';

class EditRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  String projectId;
  RequestModel requestModel;

  EditRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.projectId,
      this.projectModel,
      this.requestModel})
      : super(key: key);

  @override
  _EditRequestState createState() => _EditRequestState();
}

class _EditRequestState extends State<EditRequest> {
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              title,
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
                  return RequestEditForm(
                    requestModel: widget.requestModel,
                    isOfferRequest: widget.isOfferRequest,
                    offer: widget.offer,
                    timebankId: widget.timebankId,
                    userModel: widget.userModel,
                    loggedInUser: snapshot.data.loggedinuser,
                    projectId: widget.projectId,
                    projectModel: widget.projectModel,
                  );
                }
                return Text('');
              })),
    );
  }

  String get title {
    if (widget.requestModel.projectId == null ||
        widget.requestModel.projectId == "" ||
        widget.requestModel.projectId.isEmpty) {
      return S.of(context).edit;
    }
    return S.of(context).edit_request;
  }
}

class RequestEditForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  final ProjectModel projectModel;
  final String projectId;
  RequestModel requestModel;
  RequestEditForm(
      {this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.loggedInUser,
      this.projectId,
      this.projectModel,
      this.requestModel});

  @override
  RequestEditFormState createState() {
    return RequestEditFormState();
  }
}

class RequestEditFormState extends State<RequestEditForm> {
  final GlobalKey<_EditRequestState> _offerState = GlobalKey();
  final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();
  List<String> selectedCategoryIds = [];

  RequestModel requestModel;
  GeoFirePoint location;
  final _debouncer = Debouncer(milliseconds: 500);

  String initialRequestTitle = '';
  String initialRequestDescription = '';
  var startDate;
  var endDate;
  int tempCredits = 0;
  int tempNoOfVolunteers = 0;

  End end = End();
  var focusNodes = List.generate(16, (_) => FocusNode());

  double sevaCoinsValue = 0;
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;
  int sharedValue = 0;

  String _selectedTimebankId;
  int oldHours = 0;
  int oldTotalRecurrences = 0;
  bool isPublicCheckboxVisible = false;

//One To Many Request new variables
  bool isAdmin = false;
  //Map<dynamic,dynamic> selectedInstructorMap;
  final TextEditingController searchTextController = TextEditingController();
  final searchOnChange = BehaviorSubject<String>();
  final _textUpdates = StreamController<String>();

  //Below variable for Borrow Requests
  int roomOrTool = 0;

  UserModel selectedInstructorModel;
  bool createEvent = false;
  bool instructorAdded = false;

  Future<TimebankModel> getTimebankAdminStatus;
  Future getProjectsByFuture;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();

  RegExp regExp = RegExp(
    r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
    caseSensitive: false,
    multiLine: false,
  );
  @override
  void initState() {
    super.initState();
    _selectedTimebankId = widget.timebankId;
    requestModel = RequestModel(
      communityId: widget.requestModel.communityId,
      oneToManyRequestAttenders: widget.requestModel.oneToManyRequestAttenders,
    );
    this.requestModel.timebankId = _selectedTimebankId;
    this.location = widget.requestModel.location;
    this.selectedAddress = widget.requestModel.address;
    this.oldHours = widget.requestModel.numberOfHours;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = widget.projectId;
    if (widget.requestModel.categories != null &&
        widget.requestModel.categories.length > 0) {
      getCategoryModels(widget.requestModel.categories, 'Selected Categories');
    }
    isPublicCheckboxVisible = widget.requestModel.virtualRequest ?? false;
    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );
    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    tempCredits = widget.requestModel.maxCredits;
    initialRequestTitle = widget.requestModel.title;
    initialRequestDescription = widget.requestModel.description;
    tempNoOfVolunteers = widget.requestModel.numberOfApprovals;

//will be true because a One to many request when editing should have an instructor
    instructorAdded = true;

    log('Instructor Data:  ' +
        widget.requestModel.selectedInstructor.toString());
    log('Instructor Data:  ' + widget.requestModel.approvedUsers.toString());

    fetchRemoteConfig();

    // if ((FlavorConfig.appFlavor == Flavor.APP ||
    //     FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
    //   // _fetchCurrentlocation;
    // }
  }

  // void get _fetchCurrentlocation async {
  //   try {
  //     Location templocation = Location();
  //     bool _serviceEnabled;
  //     PermissionStatus _permissionGranted;

  //     _serviceEnabled = await templocation.serviceEnabled();
  //     if (!_serviceEnabled) {
  //       _serviceEnabled = await templocation.requestService();
  //       if (!_serviceEnabled) {
  //         return;
  //       }
  //     }

  //     _permissionGranted = await templocation.hasPermission();
  //     if (_permissionGranted == PermissionStatus.denied) {
  //       _permissionGranted = await templocation.requestPermission();
  //       if (_permissionGranted != PermissionStatus.granted) {
  //         return;
  //       }
  //     }
  //     Location().getLocation().then((onValue) {
  //       location = GeoFirePoint(onValue.latitude, onValue.longitude);
  //       LocationUtility()
  //           .getFormattedAddress(
  //         location.latitude,
  //         location.longitude,
  //       )
  //           .then((address) {
  //         setState(() {
  //           this.selectedAddress = address;
  //         });
  //       });
  //     });
  //   } on PlatformException catch (e) {
  //     if (e.code == 'PERMISSION_DENIED') {
  //       //error = e.message;
  //     } else if (e.code == 'SERVICE_STATUS_ERROR') {
  //       //error = e.message;
  //     }
  //   }
  // }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  @override
  void didChangeDependencies() {
    this.requestModel.email = widget.requestModel.email;
    this.requestModel.fullName = widget.requestModel.fullName;
    this.requestModel.photoUrl = widget.requestModel.photoUrl;
    this.requestModel.sevaUserId = widget.requestModel.sevaUserId;
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

  Widget addToProjectContainer(
      snapshot, List<ProjectModel> projectModelList, requestModel) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    timebankModel = snapshot.data;
    if (isAccessAvailable(
            snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID) &&
        widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST &&
        isFromRequest()) {
      return ProjectSelection(
          requestModel: requestModel,
          projectModelList: projectModelList,
          selectedProject: widget.requestModel.projectId != null
              ? projectModelList.firstWhere(
                  (element) => element.id == widget.requestModel.projectId,
                  orElse: () => null)
              : null,
          updateProjectIdCallback: (String projectid) {
            widget.requestModel.projectId = projectid;
          },
          admin: isAccessAvailable(
              snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID));
    } else {
      this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      this.requestModel.requestType = RequestType.TIME;
      return Container();
      // return ProjectSelection(
      //   requestModel: requestModel,
      //   projectModelList: projectModelList,
      //   selectedProject: null,
      //   admin: false,
      // );
    }
  }

  // Widget get assignProjectToRequestContainerWidget {
  //   return InkWell(
  //     splashColor: Colors.transparent,
  //     focusColor: Colors.transparent,
  //     hoverColor: Colors.transparent,
  //     onTap: () async {
  //       ExtendedNavigator.ofRouter<RequestsRouter>()
  //           .pushAssignProjectToRequest(
  //         timebankModel: timebankModel,
  //         userModel: BlocProvider.of<AuthBloc>(context).user,
  //         timebankProjectsList: timebankProjects,
  //         personalProjectsList: userPersonalProjects,
  //       )
  //           .then((projectModelRes) {
  //         if (projectModelRes != '') {
  //           selectedProjectModel = projectModelRes;
  //           //this.requestModel.projectId = selectedProjectModel.id;
  //           tempProjectId = selectedProjectModel.id;
  //           updateProject = true;
  //           setState(() {});
  //         }
  //       });
  //     },
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Text(S.of(context).assign_to_project,
  //                 style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.black87)),
  //             Spacer(),
  //             Icon(
  //               Icons.arrow_drop_down_circle,
  //               size: 30,
  //               color: Theme.of(context).primaryColor,
  //             )
  //           ],
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         Chip(
  //           label: Container(
  //             constraints: BoxConstraints(
  //                 maxWidth: MediaQuery.of(context).size.width - 80.0),
  //             child: Text(
  //                 selectedProjectModel == null
  //                     ? S.of(context).unassigned
  //                     : selectedProjectModel.name,
  //                 overflow: TextOverflow.ellipsis),
  //           ),
  //           deleteIcon: Icon(
  //             Icons.cancel,
  //             size: 20,
  //           ),
  //           deleteIconColor: Colors.black38,
  //           onDeleted: () {
  //             if (selectedProjectModel != null) {
  //               selectedProjectModel = null;
  //               //selectedProjectModel.id = '';
  //               tempProjectId = '';
  //               setState(() {});
  //             }
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }
  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    startDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestStart));
    endDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestEnd));
    hoursMessage = S.of(context).set_duration;
    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    this.requestModel.email = loggedInUser.email;
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;

    Widget headerContainer(snapshot) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (isAccessAvailable(
          snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID)) {
        return requestSwitch();
      } else {
        this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        this.requestModel.requestType = RequestType.TIME;
        return Container();
      }
    }

    return FutureBuilder<TimebankModel>(
        future: getTimebankAdminStatus,
        builder: (context, snapshot) {
          // if(snapshot.connectionState == ConnectionState.waiting){
          //   return LoadingIndicator();
          // }
          log("timebank ${snapshot.data}");
          return FutureBuilder<List<ProjectModel>>(
              future: getProjectsByFuture,
              builder: (projectscontext, projectListSnapshot) {
                if (projectListSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return LoadingIndicator();
                }
                if (projectListSnapshot.hasError) {
                  return Center(
                    child: Text(projectListSnapshot.error.toString()),
                  );
                }
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
                            // headerContainer(snapshot),
                            // RequestTypeWidget(),

                            Text(
                              S.of(context).request_title,
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
                                setState(() {
                                  initialRequestTitle = value;
                                });
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
                                hintText: S.of(context).request_title_hint,
                                hintStyle: hintTextStyle,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              initialValue: widget.requestModel.title,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).request_subject;
                                }
                                if (profanityDetector.isProfaneString(value)) {
                                  return S.of(context).profanity_text_alert;
                                }
                                //widget.requestModel.title = value;
                                initialRequestTitle = value;
                              },
                            ),

                            SizedBox(height: 15),

                            //Instructor to be assigned to One to many requests widget Here

                            instructorAdded
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 20),
                                      Text(
                                        "Selected Speaker",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Europa',
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            // SizedBox(
                                            //   height: 15,
                                            // ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                UserProfileImage(
                                                  photoUrl: widget
                                                      .requestModel
                                                      .selectedInstructor
                                                      .photoURL,
                                                  email: widget.requestModel
                                                      .selectedInstructor.email,
                                                  userId: widget
                                                      .requestModel
                                                      .selectedInstructor
                                                      .sevaUserID,
                                                  height: 75,
                                                  width: 75,
                                                  timebankModel: timebankModel,
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    widget
                                                            .requestModel
                                                            .selectedInstructor
                                                            .fullname ??
                                                        S
                                                            .of(context)
                                                            .name_not_available,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Container(
                                                  height: 37,
                                                  padding: EdgeInsets.only(
                                                      bottom: 0),
                                                  child: InkWell(
                                                    child: Icon(
                                                      Icons.cancel_rounded,
                                                      size: 30,
                                                      color: Colors.grey,
                                                    ),
                                                    onTap: () {
                                                      setState(() {
                                                        instructorAdded = false;
                                                        widget.requestModel
                                                                .selectedInstructor =
                                                            null;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : widget.requestModel.requestType ==
                                        RequestType.ONE_TO_MANY_REQUEST
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                            SizedBox(height: 20),
                                            Text(
                                              "Select a Speaker*",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Europa',
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 15),
                                            TextField(
                                              style: TextStyle(
                                                  color: Colors.black),
                                              controller: searchTextController,
                                              onChanged: _search,
                                              autocorrect: true,
                                              decoration: InputDecoration(
                                                suffixIcon: IconButton(
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: Colors.black54,
                                                    ),
                                                    onPressed: () {
                                                      searchTextController
                                                          .clear();
                                                    }),
                                                hasFloatingPlaceholder: false,
                                                alignLabelWithHint: true,
                                                isDense: true,
                                                prefixIcon: Icon(
                                                  Icons.search,
                                                  color: Colors.grey,
                                                ),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        10.0, 12.0, 10.0, 5.0),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.7),
                                                ),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide:
                                                            BorderSide(
                                                                color: Colors
                                                                    .white),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    15.7)),
                                                hintText: 'Ex: Garry',
                                                hintStyle: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),

                                            //SizedBox(height: 5),

                                            Container(
                                                child: Column(children: [
                                              StreamBuilder<List<UserModel>>(
                                                stream: SearchManager
                                                    .searchUserInSevaX(
                                                  queryString:
                                                      searchTextController.text,
                                                  //validItems: validItems,
                                                ),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    Text(snapshot.error
                                                        .toString());
                                                  }
                                                  if (!snapshot.hasData) {
                                                    return Center(
                                                      child: SizedBox(
                                                        height: 48,
                                                        width: 40,
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 12.0),
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  List<UserModel> userList =
                                                      snapshot.data;
                                                  userList.removeWhere((user) =>
                                                      user.sevaUserID ==
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID ||
                                                      user.sevaUserID ==
                                                          widget.requestModel
                                                              .sevaUserId);

                                                  if (userList.length == 0) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 0),
                                                              borderRadius: BorderRadius.vertical(
                                                                  bottom: Radius
                                                                      .circular(
                                                                          7.0)),
                                                            ),
                                                            borderOnForeground:
                                                                false,
                                                            shadowColor:
                                                                Colors.white24,
                                                            elevation: 5,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      top:
                                                                          11.0),
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .no_member_found,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }

                                                  if (searchTextController.text
                                                          .trim()
                                                          .length <
                                                      3) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.15,
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                  width: 0),
                                                              borderRadius: BorderRadius.vertical(
                                                                  bottom: Radius
                                                                      .circular(
                                                                          7.0)),
                                                            ),
                                                            borderOnForeground:
                                                                false,
                                                            shadowColor:
                                                                Colors.white24,
                                                            elevation: 5,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      top:
                                                                          11.0),
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .validation_error_search_min_characters,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Scrollbar(
                                                      child: Center(
                                                        child: Card(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .transparent,
                                                                width: 0),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          borderOnForeground:
                                                              false,
                                                          shadowColor:
                                                              Colors.white24,
                                                          elevation: 5,
                                                          child: LimitedBox(
                                                            maxHeight:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.55,
                                                            maxWidth: 90,
                                                            child: ListView
                                                                .separated(
                                                                    primary:
                                                                        false,
                                                                    //physics: NeverScrollableScroflutter card bordellPhysics(),
                                                                    shrinkWrap:
                                                                        true,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    itemCount:
                                                                        userList
                                                                            .length,
                                                                    separatorBuilder: (BuildContext
                                                                                context,
                                                                            int
                                                                                index) =>
                                                                        Divider(),
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      UserModel
                                                                          user =
                                                                          userList[
                                                                              index];

                                                                      List<String>
                                                                          timeBankIds =
                                                                          snapshot.data[index].favoriteByTimeBank ??
                                                                              [];
                                                                      List<String>
                                                                          memberId =
                                                                          user.favoriteByMember ??
                                                                              [];

                                                                      return OneToManyInstructorCard(
                                                                        userModel:
                                                                            user,
                                                                        timebankModel:
                                                                            timebankModel,
                                                                        isAdmin:
                                                                            isAdmin,
                                                                        //refresh: refresh,
                                                                        currentCommunity: SevaCore.of(context)
                                                                            .loggedInUser
                                                                            .currentCommunity,
                                                                        loggedUserId: SevaCore.of(context)
                                                                            .loggedInUser
                                                                            .sevaUserID,
                                                                        isFavorite: isAdmin
                                                                            ? timeBankIds.contains(widget.requestModel.timebankId)
                                                                            : memberId.contains(SevaCore.of(context).loggedInUser.sevaUserID),
                                                                        addStatus: S
                                                                            .of(context)
                                                                            .add,
                                                                        onAddClick:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            selectedInstructorModel =
                                                                                user;
                                                                            instructorAdded =
                                                                                true;
                                                                            widget.requestModel.selectedInstructor =
                                                                                BasicUserDetails(
                                                                              fullname: user.fullname,
                                                                              email: user.email,
                                                                              photoURL: user.photoURL,
                                                                              sevaUserID: user.sevaUserID,
                                                                            );
                                                                          });
                                                                        },
                                                                      );
                                                                    }),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ])),
                                          ])
                                    : Container(height: 0, width: 0),

                            SizedBox(height: 30),

                            OfferDurationWidget(
                                title: S.of(context).request_duration,
                                startTime: startDate,
                                endTime: endDate),

                            widget.requestModel.requestType == RequestType.TIME
                                ? TimeRequest(snapshot, projectModelList)
                                : widget.requestModel.requestType ==
                                        RequestType.CASH
                                    ? CashRequest(snapshot, projectModelList)
                                    : widget.requestModel.requestType ==
                                            RequestType.ONE_TO_MANY_REQUEST
                                        ? TimeRequest(
                                            snapshot, projectModelList)
                                        : widget.requestModel.requestType ==
                                                RequestType.BORROW
                                            ? BorrowRequest(
                                                snapshot, projectModelList)
                                            : GoodsRequest(
                                                snapshot, projectModelList),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: OpenScopeCheckBox(
                                infoType: InfoType.VirtualRequest,
                                isChecked: widget.requestModel.virtualRequest,
                                checkBoxTypeLabel:
                                    CheckBoxType.type_VirtualRequest,
                                onChangedCB: (bool val) {
                                  if (widget.requestModel.virtualRequest !=
                                      val) {
                                    widget.requestModel.virtualRequest = val;
                                    if (val) {
                                      isPublicCheckboxVisible = true;
                                    } else {
                                      isPublicCheckboxVisible = false;
                                      widget.requestModel.public = false;
                                    }

                                    log('value ${widget.requestModel.virtualRequest}');
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            HideWidget(
                              hide: !isPublicCheckboxVisible ||
                                  widget.requestModel.requestMode !=
                                      RequestMode.TIMEBANK_REQUEST,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: OpenScopeCheckBox(
                                    infoType: InfoType.OpenScopeRequest,
                                    isChecked: widget.requestModel.public,
                                    checkBoxTypeLabel:
                                        CheckBoxType.type_Requests,
                                    onChangedCB: (bool val) {
                                      if (widget.requestModel.public != val) {
                                        widget.requestModel.public = val;
                                        log('value ${widget.requestModel.public}');
                                        setState(() {});
                                      }
                                    }),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30.0),
                              child: Center(
                                child: Container(
                                  // width: 150,
                                  child: RaisedButton(
                                    onPressed: editRequest,
                                    child: Text(
                                      S
                                          .of(context)
                                          .update_request
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

  void _search(String queryString) {
    if (queryString.length == 3) {
      setState(() {
        searchOnChange.add(queryString);
      });
    } else {
      searchOnChange.add(queryString);
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
            goodsbefore: widget.requestModel.goodsDonationDetails.requiredGoods,
            onSelectedGoods: (goods) => {
              widget.requestModel.goodsDonationDetails.requiredGoods = goods
            },
          ),
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
            initialValue: widget.requestModel.goodsDonationDetails.address,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                widget.requestModel.goodsDonationDetails.address = value;
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
            initialValue: requestModel.cashModel.achdetails.bank_name,
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
                widget.requestModel.cashModel.achdetails.bank_name = value;
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
            initialValue: requestModel.cashModel.achdetails.bank_address,
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
                widget.requestModel.cashModel.achdetails.bank_address = value;
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
            initialValue: requestModel.cashModel.achdetails.routing_number,
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
                widget.requestModel.cashModel.achdetails.routing_number = value;
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
            initialValue: requestModel.cashModel.achdetails.account_number,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 6, value);
            },
            focusNode: focusNodes[15],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.achdetails.account_number = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.account_number = value;
              } else {
                return S.of(context).enter_valid_account_number;
              }
              return null;
            },
          )
        ]);
  }

  RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

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
            initialValue: requestModel.cashModel.zelleId != null
                ? requestModel.cashModel.zelleId
                : '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.zelleId = value;
            },
            validator: (value) {
              return _validateEmailAndPhone(value);
            },
          )
        ]);
  }

  String _validateEmailAndPhone(String value) {
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
      widget.requestModel.cashModel.zelleId = value;

      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
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
            initialValue: requestModel.cashModel.paypalId ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.paypalId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!emailPattern.hasMatch(value)) {
                return S.of(context).enter_valid_link;
              } else {
                widget.requestModel.cashModel.paypalId = value;

                return null;
              }
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
            initialValue: requestModel.cashModel.venmoId ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                widget.requestModel.cashModel.venmoId = value;
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
          S.of(context).request_payment_description_hint,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        _optionRadioButton(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_paypal,
            value: RequestPaymentType.PAYPAL,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        _optionRadioButton(
            title: 'Venmo',
            value: RequestPaymentType.VENMO,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_zellepay,
            value: RequestPaymentType.ZELLEPAY,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        getPaymentInformation
      ],
    );
  }

  Widget get getPaymentInformation {
    switch (widget.requestModel.cashModel.paymentType) {
      case RequestPaymentType.ACH:
        return RequestPaymentACH(widget.requestModel);

      case RequestPaymentType.PAYPAL:
        return RequestPaymentPaypal(widget.requestModel);

      case RequestPaymentType.ZELLEPAY:
        return RequestPaymentZellePay(widget.requestModel);

      case RequestPaymentType.VENMO:
        return RequestPaymentVenmo(widget.requestModel);

      default:
        return RequestPaymentACH(widget.requestModel);
    }
  }

  //  Widget BorrowToolTitleField(hintTextDesc) {
  //   return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text(
  //           "Tool Name*",
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
  //           initialValue: widget.requestModel.borrowRequestToolName,
  //           keyboardType: TextInputType.multiline,
  //           maxLines: 1,
  //           validator: (value) {
  //             if (value.isEmpty) {
  //               return S.of(context).validation_error_general_text;
  //             }
  //             if (profanityDetector.isProfaneString(value)) {
  //               return S.of(context).profanity_text_alert;
  //             }
  //             widget.requestModel.borrowRequestToolName = value;
  //           },
  //         ),
  //       ]);
  // }

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).request_description,
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
            if (value != null && value.length > 1) {
              _debouncer.run(() {
                getCategoriesFromApi(value);
              });
            }
            updateExitWithConfirmationValue(context, 9, value);

            setState(() {
              initialRequestDescription = value;
            });
          },
          focusNode: focusNodes[0],
          onFieldSubmitted: (v) {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
          textInputAction: TextInputAction.next,
          maxLength: 500,
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: hintTextDesc,
            hintStyle: hintTextStyle,
          ),
          initialValue: widget.requestModel.description,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            }
            if (profanityDetector.isProfaneString(value)) {
              return S.of(context).profanity_text_alert;
            }
            //widget.requestModel.description = value;
            initialRequestDescription = value;
          },
        ),
      ],
    );
  }

  Widget RequestTypeWidget() {
    return widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
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
                  _optionRadioButton(
                    title: S.of(context).request_type_time,
                    value: RequestType.TIME,
                    groupvalue: widget.requestModel.requestType,
                    onChanged: (value) {
                      //instructorAdded = false;
                      //widget.requestModel.selectedInstructor.clear();
                      widget.requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  _optionRadioButton(
                    title: S.of(context).one_to_many,
                    value: RequestType.ONE_TO_MANY_REQUEST,
                    groupvalue: widget.requestModel.requestType,
                    onChanged: (value) {
                      widget.requestModel.requestType = value;
                      //instructorAdded = true;
                      // widget.requestModel.selectedInstructor = ({
                      //   'fullname': widget.userModel.fullname,
                      //   'email': widget.userModel.email,
                      //   'photoURL': widget.userModel.photoURL,
                      //   'sevaUserID': widget.userModel.sevaUserID,
                      // });
                      setState(() => {});
                    },
                  ),
                  _optionRadioButton(
                      title: S.of(context).request_type_cash,
                      value: RequestType.CASH,
                      groupvalue: widget.requestModel.requestType,
                      onChanged: (value) {
                        widget.requestModel.requestType = value;
                        setState(() => {});
                      }),
                  _optionRadioButton(
                      title: S.of(context).request_type_goods,
                      value: RequestType.GOODS,
                      groupvalue: widget.requestModel.requestType,
                      onChanged: (value) {
                        widget.requestModel.requestType = value;
                        setState(() => {});
                      }),
                ],
              )
            ],
          )
        : Container();
  }

// Choose Category and Sub Category function
  // get data from Category class
  List categories;
  List<CategoryModel> modelList = List();
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

      if (response.statusCode == 200) {
        Map<String, dynamic> bodyMap = json.decode(response.body);
        List<String> categoriesList = bodyMap.containsKey('string_vec')
            ? List.castFrom(bodyMap['string_vec'])
            : [];
        if (categoriesList != null && categoriesList.length > 0) {
          getCategoryModels(categoriesList, S.of(context).suggested_categories);
        }
      } else {
        return null;
      }
    } catch (exception) {
      log(exception.toString());
      return null;
    }
  }

  Future<void> getCategoryModels(
      List<String> categoriesList, String title) async {
    List<CategoryModel> modelList = List();
    for (int i = 0; i < categoriesList.length; i += 1) {
      CategoryModel categoryModel = await FirestoreManager.getCategoryForId(
        categoryID: categoriesList[i],
      );
      modelList.add(categoryModel);
    }

    updateInformation([title, modelList]);
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
    log(' poped selectedCategory  => ${category[0]} \n poped selectedSubCategories => ${category[1]} ');
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

  Widget TimeRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: widget.requestModel.isRecurring == true ||
                widget.requestModel.autoGenerated == true,
            child: EditRepeatWidget(
              requestModel: widget.requestModel,
              offerModel: null,
            ),
          ),
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint),
          SizedBox(height: 20),
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
                  initialValue: widget.requestModel.maxCredits.toString(),
                  onChanged: (v) {
                    logger.i("___________>>> Updating credits to ============");

                    updateExitWithConfirmationValue(context, 10, v);
                    if (v.isNotEmpty && int.parse(v) >= 0) {
                      //widget.requestModel.maxCredits = int.parse(v);
                      logger.i("___________>>> Updating credits to " +
                          int.parse(v).toString());

                      tempCredits = int.parse(v);
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
                      //requestModel.maxCredits = int.parse(value);
                      tempCredits = int.parse(value);
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
            initialValue: widget.requestModel.numberOfApprovals.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 11, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                //widget.requestModel.numberOfApprovals = int.parse(v);
                tempNoOfVolunteers = int.parse(v);
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
                //widget.requestModel.numberOfApprovals = int.parse(value);
                tempNoOfVolunteers = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          CommonUtils.TotalCredits(
            context: context,
            requestCreditsMode: TotalCreditseMode.EDIT_MODE,
            requestModel: widget.requestModel,
          ),

          SizedBox(height: 10),

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
          //               'Tick to create an event for this request')
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

  Widget BorrowRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: widget.requestModel.isRecurring == true ||
                widget.requestModel.autoGenerated == true,
            child: EditRepeatWidget(
              requestModel: widget.requestModel,
              offerModel: null,
            ),
          ),
          SizedBox(height: 20),

          // widget.requestModel.borrowRequestToolName != null
          // ? BorrowToolTitleField('Ex: Hammer or Chair...')
          //     : Container(),

          SizedBox(height: 15),

          RequestDescriptionData('Please describe what you require'),
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
                  widget.requestModel,
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

  Widget CashRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
            focusNode: focusNodes[5],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            initialValue: widget.requestModel.cashModel.targetAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 12, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.targetAmount = int.parse(v);
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
                widget.requestModel.cashModel.targetAmount = int.parse(value);
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
            initialValue: widget.requestModel.cashModel.minAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 13, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.minAmount = int.parse(v);
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
              } else {
                widget.requestModel.cashModel.minAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_cash),
          SizedBox(height: 20),
          AddImagesForRequest(
            onLinksCreated: (List<String> imageUrls) {
              widget.requestModel.imageUrls = imageUrls;
            },
            selectedList: widget.requestModel.imageUrls,
          ),
          SizedBox(height: 20),
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
                  widget.requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestPaymentDescriptionData(widget.requestModel),
        ]);
  }

  Widget GoodsRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_goods),
          SizedBox(height: 20),
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
          AddImagesForRequest(
            onLinksCreated: (List<String> imageUrls) {
              widget.requestModel.imageUrls = imageUrls;
            },
            selectedList: widget.requestModel.imageUrls,
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  widget.requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestGoodsDescriptionData(),
        ]);
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
  }

  Widget _optionRadioButton(
      {String title, value, groupvalue, Function onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading:
          Radio(value: value, groupValue: groupvalue, onChanged: onChanged),
    );
  }

  Widget requestSwitch() {
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
              S.of(context).timebank_request(1),
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
                  widget.requestModel.requestMode =
                      RequestMode.TIMEBANK_REQUEST;
                } else {
                  widget.requestModel.requestMode =
                      RequestMode.PERSONAL_REQUEST;
                  widget.requestModel.requestType = RequestType.TIME;
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
          widget.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          widget.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
          widget.requestModel.requestType = RequestType.TIME;
        }
      }
      return Container();
    }
  }

  BuildContext dialogContext;

  void editRequest() async {
    log('Project ID:  ' + widget.requestModel.projectId.toString());
    // verify f the start and end date time is not same
    log('while updating:  ' + widget.requestModel.projectId);

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

    logger.i(widget.requestModel.communityId + "<<<<<<<<<<<<<<<>>>>>>>>>>>>");

    if (_formKey.currentState.validate()) {
      if (widget.requestModel.public) {
        widget.requestModel.timebanksPosted = [
          widget.requestModel.timebankId,
          FlavorConfig.values.timebankId
        ];
      } else {
        widget.requestModel.timebanksPosted = [widget.requestModel.timebankId];
      }

      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        EditRepeatWidgetState.recurringDays =
            EditRepeatWidgetState.getRecurringdays();
        // end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
        // end.on = end.endType == "on"
        //     ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch
        //     : null;
        // end.after = (end.endType == "after"
        //     ? int.parse(EditRepeatWidgetState.after)
        //     : 1);
        // widget.requestModel.end = end;
      }

      if (widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
        var onBalanceCheckResult;
        if (widget.requestModel.isRecurring == true ||
            widget.requestModel.autoGenerated == true) {
          int recurrences = widget.requestModel.end.endType == "after"
              ? (widget.requestModel.end.after -
                      widget.requestModel.occurenceCount)
                  .abs()
              : calculateRecurrencesOnMode(widget.requestModel);
          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            credits: widget.requestModel.isRecurring
                ? widget.requestModel.numberOfHours.toDouble() * recurrences
                : widget.requestModel.numberOfHours.toDouble(),
            communityId: widget.requestModel.communityId,
          );
        } else {
          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: SevaCore.of(context).loggedInUser.email,
            userId: SevaCore.of(context).loggedInUser.sevaUserID,
            credits: widget.requestModel.isRecurring
                ? widget.requestModel.numberOfHours.toDouble() * 0
                : widget.requestModel.numberOfHours.toDouble(),
            communityId: widget.requestModel.communityId,
          );
        }

        if (!onBalanceCheckResult) {
          showInsufficientBalance();
          return;
        }
      }

      logger.i("=============||||||===============");

      /// TODO take language from Prakash
      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp == 0 ||
          OfferDurationWidgetState.endtimestamp == 0) {
        showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp >
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater);
        return;
      }

      // if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      //   List<String> approvedUsers = [];
      //   approvedUsers.add(widget.requestModel.selectedInstructor.email);
      //   widget.requestModel.approvedUsers = approvedUsers;
      // }

      if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
          (widget.requestModel.selectedInstructor == {} ||
              widget.requestModel.selectedInstructor == null ||
              instructorAdded == false)) {
        showDialogForTitle(dialogTitle: 'Select an Instructor');
        return;
      }

      //comparing the recurring days List

      Function eq = const ListEquality().equals;
      bool recurrinDaysListsMatch = eq(widget.requestModel.recurringDays,
          EditRepeatWidgetState.recurringDays);
      log('Days Match:  ' + recurrinDaysListsMatch.toString());
      String tempSelectedEndType =
          EditRepeatWidgetState.endType == 0 ? 'on' : 'after';

      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        if (widget.requestModel.title != initialRequestTitle ||
            startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetState.starttimestamp ||
            endDate.millisecondsSinceEpoch !=
                OfferDurationWidgetState.endtimestamp ||
            widget.requestModel.description != initialRequestDescription ||
            tempCredits != widget.requestModel.maxCredits ||
            tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
            location != widget.requestModel.location) {
          //setState(() {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.location = location;
          widget.requestModel.address = selectedAddress;
          widget.requestModel.categories = selectedCategoryIds.toList();

          widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
          widget.requestModel.maxCredits = tempCredits;

          startDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetState.starttimestamp
              ? widget.requestModel.requestStart =
                  OfferDurationWidgetState.starttimestamp
              : null;

          endDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetState.endtimestamp
              ? widget.requestModel.requestEnd =
                  OfferDurationWidgetState.endtimestamp
              : null;
          //});

          if (selectedInstructorModel != null &&
              selectedInstructorModel.sevaUserID !=
                  widget.requestModel.sevaUserId &&
              !widget.requestModel.acceptors
                  .contains(selectedInstructorModel.email) &&
              widget.requestModel.requestType ==
                  RequestType.ONE_TO_MANY_REQUEST) {
            List<String> acceptorsList = [];
            acceptorsList.add(selectedInstructorModel.email);
            widget.requestModel.acceptors = acceptorsList;
            widget.requestModel.requestCreatorName =
                SevaCore.of(context).loggedInUser.fullname;
            log('ADDED ACCEPTOR');

            if (selectedInstructorModel.communities
                .contains(widget.requestModel.communityId)) {
              await sendNotificationToMemberOneToManyRequest(
                  communityId: widget.requestModel.communityId,
                  timebankId: widget.requestModel.timebankId,
                  sevaUserId: selectedInstructorModel.sevaUserID,
                  userEmail: selectedInstructorModel.email);
            } else {
              await sendNotificationToMemberOneToManyRequest(
                  communityId: FlavorConfig.values.timebankId,
                  timebankId: FlavorConfig.values.timebankId,
                  sevaUserId: selectedInstructorModel.sevaUserID,
                  userEmail: selectedInstructorModel.email);
              // send sevax global notification for user who is not part of the community for this request
              await sendMailToInstructor(
                  senderEmail: 'noreply@sevaexchange.com', //requestModel.email,
                  receiverEmail: selectedInstructorModel.email,
                  communityName: widget.requestModel.fullName,
                  requestName: widget.requestModel.title,
                  requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
                  receiverName: selectedInstructorModel.fullname,
                  startDate: widget.requestModel.requestStart,
                  endDate: widget.requestModel.requestEnd);
            }
          }

          return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext viewContext) {
              return WillPopScope(
                onWillPop: () {},
                child: AlertDialog(
                  title: Text(S.of(context).this_is_repeating_event),
                  actions: [
                    FlatButton(
                      child: Text(
                        S.of(context).edit_this_event,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(viewContext);
                        linearProgressForCreatingRequest();
                        await updateRequest(requestModel: widget.requestModel);
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        S.of(context).edit_subsequent_event,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(viewContext);
                        linearProgressForCreatingRequest();
                        await updateRequest(requestModel: widget.requestModel);
                        await RequestManager.updateRecurrenceRequestsFrontEnd(
                          updatedRequestModel: widget.requestModel,
                          communityId: SevaCore.of(context)
                              .loggedInUser
                              .currentCommunity,
                          timebankId:
                              SevaCore.of(context).loggedInUser.currentTimebank,
                        );

                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
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
        }

        logger.i("=============////////===============");

        if (tempSelectedEndType != widget.requestModel.end.endType ||
            widget.requestModel.end.after !=
                int.parse(EditRepeatWidgetState.after) ||
            widget.requestModel.end.on !=
                EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch ||
            recurrinDaysListsMatch == false) {
          //setState(() {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.isRecurring = EditRepeatWidgetState.isRecurring;
          widget.requestModel.end.after =
              int.parse(EditRepeatWidgetState.after);
          widget.requestModel.end.endType = tempSelectedEndType;
          widget.requestModel.recurringDays =
              EditRepeatWidgetState.recurringDays;
          widget.requestModel.end.on =
              EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch;
          //});

          logger.i("=============IF===============");

          linearProgressForCreatingRequest();
          await updateRequest(requestModel: widget.requestModel);
          await RequestManager.updateRecurrenceRequestsFrontEnd(
            updatedRequestModel: widget.requestModel,
            communityId: SevaCore.of(context).loggedInUser.currentCommunity,
            timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          );

          Navigator.pop(dialogContext);
          Navigator.pop(context);
        } else {
          Navigator.of(context).pop();
        }
      } else if (widget.requestModel.isRecurring == false &&
          widget.requestModel.autoGenerated == false) {
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
          List<String> acceptorsList = [];
          acceptorsList.add(selectedInstructorModel.email);
          widget.requestModel.acceptors = acceptorsList;
          widget.requestModel.requestCreatorName =
              SevaCore.of(context).loggedInUser.fullname;
          log('ADDED ACCEPTOR');

          if (selectedInstructorModel.communities
              .contains(widget.requestModel.communityId)) {
            await sendNotificationToMemberOneToManyRequest(
                communityId: widget.requestModel.communityId,
                timebankId: widget.requestModel.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email);
          } else {
            // send sevax global notification for user who is not part of the community for this request
            await sendNotificationToMemberOneToManyRequest(
                communityId: FlavorConfig.values.timebankId,
                timebankId: FlavorConfig.values.timebankId,
                sevaUserId: selectedInstructorModel.sevaUserID,
                userEmail: selectedInstructorModel.email);
            await sendMailToInstructor(
                senderEmail: 'noreply@sevaexchange.com', //requestModel.email,
                receiverEmail: selectedInstructorModel.email,
                communityName: widget.requestModel.fullName,
                requestName: widget.requestModel.title,
                requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
                receiverName: selectedInstructorModel.fullname,
                startDate: widget.requestModel.requestStart,
                endDate: widget.requestModel.requestEnd);
          }
        }

        widget.requestModel.title = initialRequestTitle;
        widget.requestModel.description = initialRequestDescription;
        widget.requestModel.location = location;
        widget.requestModel.address = selectedAddress;
        widget.requestModel.categories = selectedCategoryIds.toList();
        startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetState.starttimestamp
            ? widget.requestModel.requestStart =
                OfferDurationWidgetState.starttimestamp
            : null;
        endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp
            ? widget.requestModel.requestEnd =
                OfferDurationWidgetState.endtimestamp
            : null;
        widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
        widget.requestModel.maxCredits = tempCredits;

        linearProgressForCreatingRequest();
        await updateRequest(requestModel: widget.requestModel);

        Navigator.pop(dialogContext);
        Navigator.pop(context);
      } else {
        Navigator.of(context).pop();
      }
      //}
    }
  }

  // Future _getLocation() async {
  //   String address = await LocationUtility().getFormattedAddress(
  //     location.latitude,
  //     location.longitude,
  //   );

  //   setState(() {
  //     this.selectedAddress = address;
  //   });
  // }

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

  bool hasRegisteredLocation() {
    return location != null;
  }

  Future<void> sendNotificationToMemberOneToManyRequest(
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
        data: widget.requestModel.toMap(),
        isRead: false,
        isTimebankNotification: false,
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
      mailContent:
          """ <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head>
        <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    </head>
    
    <body>
        <div dir="ltr">
    
            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;border:0px;background-color:white;font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif">
                <tbody>
    
                        <tr>
                        <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:10px;border-right:10px;border-top:10px;border-bottom:0px;padding:40px 80px 0px 80px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:600px;width:600px">
                                <tbody>
                                    
                                    <tr>
                                        <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateHeader" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:19px;padding-bottom:19px">
                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:600px;width:600px">
                                                <tbody>
                                                    <tr>
                                                        <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" >
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" >
                                                                            <table align="left" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse:inherit;border:0px;border-color:white;">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td valign="top" style="padding:0px;text-align:center"><img align="left" alt="" src="https://ci5.googleusercontent.com/proxy/KMTN5MCNI08J15B09izASZ49J6rqtQf7e39MXu2B9OeOXFLSrmcqMBLGqpRsiuXVXCs5K0VhqORlonSSzigT_LlYKqS9WLljenNftkN5gYij5IKg6WOJ3VGHj2YikF1RrzTnoKPBEXfJl5RtYCqCHQVcmNYZZQ=s0-d-e1-ft#https://mcusercontent.com/18ef8611cb76f33e8a73c9575/images/60fe9519-6fc0-463f-8c67-b6341d56cf6f.jpg"
                                                                                                width="108" style="margin-right:35px;border-collapse:inherit;border:0px;border-color:white;height:auto;outline:none;vertical-align:bottom;max-width:400px;padding-bottom:0px;display:inline" class="CToWUd"></td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
    
                                    <tr>
                                        <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse: inherit;border:0px;padding:0px">
                                            
                                        
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;table-layout:fixed">
                                                <tbody>
                                                    <tr>
                                                        <td style="min-width:100%;padding:18px 10px 18px 0px">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;min-width:100%;border-top:2px solid rgb(234, 234, 234)">
                                                                <tbody>
                                                                    <tr>
                                                                        <td></td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                <tbody>
                                                    <tr>
                                                        <td valign="top" style="padding-bottom:10px">
                                                            <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
                                                                            <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">Hi ${receiverName},</div>
                                                                            <div style="text-align:left;font-size:20px;line-height:25px;color:black;font-weight:700;"><br>You have been invited by ${requestCreatorName} to be the speaker \n for: ${requestName} on ${DateFormat('EEEE, d MMM h:mm a').format(DateTime.fromMillisecondsSinceEpoch(startDate))}.</div>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>

                                        </td>
                                    </tr>
    
                                </tbody>
                            </table>
                        </td>
                    </tr>
                        <td align="center" valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
                            <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:0px;border-right:0px;border-top:0px;border-bottom:0px;padding:0px 0px 0px 00px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:777px">
                                <tbody>
    
                                    <tr>
                                        <td align=" center " valign="top " id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateFooter " style="background:none 50% 50%/cover no-repeat rgb(47,46,46);border:0px;padding-top:45px;padding-bottom:33px;">
                                            <table align="center " border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="max-width:600px;width:600px ">
                                                <tbody>
                                                    <tr>
                                                        <td valign="top " style="background:none 50% 50%/cover no-repeat transparent;border:0px;padding-top:0px;padding-bottom:0px ">
                                                            <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="min-width:100%;table-layout:fixed;">
                                                                <tbody>
                                                                    <tr>
                                                                        <td style="">
                                                                            <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="margin-left:12%;padding-right:15%;border-top: 2px solid rgb(80,80,80) ">
                                                                                <tbody>
                                                                                    <tr>
                                                                                        <td></td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                            <table border="0 " cellpadding="0 " cellspacing="0 " width="100%">
                                                                <tbody>
                                                                    <tr>
                                                                        <td valign="top " style="padding-top:9px;">
                                                                            <table align="left " border="0" cellpadding="0 " cellspacing="0 " width="100% " style="margin-left:40%;padding-right:50%;">
                                                                                <tbody>
                                                                                    <tr>
                                                                                <td valign="top " style="font-family:Helvetica;word-break:break-word;color:rgb(255,255,255);font-size:12px;line-height:18px;text-align:center;padding:0px 18px 9px">
                                                                                    <em>Copyright Â© 2020 Seva Exchange, All rights reserved.</em><br><br><strong>Feel free to contact us at:</strong><br><a href="mailto:contact@sevaexchange.com " style="color:rgb(255,255,255) "
                                                                                        target="_blank ">info@sevaexchange.com</a><br><br><a href="https://sevaxapp.com/PrivacyPolicy.html" target="_blank" style="color:rgb(255,255,255);">Privacy Policy&nbsp;</a>&nbsp;<br>
                                                                                </td>
                                                                                    </tr>
                                                                                </tbody>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
    
                                </tbody>
                            </table>
                        </td>
    
                </tbody>
            </table>
        </div>
    </body>
  </html> """,
    ));
  } //Label to be confirmed

  // requestCreatorName + ' from ' + communityName + ' has invited you',
  //     mailContent: 'You have been invited to instruct ' +
  //         requestName +
  //         ' from ' +
  //         DateTime.fromMillisecondsSinceEpoch(startDate)
  //             .toString()
  //             .substring(0, 11) +
  //         ' to ' +
  //         DateTime.fromMillisecondsSinceEpoch(endDate)
  //             .toString()
  //             .substring(0, 11) +

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

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).updating_request),
            content: LinearProgressIndicator(),
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
    var requestCoins = widget.requestModel.numberOfHours;
    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
    return requestCoins <= finalbalance;
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty && !widget.requestModel.isRecurring) {
      ProjectModel projectModel = widget.projectModel;
//      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
//      if (!projectModel.members.contains(userSevaUserId)) {
//        projectModel.members.add(userSevaUserId);
//      }
      projectModel.pendingRequests.add(widget.requestModel.id);
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
}

class ProjectSelection extends StatefulWidget {
  ProjectSelection(
      {Key key,
      this.requestModel,
      this.admin,
      this.projectModelList,
      this.selectedProject,
      this.updateProjectIdCallback})
      : super(key: key);
  final admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;
  Function(String projectId) updateProjectIdCallback;

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  ProjectModel selectedModel = ProjectModel();
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    // log('Project Model Check:  ' + widget.projectModelList.toString());
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
    // log('Model List:  ' + list.toString());
    // log('Project Id:  ' + widget.requestModel.projectId.toString());
    return MultiSelect(
      autovalidate: true,
      initialValue: [
        widget.selectedProject != null ? widget.selectedProject.id : 'None'
      ],
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
          //widget.requestModel.projectId = value[0];
          widget.updateProjectIdCallback(value[0]);
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }

//  void _onFormSaved() {
//    final FormState form = _formKey.currentState;
//    form.save();
//  }
}

typedef StringMapCallback = void Function(Map<String, dynamic> goods);

class GoodsDynamicSelection2 extends StatefulWidget {
  final bool automaticallyImplyLeading;
  Map<String, String> goodsbefore;
  final StringMapCallback onSelectedGoods;

  GoodsDynamicSelection2(
      {this.goodsbefore,
      @required this.onSelectedGoods,
      this.automaticallyImplyLeading = true});
  @override
  _GoodsDynamicSelection2State createState() => _GoodsDynamicSelection2State();
}

class _GoodsDynamicSelection2State extends State<GoodsDynamicSelection2> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  bool autovalidate = false;
  Map<String, String> goods = {};
  Map<String, String> _selectedGoods = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    this._selectedGoods = widget.goodsbefore != null ? widget.goodsbefore : {};
    Firestore.instance
        .collection('donationCategories')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.documentID);
        goods[data.documentID] = data['goodTitle'];

        // ids[data['name']] = data.documentID;
      });
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            //TODOSUGGESTION
            TypeAheadField<SuggestedItem>(
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorBuilder: (context, err) {
                  return Text(S.of(context).error_occured);
                },
                hideOnError: true,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: S.of(context).search,
                    filled: true,
                    fillColor: Colors.grey[300],
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: InkWell(
                      splashColor: Colors.transparent,
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _textEditingController.clear();
                        controller.close();
                      },
                    ),
                  ),
                ),
                suggestionsBoxController: controller,
                suggestionsCallback: (pattern) async {
                  List<SuggestedItem> dataCopy = [];
                  goods.forEach(
                    (k, v) => dataCopy.add(SuggestedItem()
                      ..suggestionMode = SuggestionMode.FROM_DB
                      ..suggesttionTitle = v),
                  );
                  dataCopy.retainWhere((s) => s.suggesttionTitle
                      .toLowerCase()
                      .contains(pattern.toLowerCase()));
                  if (pattern.length > 2 &&
                      !dataCopy.contains(
                          SuggestedItem()..suggesttionTitle = pattern)) {
                    var spellCheckResult =
                        await SpellCheckManager.evaluateSpellingFor(pattern,
                            language:
                                SevaCore.of(context).loggedInUser.language ??
                                    'en');
                    if (spellCheckResult.hasErros) {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    } else if (spellCheckResult.correctSpelling != pattern) {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.SUGGESTED
                        ..suggesttionTitle = spellCheckResult.correctSpelling);

                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    } else {
                      dataCopy.add(SuggestedItem()
                        ..suggestionMode = SuggestionMode.USER_DEFINED
                        ..suggesttionTitle = pattern);
                    }
                  }
                  return await Future.value(dataCopy);
                },
                itemBuilder: (context, suggestedItem) {
                  switch (suggestedItem.suggestionMode) {
                    case SuggestionMode.FROM_DB:
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          suggestedItem.suggesttionTitle,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      );

                    case SuggestionMode.SUGGESTED:
                      if (ProfanityDetector()
                          .isProfaneString(suggestedItem.suggesttionTitle)) {
                        return ProfanityDetector.getProanityAdvisory(
                          suggestion: suggestedItem.suggesttionTitle,
                          suggestionMode: SuggestionMode.SUGGESTED,
                          context: context,
                        );
                      }
                      return searchUserDefinedEntity(
                        keyword: suggestedItem.suggesttionTitle,
                        language: 'en',
                        suggestionMode: suggestedItem.suggestionMode,
                        showLoader: true,
                      );

                    case SuggestionMode.USER_DEFINED:
                      if (ProfanityDetector()
                          .isProfaneString(suggestedItem.suggesttionTitle)) {
                        return ProfanityDetector.getProanityAdvisory(
                          suggestion: suggestedItem.suggesttionTitle,
                          suggestionMode: SuggestionMode.USER_DEFINED,
                          context: context,
                        );
                      }

                      return searchUserDefinedEntity(
                        keyword: suggestedItem.suggesttionTitle,
                        language: 'en',
                        suggestionMode: suggestedItem.suggestionMode,
                        showLoader: false,
                      );

                    default:
                      return Container();
                  }
                },
                noItemsFoundBuilder: (context) {
                  return searchUserDefinedEntity(
                    keyword: _textEditingController.text,
                    language: 'en',
                    showLoader: false,
                  );
                },
                onSuggestionSelected: (SuggestedItem suggestion) {
                  if (ProfanityDetector()
                      .isProfaneString(suggestion.suggesttionTitle)) {
                    return;
                  }

                  switch (suggestion.suggestionMode) {
                    case SuggestionMode.SUGGESTED:
                      var newGoodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: newGoodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[newGoodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.USER_DEFINED:
                      var goodId = Uuid().generateV4();
                      addGoodsToDb(
                        goodsId: goodId,
                        goodsLanguage: 'en',
                        goodsTitle: suggestion.suggesttionTitle,
                      );
                      goods[goodId] = suggestion.suggesttionTitle;
                      break;

                    case SuggestionMode.FROM_DB:
                      break;
                  }
                  // controller.close();

                  _textEditingController.clear();
                  if (!_selectedGoods.containsValue(suggestion)) {
                    controller.close();
                    String id = goods.keys.firstWhere(
                      (k) => goods[k] == suggestion.suggesttionTitle,
                    );
                    _selectedGoods[id] = suggestion.suggesttionTitle;
                    widget.onSelectedGoods(_selectedGoods);
                    setState(() {});
                  }
                }
                // onSuggestionSelected: (suggestion) {
                //   _textEditingController.clear();
                //   if (!_selectedGoods.containsValue(suggestion)) {
                //     controller.close();
                //     String id =
                //         goods.keys.firstWhere((k) => goods[k] == suggestion);
                //     _selectedGoods[id] = suggestion;
                //     widget.onSelectedGoods(_selectedGoods);
                //     setState(() {});
                //   }
                // },
                ),

            SizedBox(height: 20),
            !isDataLoaded
                ? LoadingIndicator()
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Wrap(
                          runSpacing: 5.0,
                          spacing: 5.0,
                          children: _selectedGoods.values
                              .toList()
                              .map(
                                (value) => value == null
                                    ? Container()
                                    : CustomChip(
                                        title: value,
                                        onDelete: () {
                                          String id =
                                              _selectedGoods.keys.firstWhere(
                                            (k) {
                                              return _selectedGoods[k] == value;
                                            },
                                          );
                                          _selectedGoods.remove(id);
                                          widget
                                              .onSelectedGoods(_selectedGoods);
                                          setState(() {});
                                        },
                                      ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
            //   Spacer(),
          ],
        ));
  }

  // FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
  //   String keyword,
  //   String language,
  // }) {
  //   return FutureBuilder<SpellCheckResult>(
  //     future: SpellCheckManager.evaluateSpellingFor(
  //       keyword,
  //       language: language,
  //     ),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return getLinearLoading;
  //       }

  //       return getSuggestionLayout(
  //         suggestion:
  //             !snapshot.data.hasErros ? snapshot.data.correctSpelling : keyword,
  //       );
  //     },
  //   );
  // }

  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String keyword,
    String language,
    SuggestionMode suggestionMode,
    bool showLoader,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoader ? getLinearLoading : LinearProgressIndicator();
        }

        return getSuggestionLayout(
          suggestion: keyword,
          suggestionMode: suggestionMode,
        );
      },
    );
  }

  Widget get getLinearLoading {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Future<void> addGoodsToDb({
    String goodsId,
    String goodsTitle,
    String goodsLanguage,
  }) async {
    await Firestore.instance
        .collection('donationCategories')
        .document(goodsId)
        .setData(
      {'goodTitle': goodsTitle, 'lang': goodsLanguage},
    );
  }

  Padding getSuggestionLayout({
    String suggestion,
    SuggestionMode suggestionMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          height: 40,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: S.of(context).add + ' ',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: "\"${suggestion}\"",
                            style: suggestionMode == SuggestionMode.SUGGESTED
                                ? TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  )
                                : TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                    decorationStyle: TextDecorationStyle.wavy,
                                    decorationThickness: 1.5,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      suggestionMode == SuggestionMode.SUGGESTED
                          ? S.of(context).suggested
                          : S.of(context).you_entered,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add,
                color: Colors.grey,
              ),
            ],
          )),
    );
  }
// Padding getSuggestionLayout({
//   String suggestion,
// }) {
//   return Padding(
//     padding: const EdgeInsets.all(18.0),
//     child: GestureDetector(
//       onTap: () async {
//         _textEditingController.clear();
//         controller.close();
//         var goodsId = Uuid().generateV4();
//         await addGoodsToDb(
//           goodsId: goodsId,
//           goodsLanguage: 'en',
//           goodsTitle: suggestion,
//         );
//         goods[goodsId] = suggestion;

//         if (!_selectedGoods.containsValue(suggestion)) {
//           controller.close();
//           String id = goods.keys.firstWhere((k) => goods[k] == suggestion);
//           _selectedGoods[id] = suggestion;
//           setState(() {});
//         }
//       },
//       child: Container(
//           height: 40,
//           alignment: Alignment.centerLeft,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "${S.of(context).add.toUpperCase()} \"${suggestion}\"",
//                       style: TextStyle(fontSize: 16, color: Colors.blue),
//                     ),
//                     Text(
//                       S.of(context).no_data,
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.add,
//                 color: Colors.grey,
//               ),
//             ],
//           )),
//     ),
//   );
// }
}

enum TotalCreditseMode { EDIT_MODE, CREATE_MODE }
