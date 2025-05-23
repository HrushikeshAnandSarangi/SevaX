import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/project_view/projects_template_view.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';

class RecurringEventsList extends StatefulWidget {
  final String? timebankId;
  final TimebankModel? timebankModel;
  final String parentEventId;

  RecurringEventsList({
    this.timebankId,
    this.timebankModel,
    required this.parentEventId,
  });

  @override
  EventListState createState() => EventListState();
}

class EventListState extends State<RecurringEventsList> {
  bool isAdminOrOwner = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // isAdminOrOwner = widget.timebankModel.admins
    //         .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
    //     widget.timebankModel.organizers
    //         .contains(SevaCore.of(context).loggedInUser.sevaUserID);
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<ProjectModel>>(
              stream: FirestoreManager.getRecurringEvents(
                parentEventId: widget.parentEventId,
              ),
              builder: (BuildContext context,
                  AsyncSnapshot<List<ProjectModel>> projectListSnapshot) {
                logger.d("===============|||");
                if (projectListSnapshot.hasError) {
                  return Text(S.of(context).general_stream_error +
                      " " +
                      projectListSnapshot.error.toString());
                }
                switch (projectListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return LoadingIndicator();
                  default:
                    List<ProjectModel> projectModelList =
                        projectListSnapshot.data!;

                    if (projectModelList.length == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: EmptyWidget(
                            title: S.of(context).no_events_title,
                            sub_title: isAdminOrOwner
                                ? S.of(context).no_content_common_description
                                : S.of(context).cannot_create_project,
                            titleFontSize: 16.0,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: projectModelList.length,
                      itemBuilder: (BuildContext context, int index) {
                        //   return Text('Lo');
                        ProjectModel project = projectModelList[index];
                        int totalTask = project.completedRequests != null &&
                                project.pendingRequests != null
                            ? project.pendingRequests!.length +
                                project.completedRequests!.length
                            : 0;

                        return ProjectsCard(
                          isRecurring: project.isRecurring!,
                          timestamp: project.createdAt!,
                          startTime: project.startTime!,
                          endTime: project.endTime!,
                          title: project.name!,
                          description: project.description!,
                          photoUrl: project.photoUrl!,
                          location: project.address!,
                          tasks: totalTask,
                          pendingTask: project.pendingRequests!.length!,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_context) => BlocProvider(
                                  bloc: BlocProvider.of<HomeDashBoardBloc>(
                                      context),
                                  child: ProjectRequests(
                                    ComingFrom.Projects,
                                    timebankId: widget.timebankId!,
                                    projectModel: project,
                                    timebankModel: widget.timebankModel!,
                                  ),
                                ),
                              ),
                            );
                          },
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
    if (widget.timebankModel!.id == FlavorConfig.values.timebankId &&
        !isAccessAvailable(widget.timebankModel!,
            SevaCore.of(context).loggedInUser.sevaUserID!)) {
      showAdminAccessMessage(context: context);
    } else {
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
  }

  void showProjectsWebPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
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
}

void showInfoOfConcept({String? dialogTitle, BuildContext? mContext}) {
  showDialog(
      context: mContext!,
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
                  dialogTitle!,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
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
