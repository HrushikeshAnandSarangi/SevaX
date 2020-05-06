// import 'package:flutter/material.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/globals.dart' as globals;
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
// import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/exchange/createoffer.dart';
// import 'package:sevaexchange/views/exchange/createrequest.dart';
// import 'package:sevaexchange/views/news/newscreate.dart';
// import 'package:sevaexchange/views/profile/profileviewer.dart';
// import 'package:sevaexchange/views/timebanks/branch_list.dart';
// import 'package:sevaexchange/views/timebanks/join_request_view.dart';
// import 'package:sevaexchange/views/timebanks/timebank_admin_view.dart';
// import 'package:sevaexchange/views/timebanks/timebank_join_request.dart';
// import 'package:sevaexchange/views/timebanks/timebank_join_requests_view.dart';
// import 'package:sevaexchange/views/timebanks/timebankcreate.dart';
// import 'package:sevaexchange/views/timebanks/timebankedit.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../flavor_config.dart';

// class BranchView extends StatefulWidget {
//   final String timebankId;

//   BranchView({
//     @required this.timebankId,
//   });

//   @override
//   _BranchViewState createState() => _BranchViewState();
// }

// class _BranchViewState extends State<BranchView> {
//   TimebankModel timebankModel;
//   JoinRequestModel joinRequestModel = new JoinRequestModel();
//   UserModel ownerModel;
//   String title = 'Loading';
//   String loggedInUser;
//   final formkey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext buildcontext) {
//     loggedInUser = SevaCore.of(context).loggedInUser.sevaUserID;
//     return timebankStreamBuilder(buildcontext);
//   }

