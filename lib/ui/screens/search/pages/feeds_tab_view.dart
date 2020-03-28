import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';

import 'package:sevaexchange/utils/bloc_provider.dart';

class FeedsTabView extends StatefulWidget {
  @override
  _FeedsTabViewState createState() => _FeedsTabViewState();
}

class _FeedsTabViewState extends State<FeedsTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      color: Colors.pink,
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
