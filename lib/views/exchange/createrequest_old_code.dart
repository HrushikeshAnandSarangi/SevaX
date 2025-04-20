// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:rxdart/subjects.dart';
// import 'package:sevaexchange/components/ProfanityDetector.dart';
// import 'package:sevaexchange/components/calendar_events/models/kloudless_models.dart';
// import 'package:sevaexchange/components/calendar_events/module/index.dart';
// import 'package:sevaexchange/components/common_help_icon.dart';
// import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
// import 'package:sevaexchange/components/goods_dynamic_selection_createRequest.dart';
// import 'package:sevaexchange/components/pdf_screen.dart';
// import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/labels.dart';
// import 'package:sevaexchange/models/basic_user_details.dart';
// import 'package:sevaexchange/models/cash_model.dart';
// import 'package:sevaexchange/models/category_model.dart';
// import 'package:sevaexchange/models/enums/help_context_enums.dart';
// import 'package:sevaexchange/models/location_model.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/models/selectedSpeakerTimeDetails.dart';
// import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
// import 'package:sevaexchange/new_baseline/models/community_model.dart';
// import 'package:sevaexchange/new_baseline/models/project_model.dart';
// import 'package:sevaexchange/new_baseline/models/user_insufficient_credits_model.dart';
// import 'package:sevaexchange/repositories/firestore_keys.dart';
// import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
// import 'package:sevaexchange/ui/screens/request/widgets/skills_for_requests_widget.dart';
// import 'package:sevaexchange/ui/utils/date_formatter.dart';
// import 'package:sevaexchange/ui/utils/debouncer.dart';
// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
// import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
// import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
// import 'package:sevaexchange/utils/extensions.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/utils/helpers/configuration_check.dart';
// import 'package:sevaexchange/utils/helpers/mailer.dart';
// import 'package:sevaexchange/utils/helpers/projects_helper.dart';
// import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
// import 'package:sevaexchange/utils/log_printer/log_printer.dart';
// import 'package:sevaexchange/utils/soft_delete_manager.dart';
// import 'package:sevaexchange/utils/svea_credits_manager.dart';
// import 'package:sevaexchange/utils/utils.dart' as utils;
// import 'package:sevaexchange/utils/utils.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/exchange/edit_request_old_code.dart';
// import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
// import 'package:sevaexchange/views/messages/list_members_timebank.dart';
// import 'package:sevaexchange/views/requests/onetomany_request_instructor_card.dart';
// import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
// import 'package:sevaexchange/views/workshop/direct_assignment.dart';
// import 'package:sevaexchange/widgets/add_images_for_request.dart';
// import 'package:sevaexchange/widgets/custom_buttons.dart';
// import 'package:sevaexchange/widgets/custom_info_dialog.dart';
// import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
// import 'package:sevaexchange/widgets/hide_widget.dart';
// import 'package:sevaexchange/widgets/location_picker_widget.dart';
// import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
// import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
// import 'package:sevaexchange/widgets/select_category.dart';
// import 'package:sevaexchange/widgets/user_profile_image.dart';

// import '../../labels.dart';

// class CreateRequest extends StatefulWidget {
//   final bool isOfferRequest;
//   final OfferModel offer;
//   final String timebankId;
//   final UserModel userModel;
//   final ProjectModel projectModel;
//   final String projectId;
//   final ComingFrom comingFrom;

//   CreateRequest({
//     Key key,
//     @required this.comingFrom,
//     this.isOfferRequest,
//     this.offer,
//     this.timebankId,
//     this.userModel,
//     this.projectId,
//     this.projectModel,
//   }) : super(key: key);

//   @override
//   _CreateRequestState createState() => _CreateRequestState();
// }

// class _CreateRequestState extends State<CreateRequest> {
//   @override
//   Widget build(BuildContext context) {
//     return ExitWithConfirmation(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: Text(
//             _title,
//             style: TextStyle(fontSize: 18),
//           ),
//           centerTitle: false,
//           actions: [
//             CommonHelpIconWidget(),
//           ],
//         ),
//         body: StreamBuilder<UserModelController>(
//           stream: userBloc.getLoggedInUser,
//           builder: (context, snapshot) {
//             if (snapshot.hasError)
//               return Text(
//                 S.of(context).general_stream_error,
//               );
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return LoadingIndicator();
//             }
//             if (snapshot.data != null) {
//               return RequestCreateForm(
//                 comingFrom: widget.comingFrom,
//                 isOfferRequest:
//                     widget.offer != null ? widget.isOfferRequest : false,
//                 offer: widget.offer,
//                 timebankId: widget.timebankId,
//                 userModel: widget.userModel,
//                 loggedInUser: snapshot.data.loggedinuser,
//                 projectId: widget.projectId,
//                 projectModel: widget.projectModel,
//               );
//             }
//             return Text('');
//           },
//         ),
//       ),
//     );
//   }

//   String get _title {
//     if (widget.projectId == null ||
//         widget.projectId.isEmpty ||
//         widget.projectId == "") {
//       return S.of(context).create_request;
//     }
//     return S.of(context).create_project_request;
//   }
// }

// class RequestCreateForm extends StatefulWidget {
//   final bool isOfferRequest;
//   final OfferModel offer;
//   final String timebankId;
//   final UserModel userModel;
//   final UserModel loggedInUser;
//   final ProjectModel projectModel;
//   final String projectId;
//   final ComingFrom comingFrom;

//   RequestCreateForm({
//     this.isOfferRequest = false,
//     @required this.comingFrom,
//     this.offer,
//     this.timebankId,
//     this.userModel,
//     @required this.loggedInUser,
//     this.projectId,
//     this.projectModel,
//   });

//   @override
//   RequestCreateFormState createState() {
//     return RequestCreateFormState();
//   }
// }

// class RequestCreateFormState extends State<RequestCreateForm>
//     with WidgetsBindingObserver {
//   final _formKey = GlobalKey<FormState>();
//   final hoursTextFocus = FocusNode();
//   final volunteersTextFocus = FocusNode();
//   ProjectModel selectedProjectModel = null;
//   RequestModel requestModel;
//   bool isPulicCheckboxVisible = false;
//   End end = End();
//   var focusNodes = List.generate(18, (_) => FocusNode());
//   List<String> eventsIdsArr = [];
//   List<String> selectedCategoryIds = [];
//   bool comingFromDynamicLink = false;
//   GeoFirePoint location;

//   double sevaCoinsValue = 0;
//   String hoursMessage;
//   String selectedAddress;
//   int sharedValue = 0;
//   final _debouncer = Debouncer(milliseconds: 500);

//   String _selectedTimebankId;

//   final TextEditingController searchTextController = TextEditingController();
//   final searchOnChange = BehaviorSubject<String>();
//   final _textUpdates = StreamController<String>();
//   var validItems = [];
//   bool isAdmin = false;
//   UserModel selectedInstructorModel;
//   SelectedSpeakerTimeDetails selectedSpeakerTimeDetails =
//       new SelectedSpeakerTimeDetails(speakingTime: 0.0, prepTime: 0);
//   DocumentReference speakerNotificationDocRef;

//   //Below variable for One to Many Requests
//   bool createEvent = false;
//   bool instructorAdded = false;

//   //Borrow request fields below
//   // String borrowAgreementLinkFinal = '';
//   // String documentName = '';

//   //Below variable for Borrow Requests
//   int roomOrTool = 0;

//   Future<TimebankModel> getTimebankAdminStatus;
//   Future<List<ProjectModel>> getProjectsByFuture;
//   TimebankModel timebankModel;
//   final profanityDetector = ProfanityDetector();

//   RegExp regExp = RegExp(
//     r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
//     caseSensitive: false,
//     multiLine: false,
//   );

//   CommunityModel communityModel;

//   @override
//   void initState() {
//     super.initState();

//     String _searchText = "";

//     AppConfig.helpIconContextMember = HelpContextMemberType.time_requests;

//     WidgetsBinding.instance.addObserver(this);
//     _selectedTimebankId = widget.timebankId;

//     getProjectsByFuture =
//         FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

//     requestModel = RequestModel(
//         requestType: RequestType.TIME,
//         cashModel: CashModel(
//             paymentType: RequestPaymentType.ZELLEPAY,
//             achdetails: new ACHModel()),
//         goodsDonationDetails: GoodsDonationDetails(),
//         communityId: widget.loggedInUser.currentCommunity,
//         oneToManyRequestAttenders: [],
//         timebankId: widget.timebankId);
//     this.requestModel.virtualRequest = false;
//     this.requestModel.public = false;
//     this.requestModel.timebankId = _selectedTimebankId;
//     this.requestModel.public = false;
//     this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//     this.requestModel.projectId = widget.projectId;

//     if (widget.isOfferRequest ?? false) {
//       requestModel.requestType = widget.offer.type;
//       requestModel.goodsDonationDetails.requiredGoods =
//           widget.offer.goodsDonationDetails.requiredGoods;
//     }

//     getTimebankAdminStatus = getTimebankDetailsbyFuture(
//       timebankId: _selectedTimebankId,
//     );
//     fetchRemoteConfig();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       selectedInstructorModel = SevaCore.of(context).loggedInUser;

//       FirestoreManager.getAllTimebankIdStream(
//         timebankId: widget.timebankId,
//       ).then((onValue) {
//         setState(() {
//           validItems = onValue.listOfElement;
//           timebankModel = onValue.timebankModel;
//         });
//         if (isAccessAvailable(timebankModel, widget.loggedInUser.sevaUserID)) {
//           isAdmin = true;
//         }
//       });
//       // executes after build
//     });

//     searchTextController.addListener(() {
//       _debouncer.run(() {
//         String s = searchTextController.text;

//         if (s.isEmpty) {
//           setState(() {
//             _searchText = "";
//           });
//         } else {
//           setState(() {
//             _searchText = s;
//           });
//         }
//       });
//     });

//     // if ((FlavorConfig.appFlavor == Flavor.APP ||
//     //     FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
//     // _fetchCurrentlocation;
//     // }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed && comingFromDynamicLink) {
//       Navigator.of(context).pop();
//     }
//   }

//   Future<void> fetchRemoteConfig() async {
//     AppConfig.remoteConfig = await RemoteConfig.instance;
//     AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
//     AppConfig.remoteConfig.activateFetched();
//   }

//   @override
//   void didChangeDependencies() {
//     if (widget.loggedInUser?.sevaUserID != null)
//       FirestoreManager.getUserForIdStream(
//               sevaUserId: widget.loggedInUser.sevaUserID)
//           .listen((userModel) {});
//     super.didChangeDependencies();
//   }

//   TextStyle hintTextStyle = TextStyle(
//     fontSize: 14,
//     // fontWeight: FontWeight.bold,
//     color: Colors.grey,
//     fontFamily: 'Europa',
//   );

//   Widget addToProjectContainer(snapshot, projectModelList, requestModel) {
//     if (snapshot.hasError) return Text(snapshot.error.toString());
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Container();
//     }
//     timebankModel = snapshot.data;
//     if (isAccessAvailable(
//             snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID) &&
//         requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
//                   createEvent)
//               ? Container()
//               : Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Flexible(
//                       child: ProjectSelection(
//                         setcreateEventState: () {
//                           createEvent = !createEvent;
//                           setState(() {});
//                         },
//                         createEvent: createEvent,
//                         requestModel: requestModel,
//                         projectModelList: projectModelList,
//                         selectedProject: null,
//                         admin: isAccessAvailable(snapshot.data,
//                             SevaCore.of(context).loggedInUser.sevaUserID),
//                       ),
//                     ),
//                   ],
//                 ),
//           createEvent
//               ? GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       createEvent = !createEvent;
//                       requestModel.projectId = '';
//                       log('projectId2:  ' + requestModel.projectId.toString());
//                       log('createEvent2:  ' + createEvent.toString());
//                     });
//                   },
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_box, size: 19, color: Colors.green),
//                       SizedBox(width: 5),
//                       Expanded(
//                         child: Text(
//                           S.of(context).onetomanyrequest_create_new_event,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Container(),
//         ],
//       );
//     } else {
//       this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//       this.requestModel.requestType = RequestType.TIME;

//       //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//       instructorAdded = false;
//       requestModel.selectedInstructor = null;

//       return Container();
//       // return ProjectSelection(
//       //   requestModel: requestModel,
//       //   projectModelList: projectModelList,
//       //   selectedProject: null,
//       //   admin: false,
//       // );
//     }
//   }

//   void updateExitWithConfirmationValue(
//       BuildContext context, int index, String value) {
//     ExitWithConfirmation.of(context).fieldValues[index] = value;
//   }

//   Widget headerContainer(snapshot) {
//     if (snapshot.hasError) return Text(snapshot.error.toString());
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Container();
//     }
//     timebankModel = snapshot.data;
//     if (isAccessAvailable(
//         snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID)) {
//       return requestSwitch(
//         timebankModel: timebankModel,
//       );
//     } else {
//       this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//       requestModel.requestType = RequestType.TIME;

//       //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//       // setState(() {
//       //   instructorAdded = false;
//       //   requestModel.selectedInstructor = null;
//       // });

//       // this.requestModel.requestType = RequestType.TIME;
//       return Container();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     logger.e('CREATE EVENT STATUS: ' + createEvent.toString());
//     hoursMessage = S.of(context).set_duration;
//     UserModel loggedInUser = SevaCore.of(context).loggedInUser;
//     this.requestModel.email = loggedInUser.email;
//     this.requestModel.sevaUserId = loggedInUser.sevaUserID;
//     this.requestModel.communityId = loggedInUser.currentCommunity;
//     log("=========>>>>>>>  FROM CREATE STATE ${this.requestModel.communityId} ");

//     log('REQUEST TYPE:  ' + requestModel.requestType.toString());
//     log('ID timebank ' + requestModel.timebankId.toString());

//     return FutureBuilder<TimebankModel>(
//         future: getTimebankAdminStatus,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return LoadingIndicator();
//           }
//           return FutureBuilder<List<ProjectModel>>(
//               future: getProjectsByFuture,
//               builder: (projectscontext, projectListSnapshot) {
//                 if (!projectListSnapshot.hasData) {
//                   return Container();
//                 }

