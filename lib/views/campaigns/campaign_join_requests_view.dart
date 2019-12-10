import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/views/profile/profile_viewer_join_request.dart';

class CampaignJoinRequestView extends StatefulWidget {
  final String campaignID;

  CampaignJoinRequestView({Key key, this.campaignID}) : super(key: key);

  createState() => CampaignJoinRequestViewState();
}

class CampaignJoinRequestViewState extends State<CampaignJoinRequestView> {
  final String campaignID;
  CampaignJoinRequestViewState({Key key, this.campaignID});

  String docID;
  void initState() {
    super.initState();

    docID = globals.currentCampaignCreator +
        '*' +
        globals.currentCampaignCreatedTimeStamp.toString();
  }

  createState() => CampaignJoinRequestViewState();

  int indexItemNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Join Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('join_requests_campaign')
            .where('campaignid', isEqualTo: docID)
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
                                        userEmail: item['requestor_email'],
                                        reason: item['reason'],
                                        tbName: item['campaign_name'],
                                      ),
                                    ),
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
                              globals.currentCampaignMembersEmail
                                  .add(item['requestor_email']);
                              globals.currentCampaignMembersFullname
                                  .add(item['requestor_fullname']);
                              globals.currentCampaignMembersPhotoURL
                                  .add(item['requestor_photourl']);

                              Firestore.instance
                                  .collection('campaigns')
                                  .document(docID)
                                  .updateData({
                                'membersemail':
                                    globals.currentCampaignMembersEmail,
                                'membersfullname':
                                    globals.currentCampaignMembersFullname,
                                'membersphotourl':
                                    globals.currentCampaignMembersPhotoURL,
                              });

                              Firestore.instance
                                  .collection('users')
                                  .document(item['requestor_email'])
                                  .updateData({
                                'membership_campaigns': FieldValue.arrayUnion(
                                  [docID],
                                )
                              });

                              Firestore.instance
                                  .collection('join_requests_campaign')
                                  .document(
                                      docID + '*' + item['requestor_email'])
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
                                  .collection('join_requests_campaign')
                                  .document(
                                      docID + '*' + item['requestor_email'])
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
