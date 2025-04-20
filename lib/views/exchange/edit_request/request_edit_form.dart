
// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collection/equality.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:sevaexchange/components/ProfanityDetector.dart';
// import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
// import 'package:sevaexchange/components/goods_dynamic_selection_editRequest.dart';
// import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/labels.dart';
// import 'package:sevaexchange/models/basic_user_details.dart';
// import 'package:sevaexchange/models/category_model.dart';
// import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
// import 'package:sevaexchange/models/location_model.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/models/selectedSpeakerTimeDetails.dart';
// import 'package:sevaexchange/new_baseline/models/project_model.dart';
// import 'package:sevaexchange/repositories/firestore_keys.dart';
// import 'package:sevaexchange/ui/screens/request/pages/select_borrow_item.dart';
// import 'package:sevaexchange/ui/utils/date_formatter.dart';
// import 'package:sevaexchange/ui/utils/debouncer.dart';
// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/utils/data_managers/request_data_manager.dart' as RequestManager;
// import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
// import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/utils/helpers/mailer.dart';
// import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
// import 'package:sevaexchange/utils/log_printer/log_printer.dart';
// import 'package:sevaexchange/utils/svea_credits_manager.dart';
// import 'package:sevaexchange/utils/utils.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/exchange/widgets/project_selection.dart';
// import 'package:sevaexchange/views/exchange/widgets/request_enums.dart';
// import 'package:sevaexchange/views/exchange/edit_request/edit_request_old_code.dart';
// import 'package:sevaexchange/views/messages/list_members_timebank.dart';
// import 'package:sevaexchange/views/requests/onetomany_request_instructor_card.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
// import 'package:sevaexchange/views/workshop/direct_assignment.dart';
// import 'package:sevaexchange/widgets/add_images_for_request.dart';
// import 'package:sevaexchange/widgets/custom_buttons.dart';
// import 'package:sevaexchange/widgets/custom_info_dialog.dart';
// import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
// import 'package:sevaexchange/widgets/hide_widget.dart';
// import 'package:sevaexchange/widgets/location_picker_widget.dart';
// import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';
// import 'package:sevaexchange/widgets/select_category.dart';
// import 'package:sevaexchange/widgets/user_profile_image.dart';

// class RequestEditForm extends StatefulWidget {
//   final bool isOfferRequest;
//   final OfferModel offer;
//   final String timebankId;
//   final UserModel userModel;
//   final UserModel loggedInUser;
//   final ProjectModel projectModel;
//   final String projectId;
//   RequestModel requestModel;

//   RequestEditForm(
//       {this.isOfferRequest,
//       this.offer,
//       this.timebankId,
//       this.userModel,
//       this.loggedInUser,
//       this.projectId,
//       this.projectModel,
//       this.requestModel});

//   @override
//   RequestEditFormState createState() {
//     return RequestEditFormState();
//   }
// }

// class RequestEditFormState extends State<RequestEditForm> {
//   final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();
//   final _formKey = GlobalKey<FormState>();
//   final hoursTextFocus = FocusNode();
//   final volunteersTextFocus = FocusNode();
//   List<String> selectedCategoryIds = [];
//   RequestModel requestModel;
//   GeoFirePoint location;
//   final _debouncer = Debouncer(milliseconds: 500);

//   String initialRequestTitle = '';
//   String initialRequestDescription = '';
//   var startDate;
//   var endDate;
//   int tempCredits = 0;
//   int tempNoOfVolunteers = 0;
//   String tempProjectId = '';

//   End end = End();
//   var focusNodes = List.generate(18, (_) => FocusNode());

//   double sevaCoinsValue = 0;
//   String hoursMessage = ' Click to Set Duration';
//   String selectedAddress;
//   int sharedValue = 0;

//   String _selectedTimebankId;
//   int oldHours = 0;
//   int oldTotalRecurrences = 0;
//   bool isPublicCheckboxVisible = false;

// //One To Many Request new variables
//   bool isAdmin = false;

//   //Map<dynamic,dynamic> selectedInstructorMap;
//   final TextEditingController searchTextController = TextEditingController();
//   final searchOnChange = BehaviorSubject<String>();
//   final _textUpdates = StreamController<String>();

//   //Below variable for Borrow Requests
//   int roomOrTool = 0;

//   UserModel selectedInstructorModel;
//   BasicUserDetails selectedInstructorModelTemp;
//   SelectedSpeakerTimeDetails selectedSpeakerTimeDetails =
//       new SelectedSpeakerTimeDetails(speakingTime: 0.0, prepTime: 0);
//   DocumentReference speakerNotificationDocRefNew;
//   bool createEvent = false;
//   bool instructorAdded = false;

//   Future<TimebankModel> getTimebankAdminStatus;
//   Future getProjectsByFuture;
//   TimebankModel timebankModel;
//   final profanityDetector = ProfanityDetector();

//   RegExp regExp = RegExp(
//     r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
//     caseSensitive: false,
//     multiLine: false,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _selectedTimebankId = widget.timebankId;
//     requestModel = RequestModel(
//       communityId: widget.requestModel.communityId,
//       oneToManyRequestAttenders: widget.requestModel.oneToManyRequestAttenders,
//       selectedInstructor: widget.requestModel.selectedInstructor,
//     );
//     logger.e('PAYPAL CHECK:  ' + widget.requestModel.cashModel.toString());
//     selectedInstructorModelTemp = widget.requestModel.selectedInstructor;
//     this.requestModel.timebankId = _selectedTimebankId;
//     this.location = widget.requestModel.location;

//     logger.d(widget.requestModel.location.toString() + "From Database =====================");
//     this.selectedAddress = widget.requestModel.address;
//     this.oldHours = widget.requestModel.numberOfHours;
//     this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//     //this.requestModel.projectId = widget.projectId;
//     if (widget.requestModel.categories != null && widget.requestModel.categories.length > 0) {
//       getCategoryModels(widget.requestModel.categories, 'Selected Categories');
//     }
//     isPublicCheckboxVisible = widget.requestModel.virtualRequest ?? false;
//     getTimebankAdminStatus = getTimebankDetailsbyFuture(timebankId: _selectedTimebankId);
//     getProjectsByFuture = FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

//     tempCredits = widget.requestModel.maxCredits;
//     initialRequestTitle = widget.requestModel.title;
//     initialRequestDescription = widget.requestModel.description;
//     tempNoOfVolunteers = widget.requestModel.numberOfApprovals;
//     tempProjectId = widget.requestModel.projectId;

//     //will be true because a One to many request when editing should have an instructor
//     if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//       instructorAdded = true;
//     }

//     log('Instructor Data:  ' + widget.requestModel.selectedInstructor.toString());
//     log('Instructor Data:  ' + widget.requestModel.approvedUsers.toString());

//     fetchRemoteConfig();

//     // if ((FlavorConfig.appFlavor == Flavor.APP ||
//     //     FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
//     //   // _fetchCurrentlocation;
//     // }
//   }

//   Future<void> fetchRemoteConfig() async {
//     AppConfig.remoteConfig = await RemoteConfig.instance;
//     AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
//     AppConfig.remoteConfig.activateFetched();
//   }

//   @override
//   void didChangeDependencies() {
//     this.requestModel.email = widget.requestModel.email;
//     this.requestModel.fullName = widget.requestModel.fullName;
//     this.requestModel.photoUrl = widget.requestModel.photoUrl;
//     this.requestModel.sevaUserId = widget.requestModel.sevaUserId;
//     if (widget.loggedInUser?.sevaUserID != null)
//       FirestoreManager.getUserForIdStream(sevaUserId: widget.loggedInUser.sevaUserID)
//           .listen((userModel) {});
//     super.didChangeDependencies();
//   }

//   TextStyle hintTextStyle = TextStyle(
//     fontSize: 14,
//     // fontWeight: FontWeight.bold,
//     color: Colors.grey,
//     fontFamily: 'Europa',
//   );

//   Widget addToProjectContainer(snapshot, List<ProjectModel> projectModelList, requestModel) {
//     if (snapshot.hasError) return Text(snapshot.error.toString());
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return Container();
//     }
//     timebankModel = snapshot.data;
//     if (isAccessAvailable(snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID) &&
//         widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST &&
//         isFromRequest()) {
//       return ProjectSelection(
//         requestModel: requestModel,
//         projectModelList: projectModelList,
//         admin: isAccessAvailable(snapshot.data, SevaCore.of(context).loggedInUser.sevaUserID),
//         selectedProject: (tempProjectId != null && tempProjectId.isNotEmpty)
//             ? projectModelList.firstWhere((element) => element.id == widget.requestModel.projectId,
//                 orElse: () => null)
//             : null,
//         updateProjectIdCallback: (String projectid) {
//           //widget.requestModel.projectId = projectid;
//           tempProjectId = projectid;
//           setState(() {});
//         },
//       );
//     } else {
//       this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//       this.requestModel.requestType = RequestType.TIME;
//       return Container();
//       // return ProjectSelection(
//       //   requestModel: requestModel,
//       //   projectModelList: projectModelList,
//       //   selectedProject: null,
//       //   admin: false,
//       // );
//     }
//   }

//   void updateExitWithConfirmationValue(BuildContext context, int index, String value) {
//     ExitWithConfirmation.of(context).fieldValues[index] = value;
//   }

//   @override
//   Widget build(BuildContext context) {
//     startDate = getUpdatedDateTimeAccToUserTimezone(
//         timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
//         dateTime: DateTime.fromMillisecondsSinceEpoch(widget.requestModel.requestStart));
//     endDate = getUpdatedDateTimeAccToUserTimezone(
//         timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
//         dateTime: DateTime.fromMillisecondsSinceEpoch(widget.requestModel.requestEnd));
//     hoursMessage = S.of(context).set_duration;
//     UserModel loggedInUser = SevaCore.of(context).loggedInUser;
//     this.requestModel.email = loggedInUser.email;
//     this.requestModel.sevaUserId = loggedInUser.sevaUserID;

