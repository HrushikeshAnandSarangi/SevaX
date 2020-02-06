// import 'dart:collection';
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:logger/logger.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
// import 'package:sevaexchange/utils/utils.dart' as utils;
// import 'package:sevaexchange/main.dart' as prefix0;
// import 'package:intl/intl.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/globals.dart' as globals;
// import 'package:sevaexchange/models/offer_model.dart';
// import 'package:sevaexchange/models/request_model.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
// import 'package:sevaexchange/views/core.dart';

// import 'package:sevaexchange/views/exchange/select_request_view.dart';
// import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
// import 'package:sevaexchange/views/group_models/GroupingStrategy.dart';
// import 'package:sevaexchange/views/register_location.dart';
// import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
// import 'package:sevaexchange/views/workshop/approvedUsers.dart';

// import '../core.dart';
// import 'edit_offer.dart';
// import 'edit_request.dart';

// class HelpView extends StatefulWidget {
//   final TabController controller;

//   HelpView(this.controller);

//   HelpViewState createState() => HelpViewState();
// }

// class HelpViewState extends State<HelpView> {
//   static bool isAdminOrCoordinator = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     FirestoreManager.getTimeBankForId(
//             timebankId: SevaCore.of(context).loggedInUser.currentTimebank)
//         .then((timebank) {
//       if (timebank.admins
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
//           timebank.coordinators
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
//         setState(() {
//           isAdminOrCoordinator = true;
//         });
//       } else {}
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TabBarView(
//       controller: widget.controller,
//       physics: NeverScrollableScrollPhysics(),
//       children: [
//         Requests(context),
//         Offers(context),
//       ],
//     );
//   }
// }

// class Requests extends StatefulWidget {
//   final BuildContext parentContext;

//   Requests(this.parentContext);

//   @override
//   RequestsState createState() => RequestsState();
// }

// class RequestsState extends State<Requests> {
//   _setORValue() {
//     globals.orCreateSelector = 0;
//   }

//   String timebankId = FlavorConfig.values.timebankId;
//   bool isNearme = false;
//   List<TimebankModel> timebankList = [];
//   bool isNearMe = false;
//   int sharedValue = 0;

//   final Map<int, Widget> logoWidgets = const <int, Widget>{
//     0: Text(
//       'All',
//       style: TextStyle(fontSize: 10.0),
//     ),
//     1: Text(
//       'Near Me',
//       style: TextStyle(fontSize: 10.0),
//     ),
//   };

//   @override
//   Widget build(BuildContext context) {
//     _setORValue();
//     return Column(
//       children: <Widget>[
//         Offstage(
//           offstage: false,
//           child: Row(
//             children: <Widget>[
//               Padding(
//                 padding: EdgeInsets.only(left: 10),
//               ),
//               Text(
//                 FlavorConfig.values.timebankTitle,
//                 style: (TextStyle(fontWeight: FontWeight.w500)),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(left: 10),
//               ),
//               StreamBuilder<Object>(
//                   stream: FirestoreManager.getTimebanksForUserStream(
//                     userId: SevaCore.of(context).loggedInUser.sevaUserID,
//                     communityId:
//                         SevaCore.of(context).loggedInUser.currentCommunity,
//                   ),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError)
//                       return new Text('Error: ${snapshot.error}');
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     timebankList = snapshot.data;
//                     List<String> dropdownList = [];

//                     int adminOfCount = 0;
//                     if (FlavorConfig.values.timebankName == "Yang 2020") {
//                       dropdownList.add("Create Yang Gang");
//                     }
//                     timebankList.forEach((t) {
//                       dropdownList.add(t.id);

//                       if (t.admins.contains(
//                           SevaCore.of(context).loggedInUser.sevaUserID)) {
//                         adminOfCount++;

//                         SevaCore.of(context)
//                             .loggedInUser
//                             .timebankIdForYangGangAdmin = t.id;
//                       }
//                     });

//                     SevaCore.of(context).loggedInUser.associatedWithTimebanks =
//                         dropdownList.length;
//                     SevaCore.of(context).loggedInUser.adminOfYanagGangs =
//                         adminOfCount;

//                     return Expanded(
//                       child: DropdownButton<String>(
//                         value: timebankId,
//                         onChanged: (String newValue) {
//                           if (newValue == "Create Yang Gang") {
//                             {
//                               this.createSubTimebank(context);
//                             }
//                           } else {
//                             setState(() {
//                               SevaCore.of(context)
//                                   .loggedInUser
//                                   .currentTimebank = newValue;
//                               timebankId = newValue;
//                             });
//                           }
//                         },
//                         items: dropdownList
//                             .map<DropdownMenuItem<String>>((String value) {
//                           if (value == "Create Yang Gang") {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(
//                                 value,
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             );
//                           } else {
//                             if (value == 'All') {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             } else {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: FutureBuilder<Object>(
//                                     future: FirestoreManager.getTimeBankForId(
//                                         timebankId: value),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.hasError)
//                                         return new Text(
//                                             'Error: ${snapshot.error}');
//                                       if (snapshot.connectionState ==
//                                           ConnectionState.waiting) {
//                                         return Offstage();
//                                       }
//                                       TimebankModel timebankModel =
//                                           snapshot.data;
//                                       return Text(
//                                         timebankModel.name,
//                                         style: TextStyle(fontSize: 15.0),
//                                       );
//                                     }),
//                               );
//                             }
//                           }
//                         }).toList(),
//                       ),
//                     );
//                   }),
//               Container(
//                 width: 120,
//                 child: CupertinoSegmentedControl<int>(
//                   selectedColor: Color.fromARGB(255, 4, 47, 110),
//                   children: logoWidgets,

