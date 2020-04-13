import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';
import '../core.dart';

class ViewRequestStatus extends StatefulWidget {
  final RequestModel requestModel;
  ViewRequestStatus({this.requestModel});
  ViewRequestStatusState createState() => ViewRequestStatusState();
}

class ViewRequestStatusState extends State<ViewRequestStatus>
    with SingleTickerProviderStateMixin {
  // static bool isAdminOrCoordinator = false;
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: Text(
          'Request Status',
          style: TextStyle(fontSize: 18),
        )),
        bottom: TabBar(
          indicatorColor: Colors.black,
          labelColor: Colors.white,
          tabs: [
            Tab(child: Text('Pending requests')),
            Tab(child: Text('Approved members')),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimebankRequests(requestModel: widget.requestModel),
          ApprovedMembers(
            requestModel: widget.requestModel,
          ),
        ],
      ),
    );
  }
}

class TimebankRequests extends StatefulWidget {
  final RequestModel requestModel;
  TimebankRequests({this.requestModel});

  @override
  State<StatefulWidget> createState() {
    return TimebankRequestsState();
  }
}

class TimebankRequestsState extends State<TimebankRequests> {
  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  @override
  Widget build(BuildContext context) {
    var futures = <Future>[];
    futures.clear();
    widget.requestModel.acceptors.forEach((memberEmail) {
      if (!widget.requestModel.approvedUsers.contains(memberEmail)) {
        futures.add(getUserDetails(memberEmail: memberEmail));
      } else {
        print("Member approved alredy");
      }
    });

    return FutureBuilder(
        future: Future.wait(futures),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No pending requests'),
            );
          }

          var snap = snapshot.data.map((f) {
            return UserModel.fromDynamic(f);
          }).toList();

          snap.sort((a, b) =>
              a.fullname.toLowerCase().compareTo(b.fullname.toLowerCase()));

          return ListView(
            children: <Widget>[
              ...snap.map((userModel) {
                // return Text(f['fullname']);

                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: notificationDecoration,
                  child: ListTile(
                    title: Text(userModel.fullname),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.photoURL),
                    ),
                    subtitle: Text(
                      'Pending approval',
                      style: TextStyle(color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {
                      showDialogForApprovalOfRequest(
                              context: context,
                              userModel: userModel,
                              requestModel: widget.requestModel,
                              notificationId: "sampleID")
                          .then((onValue) {
                        setState(() {});
                        print("Action completed");
                      });
                      //set the state
                    },
                  ),
                );
              }).toList()
            ],
          );
        });
  }

// crate dialog for approval or rejection
  Future showDialogForApprovalOfRequest({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
  }) {
    return showDialog(
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
                      userModel.fullname == null
                          ? "Anonymous"
                          : userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      userModel.email == null
                          ? "User email not updated"
                          : userModel.email,
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      userModel.bio == null
                          ? "Bio not yet updated"
                          : userModel.bio,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Center(
                    child: Text(
                        "By approving, ${userModel.fullname} will be added to the event.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            'Approve',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            // Once approved
                            approveMemberForVolunteerRequest(
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel);
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Decline',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            // request declined

                            declineRequestedMember(
                                model: requestModel,
                                notificationId: notificationId,
                                user: userModel);

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
  }) async {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;

    approveAcceptRequest(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: SevaCore.of(context).loggedInUser.currentCommunity,
    );
    if (model.projectId.isNotEmpty) {
      await FirestoreManager.updateProjectCompletedRequest(
          projectId: model.projectId, requestId: model.id);
    }
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

  Decoration get notificationDecoration => ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        shadows: shadowList,
      );

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  Widget get notificationShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }
}

Future<List<UserModel>> getRequestStatus({
  @required String requestId,
}) async {
  Firestore.instance.collection('requests').document(requestId).get().then(
    (requestDetails) async {
      var futures = <Future>[];
      RequestModel model = RequestModel.fromMap(
        requestDetails.data,
      );

      model.approvedUsers.forEach((membersId) {
        futures.add(
          Firestore.instance
              .collection("users")
              .document(membersId)
              .get()
              .then((onValue) {
            return onValue;
          }),
        );
      });

      return Future.wait(futures).then((onValue) {
        for (int i = 0; i < model.approvedUsers.length; i++) {
          var user = UserModel.fromDynamic(onValue[i]);
          usersRequested.add(user);
        }
        return usersRequested;
      });
    },
  );
}