//     return FutureBuilder<TimebankModel>(
//         future: getTimebankAdminStatus,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Container();
//           }
//           timebankModel = snapshot.data;

//           if (snapshot.hasError) {
//             return Text(snapshot.error);
//           }

//           if (widget.requestModel.location == null || widget.requestModel.address == null) {
//             // logger.d(selectedAddress + " =====Location " + location.toString());

//             location = timebankModel.location;
//             selectedAddress = timebankModel.address;
//           } else {
//             location = widget.requestModel.location;
//             selectedAddress = widget.requestModel.address;
//           }

//           return FutureBuilder<List<ProjectModel>>(
//               future: getProjectsByFuture,
//               builder: (projectscontext, projectListSnapshot) {
//                 if (projectListSnapshot.connectionState == ConnectionState.waiting) {
//                   return LoadingIndicator();
//                 }
//                 if (projectListSnapshot.hasError) {
//                   return Center(
//                     child: Text(projectListSnapshot.error.toString()),
//                   );
//                 }
//                 List<ProjectModel> projectModelList = projectListSnapshot.data;
//                 return Form(
//                   key: _formKey,
//                   child: Container(
//                     padding: EdgeInsets.all(20.0),
//                     child: SingleChildScrollView(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             // headerContainer(snapshot),
//                             // RequestTypeWidget(),

//                             Text(
//                               S.of(context).request_title,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Europa',
//                                 color: Colors.black,
//                               ),
//                             ),
//                             TextFormField(
//                               autovalidateMode: AutovalidateMode.onUserInteraction,
//                               onChanged: (value) {
//                                 updateExitWithConfirmationValue(context, 1, value);
//                                 setState(() {
//                                   initialRequestTitle = value;
//                                 });
//                               },
//                               onFieldSubmitted: (v) {
//                                 FocusScope.of(context).requestFocus(focusNodes[0]);
//                               },
//                               // inputFormatters: <TextInputFormatter>[
//                               //   WhitelistingTextInputFormatter(
//                               //       RegExp("[a-zA-Z0-9_ ]*"))
//                               // ],
//                               decoration: InputDecoration(
//                                 errorMaxLines: 2,
//                                 hintText: S.of(context).request_title_hint,
//                                 hintStyle: hintTextStyle,
//                               ),
//                               textInputAction: TextInputAction.next,
//                               keyboardType: TextInputType.text,
//                               initialValue: widget.requestModel.title,
//                               textCapitalization: TextCapitalization.sentences,
//                               validator: (value) {
//                                 if (value.isEmpty) {
//                                   return S.of(context).request_subject;
//                                 }
//                                 if (profanityDetector.isProfaneString(value)) {
//                                   return S.of(context).profanity_text_alert;
//                                 }
//                                 //widget.requestModel.title = value;
//                                 initialRequestTitle = value;
//                               },
//                             ),

//                             SizedBox(height: 15),

//                             //Instructor to be assigned to One to many requests widget Here

//                             instructorAdded
//                                 ? Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(height: 20),
//                                       Text(
//                                         S.of(context).selected_speaker,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'Europa',
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       SizedBox(height: 15),
//                                       Padding(
//                                         padding: const EdgeInsets.only(left: 0, right: 10),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.center,
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: <Widget>[
//                                             // SizedBox(
//                                             //   height: 15,
//                                             // ),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                               children: <Widget>[
//                                                 UserProfileImage(
//                                                   photoUrl: selectedInstructorModelTemp.photoURL,
//                                                   email: selectedInstructorModelTemp.email,
//                                                   userId: selectedInstructorModelTemp.sevaUserID,
//                                                   height: 75,
//                                                   width: 75,
//                                                   timebankModel: timebankModel,
//                                                 ),
//                                                 SizedBox(
//                                                   width: 15,
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                     selectedInstructorModelTemp.fullname ??
//                                                         S.of(context).name_not_available,
//                                                     style: TextStyle(
//                                                         color: Colors.black,
//                                                         fontSize: 18,
//                                                         fontWeight: FontWeight.bold),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 15,
//                                                 ),
//                                                 Container(
//                                                   height: 37,
//                                                   padding: EdgeInsets.only(bottom: 0),
//                                                   child: InkWell(
//                                                     child: Icon(
//                                                       Icons.cancel_rounded,
//                                                       size: 30,
//                                                       color: Colors.grey,
//                                                     ),
//                                                     onTap: () {
//                                                       setState(() {
//                                                         instructorAdded = false;
//                                                         selectedInstructorModelTemp = null;
//                                                       });
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//                                     ? Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                             SizedBox(height: 20),
//                                             Text(
//                                               S.of(context).select_a_speaker,
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 fontFamily: 'Europa',
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             SizedBox(height: 15),
//                                             TextField(
//                                               style: TextStyle(color: Colors.black),
//                                               controller: searchTextController,
//                                               onChanged: _search,
//                                               autocorrect: true,
//                                               decoration: InputDecoration(
//                                                 suffixIcon: IconButton(
//                                                     icon: Icon(
//                                                       Icons.clear,
//                                                       color: Colors.black54,
//                                                     ),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         searchTextController.clear();
//                                                       });
//                                                     }),
//                                                 alignLabelWithHint: true,
//                                                 isDense: true,
//                                                 prefixIcon: Icon(
//                                                   Icons.search,
//                                                   color: Colors.grey,
//                                                 ),
//                                                 contentPadding:
//                                                     EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
//                                                 filled: true,
//                                                 fillColor: Colors.grey[200],
//                                                 focusedBorder: OutlineInputBorder(
//                                                   borderSide: BorderSide(color: Colors.white),
//                                                   borderRadius: BorderRadius.circular(15.7),
//                                                 ),
//                                                 enabledBorder: UnderlineInputBorder(
//                                                     borderSide: BorderSide(color: Colors.white),
//                                                     borderRadius: BorderRadius.circular(15.7)),
//                                                 hintText: S.of(context).select_speaker_hint,
//                                                 hintStyle: TextStyle(
//                                                   color: Colors.black45,
//                                                   fontSize: 14,
//                                                 ),
//                                                 floatingLabelBehavior: FloatingLabelBehavior.never,
//                                               ),
//                                             ),

//                                             //SizedBox(height: 5),

//                                             Container(
//                                                 child: Column(children: [
//                                               StreamBuilder<List<UserModel>>(
//                                                 stream: SearchManager.searchUserInSevaX(
//                                                   queryString: searchTextController.text,
//                                                   //validItems: validItems,
//                                                 ),
//                                                 builder: (context, snapshot) {
//                                                   if (snapshot.hasError) {
//                                                     Text(snapshot.error.toString());
//                                                   }
//                                                   if (!snapshot.hasData) {
//                                                     return Center(
//                                                       child: SizedBox(
//                                                         height: 48,
//                                                         width: 40,
//                                                         child: Container(
//                                                           margin: const EdgeInsets.only(top: 12.0),
//                                                           child: CircularProgressIndicator(),
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }

//                                                   List<UserModel> userList = snapshot.data;
//                                                   userList.removeWhere((user) =>
//                                                       user.sevaUserID ==
//                                                           SevaCore.of(context)
//                                                               .loggedInUser
//                                                               .sevaUserID ||
//                                                       user.sevaUserID ==
//                                                           widget.requestModel.sevaUserId);

//                                                   if (userList.length == 0) {
//                                                     return Row(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       children: [
//                                                         Container(
//                                                           width: MediaQuery.of(context).size.width *
//                                                               0.85,
//                                                           height:
//                                                               MediaQuery.of(context).size.width *
//                                                                   0.15,
//                                                           child: Card(
//                                                             shape: RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors.transparent,
//                                                                   width: 0),
//                                                               borderRadius: BorderRadius.vertical(
//                                                                   bottom: Radius.circular(7.0)),
//                                                             ),
//                                                             borderOnForeground: false,
//                                                             shadowColor: Colors.white24,
//                                                             elevation: 5,
//                                                             child: Padding(
//                                                               padding: const EdgeInsets.only(
//                                                                   left: 15.0, top: 11.0),
//                                                               child: Text(
//                                                                 S.of(context).no_member_found,
//                                                                 style: TextStyle(
//                                                                   color: Colors.grey,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     );
//                                                   }

//                                                   if (searchTextController.text.trim().length < 3) {
//                                                     return Row(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       children: [
//                                                         Container(
//                                                           width: MediaQuery.of(context).size.width *
//                                                               0.85,
//                                                           height:
//                                                               MediaQuery.of(context).size.width *
//                                                                   0.15,
//                                                           child: Card(
//                                                             shape: RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors.transparent,
//                                                                   width: 0),
//                                                               borderRadius: BorderRadius.vertical(
//                                                                   bottom: Radius.circular(7.0)),
//                                                             ),
//                                                             borderOnForeground: false,
//                                                             shadowColor: Colors.white24,
//                                                             elevation: 5,
//                                                             child: Padding(
//                                                               padding: const EdgeInsets.only(
//                                                                   left: 15.0, top: 11.0),
//                                                               child: Text(
//                                                                 S
//                                                                     .of(context)
//                                                                     .validation_error_search_min_characters,
//                                                                 style: TextStyle(
//                                                                   color: Colors.grey,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     );
//                                                   } else {
//                                                     return Scrollbar(
//                                                       child: Center(
//                                                         child: Card(
//                                                           shape: RoundedRectangleBorder(
//                                                             side: BorderSide(
//                                                                 color: Colors.transparent,
//                                                                 width: 0),
//                                                             borderRadius: BorderRadius.circular(10),
//                                                           ),
//                                                           borderOnForeground: false,
//                                                           shadowColor: Colors.white24,
//                                                           elevation: 5,
//                                                           child: LimitedBox(
//                                                             maxHeight:
//                                                                 MediaQuery.of(context).size.width *
//                                                                     0.55,
//                                                             maxWidth: 90,
//                                                             child: ListView.separated(
//                                                                 primary: false,
//                                                                 //physics: NeverScrollableScroflutter card bordellPhysics(),
//                                                                 shrinkWrap: true,
//                                                                 padding: EdgeInsets.zero,
//                                                                 itemCount: userList.length,
//                                                                 separatorBuilder:
//                                                                     (BuildContext context,
//                                                                             int index) =>
//                                                                         Divider(),
//                                                                 itemBuilder: (context, index) {
//                                                                   UserModel user = userList[index];

