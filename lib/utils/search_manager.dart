import 'dart:convert';
import 'dart:developer';

// import 'dart:html';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/agreement_template_model.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/agreement_template_model.dart';
import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/new_baseline/models/borrow_agreement_template_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_template_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/search_via_zipcode.dart';

class SearchManager {
  static Future<http.Response> makeGetRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    return await http.get(Uri.parse(url), headers: headers);
  }

  static Future<http.Response> makePostRequest({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await http.post(Uri.parse(url), body: body, headers: headers);
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
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      UserModel user = UserModel.fromMap(sourceMap, 'search_manager');
      userList.add(user);
    });
    yield userList;
  }

  static Stream<List<CommunityModel>> searchCommunity({
    @required queryString,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxcommunities/_doc/_search?size=400';
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

    List<CommunityModel> communityList = [];
    try {
      communityList =
          await SearchCommunityViaZIPCode.getCommunitiesViaZIPCode(queryString);
    } on NoNearByCommunitesFoundException catch (e) {
      // FirebaseCrashlytics.instance
      //     .log('NoNearByCommunitesViaZIPFoundException');
    }

    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      var community = CommunityModel(sourceMap);
      if (AppConfig.isTestCommunity) {
        if (community.testCommunity) {
          communityList.add(community);
        }
      } else {
        if (community.private == false && !community.testCommunity) {
          communityList.add(community);
        }
      }
    });
    yield communityList;
  }

  static Future<bool> searchCommunityForDuplicate(
      {required String queryString}) async {
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
      if (map['_source']['name'].toLowerCase().trim() ==
          queryString.toLowerCase()) {
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

  static Stream<List<ProjectTemplateModel>> searchProjectTemplate({
    @required queryString,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/posttemplates/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": queryString,
                "fields": ["templateName"],
                "type": "phrase_prefix"
              }
            }
          ]
        }
      },
      "sort": {
        "templateName.keyword": {"order": "asc"}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<ProjectTemplateModel> templatesList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];

      var template = ProjectTemplateModel.fromMap(sourceMap);
      if (template.softDelete == false) {
        templatesList.add(template);
      }

      //CommunityModel communityModel = CommunityModel.fromMap(sourceMap);
      //communityList.add(communityModel);
    });
    yield templatesList;
  }

  //searcch borrow agreement template
  static Stream<List<AgreementTemplateModel>> searchAgreementTemplate(
      {required queryString, required placeOrItem, required creatorId}) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/agreement_templates/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "term": {"creatorId.keyword": creatorId}
            },
            {
              "multi_match": {
                "query": queryString,
                "fields": ["templateName"],
                "type": "phrase_prefix"
              }
            }
          ]
        }
      },
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);

    log('hit ${hitList}');

    List<AgreementTemplateModel> templatesList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      var template = AgreementTemplateModel.fromMap(sourceMap);

      if (template.softDelete == false && template.placeOrItem == placeOrItem) {
        templatesList.add(template);
      }
    });
    yield templatesList;
  }

  static Future<bool> searchAgrrementTemplateForDuplicate(
      {required String queryString}) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/agreement_templates/_doc/_search';

    dynamic body = json.encode({
      "query": {
        "match": {"templateName": queryString}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
//    await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
    bool templateFound = false;
    for (var map in hitList) {
      if (map['_source']['templateName'].toLowerCase() ==
          queryString.toLowerCase()) {
        templateFound = true;

        break;
      }
    }

    return templateFound;
//    int count =
//        await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
//    if (count > 0) {
//      return true;
//    } else {
//      return false;
//    }
  }

  //search borrow agreement template
  static Stream<List<AgreementTemplateModel>> searchBorrowAgreementTemplate({
    @required queryString,
  }) async* {
    String url =

        ///query needs to be refactored to agreement_tmeplates (common for borrow requests and lending offers)
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/agreement_templates/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": queryString,
                "fields": ["templateName"],
                "type": "phrase_prefix"
              }
            }
          ]
        }
      },
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);

    log('hit ${hitList}');

    List<AgreementTemplateModel> templatesList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      var template = AgreementTemplateModel.fromMap(sourceMap);

      if (template.softDelete == false) {
        templatesList.add(template);
      }
    });
    yield templatesList;
  }

  static Future<bool> searchTemplateForDuplicate(
      {required String queryString}) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/posttemplates/_doc/_search';

    dynamic body = json.encode({
      "query": {
        "match": {"templateName": queryString}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
//    await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
    bool templateFound = false;
    for (var map in hitList) {
      if (map['_source']['templateName'].toLowerCase() ==
          queryString.toLowerCase()) {
        templateFound = true;

        break;
      }
    }

    return templateFound;
//    int count =
//        await _makeElasticSearchPostRequestCommunityDuplicate(url, body);
//    if (count > 0) {
//      return true;
//    } else {
//      return false;
//    }
  }

  static Future<bool> searchRequestCategoriesForDuplicate(
      {required queryString, required BuildContext context}) async {
    var key = S.of(context).localeName;

    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/request_categories/_doc/_search?size=400';
    dynamic body = json.encode({
      "query": {
        "match": {"title_" + key ?? 'en': queryString.trim()}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    bool categoryfound = false;
    for (var map in hitList) {
      if (map['_source']['title_' + key ?? 'en'].toLowerCase() ==
          queryString.toLowerCase()) {
        categoryfound = true;
        break;
      }
    }
    return categoryfound;
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
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
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
      UserModel user = UserModel.fromMap(sourceMap, 'search_manager');

//      if (validItems.contains(user.sevaUserID)) {
      userList.add(user);
//      }
    });
    yield userList;
  }

  static Stream<List<UserModel>> searchForUserWithTimebankId({
    required queryString,
    required List<String> validItems,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';

    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
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
      UserModel user = UserModel.fromMap(sourceMap, 'search_manager');
      if (validItems.contains(user.sevaUserID)) {
        userList.add(user);
      }
    });
    yield userList;
  }

  static Future<List<TimebankModel>> searchTimebankModelsOfUserFuture(
      {required String queryString, required UserModel currentUser}) async {
    String url = FlavorConfig.values.elasticSearchBaseURL +
        "//elasticsearch/sevaxtimebanks/sevaxtimebank/_search";
    dynamic body = json.encode({
      "size": 3000,
      "query": {
        "bool": {
          "must": [
            {
              "term": {"community_id.keyword": currentUser.currentCommunity}
            },
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
    List<TimebankModel> timeBanksList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (sourceMap['softDelete'] == false &&
          currentUser.blockedBy!.length == 0) {
        var timeBank = TimebankModel.fromMap(sourceMap);
        timeBanksList.add(timeBank);
      } else {
        if (sourceMap['softDelete'] == false &&
            !currentUser.blockedBy!.contains(sourceMap["creator_id"])) {
          var timeBank = TimebankModel.fromMap(sourceMap);
          timeBanksList.add(timeBank);
        }
      }
    });
    return timeBanksList;
  }

  static Future<List<UserModel>> searchForUserWithTimebankIdFuture({
    required String queryString,
    required List<String> validItems,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
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

      UserModel user = UserModel.fromMap(sourceMap, 'search_manager');
      if (validItems.contains(user.sevaUserID)) {
        userList.add(user);
      }
    });
    return userList;
  }

  static Future<List<String>> searchSkills({
    required String queryString,
    required String language,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/skills/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "match": {language: queryString}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<String> skillList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];

      skillList.add(sourceMap['id']);
    });
    return skillList;
  }

  static Future<List<String>> getSkills({
    required List<String> skillsList,
    required String languageCode,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/skills/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "filter": [
            {
              "terms": {"id.keyword": skillsList}
            }
          ]
        }
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<String> skillList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];

      skillList.add(sourceMap[languageCode]);
    });
    return skillList;
  }

  static Future<List<String>> getInterests({
    required List<String> interestList,
    required String languageCode,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/interests/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "bool": {
          "filter": [
            {
              "terms": {"id.keyword": interestList}
            }
          ]
        }
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<String> interestsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];

      interestsList.add(sourceMap[languageCode]);
    });
    return interestsList;
  }

  static Future<List<String>> searchInterest({
    required String queryString,
    required String language,
  }) async {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/interests/_doc/_search';
    dynamic body = json.encode({
      "query": {
        "match": {language: queryString}
      }
    });
    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<String> interestsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];

      interestsList.add(sourceMap['id']);
    });
    return interestsList;
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
      if (model.associatedRequest == null || model.associatedRequest!.isEmpty)
        offerList.add(model);
    });
    yield offerList;
  }

  static Stream<List<RequestModel>> searchForRequest({
    required String queryString,
  }) async* {
    String url =
        '${FlavorConfig.values.elasticSearchBaseURL}//elasticsearch/requests/request/_search';
    dynamic body = json.encode(
      {
        "query": {
          "bool": {
            "must": [
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
