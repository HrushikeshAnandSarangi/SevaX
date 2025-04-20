import "dart:developer";

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/search/bloc/search_bloc.dart';
import 'package:sevaexchange/ui/screens/search/pages/projects_tab_view.dart';
import 'package:sevaexchange/ui/screens/search/pages/requests_tab_view.dart';
import 'package:sevaexchange/ui/screens/search/widgets/search_field.dart';
import 'package:sevaexchange/ui/screens/search/widgets/search_tab_bar.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

import 'feeds_tab_view.dart';
import 'group_tab_view.dart';
import 'members_tab_view.dart';
import 'offers_tab_view.dart';
import 'projects_tab_view.dart';
//import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import 'requests_tab_view.dart';

class SearchPage extends StatefulWidget {
  final HomeDashBoardBloc? bloc;
  final TimebankModel? timebank;
  final CommunityModel? community;

  final UserModel? user;

  const SearchPage({
    Key? key,
    this.bloc,
    this.timebank,
    this.community,
    this.user,
  }) : super(key: key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  SearchBloc? _bloc;
  TextEditingController _controller = TextEditingController();
  TabController? _tabController;
  String? selectedCommunity;

  @override
  void initState() {
    _bloc = SearchBloc(
      user: widget.user,
      timebank: widget.timebank,
      community: widget.community,
    );

    _tabController = TabController(
      length: 6,
      initialIndex: 0,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _bloc!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("${_bloc!.community}");
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            widget.community!.name,
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SearchField(bloc: _bloc!, controller: _controller),
            ),
            SizedBox(height: 10),
            Divider(
              indent: 20,
              endIndent: 20,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SearchTabBar(tabController: _tabController!),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  FeedsTabView(
                    communityModel: widget.community,
                  ),
                  RequestsTabView(
                    communityModel: widget.community!,
                  ),
                  OffersTabView(),
                  ProjectsTabView(),
                  GroupTabView(),
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
