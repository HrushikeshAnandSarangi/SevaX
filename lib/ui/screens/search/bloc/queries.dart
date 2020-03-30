import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart';
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
    Map<String, dynamic> bodyMap = json.decode(response.body);
    Map<String, dynamic> hitMap = bodyMap['hits'];
    List<Map<String, dynamic>> hitList = List.castFrom(hitMap['hits']);
    return hitList;
  }


  static Stream<List<NewsModel>> searchFeeds({
    @required queryString,
    @required UserModel loggedInUser
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
      if(!loggedInUser.blockedBy.contains(sourceMap["sevauserid"])){
        NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
        news.id = map['_id'];
        newsList.add(news);
      }
    });
    yield newsList;
  }

  static Stream<List<OfferModel>> searchOffers({
    @required queryString,
    @required loggedInUser
  }) async* {
    String url = baseURL + 'http://35.227.18.55//elasticsearch/offers/offer/_search';
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
      if(!loggedInUser.blockedBy.contains(sourceMap["sevauserId"])){
        OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
        if (model.associatedRequest == null || model.associatedRequest.isEmpty){
          offerList.add(model);
        }
      }
    });
    yield offerList;
  }
// TODO projects remaining. Will be done after wiring elasticsearch to projects collection
  static Stream<List<RequestModel>> searchRequests({
    @required String queryString,
    @required loggedInUser
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
      if(!loggedInUser.blockedBy.contains(sourceMap["sevauserid"])){
        RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
        if (model.accepted == false) offerList.add(model);
      }

    });
    yield offerList;
  }

  static Stream<List<TimebankModel>> searchGroups({
    @required queryString,
    @required loggedInUser
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
      if(!loggedInUser.blockedBy.contains(sourceMap["creator_id"])){
        var timeBank = TimebankModel.fromMap(sourceMap);
        timeBankList.add(timeBank);
      }

    });
    yield timeBankList;
  }

  static Stream<List<UserModel>> searchMembersOfTimebank({
    @required queryString,
    @required loggedInUser
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
      if(!loggedInUser.blockedBy.contains(sourceMap['sevauserid'])){
        UserModel user = UserModel.fromMap(sourceMap);
        userList.add(user);
      }
    });
    yield userList;
  }




}