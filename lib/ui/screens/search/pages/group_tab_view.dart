import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/widgets/group_card.dart';
import 'package:sevaexchange/ui/utils/strings.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class GroupTabView extends StatefulWidget {
  @override
  _GroupTabViewState createState() => _GroupTabViewState();
}

class _GroupTabViewState extends State<GroupTabView> {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<SearchBloc>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: <Widget>[
            Text(
              ExplorePageLabels.groupInfo,
              style: TextStyle(fontSize: 16),
            ),
            StreamBuilder<String>(
              stream: _bloc.searchText,
              builder: (context, search) {
                if (search.data == null || search.data == "") {
                  return Center(child: Text("Search Something"));
                }
                return StreamBuilder<List<TimebankModel>>(
                  stream: Searches.searchGroups(
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Text("No data found !"),
                        ],
                      );
                    }

                    print("snapshot ==> ${snapshot.data.length}");

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        final group = snapshot.data[index];
                        return GroupCard(
                          image: group.photoUrl ?? "",
                          title: group.name,
                          subtitle: group.missionStatement,
                          onPressed: () {},
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          thickness: 2,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
