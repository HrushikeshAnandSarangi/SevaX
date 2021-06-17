//import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:flutter/material.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:sevaexchange/models/user_model.dart';
//import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
//import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
//import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
//
//class MembersManage extends StatefulWidget {
//  final TimebankModel timebankModel;
//
//  MembersManage({Key key, @required this.timebankModel}) : super(key: key);
//
//  State<StatefulWidget> createState() => MembersManageState();
//}
//
//class MembersManageState extends State<MembersManage> {
//  TimebankModel timebankModel;
//
//  @override
//  void initState() {
//    super.initState();
//    timebankModel = widget.timebankModel;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Manage Members'),
//      ),
//      body: StreamBuilder<TimebankModel>(
//        stream: FirestoreManager.getTimebankModelStream(
//            timebankId: timebankModel.id),
//        builder: (context, snapshots) {
//          if (snapshots.hasError) return Text('Error: ${snapshots.error}');
//          if (snapshots.connectionState == ConnectionState.waiting) {
//            return LoadingIndicator();
//          }
//
//          TimebankModel timebankSnapshotModel = snapshots.data;
//
//          return ListView(
//            children: timebankSnapshotModel.members.map((member) {
//              return StreamBuilder<UserModel>(
//                stream: FirestoreManager.getUserForEmailStream(member),
//                builder: (context, userSnapshot) {
//                  if (userSnapshot.hasError)
//                    return Text('Error: ${userSnapshot.error}');
//                  if (userSnapshot.connectionState == ConnectionState.waiting) {
//                    return LoadingIndicator();
//                  }
//
//                  UserModel userModel = userSnapshot.data;
//                  return Slidable(
//                    delegate: SlidableDrawerDelegate(),
//                    actionExtentRatio: 0.25,
//                    child: Container(
//                      color: Colors.white,
//                      child: ListTile(
//                        contentPadding: EdgeInsets.only(left: 25.0),
//                        title: Text(userModel.fullname ?? ''),
//                      ),
//                    ),
//                    actions: <Widget>[
//                      IconSlideAction(
//                        caption: 'Coordinator',
//                        color: Colors.green,
//                        icon: Icons.security,
//                        onTap: () => print('Coordinator'),
//                      ),
//                      IconSlideAction(
//                        caption: 'Admin',
//                        color: Colors.blue,
//                        icon: Icons.security,
//                        onTap: () => print('Admin'),
//                      ),
//                    ],
//                    secondaryActions: <Widget>[
//                      IconSlideAction(
//                        caption: 'Delete',
//                        color: Colors.red,
//                        icon: Icons.delete,
//                        onTap: () {
//                          List<String> existingMembers =
//                              timebankSnapshotModel.members;
//                          existingMembers.removeWhere(
//                              (member) => member == userModel.email);
//
//                          timebankSnapshotModel.members = existingMembers;
//
//                          CollectionRef
//                              .collection('timebanks')
//                              .doc(timebankSnapshotModel.id)
//                              .update(timebankSnapshotModel.toMap());
//
//                          CollectionRef
//                              .users
//                              .doc(userModel.email)
//                              .update({
//                            'membershipTimebanks':
//                                FieldValue.arrayRemove([timebankModel.id])
//                          });
//                        },
//                      ),
//                    ],
//                  );
//                },
//              );
//            }).toList(),
//          );
//        },
//      ),
//    );
//  }
//}