//                   padding: EdgeInsets.only(left: 5.0, right: 5.0),
//                   //selectedColor: Colors.deepOrange,
//                   groupValue: sharedValue,
//                   onValueChanged: (int val) {
//                     print(val);
//                     if (val != sharedValue) {
//                       setState(() {
//                         if (isNearme == true)
//                           isNearme = false;
//                         else
//                           isNearme = true;
//                       });
//                       setState(() {
//                         sharedValue = val;
//                       });
//                     }
//                   },
//                   //groupValue: sharedValue,
//                 ),
//               ),
// //              RaisedButton(
// //                onPressed: () {
// //                  setState(() {
// //                    if (isNearme == true)
// //                      isNearme = false;
// //                    else
// //                      isNearme = true;
// //                  });
// //                },
// //                child: isNearme == false ? Text('Near Me') : Text('All'),
// //                color: Theme.of(context).accentColor,
// //                textColor: Colors.white,
// //              ),
//               Padding(
//                 padding: EdgeInsets.only(right: 5),
//               ),
//             ],
//           ),
//         ),
//         Divider(
//           color: Colors.grey,
//           height: 0,
//         ),
//         isNearme == true
//             ? NearRequestListItems(
//                 parentContext: context,
//                 timebankId: timebankId,
//               )
//             : RequestListItems(
//                 parentContext: context,
//                 timebankId: timebankId,
//               )
//       ],
//     );
//   }

//   void createSubTimebank(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TimebankCreate(
//           timebankId: FlavorConfig.values.timebankId,
//         ),
//       ),
//     );
//   }
// }

// class RequestCardView extends StatefulWidget {
//   final RequestModel requestItem;

//   RequestCardView({
//     Key key,
//     @required this.requestItem,
//   }) : super(key: key);

//   @override
//   _RequestCardViewState createState() => _RequestCardViewState();
// }

// class _RequestCardViewState extends State<RequestCardView> {
//   void _acceptRequest() {
//     Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
//     acceptorList.add(SevaCore.of(context).loggedInUser.email);
//     widget.requestItem.acceptors = acceptorList.toList();
//     FirestoreManager.acceptRequest(
//       timebankId: timebankId,
//       requestModel: widget.requestItem,
//       senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//       communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//     );
//   }

