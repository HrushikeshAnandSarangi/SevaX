import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/project_view/create_edit_project.dart';

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
                    ),
                    onTap: () {
                      navigateToCreateProject();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ProjectModel>>(
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
    if (widget.timebankModel.admins
        .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
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
  }
}
