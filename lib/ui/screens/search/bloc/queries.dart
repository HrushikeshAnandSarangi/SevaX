import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';

class Searches {
  static Future<http.Response> makePostRequest({
    @required String url,
    Map<String, String> headers,
    dynamic body,
  }) async {
    var result = await http.post(url, body: body, headers: headers);
    return result;
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

  // Feeds DONE
  static Stream<List<NewsModel>> searchFeeds(
      {@required String queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != FlavorConfig.values.timebankId) {
        timebanksIdArr.add(doc.documentID);
      }
    });
    // List<String> myTimebanks = getTimebanksAndGroupsOfUser(
    //     currentCommunityOfUser.timebanks, timebanksIdArr);
    // List<String> myTimebanks = getTimebanksAndGroupsOfUser(
    //     currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);

    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/newsfeed/_doc/_search';
    dynamic body = json.encode(
      {
        "size": 1000,
        "query": {
          "bool": {
            "must": [
              {
                "terms": {"timebanksposted.keyword": timebanksIdArr}
              },
              {
                "multi_match": {
                  "query": queryString,
                  "fields": ["description", "email", "subheading"],
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
    List<NewsModel> feedsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (loggedInUser.blockedBy.length == 0 &&
          sourceMap['softDelete'] == false) {
        NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
        news.id = map['_id'];
        feedsList.add(news);
      } else {
        if (sourceMap['softDelete'] == false &&
            !loggedInUser.blockedBy.contains(sourceMap["sevauserid"])) {
          NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
          news.id = map['_id'];
          feedsList.add(news);
        }
      }
    });
    // for (var i = 0; i < feedsList.length; i++) {
    //   UserModel userModel = await getUserForId(
    //     sevaUserId: feedsList[i].sevaUserId,
    //   );
    //   feedsList[i].userPhotoURL = userModel.photoURL;
    // }
    yield feedsList;
  }

  // Offers DONE

  static Stream<List<OfferModel>> searchOffers(
      {@required queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .where('community_id', isEqualTo: loggedInUser.currentCommunity)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != FlavorConfig.values.timebankId) {
        timebanksIdArr.add(doc.documentID);
      }
    });
    // List<String> myTimebanks = getTimebanksAndGroupsOfUser(
    //     currentCommunityOfUser.timebanks, timebanksIdArr);
//    List<String> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/offers/_doc/_search';

    dynamic body = json.encode({
      "size": 3000,
      "query": {
        "bool": {
          "must": [
            {
              "terms": {"timebankId.keyword": timebanksIdArr}
            },
            {
              "term": {"autoGenerated": false}
            },
            {
              "bool": {
                "should": [
                  {
                    "nested": {
                      "path": "individualOfferDataModel",
                      "query": {
                        "bool": {
                          "should": {
                            "multi_match": {
                              "query": queryString,
                              "fields": [
                                "individualOfferDataModel.description",
                                "individualOfferDataModel.title"
                              ],
                              "type": "phrase_prefix"
                            }
                          }
                        }
                      }
                    }
                  },
                  {
                    "nested": {
                      "path": "groupOfferDataModel",
                      "query": {
                        "bool": {
                          "should": {
                            "multi_match": {
                              "query": queryString,
                              "fields": [
                                "groupOfferDataModel.classDescription",
                                "groupOfferDataModel.classTitle"
                              ],
                              "type": "phrase_prefix"
                            }
                          }
                        }
                      }
                    }
                  },
                  {
                    "multi_match": {
                      "query": queryString,
                      "fields": ["email", "fullname", "selectedAdrress"],
                      "type": "phrase_prefix"
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    });

    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<OfferModel> offersList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (loggedInUser.blockedBy.length == 0 &&
          sourceMap['softDelete'] == false) {
        try {
          OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
          if (model.associatedRequest == null ||
              model.associatedRequest.isEmpty) {
            offersList.add(model);
          }
        } catch (e) {
          logger.e(e);
        }
      } else {
        if (sourceMap['softDelete'] == false &&
            !loggedInUser.blockedBy.contains(sourceMap["sevauserId"])) {
          OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
          if (model.associatedRequest == null ||
              model.associatedRequest.isEmpty) {
            offersList.add(model);
          }
        }
      }
    });
    yield offersList;
  }

  // Projects DONE

  static Stream<List<ProjectModel>> searchProjects(
      {@required String queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .where('community_id', isEqualTo: loggedInUser.currentCommunity)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != FlavorConfig.values.timebankId) {
        timebanksIdArr.add(doc.documentID);
      }
    });
    // List<String> myTimebanks = getTimebanksAndGroupsOfUser(
    //     currentCommunityOfUser.timebanks, timebanksIdArr);
//    List<String> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/sevaxprojects/_doc/_search';
    dynamic body = json.encode(
      {
        "size": 3000,
        "query": {
          "bool": {
            "must": [
              {
                "terms": {"timebank_id.keyword": timebanksIdArr}
              },
              {
                "multi_match": {
                  "query": queryString,
                  "fields": ["address", "description", "email_id", "name"],
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
    List<ProjectModel> projectsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (loggedInUser.blockedBy.length == 0 &&
          sourceMap['softDelete'] == false) {
        ProjectModel model = ProjectModel.fromMap(sourceMap);
        projectsList.add(model);
      } else {
        if (sourceMap['softDelete'] == false &&
            !loggedInUser.blockedBy.contains(sourceMap["creator_id"])) {
          ProjectModel model = ProjectModel.fromMap(sourceMap);
          projectsList.add(model);
        }
      }
    });
    projectsList.sort((a, b) => a.name.compareTo(b.name));
    yield projectsList;
  }

  // Requests DONE

  static Stream<List<RequestModel>> searchRequests(
      {@required String queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .where('community_id', isEqualTo: loggedInUser.currentCommunity)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != FlavorConfig.values.timebankId) {
        timebanksIdArr.add(doc.documentID);
      }
    });
    // List<String> myTimebanks = getTimebanksAndGroupsOfUser(
    //     currentCommunityOfUser.timebanks, timebanksIdArr);
//    List<String> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);

    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/requests/request/_search';
    dynamic body = json.encode(
      {
        "size": 3000,
        "query": {
          "bool": {
            "must": [
              {
                "terms": {"timebankId.keyword": timebanksIdArr}
              },
              {
                "term": {"autoGenerated": false}
              },
              {
                "multi_match": {
                  "query": queryString,
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
    List<RequestModel> requestsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      log("gotten req -> ${sourceMap['title']}");
      if (sourceMap['softDelete'] == false &&
          sourceMap['autoGenerated'] == false &&
          loggedInUser.blockedBy.length == 0) {
        RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
        if (model.accepted == false) requestsList.add(model);
      } else {
        if (sourceMap['softDelete'] == false &&
            sourceMap['autoGenerated'] == false &&
            !loggedInUser.blockedBy.contains(sourceMap["sevauserid"])) {
          RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
          if (model.accepted == false) requestsList.add(model);
        }
      }
//      requestsList.sort((a, b) => a.title.compareTo(b.title));
    });
    yield requestsList;
  }

  // Groups DONE

  static Stream<List<TimebankModel>> searchGroups(
      {@required queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    String url = FlavorConfig.values.elasticSearchBaseURL +
        "//elasticsearch/sevaxtimebanks/sevaxtimebank/_search";
    dynamic body = json.encode({
      "size": 3000,
      "query": {
        "bool": {
          "must": [
            {
              "term": {
                "parent_timebank_id.keyword":
                    currentCommunityOfUser.primary_timebank
              }
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
          loggedInUser.blockedBy.length == 0) {
        var timeBank = TimebankModel.fromMap(sourceMap);
        timeBanksList.add(timeBank);
      } else {
        if (sourceMap['softDelete'] == false &&
            !loggedInUser.blockedBy.contains(sourceMap["creator_id"])) {
          var timeBank = TimebankModel.fromMap(sourceMap);
          timeBanksList.add(timeBank);
        }
      }
//      timeBanksList.sort((a, b) => a.name.compareTo(b.name));
    });
    yield timeBanksList;
  }

  // Members DONE

  static Stream<List<UserModel>> searchMembersOfTimebank({
    @required queryString,
    @required String languageCode,
    @required UserModel loggedInUser,
    @required CommunityModel currentCommunityOfUser,
    // QuerySnapshot skillsListSnap,
    //QuerySnapshot interestsListSnap,
  }) async* {
    Map<String, List<String>> allSkillsInterestsConsolidated =
        await getSkillsInterestsIdsOfUser(
            //skillsListSnap, interestsListSnap,
            queryString.toLowerCase(),
            languageCode);

    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
      {
        "size": 3000,
        "query": {
          "bool": {
            "must": [
              {
                "term": {"communities.keyword": loggedInUser.currentCommunity}
              },
              {
                "bool": {
                  "should": [
                    {
                      "multi_match": {
                        "query": queryString,
                        "fields": ["email", "fullname", "bio"],
                        "type": "phrase_prefix"
                      }
                    },
                    {
                      "terms": {
                        "skills.keyword": []
                        // allSkillsInterestsConsolidated['skills']
                      }
                    },
                    {
                      "terms": {
                        "interests.keyword": []
                        // allSkillsInterestsConsolidated['interests']
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      },
    );

    List<Map<String, dynamic>> hitList =
        await _makeElasticSearchPostRequest(url, body);
    List<UserModel> usersList = [];

    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (loggedInUser.blockedBy.length == 0) {
        if (loggedInUser.sevaUserID != sourceMap['sevauserid']) {
          UserModel user = UserModel.fromMap(sourceMap, 'queries');
          usersList.add(user);
        }
      } else {
        if (!loggedInUser.blockedBy.contains(sourceMap['sevauserid']) &&
            loggedInUser.sevaUserID != sourceMap['sevauserid']) {
          UserModel user = UserModel.fromMap(sourceMap, 'queries');
          usersList.add(user);
        }
      }
    });

//      usersList.sort((a, b) => a.fullname.compareTo(b.fullname));
    yield usersList;
  }

  static List<String> getTimebanksAndGroupsOfUser(
      timebanksOfCommunity, timebanksOfUser) {
    List<String> timebankarr = List();
    timebanksOfCommunity.forEach((tb) {
      if (timebanksOfUser.contains(tb)) {
        timebankarr.add(tb);
      }
    });
    return timebankarr;
  }

  static Future<Map<String, List<String>>> getSkillsInterestsIdsOfUser(
      //  QuerySnapshot allSkills,
      ///QuerySnapshot allInterests,
      String queryString,
      String language) async {
    Map<String, List<String>> skillsInterestsConsolidated = {};

    List<String> skillsarr = List();
    List<String> interestsarr = List();
    String temp = "";

    skillsarr = await SearchManager.searchSkills(
        queryString: queryString, language: language);

    interestsarr = await SearchManager.searchInterest(
        queryString: queryString, language: language);
    log('data skilll ${skillsarr}');
    log('data inter ${interestsarr}');

//    allSkills.documents.forEach((skillDoc) {
//      temp = skillDoc.data['name'].toLowerCase();
//      if (temp.contains(queryString.toLowerCase())) {
//        skillsarr.add(skillDoc.documentID);
//      }
//    });
//    allInterests.documents.forEach((interestDoc) {
//      temp = interestDoc.data['name'].toLowerCase();
//      if (temp.contains(queryString)) {
//        interestsarr.add(interestDoc.documentID);
//      }
//    });

    skillsInterestsConsolidated['skills'] = skillsarr;
    skillsInterestsConsolidated['interests'] = interestsarr;

    return skillsInterestsConsolidated;
  }
}
