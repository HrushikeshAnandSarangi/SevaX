import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/feeds_tab_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/group_tab_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/projects_tab_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/requests_tab_view.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_tab_bar.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/search_field.dart';
import 'package:sevaexchange/ui/utils/strings.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

import 'members_tab_view.dart';
import 'offers_tab_view.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  ExploreBloc _bloc = ExploreBloc();
  TextEditingController _controller = TextEditingController();
  TabController _tabController;

  @override
  void initState() {
    _bloc.searchAfterDelay();
    _tabController = TabController(
      length: ExplorePageLabels.tabContent.length,
      initialIndex: 0,
      vsync: this,
    );
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
        appBar: AppBar(),
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
              child: TabBarView(controller: _tabController, children: <Widget>[
                GroupTabView(),
                ProjectsTabView(),
                FeedsTabView(),
                RequestsTabView(),
                OffersTabView(),
                MembersTabView(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
