import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/utils/strings.dart';

class SearchTabBar extends StatelessWidget {
  const SearchTabBar({
    Key key,
    @required TabController tabController,
  })  : _tabController = tabController,
        super(key: key);

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
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
        ExplorePageLabels.tabContent.length,
        (index) => Tab(
          child: Text(
            ExplorePageLabels.tabContent[index],
          ),
        ),
      ),
    );
  }
}
