import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/find_communities_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_page_view_holder.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/ui/screens/search/bloc/queries.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunityByCategoryView extends StatefulWidget {
  final CommunityCategoryModel model;
  final bool isFromNearby;
  final GeoPoint? geoPoint;
  final bool isUserSignedIn;

  const CommunityByCategoryView({
    Key? key,
    required this.model,
    this.isFromNearby = false,
    this.geoPoint,
    required this.isUserSignedIn,
  }) : super(key: key);
  @override
  _CommunityByCategoryViewState createState() =>
      _CommunityByCategoryViewState();
}

class _CommunityByCategoryViewState extends State<CommunityByCategoryView> {
  Future<List<CommunityModel>>? communities;
  FindCommunitiesBloc? _bloc;

  @override
  void initState() {
    _bloc = FindCommunitiesBloc();
    if (!widget.isFromNearby) {
      communities = ElasticSearchApi.getCommunitiesByCategory(widget.model.id);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExplorePageViewHolder(
      hideSearchBar: true,
      hideHeader: widget.isUserSignedIn,
      hideFooter: widget.isUserSignedIn,
      appBarTitle: widget.isFromNearby
          ? S.of(context).timebanks_near_you
          : widget.model.getCategoryName(context),
      child: widget.isFromNearby
          ? StreamBuilder(
              stream: widget.isUserSignedIn
                  ? _bloc!.nearyByCommunities
                  : Searches.getNearBYCommunities(geoPoint: widget.geoPoint),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 4),
                      child: LoadingIndicator(),
                    ),
                  );
                }
                if (snapshot.data == null || (snapshot.data as List).isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 4 - 20),
                      child: Text(S.of(context).no_search_result_found),
                    ),
                  );
                }

                return communitiesWidget(
                  snapshot.data as List<CommunityModel>,
                  widget.isUserSignedIn,
                );
              },
            )
          : FutureBuilder(
              future: communities,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 4),
                      child: LoadingIndicator(),
                    ),
                  );
                }
                if (snapshot.data == null || (snapshot.data as List).isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 4 - 20),
                      child: Text(S.of(context).no_search_result_found),
                    ),
                  );
                }

                return communitiesWidget(
                  snapshot.data as List<CommunityModel>,
                  widget.isUserSignedIn,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        BackButton(),
                        Text(
                          widget.model.getCategoryName(context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Widget communitiesWidget(
    List<CommunityModel> communityList, bool isUserSignedIn,
    {Widget? child}) {
  return Column(
    children: [
      child ?? Container(),
      ...List.generate(
        communityList.length,
        (index) {
          return ExploreCommunityCard(
            model: communityList[index],
            isSignedUser: isUserSignedIn, //to be updated
          );
        },
      ),
    ],
  );
}
