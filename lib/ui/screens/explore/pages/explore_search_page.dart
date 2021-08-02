import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/communities_search_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/events_search_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/pages/offers_search_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/requests_search_view.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/offer_filters.dart';
import 'package:sevaexchange/ui/screens/request/widgets/request_filters.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/filters.dart';
import 'package:sevaexchange/widgets/custom_back.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class ExploreSearchPage extends StatefulWidget {
  final String searchText;
  final int tabIndex;
  final bool isUserSignedIn;

  const ExploreSearchPage(
      {Key key,
      this.searchText,
      this.tabIndex = 0,
      @required this.isUserSignedIn})
      : assert(tabIndex <= 4),
        super(key: key);
  @override
  _ExploreSearchPageState createState() => _ExploreSearchPageState();
}

class _ExploreSearchPageState extends State<ExploreSearchPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  TextEditingController _searchController = TextEditingController();
  ExploreSearchPageBloc _bloc = ExploreSearchPageBloc();
  StreamController _tabIndex = StreamController<int>.broadcast();
  ScrollController _scrollController = ScrollController();
  final searchBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(40),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(milliseconds: 300),
        () => {
              _bloc.load(
                  widget.isUserSignedIn
                      ? SevaCore.of(context).loggedInUser.sevaUserID
                      : '',
                  context),
            });
    _tabIndex.add(widget.tabIndex);
    _searchController.text = widget.searchText;
    _bloc.onSearchChange(widget.searchText);
    _controller = TabController(
      initialIndex: widget.tabIndex,
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabIndex.close();
    _bloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ExploreSearchPageBloc>(
          create: (context) => _bloc,
          dispose: (context, bloc) => bloc.dispose(),
        ),
        InheritedProvider<ScrollController>(
          create: (c) => _scrollController,
          dispose: (_, __) => _scrollController.dispose(),
        ),
      ],
      child: ExplorePageViewHolder(
        scrollController: _scrollController,
        appBarTitle: S.of(context).search,
        hideSearchBar: true,
        hideHeader: widget.isUserSignedIn,
        hideFooter: widget.isUserSignedIn,
        controller: _searchController,
        onSearchChanged: (value) {
          logger.i(value);
          _bloc.onSearchChange(value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isUserSignedIn)
              CustomBackButton(
                onBackPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: _bloc.onSearchChange,
                decoration: InputDecoration(
                  hintText: S.of(context).explore_search_hint,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  enabledBorder: searchBorder,
                  focusedBorder: searchBorder,
                  disabledBorder: searchBorder,
                  errorBorder: searchBorder,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 5, 5, 5),
                    child: CustomTextButton(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        S.of(context).search,
                        style: TextStyle(
                          color: Colors.white,
                          // fontSize: 10,
                        ),
                      ),
                      textColor: Colors.white,
                      color: Colors.orange,
                      shape: StadiumBorder(),
                      // RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(20),
                      // ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            ExploreSearchTabBar(
              tabBar: _tabBar,
              bloc: _bloc,
              tabIndex: _tabIndex,
              initialTabIndex: widget.tabIndex,
              isUserSignedIn: widget.isUserSignedIn,
            ),
          ],
        ),
      ),
    );
  }

  List<String> get communityCategory => [
        "Outdoors & Adventure",
        "Tech",
        "Family",
        "Health & Wellness",
        "Sports & Fitness",
        "Learning",
        "Photography",
        "Food & Drink",
        "Writing",
        "Language & Culture",
        "Music",
        "Movements",
        "LGBTQ",
        "Film",
        "Sci-Fi & Games",
        "Beliefs",
        "Arts",
        "Book Clubs",
        "Dance",
        "Pets",
        "Hobbies & Crafts",
        "Fashion & Beauty",
        "Social",
        "Career & Business",
      ];

  List<String> get _tabsText => ["Communities", "Events", "Requests", "Offers"];

  List<Tab> get _tabs => _tabsText
      .map(
        (e) => Tab(text: e),
      )
      .toList();

  TabBar get _tabBar => TabBar(
        labelPadding: EdgeInsets.only(left: 0, right: 12),
        indicatorPadding: EdgeInsets.only(left: -4, right: 12),
        labelColor: Colors.black,
        isScrollable: true,
        controller: _controller,
        indicatorSize: TabBarIndicatorSize.label,
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        tabs: _tabs,
        indicatorColor: Theme.of(context).accentColor,
        indicatorWeight: 3,
        onTap: (index) {
          _tabIndex.add(index);
        },
      );

  Widget getDropDownButton() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          onChanged: (int value) {},
          value: 0,
          icon: Icon(Icons.keyboard_arrow_down),
          iconEnabledColor: Theme.of(context).primaryColor,
          style: TextStyle(color: Theme.of(context).primaryColor),
          items: <DropdownMenuItem<int>>[
            DropdownMenuItem(
              value: 0,
              child: Text(S.of(context).any_category.firstWordUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreCommunityCard extends StatelessWidget {
  final CommunityModel model;
  final bool isSignedUser;
  const ExploreCommunityCard({
    Key key,
    @required this.model,
    @required this.isSignedUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExploreCommunityDetails(
                communityId: model.id,
                isSignedUser: isSignedUser,
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 410,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        model.logo_url ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    model.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  HideWidget(
                    hide: (model.billing_address == null ||
                        model.billing_address.city == null ||
                        model.billing_address.country == null),
                    child: Text(
                      model.billing_address.city +
                          ' | ' +
                          model.billing_address.country,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      model.about,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Spacer(),
                  MemberAvatarListWithCount(
                    userIds: model.members,
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleCommunityCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const SimpleCommunityCard({Key key, this.image, this.title, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  height: 40,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 8),
            Text(title ?? ''),
          ],
        ),
      ),
    );
  }
}

class ExploreSearchTabBar extends StatelessWidget {
  const ExploreSearchTabBar({
    Key key,
    @required TabBar tabBar,
    @required ExploreSearchPageBloc bloc,
    @required StreamController<int> tabIndex,
    @required int initialTabIndex,
    @required bool isUserSignedIn,
  })  : _tabBar = tabBar,
        _bloc = bloc,
        _tabIndex = tabIndex,
        _initialTabIndex = initialTabIndex,
        _isUserSignedIn = isUserSignedIn,
        super(key: key);

  final TabBar _tabBar;
  final ExploreSearchPageBloc _bloc;
  final StreamController _tabIndex;
  final int _initialTabIndex;
  final bool _isUserSignedIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabBar,
        SizedBox(height: 12),
        StreamBuilder<int>(
          initialData: _initialTabIndex,
          stream: _tabIndex.stream,
          builder: (context, snapshot) {
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Container(
                  height: 30,
                  width: 135,
                  child: StreamBuilder<int>(
                    initialData: 0,
                    stream: _bloc.distance,
                    builder: (context, snapshot) {
                      return Container(
                        decoration: BoxDecoration(
                          color: snapshot.data != 0
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context)
                                .push<int>(
                              MaterialPageRoute(
                                builder: (context) => NearByFiltersView(),
                              ),
                            )
                                .then(
                              (value) {
                                if (value != null) {
                                  _bloc.distanceChanged(value);
                                } else {
                                  _bloc.distanceChanged(0);
                                }
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                snapshot.data == 0
                                    ? L.of(context).any_distance
                                    : 'Within ${snapshot.data} ' +
                                        S.of(context).miles,
                                style: TextStyle(
                                  color: snapshot.data == 0
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                ),
                              ),
                              Spacer(),
                              HideWidget(
                                hide: snapshot.data == 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      _bloc.distanceChanged(0);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                StreamBuilder<SelectedCommunityCategoryWithData>(
                  stream: CombineLatestStream.combine2(
                    _bloc.communityCategory,
                    _bloc.selectedCommunityCategoryId,
                    (a, b) => SelectedCommunityCategoryWithData(a, b),
                  ),
                  builder: (context, selectedCommunityCategoryWithData) {
                    if (selectedCommunityCategoryWithData.data == null ||
                        snapshot.data != 0) {
                      return Container();
                    }
                    return Container(
                      height: 30,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          onChanged: (String value) {
                            _bloc.onCommunityCategoryChanged(value);
                          },
                          value: selectedCommunityCategoryWithData
                                  .data.selectedId ??
                              '_',
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconEnabledColor: Theme.of(context).primaryColor,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: '_',
                              child: Text(
                                S.of(context).any_category.firstWordUpperCase(),
                              ),
                            ),
                            ...selectedCommunityCategoryWithData.data.data.map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(
                                  e.getCategoryName(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                StreamBuilder<SelectedRequestCategoryWithData>(
                  stream: CombineLatestStream.combine2(
                    _bloc.requestCategory,
                    _bloc.selectedRequestCategoryId,
                    (a, b) => SelectedRequestCategoryWithData(a, b),
                  ),
                  builder: (context, selectedRequestCategoryWithData) {
                    if (selectedRequestCategoryWithData.data == null ||
                        snapshot.data != 2) {
                      return Container();
                    }
                    return Container(
                      height: 30,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          onChanged: (String value) {
                            _bloc.onRequestCategoryChanged(value);
                          },
                          value:
                              selectedRequestCategoryWithData.data.selectedId ??
                                  '_',
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconEnabledColor: Theme.of(context).primaryColor,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: '_',
                              child: Text(S
                                  .of(context)
                                  .any_category
                                  .firstWordUpperCase()),
                            ),
                            ...selectedRequestCategoryWithData.data.data.map(
                              (e) => DropdownMenuItem(
                                value: e.typeId,
                                child: Text(
                                  e.getCategoryName(context).toString(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                HideWidget(
                  hide: snapshot.data != 2,
                  child: RequestFilters(
                    stream: _bloc.requestFilter,
                    onTap: _bloc.onRequestFilterChange,
                    hideFilters: [false, false, false, false, true, true],
                  ),
                ),
                HideWidget(
                  hide: snapshot.data != 3,
                  child: OfferFilters(
                    stream: _bloc.offerFilter,
                    onTap: _bloc.onOfferFilterChange,
                    hideFilters: [false, false, false, false, true, true],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 12),
        StreamBuilder<int>(
          initialData: _initialTabIndex,
          stream: _tabIndex.stream,
          builder: (context, snapshot) {
            logger.wtf("tabIndex", snapshot.data);
            switch (snapshot.data) {
              case 0:
                return CommunitiesSearchView(
                  isUserSignedIn: _isUserSignedIn,
                );
                break;
              case 1:
                return EventsSearchView(
                  isUserSignedIn: _isUserSignedIn,
                );
                break;
              case 2:
                return RequestsSearchView(
                  isUserSignedIn: _isUserSignedIn,
                );
                break;
              case 3:
                return OffersSearchView(
                  isUserSignedIn: _isUserSignedIn,
                );
                break;
              default:
                logger.wtf("default case");
                return CommunitiesSearchView(
                  isUserSignedIn: _isUserSignedIn,
                );
                break;
            }
          },
        ),
      ],
    );
  }
}
