import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/constants/sevatitles.dart';

import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/explore_cards_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/find_communities_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_browse_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_events_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_featured_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_find_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_offers_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_requests_card.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';

import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

import '../../../../l10n/l10n.dart';
import '../../../../new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

List findCardsData = [
  {
    'imageUrl':
        'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
    'title': FindCards.COMMUNITIES.readable
  },
  {
    'imageUrl':
        'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
    'title': FindCards.EVENTS.readable
  },
  {
    'imageUrl':
        'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
    'title': FindCards.REQUESTS.readable
  },
  {
    'imageUrl':
        'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
    'title': FindCards.OFFERS.readable
  },
  {
    'imageUrl':
        'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
    'title': FindCards.PEOPLE.readable
  }
];

List<String> participantsImageList1 = [
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
];
List<String> participantsImageList2 = [
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
  "https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fuser%20circle%20avatar.png?alt=media&token=f5ccc2aa-1178-413a-b26f-f496caaac203",
];

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _searchController = TextEditingController();
  List<ProjectModel> eventsList = [];
  List<RequestModel> requestList = [];
  List<OfferModel> offerList = [];
  FindCommunitiesBloc _bloc;
  List<CommunityModel> communityList = [];
  List<CommunityModel> finalCommunityList = [];
  bool seeAllBool = false;
  int seeAllSliceVal = 4;
  int members = 4000;
  List<CategoryModel> categories = [];
  bool dataLoaded = false;
  bool isSignedUser = false;

  void initState() {
    super.initState();
    _bloc = FindCommunitiesBloc();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      isSignedUser = SevaCore.of(context).loggedInUser != null;
      if (isSignedUser) {
        gpsCheck().then((_) {
          _bloc.init(SevaCore.of(context).loggedInUser.nearBySettings);
          getCategories();
        });
      }
    });
  }

  Future<void> getCategories() async {
    await FirestoreManager.getAllCategories().then((value) {
      categories = value;
      dataLoaded = true;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: SevaCore.of(context).loggedInUser != null,
      hideFooter: SevaCore.of(context).loggedInUser != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //SizedBox(width: 30),
                    Text(
                      'Explore Opportunities',
                      style: TextStyle(
                        fontSize: screenWidth * 0.027,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(
                          245,
                          166,
                          35,
                          1,
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.025),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: screenWidth * 0.7,
                      child: Text(
                        'Find communities near you. Offer to volunteer. Request the help you need. Search for community events based on your interests and more!',
                        style: TextStyle(fontSize: screenWidth * 0.015),
                      ),
                    ),

                    SizedBox(height: 20),

                    Stack(
                      children: [
                        SearchBar(
                          controller: _searchController,
                          hintText: 'Try "Osaka" "Postal Code" "Location"',
                          onChanged: null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7, right: 10),
                            child: Container(
                              width: 120,
                              height: 32,
                              child: RaisedButton(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                color: Color.fromRGBO(245, 166, 35, 1),
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                onPressed: () {
                                  if (_searchController.text != null ||
                                      _searchController.text.isNotEmpty) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ExploreSearchPage(
                                          searchText: _searchController.text,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 120,
                      width: screenWidth * 1,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: findCardsData.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              ExploreFindCard(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore_find_card_image.JPG?alt=media&token=6a8fca32-df2a-4026-84d4-f5dcb7d36b70',
                                title: findCardsData[index]['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExploreSearchPage(
                                        tabIndex: index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        eventsList.length > 4
                            ? InkWell(
                                child: Row(
                                  children: [
                                    Text(
                                      'See all  ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 11)
                                  ],
                                ),
                                onTap: () {
                                  //navigate to see all projects/events
                                },
                              )
                            : Container(height: 0, width: 0),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 255,
                      child: StreamBuilder<List<ProjectModel>>(
                          stream: isSignedUser
                              ? FirestoreManager.getPublicProjects()
                              : Searches.getPublicProjects(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }
                            if (snapshot.data == null) {
                              return Center(
                                child: Text('No events available'),
                              );
                            }
                            eventsList = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: eventsList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                ProjectModel projectModel = eventsList[index];
                                String landMark = projectModel.address;

                                if (projectModel.address != null &&
                                    projectModel.address.contains(',')) {
                                  List<String> x =
                                      projectModel.address.split(',');
                                  landMark = x[x.length > 3
                                      ? x.length - 3
                                      : x.length - 1];
                                }
                                return Row(
                                  children: [
                                    ExploreEventsCard(
                                      imageUrl: projectModel.photoUrl ??
                                          defaultGroupImageURL,
                                      communityName:
                                          'projectModel.communityName',
                                      city: landMark ?? '',
                                      description: projectModel.name,
                                      participantsImageList:
                                          participantsImageList1,
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Requests',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        requestList.length > 4
                            ? InkWell(
                                child: Row(
                                  children: [
                                    Text(
                                      'See all  ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 11)
                                  ],
                                ),
                                onTap: () {
                                  //navigate to see all projects/events
                                },
                              )
                            : Container(height: 0, width: 0),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 320,
                      child: StreamBuilder<List<RequestModel>>(
                          stream: isSignedUser
                              ? FirestoreManager.getPublicRequests()
                              : Searches.getPublicRequests(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }
                            if (snapshot.data == null) {
                              return Center(
                                child: Text(S.of(context).no_requests),
                              );
                            }
                            requestList = snapshot.data;

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: 6,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                RequestModel model = requestList[index];
                                String landMark = model.address;

                                if (model.address != null &&
                                    model.address.contains(',')) {
                                  List<String> x = model.address.split(',');
                                  landMark = x[x.length > 3
                                      ? x.length - 3
                                      : x.length - 1];
                                }
                                return Row(
                                  children: [
                                    ExploreRequestsCard(
                                      imageUrl: model.photoUrl ??
                                          defaultGroupImageURL,
                                      communityName:
                                          "model.communityName ?? ''",
                                      city: landMark ?? '',
                                      description: model.title,
                                      participantsImageList:
                                          participantsImageList2,
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Featured Communities',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 300,
                      child: StreamBuilder<List<CommunityModel>>(
                          stream: Searches.getPublicCommunities(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }
                            if (snapshot.data == null) {
                              return Center(
                                child: Text(S.of(context).no_timebanks_found),
                              );
                            }
                            communityList = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: 6,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                CommunityModel community = communityList[index];
                                if (index > 5) {
                                  return null;
                                } else {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ExploreFeaturedCard(
                                        imageUrl: community.logo_url,
                                        communityName: community.name,
                                        onTap: () {},
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Offers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        offerList.length > 4
                            ? InkWell(
                                child: Row(
                                  children: [
                                    Text(
                                      'See all  ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios_rounded,
                                        size: 11)
                                  ],
                                ),
                                onTap: () {
                                  //navigate to see all projects/events
                                },
                              )
                            : Container(height: 0, width: 0),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 255,
                      child: StreamBuilder<List<OfferModel>>(
                          stream: isSignedUser
                              ? FirestoreManager.getPublicOffers()
                              : Searches.getPublicOffers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }
                            if (snapshot.data == null) {
                              return Center(
                                child: Text(S.of(context).no_timebanks_found),
                              );
                            }
                            offerList = snapshot.data;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                OfferModel offer = offerList[index];
                                String landMark = offer.selectedAdrress;

                                if (offer.selectedAdrress != null &&
                                    offer.selectedAdrress.contains(',')) {
                                  List<String> x =
                                      offer.selectedAdrress.split(',');
                                  landMark = x[x.length > 3
                                      ? x.length - 3
                                      : x.length - 1];
                                }
                                return Row(
                                  children: [
                                    ExploreOffersCard(
                                      imageUrl: defaultGroupImageURL,
                                      offerName: "offer.communityName ?? ''",
                                      city: landMark ?? '',
                                      description: offer.fullName,
                                      onTap: () {},
                                    ),
                                  ],
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seva Communites near you.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 7),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: StreamBuilder<bool>(
                        stream: _bloc.seeAllBool,
                        builder: (context, snapshotSeeAll) {
                          return StreamBuilder<String>(
                              stream: _bloc.searchKey,
                              builder: (context, searchKey) {
                                return StreamBuilder<List<CommunityModel>>(
                                  stream: searchKey.hasData &&
                                          searchKey.data != null &&
                                          searchKey.data.isNotEmpty
                                      ? SearchManager.searchCommunity(
                                          queryString: searchKey.data,
                                        )
                                      : _bloc.nearyByCommunities,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text(snapshot.error);
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingIndicator();
                                    }

                                    if (snapshot.data == null ||
                                        snapshot.data.length == 0) {
                                      return Text(
                                        !searchKey.hasData
                                            ? S.of(context).no_near_communities
                                            : S.of(context).no_timebanks_found,
                                      );
                                    }
//                                        if(snapshotSeeAll.hasData){
                                    bool seeAllBoolStreamVal =
                                        snapshotSeeAll.data;
//                                        } else {
//                                            seeAllBoolStreamVal = false;
//                                        }
                                    communityList = snapshot.data;
                                    if (searchKey.hasData) {
                                      if (searchKey.data.isEmpty ||
                                          searchKey.data == null) {
                                        finalCommunityList = seeAllBoolStreamVal
                                            ? communityList
                                            : communityList.sublist(
                                                0,
                                                seeAllSliceVal >
                                                        communityList.length
                                                    ? communityList.length
                                                    : seeAllSliceVal);
                                      } else {
                                        finalCommunityList = communityList;
                                      }
                                    } else {
                                      finalCommunityList = communityList;
                                    }
                                    return GridView.count(
                                      shrinkWrap: true,
                                      crossAxisCount: 2,
                                      childAspectRatio: 3 / 1,
                                      crossAxisSpacing: 0.1,
                                      mainAxisSpacing: 0.2,
                                      children: List.generate(
                                        finalCommunityList.length,
                                        (index) {
                                          var status = _bloc.compareUserStatus(
                                            snapshot.data[index],
                                            SevaCore.of(context)
                                                .loggedInUser
                                                .sevaUserID,
                                          );
                                          return CommunityCard(
                                            memberIds: snapshot.data[index]
                                                        .members.length >
                                                    20
                                                ? snapshot.data[index].members
                                                    .sublist(0, 20)
                                                : snapshot.data[index].members
                                                    .sublist(
                                                        0,
                                                        snapshot.data[index]
                                                            .members.length),
                                            imageUrl:
                                                snapshot.data[index].logo_url,
                                            name: snapshot.data[index].name,
                                            memberCount: snapshot
                                                .data[index].members.length
                                                .toString(),
                                            buttonLabel: status ==
                                                    CompareUserStatus.JOINED
                                                ? S.of(context).joined
                                                : S.of(context).join,
                                            buttonColor: status ==
                                                    CompareUserStatus.JOINED
                                                ? HexColor("#D2D2D2")
                                                : Theme.of(context).accentColor,
                                            textColor: status ==
                                                    CompareUserStatus.JOINED
                                                ? Colors.white
                                                : Colors.black87,
                                            onbuttonPress: status ==
                                                    CompareUserStatus.JOINED
                                                ? null
                                                : () {
                                                    // Navigator.of(context).push()
                                                    // ExtendedNavigator
                                                    //         .ofRouter<
                                                    //             inRoutePrefix
                                                    //                 .Router>()
                                                    //     .pushSevaCommunityDetailsViewWeb(
                                                    //   communityModel: snapshot
                                                    //       .data[index],
                                                    //   userModel: BlocProvider
                                                    //           .of<AuthBloc>(
                                                    //               context)
                                                    //       .user,
                                                    // );
                                                  },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Browse requests by category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(height: 10),
                    dataLoaded
                        ? Container(
                            child: GridView(
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 0.5,
                                childAspectRatio: 6,
                              ),
                              children: List.generate(
                                categories.length,
                                (index) => ExploreBrowseCard(
                                  imageUrl:
                                      'https://firebasestorage.googleapis.com/v0/b/sevax-dev-project-for-sevax.appspot.com/o/explore_cards_test_images%2Fexplore%20browse%20card%20image.JPG?alt=media&token=48eda7bf-0089-40f4-8b04-0efcb3a881bd',
                                  title: categories[index].title_en,
                                  onTap: () {},
                                ),
                              ),
                            ),
                          )
                        : LoadingIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> gpsCheck() async {
    logger.i("check gps");

    try {
      Location templocation = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        logger.i("requesting location");

        if (!_serviceEnabled) {
          return;
        } else {
          setState(() {});
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        logger.i("requesting location");
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        } else {
          setState(() {});
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        logger.e(e);
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        logger.e(e);
      }
    }
  }
}

class SearchBar extends StatelessWidget {
  SearchBar({Key key, this.hintText, this.onChanged, this.controller})
      : super(key: key);

  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final border = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey[400], width: 0.5),
    borderRadius: BorderRadius.circular(30),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      shadowColor: Colors.grey[200],
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search),
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