//                 List<ProjectModel> projectModelList = projectListSnapshot.data;

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(
//                     child: SizedBox(
//                       height: 48,
//                       width: 48,
//                       child: CircularProgressIndicator(),
//                     ),
//                   );
//                 } else if (snapshot.hasError) {
//                   return Text(S.of(context).error_loading_data);
//                 } else {
//                   selectedAddress = snapshot.data.address;
//                   location = snapshot.data.location;
//                   return Form(
//                     key: _formKey,
//                     child: Container(
//                       padding: EdgeInsets.all(20.0),
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               headerContainer(snapshot),
// //                            TransactionsMatrixCheck(transaction_matrix_type: "cash_goods_requests", child: RequestTypeWidget()),

//                               RequestTypeWidgetCommunityRequests(),

//                               RequestTypeWidgetPersonalRequests(),

//                               SizedBox(height: 14),

//                               Text(
//                                 "${S.of(context).request_title}",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'Europa',
//                                   color: Colors.black,
//                                 ),
//                               ),
//                               TextFormField(
//                                 autovalidateMode:
//                                     AutovalidateMode.onUserInteraction,
//                                 onChanged: (value) {
//                                   updateExitWithConfirmationValue(
//                                       context, 1, value);
//                                 },
//                                 onFieldSubmitted: (v) {
//                                   FocusScope.of(context)
//                                       .requestFocus(focusNodes[0]);
//                                 },
//                                 // inputFormatters: <TextInputFormatter>[
//                                 //   WhitelistingTextInputFormatter(
//                                 //       RegExp("[a-zA-Z0-9_ ]*"))
//                                 // ],
//                                 decoration: InputDecoration(
//                                   errorMaxLines: 2,
//                                   hintText: requestModel.requestType ==
//                                           RequestType.TIME
//                                       ? S.of(context).request_title_hint
//                                       : requestModel.requestType ==
//                                               RequestType.CASH
//                                           ? S
//                                               .of(context)
//                                               .cash_request_title_hint
//                                           : requestModel.requestType ==
//                                                   RequestType
//                                                       .ONE_TO_MANY_REQUEST
//                                               ? S
//                                                   .of(context)
//                                                   .onetomanyrequest_title_hint
//                                               : requestModel.requestType ==
//                                                       RequestType.BORROW
//                                                   ? S
//                                                       .of(context)
//                                                       .request_title_hint
//                                                   : "Ex: Non-perishable goods for Food Bank...",
//                                   hintStyle: hintTextStyle,
//                                 ),
//                                 textInputAction: TextInputAction.next,
//                                 keyboardType: TextInputType.text,
//                                 initialValue: widget.offer != null &&
//                                         widget.isOfferRequest
//                                     ? getOfferTitle(
//                                         offerDataModel: widget.offer,
//                                       )
//                                     : "",
//                                 textCapitalization:
//                                     TextCapitalization.sentences,
//                                 validator: (value) {
//                                   if (value.isEmpty) {
//                                     return S.of(context).request_subject;
//                                   } else if (profanityDetector
//                                       .isProfaneString(value)) {
//                                     return S.of(context).profanity_text_alert;
//                                   } else if (value
//                                           .substring(0, 1)
//                                           .contains('_') &&
//                                       !AppConfig.testingEmails
//                                           .contains(AppConfig.loggedInEmail)) {
//                                     return S
//                                         .of(context)
//                                         .creating_request_with_underscore_not_allowed;
//                                   } else {
//                                     requestModel.title = value;
//                                     return null;
//                                   }
//                                 },
//                               ),

//                               SizedBox(height: 15),

//                               //Instructor to be assigned to One to many requests widget Here

//                               instructorAdded
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(height: 20),
//                                         Text(
//                                           S.of(context).selected_speaker,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             fontFamily: 'Europa',
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         SizedBox(height: 15),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 0, right: 10),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.center,
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               // SizedBox(
//                                               //   height: 15,
//                                               // ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.start,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   UserProfileImage(
//                                                     photoUrl: requestModel
//                                                         .selectedInstructor
//                                                         .photoURL,
//                                                     email: requestModel
//                                                         .selectedInstructor
//                                                         .email,
//                                                     userId: requestModel
//                                                         .selectedInstructor
//                                                         .sevaUserID,
//                                                     height: 75,
//                                                     width: 75,
//                                                     timebankModel:
//                                                         timebankModel,
//                                                   ),
//                                                   SizedBox(
//                                                     width: 15,
//                                                   ),
//                                                   Expanded(
//                                                     child: Text(
//                                                       requestModel
//                                                               .selectedInstructor
//                                                               .fullname ??
//                                                           S
//                                                               .of(context)
//                                                               .name_not_available,
//                                                       style: TextStyle(
//                                                           color: Colors.black,
//                                                           fontSize: 18,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     width: 15,
//                                                   ),
//                                                   Container(
//                                                     height: 37,
//                                                     padding: EdgeInsets.only(
//                                                         bottom: 0),
//                                                     child: InkWell(
//                                                       child: Icon(
//                                                         Icons.cancel_rounded,
//                                                         size: 30,
//                                                         color: Colors.grey,
//                                                       ),
//                                                       onTap: () {
//                                                         setState(() {
//                                                           instructorAdded =
//                                                               false;
//                                                           requestModel
//                                                                   .selectedInstructor =
//                                                               null;
//                                                         });
//                                                       },
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : requestModel.requestType ==
//                                           RequestType.ONE_TO_MANY_REQUEST
//                                       ? Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                               SizedBox(height: 20),
//                                               Text(
//                                                 S.of(context).select_a_speaker,
//                                                 style: TextStyle(
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontFamily: 'Europa',
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                               SizedBox(height: 15),
//                                               TextField(
//                                                 style: TextStyle(
//                                                     color: Colors.black),
//                                                 controller:
//                                                     searchTextController,
//                                                 onChanged: _search,
//                                                 autocorrect: true,
//                                                 decoration: InputDecoration(
//                                                   suffixIcon: IconButton(
//                                                       icon: Icon(
//                                                         Icons.clear,
//                                                         color: Colors.black54,
//                                                       ),
//                                                       onPressed: () {
//                                                         setState(() {
//                                                           searchTextController
//                                                               .clear();
//                                                         });
//                                                       }),
//                                                   alignLabelWithHint: true,
//                                                   isDense: true,
//                                                   prefixIcon: Icon(
//                                                     Icons.search,
//                                                     color: Colors.grey,
//                                                   ),
//                                                   contentPadding:
//                                                       EdgeInsets.fromLTRB(10.0,
//                                                           12.0, 10.0, 5.0),
//                                                   filled: true,
//                                                   fillColor: Colors.grey[200],
//                                                   focusedBorder:
//                                                       OutlineInputBorder(
//                                                     borderSide: BorderSide(
//                                                         color: Colors.white),
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15.7),
//                                                   ),
//                                                   enabledBorder:
//                                                       UnderlineInputBorder(
//                                                           borderSide:
//                                                               BorderSide(
//                                                                   color: Colors
//                                                                       .white),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(
//                                                                       15.7)),
//                                                   hintText: S
//                                                       .of(context)
//                                                       .select_speaker_hint,
//                                                   hintStyle: TextStyle(
//                                                     color: Colors.black45,
//                                                     fontSize: 14,
//                                                   ),
//                                                   floatingLabelBehavior:
//                                                       FloatingLabelBehavior
//                                                           .never,
//                                                 ),
//                                               ),

//                                               //SizedBox(height: 5),

//                                               Container(
//                                                   child: Column(children: [
//                                                 StreamBuilder<List<UserModel>>(
//                                                   stream: SearchManager
//                                                       .searchUserInSevaX(
//                                                     queryString:
//                                                         searchTextController
//                                                             .text,
//                                                     //validItems: validItems,
//                                                   ),
//                                                   builder: (context, snapshot) {
//                                                     if (snapshot.hasError) {
//                                                       Text(snapshot.error
//                                                           .toString());
//                                                     }
//                                                     if (!snapshot.hasData) {
//                                                       return Center(
//                                                         child: SizedBox(
//                                                           height: 48,
//                                                           width: 40,
//                                                           child: Container(
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .only(
//                                                                     top: 12.0),
//                                                             child:
//                                                                 CircularProgressIndicator(),
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }

//                                                     List<UserModel> userList =
//                                                         snapshot.data;
//                                                     userList.removeWhere((user) =>
//                                                         user.sevaUserID ==
//                                                             SevaCore.of(context)
//                                                                 .loggedInUser
//                                                                 .sevaUserID ||
//                                                         user.sevaUserID ==
//                                                             requestModel
//                                                                 .sevaUserId);

//                                                     if (userList.length == 0) {
//                                                       return Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           // Container(
//                                                           //   width: MediaQuery.of(
//                                                           //               context)
//                                                           //           .size
//                                                           //           .width *
//                                                           //       0.85,
//                                                           //   height: MediaQuery.of(
//                                                           //               context)
//                                                           //           .size
//                                                           //           .width *
//                                                           //       0.15,
//                                                           //   child:
//                                                           Expanded(
//                                                             child: Card(
//                                                               shape:
//                                                                   RoundedRectangleBorder(
//                                                                 side: BorderSide(
//                                                                     color: Colors
//                                                                         .transparent,
//                                                                     width: 0),
//                                                                 borderRadius: BorderRadius.vertical(
//                                                                     bottom: Radius
//                                                                         .circular(
//                                                                             7.0)),
//                                                               ),
//                                                               borderOnForeground:
//                                                                   false,
//                                                               shadowColor:
//                                                                   Colors
//                                                                       .white24,
//                                                               elevation: 5,
//                                                               child: Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .only(
//                                                                         left:
//                                                                             15.0,
//                                                                         top:
//                                                                             11.0),
//                                                                 child: Text(
//                                                                   S
//                                                                       .of(context)
//                                                                       .no_member_found,
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: Colors
//                                                                         .grey,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       );
//                                                     }

//                                                     if (searchTextController
//                                                             .text
//                                                             .trim()
//                                                             .length <
//                                                         3) {
//                                                       return Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           // Container(
//                                                           //   width: MediaQuery.of(
//                                                           //               context)
//                                                           //           .size
//                                                           //           .width *
//                                                           //       0.85,
//                                                           //   height: MediaQuery.of(
//                                                           //               context)
//                                                           //           .size
//                                                           //           .width *
//                                                           //       0.15,
//                                                           //   child:
//                                                           Expanded(
//                                                             child: Card(
//                                                               shape:
//                                                                   RoundedRectangleBorder(
//                                                                 side: BorderSide(
//                                                                     color: Colors
//                                                                         .transparent,
//                                                                     width: 0),
//                                                                 borderRadius: BorderRadius.vertical(
//                                                                     bottom: Radius
//                                                                         .circular(
//                                                                             7.0)),
//                                                               ),
//                                                               borderOnForeground:
//                                                                   false,
//                                                               shadowColor:
//                                                                   Colors
//                                                                       .white24,
//                                                               elevation: 5,
//                                                               child: Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .only(
//                                                                         left:
//                                                                             15.0,
//                                                                         top:
//                                                                             11.0),
//                                                                 child: Text(
//                                                                   S
//                                                                       .of(context)
//                                                                       .validation_error_search_min_characters,
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: Colors
//                                                                         .grey,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       );
//                                                     } else {
//                                                       return Scrollbar(
//                                                         child: Center(
//                                                           child: Card(
//                                                             shape:
//                                                                 RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors
//                                                                       .transparent,
//                                                                   width: 0),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           10),
//                                                             ),
//                                                             borderOnForeground:
//                                                                 false,
//                                                             shadowColor:
//                                                                 Colors.white24,
//                                                             elevation: 5,
//                                                             child: LimitedBox(
//                                                               maxHeight:
//                                                                   MediaQuery.of(
//                                                                               context)
//                                                                           .size
//                                                                           .width *
//                                                                       0.55,
//                                                               maxWidth: 90,
//                                                               child: ListView
//                                                                   .separated(
//                                                                       primary:
//                                                                           false,
//                                                                       //physics: NeverScrollableScroflutter card bordellPhysics(),
//                                                                       shrinkWrap:
//                                                                           true,
//                                                                       padding:
//                                                                           EdgeInsets
//                                                                               .zero,
//                                                                       itemCount:
//                                                                           userList
//                                                                               .length,
//                                                                       separatorBuilder:
//                                                                           (BuildContext context, int index) =>
//                                                                               Divider(),
//                                                                       itemBuilder:
//                                                                           (context,
//                                                                               index) {
//                                                                         UserModel
//                                                                             user =
//                                                                             userList[index];

//                                                                         List<String>
//                                                                             timeBankIds =
//                                                                             snapshot.data[index].favoriteByTimeBank ??
//                                                                                 [];
//                                                                         List<String>
//                                                                             memberId =
//                                                                             user.favoriteByMember ??
//                                                                                 [];

//                                                                         return OneToManyInstructorCard(
//                                                                           userModel:
//                                                                               user,
//                                                                           timebankModel:
//                                                                               timebankModel,
//                                                                           isAdmin:
//                                                                               isAdmin,
//                                                                           //refresh: refresh,
//                                                                           currentCommunity: SevaCore.of(context)
//                                                                               .loggedInUser
//                                                                               .currentCommunity,
//                                                                           loggedUserId: SevaCore.of(context)
//                                                                               .loggedInUser
//                                                                               .sevaUserID,
//                                                                           isFavorite: isAdmin
//                                                                               ? timeBankIds.contains(requestModel.timebankId)
//                                                                               : memberId.contains(SevaCore.of(context).loggedInUser.sevaUserID),
//                                                                           addStatus: S
//                                                                               .of(context)
//                                                                               .add,
//                                                                           onAddClick:
//                                                                               () {
//                                                                             setState(() {
//                                                                               selectedInstructorModel = user;
//                                                                               instructorAdded = true;
//                                                                               requestModel.selectedInstructor = BasicUserDetails(
//                                                                                 fullname: user.fullname,
//                                                                                 email: user.email,
//                                                                                 photoURL: user.photoURL,
//                                                                                 sevaUserID: user.sevaUserID,
//                                                                               );
//                                                                             });
//                                                                           },
//                                                                         );
//                                                                       }),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       );
//                                                     }
//                                                   },
//                                                 ),
//                                               ])),
//                                             ])
//                                       : Container(height: 0, width: 0),

//                               //Below is for testing purpose

