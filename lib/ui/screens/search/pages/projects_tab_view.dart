import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

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
        stream: _bloc.searchText,
        builder: (context, snapshot) {
          return Center(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: Colors.primaries.length,
              itemBuilder: (context, index) {
                return ProjectsCard(
                  timestamp: 120,
                  startTime: 120,
                  endTime: 120,
                  title: "Product Designer",
                  description:
                      "Treva student connects student parents and teacher..",
                  photoUrl: "",
                  tasks: 10,
                  pendingTask: 7,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
