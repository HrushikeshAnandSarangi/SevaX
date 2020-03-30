import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
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
      color: Colors.grey,
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, snapshot) {
          return Center(
            child: Text(snapshot.data ?? ""),
          );
        },
      ),
    );
  }
}
