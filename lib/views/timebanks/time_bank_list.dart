// import 'package:flutter/material.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
// import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
// import 'package:sevaexchange/views/timebanks/timebank_view.dart';
// import 'package:sevaexchange/views/timebanks/timebankcreate.dart';

// class TimeBankList extends StatelessWidget {
//   final String timebankid;
//   final String title;
//   TimebankModel superAdminTimebankModel;
//   TimeBankList(
//       {@required this.timebankid,
//       @required this.title,
//       this.superAdminTimebankModel});

//   @override
//   Widget build(BuildContext context) {
//     print('timebankid asasasas:$timebankid');
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(
//             FlavorConfig.values.timebankName == "Yang 2020"
//                 ? "Yang Gang Chapters"
//                 : "${FlavorConfig.values.timebankTitle} list",
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.home),
//               onPressed: () {
//                 Navigator.popUntil(
//                     context, ModalRoute.withName(Navigator.defaultRouteName));
//               },
//             )
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           label: Text('Create Timebank'),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => TimebankCreate(
//                   timebankId: timebankid,
//                 ),
//               ),
//             );
//           },
//           foregroundColor: FlavorConfig.values.buttonTextColor,
//         ),
//         body: getSubTimebanks(timebankid));
//   }

//   Widget getSubTimebanks(String timebankId) {
//     return StreamBuilder<List<TimebankModel>>(
//       stream: getChildTimebanks(
//         timebankId: timebankId,
//       ),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text(snapshot.error.toString());
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//         List<TimebankModel> reportedList = snapshot.data;
//         return Container(
//           child: ListView(
//             children: <Widget>[
//               getDataScrollView(
//                 context,
//                 reportedList,
//               ),
//               Container(
//                 height: 100,
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget getDataScrollView(
//     BuildContext context,
//     List<TimebankModel> reportedList,
//   ) {
//     return getContent(context, reportedList);
//   }

//   Widget getContent(BuildContext context, List<TimebankModel> timebankList) {
//     return Column(
//       children: <Widget>[
//         ...timebankList.map((model) {
//           return model.id != FlavorConfig.values.timebankId
//               ? GestureDetector(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: <Widget>[
//                           Container(
//                             child: CircleAvatar(
//                               minRadius: 32.0,
//                               backgroundColor: Colors.grey,
//                               backgroundImage: _getImage(model),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 8,
//                           ),
//                           Container(
//                             child: Expanded(
//                               child: Text(
//                                 model.name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 18.0,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.of(context).push(
//                       MaterialPageRoute(
//                         settings: RouteSettings(name: "123"),
//                         builder: (routeContext) {
//                           return TimebankView(
//                             timebankId: model.id,
//                             superAdminTimebankModel:
//                                 this.superAdminTimebankModel,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 )
//               : Offstage();
//         })
//       ],
//     );
//   }

//   ImageProvider _getImage(TimebankModel model) {
//     if (model.photoUrl == null) {
//       return AssetImage('lib/assets/images/profile.png');
//     } else {
//       return NetworkImage(model.photoUrl);
//     }
//   }
// }