//   void _withdrawRequest() {
//     Set<String> acceptorList = Set.from(widget.requestItem.acceptors);
//     acceptorList.remove(SevaCore.of(context).loggedInUser.email);
//     widget.requestItem.acceptors = acceptorList.toList();
//     FirestoreManager.acceptRequest(
//       requestModel: widget.requestItem,
//       senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
//       isWithdrawal: true,
//       communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: <Widget>[
//           widget.requestItem.sevaUserId ==
//                   SevaCore.of(context).loggedInUser.sevaUserID
//               ? IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditRequest(
//                           timebankId:
//                               SevaCore.of(context).loggedInUser.currentTimebank,
//                           requestModel: widget.requestItem,
//                         ),
//                       ),
//                     );
//                   },
//                 )
//               : Offstage(),
//           widget.requestItem.sevaUserId ==
//                       SevaCore.of(context).loggedInUser.sevaUserID &&
//                   widget.requestItem.acceptors.length == 0
//               ? IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext viewcontext) {
//                           return AlertDialog(
//                             title: Text(
//                                 'Are you sure you want to delete this request?'),
//                             actions: <Widget>[
//                               FlatButton(
//                                 child: Text(
//                                   'No',
//                                   style: TextStyle(
//                                     fontSize: dialogButtonSize,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pop(viewcontext);
//                                 },
//                               ),
//                               FlatButton(
//                                 child: Text(
//                                   'Yes',
//                                   style: TextStyle(
//                                     fontSize: dialogButtonSize,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   deleteRequest(
//                                       requestModel: widget.requestItem);
//                                   Navigator.pop(viewcontext);
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ],
//                           );
//                         });
//                   },
//                 )
//               : Offstage()
//         ],
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(
//           widget.requestItem.title,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel userModel = snapshot.data;
//             String usertimezone = userModel.timezone;
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(),
//                 child: Container(
//                   padding: EdgeInsets.all(10.0),
//                   child: Container(
//                     padding: EdgeInsets.all(10.0),
//                     color: widget.requestItem.color,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             widget.requestItem.title,
//                             style: TextStyle(
//                                 fontSize: 18.0, fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: RichTextView(
//                               text: widget.requestItem.description),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             'From:  ' +
//                                 DateFormat('MMMM dd, yyyy @ h:mm a').format(
//                                   getDateTimeAccToUserTimezone(
//                                       dateTime:
//                                           DateTime.fromMillisecondsSinceEpoch(
//                                               widget.requestItem.requestStart),
//                                       timezoneAbb: usertimezone),
//                                 ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             'Until:  ' +
//                                 DateFormat('MMMM dd, yyyy @ h:mm a').format(
//                                   getDateTimeAccToUserTimezone(
//                                       dateTime:
//                                           DateTime.fromMillisecondsSinceEpoch(
//                                               widget.requestItem.requestEnd),
//                                       timezoneAbb: usertimezone),
//                                 ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child:
//                               Text('Posted By: ' + widget.requestItem.fullName),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             'PostDate:  ' +
//                                 DateFormat('MMMM dd, yyyy @ h:mm a').format(
//                                   getDateTimeAccToUserTimezone(
//                                       dateTime:
//                                           DateTime.fromMillisecondsSinceEpoch(
//                                               widget.requestItem.postTimestamp),
//                                       timezoneAbb: usertimezone),
//                                 ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text('Number of volunteers required: ' +
//                               '${widget.requestItem.numberOfApprovals}'),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(' '),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: RaisedButton(
//                             color: Theme.of(context).accentColor,
//                             onPressed: widget.requestItem.sevaUserId ==
//                                     SevaCore.of(context).loggedInUser.sevaUserID
//                                 ? null
//                                 : () {
//                                     widget.requestItem.acceptors.contains(
//                                             SevaCore.of(context)
//                                                 .loggedInUser
//                                                 .email)
//                                         ? _withdrawRequest()
//                                         : _acceptRequest();
//                                     Navigator.pop(context);
//                                   },
//                             child: Text(
//                               widget.requestItem.acceptors.contains(
//                                       SevaCore.of(context).loggedInUser.email)
//                                   ? 'Withdraw Request'
//                                   : 'Accept Request',
//                               style: TextStyle(
//                                 color: FlavorConfig.values.buttonTextColor,
//                               ),
//                             ),
//                           ),
//                         ),
//                         widget.requestItem.sevaUserId !=
//                                 SevaCore.of(context).loggedInUser.sevaUserID
//                             ? Offstage()
//                             : Container(
//                                 padding: EdgeInsets.all(8.0),
//                                 child: RaisedButton(
//                                   color: Theme.of(context).accentColor,
//                                   onPressed: widget.requestItem.approvedUsers
//                                               .length <
//                                           1
//                                       ? null
//                                       : () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                                 builder:
//                                                     (BuildContext context) =>
//                                                         RequestStatusView(
//                                                           requestId: widget
//                                                               .requestItem.id,
//                                                         ),
//                                                 fullscreenDialog: true),
//                                           );
//                                         },
//                                   child: Text(
//                                     widget.requestItem.approvedUsers.length < 1
//                                         ? 'No Approved members yet'
//                                         : 'View Approved Members',
//                                     style: TextStyle(
//                                       color:
//                                           FlavorConfig.values.buttonTextColor,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   Future<void> deleteRequest({
//     @required RequestModel requestModel,
//   }) async {
//     print(requestModel.toMap());

//     return await Firestore.instance
//         .collection('requests')
//         .document(requestModel.id)
//         .delete();
//   }
// }

// class Offers extends StatefulWidget {
//   final BuildContext parentContext;

//   Offers(this.parentContext);

//   @override
//   OffersState createState() => OffersState();
// }

// class OffersState extends State<Offers> {
//   _setORValue() {
//     globals.orCreateSelector = 1;
//   }

//   String timebankId = FlavorConfig.values.timebankId;
//   List<TimebankModel> timebankList = [];
//   bool isNearme = false;
//   int sharedValue = 0;

//   @override
//   Widget build(BuildContext context) {
//     _setORValue();
//     return Column(
//       children: <Widget>[
//         Offstage(
//           offstage: false,
//           child: Row(
//             children: <Widget>[
//               Padding(
//                 padding: EdgeInsets.only(left: 10),
//               ),
//               Text(
//                 FlavorConfig.values.timebankTitle,
//                 style: (TextStyle(fontWeight: FontWeight.w500)),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(left: 10),
//               ),
//               StreamBuilder<List<TimebankModel>>(
//                   stream: FirestoreManager.getTimebanksForUserStream(
//                     userId: SevaCore.of(context).loggedInUser.sevaUserID,
//                     communityId:
//                         SevaCore.of(context).loggedInUser.currentCommunity,
//                   ),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError)
//                       return new Text('Error: ${snapshot.error}');
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     timebankList = snapshot.data;
//                     List<String> dropdownList = [];

//                     int adminOfCount = 0;
//                     if (FlavorConfig.values.timebankName == "Yang 2020") {
//                       dropdownList.add("Create Yang Gang");
//                     }

//                     timebankList.forEach((t) {
//                       dropdownList.add(t.id);
//                       if (t.admins.contains(
//                           SevaCore.of(context).loggedInUser.sevaUserID)) {
//                         adminOfCount++;

//                         SevaCore.of(context)
//                             .loggedInUser
//                             .timebankIdForYangGangAdmin = t.id;
//                       }
//                     });

//                     SevaCore.of(context).loggedInUser.associatedWithTimebanks =
//                         dropdownList.length;

//                     SevaCore.of(context).loggedInUser.adminOfYanagGangs =
//                         adminOfCount;

//                     return Expanded(
//                       child: DropdownButton<String>(
//                         value: timebankId,
//                         onChanged: (String newValue) {
//                           if (newValue == "Create Yang Gang") {
//                             createSubTimebank(context);
//                           } else {
//                             setState(() {
//                               timebankId = newValue;
//                               SevaCore.of(context)
//                                   .loggedInUser
//                                   .currentTimebank = newValue;
//                             });
//                           }
//                         },
//                         items: dropdownList
//                             .map<DropdownMenuItem<String>>((String value) {
//                           if (value == "Create Yang Gang") {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(
//                                 value,
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             );
//                           } else {
//                             if (value == 'All') {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: Text(value),
//                               );
//                             } else {
//                               return DropdownMenuItem<String>(
//                                 value: value,
//                                 child: FutureBuilder<Object>(
//                                     future: FirestoreManager.getTimeBankForId(
//                                         timebankId: value),
//                                     builder: (context, snapshot) {
//                                       if (snapshot.hasError)
//                                         return new Text(
//                                             'Error: ${snapshot.error}');
//                                       if (snapshot.connectionState ==
//                                           ConnectionState.waiting) {
//                                         return Offstage();
//                                       }
//                                       TimebankModel timebankModel =
//                                           snapshot.data;
//                                       return Text(
//                                         timebankModel.name,
//                                         style: TextStyle(fontSize: 15.0),
//                                       );
//                                     }),
//                               );
//                             }
//                           }
//                         }).toList(),
//                       ),
//                     );
//                   }),
//               Container(
//                 width: 120,
//                 child: CupertinoSegmentedControl<int>(
//                   selectedColor: Color.fromARGB(255, 4, 47, 110),
//                   children: logoWidgets,
//                   padding: EdgeInsets.only(left: 5.0, right: 5.0),
//                   //selectedColor: Colors.deepOrange,
//                   groupValue: sharedValue,
//                   onValueChanged: (int val) {
//                     print(val);
//                     if (val != sharedValue) {
//                       setState(() {
//                         if (isNearme == true)
//                           isNearme = false;
//                         else
//                           isNearme = true;
//                       });
//                       setState(() {
//                         sharedValue = val;
//                       });
//                     }
//                   },
//                   //groupValue: sharedValue,
//                 ),
//               ),
// //              RaisedButton(
// //                onPressed: () {
// //                  setState(() {
// //                    if (isNearme == true)
// //                      isNearme = false;
// //                    else
// //                      isNearme = true;
// //                  });
// //                },
// //                child: isNearme == false ? Text('Near Me') : Text('All'),
// //                color: Theme.of(context).accentColor,
// //                textColor: Colors.white,
// //              ),
//               Padding(
//                 padding: EdgeInsets.only(right: 5),
//               ),
//             ],
//           ),
//         ),
//         Divider(
//           color: Colors.grey,
//           height: 0,
//         ),
//         isNearme == true
//             ? NearOfferListItems(
//                 parentContext: context,
//                 timebankId: timebankId,
//               )
//             : OfferListItems(
//                 parentContext: context,
//                 timebankId: timebankId,
//               )
//       ],
//     );
//   }

