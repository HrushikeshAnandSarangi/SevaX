// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/communities/widgets/communities_categories.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunitiesSearchView extends StatelessWidget {
  final bool isUserSignedIn;

  const CommunitiesSearchView({Key? key, required this.isUserSignedIn})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var _bloc = Provider.of<ExploreSearchPageBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<CommunityModel>>(
          initialData: [],
          stream: _bloc.communities,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }

            if (snapshot.data!.isEmpty) {
              return Text(S.of(context).no_search_result_found);
            }

            int length = snapshot.data!.length;
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
                            S.of(context).featured_communities,
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
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    var community = snapshot.data![index];
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
                                                isSignedUser: isUserSignedIn,
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
                                                community.logo_url ?? '',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              community.name,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ExploreCommunityCard(
                      model:
                          snapshot.data![index >= length ? length ~/ 2 : index],
                      isSignedUser: isUserSignedIn,
                    );
                  }
                },
              ),
            );
          },
        ),
        SizedBox(height: 22),
        Text(
          S.of(context).browse_by_category,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        CommunitiesCategory(
          stream: _bloc.communityCategory,
          onTap: (value) {
            _bloc.onCommunityCategoryChanged(value.id);
            Provider.of<ScrollController>(context, listen: false)?.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }
}
