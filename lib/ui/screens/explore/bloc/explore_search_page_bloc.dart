import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/community_repository.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_list_bloc.dart';
import 'package:sevaexchange/ui/screens/request/bloc/request_bloc.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';

import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class ExploreSearchPageBloc {
  final _communityCategory = BehaviorSubject<List<CommunityCategoryModel>>();
  final _searchText = BehaviorSubject<String>();
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _featuredCommunities = BehaviorSubject<List<CommunityModel>>();
  final _events = BehaviorSubject<List<ProjectModel>>();
  final _requests = BehaviorSubject<List<RequestModel>>();
  final _offers = BehaviorSubject<List<OfferModel>>();
  final _selectedCommunityCategory = BehaviorSubject<String>.seeded('_');
  final _selectedRequestCategory = BehaviorSubject<String>.seeded('_');
  final _requestCategory = BehaviorSubject<List<CategoryModel>>();
  final _debouncer = Debouncer(milliseconds: 800);

  //filters
  final _distance = BehaviorSubject<int>.seeded(0);
  final _requestFilter = BehaviorSubject<RequestFilter>.seeded(RequestFilter());
  final _offerFilter = BehaviorSubject<OfferFilter>.seeded(OfferFilter());

  Stream<OfferFilter> get offerFilter => _offerFilter.stream;
  Stream<RequestFilter> get requestFilter => _requestFilter.stream;
  Stream<String> get searchText => _searchText.stream;
  Stream<List<CommunityCategoryModel>> get communityCategory =>
      _communityCategory.stream;
  Stream<List<CommunityModel>> get communities => _communities.stream;
  Stream<List<ProjectModel>> get events => _events.stream;
  Stream<List<RequestModel>> get requests => _requests.stream;
  Stream<List<OfferModel>> get offers => _offers.stream;
  Stream<List<CommunityModel>> get featuredCommunities =>
      _featuredCommunities.stream;
  Stream<int> get distance => _distance.stream;
  Stream<String> get selectedCommunityCategoryId =>
      _selectedCommunityCategory.stream;
  Stream<String> get selectedRequestCategoryId =>
      _selectedRequestCategory.stream;
  Stream<List<CategoryModel>> get requestCategory => _requestCategory.stream;
  Function(RequestFilter) get onRequestFilterChange => _requestFilter.sink.add;
  Function(OfferFilter) get onOfferFilterChange => _offerFilter.sink.add;
  Function(String) get onCommunityCategoryChanged =>
      _selectedCommunityCategory.sink.add;
  Function(String) get onRequestCategoryChanged =>
      _selectedRequestCategory.sink.add;
  Function(int) get distanceChanged => _distance.sink.add;

  void onSearchChange(String value) {
    if (value != null || value != "") {
      _debouncer.run(() {
        _searchText.sink.add(value);
      });
    }
  }

  Future<void> load() async {
    ElasticSearchApi.getAllCategories().then((value) {
      _requestCategory.add(value);
    });
    LocationData location;
    try {
      location = await LocationHelper.gpsCheck().timeout(Duration(seconds: 3));
    } catch (e) {
      logger.e("explore search bloc location timed out");
    }
    CommunityRepository.getCommunityCategories().then((value) {
      _communityCategory.add(value);
    });

    CommunityRepository.getFeatureCommunitiesFuture().then((value) {
      if (value != null) {
        _featuredCommunities.add(value);
      }
    });
    CombineLatestStream.combine2(
      _searchText,
      _distance,
      (a, b) => [a, b],
    ).listen((value) {
      String searchText = value[0];
      DistanceFilterData distanceFilterData = DistanceFilterData(
        location,
        value[1],
      );

      if (searchText == null || searchText.isEmpty) {
        _selectedCommunityCategory.listen((categoryId) {
          ElasticSearchApi.getPublicCommunities(
            distanceFilterData: distanceFilterData,
          ).then((value) {
            if (categoryId == null || categoryId == '_') {
              _communities.add(value);
            } else {
              var x = value
                  .where((element) =>
                      element.communityCategories.contains(categoryId))
                  .toList();

              _communities.add(x);
            }
          });
        });
        _offerFilter.listen((filter) {
          ElasticSearchApi.getPublicOffers(
            distanceFilterData: distanceFilterData,
          ).then(
            (value) {
              _offers.add(
                value.where((element) => filter.checkFilter(element)).toList(),
              );
            },
          );
        });

        ElasticSearchApi.getPublicProjects(
          distanceFilterData: distanceFilterData,
        ).then((value) {
          _events.add(value);
        });

        CombineLatestStream.combine2<RequestFilter, String,
            SelectedRequestFilter>(
          _requestFilter,
          _selectedRequestCategory,
          (a, b) => SelectedRequestFilter(a, b),
        ).listen(
          (data) {
            ElasticSearchApi.getPublicRequests(
              distanceFilterData: distanceFilterData,
            ).then(
              (value) {
                _requests.add(
                  value.where((element) {
                    bool cond1 = data.filter.checkFilter(element);
                    if (data.categoryId != null && data.categoryId != '_') {
                      logger.wtf("cond1 and 2 -> ${element.title}");
                      return cond1 &&
                          element.categories.contains(data.categoryId);
                    } else {
                      logger.wtf("cond1 -> ${element.title}");
                      return cond1;
                    }
                  }).toList(),
                );
              },
            );
          },
        );
      } else {
        CombineLatestStream.combine2<RequestFilter, String,
            SelectedRequestFilter>(
          _requestFilter,
          _selectedRequestCategory,
          (a, b) => SelectedRequestFilter(a, b),
        ).listen(
          (data) {
            ElasticSearchApi.searchPublicRequests(
              queryString: searchText,
              distanceFilterData: distanceFilterData,
            ).then(
              (value) {
                _requests.add(
                  value
                      .where(
                        (element) =>
                            data.filter.checkFilter(element) &&
                            (data.categoryId != null && data.categoryId != '_'
                                ? element.categories.contains(data.categoryId)
                                : true),
                      )
                      .toList(),
                );
              },
            );
          },
        );

        ElasticSearchApi.searchPublicEvents(
          queryString: searchText,
          distanceFilterData: distanceFilterData,
        ).then(
          (data) => _events.add(data),
        );
        _offerFilter.listen((filter) {
          ElasticSearchApi.searchPublicOffers(
            queryString: searchText,
            distanceFilterData: distanceFilterData,
          ).then(
            (value) {
              _offers.add(
                value.where((element) => filter.checkFilter(element)).toList(),
              );
            },
          );
        });
        _selectedCommunityCategory.listen(
          (categoryId) {
            ElasticSearchApi.searchCommunity(
              queryString: searchText,
              distanceFilterData: distanceFilterData,
            ).then((value) {
              if (categoryId == null || categoryId == '_') {
                _communities.add(value);
              } else {
                var x = value
                    .where((element) =>
                        element.communityCategories.contains(categoryId))
                    .toList();

                _communities.add(x);
              }
            });
          },
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
    _selectedCommunityCategory.close();
    _selectedRequestCategory.close();
  }
}

class SelectedCommunityCategoryWithData {
  final List<CommunityCategoryModel> data;
  final String selectedId;

  SelectedCommunityCategoryWithData(this.data, this.selectedId);
}

class SelectedRequestCategoryWithData {
  final List<CategoryModel> data;
  final String selectedId;

  SelectedRequestCategoryWithData(this.data, this.selectedId);
}

class SelectedRequestFilter {
  final RequestFilter filter;
  final String categoryId;

  SelectedRequestFilter(this.filter, this.categoryId);
}