//   void createSubTimebank(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TimebankCreate(
//           timebankId: FlavorConfig.values.timebankId,
//         ),
//       ),
//     );
//   }

//   final Map<int, Widget> logoWidgets = const <int, Widget>{
//     0: Text(
//       'All',
//       style: TextStyle(fontSize: 10.0),
//     ),
//     1: Text(
//       'Near Me',
//       style: TextStyle(fontSize: 10.0),
//     ),
//   };
// }

// class OfferCardView extends StatefulWidget {
//   final OfferModel offerModel;
//   String sevaUserIdOffer;

//   bool isAdmin = false;

//   OfferCardView({this.offerModel});

//   @override
//   State<StatefulWidget> createState() {
//     return OfferCardViewState();
//   }
// }

// class OfferCardViewState extends State<OfferCardView> {
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     FirestoreManager.getTimeBankForId(timebankId: widget.offerModel.timebankId)
//         .then((timebank) {
//       if (timebank.admins
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
//           timebank.coordinators
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
//         if (widget.isAdmin == false) {
//           setState(() {
//             widget.isAdmin = true;
//           });
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     FirestoreManager.getTimeBankForId(timebankId: widget.offerModel.timebankId)
//         .then((timebank) {
//       if (timebank.admins
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
//           timebank.coordinators
//               .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {}
//     });
//     return Scaffold(
//       appBar: AppBar(
//         actions: <Widget>[
//           widget.offerModel.sevaUserId ==
//                   SevaCore.of(context).loggedInUser.sevaUserID
//               ? IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => UpdateOffer(
//                           timebankId:
//                               SevaCore.of(context).loggedInUser.currentTimebank,
//                           offerModel: widget.offerModel,
//                         ),
//                       ),
//                     );
//                   },
//                 )
//               : Offstage(),
//           widget.offerModel.sevaUserId ==
//                       SevaCore.of(context).loggedInUser.sevaUserID &&
//                   widget.offerModel.requestList.length == 0
//               ? IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: () {
//                     showDialog(
//                         context: context,
//                         builder: (BuildContext viewcontext) {
//                           return AlertDialog(
//                             title: Text(
//                                 'Are you sure you want to delete this offer?'),
//                             actions: <Widget>[
//                               FlatButton(
//                                 child: Text(
//                                   'No',
//                                   style: TextStyle(
//                                     fontSize: dialogButtonSize,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pop(viewcontext);
//                                 },
//                               ),
//                               FlatButton(
//                                 child: Text(
//                                   'Yes',
//                                   style: TextStyle(
//                                     fontSize: dialogButtonSize,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   deleteOffer(offerModel: widget.offerModel);
//                                   Navigator.pop(viewcontext);
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ],
//                           );
//                         });
//                   },
//                 )
//               : Offstage()
//         ],
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(
//           widget.offerModel.title,
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel userModel = snapshot.data;
//             String usertimezone = userModel.timezone;

//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(),
//                 child: Container(
//                   padding: EdgeInsets.all(10.0),
//                   child: Container(
//                     padding: EdgeInsets.all(10.0),
//                     color: widget.offerModel.color,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             widget.offerModel.title,
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child:
//                               RichTextView(text: widget.offerModel.description),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child:
//                               Text('Posted By: ' + widget.offerModel.fullName),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           alignment: Alignment(-1.0, 0.0),
//                           child: Text(
//                             'PostDate:  ' +
//                                 DateFormat('MMMM dd, yyyy @ h:mm a').format(
//                                   getDateTimeAccToUserTimezone(
//                                       dateTime:
//                                           DateTime.fromMillisecondsSinceEpoch(
//                                               widget.offerModel.timestamp),
//                                       timezoneAbb: usertimezone),
//                                 ),
//                           ),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(' '),
//                         ),
//                         Container(
//                           padding: EdgeInsets.all(8.0),
//                           child: RaisedButton(
//                             color: Theme.of(context).accentColor,
//                             onPressed: widget.offerModel.sevaUserId ==
//                                         SevaCore.of(context)
//                                             .loggedInUser
//                                             .sevaUserID ||
//                                     (widget.isAdmin &&
//                                         widget.offerModel.acceptedOffer)
//                                 ? null
//                                 : () {
//                                     widget.sevaUserIdOffer =
//                                         widget.offerModel.sevaUserId;

//                                     FirestoreManager.getTimeBankForId(
//                                             timebankId:
//                                                 widget.offerModel.timebankId)
//                                         .then((timebank) {
//                                       if (timebank.admins.contains(
//                                               SevaCore.of(context)
//                                                   .loggedInUser
//                                                   .sevaUserID) ||
//                                           timebank.coordinators.contains(
//                                               SevaCore.of(context)
//                                                   .loggedInUser
//                                                   .sevaUserID)) {
//                                         setState(() {
//                                           widget.isAdmin = true;
//                                         });

//                                         _makePostRequest(widget.offerModel);
// //                                  Navigator.push(
// //                                    context,
// //                                    MaterialPageRoute(
// //                                      builder: (context) =>
// //                                          SelectRequestView(
// //                                            offerModel: offerModel,
// //                                            sevaUserIdOffer: sevaUserIdOffer,
// //                                          ),
// //                                    ),
// //                                  );
//                                       } else {
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title:
//                                                   new Text("Permission Denied"),
//                                               content: new Text(
//                                                   "You need to be an Admin or Coordinator to have permission to send request to offers"),
//                                               actions: <Widget>[
//                                                 new FlatButton(
//                                                   child: new Text("Close"),
//                                                   onPressed: () {
//                                                     Navigator.of(context).pop();
//                                                   },
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         );
//                                       }
//                                     });
//                                   },
//                             child: Text(
//                               !widget.offerModel.acceptedOffer ||
//                                       !widget.isAdmin
//                                   ? 'Accept Offer'
//                                   : 'Offer Accepted',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   String offerStatusLabel;

