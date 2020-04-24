import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/project_view/create_edit_project.dart';

import '../requests/project_request.dart';

class TimeBankProjectsView extends StatefulWidget {
  final String timebankId;
  final TimebankModel timebankModel;

  TimeBankProjectsView({this.timebankId, this.timebankModel});

  @override
  _TimeBankProjectsViewState createState() => _TimeBankProjectsViewState();
}

class _TimeBankProjectsViewState extends State<TimeBankProjectsView> {
  String description =
      'Projects are logical collections under a Group. For example, the Technology Committee Group can have the following Projects: School web page, Equipment, Apps, etc.';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 10),
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                ButtonTheme(
                  minWidth: 110.0,
                  height: 50.0,
                  buttonColor: Color.fromRGBO(234, 135, 137, 1.0),
                  child: Stack(
                    children: [
                      FlatButton(
                        onPressed: () {},
                        child: Text(
                          'Projects',
                          style: (TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                      Positioned(
                        // will be positioned in the top right of the container
                        top: -8,
                        right: -10,
                        child: IconButton(
                          icon: Image.asset(
                            'lib/assets/images/info.png',
                            color: FlavorConfig.values.theme.primaryColor,
                            height: 16,
                            width: 16,
                          ),
                          tooltip: description,
                          onPressed: () {
                            showInfoOfConcept(
                                dialogTitle: description, mContext: context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                TransactionLimitCheck(
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: FlavorConfig.values.theme.primaryColor,
                      ),
                    ),
                    onTap: () {
                      navigateToCreateProject();
                    },
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.help_outline),
                  color: FlavorConfig.values.theme.primaryColor,
                  iconSize: 24,
                  onPressed: showProjectsWebPage,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProjectModel>>(
              stream: FirestoreManager.getAllProjectListStream(
                  timebankid: widget.timebankId),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ProjectModel>> projectListSnapshot) {
                if (projectListSnapshot.hasError) {
                  return new Text('Error: ${projectListSnapshot.error}');
                }
                switch (projectListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<ProjectModel> projectModelList =
                        projectListSnapshot.data;

                    if (projectModelList.length == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  text: 'No projects available.Try ',
                                ),
                                TextSpan(
                                    text: 'creating one',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = navigateToCreateProject),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: projectModelList.length,
                      itemBuilder: (BuildContext context, int index) {
                        ProjectModel project = projectModelList[index];
                        int totalTask = project.completedRequests != null &&
                                project.pendingRequests != null
                            ? project.pendingRequests.length +
                                project.completedRequests.length
                            : 0;
                        return ProjectsCard(
                          timestamp: project.createdAt,
                          startTime: project.startTime,
                          endTime: project.endTime,
                          title: project.name,
                          description: project.description,
                          photoUrl: project.photoUrl,
                          location: project.address,
                          tasks: totalTask,
                          pendingTask: project.pendingRequests?.length,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectRequests(
                                timebankId: widget.timebankId,
                                projectModel: project,
                                timebankModel: widget.timebankModel,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAdminAccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Projects Alert"),
          content: new Text("Only admin can create projects"),
          actions: <Widget>[
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

  void navigateToCreateProject() {
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
  }

  void showProjectsWebPage() {
    var dynamicLinks = json.decode(AppConfig.remoteConfig.getString('links'));
    navigateToWebView(
      aboutMode: AboutMode(
          title: "Projects Help", urlToHit: dynamicLinks['projectsInfoLink']),
      context: context,
    );
  }

  void navigateToWebView({
    BuildContext context,
    AboutMode aboutMode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SevaWebView(aboutMode),
      ),
    );
  }
}

void showInfoOfConcept({String dialogTitle, BuildContext mContext}) {
  showDialog(
      context: mContext,
      builder: (BuildContext viewContext) {
        return AlertDialog(
//            title: Text(
//              dialogTitle,
//              style: TextStyle(
//                fontSize: 16,
//              ),
//            ),
          content: Form(
            child: Container(
              height: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  dialogTitle,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Ok',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                return Navigator.of(viewContext).pop();
              },
            ),
          ],
        );
      });
}
