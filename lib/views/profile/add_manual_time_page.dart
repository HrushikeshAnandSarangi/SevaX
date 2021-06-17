// import 'dart:async';
// import 'dart:core';
// import 'dart:developer';


// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:sevaexchange/auth/auth_provider.dart';
// import 'package:sevaexchange/auth/auth_router.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/notifications_model.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/new_baseline/models/add_manual_time_model.dart';
// import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
// import 'package:sevaexchange/utils/search_manager.dart';
// import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import 'package:sevaexchange/utils/utils.dart';

// class AddManualTimeWidget extends StatefulWidget {
//   final UserModel userModel;
//   AddManualTimeWidget({
//     @required this.userModel,
//   });

//   @override
//   _AddManualTimeWidgetState createState() => _AddManualTimeWidgetState();
// }

// class _AddManualTimeWidgetState extends State<AddManualTimeWidget> {
//   SuggestionsBoxController controller = SuggestionsBoxController();
//   TextEditingController _textEditingController = TextEditingController();
//   TimebankModel selectedTimebankModel = null;
//   AddManualTimeModel addManualTimeModel = AddManualTimeModel();

//   String noOfManualHours;
//   String errText;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: true,
//           title: Text("Add Manual time", style: TextStyle(fontSize: 18)),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 Container(
//                   padding: EdgeInsets.only(left: 25, right: 25),
//                   child: Text(
//                     "Select the community or group for which you wish to add manual time.",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black54,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Container(
//                     padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
//                   child: TypeAheadField<TimebankModel>(
//                     suggestionsBoxDecoration: SuggestionsBoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     textFieldConfiguration: TextFieldConfiguration(
//                       controller: _textEditingController,
//                       decoration: InputDecoration(
//                         hintText: S.of(context).search,
//                         filled: true,
//                         fillColor: Colors.grey[300],
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.white),
//                           borderRadius: BorderRadius.circular(25.7),
//                         ),
//                         enabledBorder: UnderlineInputBorder(
//                             borderSide: BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(25.7)),
//                         contentPadding:
//                             EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Colors.grey,
//                         ),
//                         suffixIcon: InkWell(
//                           splashColor: Colors.transparent,
//                           child: Icon(
//                             Icons.clear,
//                             color: Colors.grey,
//                           ),
//                           onTap: () {
//                             _textEditingController.clear();
//                             controller.close();
//                           },
//                         ),
//                       ),
//                     ),
//                     suggestionsBoxController: controller,
//                     suggestionsCallback: (pattern) async {
//                       return await SearchManager.searchTimebankModelsOfUserFuture(
//                           queryString: pattern, currentUser: widget.userModel);
//                     },
//                     itemBuilder: (context, suggestion) {
//                       // print("suggest ${suggestion}");
//                       return suggestion.name != null
//                           ? Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Text(
//                                 suggestion.name,
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             )
//                           : Offstage();
//                     },
//                     noItemsFoundBuilder: (context) {
//                       return Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Text(
//                           S.of(context).no_user_found,
//                           style: TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                       );
//                     },
//                     onSuggestionSelected: (suggestion) {
//                       selectedTimebankModel = suggestion;
//                       setState(() {});
//                       _textEditingController.clear();
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 selectedTimebankModel == null
//                   ? Container()
//                   : ListTile(title: Text(selectedTimebankModel.name)),
//                 SizedBox(height: 20),
//                 Row(
//                   children: [
//                     SizedBox(width:27),
//                     Container(
//                         width: 150,
//                         height:50,
//                         child: TextFormField(
//                             onChanged: (value) {
//                                 noOfManualHours = value;
//                                 setState((){});
//                             },
//                             inputFormatters: <TextInputFormatter>[
//                                 FilteringTextInputFormatter.digitsOnly
//                             ],
//                             decoration: InputDecoration(
//                                 hintText: "Enter the hours",
//                                 errorText: errText,
//                                 errorMaxLines: 2,
//                             border: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     const Radius.circular(8.0),
//                                 ),
//                                 borderSide: BorderSide(
//                                     color: Colors.black,
//                                     width: 0.5,
//                                 ),
//                             ),
//                             enabledBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     const Radius.circular(8.0),
//                                 ),
//                                 borderSide: BorderSide(
//                                     color: Colors.black,
//                                     width: 0.5,
//                                 ),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                     const Radius.circular(8.0),
//                                 ),
//                                 borderSide: BorderSide(
//                                     color: Colors.black,
//                                     width: 0.5,
//                                 ),
//                             ),
//                             ),
//                             keyboardType: TextInputType.number,
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 optionButtons(),
//               ],
//             ),
//           ),
//         ));
//   }

