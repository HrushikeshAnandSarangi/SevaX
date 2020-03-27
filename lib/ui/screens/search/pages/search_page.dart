import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/explore_bloc.dart';
import 'package:sevaexchange/ui/screens/search/pages/projects_tab_view.dart';
import 'package:sevaexchange/ui/screens/search/pages/requests_tab_view.dart';
import 'package:sevaexchange/ui/screens/search/widgets/explore_tab_bar.dart';
import 'package:sevaexchange/ui/screens/search/widgets/search_field.dart';
import 'package:sevaexchange/ui/utils/strings.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';

import 'feeds_tab_view.dart';
import 'group_tab_view.dart';
import 'members_tab_view.dart';
import 'offers_tab_view.dart';

class SearchPage extends StatefulWidget {
  final HomeDashBoardBloc bloc;

  const SearchPage({Key key, this.bloc}) : super(key: key);
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  SearchBloc _bloc = SearchBloc();
  TextEditingController _controller = TextEditingController();
  TabController _tabController;
  String selectedCommunity;

  @override
  void initState() {
    _bloc.searchAfterDelay();
    _tabController = TabController(
      length: ExplorePageLabels.tabContent.length,
      initialIndex: 0,
      vsync: this,
    );
    Future.delayed(Duration.zero, () {
      selectedCommunity = SevaCore.of(context).loggedInUser.currentCommunity;
    });
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: StreamBuilder<List<CommunityModel>>(
            stream: widget.bloc.communities,
            builder: (context, snapshot) {
              return snapshot.data != null
                  ? Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).primaryColor,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          style: TextStyle(color: Colors.white),
                          focusColor: Colors.white,
                          iconEnabledColor: Colors.white,
                          value: selectedCommunity,
                          onChanged: (v) {
                            selectedCommunity = v;
                            setState(() {});
                          },
                          items: List.generate(
                            snapshot.data.length,
                            (index) => DropdownMenuItem(
                              value: snapshot.data[index].id,
                              child: Text(
                                snapshot.data[index].name,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text('Loading');
            },
          ),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                SizedBox(width: 20),
                Expanded(
                  child: SearchField(bloc: _bloc, controller: _controller),
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 10),
            Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ExploreTabBar(tabController: _tabController),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  GroupTabView(),
                  ProjectsTabView(),
                  FeedsTabView(),
                  RequestsTabView(),
                  OffersTabView(),
                  MembersTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
