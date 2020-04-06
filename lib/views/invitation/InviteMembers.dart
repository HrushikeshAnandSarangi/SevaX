// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/utils/utils.dart' as utils;
// import 'package:sevaexchange/views/messages/list_members_timebank.dart';
// import 'package:share/share.dart';

// import 'TimebankCodeModel.dart';

// class InviteMembers extends StatefulWidget {
//   final String communityId;
//   final String timebankId;

//   InviteMembers(this.timebankId, this.communityId);

//   @override
//   State<StatefulWidget> createState() => InviteMembersState(timebankId);
// }

// class InviteMembersState extends State<InviteMembers> {
//   String timebankId;
//   InviteMembersState(this.timebankId);
//   TimebankCodeModel codeModel = TimebankCodeModel();
//   Future<TimebankModel> timebankModel;

//   @override
//   void initState() {
//     timebankModel = getTimebankDetailsbyFuture(
//       timebankId: timebankId,
//     );
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           FlavorConfig.values.timebankName == "Yang 2020"
//               ? "Yang Gang Codes"
//               : "Timebank Codes",
//           style: TextStyle(
//             fontSize: 18,
//           ),
//         ),
//       ),
//       body: Column(
//         children: <Widget>[
//           Divider(
//             color: Colors.grey,
//             height: 0,
//           ),
//           FutureBuilder(
//             future: timebankModel,
//             builder: (BuildContext context, AsyncSnapshot snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               }
//               return getTimebankCodesWidget;
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         icon: Icon(Icons.add),
//         label: Text("Generate Code"),
//         onPressed: () {
//           _asyncInputDialog(context);
//         },
//       ),
//     );
//   }

//   String shareText(TimebankCodeModel timebankCode) {
//     var text =
//         "Please join me on the SevaX by using the code \"${timebankCode.timebankCode}\"";

//     return text;
//   }

//   Stream<List<TimebankCodeModel>> getTimebankCodes({
//     String timebankId,
//   }) async* {
//     var data = Firestore.instance
//         .collection('timebankCodes')
//         .where('timebankId', isEqualTo: timebankId)
//         .snapshots();

//     yield* data.transform(
//       StreamTransformer<QuerySnapshot, List<TimebankCodeModel>>.fromHandlers(
//         handleData: (querySnapshot, timebankCodeSink) {
//           List<TimebankCodeModel> timebankCodes = [];
//           querySnapshot.documents.forEach((documentSnapshot) {
//             timebankCodes.add(TimebankCodeModel.fromMap(
//               documentSnapshot.data,
//             ));
//           });
//           timebankCodeSink.add(timebankCodes);
//         },
//       ),
//     );
//   }

//   Future<String> _asyncInputDialog(BuildContext context) async {
//     String timebankCode = createCryptoRandomString();

//     String teamName = '';
//     return showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Code generated"),
//           content: new Row(
//             children: <Widget>[
//               Text(timebankCode + " is your code."),
//             ],
//           ),
//           actions: <Widget>[
//             RaisedButton(
//               padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
//               color: Theme.of(context).accentColor,
//               textColor: FlavorConfig.values.buttonTextColor,
//               child: Text(
//                 'Publish code',
//                 style: TextStyle(
//                   fontSize: dialogButtonSize,
//                 ),
//               ),
//               onPressed: () {
//                 var today = new DateTime.now();
//                 var oneDayFromToday =
//                     today.add(new Duration(days: 30)).millisecondsSinceEpoch;
//                 registerTimebankCode(
//                   timebankCode: timebankCode,
//                   timebankId: timebankId,
//                   validUpto: oneDayFromToday,
//                   communityId: widget.communityId,
//                 );
//                 Navigator.of(context).pop("completed");
//               },
//             ),
//             FlatButton(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.red, fontSize: dialogButtonSize),
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   static String createCryptoRandomString([int length = 10]) {
//     final Random _random = Random.secure();
//     var values = List<int>.generate(length, (i) => _random.nextInt(100));
//     return base64Url.encode(values).substring(0, 6).toLowerCase();
//   }

//   Future<void> registerTimebankCode({
//     String timebankId,
//     String timebankCode,
//     int validUpto,
//     String communityId,
//   }) async {
//     codeModel.createdOn = DateTime.now().millisecondsSinceEpoch;
//     codeModel.timebankId = timebankId;
//     codeModel.validUpto = validUpto;
//     codeModel.timebankCodeId = utils.Utils.getUuid();
//     codeModel.timebankCode = timebankCode;
//     codeModel.communityId = communityId;

//     print('codemodel ${codeModel.toString()}');
//     await Firestore.instance
//         .collection('timebankCodes')
//         .document(codeModel.timebankCodeId)
//         .setData(codeModel.toMap());
//   }

//   void deleteShareCode(String timebankCodeId) {
//     Firestore.instance
//         .collection("timebankCodes")
//         .document(timebankCodeId)
//         .delete();

//     print('deleted');
//   }

//   Widget get getTimebankCodesWidget {
//     return StreamBuilder<List<TimebankCodeModel>>(
//         stream: getTimebankCodes(timebankId: timebankId),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text(snapshot.error.toString());
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           List<TimebankCodeModel> codeList = snapshot.data.reversed.toList();

//           if (codeList.length == 0) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Text('No codes generated yet.'),
//               ),
//             );
//           }
//           return Expanded(
//             child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: codeList.length,
//                 itemBuilder: (context, index) {
//                   String length = "0";

//                   TimebankCodeModel timebankCode = codeList.elementAt(index);
//                   if (timebankCode.usersOnBoarded == null) {
//                     length = "Not yet redeemed";
//                   } else {
//                     if (timebankCode.usersOnBoarded.length == 1) {
//                       length = "Redeemed by 1 user";
//                     } else if (timebankCode.usersOnBoarded.length > 1) {
//                       length =
//                           "Redeemed by ${timebankCode.usersOnBoarded.length} users";
//                     } else {
//                       length = "Not yet redeemed";
//                     }
//                   }
//                   return GestureDetector(
//                     child: Card(
//                       margin: EdgeInsets.all(5),
//                       child: Container(
//                         margin: EdgeInsets.all(15),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Text(FlavorConfig.values.timebankName == "Yang 2020"
//                                 ? "Yang Gang Code : " +
//                                     timebankCode.timebankCode
//                                 : "Timebank code : " +
//                                     timebankCode.timebankCode),
//                             Text(length),
//                             Text(
//                               DateTime.now().millisecondsSinceEpoch >
//                                       timebankCode.validUpto
//                                   ? "Expired"
//                                   : "Active",
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 GestureDetector(
//                                   onTap: () {
//                                     Share.share(shareText(timebankCode));
//                                   },
//                                   child: Container(
//                                     margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
//                                     child: Text(
//                                       'Share code',
//                                       style: TextStyle(color: Colors.blue),
//                                     ),
//                                   ),
//                                 ),
//                                 GestureDetector(
//                                   child: IconButton(
//                                     icon: Image.asset(
//                                       'lib/assets/images/recycle-bin.png',
//                                     ),
//                                     iconSize: 30,
//                                     onPressed: () {
//                                       deleteShareCode(
//                                           timebankCode.timebankCodeId);
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }),
//           );
//         });
//   }
// }
