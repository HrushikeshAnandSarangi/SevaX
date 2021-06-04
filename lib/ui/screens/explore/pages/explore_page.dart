import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/explore_cards_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/find_communities_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/community_by_category_view.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/ui/screens/explore/pages/requests_by_category_view.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/community_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_events_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_featured_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_find_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_offers_card.dart';
import 'package:sevaexchange/ui/screens/explore/widgets/explore_requests_card.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_dashboard_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/offer_details_router.dart';
import 'package:sevaexchange/ui/screens/request/widgets/request_categories.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/onboarding/findcommunitiesview.dart';
import 'package:sevaexchange/views/requests/project_request.dart';
import 'package:sevaexchange/views/requests/request_tab_holder.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebank_modules/request_details_about_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import '../../../../labels.dart';

import '../../../../l10n/l10n.dart';
import '../../../../new_baseline/models/community_model.dart';

class ExplorePage extends StatefulWidget {
  final bool isUserSignedIn;

  const ExplorePage({Key key, @required this.isUserSignedIn}) : super(key: key);
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
  ExplorePageBloc _exploreBloc = ExplorePageBloc();
  FindCommunitiesBloc _bloc;

  bool seeAllBool = false;
  int seeAllSliceVal = 4;
  int members = 4000;
  List<CategoryModel> categories = [];
  bool dataLoaded = false;