Future<RequestModel> getRequestData({
  @required String requestId,
}) async {
  Firestore.instance.collection('requests').document(requestId).get().then(
    (requestDetails) async {
      var futures = <Future>[];
      RequestModel model = RequestModel.fromMap(
        requestDetails.data,
      );
      return model;
    },
  );
}

List<UserModel> usersRequested = List();

class ApprovedMembers extends StatelessWidget {
  final RequestModel requestModel;
  ApprovedMembers({this.requestModel});

  Future<dynamic> getUserDetails({String memberEmail}) async {
    var user = await Firestore.instance
        .collection("users")
        .document(memberEmail)
        .get();

    return user.data;
  }

  @override
  Widget build(BuildContext context) {
    var futures = <Future>[];
    futures.clear();
    requestModel.approvedUsers.forEach((memberEmail) {
      futures.add(getUserDetails(memberEmail: memberEmail));
    });

    return FutureBuilder(
        future: Future.wait(futures),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No approved members'),
            );
          }

          var snap = snapshot.data.map((f) {
            return UserModel.fromDynamic(f);
          }).toList();

          snap.sort((a, b) =>
              a.fullname.toLowerCase().compareTo(b.fullname.toLowerCase()));

          return ListView(
            children: <Widget>[
              ...snap.map((userModel) {
                // return Text(f['fullname']);

                return Container(
                  margin: EdgeInsets.all(2),
                  decoration: notificationDecoration,
                  child: ListTile(
                    title: Text(userModel.fullname),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userModel.photoURL),
                    ),
                    subtitle: Text(
                      'Approved Member',
                      style: TextStyle(color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () {},
                  ),
                );
              }).toList()
            ],
          );
        });
  }

// crate dialog for approval or rejection
  void showDialogForApprovalOfRequest({
    BuildContext context,
    UserModel userModel,
    RequestModel requestModel,
    String notificationId,
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
                      userModel.fullname == null
                          ? "Anonymous"
                          : userModel.fullname,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Text(
                      userModel.email == null
                          ? "User email not updated"
                          : userModel.email,
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      userModel.bio == null
                          ? "Bio not yet updated"
                          : userModel.bio,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Center(
                    child: Text(
                        "By approving, ${userModel.fullname} will be added to the event.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
//
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: FlavorConfig.values.theme.primaryColor,
                          child: Text(
                            'Approve',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            // Once approved
                            approveMemberForVolunteerRequest(
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                            );
                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                      ),
                      Container(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Decline',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Europa'),
                          ),
                          onPressed: () async {
                            // request declined

                            declineRequestedMember(
                              model: requestModel,
                              notificationId: notificationId,
                              user: userModel,
                              communityId: SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                            );

                            Navigator.pop(viewContext);
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  void declineRequestedMember({
    RequestModel model,
    UserModel user,
    String notificationId,
    @required String communityId,
  }) {
    List<String> acceptedUsers = model.acceptors;
    Set<String> usersSet = acceptedUsers.toSet();

    usersSet.remove(user.email);
    model.acceptors = usersSet.toList();

    rejectAcceptRequest(
      requestModel: model,
      rejectedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: communityId,
    );
  }

  void approveMemberForVolunteerRequest({
    RequestModel model,
    UserModel user,
    String notificationId,
    @required String communityId,
  }) {
    List<String> approvedUsers = model.approvedUsers;
    Set<String> usersSet = approvedUsers.toSet();

    usersSet.add(user.email);
    model.approvedUsers = usersSet.toList();

    if (model.numberOfApprovals <= model.approvedUsers.length)
      model.accepted = true;
    approveAcceptRequest(
      requestModel: model,
      approvedUserId: user.sevaUserID,
      notificationId: notificationId,
      communityId: communityId,
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

  Decoration get notificationDecoration => ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        shadows: shadowList,
      );

  List<BoxShadow> get shadowList => [shadow];

  BoxShadow get shadow {
    return BoxShadow(
      color: Colors.black.withAlpha(10),
      spreadRadius: 2,
      blurRadius: 3,
    );
  }

  Widget get notificationShimmer {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white.withAlpha(80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, color: Colors.white),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
            ),
          ),
        ),
        baseColor: Colors.black.withAlpha(50),
        highlightColor: Colors.white.withAlpha(50),
      ),
    );
  }
}

class CampaignRequests extends StatelessWidget {
  final BuildContext parentContext;
  CampaignRequests({this.parentContext});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Coming soon'),
    );
  }
}
