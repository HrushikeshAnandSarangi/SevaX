import 'dart:async';
import 'package:sevaexchange/models/community_model.dart';

import 'community_list_provider.dart';

class Repository {
  final communityApiProvider = CommunityApiProvider();

  Future searchCommunityByName(name, communities) => communityApiProvider.searchCommunityByName(name, communities);

//  Future<TrailerModel> fetchTrailers(int movieId) => moviesApiProvider.fetchTrailer(movieId);
}