//   _makePostRequest(OfferModel offerModel) async {
//     // set up POST request arguments
//     String url =
//         'https://us-central1-sevaxproject4sevax.cloudfunctions.net/acceptOffer';
//     Map<String, String> headers = {"Content-type": "application/json"};
//     Map<String, String> body = {
//       'id': offerModel.id,
//       'email': offerModel.email,
//       'notificationId': utils.Utils.getUuid(),
//       'acceptorSevaId': SevaCore.of(context).loggedInUser.sevaUserID,
//       'timebankId': FlavorConfig.values.timebankId,
//       'sevaUserId': offerModel.sevaUserId,
//     };

//     setState(() {
//       widget.offerModel.acceptedOffer = true;
//     });

//     // make POST request
//     Response response =
//         await post(url, headers: headers, body: json.encode(body));
//     // check the status code for the result
//     int statusCode = response.statusCode;

//     if (statusCode == 200) {
//       print("Request completed successfully");
//     } else {
//       print("Request failed");
//     }
//     // this API passes back the id of the new item added to the body
//     // String body = response.body;
//     // {
//     //   "title": "Hello",
//     //   "body": "body text",
//     //   "userId": 1,
//     //   "id": 101
//     // }
//   }

//   Future<void> deleteOffer({
//     @required OfferModel offerModel,
//   }) async {
//     return await Firestore.instance
//         .collection('offers')
//         .document(offerModel.id)
//         .delete();
//   }
// }

// class NearRequestListItems extends StatelessWidget {
//   final String timebankId;
//   final BuildContext parentContext;

//   const NearRequestListItems({Key key, this.timebankId, this.parentContext})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (timebankId != 'All') {
//       return FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel user = snapshot.data;
//             String loggedintimezone = user.timezone;