//                                                                   List<String> timeBankIds =
//                                                                       snapshot.data[index]
//                                                                               .favoriteByTimeBank ??
//                                                                           [];
//                                                                   List<String> memberId =
//                                                                       user.favoriteByMember ?? [];

//                                                                   return OneToManyInstructorCard(
//                                                                     userModel: user,
//                                                                     timebankModel: timebankModel,
//                                                                     isAdmin: isAdmin,
//                                                                     //refresh: refresh,
//                                                                     currentCommunity:
//                                                                         SevaCore.of(context)
//                                                                             .loggedInUser
//                                                                             .currentCommunity,
//                                                                     loggedUserId:
//                                                                         SevaCore.of(context)
//                                                                             .loggedInUser
//                                                                             .sevaUserID,
//                                                                     isFavorite: isAdmin
//                                                                         ? timeBankIds.contains(
//                                                                             widget.requestModel
//                                                                                 .timebankId)
//                                                                         : memberId.contains(
//                                                                             SevaCore.of(context)
//                                                                                 .loggedInUser
//                                                                                 .sevaUserID),
//                                                                     addStatus: S.of(context).add,
//                                                                     onAddClick: () {
//                                                                       setState(() {
//                                                                         selectedInstructorModel =
//                                                                             user;
//                                                                         instructorAdded = true;
//                                                                         selectedInstructorModelTemp =
//                                                                             BasicUserDetails(
//                                                                           fullname: user?.fullname,
//                                                                           email: user?.email,
//                                                                           photoURL: user?.photoURL,
//                                                                           sevaUserID:
//                                                                               user?.sevaUserID,
//                                                                         );
//                                                                         // widget.requestModel.selectedInstructor =
//                                                                         //     BasicUserDetails(
//                                                                         //   fullname: user.fullname,
//                                                                         //   email: user.email,
//                                                                         //   photoURL: user.photoURL,
//                                                                         //   sevaUserID: user.sevaUserID,
//                                                                         // );
//                                                                       });
//                                                                     },
//                                                                   );
//                                                                 }),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     );
//                                                   }
//                                                 },
//                                               ),
//                                             ])),
//                                           ])
//                                     : Container(height: 0, width: 0),
//                             HideWidget(
//                               hide: widget.requestModel.requestType != RequestType.BORROW,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     S.of(context).borrow,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Europa',
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                   HideWidget(
//                                     hide: widget.requestModel.roomOrTool ==
//                                         LendingType.PLACE.readable,
//                                     child: Text(
//                                       S.of(context).select_a_item_lending,
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         //fontWeight: FontWeight.bold,
//                                         fontFamily: 'Europa',
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 10,
//                                   ),
//                                   HideWidget(
//                                     hide: widget.requestModel.roomOrTool ==
//                                         LendingType.PLACE.readable,
//                                     child: SelectBorrowItem(
//                                       selectedItems: widget.requestModel.borrowModel.requiredItems,
//                                       onSelectedItems: (items) =>
//                                           {widget.requestModel.borrowModel.requiredItems = items},
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(height: 30),

//                             OfferDurationWidget(
//                                 title: S.of(context).request_duration,
//                                 startTime: startDate,
//                                 endTime: endDate),

//                             widget.requestModel.requestType == RequestType.TIME
//                                 ? TimeRequest(snapshot, projectModelList)
//                                 : widget.requestModel.requestType == RequestType.CASH
//                                     ? CashRequest(snapshot, projectModelList)
//                                     : widget.requestModel.requestType ==
//                                             RequestType.ONE_TO_MANY_REQUEST
//                                         ? TimeRequest(snapshot, projectModelList)
//                                         : widget.requestModel.requestType == RequestType.BORROW
//                                             ? BorrowRequest(snapshot, projectModelList)
//                                             : GoodsRequest(snapshot, projectModelList),

//                             SizedBox(height: 20),

//                             widget.requestModel.requestType != RequestType.BORROW
//                                 ? Center(
//                                     child: LocationPickerWidget(
//                                       selectedAddress: selectedAddress,
//                                       location: location,
//                                       onChanged: (LocationDataModel dataModel) {
//                                         log("received data model");
//                                         setState(() {
//                                           widget.requestModel.location = dataModel.geoPoint;
//                                           widget.requestModel.address = dataModel.location;

//                                           location = dataModel.geoPoint;
//                                           this.selectedAddress = dataModel.location;
//                                         });
//                                       },
//                                     ),
//                                   )
//                                 : Container(),

//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               child: OpenScopeCheckBox(
//                                 infoType: InfoType.VirtualRequest,
//                                 isChecked: widget.requestModel.virtualRequest,
//                                 checkBoxTypeLabel: CheckBoxType.type_VirtualRequest,
//                                 onChangedCB: (bool val) {
//                                   if (widget.requestModel.virtualRequest != val) {
//                                     widget.requestModel.virtualRequest = val;
//                                     if (val) {
//                                       isPublicCheckboxVisible = true;
//                                     } else {
//                                       isPublicCheckboxVisible = false;
//                                       widget.requestModel.public = false;
//                                     }

//                                     log('value ${widget.requestModel.virtualRequest}');
//                                     setState(() {});
//                                   }
//                                 },
//                               ),
//                             ),
//                             HideWidget(
//                               hide: !isPublicCheckboxVisible ||
//                                   widget.requestModel.requestMode != RequestMode.TIMEBANK_REQUEST,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 10),
//                                 child: TransactionsMatrixCheck(
//                                   comingFrom: ComingFrom.Requests,
//                                   upgradeDetails:
//                                       AppConfig.upgradePlanBannerModel.public_to_sevax_global,
//                                   transaction_matrix_type: 'create_public_request',
//                                   child: OpenScopeCheckBox(
//                                       infoType: InfoType.OpenScopeRequest,
//                                       isChecked: widget.requestModel.public,
//                                       checkBoxTypeLabel: CheckBoxType.type_Requests,
//                                       onChangedCB: (bool val) {
//                                         if (widget.requestModel.public != val) {
//                                           widget.requestModel.public = val;
//                                           log('value ${widget.requestModel.public}');
//                                           setState(() {});
//                                         }
//                                       }),
//                                 ),
//                               ),
//                             ),

//                             Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 30.0),
//                               child: Center(
//                                 child: Container(
//                                   // width: 150,
//                                   child: CustomElevatedButton(
//                                     onPressed: editRequest,
//                                     child: Text(
//                                       S.of(context).update_request.padLeft(10).padRight(10),
//                                       style: Theme.of(context).primaryTextTheme.button,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               });
//         });
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

//   Widget RequestGoodsDescriptionData() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       Text(
//         S.of(context).request_goods_description,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       GoodsDynamicSelection(
//         goodsbefore: widget.requestModel.goodsDonationDetails.requiredGoods,
//         onSelectedGoods: (goods) =>
//             {widget.requestModel.goodsDonationDetails.requiredGoods = goods},
//       ),
//       Text(
//         S.of(context).request_goods_address,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       Text(
//         S.of(context).request_goods_address_hint,
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 2, value);
//         },
//         focusNode: focusNodes[8],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[8]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: S.of(context).request_goods_address_inputhint,
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.goodsDonationDetails.address,
//         keyboardType: TextInputType.multiline,
//         maxLines: 3,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else {
//             widget.requestModel.goodsDonationDetails.address = value;
// //                setState(() {});
//           }
//           return null;
//         },
//       ),
//     ]);
//   }

