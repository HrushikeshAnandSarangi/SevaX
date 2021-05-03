import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/request_repository.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/community_by_category_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_search_cards.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/members_avatar_list_with_count.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/filters.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class ExploreSearchPage extends StatefulWidget {
  final String searchText;
  final int tabIndex;

  const ExploreSearchPage({Key key, this.searchText, this.tabIndex = 0})
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
  StreamController _tabIndex = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _bloc.load();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ExploreSearchPageBloc>(
      create: (context) => _bloc,
      dispose: (context, bloc) => bloc.dispose(),
      child: ExplorePageViewHolder(
        appBarTitle: 'Search',
        hideSearchBar: true,
        hideHeader: Provider.of<UserModel>(context) != null,
        hideFooter: Provider.of<UserModel>(context) != null,
        controller: _searchController,
        onSearchChanged: (value) {
          logger.i(value);
          _bloc.onSearchChange(value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: _bloc.onSearchChange,
                decoration: InputDecoration(
                  hintText: 'Try "Oska" "Postal Code"',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: FlatButton(
                    child: Text('Search'),
                    textColor: Colors.white,
                    color: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {},
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tabBar,
                SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    var user = Provider.of<UserModel>(context);
                    return Row(
                      children: [
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => NearByFiltersView(
                                        Provider.of<UserModel>(context),
                                      ),
                                    ),
                                  )
                                  .then(
                                    (value) => setState(() {}),
                                  );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "here", // "Within ${user.nearBySettings.radius} ${user.nearBySettings.isMiles ? 'Miles' : 'Km'}",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        getDropDownButton(),
                      ],
                    );
                  },
                ),
                SizedBox(height: 12),
                StreamBuilder<int>(
                  initialData: 0,
                  stream: _tabIndex.stream,
                  builder: (context, snapshot) {
                    // return _EventsView();
                    switch (snapshot.data) {
                      case 0:
                        return _CommunitiesView();
                        break;
                      case 1:
                        return _EventsView();
                        break;
                      case 2:
                        return _RequestsView();
                        break;
                      case 3:
                        return _OffersView();
                        break;
                      default:
                        return _CommunitiesView();
                        break;
                    }
                  },
                ),
                SizedBox(height: 12),
                Text(
                  'Browse community by category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                // FindCommunitiesView(),
                // SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: StreamBuilder<List<CommunityCategoryModel>>(
                    stream: _bloc.communityCategory,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<CommunityCategoryModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return LayoutBuilder(
                        builder: (context, constraints) => GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 4 / 0.5,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) => SimpleCommunityCard(
                            image: snapshot.data[index].logo ??
                                'https://media.istockphoto.com/photos/group-portrait-of-a-creative-business-team-standing-outdoors-three-picture-id1146473249?k=6&m=1146473249&s=612x612&w=0&h=W1xeAt6XW3evkprjdS4mKWWtmCVjYJnmp-LHvQstitU=',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommunityByCategoryView(
                                    model: snapshot.data[index],
                                  ),
                                ),
                              );
                            },
                            title: snapshot.data[index].getCategoryName(
                              context,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
        "Career & Buisness",
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
              child: Text('Any Category'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunitiesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return StreamBuilder<List<CommunityModel>>(
      initialData: null,
      stream: _bloc.communities,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }

        if (snapshot.data.isEmpty) {
          return Text('No result found');
        }

        int length = snapshot.data.length;
        return Column(
          children: List.generate(
            length + 1,
            (index) {
              if (length ~/ 2 == index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Communities',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 360,
                        child: StreamBuilder<List<CommunityModel>>(
                            stream: _bloc.featuredCommunities,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return LoadingIndicator();
                              }
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  var community = snapshot.data[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExploreCommunityDetails(
                                              communityId: community.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 200,
                                            height: 320,
                                            child: Image.network(
                                              community.logo_url,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(height: 3),
                                          Text(community.name),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                );
              } else {
                return ExploreCommunityCard(
                  model: snapshot.data[index >= length ? length ~/ 2 : index],
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _RequestsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return StreamBuilder<List<RequestModel>>(
      stream: _bloc.requests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Text('No result found');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            var request = snapshot.data[index];
            var date =
                DateTime.fromMillisecondsSinceEpoch(request.requestStart);
            // return ExploreEventCard(
            //   photoUrl: request.photoUrl ?? defaultProjectImageURL,
            //   title: request.title,
            //   description: request.description,
            //   location: request.address,
            //   communityName: "request.communityName ?? ''",
            //   date: DateFormat('d MMMM, y').format(date),
            //   time: DateFormat.jm().format(date),
            //   memberList: MemberAvatarListWithCount(
            //     userIds: request.approvedUsers,
            //   ),
            // );
            return Provider.of<UserModel>(context, listen: false) != null
                ? FutureBuilder<TimebankModel>(
                    future: getTimeBankForId(timebankId: request.timebankId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator();
                      }
                      if (snapshot.hasError) {
                        return Container();
                      }
                      if (snapshot.data == null) {
                        return Container();
                      }
                      return ExploreEventCard(
                        onTap: () {
                          bool isAdmin = snapshot.data.admins.contains(
                              Provider.of<UserModel>(context).sevaUserID);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return RequestDetailsAboutPage(
                              isAdmin: isAdmin,
                              timebankModel: snapshot.data,
                              requestItem: request,
                            );
                          }));
                        },
                        photoUrl: request.photoUrl ?? defaultProjectImageURL,
                        title: request.title,
                        description: request.description,
                        location: request.address,
                        communityName: 'request.communityName ?? ' '',
                        date: DateFormat('d MMMM, y').format(date),
                        time: DateFormat.jm().format(date),
                        memberList: MemberAvatarListWithCount(
                          userIds: request.approvedUsers,
                        ),
                      );
                    })
                : ExploreEventCard(
                    onTap: () {
                      showSignInAlertMessage(
                          context: context,
                          message:
                              'Please Sign In/Sign up to access ${request.title}');
                    },
                    photoUrl: request.photoUrl ?? defaultProjectImageURL,
                    title: request.title,
                    description: request.description,
                    location: request.address,
                    communityName: 'request.communityName ?? ' '',
                    date: DateFormat('d MMMM, y').format(date),
                    time: DateFormat.jm().format(date),
                    memberList: MemberAvatarListWithCount(
                      userIds: request.approvedUsers,
                    ),
                  );
          },
        );
      },
    );
  }
}

class _OffersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return StreamBuilder<List<OfferModel>>(
      stream: _bloc.offers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Text('No result found');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            var offer = snapshot.data[index];
            var date = DateTime.fromMillisecondsSinceEpoch(offer.timestamp);
            return ExploreEventCard(
              onTap: () {
                if (Provider.of<UserModel>(context, listen: false) != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return OfferDetailsRouter(
                          offerModel: offer,
                          comingFrom: ComingFrom.Home,
                        );
                      },
                    ),
                  );
                } else {
                  showSignInAlertMessage(
                      context: context,
                      message:
                          'Please Sign In/Sign up to access ${offer.individualOfferDataModel != null ? offer.individualOfferDataModel.title : offer.groupOfferDataModel.classTitle}');
                }
              },
              photoUrl: /*offer.photoUrl ??*/ defaultProjectImageURL,
              title: getOfferTitle(offerDataModel: offer),
              description: getOfferDescription(offerDataModel: offer),
              location: offer.selectedAdrress,
              communityName: "offer.communityName ?? ''",
              date: DateFormat('d MMMM, y').format(date),
              time: DateFormat.jm().format(date),
            );
          },
        );
      },
    );
  }
}

class _EventsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);

    return StreamBuilder<List<ProjectModel>>(
      stream: _bloc.events,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Text('No result found');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            var event = snapshot.data[index];
            var date = DateTime.fromMillisecondsSinceEpoch(event.startTime);
            return ExploreEventCard(
              photoUrl: event.photoUrl ?? defaultProjectImageURL,
              title: event.name,
              description: event.description,
              location: event.address,
              communityName: "event.communityName ?? ''",
              date: DateFormat('d MMMM, y').format(date),
              time: DateFormat.jm().format(date),
              memberList: MemberAvatarListWithCount(
                userIds: event.associatedmembers.keys.toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class ExploreCommunityCard extends StatelessWidget {
  final CommunityModel model;
  const ExploreCommunityCard({
    Key key,
    @required this.model,
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
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 400,
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
                        model.logo_url,
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
                  Text(
                    ' New York | USA',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
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