//             return StreamBuilder<List<RequestModel>>(
//               stream: FirestoreManager.getNearRequestListStream(
//                 timebankId: timebankId,
//               ),
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                 if (requestListSnapshot.hasError) {
//                   return new Text('Error: ${requestListSnapshot.error}');
//                 }
//                 switch (requestListSnapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                   default:
//                     List<RequestModel> requestModelList =
//                         requestListSnapshot.data;

//                     requestModelList = filterBlockedRequestsContent(
//                         context: context, requestModelList: requestModelList);

//                     if (requestModelList.length == 0) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(child: Text('No Requests')),
//                       );
//                     }

//                     return Expanded(
//                       child: ListView.builder(
//                         itemCount: requestModelList.length + 1,
//                         itemBuilder: (context, index) {
//                           if (index >= requestModelList.length) {
//                             return Container(
//                               width: double.infinity,
//                               height: 65,
//                             );
//                           }
//                           return getRequestView(
//                             requestModelList[index],
//                             loggedintimezone,
//                           );
//                         },
//                       ),
//                     );

//                   // Expanded(
//                   //   child: Container(
//                   //     padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                   //     child: ListView(
//                   //       children: requestModelList.map(
//                   //         (RequestModel requestModel) {
//                   //           return getRequestView(
//                   //               requestModel, loggedintimezone);
//                   //         },
//                   //       ).toList(),
//                   //     ),
//                   //   ),
//                   // );
//                 }
//               },
//             );
//           });
//     } else {
//       return FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel user = snapshot.data;
//             String loggedintimezone = user.timezone;

//             return StreamBuilder<List<RequestModel>>(
//               stream: FirestoreManager.getNearRequestListStream(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                 if (requestListSnapshot.hasError) {
//                   return new Text('Error: ${requestListSnapshot.error}');
//                 }
//                 switch (requestListSnapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                   //filter

//                   default:
//                     List<RequestModel> requestModelList =
//                         requestListSnapshot.data;

//                     requestModelList = filterBlockedRequestsContent(
//                         context: context, requestModelList: requestModelList);

//                     if (requestModelList.length == 0) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(child: Text('No Requests')),
//                       );
//                     }

//                     return Expanded(
//                       child: Container(
//                         padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                         child: ListView(
//                           children: requestModelList.map(
//                             (RequestModel requestModel) {
//                               return getRequestView(
//                                   requestModel, loggedintimezone);
//                             },
//                           ).toList(),
//                         ),
//                       ),
//                     );
//                 }
//               },
//             );
//           });
//     }
//   }

//   List<RequestModel> filterBlockedRequestsContent(
//       {List<RequestModel> requestModelList, BuildContext context}) {
//     List<RequestModel> filteredList = [];

//     requestModelList.forEach((request) => SevaCore.of(context)
//                 .loggedInUser
//                 .blockedMembers
//                 .contains(request.sevaUserId) ||
//             SevaCore.of(context)
//                 .loggedInUser
//                 .blockedBy
//                 .contains(request.sevaUserId)
//         ? "Filtering blocked content"
//         : filteredList.add(request));

//     return filteredList;
//   }

//   Widget getRequestView(RequestModel model, String loggedintimezone) {
//     return Container(
//       decoration: containerDecoration,
//       margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Card(
//         elevation: 0,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               parentContext,
//               MaterialPageRoute(
//                 builder: (context) => RequestCardView(requestItem: model),
//               ),
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 ClipOval(
//                   child: SizedBox(
//                     height: 45,
//                     width: 45,
//                     child: FadeInImage.assetNetwork(
//                         placeholder: 'lib/assets/images/profile.png',
//                         image: model.photoUrl),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         model.title,
//                         style: Theme.of(parentContext).textTheme.subhead,
//                       ),
//                       Text(
//                         model.description,
//                         style: Theme.of(parentContext).textTheme.subtitle,
//                       ),
//                       SizedBox(height: 8),
//                       Wrap(
//                         crossAxisAlignment: WrapCrossAlignment.center,
//                         children: <Widget>[
//                           Text(getTimeFormattedString(
//                               model.requestStart, loggedintimezone)),
//                           SizedBox(width: 2),
//                           Icon(Icons.arrow_forward, size: 14),
//                           SizedBox(width: 4),
//                           Text(getTimeFormattedString(
//                               model.requestEnd, loggedintimezone)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
//     DateFormat dateFormat = DateFormat('d MMM hh:mm a ');
//     DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
//     DateTime localtime = getDateTimeAccToUserTimezone(
//         dateTime: datetime, timezoneAbb: timezoneAbb);
//     String from = dateFormat.format(
//       localtime,
//     );
//     return from;
//   }

//   BoxDecoration get containerDecoration {
//     return BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(12.0)),
//       boxShadow: [
//         BoxShadow(
//             color: Colors.black.withAlpha(10),
//             spreadRadius: 4,
//             offset: Offset(0, 3),
//             blurRadius: 6)
//       ],
//       color: Colors.white,
//     );
//   }
// }

// class RequestListItems extends StatelessWidget {
//   final String timebankId;
//   final BuildContext parentContext;

//   const RequestListItems({Key key, this.timebankId, this.parentContext})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (timebankId != 'All') {
//       return FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel user = snapshot.data;
//             String loggedintimezone = user.timezone;

//             return StreamBuilder<List<RequestModel>>(
//               stream: FirestoreManager.getRequestListStream(
//                 timebankId: timebankId,
//               ),
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                 if (requestListSnapshot.hasError) {
//                   return new Text('Error: ${requestListSnapshot.error}');
//                 }
//                 switch (requestListSnapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                   default:
//                     List<RequestModel> requestModelList =
//                         requestListSnapshot.data;
//                     requestModelList = filterBlockedRequestsContent(
//                         context: context, requestModelList: requestModelList);

//                     if (requestModelList.length == 0) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(child: Text('No Requests')),
//                       );
//                     }

//                     var consolidatedList =
//                         GroupRequestCommons.groupAndConsolidateRequests(
//                             requestModelList,
//                             SevaCore.of(context).loggedInUser.sevaUserID);

//                     return formatListFrom(
//                       consolidatedList: consolidatedList,
//                       loggedintimezone: loggedintimezone,
//                     );
//                 }
//               },
//             );
//           });
//     } else {
//       return FutureBuilder<Object>(
//           future: FirestoreManager.getUserForId(
//               sevaUserId: SevaCore.of(context).loggedInUser.sevaUserID),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return new Text('Error: ${snapshot.error}');
//             }
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }
//             UserModel user = snapshot.data;
//             String loggedintimezone = user.timezone;

//             return StreamBuilder<List<RequestModel>>(
//               stream: FirestoreManager.getAllRequestListStream(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<RequestModel>> requestListSnapshot) {
//                 if (requestListSnapshot.hasError) {
//                   return new Text('Error: ${requestListSnapshot.error}');
//                 }
//                 switch (requestListSnapshot.connectionState) {
//                   case ConnectionState.waiting:
//                     return Center(child: CircularProgressIndicator());
//                   default:
//                     List<RequestModel> requestModelList =
//                         requestListSnapshot.data;

//                     requestModelList = filterBlockedRequestsContent(
//                         context: context, requestModelList: requestModelList);

//                     if (requestModelList.length == 0) {
//                       return Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(child: Text('No Requests')),
//                       );
//                     }
//                     var consolidatedList =
//                         GroupRequestCommons.groupAndConsolidateRequests(
//                             requestModelList,
//                             SevaCore.of(context).loggedInUser.sevaUserID);
//                     return formatListFrom(consolidatedList: consolidatedList);
//                 }
//               },
//             );
//           });
//     }
//   }

//   List<RequestModel> filterBlockedRequestsContent({
//     List<RequestModel> requestModelList,
//     BuildContext context,
//   }) {
//     List<RequestModel> filteredList = [];

//     requestModelList.forEach((request) => SevaCore.of(context)
//                 .loggedInUser
//                 .blockedMembers
//                 .contains(request.sevaUserId) ||
//             SevaCore.of(context)
//                 .loggedInUser
//                 .blockedBy
//                 .contains(request.sevaUserId)
//         ? "Filtering blocked content"
//         : filteredList.add(request));

//     return filteredList;
//   }

//   Widget formatListFrom(
//       {List<RequestModelList> consolidatedList, String loggedintimezone}) {
//     return Expanded(
//       child: Container(
//           child: ListView.builder(
//         itemCount: consolidatedList.length + 1,
//         itemBuilder: (context, index) {
//           if (index >= consolidatedList.length) {
//             return Container(
//               width: double.infinity,
//               height: 65,
//             );
//           }

//           return getRequestView(consolidatedList[index], loggedintimezone);
//         },
//       )
//           // child: ListView(
//           //   children: consolidatedList.map((RequestModelList requestModel) {
//           //     return getRequestView(requestModel, loggedintimezone);
//           //   }).toList(),
//           // ),
//           ),
//     );
//   }

//   Widget getRequestView(RequestModelList model, String loggedintimezone) {
//     switch (model.getType()) {
//       case RequestModelList.TITLE:
//         return Container(
//           margin: EdgeInsets.all(12),
//           child: Text(
//             GroupRequestCommons.getGroupTitle(
//                 groupKey: (model as GroupTitle).groupTitle),
//           ),
//         );

//       case RequestModelList.REQUEST:
//         return getRequestListViewHoldder(
//           model: (model as RequestItem).requestModel,
//           loggedintimezone: loggedintimezone,
//         );

//       default:
//         return Text("DEFAULT");
//     }
//   }

//   Widget getRequestListViewHoldder(
//       {RequestModel model, String loggedintimezone}) {
//     return Container(
//       decoration: containerDecorationR,
//       margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//       child: Card(
//         color: Colors.white,
//         elevation: 2,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               parentContext,
//               MaterialPageRoute(
//                 builder: (context) => RequestCardView(requestItem: model),
//               ),
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 ClipOval(
//                   child: SizedBox(
//                     height: 45,
//                     width: 45,
//                     child: FadeInImage.assetNetwork(
//                       placeholder: 'lib/assets/images/profile.png',
//                       image: model.photoUrl == null
//                           ? defaultUserImageURL
//                           : model.photoUrl,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         model.title,
//                         style: Theme.of(parentContext).textTheme.subhead,
//                       ),
//                       Text(
//                         model.description,
//                         style: Theme.of(parentContext).textTheme.subtitle,
//                       ),
//                       SizedBox(height: 8),
//                       Wrap(
//                         crossAxisAlignment: WrapCrossAlignment.center,
//                         children: <Widget>[
//                           Text(getTimeFormattedString(
//                               model.requestStart, loggedintimezone)),
//                           SizedBox(width: 2),
//                           Icon(Icons.arrow_forward, size: 14),
//                           SizedBox(width: 4),
//                           Text(getTimeFormattedString(
//                               model.requestEnd, loggedintimezone)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String getTimeFormattedString(int timeInMilliseconds, String timezoneAbb) {
//     DateFormat dateFormat = DateFormat('d MMM hh:mm a ');
//     DateTime datetime = DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds);
//     DateTime localtime = getDateTimeAccToUserTimezone(
//         dateTime: datetime, timezoneAbb: timezoneAbb);
//     String from = dateFormat.format(
//       localtime,
//     );
//     return from;
//   }

//   BoxDecoration get containerDecoration {
//     return BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(2.0)),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withAlpha(2),
//           spreadRadius: 6,
//           offset: Offset(0, 3),
//           blurRadius: 6,
//         )
//       ],
//       color: Colors.white,
//     );
//   }

//   BoxDecoration get containerDecorationR {
//     return BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(2.0)),
//       boxShadow: [
//         BoxShadow(
//             color: Colors.black.withAlpha(2),
//             spreadRadius: 6,
//             offset: Offset(0, 3),
//             blurRadius: 6)
//       ],
//       color: Colors.white,
//     );
//   }
// }

// class OfferListItems extends StatelessWidget {
//   final String timebankId;
//   final BuildContext parentContext;

//   const OfferListItems({
//     Key key,
//     this.parentContext,
//     this.timebankId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (timebankId != 'All') {
//       return StreamBuilder<List<OfferModel>>(
//         stream: getOffersStream(timebankId: timebankId),
//         builder:
//             (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
//           if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             default:
//               List<OfferModel> offersList = snapshot.data;
//               offersList = filterBlockedOffersContent(
//                   context: context, requestModelList: offersList);

//               if (offersList.length == 0) {
//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Center(
//                     child: Text('No Offers'),
//                   ),
//                 );
//               }
//               //Here we apply grouping startegy
//               var consolidatedList =
//                   GroupOfferCommons.groupAndConsolidateOffers(
//                       offersList, SevaCore.of(context).loggedInUser.sevaUserID);
//               return formatListOffer(consolidatedList: consolidatedList);
//           }
//         },
//       );
//     } else {
//       print("set stream for offers");

//       return StreamBuilder<List<OfferModel>>(
//         stream: getAllOffersStream(),
//         builder:
//             (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
//           if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             default:
//               List<OfferModel> offersList = snapshot.data;

//               offersList = filterBlockedOffersContent(
//                   context: context, requestModelList: offersList);

//               if (offersList.length == 0) {
//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Center(
//                     child: Text('No Offers'),
//                   ),
//                 );
//               }

//               var consolidatedList =
//                   GroupOfferCommons.groupAndConsolidateOffers(
//                       offersList, SevaCore.of(context).loggedInUser.sevaUserID);
//               // return Text('sample');
//               return formatListOffer(consolidatedList: consolidatedList);
//           }
//         },
//       );
//     }
//   }

//   List<OfferModel> filterBlockedOffersContent(
//       {List<OfferModel> requestModelList, BuildContext context}) {
//     List<OfferModel> filteredList = [];

//     requestModelList.forEach((request) => SevaCore.of(context)
//                 .loggedInUser
//                 .blockedMembers
//                 .contains(request.sevaUserId) ||
//             SevaCore.of(context)
//                 .loggedInUser
//                 .blockedBy
//                 .contains(request.sevaUserId)
//         ? "Filtering blocked content"
//         : filteredList.add(request));

//     return filteredList;
//   }

//   Widget formatListOffer({List<OfferModelList> consolidatedList}) {
//     return Expanded(
//       child: Container(
//         child: ListView.builder(
//             itemCount: consolidatedList.length + 1,
//             itemBuilder: (context, index) {
//               if (index >= consolidatedList.length) {
//                 return Container(
//                   width: double.infinity,
//                   height: 65,
//                 );
//               }
//               return getOfferWidget(consolidatedList[index]);
//             }
//             // children: consolidatedList.map((OfferModelList offerModel) {
//             //   return getOfferWidget(offerModel);
//             // }).toList(),
//             ),
//       ),
//     );
//   }

//   Widget getOfferWidget(OfferModelList model) {
//     return Container(
//       decoration: containerDecoration,
//       margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
//       child: getOfferView(model),
//     );
//   }

//   Widget getOfferView(OfferModelList offerModelList) {
//     switch (offerModelList.getType()) {
//       case OfferModelList.TITLE:
//         return Container(
//           margin: EdgeInsets.all(12),
//           child: Text(
//             GroupOfferCommons.getGroupTitleForOffer(
//                 groupKey: (offerModelList as OfferTitle).groupTitle),
//           ),
//         );

//       case OfferModelList.OFFER:
//         return getOfferViewHolder((offerModelList as OfferItem).offerModel);
//     }
//   }

//   Widget getOfferViewHolder(OfferModel model) {
//     return Card(
//       elevation: 2,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             parentContext,
//             MaterialPageRoute(
//               builder: (context) => OfferCardView(offerModel: model),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               ClipOval(
//                 child: SizedBox(
//                   height: 40,
//                   width: 40,
//                   child: FadeInImage.assetNetwork(
//                     placeholder: 'lib/assets/images/profile.png',
//                     // image: user.photoURL,
//                     image: model.photoUrlImage == null
//                         ? defaultUserImageURL
//                         : model.photoUrlImage,
//                   ),
//                 ),
//               )

//               // StreamBuilder<UserModel>(
//               //   stream: FirestoreManager.getUserForIdStream(
//               //     sevaUserId: model.sevaUserId,
//               //   ),
//               //   builder: (context, snapshot) {
//               //     if (snapshot.hasError) {
//               //       return CircleAvatar(foregroundColor: Colors.red);
//               //     }
//               //     if (snapshot.connectionState == ConnectionState.waiting) {
//               //       return CircleAvatar();
//               //     }
//               //     UserModel user = snapshot.data;
//               //     return ClipOval(
//               //       child: SizedBox(
//               //         height: 40,
//               //         width: 40,
//               //         child: FadeInImage.assetNetwork(
//               //             placeholder: 'lib/assets/images/profile.png',
//               //             // image: user.photoURL,
//               //             image:
//               //                 "https://media.wired.com/photos/5c1ae77ae91b067f6d57dec0/master/pass/Comparison-City-MAIN-ART.jpg"),
//               //       ),
//               //     );
//               //   },
//               // ),
//               ,
//               SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       model.title,
//                       style: Theme.of(parentContext).textTheme.subhead,
//                     ),
//                     Text(
//                       model.description.trim(),
//                       style: Theme.of(parentContext).textTheme.subtitle,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String getTimeFormattedString(int timeInMilliseconds) {
//     DateFormat dateFormat = DateFormat('d MMM h:m a ');
//     String from = dateFormat.format(
//       DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
//     );
//     return from;
//   }

//   BoxDecoration get containerDecoration {
//     return BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(12.0)),
//       boxShadow: [
//         BoxShadow(
//             color: Colors.black.withAlpha(0),
//             spreadRadius: 4,
//             offset: Offset(0, 3),
//             blurRadius: 6)
//       ],
//       color: Colors.white,
//     );
//   }
// }

// class NearOfferListItems extends StatelessWidget {
//   final String timebankId;
//   final BuildContext parentContext;

//   const NearOfferListItems({Key key, this.parentContext, this.timebankId})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (timebankId != 'All') {
//       return StreamBuilder<List<OfferModel>>(
//         stream: getNearOffersStream(timebankId: timebankId),
//         builder:
//             (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
//           if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             default:
//               List<OfferModel> offersList = snapshot.data;
//               offersList = filterBlockedOffersContent(
//                   context: context, requestModelList: offersList);

//               if (offersList.length == 0) {
//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Center(
//                     child: Text('No Offers'),
//                   ),
//                 );
//               }
//               return Expanded(
//                 child: Container(
//                   padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                   child: ListView.builder(
//                     itemBuilder: (context, index) {
//                       OfferModel offer = offersList[index];
//                       return getOfferWidget(offer);
//                     },
//                     itemCount: offersList.length,
//                   ),
//                 ),
//               );
//           }
//         },
//       );
//     } else {
//       return StreamBuilder<List<OfferModel>>(
//         stream: getNearOffersStream(),
//         builder:
//             (BuildContext context, AsyncSnapshot<List<OfferModel>> snapshot) {
//           if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
//           switch (snapshot.connectionState) {
//             case ConnectionState.waiting:
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             default:
//               List<OfferModel> offersList = snapshot.data;
//               offersList = filterBlockedOffersContent(
//                   context: context, requestModelList: offersList);

//               if (offersList.length == 0) {
//                 return Padding(
//                   padding: const EdgeInsets.all(10.0),
//                   child: Center(
//                     child: Text('No Offers'),
//                   ),
//                 );
//               }
//               return Expanded(
//                 child: Container(
//                   padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                   child: ListView.builder(
//                     itemBuilder: (context, index) {
//                       OfferModel offer = offersList[index];
//                       return getOfferWidget(offer);
//                     },
//                     itemCount: offersList.length,
//                   ),
//                 ),
//               );
//           }
//         },
//       );
//     }
//   }

//   List<OfferModel> filterBlockedOffersContent(
//       {List<OfferModel> requestModelList, BuildContext context}) {
//     List<OfferModel> filteredList = [];

//     requestModelList.forEach((request) => SevaCore.of(context)
//                 .loggedInUser
//                 .blockedMembers
//                 .contains(request.sevaUserId) ||
//             SevaCore.of(context)
//                 .loggedInUser
//                 .blockedBy
//                 .contains(request.sevaUserId)
//         ? "Filtering blocked content"
//         : filteredList.add(request));

//     return filteredList;
//   }

//   Widget getOfferWidget(OfferModel model) {
//     return Container(
//       decoration: containerDecoration,
//       margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       child: Card(
//         elevation: 0,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               parentContext,
//               MaterialPageRoute(
//                 builder: (context) => OfferCardView(offerModel: model),
//               ),
//             );
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 StreamBuilder<UserModel>(
//                   stream: FirestoreManager.getUserForIdStream(
//                     sevaUserId: model.sevaUserId,
//                   ),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return CircleAvatar(foregroundColor: Colors.red);
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return CircleAvatar();
//                     }
//                     UserModel user = snapshot.data;
//                     return ClipOval(
//                       child: SizedBox(
//                         height: 40,
//                         width: 40,
//                         child: FadeInImage.assetNetwork(
//                             placeholder: 'lib/assets/images/profile.png',
//                             image: user.photoURL),
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         model.title.trim(),
//                         style: Theme.of(parentContext).textTheme.subhead,
//                       ),
//                       Text(
//                         model.description.trim(),
//                         style: Theme.of(parentContext).textTheme.subtitle,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String getTimeFormattedString(int timeInMilliseconds) {
//     DateFormat dateFormat = DateFormat('d MMM h:m a ');
//     String from = dateFormat.format(
//       DateTime.fromMillisecondsSinceEpoch(timeInMilliseconds),
//     );
//     return from;
//   }

//   BoxDecoration get containerDecoration {
//     return BoxDecoration(
//       borderRadius: BorderRadius.all(Radius.circular(12.0)),
//       boxShadow: [
//         BoxShadow(
//             color: Colors.black.withAlpha(10),
//             spreadRadius: 4,
//             offset: Offset(0, 3),
//             blurRadius: 6)
//       ],
//       color: Colors.white,
//     );
//   }
// }
