import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:sevaexchange/views/project_view/create_edit_project.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../core.dart';
import '../requests/project_request.dart';

class TimeBankProjectsView extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  TimeBankProjectsView({this.timebankId, this.timebankModel});

  @override
  _TimeBankProjectsViewState createState() => _TimeBankProjectsViewState();
}

class _TimeBankProjectsViewState extends State<TimeBankProjectsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
            // width: double.,
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                Text(
                  'Projects',
                  style: (TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                TransactionLimitCheck(
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: FlavorConfig.values.theme.primaryColor,
                      ),
//                      child: CircleAvatar(
//                        backgroundColor: FlavorConfig.values.theme.primaryColor,
//                        radius: 10,
//                        child: Image.asset("lib/assets/images/add.png"),
//                      ),
                    ),
                    onTap: () {
                      if (widget.timebankModel.admins.contains(
                          SevaCore.of(context).loggedInUser.sevaUserID)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateEditProject(
                              timebankId: widget.timebankId,
                              isCreateProject: true,
                              projectId: '',
                            ),
                          ),
                        );
                        return;
                      } else {
                        _showAdminAccessMessage();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<ProjectModel>>(
            stream: FirestoreManager.getAllProjectListStream(
                timebankid: widget.timebankId),
            builder: (BuildContext context,
                AsyncSnapshot<List<ProjectModel>> requestListSnapshot) {
              if (requestListSnapshot.hasError) {
                return new Text('Error: ${requestListSnapshot.error}');
              }
              switch (requestListSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  List<ProjectModel> projectModelList =
                      requestListSnapshot.data;
                  print('projects data ${requestListSnapshot.data}');
                  print('projects list ${projectModelList[0].toString()}');

//              if (projectModelList.length == 0) {
//                return Padding(
//                  padding: const EdgeInsets.all(16.0),
//                  child: Center(child: Text('No Projects')),
//                );
//              }
                  return requestCards(projectModelList);
                //  return formatListFrom(consolidatedList: projectModelList);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAdminAccessMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Projects"),
          content: new Text("Only admin can create projects"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget getSpacerItem(Widget item) {
    return Row(
      children: <Widget>[
        item,
        Spacer(),
      ],
    );
  }

  Widget requestCards(List<ProjectModel> projectlist) {
    var count = 100;
    return Expanded(
      child: SizedBox(
        height: 200.0,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: projectlist.length,
            itemBuilder: (_context, index) {
              return getListTile(projectlist[index]);
            }),
      ),
    );
  }

  BoxDecoration get containerDecorationR {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withAlpha(2),
            spreadRadius: 6,
            offset: Offset(0, 3),
            blurRadius: 6)
      ],
      color: Colors.white,
    );
  }

  Widget getListTile(ProjectModel projectModel) {
    int count = projectModel.pendingRequests.length +
        projectModel.completedRequests.length;

    return Container(
      decoration: containerDecorationR,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: Card(
        color: Colors.white,
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectRequests(
                  timebankId: widget.timebankId,

                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(
                              Icons.place,
                              color: Theme.of(context).primaryColor,
                            ),
                            label: Container(
                              width: MediaQuery.of(context).size.width - 170,
                              child: Text(
                                projectModel.address,
                                style: TextStyle(
                                  fontFamily: 'Europa',
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        timeAgo
                            .format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  projectModel.createdAt),
                            )
                            .replaceAll('hours ago', 'h'),
                        style: TextStyle(
                          fontFamily: 'Europa',
                          color: Colors.black38,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        height: 60,
                        width: 60,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            projectModel.photoUrl ??
                                'https://icon-library.net/images/user-icon-image/user-icon-image-21.jpg',
                          ),
                          minRadius: 40.0,
                        ),
                      ),
                      Container(
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              getSpacerItem(
                                Text(
                                  projectModel.name ?? "",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Europa'),
                                ),
                              ),
                              getSpacerItem(
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                        getTimeFormattedString(
                                          projectModel.startTime,
                                        ),
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'Europa')),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.remove,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      getTimeFormattedString(
                                        projectModel.endTime,
                                      ),
                                      style: TextStyle(
                                          fontFamily: 'Europa',
                                          color: Colors.grey,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              getSpacerItem(
                                Flexible(
                                  flex: 10,
                                  child: Text(
                                    projectModel.description ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Europa',
                                      fontSize: 17,
                                    ),
//                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              getSpacerItem(
                                Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            '${count.toString() ?? ""} Tasks',
                                            style: TextStyle(
                                              color: FlavorConfig
                                                  .values.theme.primaryColor,
                                              fontSize: 12,
                                              fontFamily: 'Europa',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '${projectModel.pendingRequests.length ?? '0'} Pending',
                                        style: TextStyle(
                                          fontFamily: 'Europa',
                                          color: Colors.black38,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
