import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ProjectsTabView extends StatefulWidget {
  @override
  _ProjectsTabViewState createState() => _ProjectsTabViewState();
}

class _ProjectsTabViewState extends State<ProjectsTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc!.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text(S.of(context).search_something));
          }
          return StreamBuilder<List<ProjectModel>>(
            stream: Searches.searchProjects(
              queryString: search.data!,
              loggedInUser: _bloc.user!,
              currentCommunityOfUser: _bloc.community!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(S.of(context).no_search_result_found),
                );
              }

              return Center(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    ProjectModel project = snapshot.data![index];
                    int totalTask = project.completedRequests != null &&
                            project.pendingRequests != null
                        ? project.pendingRequests!.length +
                            project.completedRequests!.length
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
                      onTap: () =>
                          onTap(timebank: _bloc.timebank!, project: project),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void onTap({TimebankModel? timebank, ProjectModel? project}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_context) => BlocProvider(
          bloc: BlocProvider.of<HomeDashBoardBloc>(context),
          child: ProjectRequests(
            ComingFrom.Projects,
            timebankId: timebank!.id,
            projectModel: project!,
            timebankModel: timebank,
          ),
        ),
      ),
    ).then((value) {
      setState(() {});
    });
  }
}
