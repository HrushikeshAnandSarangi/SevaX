import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/explore/bloc/explore_search_page_bloc.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_community_details.dart';
import 'package:sevaexchange/ui/screens/explore/pages/explore_search_page.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class CommunitiesSearchView extends StatelessWidget {
  final bool isUserSignedIn;

  const CommunitiesSearchView({Key key, this.isUserSignedIn}) : super(key: key);
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
