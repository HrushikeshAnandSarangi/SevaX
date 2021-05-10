import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ExploreSearchPageBloc {
  final _communityCategory = BehaviorSubject<List<CommunityCategoryModel>>();
  final _searchText = BehaviorSubject<String>();
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _featuredCommunities = BehaviorSubject<List<CommunityModel>>();
  final _events = BehaviorSubject<List<ProjectModel>>();
  final _requests = BehaviorSubject<List<RequestModel>>();

  final _offers = BehaviorSubject<List<OfferModel>>();
  final _debouncer = Debouncer(milliseconds: 800);

  Stream<String> get searchText => _searchText.stream;
  Stream<List<CommunityCategoryModel>> get communityCategory =>
      _communityCategory.stream;
  Stream<List<CommunityModel>> get communities => _communities.stream;
  Stream<List<ProjectModel>> get events => _events.stream;
  Stream<List<RequestModel>> get requests => _requests.stream;
  Stream<List<OfferModel>> get offers => _offers.stream;
  Stream<List<CommunityModel>> get featuredCommunities =>
      _featuredCommunities.stream;

  void onSearchChange(String value) {
    if (value != null || value != "") {
      _debouncer.run(() {
        _searchText.sink.add(value);
      });
    }
  }

  void load() {
    logger.i("explorePage init");
    CommunityRepository.getCommunityCategories().then((value) {
      _communityCategory.add(value);
    });

    CommunityRepository.getFeatureCommunitiesFuture().then((value) {
      if (value != null) {
        _featuredCommunities.add(value);
      }
    });
    _searchText.listen((searchText) {
      logger.i("search tapped");
      if (searchText == null || searchText.isEmpty) {
        ElasticSearchApi.getPublicCommunities().then((value) {
          _communities.add(value);
        });
        ElasticSearchApi.getPublicOffers().then((value) {
          _offers.add(value);
        });
        ElasticSearchApi.getPublicProjects().then((value) {
          _events.add(value);
        });
        ElasticSearchApi.getPublicRequests().then((value) {
          _requests.add(value);
        });
      } else {
        ElasticSearchApi.searchPublicRequests(queryString: searchText).then(
          (data) => _requests.add(data),
        );
        ElasticSearchApi.searchPublicEvents(queryString: searchText).then(
          (data) => _events.add(data),
        );
        ElasticSearchApi.searchPublicOffers(queryString: searchText).then(
          (data) => _offers.add(data),
        );
        ElasticSearchApi.searchCommunity(queryString: searchText).then(
          (data) => _communities.add(data),
        );
      }
    });
  }

  void dispose() {
    _searchText.close();
    _communities.close();
    _featuredCommunities.close();
    _events.close();
    _requests.close();
    _communityCategory.close();
    _offers.close();
  }
}
