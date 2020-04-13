import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:shimmer/shimmer.dart';

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
      appBar: AppBar(
        title: Text(
          'Reported Users',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
      //getCoordinationList(context, model),
      //getMembersList(context, model),
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
            future: FirestoreManager.getUserForId(
                sevaUserId: reportedUser.reportedId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (!isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  child: getUserWidget(user, context, model),
                );
              }
              return Offstage();
            },
          );
        }).toList(),
      ],
    );
  }

  Widget getUserWidget(
      UserModel user, BuildContext context, List<ReportModel> model) {
    if (user == null) return Offstage();
    return GestureDetector(
      onTap: () {
        print("------------------------Show dialog-----");
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoURL),
          ),
          title: Text(user.fullname),
          subtitle: Text(user.email),
          onTap: () {
            print("tapped list item");

            showDialogForRemovingMember(
              context: context,
              model: model,
              userModel: user,
            );
          },
        ),
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

// crate dialog for approval or rejection
  void showDialogForRemovingMember({
    BuildContext context,
    UserModel userModel,
    List<ReportModel> model,
  }) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Form(
              //key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _getCloseButton(viewContext),
                  Container(
                    height: 70,
                    width: 70,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.photoURL),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (userModel.bio != null)
                    Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Text(
                        "About ${userModel.fullname}",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  getBio(userModel),
//                  Padding(
//                    padding: EdgeInsets.all(8.0),
//                    child: Text(
//                      userModel.bio == null
//                          ? "Bio not yet updated"
//                          : userModel.bio,
//                      maxLines: 5,
//                      overflow: TextOverflow.ellipsis,
//                    ),
//                  ),
                  Center(
                    child: Text(
                        "By tapping on remove, ${userModel.fullname} will be removed from ${FlavorConfig.values.timebankName}",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: Theme.of(context).accentColor,
                        textColor: FlavorConfig.values.buttonTextColor,
                        child: Text(
                          'Remove',
                          style: TextStyle(fontFamily: 'Europa'),
                        ),
                        onPressed: () async {
                          removeMemberFromYangGang(
                            model: model,
                            user: userModel,
                          );
                          // Once approved
                          Navigator.pop(viewContext);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                      ),
                      RaisedButton(
                        child: Text(
                          'Ignore',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          // request declined
                          ignoreMember(model: model, user: userModel);
                          Navigator.pop(viewContext);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget getBio(UserModel userModel) {
    if (userModel.bio != null) {
      if (userModel.bio.length < 100) {
        return Center(
          child: Text(userModel.bio),
        );
      }
      return Container(
        height: 150,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(
            userModel.bio,
            maxLines: null,
            overflow: null,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Bio not yet updated"),
    );
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void removeMemberFromYangGang({
    List<ReportModel> model,
    UserModel user,
  }) {
    List<ReportModel> requests = model.map((s) => s).toList();
    Firestore.instance
        .collection('timebanknew')
        .document(this.timebankId)
        .updateData({
      'members': FieldValue.arrayRemove([user.sevaUserID])
    });
    Firestore.instance
        .collection('reported_users_list')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        if (doc.data['reportedId'] == user.sevaUserID) {
          requests.remove(user.sevaUserID);
          doc.reference.delete();
          print('Removed Reported user');
          break;
        }
      }
    });
  }

  void ignoreMember({
    UserModel user,
    List<ReportModel> model,
  }) {
    List<ReportModel> requests = model.map((s) => s).toList();
    Firestore.instance
        .collection('reported_users_list')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        if (doc.data['reportedId'] == user.sevaUserID) {
          requests.remove(user.sevaUserID);
          doc.reference.delete();
          print('Removed Reported user');
          break;
        }
      }
    });
  }
}
