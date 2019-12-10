import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:sevaexchange/models/models.dart';

class SearchManager {
  static final String _baseUrl = 'http://api.sevaexchange.com:9200';
  // static final String _baseUrl = 'https://b23ca2bd485f4bc18fe0ae03f9da283e.us-west1.gcp.cloud.es.io:9243';

  static Future<http.Response> makeGetRequest({
    @required String url,
    Map<String, String> headers,
  }) async {
    return await http.get(url, headers: headers);
  }
  static Future<http.Response> makePostRequest({
    @required String url,
    Map<String, String> headers,
    dynamic body,
  }) async {
    return await http.post(url, body: body, headers: headers);
  }

  static Stream<List<UserModel>> searchForUser({
    @required queryString,
  }) async* {
    String url = 'http://35.243.165.111//elasticsearch/users/user/_search';
    dynamic body = json.encode({
      "query": {
        "multi_match": {
          "query": queryString,
          "type": "phrase_prefix",
          "fields": ["email", "fullname"]
        }
      }
    });
    List<Map<String, dynamic>> hitList = await _makeElasticSearchPostRequest(url, body);
    List<UserModel> userList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      UserModel user = UserModel.fromMap(sourceMap);
      userList.add(user);
    });
    yield userList;
  }

  static Stream<List<NewsModel>> searchForNews({
    @required queryString,
  }) async* {
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

  static Stream<List<TimebankModel>> searchForTimebank({
    @required queryString,
  }) async* {
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

  static Stream<List<CampaignModel>> searchForCampaign({
    @required queryString,
  }) async* {
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

  static Stream<List<OfferModel>> searchForOffer({
    @required queryString,
  }) async* {
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

  static Stream<List<RequestModel>> searchForRequest({
    @required String queryString,
  }) async* {
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

  static Future<List<Map<String, dynamic>>> _makeElasticSearchRequest(
      String url) async {
    http.Response response = await makeGetRequest(url: url);
    Map<String, dynamic> bodyMap = json.decode(response.body);
    Map<String, dynamic> hitMap = bodyMap['hits'];
    List<Map<String, dynamic>> hitList = List.castFrom(hitMap['hits']);
    return hitList;
  }
  static Future<List<Map<String, dynamic>>> _makeElasticSearchPostRequest(
      String url, dynamic body) async {
    String username = 'user';
    String password = 'CiN36UNixjyq';
    log(json.encode({'authorization': 'basic ' + base64Encode(utf8.encode('$username:$password'))}));
    http.Response response = await makePostRequest(url: url,body: body, headers: {'authorization': 'basic dXNlcjpDaU4zNlVOaXhKeXE=', "Accept": "application/json",
      "Content-Type": "application/json"});
    log(response.body);
    Map<String, dynamic> bodyMap = json.decode(response.body);
    Map<String, dynamic> hitMap = bodyMap['hits'];
    List<Map<String, dynamic>> hitList = List.castFrom(hitMap['hits']);
    return hitList;
  }
}
