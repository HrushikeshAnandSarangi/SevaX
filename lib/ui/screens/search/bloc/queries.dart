import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';

class Searches {
  static const baseURL = 'http://35.227.18.55//elasticsearch';

  static Future<http.Response> makePostRequest({
    @required String url,
    Map<String, String> headers,
    dynamic body,
  }) async {
    return await http.post(url, body: body, headers: headers);
  }

  static Future<List<Map<String, dynamic>>> _makeElasticSearchPostRequest(
      String url, dynamic body) async {
    print("Hitting - " + url);

    String username = 'user';
    String password = 'CiN36UNixJyq';
    log(
      json.encode(
        {
          'authorization':
              'basic ' + base64Encode(utf8.encode('$username:$password'))
        },
      ),
    );
    http.Response response =
        await makePostRequest(url: url, body: body, headers: {
      'authorization': 'basic dXNlcjpDaU4zNlVOaXhKeXE=',
      "Accept": "application/json",
      "Content-Type": "application/json"
    });
    //log(response.body);
    // print("Reuqest Response --> ${response.body}");

//    print("Reuqest Response --> ${response.body}");

    Map<String, dynamic> bodyMap = json.decode(response.body);
    Map<String, dynamic> hitMap = bodyMap['hits'];
    List<Map<String, dynamic>> hitList = List.castFrom(hitMap['hits']);
    // print("Reuqest Response --> $hitList");
//    log(response.body);
//    log("loggg - "+hitList.toString());
    return hitList;
  }

  static Stream<List<NewsModel>> searchFeeds({
    @required queryString,
  }) async* {
    String url = baseURL + '/newsfeed/news/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "multi_match": {
                  "query": "$queryString",
                  "fields": [
                    "description",
                    "email",
                    "fullname",
                    "subheading",
                    "title"
                  ],
                  "type": "phrase_prefix"
                }
              }
            ]
          }
        }
      },
    );
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<NewsModel> newsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
      news.id = map['_id'];
      newsList.add(news);
    });
    yield newsList;
  }

  static Stream<List<TimebankModel>> searchGroups({
    @required queryString,
  }) async* {
    String url = baseURL + "/sevaxtimebanks/sevaxtimebank/_search";
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": queryString,
                "fields": ["address", "email_id", "missionStatement", "name"],
                "type": "phrase_prefix"
              }
            }
          ]
        }
      },
      "sort": {
        "name.keyword": {"order": "asc"}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<TimebankModel> timeBankList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      var timeBank = TimebankModel.fromMap(sourceMap);
      timeBankList.add(timeBank);
    });
    yield timeBankList;
  }

  static Stream<List<UserModel>> searchMembersOfTimebank({
    @required queryString,
//    @required List<String> validItems,
  }) async* {
    String url = baseURL + '/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "multi_match": {
                  "query": "$queryString",
                  "fields": ["email", "fullname", "bio"],
                  "type": "phrase_prefix"
                }
              },
            ]
          }
        }
      },
    );
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<UserModel> userList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      UserModel user = UserModel.fromMap(sourceMap);

//      if (validItems.contains(user.sevaUserID)) {
      userList.add(user);
//      }
    });
    yield userList;
  }

  static Stream<List<OfferModel>> searchOffers({
    @required queryString,
  }) async* {
    String url =
        baseURL + 'http://35.227.18.55//elasticsearch/offers/offer/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "multi_match": {
                  "query": "$queryString",
                  "fields": ["description", "email", "fullname", "title"],
                  "type": "phrase_prefix"
                }
              }
            ]
          }
        }
      },
    );
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);

    List<OfferModel> offerList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
      if (model.associatedRequest == null || model.associatedRequest.isEmpty)
        offerList.add(model);
    });
    yield offerList;
  }

  static Stream<List<RequestModel>> searchRequests({
    @required String queryString,
  }) async* {
    String url = baseURL + '/requests/request/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "multi_match": {
                  "query": "$queryString",
                  "fields": ["description", "email", "fullname", "title"],
                  "type": "phrase_prefix"
                }
              }
            ]
          }
        }
      },
    );
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<RequestModel> offerList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
      if (model.accepted == false) offerList.add(model);
    });
    yield offerList;
  }
}
