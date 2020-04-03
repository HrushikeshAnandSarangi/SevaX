import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/sevaavatar/timebankavatar.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/profile/review_earnings.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'create_edit_project.dart';

class AboutProjectView extends StatefulWidget {
  final String project_id;

  AboutProjectView({this.project_id});

  @override
  _AboutProjectViewState createState() => _AboutProjectViewState();
}

class _AboutProjectViewState extends State<AboutProjectView> {
  ProjectModel projectModel;
  String loggedintimezone = '';
  UserModel user;
  bool isDataLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    getData();
    setState(() {});
    super.initState();
  }

  void getData() async {
    await FirestoreManager.getProjectFutureById(projectId: widget.project_id)
        .then((onValue) {
      projectModel = onValue;
      print("projectttttt ${projectModel}");
      //  isDataLoaded = true;
      setState(() {
        getUserData();
      });
    });
  }

  void getUserData() async {
    user =
        await FirestoreManager.getUserForId(sevaUserId: projectModel.creatorId);
    print("userssssss ${user}");
    isDataLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isDataLoaded
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Column(
                              children: <Widget>[
                                TimebankAvatar(
                                    photoUrl: projectModel.photoUrl ??
                                        defaultCameraImageURL),
                                Text(''),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 30),
                            child: FlatButton(
                              onPressed: () {
                                print('pressed');

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateEditProject(
                                        timebankId: '',
                                        isCreateProject: false,
                                        projectId: projectModel.id,
                                      ),
                                    ));
                              },
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                    color:
                                        FlavorConfig.values.theme.primaryColor,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  headingText('Title'),
                  Text(projectModel.name ?? ""),
                  headingText('Mission Statement'),
                  SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                          getTimeFormattedString(
                            projectModel.startTime,
                          ),
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(projectModel.description ?? ""),
                  headingText('Organiser'),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(user.photoURL !=
                                      null
                                  ? user.photoURL ??
                                      'https://upload.wikimedia.org/wikipedia/commons/f/fc/No_picture_available.png'
                                  : defaultUserImageURL)),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(user.fullname ?? ""),
                      SizedBox(width: 30),
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
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 18),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: FlavorConfig.values.theme.primaryColor,
        ),
      ),
    );
  }
}
