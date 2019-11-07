import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/data_managers/join_request_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart';
import 'package:shimmer/shimmer.dart';

import '../../flavor_config.dart';

class JoinRequestView extends StatefulWidget {
  final String timebankId;
  JoinRequestView({this.timebankId});
  JoinRequestViewState createState() => JoinRequestViewState();
}

class JoinRequestViewState extends State<JoinRequestView>
    with SingleTickerProviderStateMixin {
  static bool isAdminOrCoordinator = false;
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Join Requests',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              'Swipe right to add and swipe left to cancel ',
              style: TextStyle(color: Colors.white, fontSize: 8),
            )
          ],
        )),
        bottom: TabBar(
          labelColor: Colors.white,
          tabs: [
            Tab(child: Text('${FlavorConfig.values.timebankTitle}s')),
            Tab(child: Text('Projects')),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TimebankRequests(
            parentContext: context,
            timebankId: widget.timebankId,
          ),
          CampaignRequests(
            parentContext: context,
          ),
        ],
      ),
    );
  }
}

class TimebankRequests extends StatelessWidget {
  final BuildContext parentContext;
  final String timebankId;
  TimebankRequests({this.parentContext, this.timebankId});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<Object>(
        stream: getTimebankJoinRequest(timebankID: timebankId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          List<JoinRequestModel> joinrequestModelList = snapshot.data;
          if (joinrequestModelList.length == 0) {
            return Center(child: Text('No Pending Tasks'));
          }
          return ListView.builder(
              itemCount: joinrequestModelList.length,
              itemBuilder: (listContext, index) {
                JoinRequestModel model = joinrequestModelList[index];
                return FutureBuilder<Object>(
                    future: getTimeBankForId(timebankId: model.entityId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return new Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      TimebankModel timebankModel = snapshot.data;
                      return Slidable(
                        delegate: SlidableBehindDelegate(),
                        actions: <Widget>[
                          SlideAction(
                            closeOnTap: true,
                            onTap: () async {
                              List<String> members = timebankModel.members;
                              Set<String> usersSet = members.toSet();

                              usersSet.add(model.userId);
                              timebankModel.members = usersSet.toList();
                              model.accepted = true;
                              await createJoinRequest(model: model);
                              await updateTimebank(
                                  timebankModel: timebankModel);
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                color: Colors.green,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        secondaryActions: <Widget>[
                          SlideAction(
                            closeOnTap: true,
                            onTap: () async {
                              model.accepted = false;
                              await createJoinRequest(model: model);
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                shape: CircleBorder(),
                                color: Colors.red,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        child: FutureBuilder<Object>(
                            future: getUserForId(sevaUserId: model.userId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return new Text('Error: ${snapshot.error}');
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(child: notificationShimmer);
                              }
                              UserModel userModel = snapshot.data;

                              return Container(
                                margin: EdgeInsets.all(2),
                                decoration: notificationDecoration,
                                child: ListTile(
                                  title: Text(userModel.fullname),
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userModel.photoURL),
                                  ),
                                  subtitle: Text(
                                    'Reason: ${model.reason}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext viewContext) {
                                          return AlertDialog(
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
                                                      backgroundImage:
                                                      NetworkImage(userModel.photoURL),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(userModel.fullname),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(userModel.bio),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                ),
                              );
                            }),
                      );
                    });
              });
        });
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
    // TODO: implement build
    return Center(
      child: Text('Coming soon'),
    );
  }
}
