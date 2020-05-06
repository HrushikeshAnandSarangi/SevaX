// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

// class MembersManageCampaign extends StatefulWidget {
//   final String campaignID;

//   MembersManageCampaign({Key key, this.campaignID}) : super(key: key);

//   createState() => MembersManageCampaignState();
// }

// class MembersManageCampaignState extends State<MembersManageCampaign> {
//   createState() => MembersManageCampaignState();

//   int indexItemNumber;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<CampaignModel>(
//       stream: FirestoreManager.getCampaignForIdStream(
//           campaignId: widget.campaignID),
//       builder: (context, campaignSnapshot) {
//         if (campaignSnapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Loading'),
//             ),
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         CampaignModel campaignModel = campaignSnapshot.data;

//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Manage Members'),
//           ),
//           body: ListView(
//             children: campaignModel.members
//                 .map(
//                   (member) => Slidable(
//                     delegate: SlidableDrawerDelegate(),
//                     actionExtentRatio: 0.25,
//                     child: Container(
//                       color: Colors.white,
//                       child: ListTile(
//                         contentPadding: EdgeInsets.only(left: 25.0),
//                         title: Text(member.fullName),
//                       ),
//                     ),
//                     actions: <Widget>[
//                       IconSlideAction(
//                         caption: 'Coordinator',
//                         color: Colors.green,
//                         icon: Icons.security,
//                         onTap: () => log('Coordinator'),
//                       ),
//                       IconSlideAction(
//                         caption: 'Admin',
//                         color: Colors.blue,
//                         icon: Icons.security,
//                         onTap: () => log('Admin'),
//                       ),
//                     ],
//                     secondaryActions: <Widget>[
//                       IconSlideAction(
//                         caption: 'Delete',
//                         color: Colors.red,
//                         icon: Icons.delete,
//                         onTap: () {
//                           List<Member> updatedMembers = campaignModel.members;
//                           updatedMembers.removeWhere((queryMember) {
//                             return queryMember.email == member.email;
//                           });

//                           campaignModel.members = updatedMembers;
//                           Firestore.instance
//                               .collection('campaigns')
//                               .document(campaignModel.id)
//                               .updateData(campaignModel.toMap());

//                           Firestore.instance
//                               .collection('users')
//                               .document(member.email)
//                               .updateData({
//                             'membership_campaigns':
//                                 FieldValue.arrayRemove([campaignModel.id])
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 )
//                 .toList(),
//           ),
//         );
//       },
//     );
//   }
// }
