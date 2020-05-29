import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';

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
//    sevaxuser
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/users/user/_search';
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
                  "fields": ["email", "fullname"],
                  "type": "phrase_prefix"
                }
              },
              {
                "bool": {"must_not": []}
              }
            ]
          }
        },
        "sort": {
          "_id": {"order": "asc"}
        }
      },
    );
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<UserModel> userList = [];
    print("searchForUser :: ${hitList}");

    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      UserModel user = UserModel.fromMap(sourceMap);
      userList.add(user);
    });
    yield userList;
  }

  static Stream<List<CommunityModel>> searchCommunity({
    @required queryString,
  }) async* {
    print("searchForUser :: ---------------");
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxcommunities/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": queryString,
                "fields": [
                  // "billing_address",
                  "name"
                  // "primary_email"
                ],
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
    List<CommunityModel> communityList = [];
    // print("community data ${hitList}");

    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      var community = CommunityModel(sourceMap);
      // print("community data ${community.name}");
      if (community.private == false) {
        communityList.add(community);
      }

      //CommunityModel communityModel = CommunityModel.fromMap(sourceMap);
      //communityList.add(communityModel);
    });
    yield communityList;
  }

  static Future<bool> searchCommunityForDuplicate(
      {@required String queryString}) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxcommunities/_doc/_search';
//    '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxcommunities/_doc/_count';
    dynamic body = json.encode({
      "query": {
        "match": {"name": queryString}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
//    await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
    bool commFound = false;
    for (var map in hitList) {
      if (map['_source']['name'].toLowerCase() == queryString.toLowerCase()) {
        commFound = true;
        break;
      }
    }

    return commFound;
//    int count =
//        await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
//    if (count > 0) {
//      return true;
//    } else {
//      return false;
//    }
  }

  static Future<bool> searchGroupForDuplicate(
      {@required queryString, @required communityId}) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxtimebanks/sevaxtimebank/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "term": {"community_id.keyword": communityId}
            },
            {
              "match": {"name": queryString}
            }
          ]
        }
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    bool groupFound = false;
    for (var map in hitList) {
      if (map['_source']['name'].toLowerCase() == queryString.toLowerCase()) {
        groupFound = true;
        break;
      }
    }
    return groupFound;
  }

  static Stream<List<TimebankModel>> searchTimeBank({
    @required queryString,
  }) async* {
    print("searchForUser :: ---------------");
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxcommunities/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": queryString,
                "fields": ["billing_address", "name", "primary_email"],
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
      // print("community data ${community.name}");

      timeBankList.add(timeBank);

      //CommunityModel communityModel = CommunityModel.fromMap(sourceMap);
      //communityList.add(communityModel);
    });
    yield timeBankList;
  }

  static Stream<List<UserModel>> searchUserInSevaX({
    @required queryString,
    //  @required List<String> validItems,
  }) async* {
    print("searchForUser :: ---------------");
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';
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
                  "fields": ["email", "fullname"],
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

    //  log("loggg - "+validItems.toString());

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

  static Stream<List<UserModel>> searchForUserWithTimebankId({
    @required queryString,
    @required List<String> validItems,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';
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
      if (validItems.contains(user.sevaUserID)) {
        userList.add(user);
      }
    });
    yield userList;
  }

  static Future<List<UserModel>> searchForUserWithTimebankIdFuture({
    @required queryString,
    @required List<String> validItems,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';
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
      if (validItems.contains(user.sevaUserID)) {
        userList.add(user);
      }
    });
    return userList;
  }

  static Stream<List<NewsModel>> searchForNews({
    @required queryString,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/newsfeed/news/_search';
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
                    "fullname",
                    "email",
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

  static Stream<List<TimebankModel>> searchForTimebank({
    @required queryString,
  }) async* {
    String url = '$_baseUrl/everything_timebanks/_search?q=$queryString*';
    List<Map<String, dynamic>> hitList = await _makeElasticSearchRequest(url);

    List<TimebankModel> timebankList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      TimebankModel model = TimebankModel(sourceMap);
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
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/offers/_doc/_search';
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
                  "fields": ["description", "title", "fullname", "email"],
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

  static Stream<List<RequestModel>> searchForRequest({
    @required String queryString,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/requests/request/_search';
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

  static Future<int> _makeElasticSearchPostRequestCommunityDuplicate(
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
    int count = bodyMap['count'];

    return count;
  }
}
