import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/project_view/projects_template_view.dart';
import 'package:sevaexchange/views/project_view/recurring_event_list.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_widget.dart';

import '../requests/project_request.dart';

class TimeBankProjectsView extends StatefulWidget {
  final String? timebankId;
  final TimebankModel? timebankModel;

  TimeBankProjectsView({this.timebankId, this.timebankModel});

  @override
  _TimeBankProjectsViewState createState() => _TimeBankProjectsViewState();
}

class _TimeBankProjectsViewState extends State<TimeBankProjectsView> {
  bool isAdminOrOwner = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isAdminOrOwner = widget.timebankModel!.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID) ||
        widget.timebankModel!.organizers
            .contains(SevaCore.of(context).loggedInUser.sevaUserID);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 10),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    S.of(context).projects,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                infoButton(
                  context: context,
                  key: GlobalKey(),
                  type: InfoType.PROJECTS,
                  // text: infoDetails['projectsInfo'] ?? description,
                ),
                Visibility(
                  visible: isAdminOrOwner,
                  child: TransactionLimitCheck(
                    comingFrom: ComingFrom.Projects,
                    timebankId: widget!.timebankId!,
                    isSoftDeleteRequested:
                        widget.timebankModel!.requestedSoftDelete,
                    child: ConfigurationCheck(
                      actionType: 'create_events',
                      role: MemberType.CREATOR,
                      child: GestureDetector(
                        child: Container(
                          margin: EdgeInsets.only(left: 0),
                          child: Icon(
                            Icons.add_circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onTap: () {
                          navigateToCreateProject();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<ProjectModelList>(
              stream: FirestoreManager.getAllProjectListStream(
                  timebankid: widget.timebankId!,
                  isAdminOrOwner: isAdminOrOwner,
                  context: context),
              builder: (BuildContext context,
                  AsyncSnapshot<ProjectModelList> projectListSnapshot) {
                if (projectListSnapshot.hasError) {
                  log("===================== ===== > ${projectListSnapshot.error}");
                  return Text(S.of(context).general_stream_error);
                }
                switch (projectListSnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return LoadingIndicator();
                  default:
                    List<ProjectModel> projectModelList =
                        projectListSnapshot.data!.events!;
                    List<ProjectModel> completedProjectModelList =
                        projectListSnapshot.data!.completedEvents!;

                    if (projectModelList.length == 0 &&
                        completedProjectModelList.length == 0) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: EmptyWidget(
                            title: S.of(context).no_events_title,
                            sub_title: isAdminOrOwner
                                ? S.of(context).no_content_common_description
                                : S.of(context).cannot_create_project,
                            titleFontSize: 16,
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: projectModelList
                                .map((model) => getEventCard(model))
                                .toList(),
                          ),
                          completedProjectModelList.length != 0
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, top: 8),
                                  child: Text(
                                    S.of(context).completed_events,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          ...completedProjectModelList
                              .map((model) => getEventCard(model))
                        ],
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getEventCard(ProjectModel project) {
    int totalTask = project.completedRequests != null &&
            project.pendingRequests != null
        ? project.pendingRequests!.length + project.completedRequests!.length
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
      pendingTask: project.pendingRequests!.length,
      onTap: () {
        if (project.isRecurring!)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_context) => BlocProvider(
                bloc: BlocProvider.of<HomeDashBoardBloc>(context),
                child: RecurringEventsList(
                  timebankId: widget.timebankId,
                  timebankModel: widget.timebankModel,
                  parentEventId: project.parentEventId!,
                ),
              ),
            ),
          );
        else
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_context) => BlocProvider(
                bloc: BlocProvider.of<HomeDashBoardBloc>(context),
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
            CustomTextButton(
              child: Text(
                S.of(mContext!).ok,
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