  GeoPoint geoPoint = GeoPoint(12.87428, 77.6688899);
  void initState() {
    super.initState();
    _bloc = FindCommunitiesBloc();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _exploreBloc.load(isUserLoggedIn: widget.isUserSignedIn);
      // if (isSignedUser) {
      gpsCheck().then((_) {
        _bloc.init(
            Provider.of<UserModel>(context, listen: false)?.nearBySettings);
        getCategories();
      });
      // }
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
    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: widget.isUserSignedIn,
      hideFooter: widget.isUserSignedIn,
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
                    Text(
                      S.of(context).explore_page_title_text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(245, 166, 35, 1),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.025),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: screenWidth * 0.7,
                      child: Text(
                        S.of(context).explore_page_subtitle_text,
                        style: TextStyle(fontSize: 14),
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
                                  S.of(context).search,
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
                                          isUserSignedIn: widget.isUserSignedIn,
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
                                        isUserSignedIn: widget.isUserSignedIn,
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
                    StreamBuilder<List<ProjectModel>>(
                        stream: _exploreBloc.events,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return LoadingIndicator();
                          }
                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              snapshot.data.isEmpty) {
                            return Container();
                          }
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).projects,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SeeAllButton(
                                    hideButton: snapshot.data.length < 6,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ExploreSearchPage(
                                            tabIndex: 1,
                                            isUserSignedIn:
                                                widget.isUserSignedIn,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.centerLeft,
                                height: 255,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    ProjectModel projectModel =
                                        snapshot.data[index];
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
                                        widget.isUserSignedIn
                                            ? FutureBuilder<TimebankModel>(
                                                future: getTimeBankForId(
                                                    timebankId: projectModel
                                                        .timebankId),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return LoadingIndicator();
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Container();
                                                  }
                                                  if (snapshot.data == null) {
                                                    return Container();
                                                  }
                                                  return ExploreEventsCard(
                                                    participantsImageList:
                                                        participantsImageList1,
                                                    imageUrl: projectModel
                                                            .photoUrl ??
                                                        defaultGroupImageURL,
                                                    communityName: projectModel
                                                            .communityName ??
                                                        '',
                                                    city: landMark ?? '',
                                                    description:
                                                        projectModel.name,
                                                    onTap: () {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return ProjectRequests(
                                                          ComingFrom.Projects,
                                                          timebankId:
                                                              projectModel
                                                                  .timebankId,
                                                          projectModel:
                                                              projectModel,
                                                          timebankModel:
                                                              snapshot.data,
                                                        );
                                                      }));
                                                    },
                                                  );
                                                })
                                            : ExploreEventsCard(
                                                participantsImageList:
                                                    participantsImageList1,
                                                imageUrl:
                                                    projectModel.photoUrl ??
                                                        defaultGroupImageURL,
                                                communityName: projectModel
                                                        .communityName ??
                                                    '',
                                                city: landMark ?? '',
                                                description: projectModel.name,
                                                onTap: () {
                                                  showSignInAlertMessage(
                                                      context: context,
                                                      message:
                                                           S.of(context).sign_in_alert);
                                                },
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                StreamBuilder<List<RequestModel>>(
                    stream: _exploreBloc.requests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator();
                      }
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data.isEmpty) {
                        return Container();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).requests,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // requestList.length > 4
                              SeeAllButton(
                                hideButton: snapshot.data.length < 6,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExploreSearchPage(
                                        tabIndex: 2,
                                        isUserSignedIn: widget.isUserSignedIn,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 320,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length > 6
                                  ? 6
                                  : snapshot.data.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                RequestModel model = snapshot.data[index];
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
                                    widget.isUserSignedIn
                                        ? FutureBuilder<TimebankModel>(
                                            future: getTimeBankForId(
                                                timebankId: model.timebankId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return LoadingIndicator();
                                              }
                                              if (snapshot.hasError) {
                                                return Container();
                                              }
                                              if (snapshot.data == null) {
                                                return Container();
                                              }
                                              return ExploreRequestsCard(
                                                imageUrl: model.photoUrl ??
                                                    defaultGroupImageURL,
                                                communityName:
                                                    model.communityName ?? '',
                                                city: landMark ?? '',
                                                description: model.title,
                                                onTap: () {
                                                  bool isAdmin = snapshot
                                                      .data.admins
                                                      .contains(
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID);
                                                  if (model.sevaUserId ==
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID ||
                                                      isAccessAvailable(
                                                          snapshot.data,
                                                          SevaCore.of(context)
                                                              .loggedInUser
                                                              .sevaUserID)) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_context) =>
                                                            BlocProvider(
                                                          bloc: BlocProvider.of<
                                                                  HomeDashBoardBloc>(
                                                              context),
                                                          child:
                                                              RequestTabHolder(
                                                            communityModel: BlocProvider
                                                                    .of<HomeDashBoardBloc>(
                                                                        context)
                                                                .selectedCommunityModel,
                                                            isAdmin: true,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_context) =>
                                                            BlocProvider(
                                                          bloc: BlocProvider.of<
                                                                  HomeDashBoardBloc>(
                                                              context),
                                                          child:
                                                              RequestDetailsAboutPage(
                                                            requestItem: model,
                                                            timebankModel:
                                                                snapshot.data,
                                                            isAdmin: false,
                                                            //communityModel: BlocProvider.of<HomeDashBoardBloc>(context).selectedCommunityModel,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                participantsImageList:
                                                    participantsImageList2,
                                              );
                                            })
                                        : ExploreRequestsCard(
                                            participantsImageList:
                                                participantsImageList2,
                                            imageUrl: model.photoUrl ??
                                                defaultGroupImageURL,
                                            communityName:
                                                model.communityName ?? '',
                                            city: landMark ?? '',
                                            description: model.title,
                                            onTap: () {
                                              showSignInAlertMessage(
                                                  context: context,
                                                  message:
                                                       S.of(context).sign_in_alert);
                                            },
                                          ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Communities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 300,
                      child: StreamBuilder<List<CommunityModel>>(
                          stream: _exploreBloc.communities,
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
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length > 6
                                  ? 6
                                  : snapshot.data.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                CommunityModel community = snapshot.data[index];
                                return ExploreFeaturedCard(
                                  imageUrl: community.logo_url,
                                  communityName: community.name,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExploreCommunityDetails(
                                          communityId: community.id,
                                          isSignedUser: widget.isUserSignedIn,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.02),
                StreamBuilder<List<OfferModel>>(
                    stream: _exploreBloc.offers,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator();
                      }
                      if (snapshot.hasError ||
                          snapshot.data == null ||
                          snapshot.data.isEmpty) {
                        return Container();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).offers,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SeeAllButton(
                                hideButton: snapshot.data.length < 6,
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExploreSearchPage(
                                        tabIndex: 3,
                                        isUserSignedIn: widget.isUserSignedIn,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerLeft,
                            height: 255,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.length > 6
                                  ? 6
                                  : snapshot.data.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                OfferModel offer = snapshot.data[index];
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
                                    widget.isUserSignedIn
                                        ? FutureBuilder<TimebankModel>(
                                            future: getTimeBankForId(
                                                timebankId: offer.timebankId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return LoadingIndicator();
                                              }
                                              if (snapshot.hasError) {
                                                return Container();
                                              }
                                              if (snapshot.data == null) {
                                                return Container();
                                              }
                                              return ExploreOffersCard(
                                                imageUrl: defaultGroupImageURL,
                                                offerName: getOfferTitle(
                                                        offerDataModel:
                                                            offer) ??
                                                    '',
                                                city: landMark ?? '',
                                                description:
                                                    getOfferDescription(
                                                        offerDataModel: offer),
                                                onTap: () {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return OfferDetailsRouter(
                                                      offerModel: offer,
                                                      comingFrom:
                                                          ComingFrom.Home,
                                                      //TODO : fix the timebank model
                                                    );
                                                  }));
                                                },
                                              );
                                            })
                                        : ExploreOffersCard(
                                            imageUrl: defaultGroupImageURL,
                                            offerName: getOfferTitle(
                                                    offerDataModel: offer) ??
                                                '',
                                            city: landMark ?? '',
                                            description: getOfferDescription(
                                                offerDataModel: offer),
                                            onTap: () {
                                              showSignInAlertMessage(
                                                  context: context,
                                                  message:
                                                      S.of(context).sign_in_alert);
                                            },
                                          ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  alignment: Alignment.centerLeft,
                  child: StreamBuilder<List<CommunityModel>>(
                    stream: widget.isUserSignedIn
                        ? _bloc.nearyByCommunities
                        : Searches.getNearBYCommunities(geoPoint: geoPoint),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(snapshot.error);
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Seva Communities near you.',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  )),
                              SeeAllButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CommunityByCategoryView(
                                        isFromNearby: true,
                                        model: CommunityCategoryModel(),
                                        geoPoint: geoPoint,
                                        isUserSignedIn: widget.isUserSignedIn,
                                      ),
                                    ),
                                  );
                                },
                                hideButton: snapshot.data.length <= 4,
                              )
                            ],
                          ),
                          SizedBox(height: 7),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 1,
                            childAspectRatio: 3 / 1,
                            crossAxisSpacing: 0.1,
                            mainAxisSpacing: 0.2,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(
                              snapshot.data.length,
                              (index) {
                                var status = widget.isUserSignedIn
                                    ? _bloc.compareUserStatus(
                                        snapshot.data[index],
                                        Provider.of<UserModel>(context)
                                            ?.sevaUserID,
                                      )
                                    : CompareUserStatus.JOIN;
                                CommunityModel community = snapshot.data[index];
                                return CommunityCard(
                                  memberIds: community.members.length > 20
                                      ? community.members.sublist(0, 20)
                                      : community.members
                                          .sublist(0, community.members.length),
                                  imageUrl: community.logo_url,
                                  name: community.name,
                                  memberCount:
                                      community.members.length.toString(),
                                  buttonLabel:
                                      status == CompareUserStatus.JOINED
                                          ? S.of(context).joined
                                          : S.of(context).join,
                                  buttonColor:
                                      status == CompareUserStatus.JOINED
                                          ? HexColor("#D2D2D2")
                                          : Theme.of(context).accentColor,
                                  textColor: status == CompareUserStatus.JOINED
                                      ? Colors.white
                                      : Colors.black87,
                                  onbuttonPress:
                                      status == CompareUserStatus.JOINED
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExploreCommunityDetails(
                                                    communityId: community.id,
                                                    isSignedUser:
                                                        widget.isUserSignedIn,
                                                  ),
                                                ),
                                              );
                                            },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse requests by category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    RequestCategories(
                      stream: widget.isUserSignedIn
                          ? FirestoreManager.getAllCategoriesStream()
                          : _exploreBloc.categories,
                      onTap: (value) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RequestsByCategoryView(
                              model: value,
                            ),
                          ),
                        );
                      },
                    ),
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
      LocationData locationData;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        logger.i("requesting location");

        if (!_serviceEnabled) {
          return;
        } else {
          locationData = await templocation.getLocation();

          double lat = locationData?.latitude;
          double lng = locationData?.longitude;
          geoPoint = GeoPoint(lat, lng);
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
          locationData = await templocation.getLocation();

          double lat = locationData?.latitude;
          double lng = locationData?.longitude;
          geoPoint = GeoPoint(lat, lng);

          setState(() {});
        }
      } else {
        locationData = await templocation.getLocation();

        double lat = locationData?.latitude;
        double lng = locationData?.longitude;
        geoPoint = GeoPoint(lat, lng);
        setState(() {});
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

class SeeAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hideButton;
  const SeeAllButton({
    Key key,
    this.onPressed,
    this.hideButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HideWidget(
      hide: hideButton,
      child: InkWell(
        child: Row(
          children: [
            Text(
              S.of(context).see_all,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 11)
          ],
        ),
        onTap: onPressed,
      ),
    );
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
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
          hintStyle: TextStyle(
            fontSize: 12,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}