//                               // SizedBox(height: 20),
//                               // requestModel.requestType == RequestType.BORROW
//                               //     ? Row(
//                               //         children: [
//                               //           GestureDetector(
//                               //             child: Text(
//                               //               'Go to agreement page',
//                               //               style: TextStyle(fontSize: 15),
//                               //             ),
//                               //             onTap: () {
//                               //               Navigator.push(
//                               //                 context,
//                               //                 MaterialPageRoute(
//                               //                     fullscreenDialog: true,
//                               //                     builder: (context) =>
//                               //                         RequestOfferAgreementForm(
//                               //                           isRequest: true,
//                               //                           roomOrTool:
//                               //                               roomOrTool == 1
//                               //                                   ? 'TOOL'
//                               //                                   : 'ROOM',
//                               //                           requestModel:
//                               //                               requestModel,
//                               //                           communityId: requestModel
//                               //                               .communityId,
//                               //                           timebankId:
//                               //                               widget.timebankId,
//                               //                           onPdfCreated: (pdfLink,
//                               //                               documentNameFinal) {
//                               //                             borrowAgreementLinkFinal =
//                               //                                 pdfLink;
//                               //                             documentName =
//                               //                                 documentNameFinal;
//                               //                             requestModel
//                               //                                     .borrowAgreementLink =
//                               //                                 pdfLink;
//                               //                             // when request is created check if above value is stored in document
//                               //                             setState(() => {});
//                               //                           },
//                               //                         )),
//                               //               );
//                               //             },
//                               //           ),
//                               //         ],
//                               //       )
//                               //     : Container(),
//                               // SizedBox(height: 12),

//                               // requestModel.requestType == RequestType.BORROW
//                               //     ? GestureDetector(
//                               //         child: Row(
//                               //           children: [
//                               //             Text(documentName != ''
//                               //                 ? 'view '
//                               //                 : ''),
//                               //             Text(
//                               //                 documentName != ''
//                               //                     ? documentName
//                               //                     : 'No Agreement Selected',
//                               //                 style: TextStyle(
//                               //                     fontWeight: FontWeight.w600,
//                               //                     color: documentName != ''
//                               //                         ? Theme.of(context)
//                               //                             .primaryColor
//                               //                         : Colors.grey)),
//                               //           ],
//                               //         ),
//                               //         onTap: () async {
//                               //           if (documentName != '') {
//                               //             await openPdfViewer(
//                               //                 borrowAgreementLinkFinal,
//                               //                 'test document',
//                               //                 context);
//                               //           } else {
//                               //             return null;
//                               //           }
//                               //         },
//                               //       )
//                               //     : Container(),

//                               requestModel.requestType == RequestType.BORROW
//                                   ? Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(height: 12),
//                                         Text(
//                                           S.of(context).borrow,
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             fontFamily: 'Europa',
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                         SizedBox(height: 10),
//                                         CupertinoSegmentedControl<int>(
//                                           unselectedColor: Colors.grey[200],
//                                           selectedColor:
//                                               Theme.of(context).primaryColor,
//                                           children: {
//                                             0: Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: 14, right: 14),
//                                               child: Text(
//                                                 S.of(context).need_a_place,
//                                                 style:
//                                                     TextStyle(fontSize: 12.0),
//                                               ),
//                                             ),
//                                             1: Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: 14, right: 14),
//                                               child: Text(
//                                                 S.of(context).item,
//                                                 style:
//                                                     TextStyle(fontSize: 12.0),
//                                               ),
//                                             ),
//                                           },
//                                           borderColor: Colors.grey,
//                                           padding: EdgeInsets.only(
//                                               left: 0.0, right: 0.0),
//                                           groupValue: roomOrTool,
//                                           onValueChanged: (int val) {
//                                             if (val != roomOrTool) {
//                                               setState(() {
//                                                 if (val == 0) {
//                                                   roomOrTool = 0;
//                                                 } else {
//                                                   roomOrTool = 1;
//                                                 }
//                                                 roomOrTool = val;
//                                               });
//                                               log('Room or Tool: ' +
//                                                   roomOrTool.toString());
//                                             }
//                                           },
//                                           //groupValue: sharedValue,
//                                         ),
//                                       ],
//                                     )
//                                   : Container(),

//                               SizedBox(height: 30),

//                               OfferDurationWidget(
//                                 title: "${S.of(context).request_duration} *",
//                               ),

//                               requestModel.requestType == RequestType.TIME
//                                   ? TimeRequest(snapshot, projectModelList)
//                                   : requestModel.requestType == RequestType.CASH
//                                       ? CashRequest(snapshot, projectModelList)
//                                       : requestModel.requestType ==
//                                               RequestType.ONE_TO_MANY_REQUEST
//                                           ? TimeRequest(
//                                               snapshot, projectModelList)
//                                           : requestModel.requestType ==
//                                                   RequestType.BORROW
//                                               ? BorrowRequest(
//                                                   snapshot, projectModelList)
//                                               : GoodsRequest(
//                                                   snapshot, projectModelList),

//                               HideWidget(
//                                 hide: AppConfig.isTestCommunity,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 8),
//                                   child: ConfigurationCheck(
//                                     actionType: 'create_virtual_request',
//                                     role: memberType(
//                                         timebankModel,
//                                         SevaCore.of(context)
//                                             .loggedInUser
//                                             .sevaUserID),
//                                     child: OpenScopeCheckBox(
//                                         infoType: InfoType.VirtualRequest,
//                                         isChecked: requestModel.virtualRequest,
//                                         checkBoxTypeLabel:
//                                             CheckBoxType.type_VirtualRequest,
//                                         onChangedCB: (bool val) {
//                                           if (requestModel.virtualRequest !=
//                                               val) {
//                                             this.requestModel.virtualRequest =
//                                                 val;

//                                             if (!val) {
//                                               requestModel.public = false;
//                                               isPulicCheckboxVisible = false;
//                                             } else {
//                                               isPulicCheckboxVisible = true;
//                                             }

//                                             setState(() {});
//                                           }
//                                         }),
//                                   ),
//                                 ),
//                               ),
//                               HideWidget(
//                                 hide: !isPulicCheckboxVisible ||
//                                     requestModel.requestMode ==
//                                         RequestMode.PERSONAL_REQUEST ||
//                                     widget.timebankId ==
//                                         FlavorConfig.values.timebankId,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 10),
//                                   child: TransactionsMatrixCheck(
//                                     comingFrom: widget.comingFrom,
//                                     upgradeDetails: AppConfig
//                                         .upgradePlanBannerModel
//                                         .public_to_sevax_global,
//                                     transaction_matrix_type:
//                                         'create_public_request',
//                                     child: ConfigurationCheck(
//                                       actionType: 'create_public_request',
//                                       role: memberType(
//                                           timebankModel,
//                                           SevaCore.of(context)
//                                               .loggedInUser
//                                               .sevaUserID),
//                                       child: OpenScopeCheckBox(
//                                           infoType: InfoType.OpenScopeEvent,
//                                           isChecked: requestModel.public,
//                                           checkBoxTypeLabel:
//                                               CheckBoxType.type_Requests,
//                                           onChangedCB: (bool val) {
//                                             if (requestModel.public != val) {
//                                               this.requestModel.public = val;
//                                               setState(() {});
//                                             }
//                                           }),
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 30.0),
//                                 child: Center(
//                                   child: Container(
//                                     child: CustomElevatedButton(
//                                       onPressed: createRequest,
//                                       child: Text(
//                                         S
//                                             .of(context)
//                                             .create_request
//                                             .padLeft(10)
//                                             .padRight(10),
//                                         style: Theme.of(context)
//                                             .primaryTextTheme
//                                             .button,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//               });
//         });
//   }

//   void function(OfferModel offerModel) {
//     switch (offerModel.type) {
//       case RequestType.CASH:
//         //radio button cash
//         //prefrill offer title, offer description, pleged amount,

//         // TODO: Handle this case.
//         break;

//       case RequestType.TIME:
//         // TODO: Handle this case.
//         break;
//       case RequestType.GOODS:
//         //radio button goods
//         //prefrill offer title, offer description, pleged amount,

//         // TODO: Handle this case.
//         break;
//       case RequestType.BORROW:
//         // TODO: Handle this case.
//         break;
//       case RequestType.ONE_TO_MANY_REQUEST:
//         // TODO: Handle this case.
//         break;
//     }
//   }

