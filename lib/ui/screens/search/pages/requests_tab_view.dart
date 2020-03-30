import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/timebank/widgets/timebank_request_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

class RequestsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<RequestModel>>(
            stream: Searches.searchRequests(queryString: search.data),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final request = snapshot.data[index];
                  return TimebankRequestCard(
                    photoUrl: request.photoUrl,
                    title: request.title,
                    subtitle: request.description,
                    startTime: request.requestStart,
                    endTime: request.requestEnd,
                    isApplied: request.acceptors.contains(
                            SevaCore.of(context).loggedInUser.email) ||
                        request.approvedUsers
                            .contains(SevaCore.of(context).loggedInUser.email),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
