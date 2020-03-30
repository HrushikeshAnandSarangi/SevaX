import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class OffersTabView extends StatefulWidget {
  @override
  _OffersTabViewState createState() => _OffersTabViewState();
}

class _OffersTabViewState extends State<OffersTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      color: Colors.yellow,
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