//   Widget optionButtons() {
//       return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//               CustomTextButton(
//                   child: Text(
//                       S.of(context).add,
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa')),
//                   textColor: FlavorConfig.values.theme.primaryColor,
//                   onPressed: () async {
//                       if(selectedTimebankModel == null){

//                           return;
//                       }
//                       if(noOfManualHours == null){

//                           return;
//                       }

//                       Navigator.pop(context);
//                       _showAddManualTimeConfirmationDialog(context);
//                   },
//               ),
//               CustomTextButton(
//                   onPressed: () {
//                       Navigator.pop(context);
//                   },
//                   child: Text(
//                       S.of(context).cancel,
//                       style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Europa'),
//                   ),
//                   textColor: Colors.grey,
//               ),

//           ],
//       );
//   }

//   void _showAddManualTimeConfirmationDialog(BuildContext parentContext) {
//       showDialog(
//           context: parentContext,
//           barrierDismissible: true,
//           builder: (_context) {
//               return AlertDialog(
//                   title: Text("Add Manual Time"),
//                   content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                           Text("Are you sure you want to add this time to this timebank ?"),
//                           SizedBox(
//                               height: 15,
//                           ),
//                           Row(
//                               children: <Widget>[
//                                   Spacer(),
//                                   CustomElevatedButton(
//                                       padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
//                                       color: Theme.of(context).accentColor,
//                                       textColor: FlavorConfig.values.buttonTextColor,
//                                       child: Text(
//                                           S.of(context).yes,
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: dialogButtonSize,
//                                           ),
//                                       ),
//                                       onPressed: () async {
//                                           Navigator.pop(_context);
//                                           await addManualTimeFunc();
//                                       },
//                                   ),
//                                   CustomTextButton(
//                                       child: Text(
//                                           S.of(context).no,
//                                           style: TextStyle(
//                                               color: Colors.red,
//                                               fontSize: dialogButtonSize,
//                                           ),
//                                       ),
//                                       onPressed: () => Navigator.pop(_context),
//                                   ),
//                               ],
//                           ),
//                       ],
//                   ),
//               );
//           },
//       );
//   }

//   Future<void> addManualTimeFunc() async {

//       addManualTimeModel.communityId = widget.userModel.currentCommunity;
//       addManualTimeModel.noOfHours = double.parse(noOfManualHours);
//       addManualTimeModel.timebankId = selectedTimebankModel.id;
//       addManualTimeModel.timestamp = DateTime.now().millisecondsSinceEpoch;
//       addManualTimeModel.seen = false;
//       addManualTimeModel.approved = false;
//       addManualTimeModel.email = widget.userModel.email;
//       addManualTimeModel.sevauserid = widget.userModel.sevaUserID;
//       addManualTimeModel.id = Utils.getUuid();
//       await CollectionRef.collection("add_manual_time").doc(addManualTimeModel.id).set(addManualTimeModel.toMap());
//       await sendAddManualTimeNotification(addManualTimeModel: addManualTimeModel,);

//   }

//   Future<void> sendAddManualTimeNotification({
//       AddManualTimeModel addManualTimeModel,
//   }) async {

//       Map<String, dynamic> manualTimeModelMap = addManualTimeModel.toMap();
//       manualTimeModelMap.removeWhere((k, v) => k=="seen" || k=="approved");

//       NotificationsModel notification = NotificationsModel(
//           id: Utils.getUuid(),
//           timebankId: FlavorConfig.values.timebankId,
//           data: manualTimeModelMap,
//           isRead: false,
//           type: NotificationType.AddManualTimeRequest,
//           communityId: addManualTimeModel.communityId,
//           senderUserId: addManualTimeModel.sevauserid,
//           targetUserId: addManualTimeModel.timebankId,
//           isTimebankNotification: true,
//       );

//       await CollectionRef
//           .timebank
//           .doc(addManualTimeModel.timebankId)
//           .collection("notifications")
//           .doc(notification.id)
//           .set(notification.toMap());
//   }
// }