//   Widget RequestPaymentACH() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_payment_ach_bank_name,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         initialValue: widget.requestModel.cashModel.achdetails.bank_name,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 3, value);
//         },
//         focusNode: focusNodes[12],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[13]);
//         },
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else if (!value.isEmpty) {
//             widget.requestModel.cashModel.achdetails.bank_name = value;
//           } else {
//             return S.of(context).enter_valid_bank_name;
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_payment_ach_bank_address,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         initialValue: widget.requestModel.cashModel.achdetails.bank_address,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 4, value);
//         },
//         focusNode: focusNodes[13],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[14]);
//         },
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else if (!value.isEmpty) {
//             widget.requestModel.cashModel.achdetails.bank_address = value;
//           } else {
//             return S.of(context).enter_valid_bank_address;
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_payment_ach_routing_number,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         initialValue: widget.requestModel.cashModel.achdetails.routing_number,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 5, value);
//         },
//         focusNode: focusNodes[14],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[15]);
//         },
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else if (!value.isEmpty) {
//             widget.requestModel.cashModel.achdetails.routing_number = value;
//           } else {
//             return S.of(context).enter_valid_routing_number;
//           }
//           return null;
//         },
//       ),
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_payment_ach_account_no,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         initialValue: widget.requestModel.cashModel.achdetails.account_number,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 6, value);
//         },
//         focusNode: focusNodes[15],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[15]);
//         },
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         onSaved: (value) {
//           widget.requestModel.cashModel.achdetails.account_number = value;
//         },
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else if (!value.isEmpty) {
//             widget.requestModel.cashModel.achdetails.account_number = value;
//           } else {
//             return S.of(context).enter_valid_account_number;
//           }
//           return null;
//         },
//       )
//     ]);
//   }

//   RegExp emailPattern =
//       RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
//   String mobilePattern = r'^[0-9]+$';

//   Widget RequestPaymentZellePay() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 7, value);
//         },
//         focusNode: focusNodes[12],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[12]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: S.of(context).request_payment_descriptionZelle_inputhint,
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.cashModel.zelleId != null
//             ? widget.requestModel.cashModel.zelleId
//             : '',
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         onSaved: (value) {
//           widget.requestModel.cashModel.zelleId = value;
//         },
//         validator: (value) {
//           return _validateEmailAndPhone(value);
//         },
//       )
//     ]);
//   }

//   String _validateEmailAndPhone(String value) {
//     RegExp regExp = RegExp(mobilePattern);
//     if (value.isEmpty) {
//       return S.of(context).validation_error_general_text;
//     } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
//       widget.requestModel.cashModel.zelleId = value;

//       return null;
//     } else {
//       return S.of(context).enter_valid_link;
//     }
//     return null;
//   }

//   Widget RequestPaymentPaypal() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {
//           updateExitWithConfirmationValue(context, 8, value);
//         },
//         focusNode: focusNodes[12],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[12]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: 'Ex: Paypal ID (phone or email)',
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.cashModel.paypalId != null
//             ? widget.requestModel.cashModel.paypalId
//             : '',
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         onSaved: (value) {
//           widget.requestModel.cashModel.paypalId = value;
//         },
//         validator: (value) {
//           RegExp regExp = RegExp(mobilePattern);
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
//             widget.requestModel.cashModel.paypalId = value;
//             return null;
//           } else {
//             return S.of(context).enter_valid_link;
//           }
//         },
//       )
//     ]);
//   }

//   Widget RequestPaymentVenmo() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {},
//         focusNode: focusNodes[12],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[12]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: S.of(context).venmo_hint,
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.cashModel.venmoId ?? '',
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         onSaved: (value) {
//           widget.requestModel.cashModel.venmoId = value;
//         },
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_general_text;
//           } else {
//             widget.requestModel.cashModel.venmoId = value;
//             return null;
//           }
//         },
//       )
//     ]);
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
//           S.of(context).request_payment_description_hint,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey,
//           ),
//         ),
//         _optionRadioButton(
//           title: S.of(context).request_paymenttype_ach,
//           value: RequestPaymentType.ACH,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             widget.requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton(
//             title: S.of(context).request_paymenttype_paypal,
//             value: RequestPaymentType.PAYPAL,
//             groupvalue: requestModel.cashModel.paymentType,
//             onChanged: (value) {
//               widget.requestModel.cashModel.paymentType = value;
//               setState(() => {});
//             }),
//         _optionRadioButton(
//           title: 'Swift',
//           value: RequestPaymentType.SWIFT,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             widget.requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         _optionRadioButton(
//             title: 'Venmo',
//             value: RequestPaymentType.VENMO,
//             groupvalue: requestModel.cashModel.paymentType,
//             onChanged: (value) {
//               widget.requestModel.cashModel.paymentType = value;
//               setState(() => {});
//             }),
//         _optionRadioButton(
//             title: S.of(context).request_paymenttype_zellepay,
//             value: RequestPaymentType.ZELLEPAY,
//             groupvalue: requestModel.cashModel.paymentType,
//             onChanged: (value) {
//               widget.requestModel.cashModel.paymentType = value;
//               setState(() => {});
//             }),
//         _optionRadioButton(
//           title: S.of(context).other(1),
//           value: RequestPaymentType.OTHER,
//           groupvalue: requestModel.cashModel.paymentType,
//           onChanged: (value) {
//             widget.requestModel.cashModel.paymentType = value;
//             setState(() => {});
//           },
//         ),
//         getPaymentInformation,
//       ],
//     );
//   }

//   Widget OtherDetailsWidget() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       Text(
//         S.of(context).other_payment_name,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {},
//         focusNode: focusNodes[0],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).autofocus(focusNodes[17]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: 'Provide other payment mode details',
//           hintStyle: hintTextStyle,
//         ),
//         keyboardType: TextInputType.multiline,
//         initialValue: widget.requestModel.cashModel.others != null
//             ? widget.requestModel.cashModel.others
//             : '',
//         maxLines: 1,
//         onSaved: (value) {
//           widget.requestModel.cashModel.others = value;
//         },
//         validator: (value) {
//           if (value.isEmpty || value == null) {
//             return S.of(context).validation_error_general_text;
//           }
//           if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
//             return S.of(context).profanity_text_alert;
//           } else {
//             widget.requestModel.cashModel.others = value;
//             return null;
//           }
//         },
//       ),
//       SizedBox(
//         height: 10,
//       ),
//       Text(
//         S.of(context).other_payment_details,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         focusNode: focusNodes[17],
//         onChanged: (value) {},
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).unfocus();
//         },
//         textInputAction: TextInputAction.next,
//         keyboardType: TextInputType.multiline,
//         minLines: 5,
//         maxLines: null,
//         onSaved: (value) {
//           widget.requestModel.cashModel.other_details = value;
//         },
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: S.of(context).other_payment_details_hint,
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.cashModel.other_details != null
//             ? widget.requestModel.cashModel.other_details
//             : '',
//         validator: (value) {
//           if (value.isEmpty || value == null) {
//             return S.of(context).validation_error_general_text;
//           }
//           if (!value.isEmpty && profanityDetector.isProfaneString(value)) {
//             return S.of(context).profanity_text_alert;
//           } else {
//             widget.requestModel.cashModel.other_details = value;
//             return null;
//           }
//         },
//       ),
//     ]);
//   }

//   Widget get getPaymentInformation {
//     switch (widget.requestModel.cashModel.paymentType) {
//       case RequestPaymentType.ACH:
//         return RequestPaymentACH();

//       case RequestPaymentType.PAYPAL:
//         return RequestPaymentPaypal();

//       case RequestPaymentType.ZELLEPAY:
//         return RequestPaymentZellePay();

//       case RequestPaymentType.VENMO:
//         return RequestPaymentVenmo();
//       case RequestPaymentType.SWIFT:
//         return RequestPaymentSwift();
//       case RequestPaymentType.OTHER:
//         return OtherDetailsWidget();

//       default:
//         return RequestPaymentACH();
//     }
//   }

//   Widget RequestPaymentSwift() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       TextFormField(
//         autovalidateMode: AutovalidateMode.onUserInteraction,
//         onChanged: (value) {},
//         focusNode: focusNodes[12],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).requestFocus(focusNodes[12]);
//         },
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//           errorMaxLines: 2,
//           hintText: 'Ex: Swift ID',
//           hintStyle: hintTextStyle,
//         ),
//         initialValue: widget.requestModel.cashModel.swiftId != null
//             ? widget.requestModel.cashModel.swiftId
//             : "",
//         keyboardType: TextInputType.multiline,
//         maxLines: 1,
//         maxLength: 11,
//         onSaved: (value) {
//           widget.requestModel.cashModel.swiftId = value;
//         },
//         validator: (value) {
//           if (value.isEmpty) {
//             return 'ID cannot be empty';
//           } else if (value.length < 8) {
//             return 'Enter valid Swift ID';
//           } else {
//             widget.requestModel.cashModel.swiftId = value;
//             return null;
//           }
//         },
//       )
//     ]);
//   }

//   //  Widget BorrowToolTitleField(hintTextDesc) {
//   //   return Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: <Widget>[
//   //         Text(
//   //           "Tool Name*",
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
//   //           initialValue: widget.requestModel.borrowRequestToolName,
//   //           keyboardType: TextInputType.multiline,
//   //           maxLines: 1,
//   //           validator: (value) {
//   //             if (value.isEmpty) {
//   //               return S.of(context).validation_error_general_text;
//   //             }
//   //             if (profanityDetector.isProfaneString(value)) {
//   //               return S.of(context).profanity_text_alert;
//   //             }
//   //             widget.requestModel.borrowRequestToolName = value;
//   //           },
//   //         ),
//   //       ]);
//   // }

//   Widget RequestDescriptionData(hintTextDesc) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Text(
//           S.of(context).request_description,
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
//             if (value != null && value.length > 1) {
//               _debouncer.run(() {
//                 getCategoriesFromApi(value);
//               });
//             }
//             updateExitWithConfirmationValue(context, 9, value);

//             setState(() {
//               initialRequestDescription = value;
//             });
//           },
//           focusNode: focusNodes[0],
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).requestFocus(focusNodes[1]);
//           },
//           textInputAction: TextInputAction.next,
//           maxLength: 500,
//           decoration: InputDecoration(
//             errorMaxLines: 2,
//             hintText: hintTextDesc,
//             hintStyle: hintTextStyle,
//           ),
//           initialValue: widget.requestModel.description,
//           keyboardType: TextInputType.multiline,
//           maxLines: 1,
//           validator: (value) {
//             if (value.isEmpty) {
//               return S.of(context).validation_error_general_text;
//             }
//             if (profanityDetector.isProfaneString(value)) {
//               return S.of(context).profanity_text_alert;
//             }
//             //widget.requestModel.description = value;
//             initialRequestDescription = value;
//           },
//         ),
//       ],
//     );
//   }

//   Widget RequestTypeWidget() {
//     return widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
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
//                   _optionRadioButton(
//                     title: S.of(context).request_type_time,
//                     value: RequestType.TIME,
//                     groupvalue: widget.requestModel.requestType,
//                     onChanged: (value) {
//                       //instructorAdded = false;
//                       //widget.requestModel.selectedInstructor.clear();
//                       widget.requestModel.requestType = value;
//                       setState(() => {});
//                     },
//                   ),
//                   _optionRadioButton(
//                     title: S.of(context).one_to_many,
//                     value: RequestType.ONE_TO_MANY_REQUEST,
//                     groupvalue: widget.requestModel.requestType,
//                     onChanged: (value) {
//                       widget.requestModel.requestType = value;
//                       //instructorAdded = true;
//                       // widget.requestModel.selectedInstructor = ({
//                       //   'fullname': widget.userModel.fullname,
//                       //   'email': widget.userModel.email,
//                       //   'photoURL': widget.userModel.photoURL,
//                       //   'sevaUserID': widget.userModel.sevaUserID,
//                       // });
//                       setState(() => {});
//                     },
//                   ),
//                   _optionRadioButton(
//                       title: S.of(context).request_type_cash,
//                       value: RequestType.CASH,
//                       groupvalue: widget.requestModel.requestType,
//                       onChanged: (value) {
//                         widget.requestModel.requestType = value;
//                         setState(() => {});
//                       }),
//                   _optionRadioButton(
//                       title: S.of(context).request_type_goods,
//                       value: RequestType.GOODS,
//                       groupvalue: widget.requestModel.requestType,
//                       onChanged: (value) {
//                         widget.requestModel.requestType = value;
//                         setState(() => {});
//                       }),
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
//         "https://proxy.sevaexchange.com/" + "http://ai.api.sevaxapp.com/request_categories",
//         headers: {
//           "Content-Type": "application/json",
//           "Access-Control": "Allow-Headers",
//           "x-requested-with": "x-requested-by"
//         },
//         body: jsonEncode({
//           "description": query,
//         }),
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> bodyMap = json.decode(response.body);
//         List<String> categoriesList =
//             bodyMap.containsKey('string_vec') ? List.castFrom(bodyMap['string_vec']) : [];
//         if (categoriesList != null && categoriesList.length > 0) {
//           getCategoryModels(categoriesList, S.of(context).suggested_categories);
//         }
//       } else {
//         return null;
//       }
//     } catch (exception) {
//       log(exception.toString());
//       return null;
//     }
//   }

//   Future<void> getCategoryModels(List<String> categoriesList, String title) async {
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
//               )),
//     );

//     if (category != null) {
//       categoryMode = category[0];
//       updateInformation(category[1]);
//     }
//     log(' poped selectedCategory  => ${category[0]} \n poped selectedSubCategories => ${category[1]} ');
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
//               padding: const EdgeInsets.only(top: 3.5, bottom: 5, left: 9, right: 9),
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
//                         subCategories.removeWhere((category) => category.typeId == item.typeId);
//                       });
//                     },
//                     child: Icon(Icons.cancel_rounded, color: Colors.grey[100], size: 28),
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

//   Widget TimeRequest(snapshot, projectModelList) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         RequestDescriptionData(S.of(context).request_description_hint),
//         SizedBox(height: 20),
//         categoryWidget(),

//         SizedBox(height: 20),
//         isFromRequest(
//           projectId: widget.projectId,
//         )
//             ? addToProjectContainer(
//                 snapshot,
//                 projectModelList,
//                 requestModel,
//               )
//             : Container(),
//         SizedBox(height: 20),
//         AddImagesForRequest(
//           onLinksCreated: (List<String> imageUrls) {
//             widget.requestModel.imageUrls = imageUrls;
//           },
//           selectedList: widget.requestModel.imageUrls,
//         ),
//         SizedBox(height: 20),
//         Text(
//           S.of(context).max_credits,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: TextFormField(
//                 focusNode: focusNodes[1],
//                 onFieldSubmitted: (v) {
//                   FocusScope.of(context).requestFocus(focusNodes[2]);
//                 },
//                 initialValue: widget.requestModel.maxCredits.toString(),
//                 onChanged: (v) {
//                   logger.i("___________>>> Updating credits to ============");

//                   updateExitWithConfirmationValue(context, 10, v);
//                   if (v.isNotEmpty && int.parse(v) >= 0) {
//                     //widget.requestModel.maxCredits = int.parse(v);
//                     logger.i("___________>>> Updating credits to " + int.parse(v).toString());

//                     tempCredits = int.parse(v);
//                     setState(() {});
//                   }
//                 },
//                 decoration: InputDecoration(
//                   hintText: requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//                       ? S.of(context).onetomanyrequest_participants_or_credits_hint
//                       : S.of(context).max_credit_hint,
//                   hintStyle: hintTextStyle,
//                   // labelText: 'No. of volunteers',
//                 ),
//                 textInputAction: TextInputAction.next,
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value.isEmpty) {
//                     return S.of(context).enter_max_credits;
//                   } else if (int.parse(value) < 0) {
//                     return S.of(context).enter_max_credits;
//                   } else if (int.parse(value) == 0) {
//                     return S.of(context).enter_max_credits;
//                   } else {
//                     //requestModel.maxCredits = int.parse(value);
//                     tempCredits = int.parse(value);
//                     setState(() {});
//                     return null;
//                   }
//                 },
//               ),
//             ),
//             infoButton(
//               context: context,
//               key: GlobalKey(),
//               type: InfoType.MAX_CREDITS,
//             ),
//           ],
//         ),
//         SizedBox(height: 20),
//         Text(
//           S.of(context).number_of_volunteers,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           focusNode: focusNodes[2],
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           initialValue: widget.requestModel.numberOfApprovals.toString(),
//           onChanged: (v) {
//             updateExitWithConfirmationValue(context, 11, v);
//             if (v.isNotEmpty && int.parse(v) >= 0) {
//               //widget.requestModel.numberOfApprovals = int.parse(v);
//               tempNoOfVolunteers = int.parse(v);
//               setState(() {});
//             }
//           },
//           decoration: InputDecoration(
//             hintText: requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//                 ? S.of(context).onetomanyrequest_participants_or_credits_hint
//                 : S.of(context).number_of_volunteers,
//             hintStyle: hintTextStyle,
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.number,
//           validator: (value) {
//             if (value.isEmpty) {
//               return S.of(context).validation_error_volunteer_count;
//             } else if (int.parse(value) < 0) {
//               return S.of(context).validation_error_volunteer_count_negative;
//             } else if (int.parse(value) == 0) {
//               return S.of(context).validation_error_volunteer_count_zero;
//             } else {
//               //widget.requestModel.numberOfApprovals = int.parse(value);
//               tempNoOfVolunteers = int.parse(value);
//               setState(() {});
//               return null;
//             }
//           },
//         ),
//         CommonUtils.TotalCredits(
//           context: context,
//           requestCreditsMode: TotalCreditseMode.EDIT_MODE,
//           requestModel: widget.requestModel,
//         ),
//         SizedBox(height: 10),

//         // requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST
//         //     ? Row(
//         //         children: [
//         //           Checkbox(
//         //             activeColor: Theme.of(context).primaryColor,
//         //             checkColor: Colors.white,
//         //             value: createEvent,
//         //             onChanged: (val) {
//         //               setState(() {
//         //                 createEvent = val;
//         //               });
//         //             },
//         //           ),
//         //           Text(
//         //               'Tick to create an event for this request')
//         //         ],
//         //       )
//         //     : Container(height: 0, width: 0),

//         SizedBox(height: 15),
//       ],
//     );
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
//             ],
//           ),
//           SizedBox(height: 20),
//           selectedCategoryModels != null && selectedCategoryModels.length > 0
//               ? Wrap(
//                   alignment: WrapAlignment.start,
//                   crossAxisAlignment: WrapCrossAlignment.start,
//                   children: _buildselectedSubCategories(),
//                 )
//               : Container(),
//         ],
//       ),
//       onTap: () => moveToCategory(),
//     );
//   }

//   Widget BorrowRequest(snapshot, projectModelList) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       RequestDescriptionData(S.of(context).request_description_hint_text_borrow),
//       SizedBox(height: 20), //Same hint for Room and Tools ?
//       // Choose Category and Sub Category
//       categoryWidget(),
//       SizedBox(height: 20),
//       isFromRequest(
//         projectId: widget.projectId,
//       )
//           ? addToProjectContainer(
//               snapshot,
//               projectModelList,
//               widget.requestModel,
//             )
//           : Container(),

//       SizedBox(height: 15),

//       Text(
//         S.of(context).location,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       SizedBox(height: 10),

//       Text(
//         S.of(context).provide_address,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.grey,
//         ),
//       ),

//       SizedBox(height: 10),

//       Center(
//         child: LocationPickerWidget(
//           selectedAddress: selectedAddress,
//           location: location,
//           onChanged: (LocationDataModel dataModel) {
//             log("received data model");
//             setState(() {
//               location = dataModel.geoPoint;
//               this.selectedAddress = dataModel.location;
//             });
//           },
//         ),
//       )
//     ]);
//   }

//   Widget CashRequest(snapshot, projectModelList) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_target_donation,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         focusNode: focusNodes[5],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).unfocus();
//         },
//         initialValue: widget.requestModel.cashModel.targetAmount.toString(),
//         onChanged: (v) {
//           updateExitWithConfirmationValue(context, 12, v);
//           if (v.isNotEmpty && int.parse(v) >= 0) {
//             widget.requestModel.cashModel.targetAmount = int.parse(v);
//             setState(() {});
//           }
//         },
//         decoration: InputDecoration(
//           hintText: S.of(context).request_target_donation_hint,
//           hintStyle: hintTextStyle,
//           prefixIcon: Icon(Icons.attach_money),

//           // labelText: 'No. of volunteers',
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(
//             (RegExp("[0-9]")),
//           ),
//         ],
//         keyboardType: TextInputType.number,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_target_donation_count;
//           } else if (int.parse(value) < 0) {
//             return S.of(context).validation_error_target_donation_count_negative;
//           } else if (int.parse(value) == 0) {
//             return S.of(context).validation_error_target_donation_count_zero;
//           } else {
//             widget.requestModel.cashModel.targetAmount = int.parse(value);
//             setState(() {});
//             return null;
//           }
//         },
//       ),
//       SizedBox(height: 20),
//       Text(
//         S.of(context).request_min_donation,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//       TextFormField(
//         focusNode: focusNodes[6],
//         onFieldSubmitted: (v) {
//           FocusScope.of(context).unfocus();
//         },
//         initialValue: widget.requestModel.cashModel.minAmount.toString(),
//         onChanged: (v) {
//           updateExitWithConfirmationValue(context, 13, v);
//           if (v.isNotEmpty && int.parse(v) >= 0) {
//             widget.requestModel.cashModel.minAmount = int.parse(v);
//             setState(() {});
//           }
//         },
//         decoration: InputDecoration(
//           hintText: S.of(context).request_min_donation_hint,
//           hintStyle: hintTextStyle,
//           // labelText: 'No. of volunteers',
//           prefixIcon: Icon(Icons.attach_money),

//           // labelText: 'No. of volunteers',
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(
//             (RegExp("[0-9]")),
//           ),
//         ],
//         keyboardType: TextInputType.number,
//         validator: (value) {
//           if (value.isEmpty) {
//             return S.of(context).validation_error_min_donation_count;
//           } else if (int.parse(value) < 0) {
//             return S.of(context).validation_error_min_donation_count_negative;
//           } else if (int.parse(value) == 0) {
//             return S.of(context).validation_error_min_donation_count_zero;
//           } else {
//             widget.requestModel.cashModel.minAmount = int.parse(value);
//             setState(() {});
//             return null;
//           }
//         },
//       ),
//       SizedBox(height: 20),
//       RequestDescriptionData(S.of(context).request_description_hint_cash),
//       SizedBox(height: 20),
//       AddImagesForRequest(
//         onLinksCreated: (List<String> imageUrls) {
//           widget.requestModel.imageUrls = imageUrls;
//         },
//         selectedList: widget.requestModel.imageUrls,
//       ),
//       SizedBox(height: 20),
//       categoryWidget(),
//       SizedBox(height: 20),
//       isFromRequest(
//         projectId: widget.projectId,
//       )
//           ? addToProjectContainer(
//               snapshot,
//               projectModelList,
//               widget.requestModel,
//             )
//           : Container(),
//       SizedBox(height: 20),
//       RequestPaymentDescriptionData(widget.requestModel),
//     ]);
//   }

//   Widget GoodsRequest(snapshot, projectModelList) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
//       SizedBox(height: 20),
//       RequestDescriptionData(S.of(context).request_description_hint_goods),
//       SizedBox(height: 20),
//       categoryWidget(),
//       SizedBox(height: 20),
//       AddImagesForRequest(
//         onLinksCreated: (List<String> imageUrls) {
//           widget.requestModel.imageUrls = imageUrls;
//         },
//         selectedList: widget.requestModel.imageUrls,
//       ),
//       SizedBox(height: 20),
//       isFromRequest(
//         projectId: widget.projectId,
//       )
//           ? addToProjectContainer(
//               snapshot,
//               projectModelList,
//               widget.requestModel,
//             )
//           : Container(),
//       SizedBox(height: 20),
//       RequestGoodsDescriptionData(),
//     ]);
//   }

//   bool isFromRequest({String projectId}) {
//     return projectId == null || projectId.isEmpty || projectId == "";
//   }

//   Widget _optionRadioButton({String title, value, groupvalue, Function onChanged}) {
//     return ListTile(
//       contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
//       title: Text(title),
//       leading: Radio(value: value, groupValue: groupvalue, onChanged: onChanged),
//     );
//   }

//   Widget requestSwitch() {
//     if (widget.projectId == null || widget.projectId.isEmpty || widget.projectId == "") {
//       return Container(
//         margin: EdgeInsets.only(bottom: 20),
//         width: double.infinity,
//         child: CupertinoSegmentedControl<int>(
//           selectedColor: Theme.of(context).primaryColor,
//           children: {
//             0: Text(
//               S.of(context).timebank_request(1),
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
//                   widget.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//                 } else {
//                   widget.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//                   widget.requestModel.requestType = RequestType.TIME;
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
//           widget.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
//         } else {
//           widget.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
//           widget.requestModel.requestType = RequestType.TIME;
//         }
//       }
//       return Container();
//     }
//   }

//   BuildContext dialogContext;

//   void editRequest() async {
//     logger.e('Project ID:  ' + tempProjectId.toString());
//     // verify f the start and end date time is not same

//     var connResult = await Connectivity().checkConnectivity();
//     if (connResult == ConnectivityResult.none) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(S.of(context).check_internet),
//           action: SnackBarAction(
//             label: S.of(context).dismiss,
//             onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//           ),
//         ),
//       );
//       return;
//     }

//     if (_formKey.currentState.validate()) {
//       if (widget.requestModel.public) {
//         widget.requestModel.timebanksPosted = [
//           widget.requestModel.timebankId,
//           FlavorConfig.values.timebankId
//         ];
//       } else {
//         widget.requestModel.timebanksPosted = [widget.requestModel.timebankId];
//       }

//       if (widget.requestModel.requestType == RequestType.GOODS &&
//           (widget.requestModel.goodsDonationDetails.requiredGoods == null ||
//               widget.requestModel.goodsDonationDetails.requiredGoods.isEmpty)) {
//         showDialogForTitle(dialogTitle: S.of(context).goods_validation);
//         return;
//       }
//       if (widget.requestModel.requestType == RequestType.BORROW &&
//           roomOrTool == 1 && //because was throwing dialog when creating for place
//           (widget.requestModel.borrowModel.requiredItems == null ||
//               widget.requestModel.borrowModel.requiredItems.isEmpty)) {
//         showDialogForTitle(dialogTitle: S.of(context).items_validation);
//         return;
//       }
//       if (widget.requestModel.isRecurring == true || widget.requestModel.autoGenerated == true) {
//         EditRepeatWidgetState.recurringDays = EditRepeatWidgetState.getRecurringdays();
//         // end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
//         // end.on = end.endType == "on"
//         //     ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch
//         //     : null;
//         // end.after = (end.endType == "after"
//         //     ? int.parse(EditRepeatWidgetState.after)
//         //     : 1);
//         // widget.requestModel.end = end;
//       }

//       if (widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
//         var onBalanceCheckResult;
//         if (widget.requestModel.isRecurring == true || widget.requestModel.autoGenerated == true) {
//           int recurrences = widget.requestModel.end.endType == "after"
//               ? (widget.requestModel.end.after - widget.requestModel.occurenceCount).abs()
//               : calculateRecurrencesOnMode(widget.requestModel);
//           onBalanceCheckResult = await SevaCreditLimitManager.hasSufficientCredits(
//             email: SevaCore.of(context).loggedInUser.email,
//             userId: SevaCore.of(context).loggedInUser.sevaUserID,
//             credits: widget.requestModel.isRecurring
//                 ? widget.requestModel.numberOfHours.toDouble() * recurrences
//                 : widget.requestModel.numberOfHours.toDouble(),
//             communityId: widget.requestModel.communityId,
//           );
//         } else {
//           onBalanceCheckResult = await SevaCreditLimitManager.hasSufficientCredits(
//             email: SevaCore.of(context).loggedInUser.email,
//             userId: SevaCore.of(context).loggedInUser.sevaUserID,
//             credits: widget.requestModel.isRecurring
//                 ? widget.requestModel.numberOfHours.toDouble() * 0
//                 : widget.requestModel.numberOfHours.toDouble(),
//             communityId: widget.requestModel.communityId,
//           );
//         }

//         if (!onBalanceCheckResult.hasSuffiientCredits) {
//           showInsufficientBalance();
//           return;
//         }
//       }

//       logger.i("=============||||||===============");

//       /// TODO take language from Prakash
//       if (OfferDurationWidgetState.starttimestamp == OfferDurationWidgetState.endtimestamp) {
//         showDialogForTitle(dialogTitle: S.of(context).validation_error_same_start_date_end_date);
//         return;
//       }

//       if (OfferDurationWidgetState.starttimestamp == 0 ||
//           OfferDurationWidgetState.endtimestamp == 0) {
//         showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
//         return;
//       }

//       if (OfferDurationWidgetState.starttimestamp > OfferDurationWidgetState.endtimestamp) {
//         showDialogForTitle(dialogTitle: S.of(context).validation_error_end_date_greater);
//         return;
//       }

//       // if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//       //   List<String> approvedUsers = [];
//       //   approvedUsers.add(widget.requestModel.selectedInstructor.email);
//       //   widget.requestModel.approvedUsers = approvedUsers;
//       // }

//       if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST &&
//           (selectedInstructorModelTemp == {} ||
//               selectedInstructorModelTemp == null ||
//               instructorAdded == false)) {
//         showDialogForTitle(dialogTitle: S.of(context).select_a_speaker);
//         return;
//       }

//       //Calculate session duration of one to many request using request start and request end time
//       if (widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//         if (OfferDurationWidgetState.starttimestamp != null &&
//             OfferDurationWidgetState.endtimestamp != null) {
//           DateTime startDateNew =
//               DateTime.fromMillisecondsSinceEpoch(OfferDurationWidgetState.starttimestamp);
//           DateTime endDateNew =
//               DateTime.fromMillisecondsSinceEpoch(OfferDurationWidgetState.endtimestamp);

//           Duration sessionDuration = endDateNew.difference(startDateNew);
//           double sixty = 60;

//           logger.e('----------> Speaking Minutes: ' + sessionDuration.inMinutes.toString());

//           selectedSpeakerTimeDetails.speakingTime =
//               double.parse((sessionDuration.inMinutes / sixty).toStringAsPrecision(3));

//           //prep time will be entered by speaker when he/she is completing the request
//           // selectedSpeakerTimeDetails.prepTime = 0;

//           widget.requestModel.selectedSpeakerTimeDetails = selectedSpeakerTimeDetails;

//           setState(() {});
//         }
//       }

//       //comparing the recurring days List

//       Function eq = const ListEquality().equals;
//       bool recurrinDaysListsMatch =
//           eq(widget.requestModel.recurringDays, EditRepeatWidgetState.recurringDays);
//       log('Days Match:  ' + recurrinDaysListsMatch.toString());
//       String tempSelectedEndType =
//           EditRepeatWidgetState.endType == 0 ? S.of(context).on : S.of(context).after;

//       if (widget.requestModel.isRecurring == true || widget.requestModel.autoGenerated == true) {
//         if (!widget.requestModel.acceptors.contains(selectedInstructorModel?.email)) {
//           //setState(() {
//           widget.requestModel.title = initialRequestTitle;
//           widget.requestModel.description = initialRequestDescription;
//           widget.requestModel.location = location;
//           widget.requestModel.projectId = tempProjectId;
//           widget.requestModel.address = selectedAddress;
//           widget.requestModel.categories = selectedCategoryIds.toList();

//           widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
//           widget.requestModel.maxCredits = tempCredits;

//           startDate.millisecondsSinceEpoch != OfferDurationWidgetState.starttimestamp
//               ? widget.requestModel.requestStart = OfferDurationWidgetState.starttimestamp
//               : null;

//           endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp
//               ? widget.requestModel.requestEnd = OfferDurationWidgetState.endtimestamp
//               : null;
//           //});

//           if (selectedInstructorModel != null &&
//               selectedInstructorModel.sevaUserID != widget.requestModel.sevaUserId &&
//               !widget.requestModel.acceptors.contains(selectedInstructorModel.email) &&
//               widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//             //below is to update the invited speaker to inivted members list when speaker is changed
//             await reUpdateInvitedSpeakerForRequest(
//               requestID: widget.requestModel.id,
//               sevaUserIdPrevious: widget.requestModel.selectedInstructor.sevaUserID,
//               emailPrevious: widget.requestModel.selectedInstructor.email,
//               sevaUserIdNew: selectedInstructorModelTemp.sevaUserID,
//               emailNew: selectedInstructorModelTemp.email,
//             );

//             List<String> acceptorsList = [];
//             Set<String> invitedUsersList = Set.from(widget.requestModel.invitedUsers);
//             //remove old speaker from invitedUsers and add new speaker to invited users
//             invitedUsersList.remove(widget.requestModel.selectedInstructor.sevaUserID);
//             invitedUsersList.add(selectedInstructorModelTemp.sevaUserID);
//             //assign updated list to request model invited users
//             widget.requestModel.invitedUsers = invitedUsersList.toList();

//             acceptorsList.add(selectedInstructorModel.email);
//             widget.requestModel.acceptors = acceptorsList;
//             widget.requestModel.requestCreatorName = SevaCore.of(context).loggedInUser.fullname;
//             log('ADDED ACCEPTOR');

//             // update new speaker details
//             widget.requestModel.selectedInstructor = BasicUserDetails(
//               fullname: selectedInstructorModelTemp?.fullname,
//               email: selectedInstructorModelTemp?.email,
//               photoURL: selectedInstructorModelTemp?.photoURL,
//               sevaUserID: selectedInstructorModelTemp?.sevaUserID,
//             );

//             if (selectedInstructorModel.communities.contains(widget.requestModel.communityId)) {
//               speakerNotificationDocRefNew = await sendNotificationToMemberOneToManyRequest(
//                   communityId: widget.requestModel.communityId,
//                   timebankId: widget.requestModel.timebankId,
//                   sevaUserId: selectedInstructorModel.sevaUserID,
//                   userEmail: selectedInstructorModel.email,
//                   speakerNotificationDocRefOld:
//                       widget.requestModel.speakerInviteNotificationDocRef);
//             } else {
//               speakerNotificationDocRefNew = await sendNotificationToMemberOneToManyRequest(
//                   communityId: FlavorConfig.values.timebankId,
//                   timebankId: FlavorConfig.values.timebankId,
//                   sevaUserId: selectedInstructorModel.sevaUserID,
//                   userEmail: selectedInstructorModel.email,
//                   speakerNotificationDocRefOld:
//                       widget.requestModel.speakerInviteNotificationDocRef);
//               // send sevax global notification for user who is not part of the community for this request
//               await sendMailToInstructor(
//                   senderEmail: 'noreply@sevaexchange.com',
//                   //requestModel.email,
//                   receiverEmail: selectedInstructorModel.email,
//                   communityName: widget.requestModel.fullName,
//                   requestName: widget.requestModel.title,
//                   requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
//                   receiverName: selectedInstructorModel.fullname,
//                   startDate: widget.requestModel.requestStart,
//                   endDate: widget.requestModel.requestEnd);
//             }
//           }

//           //MIGRATE BELOW TO MOBILE
//           widget.requestModel.isRecurring = EditRepeatWidgetState.isRecurring;
//           widget.requestModel.end.after = int.parse(EditRepeatWidgetState.after);
//           widget.requestModel.end.endType = tempSelectedEndType;
//           widget.requestModel.recurringDays = EditRepeatWidgetState.recurringDays;
//           widget.requestModel.end.on = EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch;

//           return showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (BuildContext viewContext) {
//               return WillPopScope(
//                 onWillPop: () {},
//                 child: AlertDialog(
//                   title: Text("This is a repeating request."),
//                   actions: [
//                     CustomTextButton(
//                       child: Text(
//                         "Edit this request only.",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.red,
//                         ),
//                       ),
//                       onPressed: () async {
//                         Navigator.pop(viewContext);
//                         linearProgressForCreatingRequest();
//                         await updateRequest(requestModel: widget.requestModel);
//                         Navigator.pop(dialogContext);
//                         Navigator.pop(context);
//                       },
//                     ),
//                     CustomTextButton(
//                       child: Text(
//                         "Edit subsequent requests.",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.red,
//                         ),
//                       ),
//                       onPressed: () async {
//                         Navigator.pop(viewContext);
//                         linearProgressForCreatingRequest();
//                         await updateRequest(requestModel: widget.requestModel);
//                         await RequestManager.updateRecurrenceRequestsFrontEnd(
//                           updatedRequestModel: widget.requestModel,
//                           communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//                           timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
//                         );

//                         Navigator.pop(dialogContext);
//                         Navigator.pop(context);
//                       },
//                     ),
//                     CustomTextButton(
//                       child: Text(
//                         S.of(context).cancel,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.red,
//                         ),
//                       ),
//                       onPressed: () async {
//                         Navigator.pop(viewContext);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         }

//         logger.i("=============////////===============");

//         if (tempSelectedEndType != widget.requestModel.end.endType ||
//             widget.requestModel.end.after != int.parse(EditRepeatWidgetState.after) ||
//             widget.requestModel.end.on !=
//                 EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch ||
//             recurrinDaysListsMatch == false) {
//           //setState(() {
//           widget.requestModel.title = initialRequestTitle;
//           widget.requestModel.description = initialRequestDescription;
//           widget.requestModel.isRecurring = EditRepeatWidgetState.isRecurring;
//           widget.requestModel.end.after = int.parse(EditRepeatWidgetState.after);
//           widget.requestModel.end.endType = tempSelectedEndType;
//           widget.requestModel.recurringDays = EditRepeatWidgetState.recurringDays;
//           widget.requestModel.end.on = EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch;
//           //});

//           logger.i("=============IF===============");

//           linearProgressForCreatingRequest();
//           await updateRequest(requestModel: widget.requestModel);
//           await RequestManager.updateRecurrenceRequestsFrontEnd(
//             updatedRequestModel: widget.requestModel,
//             communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//             timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
//           );

//           Navigator.pop(dialogContext);
//           Navigator.pop(context);
//         } else {
//           Navigator.of(context).pop();
//         }
//       } else if (widget.requestModel.isRecurring == false &&
//           widget.requestModel.autoGenerated == false) {
//         // if (widget.requestModel.title != initialRequestTitle ||
//         //     startDate.millisecondsSinceEpoch !=
//         //         OfferDurationWidgetState.starttimestamp ||
//         //     endDate.millisecondsSinceEpoch !=
//         //         OfferDurationWidgetState.endtimestamp ||
//         //     widget.requestModel.description != initialRequestDescription ||
//         //     tempCredits != widget.requestModel.maxCredits ||
//         //     tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
//         //     location != widget.requestModel.location) {
//         log('HERE 1');

//         if (selectedInstructorModel != null &&
//             selectedInstructorModel.sevaUserID != widget.requestModel.sevaUserId &&
//             !widget.requestModel.acceptors.contains(selectedInstructorModel.email) &&
//             widget.requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
//           //below is to update the invited speaker to inivted members list when speaker is changed
//           await reUpdateInvitedSpeakerForRequest(
//             requestID: widget.requestModel.id,
//             sevaUserIdPrevious: widget.requestModel.selectedInstructor.sevaUserID,
//             emailPrevious: widget.requestModel.selectedInstructor.email,
//             sevaUserIdNew: selectedInstructorModelTemp.sevaUserID,
//             emailNew: selectedInstructorModelTemp.email,
//           );

//           List<String> acceptorsList = [];
//           Set<String> invitedUsersList = Set.from(widget.requestModel.invitedUsers);
//           //remove old speaker from invitedUsers and add new speaker to invited users
//           invitedUsersList.remove(widget.requestModel.selectedInstructor.sevaUserID);
//           invitedUsersList.add(selectedInstructorModelTemp.sevaUserID);
//           //assign updated list to request model invited users
//           widget.requestModel.invitedUsers = invitedUsersList.toList();

//           acceptorsList.add(selectedInstructorModel.email);
//           widget.requestModel.acceptors = acceptorsList;
//           widget.requestModel.requestCreatorName = SevaCore.of(context).loggedInUser.fullname;
//           log('ADDED ACCEPTOR');

//           // update new speaker details
//           widget.requestModel.selectedInstructor = BasicUserDetails(
//             fullname: selectedInstructorModelTemp?.fullname,
//             email: selectedInstructorModelTemp?.email,
//             photoURL: selectedInstructorModelTemp?.photoURL,
//             sevaUserID: selectedInstructorModelTemp?.sevaUserID,
//           );

//           if (selectedInstructorModel.communities.contains(widget.requestModel.communityId)) {
//             speakerNotificationDocRefNew = await sendNotificationToMemberOneToManyRequest(
//                 communityId: widget.requestModel.communityId,
//                 timebankId: widget.requestModel.timebankId,
//                 sevaUserId: selectedInstructorModel.sevaUserID,
//                 userEmail: selectedInstructorModel.email,
//                 speakerNotificationDocRefOld: widget.requestModel.speakerInviteNotificationDocRef);
//           } else {
//             // send sevax global notification for user who is not part of the community for this request
//             speakerNotificationDocRefNew = await sendNotificationToMemberOneToManyRequest(
//                 communityId: FlavorConfig.values.timebankId,
//                 timebankId: FlavorConfig.values.timebankId,
//                 sevaUserId: selectedInstructorModel.sevaUserID,
//                 userEmail: selectedInstructorModel.email,
//                 speakerNotificationDocRefOld: widget.requestModel.speakerInviteNotificationDocRef);
//             await sendMailToInstructor(
//                 senderEmail: 'noreply@sevaexchange.com',
//                 //requestModel.email,
//                 receiverEmail: selectedInstructorModel.email,
//                 communityName: widget.requestModel.fullName,
//                 requestName: widget.requestModel.title,
//                 requestCreatorName: SevaCore.of(context).loggedInUser.fullname,
//                 receiverName: selectedInstructorModel.fullname,
//                 startDate: widget.requestModel.requestStart,
//                 endDate: widget.requestModel.requestEnd);
//           }
//         }

//         //update current speaker notification document reference
//         widget.requestModel.speakerInviteNotificationDocRef = speakerNotificationDocRefNew;

//         widget.requestModel.title = initialRequestTitle;
//         widget.requestModel.description = initialRequestDescription;
//         widget.requestModel.location = location;
//         widget.requestModel.address = selectedAddress;
//         widget.requestModel.projectId = tempProjectId;
//         widget.requestModel.categories = selectedCategoryIds.toList();
//         startDate.millisecondsSinceEpoch != OfferDurationWidgetState.starttimestamp
//             ? widget.requestModel.requestStart = OfferDurationWidgetState.starttimestamp
//             : null;
//         endDate.millisecondsSinceEpoch != OfferDurationWidgetState.endtimestamp
//             ? widget.requestModel.requestEnd = OfferDurationWidgetState.endtimestamp
//             : null;
//         widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
//         widget.requestModel.maxCredits = tempCredits;

//         linearProgressForCreatingRequest();
//         await updateRequest(requestModel: widget.requestModel);

//         Navigator.pop(dialogContext);
//         Navigator.pop(context);
//       } else {
//         Navigator.of(context).pop();
//       }
//       //}
//     }
//   }

//   // Future _getLocation() async {
//   //   String address = await LocationUtility().getFormattedAddress(
//   //     location.latitude,
//   //     location.longitude,
//   //   );

//   //   setState(() {
//   //     this.selectedAddress = address;
//   //   });
//   // }

//   int calculateRecurrencesOnMode(RequestModel requestModel) {
//     DateTime eventStartDate = DateTime.fromMillisecondsSinceEpoch(requestModel.requestStart);
//     int recurrenceCount = 0;
//     bool lastRound = false;
//     while (lastRound == false) {
//       eventStartDate = DateTime(eventStartDate.year, eventStartDate.month, eventStartDate.day + 1,
//           eventStartDate.hour, eventStartDate.minute, eventStartDate.second);
//       if (eventStartDate.millisecondsSinceEpoch <= requestModel.end.on && recurrenceCount < 11) {
//         if (requestModel.recurringDays.contains(eventStartDate.weekday % 7)) {
//           recurrenceCount++;
//         }
//       } else {
//         lastRound = true;
//       }
//     }
//     log("on mode recurrence count isss $recurrenceCount");
//     return recurrenceCount;
//   }

//   bool hasRegisteredLocation() {
//     return location != null;
//   }

//   Future<DocumentReference> sendNotificationToMemberOneToManyRequest(
//       {String communityId,
//       String sevaUserId,
//       String timebankId,
//       String userEmail,
//       @required DocumentReference speakerNotificationDocRefOld}) async {
//     // UserAddedModel userAddedModel = UserAddedModel(
//     //     timebankImage: timebankModel.photoUrl,
//     //     timebankName: timebankModel.name,
//     //     adminName: SevaCore.of(context).loggedInUser.fullname);

//     //delete the previous speaker's notification document, since new speaker is invited here
//     try {
//       speakerNotificationDocRefOld.delete();
//     } catch (error) {
//       logger.e('did not find notification doc to delete');
//     }


//     NotificationsModel notification = NotificationsModel(
//         id: Utils.getUuid(),
//         timebankId: FlavorConfig.values.timebankId,
//         data: widget.requestModel.toMap(),
//         isRead: false,
//         isTimebankNotification: false,
//         type: NotificationType.OneToManyRequestAccept,
//         communityId: communityId,
//         senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//         targetUserId: sevaUserId);

//     await CollectionRef.users
//         .doc(userEmail)
//         .collection("notifications")
//         .doc(notification.id)
//         .set(notification.toMap());

//     log('WRITTEN TO DB--------------------->>');

//     return speakerNotificationDocRefNew =
//         CollectionRef.users.doc(userEmail).collection("notifications").doc(notification.id);
//   }

//   //if another speaker is invited then we need to remove the previous speaker from the invited list
// //re update the invited speaker
//   Future reUpdateInvitedSpeakerForRequest(
//       {String requestID,
//       String sevaUserIdPrevious,
//       String emailPrevious,
//       String sevaUserIdNew,
//       String emailNew}) async {
//     var batch = CollectionRef.batch;

//     //remove previous speaker as invited member
//     // batch.update(
//     //     CollectionRef.requests.doc(requestID), {
//     //   'invitedUsers': FieldValue.arrayRemove([sevaUserIdPrevious]),
//     // });
//     batch.update(
//       CollectionRef.users.doc(emailPrevious),
//       {
//         'invitedRequests': FieldValue.arrayRemove([requestID])
//       },
//     );

//     //Add new speaker as invited member
//     // batch.update(
//     //     CollectionRef.requests.doc(requestID), {
//     //   'invitedUsers': FieldValue.arrayUnion([sevaUserIdNew]),
//     // });
//     batch.update(
//       CollectionRef.users.doc(emailNew),
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
//     int startDate,
//     int endDate,
//   }) async {
//     return await SevaMailer.createAndSendEmail(
//         mailContent: MailContent.createMail(
//       mailSender: senderEmail,
//       mailReciever: receiverEmail,
//       mailSubject: requestCreatorName + ' from ' + communityName + ' has invited you',
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
// ,
//     ));
//   } //Label to be confirmed

//   // requestCreatorName + ' from ' + communityName + ' has invited you',
//   //     mailContent: 'You have been invited to instruct ' +
//   //         requestName +
//   //         ' from ' +
//   //         DateTime.fromMillisecondsSinceEpoch(startDate)
//   //             .toString()
//   //             .substring(0, 11) +
//   //         ' to ' +
//   //         DateTime.fromMillisecondsSinceEpoch(endDate)
//   //             .toString()
//   //             .substring(0, 11) +

//   void showInsufficientBalance() {
//     showDialog(
//         context: context,
//         builder: (BuildContext viewContext) {
//           return AlertDialog(
//             title: Text(S.of(context).insufficient_credits_for_request),
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

//   void linearProgressForCreatingRequest() {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (createDialogContext) {
//           dialogContext = createDialogContext;
//           return AlertDialog(
//             title: Text(S.of(context).updating_request),
//             content: LinearProgressIndicator(),
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

//           if (onActivityResult != null && onActivityResult.containsKey("membersSelected")) {
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

//   String getTimeInFormat(int timeStamp) {
//     return DateFormat('EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag()).format(
//       getDateTimeAccToUserTimezone(
//           dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
//           timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
//     );
//   }

//   bool hasSufficientBalance() {
//     var requestCoins = widget.requestModel.numberOfHours;
//     var lowerLimit = json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

//     var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
//     return requestCoins <= finalbalance;
//   }

//   Future _updateProjectModel() async {
//     if (widget.projectId.isNotEmpty && !widget.requestModel.isRecurring) {
//       ProjectModel projectModel = widget.projectModel;
// //      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
// //      if (!projectModel.members.contains(userSevaUserId)) {
// //        projectModel.members.add(userSevaUserId);
// //      }
//       projectModel.pendingRequests.add(widget.requestModel.id);
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
