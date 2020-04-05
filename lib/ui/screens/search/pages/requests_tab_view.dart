import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/timebank/widgets/timebank_request_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';

class RequestsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext mcontext) {
    final _bloc = BlocProvider.of<SearchBloc>(mcontext);
    return Container(
      child: StreamBuilder<String>(
        stream: _bloc.searchText,
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<RequestModel>>(
            stream: Searches.searchRequests(
              queryString: search.data,
              loggedInUser: _bloc.user,
              currentCommunityOfUser: _bloc.community,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == null || snapshot.data.isEmpty) {
                print("===>> ${snapshot.data}");
                return Center(
                  child: Text("No data found !"),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final request = snapshot.data[index];
                  return InkWell(
                    onTap: () => _navigateToRequest(
                      context: mcontext,
                      timebankModel: _bloc.timebank,
                      requestModel: request,
                    ),
                    child: TimebankRequestCard(
                      photoUrl: request.photoUrl,
                      title: request.title,
                      subtitle: request.description,
                      startTime: request.requestStart,
                      endTime: request.requestEnd,
                      isApplied: request.acceptors.contains(
                              SevaCore.of(context).loggedInUser.email) ||
                          request.approvedUsers.contains(
                              SevaCore.of(context).loggedInUser.email),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToRequest(
      {BuildContext context,
      RequestModel requestModel,
      TimebankModel timebankModel}) {
    print("navigating");
    if (requestModel.sevaUserId ==
            SevaCore.of(context).loggedInUser.sevaUserID ||
        timebankModel.admins
            .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestTabHolder(
            isAdmin: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RequestDetailsAboutPage(
            requestItem: requestModel,
            timebankModel: timebankModel,
            isAdmin: false,
            //  project_id: '',
          ),
        ),
      );
    }
  }
}
