import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class MembersManage extends StatefulWidget {
  final TimebankModel timebankModel;

  MembersManage({Key key, @required this.timebankModel}) : super(key: key);

  createState() => MembersManageState();
}

class MembersManageState extends State<MembersManage> {
  TimebankModel timebankModel;

  @override
  void initState() {
    super.initState();
    timebankModel = widget.timebankModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Members'),
      ),
      body: StreamBuilder<TimebankModel>(
        stream: FirestoreManager.getTimebankModelStream(
            timebankId: timebankModel.id),
        builder: (context, snapshots) {
          if (snapshots.hasError) return Text('Error: ${snapshots.error}');
          if (snapshots.connectionState == ConnectionState.waiting) {
            print('Waiting for members');
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          print('Got members');
          TimebankModel timebankSnapshotModel = snapshots.data;
          print('${'-' * 10}\n${timebankSnapshotModel.toMap()}\n${'-' * 10}');
          return ListView(
            children: timebankSnapshotModel.members.map((member) {
              return StreamBuilder<UserModel>(
                stream: FirestoreManager.getUserForEmailStream(member),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError)
                    return Text('Error: ${userSnapshot.error}');
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    print('Waiting for Users');
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  print('Got users');
                  UserModel userModel = userSnapshot.data;
                  return Slidable(
                    delegate: SlidableDrawerDelegate(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 25.0),
                        title: Text(userModel.fullname ?? ''),
                      ),
                    ),
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Coordinator',
                        color: Colors.green,
                        icon: Icons.security,
                        onTap: () => print('Coordinator'),
                      ),
                      IconSlideAction(
                        caption: 'Admin',
                        color: Colors.blue,
                        icon: Icons.security,
                        onTap: () => print('Admin'),
                      ),
                    ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          List<String> existingMembers =
                              timebankSnapshotModel.members;
                          existingMembers.removeWhere(
                              (member) => member == userModel.email);

                          timebankSnapshotModel.members = existingMembers;

//                          indexItemNumber = globals
//                              .currentTimebankMembersFullname
//                              .indexOf(item);
//                          print(indexItemNumber);
//
//                          _tempEmail = globals
//                              .currentTimebankMembersEmail[indexItemNumber];
//
//                          globals.currentTimebankMembersEmail
//                              .removeAt(indexItemNumber);
//                          globals.currentTimebankMembersFullname
//                              .removeAt(indexItemNumber);
//                          globals.currentTimebankMembersPhotoURL
//                              .removeAt(indexItemNumber);
//                          print(globals.currentTimebankMembers.toString());
//                          print('docID - ' + docID);

                          Firestore.instance
                              .collection('timebanks')
                              .document(timebankSnapshotModel.id)
                              .updateData(timebankSnapshotModel.toMap());

                          Firestore.instance
                              .collection('users')
                              .document(userModel.email)
                              .updateData({
                            'membership_timebanks':
                                FieldValue.arrayRemove([timebankModel.id])
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Manage Members'),
//      ),
//      body: StreamBuilder<DocumentSnapshot>(
//        stream: Firestore.instance
//            .collection('timebanks')
//            .document(docID)
//            // .orderBy('posttimestamp', descending: true)
//            .snapshots(),
//        builder: (context, snapshot) {
//          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
//          switch (snapshot.connectionState) {
//            case ConnectionState.waiting:
//              return Center(child: CircularProgressIndicator());
//            default:
//              globals.currentTimebankMembersEmail = List<String>.from(snapshot.data['membersemail']);
//              globals.currentTimebankMembersFullname = List<String>.from(snapshot.data['membersfullname']);
//              globals.currentTimebankMembersPhotoURL = List<String>.from(snapshot.data['membersphotourl']);
//              // var memberList = snapshot.data['members'];
//
//              return Column(
//                children: globals.currentTimebankMembersFullname
//                    .map(
//                      (item) => Slidable(
//                            delegate: SlidableDrawerDelegate(),
//                            actionExtentRatio: 0.25,
//                            child: Container(
//                              color: Colors.white,
//                              child: ListTile(
//                                contentPadding: EdgeInsets.only(left: 25.0),
//                                title: Text(item),
//                              ),
//                            ),
//                            actions: <Widget>[
//                               IconSlideAction(
//                                caption: 'Coordinator',
//                                color: Colors.green,
//                                icon: Icons.security,
//                                onTap: () => print('Coordinator'),
//                              ),
//                              IconSlideAction(
//                                caption: 'Admin',
//                                color: Colors.blue,
//                                icon: Icons.security,
//                                onTap: () => print('Admin'),
//                              ),
//                            ],
//                            secondaryActions: <Widget>[
//                              IconSlideAction(
//                                caption: 'Delete',
//                                color: Colors.red,
//                                icon: Icons.delete,
//                                onTap: () {
//                                  print(item + ' deleted');
//                                  indexItemNumber = globals.currentTimebankMembersFullname.indexOf(item);
//                                  print(indexItemNumber);
//
//                                  _tempEmail = globals.currentTimebankMembersEmail[indexItemNumber];
//
//                                  globals.currentTimebankMembersEmail.removeAt(indexItemNumber);
//                                  globals.currentTimebankMembersFullname.removeAt(indexItemNumber);
//                                  globals.currentTimebankMembersPhotoURL.removeAt(indexItemNumber);
//                                  print(globals.currentTimebankMembers.toString());
//                                  print('docID - ' + docID);
//                                  Firestore.instance.collection('timebanks').document(docID).updateData({
//                                    'membersemail': globals.currentTimebankMembersEmail,
//                                    'membersfullname': globals.currentTimebankMembersFullname,
//                                    'membersphotourl': globals.currentTimebankMembersPhotoURL,
//                                  });
//
//                                Firestore.instance
//                                      .collection('users')
//                                      .document(_tempEmail)
//                                      .updateData({
//                                        'membership_timebanks': FieldValue.arrayRemove([docID])
//                                  });
//
//                                },
//                              ),
//                            ],
//                          ),
//                    )
//                    .toList(),
//              );
//          }
//        },
//      ),
//    );
//  }
}
