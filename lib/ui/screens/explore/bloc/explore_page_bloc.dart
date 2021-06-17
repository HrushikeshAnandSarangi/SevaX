import 'package:flutter/material.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/repositories/elastic_search.dart';

class ExplorePageBloc {
  final _events = BehaviorSubject<List<ProjectModel>>();
  final _requests = BehaviorSubject<List<RequestModel>>();
  final _offers = BehaviorSubject<List<OfferModel>>();
  final _communities = BehaviorSubject<List<CommunityModel>>();
  final _categories = BehaviorSubject<List<CategoryModel>>();

  Stream<List<ProjectModel>> get events => _events.stream;
  Stream<List<RequestModel>> get requests => _requests.stream;
  Stream<List<OfferModel>> get offers => _offers.stream;
  Stream<List<CommunityModel>> get communities => _communities.stream;
  Stream<List<CategoryModel>> get categories => _categories.stream;

  Stream<bool> get isDataLoaded => CombineLatestStream.combine4(
        events,
        requests,
        offers,
        communities,
        (a, b, c, d) {
          return a && b && c && d;
        },
      );

  void load({bool isUserLoggedIn = false, String sevaUserID}) {
    ElasticSearchApi.getFeaturedCommunities().then((value) {
      _communities.add(value);
    });
    if (isUserLoggedIn) {
      FirestoreManager.getPublicOffers().listen((event) {
        _offers.add(event);
      });
      FirestoreManager.getPublicProjects(sevaUserID).listen((event) {
        _events.add(event);
      });
      FirestoreManager.getPublicRequests().listen((event) {
        _requests.add(event);
      });
    } else {
      ElasticSearchApi.getPublicOffers().then((value) {
        _offers.add(value);
      });
      ElasticSearchApi.getPublicProjects(
        distanceFilterData: null,
        sevaUserID: sevaUserID,
      ).then((value) {
        _events.add(value);
      });
      ElasticSearchApi.getPublicRequests().then((value) {
        _requests.add(value);
      });
      ElasticSearchApi.getAllCategories().then((value) {
        _categories.add(value);
      });
    }
  }

  void dispose() {
    _events.close();
    _requests.close();
    _offers.close();
    _communities.close();
    _categories.close();
  }
}