//   Widget RequestGoodsDescriptionData() {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             S.of(context).request_goods_description,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           GoodsDynamicSelection(
//             selectedGoods: requestModel.goodsDonationDetails.requiredGoods,
//             onSelectedGoods: (goods) =>
//                 {requestModel.goodsDonationDetails.requiredGoods = goods},
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_goods_address,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           Text(
//             S.of(context).request_goods_address_hint,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey,
//             ),
//           ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 2, value);
//             },
//             focusNode: focusNodes[8],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[8]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: S.of(context).request_goods_address_inputhint,
//               hintStyle: hintTextStyle,
//             ),
//             keyboardType: TextInputType.multiline,
//             maxLines: 3,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else {
//                 requestModel.goodsDonationDetails.address = value;
// //                setState(() {});
//               }
//               return null;
//             },
//           ),
//         ]);
//   }

//   Widget RequestPaymentACH(RequestModel requestModel) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_payment_ach_bank_name,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 3, value);
//             },
//             focusNode: focusNodes[12],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[13]);
//             },
//             textInputAction: TextInputAction.next,
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else if (!value.isEmpty) {
//                 requestModel.cashModel.achdetails.bank_name = value;
//               } else {
//                 return S.of(context).enter_valid_bank_name;
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_payment_ach_bank_address,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 4, value);
//             },
//             focusNode: focusNodes[13],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[14]);
//             },
//             textInputAction: TextInputAction.next,
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else if (!value.isEmpty) {
//                 requestModel.cashModel.achdetails.bank_address = value;
//               } else {
//                 return S.of(context).enter_valid_bank_address;
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_payment_ach_routing_number,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             maxLength: 30,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 5, value);
//             },
//             focusNode: focusNodes[14],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[15]);
//             },
//             textInputAction: TextInputAction.next,
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else if (!value.isEmpty) {
//                 requestModel.cashModel.achdetails.routing_number = value;
//               } else {
//                 return S.of(context).enter_valid_routing_number;
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_payment_ach_account_no,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             maxLength: 30,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 6, value);
//             },
//             focusNode: focusNodes[15],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[15]);
//             },
//             textInputAction: TextInputAction.next,
//             initialValue: widget.offer != null && widget.isOfferRequest
//                 ? getOfferDescription(
//                     offerDataModel: widget.offer,
//                   )
//                 : "",
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else if (!value.isEmpty) {
//                 requestModel.cashModel.achdetails.account_number = value;
//               } else {
//                 return S.of(context).enter_valid_account_number;
//               }
//               return null;
//             },
//           )
//         ]);
//   }

//   Widget RequestPaymentZellePay() {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 7, value);
//             },
//             focusNode: focusNodes[12],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[12]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText:
//                   S.of(context).request_payment_descriptionZelle_inputhint,
//               hintStyle: hintTextStyle,
//             ),
//             // initialValue: widget.offer != null && widget.isOfferRequest
//             //     ? getOfferDescription(
//             //         offerDataModel: widget.offer,
//             //       )
//             //     : "",
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             onSaved: (value) {
//               requestModel.cashModel.zelleId = value;
//             },
//             validator: (value) {
//               requestModel.cashModel.zelleId = value;
//               return _validateEmailAndPhone(value);
//             },
//           )
//         ]);
//   }

//   String mobilePattern = r'^[0-9]+$';
//   RegExp emailPattern = RegExp(
//       r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//   String _validateEmailAndPhone(String value) {
//     RegExp regExp = RegExp(mobilePattern);
//     if (value.isEmpty) {
//       return S.of(context).validation_error_general_text;
//     } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
//       return null;
//     } else {
//       return S.of(context).enter_valid_link;
//     }
//   }

//   String _validateEmailId(String value) {
//     RegExp emailPattern = RegExp(
//         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//     if (value.isEmpty) return S.of(context).validation_error_general_text;
//     if (!emailPattern.hasMatch(value))
//       return S.of(context).validation_error_invalid_email;
//     return null;
//   }

//   Widget RequestPaymentPaypal(RequestModel requestModel) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 8, value);
//             },
//             focusNode: focusNodes[12],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[12]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: 'Ex: Paypal ID (phone or email)',
//               hintStyle: hintTextStyle,
//             ),
//             initialValue: widget.offer != null && widget.isOfferRequest
//                 ? getOfferDescription(
//                     offerDataModel: widget.offer,
//                   )
//                 : "",
//             keyboardType: TextInputType.emailAddress,
//             maxLines: 1,
//             onSaved: (value) {
//               requestModel.cashModel.paypalId = value;
//             },
//             validator: (value) {
//               RegExp regExp = RegExp(mobilePattern);
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else if (emailPattern.hasMatch(value) ||
//                   regExp.hasMatch(value)) {
//                 requestModel.cashModel.paypalId = value;
//                 return null;
//               } else {
//                 return S.of(context).enter_valid_link;
//               }
//             },
//           )
//         ]);
//   }

//   Widget RequestPaymentVenmo(RequestModel requestModel) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {},
//             focusNode: focusNodes[12],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[12]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: S.of(context).venmo_hint,
//               hintStyle: hintTextStyle,
//             ),
//             initialValue: widget.offer != null && widget.isOfferRequest
//                 ? getOfferDescription(
//                     offerDataModel: widget.offer,
//                   )
//                 : "",
//             keyboardType: TextInputType.emailAddress,
//             maxLines: 1,
//             onSaved: (value) {
//               requestModel.cashModel.venmoId = value;
//             },
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               } else {
//                 requestModel.cashModel.venmoId = value;
//                 return null;
//               }
//             },
//           )
//         ]);
//   }

//   Widget RequestPaymentSwift() {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               updateExitWithConfirmationValue(context, 7, value);
//             },
//             focusNode: focusNodes[12],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[12]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: 'Ex: Swift ID',
//               hintStyle: hintTextStyle,
//             ),
//             // initialValue: widget.offer != null && widget.isOfferRequest
//             //     ? getOfferDescription(
//             //         offerDataModel: widget.offer,
//             //       )
//             //     : "",
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             maxLength: 11,
//             onSaved: (value) {
//               requestModel.cashModel.swiftId = value;
//             },
//             validator: (value) {
//               if (value.isEmpty) {
//                 return 'ID cannot be empty';
//               } else if (value.length < 8) {
//                 return 'Enter valid Swift ID';
//               } else {
//                 requestModel.cashModel.swiftId = value;
//                 return null;
//               }
//             },
//           )
//         ]);
//   }

//   Widget OtherDetailsWidget() {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             S.of(context).other_payment_name,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {},
//             focusNode: focusNodes[16],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).autofocus(focusNodes[17]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: S.of(context).other_payment_title_hint,
//               hintStyle: hintTextStyle,
//             ),
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             onSaved: (value) {
//               requestModel.cashModel.others = value;
//             },
//             validator: (value) {
//               if (value.isEmpty || value == null) {
//                 return S.of(context).validation_error_general_text;
//               }
//               if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
//                 return S.of(context).profanity_text_alert;
//               } else {
//                 requestModel.cashModel.others = value;
//                 return null;
//               }
//             },
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           Text(
//             S.of(context).other_payment_details,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             focusNode: focusNodes[17],
//             onChanged: (value) {},
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).unfocus();
//             },
//             textInputAction: TextInputAction.next,
//             keyboardType: TextInputType.multiline,
//             minLines: 5,
//             maxLines: null,
//             onSaved: (value) {
//               requestModel.cashModel.other_details = value;
//             },
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: S.of(context).other_payment_details_hint,
//               hintStyle: hintTextStyle,
//             ),
//             validator: (value) {
//               if (value.isEmpty || value == null) {
//                 return S.of(context).validation_error_general_text;
//               }
//               if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
//                 return S.of(context).profanity_text_alert;
//               } else {
//                 requestModel.cashModel.other_details = value;
//                 return null;
//               }
//             },
//           ),
//         ]);
//   }

//   Widget RequestPaymentDescriptionData(RequestModel requestModel) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           S.of(context).request_payment_description,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         Text(
//           S.of(context).request_payment_description_hint_new,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: S.of(context).request_paymenttype_ach,
//           value: RequestPaymentType.ACH,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: S.of(context).request_paymenttype_paypal,
//           value: RequestPaymentType.PAYPAL,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: 'Swift',
//           value: RequestPaymentType.SWIFT,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: 'Venmo',
//           value: RequestPaymentType.VENMO,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: S.of(context).request_paymenttype_zellepay,
//           value: RequestPaymentType.ZELLEPAY,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton<RequestPaymentType>(
//           title: S.of(context).other(1),
//           value: RequestPaymentType.OTHER,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         requestModel.cashModel.paymentType == RequestPaymentType.ACH
//             ? RequestPaymentACH(requestModel)
//             : requestModel.cashModel.paymentType == RequestPaymentType.PAYPAL
//                 ? RequestPaymentPaypal(requestModel)
//                 : requestModel.cashModel.paymentType == RequestPaymentType.VENMO
//                     ? RequestPaymentVenmo(requestModel)
//                     : requestModel.cashModel.paymentType ==
//                             RequestPaymentType.SWIFT
//                         ? RequestPaymentSwift()
//                         : requestModel.cashModel.paymentType ==
//                                 RequestPaymentType.OTHER
//                             ? OtherDetailsWidget()
//                             : RequestPaymentZellePay(),
//       ],
//     );
//   }

//   // Widget BorrowToolTitleField(hintTextDesc) {
//   //   return Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: <Widget>[
//   //         Text(
//   //           "Request tools description*",
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             fontWeight: FontWeight.bold,
//   //             fontFamily: 'Europa',
//   //             color: Colors.black,
//   //           ),
//   //         ),
//   //         TextFormField(
//   //           autovalidateMode: AutovalidateMode.onUserInteraction,
//   //           onChanged: (value) {
//   //             // if (value != null && value.length > 5) {
//   //             //   _debouncer.run(() {
//   //             //     getCategoriesFromApi(value);
//   //             //   });
//   //             // }
//   //             updateExitWithConfirmationValue(context, 9, value);
//   //           },
//   //           focusNode: focusNodes[3],
//   //           onFieldSubmitted: (v) {
//   //             FocusScope.of(context).requestFocus(focusNodes[3]);
//   //           },
//   //           textInputAction: TextInputAction.next,
//   //           decoration: InputDecoration(
//   //             errorMaxLines: 2,
//   //             hintText: hintTextDesc,
//   //             hintStyle: hintTextStyle,
//   //           ),
//   //           initialValue: "",
//   //           keyboardType: TextInputType.multiline,
//   //           maxLines: 1,
//   //           validator: (value) {
//   //             if (value.isEmpty) {
//   //               return S.of(context).validation_error_general_text;
//   //             }
//   //             if (profanityDetector.isProfaneString(value)) {
//   //               return S.of(context).profanity_text_alert;
//   //             }
//   //             requestModel.borrowRequestToolName = value;
//   //           },
//   //         ),
//   //       ]);
//   // }

//   Widget RequestDescriptionData(hintTextDesc) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           (requestModel.requestType == RequestType.BORROW && roomOrTool == 1)
//               ? Text(
//                   S.of(context).request_tools_description,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Europa',
//                     color: Colors.black,
//                   ),
//                 )
//               : Text(
//                   "${S.of(context).request_description}",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Europa',
//                     color: Colors.black,
//                   ),
//                 ),
//           TextFormField(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               if (value != null && value.length > 5) {
//                 _debouncer.run(() {
//                   getCategoriesFromApi(value);
//                 });
//               }
//               updateExitWithConfirmationValue(context, 9, value);
//             },
//             focusNode: focusNodes[0],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).requestFocus(focusNodes[1]);
//             },
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               errorMaxLines: 2,
//               hintText: hintTextDesc,
//               hintStyle: hintTextStyle,
//             ),
//             initialValue: widget.offer != null && widget.isOfferRequest
//                 ? getOfferDescription(
//                     offerDataModel: widget.offer,
//                   )
//                 : "",
//             keyboardType: TextInputType.multiline,
//             maxLines: 1,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_general_text;
//               }
//               if (profanityDetector.isProfaneString(value)) {
//                 return S.of(context).profanity_text_alert;
//               }
//               requestModel.description = value;
//             },
//           ),
//         ]);
//   }

//   Widget RequestTypeWidgetCommunityRequests() {
//     return requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
//         ? Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 S.of(context).request_type,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Europa',
//                   color: Colors.black,
//                 ),
//               ),
//               Column(
//                 children: <Widget>[
//                   ConfigurationCheck(
//                     actionType: 'create_time_request',
//                     role: memberType(timebankModel,
//                         SevaCore.of(context).loggedInUser.sevaUserID),
//                     child: _optionRadioButton<RequestType>(
//                       title: S.of(context).request_type_time,
//                       isEnabled: !widget.isOfferRequest,
//                       value: RequestType.TIME,
//                       groupvalue: requestModel.requestType,
//                       onChanged: (value) {
//                         //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                         instructorAdded = false;
//                         requestModel.selectedInstructor = null;
//                         requestModel.requestType = value;
//                         AppConfig.helpIconContextMember =
//                             HelpContextMemberType.time_requests;
//                         setState(() => {});
//                       },
//                     ),
//                   ),
//                   TransactionsMatrixCheck(
//                     comingFrom: widget.comingFrom,
//                     upgradeDetails:
//                         AppConfig.upgradePlanBannerModel.goods_request,
//                     transaction_matrix_type: 'cash_goods_requests',
//                     child: _optionRadioButton<RequestType>(
//                       title: S.of(context).request_type_goods,
//                       isEnabled: !(widget.isOfferRequest ?? false),
//                       value: RequestType.GOODS,
//                       groupvalue: requestModel.requestType,
//                       onChanged: (value) {
//                         requestModel.isRecurring = false;
//                         requestModel.requestType = value;
//                         AppConfig.helpIconContextMember =
//                             HelpContextMemberType.goods_requests;

//                         //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                         instructorAdded = false;
//                         requestModel.selectedInstructor = null;
//                         requestModel.requestType = value;
//                         setState(() => {});
//                       },
//                     ),
//                   ),
//                   TransactionsMatrixCheck(
//                     upgradeDetails:
//                         AppConfig.upgradePlanBannerModel.cash_request,
//                     transaction_matrix_type: 'cash_goods_requests',
//                     comingFrom: widget.comingFrom,
//                     child: ConfigurationCheck(
//                       actionType: 'create_money_request',
//                       role: memberType(timebankModel,
//                           SevaCore.of(context).loggedInUser.sevaUserID),
//                       child: _optionRadioButton<RequestType>(
//                         title: S.of(context).request_type_cash,
//                         value: RequestType.CASH,
//                         isEnabled: !widget.isOfferRequest,
//                         groupvalue: requestModel.requestType,
//                         onChanged: (value) {
//                           requestModel.isRecurring = false;
//                           requestModel.requestType = value;
//                           AppConfig.helpIconContextMember =
//                               HelpContextMemberType.money_requests;

//                           //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                           instructorAdded = false;
//                           requestModel.selectedInstructor = null;
//                           requestModel.requestType = value;
//                           setState(() => {});
//                         },
//                       ),
//                     ),
//                   ),

//                   //BORROW REQUEST PUSHED TO NEXT RELEASE

//                   // TransactionsMatrixCheck(
//                   //   upgradeDetails:
//                   //       AppConfig.upgradePlanBannerModel.cash_request,
//                   //   transaction_matrix_type: 'cash_goods_requests',
//                   //   comingFrom: widget.comingFrom,
//                   //   child: ConfigurationCheck(
//                   //     actionType: 'create_goods_request',
//                   //     role: memberType(timebankModel,
//                   //         SevaCore.of(context).loggedInUser.sevaUserID),
//                   //     child: _optionRadioButton<RequestType>(
//                   //       title: 'Borrow',
//                   //       value: RequestType.BORROW,
//                   //       isEnabled: !widget.isOfferRequest,
//                   //       groupvalue: requestModel.requestType,
//                   //       onChanged: (value) {
//                   //         //requestModel.isRecurring = true;
//                   //         requestModel.requestType = value;
//                   //         //By default instructor for One To Many Requests is the creator
//                   //         instructorAdded = false;
//                   //         requestModel.selectedInstructor = null;
//                   //         AppConfig.helpIconContextMember =
//                   //             HelpContextMemberType.time_requests;
//                   //         setState(() => {});
//                   //       },
//                   //     ),
//                   //   ),
//                   // ),
//                   TransactionsMatrixCheck(
//                     upgradeDetails:
//                         AppConfig.upgradePlanBannerModel.onetomany_requests,
//                     transaction_matrix_type: 'onetomany_requests',
//                     comingFrom: widget.comingFrom,
//                     child: _optionRadioButton<RequestType>(
//                       title: S.of(context).one_to_many.sentenceCase(),
//                       value: RequestType.ONE_TO_MANY_REQUEST,
//                       isEnabled: !widget.isOfferRequest,
//                       groupvalue: requestModel.requestType,
//                       onChanged: (value) {
//                         //requestModel.isRecurring = true;
//                         requestModel.requestType = value;
//                         //By default instructor for One To Many Requests is the creator
//                         instructorAdded = true;
//                         requestModel.selectedInstructor = BasicUserDetails(
//                           fullname: SevaCore.of(context).loggedInUser.fullname,
//                           email: SevaCore.of(context).loggedInUser.email,
//                           photoURL: SevaCore.of(context).loggedInUser.photoURL,
//                           sevaUserID:
//                               SevaCore.of(context).loggedInUser.sevaUserID,
//                         );
//                         AppConfig.helpIconContextMember =
//                             HelpContextMemberType.one_to_many_requests;
//                         setState(() => {});
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             ],
//           )
//         : Container();
//   }

//   Widget RequestTypeWidgetPersonalRequests() {
//     return requestModel.requestMode == RequestMode.PERSONAL_REQUEST
//         ? Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 S.of(context).request_type,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Europa',
//                   color: Colors.black,
//                 ),
//               ),
//               Column(
//                 children: <Widget>[
//                   _optionRadioButton<RequestType>(
//                     title: S.of(context).request_type_time,
//                     isEnabled: !widget.isOfferRequest,
//                     value: RequestType.TIME,
//                     groupvalue: requestModel.requestType,
//                     onChanged: (value) {
//                       //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                       //instructorAdded = false;
//                       //requestModel.selectedInstructor = null;
//                       requestModel.requestType = value;
//                       AppConfig.helpIconContextMember =
//                           HelpContextMemberType.time_requests;

//                       //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                       instructorAdded = false;
//                       requestModel.selectedInstructor = null;
//                       requestModel.requestType = value;
//                       setState(() => {});
//                     },
//                   ),
//                   // _optionRadioButton<RequestType>(
//                   //   title: 'Borrow',
//                   //   value: RequestType.BORROW,
//                   //   isEnabled: true,
//                   //   groupvalue: requestModel.requestType,
//                   //   onChanged: (value) {
//                   //     //requestModel.isRecurring = true;
//                   //     requestModel.requestType = value;
//                   //     //By default instructor for One To Many Requests is the creator
//                   //     //instructorAdded = false;
//                   //     //requestModel.selectedInstructor = null;
//                   //     AppConfig.helpIconContextMember = HelpContextMemberType
//                   //         .time_requests; //need to make for Borrow requests
//                   //     setState(() => {});
//                   //   },
//                   // ),
//                 ],
//               )
//             ],
//           )
//         : Container();
//   }

// // Choose Category and Sub Category function
//   // get data from Category class
//   List<CategoryModel> selectedCategoryModels = [];
//   String categoryMode;
//   Map<String, dynamic> _selectedSkillsMap = {};

//   void updateInformation(List<CategoryModel> category) {
//     if (category != null && category.length > 0) {
//       selectedCategoryModels.addAll(category);
//     }
//     setState(() {});
//   }

//   Future<void> getCategoriesFromApi(String query) async {
//     try {
//       var response = await http.post(
//         "https://proxy.sevaexchange.com/" +
//             "http://ai.api.sevaxapp.com/request_categories",
//         headers: {
//           "Content-Type": "application/json",
//           "Access-Control": "Allow-Headers",
//           "x-requested-with": "x-requested-by"
//         },
//         body: jsonEncode({
//           "description": query,
//         }),
//       );
//       log('respinse ${response.body}');
//       log('respinse ${response.statusCode}');

//       if (response.statusCode == 200) {
//         Map<String, dynamic> bodyMap = json.decode(response.body);
//         List<String> categoriesList = bodyMap.containsKey('string_vec')
//             ? List.castFrom(bodyMap['string_vec'])
//             : [];
//         if (categoriesList != null && categoriesList.length > 0) {
//           getCategoryModels(categoriesList);
//         }
//       } else {
//         return null;
//       }
//     } catch (exception) {
//       log(exception.toString());
//       return null;
//     }
//   }

//   Future<void> getCategoryModels(List<String> categoriesList) async {
//     List<CategoryModel> modelList = [];
//     for (int i = 0; i < categoriesList.length; i += 1) {
//       CategoryModel categoryModel = await FirestoreManager.getCategoryForId(
//         categoryID: categoriesList[i],
//       );
//       modelList.add(categoryModel);
//     }
//     if (modelList != null && modelList.length > 0) {
//       categoryMode = S.of(context).suggested_categories;

//       updateInformation(modelList);
//     }
//   }

//   // Navigat to Category class and geting data from the class
//   void moveToCategory() async {
//     var category = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           fullscreenDialog: true,
//           builder: (context) => Category(
//                 selectedSubCategoriesids: selectedCategoryIds,
//                 // onNewCategoryCreated: () async {
//                 //   var categoryNew = await Navigator.of(context)
//                 //       .push(MaterialPageRoute(builder: (context) {
//                 //     return Category(
//                 //         selectedSubCategoriesids: selectedCategoryIds);
//                 //   }));
//                 //   updateInformation(categoryNew);
//                 // },
//               )),
//     );
//     if (category != null) {
//       categoryMode = category[0];
//       updateInformation(category[1]);
//     }
//   }

//   //building list of selectedSubCategories
//   List<Widget> _buildselectedSubCategories() {
//     List<CategoryModel> subCategories = [];
//     subCategories = selectedCategoryModels;
//     log('lll l ${subCategories.length}');
//     subCategories.forEach((item) {});
//     final ids = subCategories.map((e) => e.typeId).toSet();
//     subCategories.retainWhere((x) => ids.remove(x.typeId));
//     log('lll after ${subCategories.length}');

//     List<Widget> selectedSubCategories = [];
//     selectedCategoryIds.clear();
//     subCategories.forEach((item) {
//       selectedCategoryIds.add(item.typeId);
//       selectedSubCategories.add(
//         Padding(
//           padding: const EdgeInsets.only(right: 7, bottom: 7),
//           child: Container(
//             height: 35,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               color: Theme.of(context).primaryColor,
//             ),
//             child: Padding(
//               padding:
//                   const EdgeInsets.only(top: 3.5, bottom: 5, left: 9, right: 9),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text("${item.getCategoryName(context).toString()}",
//                       style: TextStyle(color: Colors.white)),
//                   SizedBox(width: 3),
//                   InkWell(
//                     onTap: () {
//                       setState(() {
//                         selectedCategoryIds.remove(item.typeId);
//                         selectedSubCategories.remove(item.typeId);
//                         subCategories.removeWhere(
//                             (category) => category.typeId == item.typeId);
//                       });
//                     },
//                     child: Icon(Icons.cancel_rounded,
//                         color: Colors.grey[100], size: 28),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     });
//     return selectedSubCategories;
//   }

//   Widget BorrowRequest(snapshot, projectModelList) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           RepeatWidget(),

//           SizedBox(height: 20),

//           // roomOrTool == 1
//           //     ? BorrowToolTitleField('Ex: Hammer or Chair...')
//           //     : Container(),

//           SizedBox(height: 15),

//           RequestDescriptionData(S.of(context).request_descrip_hint_text),
//           SizedBox(height: 20),
//           //Same hint for Room and Tools ?
//           // Choose Category and Sub Category
//           InkWell(
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     categoryMode == null
//                         ? Text(
//                             S.of(context).choose_category,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Europa',
//                               color: Colors.black,
//                             ),
//                           )
//                         : Text(
//                             "${categoryMode}",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Europa',
//                               color: Colors.black,
//                             ),
//                           ),
//                     Spacer(),
//                     Icon(
//                       Icons.arrow_forward_ios_outlined,
//                       size: 16,
//                     ),
//                     // Container(
//                     //   height: 25,
//                     //   width: 25,
//                     //   decoration: BoxDecoration(
//                     //       color: Theme.of(context).primaryColor,
//                     //       borderRadius: BorderRadius.circular(100)),
//                     //   child: Icon(
//                     //     Icons.arrow_drop_down_outlined,
//                     //     color: Colors.white,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 selectedCategoryModels != null &&
//                         selectedCategoryModels.length > 0
//                     ? Wrap(
//                         alignment: WrapAlignment.start,
//                         crossAxisAlignment: WrapCrossAlignment.start,
//                         children: _buildselectedSubCategories(),
//                       )
//                     : Container(),
//               ],
//             ),
//             onTap: () => moveToCategory(),
//           ),
//           SizedBox(height: 20),
//           isFromRequest(
//             projectId: widget.projectId,
//           )
//               ? addToProjectContainer(
//                   snapshot,
//                   projectModelList,
//                   requestModel,
//                 )
//               : Container(),

//           SizedBox(height: 15),

//           Center(
//             child: LocationPickerWidget(
//               selectedAddress: selectedAddress,
//               location: location,
//               onChanged: (LocationDataModel dataModel) {
//                 log("received data model");
//                 setState(() {
//                   location = dataModel.geoPoint;
//                   this.selectedAddress = dataModel.location;
//                 });
//               },
//             ),
//           )
//         ]);
//   }

//   Widget categoryWidget() {
//     return InkWell(
//       child: Column(
//         children: [
//           Row(
//             children: [
//               categoryMode == null
//                   ? Text(
//                       S.of(context).choose_category,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Europa',
//                         color: Colors.black,
//                       ),
//                     )
//                   : Text(
//                       "${categoryMode}",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Europa',
//                         color: Colors.black,
//                       ),
//                     ),
//               Spacer(),
//               Icon(
//                 Icons.arrow_forward_ios_outlined,
//                 size: 16,
//               ),
//               // Container(
//               //   height: 25,
//               //   width: 25,
//               //   decoration: BoxDecoration(
//               //       color: Theme.of(context).primaryColor,
//               //       borderRadius: BorderRadius.circular(100)),
//               //   child: Icon(
//               //     Icons.arrow_drop_down_outlined,
//               //     color: Colors.white,
//               //   ),
//               // ),
//             ],
//           ),
//           SizedBox(height: 20),
//           selectedCategoryModels != null && selectedCategoryModels.length > 0
//               ? Wrap(
//                   alignment: WrapAlignment.start,
//                   children: _buildselectedSubCategories(),
//                 )
//               : Container(),
//         ],
//       ),
//       onTap: () => moveToCategory(),
//     );
//   }

//   Widget TimeRequest(snapshot, projectModelList) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           RepeatWidget(),

//           SizedBox(height: 20),

//           requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//               ? RequestDescriptionData(S.of(context).request_descrip_hint_text)
//               : RequestDescriptionData(S.of(context).request_description_hint),

//           SizedBox(height: 20),
//           // Choose Category and Sub Category
//           categoryWidget(),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).provide_skills,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           SkillsForRequests(
//             languageCode: SevaCore.of(context).loggedInUser.language ?? 'en',
//             selectedSkills: _selectedSkillsMap,
//             onSelectedSkillsMap: (skillMap) {
//               if (skillMap.values != null && skillMap.values.length > 0) {
//                 _selectedSkillsMap = skillMap;
//                 // setState(() {});
//               }
//             },
//           ),

//           SizedBox(height: 20),
//           isFromRequest(
//             projectId: widget.projectId,
//           )
//               ? addToProjectContainer(
//                   snapshot,
//                   projectModelList,
//                   requestModel,
//                 )
//               : Container(),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).max_credits,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   focusNode: focusNodes[1],
//                   onFieldSubmitted: (v) {
//                     FocusScope.of(context).requestFocus(focusNodes[2]);
//                   },
//                   onChanged: (v) {
//                     updateExitWithConfirmationValue(context, 10, v);
//                     if (v.isNotEmpty && int.parse(v) >= 0) {
//                       requestModel.maxCredits = int.parse(v);
//                       setState(() {});
//                     }
//                   },
//                   decoration: InputDecoration(
//                     hintText: requestModel.requestType ==
//                             RequestType.ONE_TO_MANY_REQUEST
//                         ? S
//                             .of(context)
//                             .onetomanyrequest_participants_or_credits_hint
//                         : S.of(context).max_credit_hint,
//                     hintStyle: hintTextStyle,
//                     // labelText: 'No. of volunteers',
//                   ),
//                   textInputAction: TextInputAction.next,
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value.isEmpty) {
//                       return S.of(context).enter_max_credits;
//                     } else if (int.parse(value) < 0) {
//                       return S.of(context).enter_max_credits;
//                     } else if (int.parse(value) == 0) {
//                       return S.of(context).enter_max_credits;
//                     } else {
//                       requestModel.maxCredits = int.parse(value);
//                       setState(() {});
//                       return null;
//                     }
//                   },
//                 ),
//               ),
//               infoButton(
//                 context: context,
//                 key: GlobalKey(),
//                 type: InfoType.MAX_CREDITS,
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//               ? Text(
//                   S.of(context).total_no_of_participants,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Europa',
//                     color: Colors.black,
//                   ),
//                 )
//               : Text(
//                   S.of(context).number_of_volunteers,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Europa',
//                     color: Colors.black,
//                   ),
//                 ),
//           TextFormField(
//             focusNode: focusNodes[2],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).unfocus();
//             },
//             onChanged: (v) {
//               updateExitWithConfirmationValue(context, 11, v);
//               if (v.isNotEmpty && int.parse(v) >= 0) {
//                 requestModel.numberOfApprovals = int.parse(v);
//                 setState(() {});
//               }
//             },
//             decoration: InputDecoration(
//               hintText: requestModel.requestType ==
//                       RequestType.ONE_TO_MANY_REQUEST
//                   ? S.of(context).onetomanyrequest_participants_or_credits_hint
//                   : S.of(context).number_of_volunteers,
//               hintStyle: hintTextStyle,
//               // labelText: 'No. of volunteers',
//             ),
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_volunteer_count;
//               } else if (int.parse(value) < 0) {
//                 return S.of(context).validation_error_volunteer_count_negative;
//               } else if (int.parse(value) == 0) {
//                 return S.of(context).validation_error_volunteer_count_zero;
//               } else {
//                 requestModel.numberOfApprovals = int.parse(value);
//                 setState(() {});
//                 return null;
//               }
//             },
//           ),
//           CommonUtils.TotalCredits(
//             context: context,
//             requestModel: requestModel,
//             requestCreditsMode: TotalCreditseMode.CREATE_MODE,
//           ),
//           // SizedBox(height: 5),
//           // requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//           //     ? Row(
//           //         children: [
//           //           Checkbox(
//           //             activeColor: Theme.of(context).primaryColor,
//           //             checkColor: Colors.white,
//           //             value: createEvent,
//           //             onChanged: (val) {
//           //               setState(() {
//           //                 createEvent = val;
//           //               });
//           //             },
//           //           ),
//           //           Text('Tick to create an event for this request')
//           //         ],
//           //       )
//           //     : Container(height: 0, width: 0),

//           SizedBox(height: 15),
//           AddImagesForRequest(
//             onLinksCreated: (List<String> imageUrls) {
//               requestModel.imageUrls = imageUrls;
//             },
//           ),
//           Center(
//             child: LocationPickerWidget(
//               selectedAddress: selectedAddress,
//               location: location,
//               onChanged: (LocationDataModel dataModel) {
//                 log("received data model");
//                 setState(() {
//                   location = dataModel.geoPoint;
//                   this.selectedAddress = dataModel.location;
//                 });
//               },
//             ),
//           )
//         ]);
//   }

//   void _search(String queryString) {
//     if (queryString.length == 3) {
//       setState(() {
//         searchOnChange.add(queryString);
//       });
//     } else {
//       searchOnChange.add(queryString);
//     }
//   }

//   //  void refresh() {
//   //   _firestore
//   //       .requests
//   //       .doc(widget.requestModelId)
//   //       .snapshots()
//   //       .listen((reqModel) {
//   //     requestModel = RequestModel.fromMap(reqModel.data);
//   //     try {
//   //       setState(() {
//   //         buildWidget();
//   //       });
//   //     } on Exception catch (error) {
//   //       logger.e(error);
//   //     }
//   //   });
//   // }

//   Widget CashRequest(snapshot, projectModelList) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(height: 20),
//           RequestDescriptionData(S.of(context).cash_request_data_hint_text),
//           // RequestDescriptionData(S.of(context).request_description_hint_cash),
//           SizedBox(height: 20),
//           categoryWidget(),
//           SizedBox(height: 20),
//           AddImagesForRequest(
//             onLinksCreated: (List<String> imageUrls) {
//               requestModel.imageUrls = imageUrls;
//             },
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_target_donation,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             initialValue: widget.offer != null && widget.isOfferRequest
//                 ? getCashDonationAmount(
//                     offerDataModel: widget.offer,
//                   )
//                 : "",
//             focusNode: focusNodes[5],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).unfocus();
//             },
//             onChanged: (v) {
//               updateExitWithConfirmationValue(context, 12, v);
//               if (v.isNotEmpty && int.parse(v) >= 0) {
//                 requestModel.cashModel.targetAmount = int.parse(v);
//                 setState(() {});
//               }
//             },
//             decoration: InputDecoration(
//               hintText: S.of(context).request_target_donation_hint,
//               hintStyle: hintTextStyle,
//               prefixIcon: Icon(Icons.attach_money),

//               // labelText: 'No. of volunteers',
//             ),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(
//                 (RegExp("[0-9]")),
//               ),
//             ],
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_target_donation_count;
//               } else if (int.parse(value) < 0) {
//                 return S
//                     .of(context)
//                     .validation_error_target_donation_count_negative;
//               } else if (int.parse(value) == 0) {
//                 return S
//                     .of(context)
//                     .validation_error_target_donation_count_zero;
//               } else {
//                 requestModel.cashModel.targetAmount = int.parse(value);
//                 setState(() {});
//                 return null;
//               }
//             },
//           ),
//           SizedBox(height: 20),
//           Text(
//             S.of(context).request_min_donation,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Europa',
//               color: Colors.black,
//             ),
//           ),
//           TextFormField(
//             focusNode: focusNodes[6],
//             onFieldSubmitted: (v) {
//               FocusScope.of(context).unfocus();
//             },
//             onChanged: (v) {
//               updateExitWithConfirmationValue(context, 13, v);
//               if (v.isNotEmpty && int.parse(v) >= 0) {
//                 requestModel.cashModel.minAmount = int.parse(v);
//                 setState(() {});
//               }
//             },
//             decoration: InputDecoration(
//               hintText: S.of(context).request_min_donation_hint,
//               hintStyle: hintTextStyle,
//               // labelText: 'No. of volunteers',
//               prefixIcon: Icon(Icons.attach_money),

//               // labelText: 'No. of volunteers',
//             ),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(
//                 (RegExp("[0-9]")),
//               ),
//             ],
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return S.of(context).validation_error_min_donation_count;
//               } else if (int.parse(value) < 0) {
//                 return S
//                     .of(context)
//                     .validation_error_min_donation_count_negative;
//               } else if (int.parse(value) == 0) {
//                 return S.of(context).validation_error_min_donation_count_zero;
//               } else if (requestModel.cashModel.targetAmount != null &&
//                   requestModel.cashModel.targetAmount < int.parse(value)) {
//                 return S.of(context).target_amount_less_than_min_amount;
//               } else {
//                 requestModel.cashModel.minAmount = int.parse(value);
//                 setState(() {});
//                 return null;
//               }
//             },
//           ),
//           SizedBox(height: 20),
//           isFromRequest(
//             projectId: widget.projectId,
//           )
//               ? addToProjectContainer(
//                   snapshot,
//                   projectModelList,
//                   requestModel,
//                 )
//               : Container(),
//           SizedBox(height: 20),
//           RequestPaymentDescriptionData(requestModel),
//         ]);
//   }

//   Widget GoodsRequest(snapshot, projectModelList) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(height: 20),
//           RequestDescriptionData(S.of(context).goods_request_data_hint_text),
//           // RequestDescriptionData(S.of(context).request_description_hint_goods),
//           SizedBox(height: 20),
//           categoryWidget(),

//           SizedBox(height: 10),
//           AddImagesForRequest(
//             onLinksCreated: (List<String> imageUrls) {
//               requestModel.imageUrls = imageUrls;
//             },
//           ),
//           SizedBox(height: 20),
//           isFromRequest(
//             projectId: widget.projectId,
//           )
//               ? addToProjectContainer(
//                   snapshot,
//                   projectModelList,
//                   requestModel,
//                 )
//               : Container(),
//           SizedBox(height: 20),
//           RequestGoodsDescriptionData(),
//         ]);
//   }

//   bool isFromRequest({String projectId}) {
//     return projectId == null || projectId.isEmpty || projectId == "";
//   }

//   Widget _optionRadioButton<T>({
//     String title,
//     T value,
//     T groupvalue,
//     Function onChanged,
//     bool isEnabled = true,
//   }) {
//     return ListTile(
//       key: UniqueKey(),
//       contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
//       title: Text(title),
//       leading: Radio<T>(
//         value: value,
//         groupValue: groupvalue,
//         onChanged: (isEnabled ?? true) ? onChanged : null,
//       ),
//     );
//   }

//   Widget requestSwitch({
//     TimebankModel timebankModel,
//   }) {
//     if (widget.projectId == null ||
//         widget.projectId.isEmpty ||
//         widget.projectId == "") {
//       return Container(
//         margin: EdgeInsets.only(bottom: 20),
//         width: double.infinity,
//         child: CupertinoSegmentedControl<int>(
//           selectedColor: Theme.of(context).primaryColor,
//           children: {
//             0: Text(
//               timebankModel.parentTimebankId == FlavorConfig.values.timebankId
//                   ? S.of(context).timebank_request(1)
//                   : S.of(context).seva +
//                       timebankModel.name +
//                       " ${S.of(context).group} " +
//                       S.of(context).request,
//               style: TextStyle(fontSize: 12.0),
//             ),
//             1: Text(
//               S.of(context).personal_request(1),
//               style: TextStyle(fontSize: 12.0),
//             ),
//           },
//           borderColor: Colors.grey,
//           padding: EdgeInsets.only(left: 5.0, right: 5.0),
//           groupValue: sharedValue,

//           onValueChanged: (int val) {
//             if (val != sharedValue) {
//               setState(() {
//                 if (val == 0) {
//                   requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//                 } else {
//                   requestModel.requestMode = RequestMode.PERSONAL_REQUEST;

//                   requestModel.requestType = RequestType.TIME;
//                   //making false and clearing map because TIME and ONE_TO_MANY_REQUEST use same widget
//                   setState(() {
//                     instructorAdded = false;
//                     requestModel.selectedInstructor = null;
//                   });
//                   //requestModel.requestType = RequestType.TIME;
//                 }
//                 sharedValue = val;
//               });
//             }
//           },
//           //groupValue: sharedValue,
//         ),
//       );
//     } else {
//       if (widget.projectModel != null) {
//         if (widget.projectModel.mode == ProjectMode.TIMEBANK_PROJECT) {
//           requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//         } else {
//           requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//           // requestModel.requestType = RequestType.TIME;
//         }
//       }
//       return Container();
//     }
//   }

//   BuildContext dialogContext;

//   void createRequest() async {
//     // verify f the start and end date time is not same
//     var connResult = await Connectivity().checkConnectivity();
//     if (connResult == ConnectivityResult.none) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(S.of(context).check_internet),
//           action: SnackBarAction(
//             label: S.of(context).dismiss,
//             onPressed: () =>
//                 ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//           ),
//         ),
//       );
//       return;
//     }

//     DateTime startDate = DateTime.fromMillisecondsSinceEpoch(
//         OfferDurationWidgetState.starttimestamp);
//     DateTime endDate = DateTime.fromMillisecondsSinceEpoch(
//         OfferDurationWidgetState.endtimestamp);

//     requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
//     requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
//     requestModel.autoGenerated = false;

//     if (requestModel.requestType == RequestType.TIME ||
//         requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//       requestModel.isRecurring = RepeatWidgetState.isRecurring;
//     } else {
//       requestModel.isRecurring = false;
//     }

//     if (requestModel.isRecurring) {
//       requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
//       requestModel.occurenceCount = 1;
//       end.endType = RepeatWidgetState.endType == 0
//           ? S.of(context).on
//           : S.of(context).after;
//       end.on = end.endType == S.of(context).on
//           ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
//           : null;
//       end.after = (end.endType == S.of(context).after
//           ? int.parse(RepeatWidgetState.after)
//           : null);
//       requestModel.end = end;
//     }

//     if (_formKey.currentState.validate()) {
//       // validate request start and end date

//       if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
//         showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
//         return;
//       }

//       if (OfferDurationWidgetState.starttimestamp ==
//           OfferDurationWidgetState.endtimestamp) {
//         showDialogForTitle(
//             dialogTitle:
//                 S.of(context).validation_error_same_start_date_end_date);
//         return;
//       }

//       if (OfferDurationWidgetState.starttimestamp >
//           OfferDurationWidgetState.endtimestamp) {
//         showDialogForTitle(
//             dialogTitle: S.of(context).validation_error_end_date_greater);
//         return;
//       }

//       if (requestModel.requestType == RequestType.GOODS &&
//           (requestModel.goodsDonationDetails.requiredGoods == null ||
//               requestModel.goodsDonationDetails.requiredGoods.isEmpty)) {
//         showDialogForTitle(dialogTitle: S.of(context).goods_validation);
//         return;
//       }
//       communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
//         communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//       );
//       if (widget.isOfferRequest && widget.userModel != null) {
//         // if (requestModel.approvedUsers == null)
//         // requestModel.approvedUsers = [];
//         // List<String> approvedUsers = [];
//         // approvedUsers.add(widget.userModel.email);
//         // requestModel.approvedUsers = approvedUsers;

//         //TODO
//         requestModel.participantDetails = {};
//         requestModel.participantDetails[widget.userModel.email] = AcceptorModel(
//           communityId: widget.offer.communityId,
//           communityName: timebankModel.name ?? '',
//           memberEmail: widget.userModel.email,
//           memberName: widget.userModel.fullname,
//           memberPhotoUrl: widget.userModel.photoURL,
//           timebankId: widget.offer.timebankId,
//         ).toMap();
//         //create an invitation for the request
//       }

//       if (requestModel.isRecurring &&
//           (requestModel.requestType == RequestType.TIME ||
//               requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST)) {
//         if (requestModel.recurringDays.length == 0) {
//           showDialogForTitle(
//               dialogTitle: S.of(context).validation_error_empty_recurring_days);
//           return;
//         }
//       }

// //Assigning room or tool for Borrrow Requests
//       if (roomOrTool != null &&
//           requestModel.requestType == RequestType.BORROW) {
//         if (roomOrTool == 1) {
//           //CHANGE to use enums
//           requestModel.roomOrTool = 'TOOL';
//         } else {
//           requestModel.roomOrTool = 'ROOM';
//         }
//       }
// //Review done or not to be used to find out if Borrow request is completed or not
//       if (requestModel.requestType != RequestType.BORROW) {
//         requestModel.lenderReviewed = false;
//         requestModel.borrowerReviewed = false;
//       }
//       // if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//       //   List<String> approvedUsers = [];
//       //   approvedUsers.add(requestModel.selectedInstructor.email);
//       //   requestModel.approvedUsers = approvedUsers;
//       // }

//       if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
//           (requestModel.selectedInstructor.toMap().isEmpty ||
//               requestModel.selectedInstructor == null ||
//               instructorAdded == false)) {
//         showDialogForTitle(dialogTitle: S.of(context).select_a_speaker_dialog);
//         return;
//       }

//       //Calculate session duration of one to many request using request start and request end time
//       if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//         if (startDate != null && endDate != null) {
//           Duration sessionDuration = endDate.difference(startDate);
//           double sixty = 60;

//           selectedSpeakerTimeDetails.speakingTime = double.parse(
//               (sessionDuration.inMinutes / sixty).toStringAsPrecision(3));

//           //prep time will be entered by speaker when he/she is completing the request
//           selectedSpeakerTimeDetails.prepTime = 0;

//           requestModel.selectedSpeakerTimeDetails = selectedSpeakerTimeDetails;

//           setState(() {});
//         }
//       }

//       //Form and date is valid
//       //if(requestModel.requestType != RequestType.BORROW) {
//       switch (requestModel.requestMode) {
//         case RequestMode.PERSONAL_REQUEST:
//           var myDetails = SevaCore.of(context).loggedInUser;
//           this.requestModel.fullName = myDetails.fullname;
//           this.requestModel.photoUrl = myDetails.photoURL;
//           var onBalanceCheckResult =
//               await SevaCreditLimitManager.hasSufficientCredits(
//             email: SevaCore.of(context).loggedInUser.email,
//             credits: requestModel.numberOfHours.toDouble(),
//             userId: myDetails.sevaUserID,
//             communityId: timebankModel.communityId,
//           );
//           // double creditsNeeded =
//           //     await SevaCreditLimitManager.checkCreditsNeeded(
//           //   email: SevaCore.of(context).loggedInUser.email,
//           //   credits: requestModel.numberOfHours.toDouble(),
//           //   userId: myDetails.sevaUserID,
//           //   communityId: timebankModel.communityId,
//           // );
//           if (!onBalanceCheckResult.hasSuffiientCredits) {
//             showInsufficientBalance(onBalanceCheckResult.credits);
//             await sendInsufficentNotificationToAdmin(
//               creditsNeeded: onBalanceCheckResult.credits,
//             );
//             return;
//           }
//           break;

//         case RequestMode.TIMEBANK_REQUEST:
//           requestModel.fullName = timebankModel.name;
//           requestModel.photoUrl = timebankModel.photoUrl;
//           break;
//       }
//       //}

//       int timestamp = DateTime.now().millisecondsSinceEpoch;
//       String timestampString = timestamp.toString();
//       requestModel.id = '${requestModel.email}*$timestampString';
//       if (requestModel.isRecurring) {
//         requestModel.parent_request_id = requestModel.id;
//       } else {
//         requestModel.parent_request_id = null;
//       }

//       requestModel.liveMode = !AppConfig.isTestCommunity;
//       if (requestModel.public) {
//         requestModel.timebanksPosted = [
//           timebankModel.id,
//           FlavorConfig.values.timebankId
//         ];
//       } else {
//         requestModel.timebanksPosted = [timebankModel.id];
//       }

//       requestModel.communityId =
//           SevaCore.of(context).loggedInUser.currentCommunity;
//       requestModel.softDelete = false;
//       requestModel.postTimestamp = timestamp;
//       requestModel.accepted = false;
//       requestModel.acceptors = [];
//       requestModel.invitedUsers = [];
//       requestModel.recommendedMemberIdsForRequest = [];
//       requestModel.categories = selectedCategoryIds;
//       requestModel.address = selectedAddress;
//       requestModel.location = location;
//       requestModel.root_timebank_id = FlavorConfig.values.timebankId;
//       requestModel.softDelete = false;
//       requestModel.creatorName = SevaCore.of(context).loggedInUser.fullname;
//       requestModel.minimumCredits = 0;
//       requestModel.communityName = communityModel.name;
//       if (selectedInstructorModel != null &&
//           requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//         //speaker put in acceptors array, later when accepts through notification put into approved users
//         List<String> acceptorsList = [];
//         acceptorsList.add(selectedInstructorModel.email);
//         requestModel.acceptors = acceptorsList;

//         requestModel.requestCreatorName =
//             SevaCore.of(context).loggedInUser.fullname;

//         log('ADDED ACCEPTOR');
//       }

//       if (SevaCore.of(context).loggedInUser.calendarId != null) {
//         // calendar  integrated!
//         if (communityModel.payment['planId'] !=
//             SevaBillingPlans.NEIGHBOUR_HOOD_PLAN) {
//           List<String> acceptorList = widget.isOfferRequest
//               ? widget.offer.creatorAllowedCalender == null ||
//                       widget.offer.creatorAllowedCalender == false
//                   ? [requestModel.email]
//                   : [widget.offer.email, requestModel.email]
//               : [requestModel.email];
//           requestModel.allowedCalenderUsers = acceptorList.toList();
//         } else {
//           requestModel.allowedCalenderUsers = [];
//         }

//         await createProjectOneToManyRequest();

//         if (selectedInstructorModel != null &&
//             //selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
//             requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//           if (selectedInstructorModel.sevaUserID == requestModel.sevaUserId) {
//             requestModel.approvedUsers = [];
//             List<String> approvedUsers = [];
//             approvedUsers.add(requestModel.email);
//             requestModel.approvedUsers = approvedUsers;
//             log('speaker is creator');
//           } else if (selectedInstructorModel.communities
//                   .contains(requestModel.communityId) &&
//               selectedInstructorModel.sevaUserID != requestModel.sevaUserId) {
//             speakerNotificationDocRef =
//                 await sendNotificationToMemberOneToManyRequest(
//                     communityId: requestModel.communityId,
//                     timebankId: requestModel.timebankId,
//                     sevaUserId: selectedInstructorModel.sevaUserID,
//                     userEmail: selectedInstructorModel.email);
//           } else {
//             // send sevax global notification for user who is not part of the community for this request
//             speakerNotificationDocRef =
//                 await sendNotificationToMemberOneToManyRequest(
//                     communityId: FlavorConfig.values.timebankId,
//                     timebankId: FlavorConfig.values.timebankId,
//                     sevaUserId: selectedInstructorModel.sevaUserID,
//                     userEmail: selectedInstructorModel.email);
//             await sendMailToInstructor(
//                 senderEmail: 'noreply@sevaexchange.com', //requestModel.email,
//                 receiverEmail: selectedInstructorModel.email,
//                 communityName: timebankModel.name,
//                 requestName: requestModel.title,
//                 requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
//                 receiverName: selectedInstructorModel.fullname,
//                 startDate: requestModel.requestStart,
//                 endDate: requestModel.requestEnd);
//           }
//         }

//         await continueCreateRequest(confirmationDialogContext: null);

//         //below is to add speaker to inivited members when request is created
//         if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//           await updateInvitedSpeakerForRequest(
//               requestModel.id,
//               selectedInstructorModel.sevaUserID, //sevauserid null
//               selectedInstructorModel.email,
//               speakerNotificationDocRef);
//         }
//       } else {
//         linearProgressForCreatingRequest();

//         await createProjectOneToManyRequest();

//         if (selectedInstructorModel != null &&
//             //selectedInstructorModel.sevaUserID != requestModel.sevaUserId &&
//             requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//           if (selectedInstructorModel.sevaUserID == requestModel.sevaUserId) {
//             requestModel.approvedUsers = [];
//             List<String> approvedUsers = [];
//             approvedUsers.add(requestModel.email);
//             requestModel.approvedUsers = approvedUsers;
//             log('speaker is creator');
//           } else if (selectedInstructorModel.communities
//                   .contains(requestModel.communityId) &&
//               selectedInstructorModel.sevaUserID != requestModel.sevaUserId) {
//             speakerNotificationDocRef =
//                 await sendNotificationToMemberOneToManyRequest(
//                     communityId: requestModel.communityId,
//                     timebankId: requestModel.timebankId,
//                     sevaUserId: selectedInstructorModel.sevaUserID,
//                     userEmail: selectedInstructorModel.email);
//           } else {
//             // send sevax global notification for user who is not part of the community for this request
//             speakerNotificationDocRef =
//                 await sendNotificationToMemberOneToManyRequest(
//                     communityId: FlavorConfig.values.timebankId,
//                     timebankId: FlavorConfig.values.timebankId,
//                     sevaUserId: selectedInstructorModel.sevaUserID,
//                     userEmail: selectedInstructorModel.email);
//             await sendMailToInstructor(
//                 senderEmail: 'noreply@sevaexchange.com', //requestModel.email,
//                 receiverEmail: selectedInstructorModel.email,
//                 communityName: timebankModel.name,
//                 requestName: requestModel.title,
//                 requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
//                 receiverName: selectedInstructorModel.fullname,
//                 startDate: requestModel.requestStart,
//                 endDate: requestModel.requestEnd);
//           }
//         }

//         eventsIdsArr = await _writeToDB();
//         await _updateProjectModel();

//         //below is to add speaker to inivted members when request is created
//         if (requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//           await updateInvitedSpeakerForRequest(
//               requestModel.id,
//               selectedInstructorModel.sevaUserID, //sevauserid null
//               selectedInstructorModel.email,
//               speakerNotificationDocRef);
//         }

//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //     builder: (context) {
//         //       return AddToCalendar(
//         //           isOfferRequest: widget.isOfferRequest,
//         //           offer: widget.offer,
//         //           requestModel: requestModel,
//         //           userModel: widget.userModel,
//         //           eventsIdsArr: eventsIdsArr,);
//         //     },
//         //   ),
//         // );

//         Navigator.pop(dialogContext);

//         // await _settingModalBottomSheet(context);
//       }
//     }
//   }

//   Future openPdfViewer(
//       String pdfURL, String documentName, BuildContext context) {
//     progressDialog = ProgressDialog(
//       context,
//       type: ProgressDialogType.Normal,
//       isDismissible: true,
//     );
//     progressDialog.show();
//     createFileOfPdfUrl(pdfURL, documentName).then((f) {
//       progressDialog.hide();
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => PDFScreen(
//                   docName: documentName,
//                   pathPDF: f.path,
//                   isFromFeeds: false,
//                   isDownloadable: false,
//                 )),
//       );
//     });
//   }

//   Future createProjectOneToManyRequest() async {
//     //Create new Event/Project for ONE TO MANY Request
//     if (widget.projectModel == null &&
//         createEvent &&
//         requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//       String newProjectId = Utils.getUuid();
//       requestModel.projectId = newProjectId;
//       List<String> pendingRequests = [requestModel.selectedInstructor.email];

//       ProjectModel newProjectModel = ProjectModel(
//         emailId: requestModel.email,
//         members: [],
//         communityName: requestModel.communityName,
//         //phoneNumber:,
//         address: requestModel.address,
//         timebanksPosted: [requestModel.timebankId],
//         id: newProjectId,
//         name: requestModel.title,
//         communityId: requestModel.communityId,
//         photoUrl: requestModel.photoUrl,
//         creatorId: requestModel.sevaUserId,
//         mode: ProjectMode.TIMEBANK_PROJECT,
//         timebankId: requestModel.timebankId,
//         associatedMessaginfRoomId: '',
//         requestedSoftDelete: false,
//         softDelete: false,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         pendingRequests: pendingRequests,
//         startTime: requestModel.requestStart,
//         endTime: requestModel.requestEnd,
//         description: requestModel.description,
//       );

//       await createProject(projectModel: newProjectModel);

//       log("======================== createProjectWithMessaging()");
//       await ProjectMessagingRoomHelper
//           .createProjectWithMessagingOneToManyRequest(
//         projectModel: newProjectModel,
//         projectCreator: SevaCore.of(context).loggedInUser,
//       );
//     }
//   }

//   bool hasRegisteredLocation() {
//     return location != null;
//   }

//   Future<DocumentReference> sendNotificationToMemberOneToManyRequest(
//       {String communityId,
//       String sevaUserId,
//       String timebankId,
//       String userEmail}) async {
//     // UserAddedModel userAddedModel = UserAddedModel(
//     //     timebankImage: timebankModel.photoUrl,
//     //     timebankName: timebankModel.name,
//     //     adminName: BlocProvider.of<AuthBloc>(context).user.fullname);

//     NotificationsModel notification = NotificationsModel(
//         id: Utils.getUuid(),
//         timebankId: FlavorConfig.values.timebankId,
//         data: requestModel.toMap(),
//         isRead: false,
//         isTimebankNotification: false,
//         type: NotificationType.OneToManyRequestAccept,
//         communityId: communityId,
//         senderUserId: SevaCore.of(context)
//             .loggedInUser
//             .sevaUserID, //BlocProvider.of<AuthBloc>(context).user.sevaUserID,
//         targetUserId: sevaUserId);

//     await CollectionRef.users
//         .doc(userEmail)
//         .collection("notifications")
//         .doc(notification.id)
//         .set(notification.toMap());

//     return speakerNotificationDocRef = CollectionRef.users
//         .doc(userEmail)
//         .collection("notifications")
//         .doc(notification.id);
//   }

//   Future updateInvitedSpeakerForRequest(String requestID, String sevaUserId,
//       String email, DocumentReference speakerNotificationDocRef) async {
//     var batch = CollectionRef.batch;

//     batch.update(CollectionRef.requests.doc(requestID), {
//       'invitedUsers': FieldValue.arrayUnion([sevaUserId]),
//       'speakerInviteNotificationDocRef': speakerNotificationDocRef,
//     });

//     batch.update(
//       CollectionRef.users.doc(email),
//       {
//         'invitedRequests': FieldValue.arrayUnion([requestID])
//       },
//     );

//     await batch.commit();
//   }

// //Sending only if instructor is not part of the community of the request
//   Future<bool> sendMailToInstructor({
//     String senderEmail,
//     String receiverEmail,
//     String communityName,
//     String requestName,
//     String requestCreatorName,
//     String receiverName,
//     var startDate,
//     var endDate,
//   }) async {
//     return await SevaMailer.createAndSendEmail(
//         mailContent: MailContent.createMail(
//       mailSender: senderEmail,
//       mailReciever: receiverEmail,
//       mailSubject:
//           requestCreatorName + ' from ' + communityName + ' has invited you',
//       mailContent:
//           """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
//     <html xmlns="http://www.w3.org/1999/xhtml">

//     <head>
//         <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
//     </head>
    
//     <body>
//         <div dir="ltr">
    
//             <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;border:0px;background-color:white;font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif">
//                 <tbody>
    
//                         <tr>
//                         <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
//                             <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:10px;border-right:10px;border-top:10px;border-bottom:0px;padding:40px 80px 0px 80px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:600px;width:600px">
//                                 <tbody>
                                    
//                                     <tr>
//                                         <td align="center valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateHeader" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:19px;padding-bottom:19px">
//                                             <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="max-width:600px;width:600px">
//                                                 <tbody>
//                                                     <tr>
//                                                         <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
//                                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" >
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td valign="top" >
//                                                                             <table align="left" width="100%" border="0" cellpadding="0" cellspacing="0" style="border-collapse:inherit;border:0px;border-color:white;">
//                                                                                 <tbody>
//                                                                                     <tr>
//                                                                                         <td valign="top" style="padding:0px;text-align:center"><img align="left" alt="" src="https://ci5.googleusercontent.com/proxy/KMTN5MCNI08J15B09izASZ49J6rqtQf7e39MXu2B9OeOXFLSrmcqMBLGqpRsiuXVXCs5K0VhqORlonSSzigT_LlYKqS9WLljenNftkN5gYij5IKg6WOJ3VGHj2YikF1RrzTnoKPBEXfJl5RtYCqCHQVcmNYZZQ=s0-d-e1-ft#https://mcusercontent.com/18ef8611cb76f33e8a73c9575/images/60fe9519-6fc0-463f-8c67-b6341d56cf6f.jpg"
//                                                                                                 width="108" style="margin-right:35px;border-collapse:inherit;border:0px;border-color:white;height:auto;outline:none;vertical-align:bottom;max-width:400px;padding-bottom:0px;display:inline" class="CToWUd"></td>
//                                                                                     </tr>
//                                                                                 </tbody>
//                                                                             </table>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                 </tbody>
//                                             </table>
//                                         </td>
//                                     </tr>
    
//                                     <tr>
//                                         <td valign="top" style="background-image:none;background-repeat:no-repeat;background-position:50% 50%;background-size:cover;border-collapse: inherit;border:0px;padding:0px">
                                            
                                        
//                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" style="min-width:100%;table-layout:fixed">
//                                                 <tbody>
//                                                     <tr>
//                                                         <td style="min-width:100%;padding:18px 10px 18px 0px">
//                                                             <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;min-width:100%;border-top:2px solid rgb(234, 234, 234)">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td></td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                 </tbody>
//                                             </table>
//                                             <table border="0" cellpadding="0" cellspacing="0" width="100%">
//                                                 <tbody>
//                                                     <tr>
//                                                         <td valign="top" style="padding-bottom:0px">
//                                                             <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
//                                                                             <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">Hi ${receiverName},</div>
//                                                                             <div style="text-align:left;font-size:20px;line-height:25px;color:black;font-weight:700;"><br>You have been invited by ${requestCreatorName} to be a speaker \n on the topic of ${requestName} on ${DateFormat('EEEE, d').format(DateTime.fromMillisecondsSinceEpoch(startDate))} at ${DateFormat('MMM h:mm a').format(DateTime.fromMillisecondsSinceEpoch(startDate))}.</div>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                     <tr>
//                                                         <td valign="top" style="padding-bottom:10px">
//                                                             <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
//                                                                             <div style="text-align:left;font-size:20px;line-height:25px;color:black;font-weight:700;"><br>Please accept the invitation by clicking on the notification you will receive in the SevaX app.</div>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                     <tr>
//                                                         <td valign="top" style="padding-bottom:10px">
//                                                             <table align="left" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: inherit;max-width:100%;min-width:100%">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td valign="top" style="font-family:Helvetica;word-break:break-word;font-size:16px;line-height:16px;padding:0px 4px 9px">
//                                                                             <br>
//                                                                             <br>
//                                                                             <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">Regards,</div>
//                                                                             <br>
//                                                                             <div style="text-align:left;font-size:18px;line-height:20px;font-weight:500;color:#2c2c2d;">${communityName}</div>
//                                                                             <br>
//                                                                             <br>
//                                                                             <br>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                 </tbody>
//                                             </table>

//                                         </td>
//                                     </tr>
    
//                                 </tbody>
//                             </table>
//                         </td>
//                     </tr>
//                         <td align="center" valign="top" id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateBody" style="background:none 50% 50%/cover no-repeat white;border-collapse:inherit;border:0px;border-color:white;padding-top:0px;padding-bottom:0px">
//                             <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%" style="border-left:0px;border-right:0px;border-top:0px;border-bottom:0px;padding:0px 0px 0px 00px;border-style:solid;border-collapse: seperate;border-color:#766FE0;max-width:777px">
//                                 <tbody>
    
//                                     <tr >
//                                         <td align=" center " valign="top " id="m_-637120832348245336m_6644406718029751392gmail-m_-5513227398159991865templateFooter " style="background:none 50% 50%/cover no-repeat rgb(47,46,46);border:0px;padding-top:45px;padding-bottom:33px;">
//                                             <table align="center " border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="max-width:777px;width:777px ">
//                                                 <tbody>
//                                                     <tr style="text-align: center;">
//                                                         <td valign="top " style="background:none 50% 50%/cover no-repeat transparent;border:0px;padding-top:0px;padding-bottom:0px;padding-left:8%;padding-right: 8%;">
//                                                             <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="min-width:100%;table-layout:fixed;">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td style="text-align: center;">
//                                                                             <table border="0 " cellpadding="0 " cellspacing="0 " width="100% " style="border-top: 2px solid rgb(80,80,80) ">
//                                                                                 <tbody>
//                                                                                     <tr>
//                                                                                         <td></td>
//                                                                                     </tr>
//                                                                                 </tbody>
//                                                                             </table>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                             <table  border="0 " cellpadding="0 " cellspacing="0 " width="100%">
//                                                                 <tbody>
//                                                                     <tr>
//                                                                         <td valign="top " style="padding-top:9px;">
//                                                                             <table align="center " border="0" cellpadding="0 " cellspacing="0 " width="100% " style="text-align: center !important;">
//                                                                                 <tbody>
//                                                                                     <tr>
//                                                                                 <td valign="top " style="font-family:Helvetica;word-break:break-word;color:rgb(255,255,255);font-size:12px;line-height:18px;text-align:center !important;padding:0px 18px 9px">
//                                                                                     <em>Copyright © 2021 Seva Exchange Corporation. All rights reserved.</em><br><br><strong>Feel free to contact us at:</strong><br><a href="mailto:contact@sevaexchange.com " style="color:rgb(255,255,255) "
//                                                                                         target="_blank ">info@sevaexchange.com</a><br><br><a href="https://sevaxapp.com/PrivacyPolicy.html" target="_blank" style="color:rgb(255,255,255);">Privacy Policy&nbsp;</a>&nbsp;<br>
//                                                                                 </td>
//                                                                                     </tr>
//                                                                                 </tbody>
//                                                                             </table>
//                                                                         </td>
//                                                                     </tr>
//                                                                 </tbody>
//                                                             </table>
//                                                         </td>
//                                                     </tr>
//                                                 </tbody>
//                                             </table>
//                                         </td>
//                                     </tr>
    
//                                 </tbody>
//                             </table>
//                         </td>
    
//                 </tbody>
//             </table>
//         </div>
//     </body>
//   </html>

//  """,
//       // mailContent: 'You have been invited to be the speaker for' +
//       //     requestName +
//       //     ' from ' +
//       //     DateTime.fromMillisecondsSinceEpoch(startDate)
//       //         .toString()
//       //         .substring(0, 11) +
//       //     ' to ' +
//       //     DateTime.fromMillisecondsSinceEpoch(endDate)
//       //         .toString()
//       //         .substring(0, 11) +
//       //     "\n\n" +
//       //     'Thanks,' +
//       //     "\n" +
//       //     'SevaX Team.',
//     ));
//   }

//   void continueCreateRequest({BuildContext confirmationDialogContext}) async {
//     linearProgressForCreatingRequest();

//     List<String> resVar = await _writeToDB();
//     eventsIdsArr = resVar;
//     await _updateProjectModel();
//     Navigator.pop(dialogContext);

//     // if (resVar.length == 0 && requestModel.requestType != RequestType.BORROW) {
//     //   showInsufficientBalance();
//     // }
//     if (confirmationDialogContext != null) {
//       Navigator.pop(confirmationDialogContext);
//     }

//     KloudlessWidgetManager<CreateMode, RequestModel>().syncCalendar(
//       context: context,
//       builder: KloudlessWidgetBuilder().fromContext<CreateMode, RequestModel>(
//         context: context,
//         model: requestModel,
//         id: requestModel.id,
//       ),
//     );
//     if (widget.isOfferRequest == true && widget.userModel != null) {
//       Navigator.pop(context, {'response': 'ACCEPTED'});
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   void linearProgressForCreatingRequest() {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (createDialogContext) {
//           dialogContext = createDialogContext;
//           return AlertDialog(
//             title: Text(S.of(context).creating_request),
//             content: LinearProgressIndicator(),
//           );
//         });
//   }

//   void showInsufficientBalance(double credits) {
//     showDialog(
//         context: context,
//         builder: (BuildContext viewContext) {
//           return AlertDialog(
//             title: Text(S
//                 .of(context)
//                 .insufficientSevaCreditsDialog
//                 .replaceFirst('***', credits.toString())),
//             actions: <Widget>[
//               CustomTextButton(
//                 child: Text(
//                   S.of(context).ok,
//                   style: TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//                 onPressed: () async {
//                   Navigator.of(viewContext).pop();
//                 },
//               ),
//             ],
//           );
//         });
//   }

//   void showDialogForTitle({String dialogTitle}) async {
//     showDialog(
//         context: context,
//         builder: (BuildContext viewContext) {
//           return AlertDialog(
//             title: Text(dialogTitle),
//             actions: <Widget>[
//               CustomTextButton(
//                 shape: StadiumBorder(),
//                 color: Theme.of(context).primaryColor,
//                 textColor: Colors.white,
//                 child: Text(
//                   S.of(context).ok,
//                   style: TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.of(viewContext).pop();
//                 },
//               ),
//             ],
//           );
//         });
//   }

//   Map<String, UserModel> selectedUsers;
//   Map onActivityResult;

//   String memberAssignment;

//   Widget addVolunteersForAdmin() {
//     if (selectedUsers == null) {
//       selectedUsers = HashMap();
//     }

//     if (widget.userModel != null) {
//       Map<String, UserModel> map = HashMap();
//       map[widget.userModel.email] = widget.userModel;
//       selectedUsers.addAll(map);
//     }
//     memberAssignment = S.of(context).assign_to_volunteers;
//     return Container(
//       margin: EdgeInsets.all(10),
//       width: double.infinity,
//       child: CustomElevatedButton(
//         child: Text(selectedUsers != null && selectedUsers.length > 0
//             ? "${selectedUsers.length} ${S.of(context).members_selected(selectedUsers.length)}"
//             : memberAssignment),
//         onPressed: () async {
//           onActivityResult = await Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => SelectMembersInGroup(
//                 timebankId: widget.loggedInUser.currentTimebank,
//                 userEmail: widget.loggedInUser.email,
//                 userSelected: selectedUsers,
//                 listOfalreadyExistingMembers: [],
//               ),
//             ),
//           );

//           if (onActivityResult != null &&
//               onActivityResult.containsKey("membersSelected")) {
//             selectedUsers = onActivityResult['membersSelected'];
//             setState(() {
//               if (selectedUsers != null && selectedUsers.length == 0)
//                 memberAssignment = S.of(context).assign_to_volunteers;
//               else
//                 memberAssignment =
//                     "${selectedUsers.length ?? ''} ${S.of(context).volunteers_selected(selectedUsers.length)}";
//             });
//           } else {
//             //no users where selected
//           }
//           // SelectMembersInGroup
//         },
//       ),
//     );
//   }

//   Future<void> fetchLinkData() async {
//     // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
//     var link = await FirebaseDynamicLinks.instance.getInitialLink();
//     log("<<<<<<<<<<<<<<<<<<<< $link");
//     // buildContext = context;
//     // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
//     FirebaseDynamicLinks.instance.onLink(
//         onError: (_) async {},
//         onSuccess: (PendingDynamicLinkData dynamicLink) async {});

//     // This will handle incoming links if the application is already opened
//   }

//   String getTimeInFormat(int timeStamp) {
//     return DateFormat(
//             'EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag())
//         .format(
//       getDateTimeAccToUserTimezone(
//           dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
//           timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
//     );
//   }

//   bool hasSufficientBalance() {
//     var requestCoins = requestModel.numberOfHours;
//     var lowerLimit =
//         json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

//     var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
//     return requestCoins <= finalbalance;
//   }

//   Future<List<String>> _writeToDB() async {
//     if (requestModel.id == null) return [];
//     // credit the timebank the required credits before the request creation
//     // if (requestModel.requestType != RequestType.BORROW) {
//     //   log('Comes Here');
//     //   await TransactionBloc().createNewTransaction(
//     //     requestModel.timebankId,
//     //     requestModel.timebankId,
//     //     DateTime.now().millisecondsSinceEpoch,
//     //     requestModel.numberOfHours ?? 0,
//     //     true,
//     //     "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
//     //     requestModel.id,
//     //     requestModel.timebankId,
//     //     communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//     //     toEmailORId: requestModel.timebankId,
//     //     fromEmailORId: FlavorConfig.values.timebankId,
//     //   );
//     // }

//     List<String> resultVar = [];
//     if (!requestModel.isRecurring) {
//       await FirestoreManager.createRequest(requestModel: requestModel);
//       //create invitation if its from offer only for cash and goods
//       try {
//         await OfferInvitationManager
//             .handleInvitationNotificationForRequestCreatedFromOffer(
//           currentCommunity: SevaCore.of(context).loggedInUser.currentCommunity,
//           offerModel: widget.offer,
//           requestModel: requestModel,
//           senderSevaUserID: requestModel.sevaUserId,
//           timebankModel: timebankModel,
//         );
//       } on Exception catch (exception) {
//         //Log to crashlytics
//       }

//       resultVar.add(requestModel.id);
//       return resultVar;
//     } else {
//       resultVar = await FirestoreManager.createRecurringEvents(
//         requestModel: requestModel,
//         communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//         timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
//       );
//       return resultVar;
//     }
//   }

//   Future _updateProjectModel() async {
//     if (widget.projectId.isNotEmpty && !requestModel.isRecurring) {
//       ProjectModel projectModel = widget.projectModel;
// //      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
// //      if (!projectModel.members.contains(userSevaUserId)) {
// //        projectModel.members.add(userSevaUserId);
// //      }
//       projectModel.pendingRequests.add(requestModel.id);
//       await FirestoreManager.updateProject(projectModel: projectModel);
//     }
//   }

//   Future<Map> showTimebankAdvisory() {
//     return showDialog(
//         context: context,
//         builder: (BuildContext viewContext) {
//           return AlertDialog(
//             title: Text(
//               S.of(context).select_project,
//               style: TextStyle(
//                 fontSize: 16,
//               ),
//             ),
//             content: Form(
//               child: Container(
//                 height: 300,
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.vertical,
//                   child: Text(
//                     S.of(context).projects_here,
//                     style: TextStyle(
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             actions: <Widget>[
//               CustomTextButton(
//                 child: Text(
//                   S.of(context).cancel,
//                   style: TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.of(viewContext).pop({'PROCEED': false});
//                 },
//               ),
//               CustomTextButton(
//                 child: Text(
//                   S.of(context).proceed,
//                   style: TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//                 onPressed: () {
// //                  return Navigator.of(viewContext).pop({'PROCEED': true});
//                 },
//               ),
//             ],
//           );
//         });
//   }

//   void sendInsufficentNotificationToAdmin({
//     double creditsNeeded,
//   }) async {
//     log('creditsNeeded:  ' + creditsNeeded.toString());

//     UserInsufficentCreditsModel userInsufficientModel =
//         UserInsufficentCreditsModel(
//       senderName: SevaCore.of(context).loggedInUser.fullname,
//       senderId: SevaCore.of(context).loggedInUser.sevaUserID,
//       senderPhotoUrl: SevaCore.of(context).loggedInUser.photoURL,
//       timebankId: timebankModel.id,
//       timebankName: timebankModel.name,
//       creditsNeeded: creditsNeeded,
//     );

//     NotificationsModel notification = NotificationsModel(
//         id: utils.Utils.getUuid(),
//         timebankId: timebankModel.id,
//         data: userInsufficientModel.toMap(),
//         isRead: false,
//         type: NotificationType.TYPE_MEMBER_HAS_INSUFFICENT_CREDITS,
//         communityId: timebankModel.communityId,
//         senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//         targetUserId: timebankModel.creatorId);

//     await CollectionRef.timebank
//         .doc(timebankModel.id)
//         .collection("notifications")
//         .doc(notification.id)
//         .set((notification..isTimebankNotification = true).toMap());

//     log('writtent to DB');
//   }
// }

// class ProjectSelection extends StatefulWidget {
//   ProjectSelection(
//       {Key key,
//       this.requestModel,
//       this.admin,
//       this.projectModelList,
//       this.selectedProject,
//       this.timebankModel,
//       this.userModel,
//       this.createEvent,
//       this.setcreateEventState})
//       : super(key: key);
//   final bool admin;
//   final List<ProjectModel> projectModelList;
//   final ProjectModel selectedProject;
//   RequestModel requestModel;
//   TimebankModel timebankModel;
//   UserModel userModel;
//   bool createEvent;
//   VoidCallback setcreateEventState;

//   @override
//   ProjectSelectionState createState() => ProjectSelectionState();
// }

// class ProjectSelectionState extends State<ProjectSelection> {
//   @override
//   Widget build(BuildContext context) {
//     if (widget.projectModelList == null) {
//       return Container();
//     }
//     List<dynamic> list = [
//       {"name": S.of(context).unassigned, "code": "None"}
//     ];
//     for (var i = 0; i < widget.projectModelList.length; i++) {
//       list.add({
//         "name": widget.projectModelList[i].name,
//         "code": widget.projectModelList[i].id,
//         "timebankproject":
//             widget.projectModelList[i].mode == ProjectMode.TIMEBANK_PROJECT,
//       });
//     }
//     return MultiSelect(
//       timebankModel: widget.timebankModel,
//       userModel: widget.userModel,
//       autovalidate: true,
//       initialValue: ['None'],
//       titleText: Row(
//         children: [
//           Text(S.of(context).assign_to_project),
//           SizedBox(
//             width: 10,
//           ),
//           Icon(
//             Icons.arrow_drop_down_circle,
//             color: Theme.of(context).primaryColor,
//             size: 30.0,
//           ),
//           SizedBox(width: 4),
//           widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//               ? GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       widget.createEvent = !widget.createEvent;
//                       widget.requestModel.projectId = '';
//                       log('projectId1:  ' +
//                           widget.requestModel.projectId.toString());
//                       log('createEvent1:  ' + widget.createEvent.toString());
//                     });
//                     widget.setcreateEventState();
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 1.8),
//                     child: Icon(Icons.add_circle_outline_rounded,
//                         size: 28,
//                         color: widget.createEvent ? Colors.green : Colors.grey),
//                   ),
//                 )
//               : Container()
//         ],
//       ),
//       maxLength: 1, // optional
//       hintText: S.of(context).tap_to_select,
//       validator: (dynamic value) {
//         if (value == null) {
//           return S.of(context).assign_to_one_project;
//         }
//         return null;
//       },
//       errorText: S.of(context).assign_to_one_project,
//       dataSource: list,
//       admin: widget.admin,
//       textField: 'name',
//       valueField: 'code',
//       filterable: true,
//       required: true,
//       titleTextColor: Colors.black,
//       change: (value) {
//         if (value != null && value[0] != 'None') {
//           widget.requestModel.projectId = value[0];
//         } else {
//           widget.requestModel.projectId = '';
//         }
//       },
//       selectIcon: Icons.arrow_drop_down_circle,
//       saveButtonColor: Theme.of(context).primaryColor,
//       checkBoxColor: Theme.of(context).primaryColorDark,
//       cancelButtonColor: Theme.of(context).primaryColorLight,
//     );
//   }
// }

// Future<Map<String, String>> getGoodsFuture() async {
//   Map<String, String> goodsVar = {};
//   QuerySnapshot querySnapshot =
//       await CollectionRef.donationCategories.orderBy('goodTitle').get();
//   querySnapshot.docs.forEach((DocumentSnapshot docData) {
//     goodsVar[docData.id] = docData.data()['goodTitle'];
//   });
//   log("goodsVar length ${goodsVar.length.toString()}");
//   return goodsVar;
// }

// enum BorrowRequestType {
//   TOOL,
//   ROOM,
// }

// class SevaBillingPlans {
//   static String NEIGHBOUR_HOOD_PLAN = 'neighbourhood_plan';
//   static String COMMUNITY_PLAN = 'tall_plan';
//   static String COMMUNITY_PLUS = 'community_plus_plan';
//   static String NON_PROFIT = 'grande_plan';
//   static String ENTERPRISE = 'venti_plan';
// }
