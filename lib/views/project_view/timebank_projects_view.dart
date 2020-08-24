import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/project_view/projects_template_view.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

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
  void initState() {
    super.initState();
  }

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
                          S.of(context).projects,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Positioned(
                        // will be positioned in the top right of the container
                        top: -8,
                        right: -10,
                        child: infoButton(
                          context: context,
                          key: GlobalKey(),
                          type: InfoType.PROJECTS,
                          // text: infoDetails['projectsInfo'] ?? description,
                        ),
                        // child: IconButton(
                        //   icon: Image.asset(
                        //     'lib/assets/images/info.png',
                        //     color: FlavorConfig.values.theme.primaryColor,
                        //     height: 16,
                        //     width: 16,
                        //   ),
                        //   tooltip: infoDetails['projectsInfo'] != null
                        //       ? infoDetails['projectsInfo'] ?? description
                        //       : description,
                        //   onPressed: () {
                        //     showInfoOfConcept(
                        //         dialogTitle:
                        //             infoDetails['projectsInfo'] != null
                        //                 ? infoDetails['projectsInfo'] ??
                        //                     description
                        //                 : description,
                        //         mContext: context);
                        //   },
                        // ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                TransactionLimitCheck(
                  isSoftDeleteRequested:
                      widget.timebankModel.requestedSoftDelete,
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(left: 0),
                      child: Icon(
                        Icons.add_circle,
                        color: FlavorConfig.values.theme.primaryColor,
                      ),
                    ),
                    onTap: () {
                      navigateToCreateProject();
                    },
                  ),
                ),
                Spacer(),
                Container(
                  height: 40,
                  width: 40,
                  child: IconButton(
                    icon: Image.asset(
                      'lib/assets/images/help.png',
                    ),
                    color: FlavorConfig.values.theme.primaryColor,
                    //iconSize: 16,
                    onPressed: showProjectsWebPage,
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
                  AsyncSnapshot<List<ProjectModel>> projectListSnapshot) {
                if (projectListSnapshot.hasError) {
                  return Text(S.of(context).general_stream_error);
                }
                switch (projectListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return LoadingIndicator();
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
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  text: '${S.of(context).no_projects_message} ',
                                ),
                                TextSpan(
                                  text: S.of(context).creating_one,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = navigateToCreateProject,
                                ),
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

  void navigateToCreateProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectTemplateView(
          timebankId: widget.timebankId,
          isCreateProject: true,
          projectId: '',
        ),
      ),
    );
  }

  void showProjectsWebPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig.getString(
        "links_${S.of(context).localeName}",
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).projects + ' ' + S.of(context).help,
          urlToHit: dynamicLinks['projectsInfoLink']),
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
                S.of(mContext).ok,
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
