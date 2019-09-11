import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/base/base_service.dart';
import 'dart:convert';

import 'package:sevaexchange/models/models.dart';

class SearchService extends BaseService {
  static final String _baseUrl = 'http://api.sevaexchange.com:9200';

  /// make a get request using [url] and [headers]
  Future<http.Response> makeGetRequest({
    @required String url,
    Map<String, String> headers,
  }) async {
    log.i('makeGetRequest: URL: $url Headers: $headers');
    return await http.get(url, headers: headers);
  }

  /// Search for user for [queryString]
  Stream<List<UserModel>> searchForUser({
    @required queryString,
  }) async* {
    log.i('searchForUser: QueryString: $queryString');
    String url = '$_baseUrl/everything_profile/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<UserModel> userList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      UserModel user = UserModel.fromMap(sourceMap);
      userList.add(user);
    });
    yield userList;
  }

  /// Search for News for [queryString]
  Stream<List<NewsModel>> searchForNews({
    @required queryString,
  }) async* {
    log.i('searchForNews: QueryString: $queryString');
    String url = '$_baseUrl/everything_news/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<NewsModel> newsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      NewsModel news = NewsModel.fromMap(sourceMap);
      news.id = map['_id'];
      newsList.add(news);
    });
    yield newsList;
  }

  /// Search for Timebank for [queryString]
  Stream<List<TimebankModel>> searchForTimebank({
    @required queryString,
  }) async* {
    log.i('searchForTimebank: QueryString: $queryString');
    String url = '$_baseUrl/everything_timebanks/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<TimebankModel> timebankList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      TimebankModel model = TimebankModel.fromMap(sourceMap);
      model.id = map['_id'];
      timebankList.add(model);
    });
    yield timebankList;
  }

  /// Search for Campaign for [queryString]
  Stream<List<CampaignModel>> searchForCampaign({
    @required queryString,
  }) async* {
    log.i('searchForCampaign: QueryString: $queryString');
    String url = '$_baseUrl/everything_campaigns/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<CampaignModel> campaignList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      CampaignModel model = CampaignModel.fromMap(sourceMap);
      model.id = map['_id'];
      campaignList.add(model);
    });
    yield campaignList;
  }

  /// Search for offer for [queryString]
  Stream<List<OfferModel>> searchForOffer({
    @required queryString,
  }) async* {
    log.i('searchForOffer: QueryString: $queryString');
    String url = '$_baseUrl/everything_offers/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<OfferModel> offerList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      OfferModel model = OfferModel.fromMap(sourceMap);
      if (model.associatedRequest == null || model.associatedRequest.isEmpty)
        offerList.add(model);
    });
    yield offerList;
  }

  /// Search for Request for [queryString]
  Stream<List<RequestModel>> searchForRequest({
    @required String queryString,
  }) async* {
    log.i('searchForRequest: QueryString: $queryString');
    String url = '$_baseUrl/everything_requests/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<RequestModel> offerList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      RequestModel model = RequestModel.fromMap(sourceMap);
      if (model.accepted == false) offerList.add(model);
    });
    yield offerList;
  }

  /// make elastic search request using [url]
  Future<List<Map<String, dynamic>>> _makeElasticSearchRequest(
      String url) async {
    log.i('_makeElasticSearchRequest: URL: $url');
    http.Response response = await makeGetRequest(url: url);
    Map<String, dynamic> bodyMap = json.decode(response.body);
    Map<String, dynamic> hitMap = bodyMap['hits'];
    List<Map<String, dynamic>> hitList = List.castFrom(hitMap['hits']);
    return hitList;
  }
}
