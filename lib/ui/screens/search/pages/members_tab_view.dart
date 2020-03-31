import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class MembersTabView extends StatefulWidget {
  @override
  _MembersTabViewState createState() => _MembersTabViewState();
}

class _MembersTabViewState extends State<MembersTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      color: Colors.green,
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
