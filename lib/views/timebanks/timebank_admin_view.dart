import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sevaexchange/views/core.dart';

import 'dart:ui';

class TimebankAdminPage extends StatefulWidget {
  final String timebankId;

  TimebankAdminPage({@required this.timebankId});

  @override
  _TimebankAdminPageState createState() => _TimebankAdminPageState();
}

class _TimebankAdminPageState extends State<TimebankAdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _TimeBankAdminView(
        timebankId: widget.timebankId,
      ),
    );
  }
}

class _TimeBankAdminView extends StatelessWidget {
  final String timebankId;

  _TimeBankAdminView({
    @required this.timebankId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TimebankModel>(
      stream: FirestoreManager.getTimebankModelStream(
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
        TimebankModel timebankModel = snapshot.data;
        return Container(
          child: getDataScrollView(
            context,
            timebankModel,
          ),
        );
      },
    );
  }

  Widget getDataScrollView(
    BuildContext context,
    TimebankModel timebankModel,
  ) {
    return CustomScrollView(
      slivers: <Widget>[
        getAppBar(context, timebankModel),
        SliverList(
          delegate: SliverChildListDelegate(
            getContent(context, timebankModel),
          ),
        ),
      ],
    );
  }

  Widget getAppBar(BuildContext context, TimebankModel timebankModel) {
    return SliverAppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      expandedHeight: 250,
      floating: false,
      snap: false,
      pinned: true,
      elevation: 0,
      actions: <Widget>[
        IconButton(
          tooltip: 'Add Members',
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          timebankModel.name,
          style: TextStyle(color: Colors.white),
        ),
        collapseMode: CollapseMode.pin,
        background: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  height: 130,
                  width: 130,
                  margin: EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                        blurRadius: 17,
                      )
                    ],
                    shape: CircleBorder(),
                  ),
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'lib/assets/images/noimagefound.png',
                      image: timebankModel.photoUrl,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getContent(BuildContext context, TimebankModel model) {
    return [
      getAdminList(context, model),
      getCoordinationList(context, model),
      getMembersList(context, model),
      SizedBox(height: 48),
    ];
  }

  Widget getAdminList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );

    if (model.admins.length == 0) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Admins'),
        ...model.admins.map((admin) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: admin),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        admins.remove(user.sevaUserID);
                        updateTimebank(model, admins: admins);
                      },
                    ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      icon: Icons.arrow_downward,
                      color: Colors.orange,
                      caption: 'Coordinator',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        coordinators.add(user.sevaUserID);
                        admins.remove(user.sevaUserID);
                        updateTimebank(
                          model,
                          coordinators: coordinators,
                          admins: admins,
                        );
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return getUserWidget(user, context);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget getCoordinationList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );
    if (model.coordinators == null || model.coordinators.isEmpty)
      return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Coordinators'),
        ...model.coordinators.map((coordinator) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: coordinator),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        coordinators.remove(user.sevaUserID);
                        updateTimebank(model, coordinators: coordinators);
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return getUserWidget(user, context);
            },
          );
        }).toList(),
      ],
    );
  }

  Widget getMembersList(BuildContext context, TimebankModel model) {
    bool isAdmin = model.admins.contains(
      SevaCore.of(context).loggedInUser.sevaUserID,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        getSectionTitle(context, 'Members'),
        ...model.members.map((member) {
          return FutureBuilder<UserModel>(
            future: FirestoreManager.getUserForId(sevaUserId: member),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.connectionState == ConnectionState.waiting) {
                return shimmerWidget;
              }
              UserModel user = snapshot.data;
              if (isAdmin) {
                return Slidable(
                  delegate: SlidableDrawerDelegate(),
                  actions: <Widget>[
                    if (!model.admins.contains(user.sevaUserID))
                      IconSlideAction(
                        icon: Icons.supervisor_account,
                        color: Colors.green,
                        caption: 'Admin',
                        onTap: () {
                          List<String> admins =
                              model.admins.map((s) => s).toList();
                          List<String> coordinators =
                              model.coordinators.map((s) => s).toList();
                          admins.add(user.sevaUserID);
                          coordinators.remove(user.sevaUserID);
                          updateTimebank(
                            model,
                            admins: admins,
                            coordinators: coordinators,
                          );
                        },
                      ),
                    if (!model.coordinators.contains(user.sevaUserID) &&
                        !model.admins.contains(user.sevaUserID))
                      IconSlideAction(
                        icon: Icons.supervised_user_circle,
                        color: Colors.orange,
                        caption: 'Coordinator',
                        onTap: () {
                          List<String> coordinators =
                              model.coordinators.map((s) => s).toList();
                          coordinators.add(user.sevaUserID);
                          updateTimebank(model, coordinators: coordinators);
                        },
                      ),
                  ],
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      icon: Icons.close,
                      color: Colors.red,
                      caption: 'Remove',
                      onTap: () {
                        List<String> admins =
                            model.admins.map((s) => s).toList();
                        List<String> coordinators =
                            model.coordinators.map((s) => s).toList();
                        List<String> members =
                            model.members.map((s) => s).toList();
                        admins.remove(user.sevaUserID);
                        coordinators.remove(user.sevaUserID);
                        members.remove(user.sevaUserID);
                        updateTimebank(
                          model,
                          members: members,
                          admins: admins,
                          coordinators: coordinators,
                        );
                      },
                    ),
                  ],
                  child: getUserWidget(user, context),
                );
              }
              return getUserWidget(user, context);
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileViewer(
                userEmail: user.email,
              ),
            ),
          );
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

  Widget getDataCard({
    @required String title,
  }) {
    return Container(
      child: Column(
        children: <Widget>[Text('')],
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

  Future updateTimebank(
    TimebankModel model, {
    List<String> admins,
    List<String> coordinators,
    List<String> members,
  }) async {
    if (admins != null) {
      model.admins = admins;
    }
    if (coordinators != null) {
      model.coordinators = coordinators;
    }
    if (members != null) {
      model.members = members;
    }
    await FirestoreManager.updateTimebank(timebankModel: model);
  }
}
