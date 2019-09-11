import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/views/profile/profile_viewer_join_request.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';

import '../membersaddedit.dart';

class TimebankJoinRequestView extends StatefulWidget {
  final TimebankModel timebankModel;

  TimebankJoinRequestView({
    Key key,
    @required this.timebankModel,
  }) : super(key: key) {
    assert(timebankModel.id != null, 'Timebank ID cannot be null');
  }

  @override
  TimebankJoinRequestViewState createState() => TimebankJoinRequestViewState();
}

class TimebankJoinRequestViewState extends State<TimebankJoinRequestView> {
  TimebankJoinRequestViewState({Key key});

  TimebankModel timebankModel;
  int indexItemNumber;

  @override
  void initState() {
    super.initState();
    timebankModel = widget.timebankModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('join_requests_timebanks')
            .where('timebankid', isEqualTo: widget.timebankModel.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              return Column(
                children: snapshot.data.documents
                    .map(
                      (item) => Slidable(
                        delegate: SlidableDrawerDelegate(),
                        actionExtentRatio: 0.25,
                        child: Container(
                          padding: EdgeInsets.only(left: 5.0),
                          color: Colors.white,
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                minRadius: 15.0,
                                backgroundImage:
                                    NetworkImage(item['requestor_photourl']),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileViewerJoinRequest(
                                              userEmail:
                                                  item['requestor_email'],
                                              reason: item['reason'],
                                              tbName: item['timebank_name'],
                                            )),
                                  );
                                },
                                child: Text(item['requestor_fullname']),
                                // contentPadding: EdgeInsets.only(left: 25.0),
                                // title: Text(item['requestor_fullname']),
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Accept',
                            color: Colors.blue,
                            icon: Icons.security,
                            onTap: () {
//                                  setState(() {
//                                    globals.currentTimebankMembersEmail
//                                        .add(item['requestor_email']);
//                                    globals.currentTimebankMembersFullname
//                                        .add(item['requestor_fullname']);
//                                    globals.currentTimebankMembersPhotoURL
//                                        .add(item['requestor_photourl']);
//
//                                    // globals.userTimebanksCampaigns.add(globals.currentCampaignCreator + '*' + globals.currentCampaignCreatedTimeStamp.toString());
//                                  });
                              Member newMember = Member(
                                fullName: item['requestor_fullname'],
                                email: item['requestor_email'],
                                photoUrl: item['requestor_photourl'],
                              );

                              timebankModel.members.add(newMember.email);

                              Firestore.instance
                                  .collection('timebanks')
                                  .document(widget.timebankModel.id)
                                  .updateData(timebankModel.toMap());

                              Firestore.instance
                                  .collection('users')
                                  .document(item['requestor_email'])
                                  .updateData({
                                'membership_timebanks':
                                    FieldValue.arrayUnion([timebankModel.id])
                              });

                              Firestore.instance
                                  .collection('join_requests_timebanks')
                                  .document(timebankModel.id +
                                      '*' +
                                      item['requestor_email'])
                                  .delete();
                            },
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Reject',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              Firestore.instance
                                  .collection('join_requests_timebanks')
                                  .document(timebankModel.id +
                                      '*' +
                                      item['requestor_email'])
                                  .delete();
                            },
                          ),
                        ],
                      ),
                    )
                    .toList(),
              );
          }
        },
      ),
    );
  }
}
