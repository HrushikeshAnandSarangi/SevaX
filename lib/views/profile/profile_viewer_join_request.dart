// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';

// class ProfileViewerJoinRequest extends StatelessWidget {
//   final String userEmail;
//   final String reason;
//   final String tbName;

//   ProfileViewerJoinRequest({Key key, this.userEmail, this.reason, this.tbName})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.white),
//         backgroundColor: Theme.of(context).primaryColor,
//         title: Text(
//           'User Profile',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: false,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: Firestore.instance
//             .collection('users')
//             .document(userEmail)
//             .snapshots(),
//         builder:
//             (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   height: 110.0,
//                   child: Column(children: <Widget>[
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: <Widget>[
//                         Container(
//                             padding: EdgeInsets.only(top: 25.0),
//                             child: CircleAvatar(
//                               backgroundImage: (NetworkImage(
//                                   snapshot.data['photourl'] ??
//                                       defaultUserImageURL)),
//                               minRadius: 40.0,
//                             )
//                             //  SevaAvatar(),
//                             ),
//                       ],
//                     ),
//                   ]),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
//                   child: Center(
//                     child: Text(
//                       snapshot.data['fullname'],
//                       style: TextStyle(
//                           fontWeight: FontWeight.w800, fontSize: 17.0),
//                       // overflow: TextOverflow.ellipsis,
//                       // maxLines: 2,
//                     ),
//                   ),
//                   // NameInfo(),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0),
//                   child: Divider(
//                     color: Colors.deepPurple,
//                   ),
//                 ),

//                 // SHOWCASE NEW VIEW TO DO
//                 //  Container(
//                 //   color: Colors.teal,
//                 //   child: Showcase(),
//                 // ),

//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
//                   child: Text(
//                     'I would like to join your Timebank called ' +
//                         '"' +
//                         tbName +
//                         '"',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
//                   child: Text(
//                     'And the reason I would like to join: ' +
//                         '"' +
//                         reason +
//                         '"',
//                     style: TextStyle(fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(20.0),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 5.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         'Bio and CV',
//                         style: TextStyle(
//                             fontSize: 16.0, fontWeight: FontWeight.w700),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0),
//                   child: Text(
//                     snapshot.data['bio'] ?? 'User not updated bio',
//                     style:
//                         TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
//                   ),
//                 ),

//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
//                   child: Text(
//                     'My Interests',
//                     style:
//                         TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0),
//                   child: getChipWidgets(snapshot.data['interests']),
//                 ),

//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
//                   child: Text(
//                     'My Skills',
//                     style:
//                         TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.only(left: 25.0, right: 25.0),
//                   child: getChipWidgets(snapshot.data['skills']),
//                 ),

//                 // Container(
//                 //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
//                 //   child: TaskButton(),
//                 // ),
//                 // Container(
//                 //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
//                 //   child: HoursExchangeButton(),
//                 // ),
//                 Padding(
//                   padding: EdgeInsets.all(10.0),
//                 ),
//                 // Container(
//                 //   padding: EdgeInsets.only(left: 25.0, top: 15.0, right: 25.0),
//                 //   child: Text('appName  - ' + _appName + 'appName  - ' + _appName +
//                 //               'packageName  - ' + _packageName +
//                 //               'version  - ' + _version +
//                 //               'BuildNumber  - ' + _buildNumber),
//                 // ),
//                 // Container(
//                 //   child: Text(' '),
//                 // ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// Color _getChipColor() {
//   List colors = [
//     Colors.red,
//     Colors.pink,
//     Colors.purple,
//     Colors.deepPurple,
//     Colors.indigo,
//     Colors.blue,
//     Colors.lightBlue,
//     Colors.cyan,
//     Colors.teal,
//     Colors.green,
//     Colors.lightGreen,
//     Colors.lime,
//     Colors.amber,
//     Colors.orange,
//     Colors.deepOrange,
//     Colors.brown,
//     Colors.blueGrey,
//     Colors.redAccent,
//   ];

//   Random random = Random();
//   int selected = random.nextInt(18);

//   return colors[selected];
// }

// Widget getChipWidgets(List<dynamic> strings) {
//   return Wrap(
//     spacing: 5.0,
//     alignment: WrapAlignment.start,
//     children: strings
//         .map(
//           (item) => ActionChip(
//             padding: EdgeInsets.all(3.0),
//             onPressed: () {},
//             backgroundColor: _getChipColor(),
//             label: Text(
//               item,
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         )
//         .toList(),
//   );
// }