//   StreamBuilder<TimebankModel> timebankStreamBuilder(
//       BuildContext buildcontext) {
//     return StreamBuilder<TimebankModel>(
//       stream: FirestoreManager.getTimebankModelStream(
//           timebankId: widget.timebankId),
//       builder: (streamContext, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text('Loading'),
//                 actions: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.home),
//                     onPressed: () {
//                       Navigator.popUntil(context,
//                           ModalRoute.withName(Navigator.defaultRouteName));
//                     },
//                   )
//                 ],
//               ),
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//             break;
//           default:
//             this.timebankModel = snapshot.data;
//             globals.timebankAvatarURL = timebankModel.photoUrl;
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(
//                   '${timebankModel.name}',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 actions: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.home),
//                     onPressed: () {
//                       Navigator.popUntil(context,
//                           ModalRoute.withName(Navigator.defaultRouteName));
//                     },
//                   )
//                 ],
//               ),
//               floatingActionButton: FloatingActionButton.extended(
//                 icon: Icon(
//                   Icons.add,
//                 ),
//                 foregroundColor: FlavorConfig.values.buttonTextColor,
//                 label: Text(
//                   'Create Branch',
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => TimebankCreate(
//                               timebankId: timebankModel.id,
//                             )),
//                   );
//                 },
//               ),
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     padding: EdgeInsets.only(
//                       top: 20.0,
//                       right: 20.0,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: <Widget>[
//                             Container(
//                               padding: EdgeInsets.only(right: 15.0, left: 20.0),
//                               child: CircleAvatar(
//                                 backgroundColor: Colors.grey,
//                                 backgroundImage:
//                                     _avatarImage(timebankModel.photoUrl),
//                                 minRadius: 40.0,
//                               ),
//                             ),
//                             Flexible(
//                               child: Text(
//                                 '${timebankModel.name}' ?? '',
//                                 style: TextStyle(
//                                   fontSize: 18.0,
//                                   fontStyle: FontStyle.normal,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           padding: EdgeInsets.only(left: 20.0),
//                           child: Divider(color: Colors.deepPurple),
//                         ),
//                         timebankModel.admins.contains(loggedInUser)
//                             ? FlatButton(
//                                 child: Text('View Requests'),
//                                 textColor: Theme.of(context).accentColor,
//                                 disabledTextColor:
//                                     Theme.of(context).accentColor,
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => JoinRequestView(
//                                               timebankId: timebankModel.id,
//                                             )),
//                                   );
//                                 },
//                               )
//                             : timebankModel.members.contains(loggedInUser)
//                                 ? Offstage()
//                                 : FlatButton(
//                                     child:
//                                         Text('Request to join this Timebank'),
//                                     textColor: Theme.of(context).accentColor,
//                                     disabledTextColor:
//                                         Theme.of(context).accentColor,
//                                     onPressed: () {
//                                       showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           // return object of type Dialog
//                                           return AlertDialog(
//                                             title: new Text(
//                                                 "Why do you want to join the timebank? "),
//                                             content: Form(
//                                               key: formkey,
//                                               child: TextFormField(
//                                                 decoration: InputDecoration(
//                                                   hintText: 'Reason',
//                                                   labelText: 'Reason',
//                                                   // labelStyle: textStyle,
//                                                   // labelStyle: textStyle,
//                                                   // labelText: 'Description',
//                                                   border: OutlineInputBorder(
//                                                     borderRadius:
//                                                         const BorderRadius.all(
//                                                       const Radius.circular(
//                                                           20.0),
//                                                     ),
//                                                     borderSide: new BorderSide(
//                                                       color: Colors.black,
//                                                       width: 1.0,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 keyboardType:
//                                                     TextInputType.multiline,
//                                                 maxLines: 1,
//                                                 validator: (value) {
//                                                   if (value.isEmpty) {
//                                                     return 'Please enter some text';
//                                                   }
//                                                   joinRequestModel.reason =
//                                                       value;
//                                                 },
//                                               ),
//                                             ),
//                                             actions: <Widget>[
//                                               // usually buttons at the bottom of the dialog
//                                               new FlatButton(
//                                                 padding: EdgeInsets.fromLTRB(
//                                                     20, 5, 20, 5),
//                                                 color: Theme.of(context)
//                                                     .accentColor,
//                                                 textColor: FlavorConfig
//                                                     .values.buttonTextColor,
//                                                 child: new Text(
//                                                   "Send Join Request",
//                                                   style: TextStyle(
//                                                       fontSize:
//                                                           dialogButtonSize,
//                                                       fontFamily: 'Europa'),
//                                                 ),
//                                                 onPressed: () async {
//                                                   //For test
//                                                   Navigator.of(context).pop();

//                                                   joinRequestModel.userId =
//                                                       loggedInUser;
//                                                   joinRequestModel
//                                                       .timestamp = DateTime
//                                                           .now()
//                                                       .millisecondsSinceEpoch;

//                                                   joinRequestModel.entityId =
//                                                       timebankModel.id;
//                                                   joinRequestModel.entityType =
//                                                       EntityType.Timebank;
//                                                   joinRequestModel.accepted =
//                                                       null;

//                                                   if (formkey.currentState
//                                                       .validate()) {
//                                                     await updateJoinRequest(
//                                                         model:
//                                                             joinRequestModel);
//                                                   }
//                                                 },
//                                               ),
//                                               new FlatButton(
//                                                 child: new Text(
//                                                   "Close",
//                                                   style: TextStyle(
//                                                       fontSize:
//                                                           dialogButtonSize,
//                                                       color: Colors.red,
//                                                       fontFamily: 'Europa'),
//                                                 ),
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop();
//                                                 },
//                                               ),
//                                             ],
//                                           );
//                                         },
//                                       );
//                                     },
//                                   ),

//                         _showCreateCampaignButton(context),
//                         _showJoinRequests(context),
//                         FlatButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       _whichRoute('viewcampaigns')),
//                             );
//                           },
//                           child: _whichButton('viewcampaigns'),
//                         ),
//                         FlatButton(
//                           child: Text(
//                             'View Branches',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => BranchList(
//                                         timebankid: timebankModel.id,
//                                       )),
//                             );
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(
//                             'Create News Feed',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => NewsCreate(
//                                     timebankId: timebankModel.id,
//                                   ),
//                                 ));
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(
//                             'Create ${FlavorConfig.values.requestTitle}',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => CreateRequest(
//                                   timebankId: timebankModel.id,
//                                   projectId: "",
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(
//                             'Create ${FlavorConfig.values.offertitle}',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => CreateOffer(
//                                         timebankId: timebankModel.id,
//                                       )),
//                             );
//                           },
//                         ),
//                         timebankModel.parentTimebankId != null
//                             ? FutureBuilder<Object>(
//                                 future: FirestoreManager.getTimeBankForId(
//                                     timebankId: timebankModel.parentTimebankId),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasError)
//                                     return Text('Error: ${snapshot.error}');
//                                   if (snapshot.connectionState ==
//                                       ConnectionState.waiting)
//                                     return Offstage();
//                                   TimebankModel model = snapshot.data;
//                                   return Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             top: 10.0, left: 20.0),
//                                         child: Text(
//                                           'Parent Timebank',
//                                           style: TextStyle(
//                                             fontSize: 18.0,
//                                             fontWeight: FontWeight.w700,
//                                             decoration:
//                                                 TextDecoration.underline,
//                                           ),
//                                         ),
//                                       ),
//                                       Padding(
//                                         padding: EdgeInsets.only(
//                                             top: 10.0, left: 20.0),
//                                         child: Text(
//                                           '${model.name}',
//                                           style: TextStyle(fontSize: 18.0),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 })
//                             : Offstage(),

//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             'Mission Statement',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             '${timebankModel.missionStatement}',
//                             style: TextStyle(fontSize: 18.0),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 20.0, left: 20.0),
//                           child: Text(
//                             'Address',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             '${timebankModel.address}',
//                             style: TextStyle(fontSize: 18.0),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 20.0, left: 20.0),
//                           child: Text(
//                             'Phone Number',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 3.0),
//                           child: FlatButton(
//                             child: Text(
//                               '${timebankModel.phoneNumber}',
//                               style: TextStyle(
//                                   fontSize: 18.0, fontWeight: FontWeight.w400),
//                             ),
//                             onPressed: () {
//                               String _number = timebankModel.phoneNumber;
//                               launch('tel:$_number');
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             'Email',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 3.0),
//                           child: FlatButton(
//                             child: Text(
//                               '${timebankModel.emailId}',
//                               style: TextStyle(
//                                 fontSize: 18.0,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             onPressed: () {
//                               String _email = '${timebankModel.emailId}';
//                               launch('mailto:$_email');
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             'Closed :',
//                             style: TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w700,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 10.0, left: 20.0),
//                           child: Text(
//                             '${timebankModel.protected}',
//                             style: TextStyle(fontSize: 18.0),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 20, bottom: 80),
//                           child: Row(
//                             children: <Widget>[
//                               Text(
//                                 'Manage Members',
//                                 style: TextStyle(
//                                     fontSize: 18.0,
//                                     fontWeight: FontWeight.w700),
//                               ),
//                               _showManageMembersButton(context)
//                             ],
//                           ),
//                         ),
//                         // StreamBuilder<UserModel>(
//                         //   stream: FirestoreManager.getUserForIdStream(
//                         //       sevaUserId: timebankModel.creatorId),
//                         //   builder: (context, snapshot) {
//                         //     if (snapshot.hasError)
//                         //       return Text('Error: ${snapshot.error}');
//                         //     switch (snapshot.connectionState) {
//                         //       case ConnectionState.waiting:
//                         //         return Center(
//                         //             child: CircularProgressIndicator());
//                         //         break;
//                         //       default:
//                         //         UserModel ownerModel = snapshot.data;
//                         //         this.ownerModel = ownerModel;
//                         //         return FlatButton(
//                         //           onPressed: ownerModel != null
//                         //               ? () {
//                         //                   Navigator.push(
//                         //                       context,
//                         //                       MaterialPageRoute(
//                         //                           builder: (context) =>
//                         //                               ProfileViewer(
//                         //                                 userEmail:
//                         //                                     ownerModel.email,
//                         //                               )));
//                         //                 }
//                         //               : null,
//                         //           child: Row(
//                         //             children: <Widget>[
//                         //               Padding(
//                         //                 padding: const EdgeInsets.only(
//                         //                     left: 28.0,
//                         //                     right: 8.0,
//                         //                     top: 8.0,
//                         //                     bottom: 8.0),
//                         //                 child: CircleAvatar(
//                         //                   // minRadius: 20.0,
//                         //                   backgroundImage: ownerModel == null ||
//                         //                           ownerModel.photoURL == null ||
//                         //                           ownerModel.photoURL.isEmpty
//                         //                       ? AssetImage(
//                         //                           'lib/assets/images/noimagefound.png')
//                         //                       : NetworkImage(
//                         //                           ownerModel.photoURL),
//                         //                 ),
//                         //               ),
//                         //               Flexible(
//                         //                 child: Container(
//                         //                   padding: EdgeInsets.only(right: 13.0),
//                         //                   child: ownerModel != null &&
//                         //                           ownerModel.fullname != null
//                         //                       ? Text(
//                         //                           ownerModel.fullname,
//                         //                           overflow:
//                         //                               TextOverflow.ellipsis,
//                         //                           style: TextStyle(
//                         //                             fontSize: 18.0,
//                         //                           ),
//                         //                         )
//                         //                       : Container(),
//                         //                 ),
//                         //               ),
//                         //             ],
//                         //           ),
//                         //         );
//                         //     }
//                         //   },
//                         // ),
//                         //getTextWidgets(context),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//         }
//       },
//     );
//   }

//   Widget _showCreateCampaignButton(BuildContext context) {
//     if (timebankModel.creatorId ==
//         SevaCore.of(context).loggedInUser.sevaUserID) {
//       return FlatButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => _whichRoute('campaigns'),
//             ),
//           );
//         },
//         child: _whichButton('campaigns'),
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.all(0.0),
//       );
//     }
//   }

//   Widget _showJoinRequests(BuildContext context) {
//     if (timebankModel.creatorId ==
//         SevaCore.of(context).loggedInUser.sevaUserID) {
//       return FlatButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => _whichRoute('joinrequests'),
//             ),
//           );
//         },
//         child: _whichButton('joinrequests'),
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.all(0.0),
//       );
//     }
//   }

//   Widget _whichRoute(String section) {
//     switch (section) {
//       case 'timebanks':
//         if (timebankModel.creatorId ==
//             SevaCore.of(context).loggedInUser.sevaUserID) {
//           return TimebankEdit(
//             ownerModel: ownerModel,
//             timebankModel: timebankModel,
//           );
//         } else {
//           return TimebankJoinRequest(
//             timebankModel: timebankModel,
//             owner: ownerModel,
//           );
//         }
//         break;
//       // case 'campaigns':
//       //   if (timebankModel.creatorId ==
//       //       SevaCore.of(context).loggedInUser.sevaUserID) {
//       //     return CampaignCreate(
//       //       timebankModel: timebankModel,
//       //     );
//       //   } else {
//       //     return CampaignJoin();
//       //   }
//       //   break;
//       // case 'viewcampaigns':
//       //   return CampaignsView(
//       //     timebankModel: timebankModel,
//       //   );
//       // break;
//       case 'joinrequests':
//         return TimebankJoinRequestView(
//           timebankModel: timebankModel,
//         );
//         break;
//       default:
//         return null;
//     }
//   }

//   Widget _whichButton(String section) {
//     switch (section) {
//       case 'timebanks':
//         if (timebankModel.creatorId ==
//             SevaCore.of(context).loggedInUser.sevaUserID) {
//           return Text(
//             'Edit Timebank',
//             style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).accentColor),
//           );
//         } else {
//           return Offstage();
//         }
//         break;
//       case 'campaigns':
//         if (timebankModel.creatorId ==
//             SevaCore.of(context).loggedInUser.sevaUserID) {
//           return Text(
//             'Create a Campaign (Project)',
//             style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).accentColor),
//           );
//         } else {
//           return Text(
//             'Join a Campaign (Project)',
//             style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: Theme.of(context).accentColor),
//           );
//         }
//         break;
//       case 'viewcampaigns':
//         return Text(
//           'View Current Campaigns',
//           style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Theme.of(context).accentColor),
//         );
//         break;
//       case 'joinrequests':
//         return Text(
//           'View Timebank Join Requests',
//           style: TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Theme.of(context).accentColor),
//         );
//         break;
//       default:
//         return null;
//     }
//   }

//   Widget _showManageMembersButton(BuildContext context) {
//     assert(timebankModel.id != null);
//     return FlatButton(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) {
//               return TimebankAdminPage(
//                 timebankId: timebankModel.id,
//                 userEmail: SevaCore.of(context).loggedInUser.email,
//               );
//             },
//           ),
//         );
//       },
//       child: Icon(Icons.edit),
//     );
//   }

//   Widget getTextWidgets(BuildContext context) {
//     List<Widget> list = List<Widget>();

//     timebankModel.members.forEach(
//       (member) {
//         list.add(
//           FlatButton(
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (routeContext) => ProfileViewer(userEmail: member),
//                 ),
//               );
//             },
//             child: StreamBuilder<UserModel>(
//                 stream: FirestoreManager.getUserForEmailStream(member),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Text(snapshot.error.toString());
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Container();
//                   }
//                   UserModel user = snapshot.data;
//                   return Row(
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: CircleAvatar(
//                           // minRadius: 20.0,
//                           backgroundImage: user.photoURL == null ||
//                                   user.photoURL.isEmpty
//                               ? AssetImage('lib/assets/images/noimagefound.png')
//                               : NetworkImage(user.photoURL),
//                         ),
//                       ),
//                       Flexible(
//                         child: Container(
//                           padding: EdgeInsets.only(right: 13.0),
//                           child: Text(
//                             user.fullname ?? '',
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 18.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//           ),
//         );
//       },
//     );

//     return Padding(
//       padding: const EdgeInsets.only(left: 20.0),
//       child:
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
//     );
//   }

//   ImageProvider _avatarImage(avatarURL) {
//     if (avatarURL == null || avatarURL == '') {
//       return AssetImage('lib/assets/images/profile.png');
//     } else {
//       return NetworkImage(avatarURL);
//     }
//   }
// }
