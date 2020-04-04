import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/project_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';


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
        builder: (context, search) {
          if (search.data == null || search.data == "") {
            return Center(child: Text("Search Something"));
          }
          return StreamBuilder<List<ProjectModel>>(
            stream: Searches.searchProjects(
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

              return Center(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {

                    return ProjectsCard(
                      timestamp: snapshot.data[index].createdAt,
                      startTime: snapshot.data[index].startTime,
                      endTime: snapshot.data[index].endTime,
                      title: "asdasdsasds",
                      description:snapshot.data[index].description,
                      photoUrl: snapshot.data[index].photoUrl,
//                      location: snapshot.data[index].lcoation,
                      tasks: 10,
                      pendingTask: 7,
//                  onTap: ,
                    );
                  },
                ),
              );
            }
          );
        },
      ),
    );
  }
}
