import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

class ReportedUsersPage extends StatefulWidget {
  final String timebankId;

  ReportedUsersPage({@required this.timebankId});

  @override
  _ReportedUsersPageState createState() => _ReportedUsersPageState();
}

class _ReportedUsersPageState extends State<ReportedUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reported Users',style: TextStyle(color: Colors.white),),),
      body: _ReportedUsersView(
        timebankId: widget.timebankId,
      ),
    );
  }
}

class _ReportedUsersView extends StatelessWidget {
  final String timebankId;

  _ReportedUsersView({
    @required this.timebankId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReportModel>>(
      stream: getReportedUsersStream(
        timebankId: timebankId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<ReportModel> reportedList = snapshot.data;
        return Container(
          child: getDataScrollView(
            context,
            reportedList,
          ),
        );
      },
    );
  }

  Widget getDataScrollView(
      BuildContext context,
      List<ReportModel> reportedList,
      ) {
    return CustomScrollView(
      slivers: <Widget>[
        //getAppBar(context, reportedList),
        SliverList(
          delegate: SliverChildListDelegate(
            getContent(context, reportedList),
          ),
        ),
      ],
    );
  }

  List<Widget> getContent(BuildContext context, List<ReportModel> model) {
    return [
      getAdminList(context, model),
//      getCoordinationList(context, model),
//      getMembersList(context, model),
      SizedBox(height: 48),
    ];
  }

  Widget getAdminList(BuildContext context, List<ReportModel> model) {
    bool isAdmin = model.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );

    if (model.length == 0) 
      return Center(
        child: Container(
          padding: EdgeInsets.only(top: 10.0),
          child: Text('No Users Found!'),
        ),
      );
    print(model);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...model.map((reportedUser) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: reportedUser.reportedId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (!isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<ReportModel> requests =
                        model.map((s) => s).toList();
                        Firestore.instance
                            .collection('timebanknew').document(this.timebankId)
                            .updateData({'members':FieldValue.arrayRemove([user.sevaUserID])});
                      Firestore.instance.collection('reported_users_list').getDocuments().then((snapshot) {
                        for (DocumentSnapshot doc in snapshot.documents) {
                          if (doc.data['reportedId'] == user.sevaUserID) {
                            requests.remove(user.sevaUserID);
                            doc.reference.delete();
                            print('Removed Reported user');
                            break;
                          }
                        }
                      });
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      icon: Icons.arrow_downward,
                      color: Colors.orange,
                      caption: 'Ignore',
                      onTap: () {
                        List<ReportModel> requests =
                        model.map((s) => s).toList();
                        Firestore.instance.collection('reported_users_list').getDocuments().then((snapshot) {
                          for (DocumentSnapshot doc in snapshot.documents) {
                            if (doc.data['reportedId'] == user.sevaUserID) {
                              requests.remove(user.sevaUserID);
                              doc.reference.delete();
                              print('Removed Reported user');
                              break;
                            }
                          }
                        });
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return Offstage();
            },
          );
        }).toList(),
      ],
    );
  }


  Widget getUserWidget(UserModel user, BuildContext context) {
    if (user == null) return Offstage();
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoURL),
        ),
        title: Text(user.fullname),
        subtitle: Text(user.email),
        onTap: () {
        },
      ),
    );
  }

  Widget getSectionTitle(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle,
      ),
    );
  }

  Widget get shimmerWidget {
    return Shimmer.fromColors(
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey.withAlpha(40),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
            title: Container(
              color: Colors.grey.withAlpha(90),
              height: 10,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey.withAlpha(90),
            ),
            subtitle: Container(
              color: Colors.grey.withAlpha(90),
              height: 8,
            )),
      ),
      baseColor: Colors.grey,
      highlightColor: Colors.white,
    );
  }

//  Future updateTimebank(
//      TimebankModel model, {
//        List<String> admins,
//        List<String> coordinators,
//        List<String> members,
//      }) async {
//    if (admins != null) {
//      model.admins = admins;
//    }
//    if (coordinators != null) {
//      model.coordinators = coordinators;
//    }
//    if (members != null) {
//      model.members = members;
//    }
//    await FirestoreManager.updateTimebank(timebankModel: model);
//  }
}