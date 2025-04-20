import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/extensions.dart';

class SearchTabBar extends StatelessWidget {
  const SearchTabBar({
    Key? key,
    required TabController tabController,
  })  : _tabController = tabController,
        super(key: key);

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    List<String> searchLabels = [
      S.of(context).feeds,
      S.of(context).requests,
      S.of(context).offers,
      S.of(context).projects,
      S.of(context).groups.toLowerCase().firstWordUpperCase(),
      S.of(context).members,
    ];

    return TabBar(
      isScrollable: true,
      controller: _tabController,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.7,
      ),
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.black,
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        letterSpacing: 0.7,
      ),
      indicatorColor: Theme.of(context).primaryColor,
      labelPadding: EdgeInsets.symmetric(horizontal: 10),
      tabs: List.generate(
        searchLabels.length,
        (index) => Tab(
          child: Text(
            searchLabels[index],
          ),
        ),
      ),
    );
  }
}
