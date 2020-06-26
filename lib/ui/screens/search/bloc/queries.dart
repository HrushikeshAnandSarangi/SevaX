import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';

class Searches {
  static Future<http.Response> makePostRequest({
    @required String url,
    Map<String, String> headers,
    dynamic body,
  }) async {
    var result = await http.post(url, body: body, headers: headers);
    print("http response ==> ${result.body}");
    return result;
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

  // Feeds DONE

  static Stream<List<NewsModel>> searchFeeds(
      {@required String queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = new List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != "73d0de2c-198b-4788-be64-a804700a88a4") {
        timebanksIdArr.add(doc.documentID);
      }
    });
    List<String> myTimebanks = getTimebanksAndGroupsOfUser(
        currentCommunityOfUser.timebanks, timebanksIdArr);
//    List<String> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/newsfeed/_doc/_search';
    dynamic body = json.encode(
      {
        "size": 1000,
        "query": {
          "bool": {
            "must": [
              {
                "nested": {
                  "path": "entity",
                  "query": {
                    "bool": {
                      "must": {
                        "terms": {"entity.entityId.keyword": myTimebanks}
                      }
                    }
                  }
                }
              },
              {
                "match": {
                  "root_timebank_id": "73d0de2c-198b-4788-be64-a804700a88a4"
                }
              },
              {
                "multi_match": {
                  "query": queryString,
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
    List<NewsModel> feedsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if (loggedInUser.blockedBy.length == 0 && sourceMap['softDelete']==false) {
        NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
        news.id = map['_id'];
        feedsList.add(news);
      } else {
        if (sourceMap['softDelete']==false && !loggedInUser.blockedBy.contains(sourceMap["sevauserid"])) {
          NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
          news.id = map['_id'];
          feedsList.add(news);
        }
      }
    });
    for (var i = 0; i < feedsList.length; i++) {
      //  modelList[i].userPhotoURL = onValue[i]['photourl'];
      UserModel userModel = await getUserForId(
        sevaUserId: feedsList[i].sevaUserId,
      );
      feedsList[i].userPhotoURL = userModel.photoURL;
    }
//    feedsList.sort((a, b) => a.title.compareTo(b.title));
    yield feedsList;
  }

  // Offers DONE

  static Stream<List<OfferModel>> searchOffers(
      {@required queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser}) async* {
    List<String> timebanksIdArr = new List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != "73d0de2c-198b-4788-be64-a804700a88a4") {
        timebanksIdArr.add(doc.documentID);
      }
    });
    List<String> myTimebanks = getTimebanksAndGroupsOfUser(
        currentCommunityOfUser.timebanks, timebanksIdArr);
//    List<String> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/offers/_doc/_search';

    dynamic body = json.encode({
      "size": 3000,
      "query": {
        "bool": {
          "must": [
            {
              "term": {
                "root_timebank_id.keyword": FlavorConfig.values.timebankId
              }
            },
            {
              "terms": {"timebankId.keyword": myTimebanks}
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
      if (loggedInUser.blockedBy.length == 0 && sourceMap['softDelete']==false) {
        try {
          OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
          if (model.associatedRequest == null ||
              model.associatedRequest.isEmpty) {
            offersList.add(model);
          }
        } catch (e) {
          print(e);
        }
      } else {
        if (sourceMap['softDelete']==false && !loggedInUser.blockedBy.contains(sourceMap["sevauserId"])) {
          OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
          print("**---->> ${model.offerType}");
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
    List<String> timebanksIdArr = new List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != "73d0de2c-198b-4788-be64-a804700a88a4") {
        timebanksIdArr.add(doc.documentID);
      }
    });
    List<String> myTimebanks = getTimebanksAndGroupsOfUser(
        currentCommunityOfUser.timebanks, timebanksIdArr);
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
                "terms": {"timebank_id.keyword": myTimebanks}
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
      if (loggedInUser.blockedBy.length == 0 && sourceMap['softDelete']==false) {
        ProjectModel model = ProjectModel.fromMap(sourceMap);
        projectsList.add(model);
      } else {
        if (sourceMap['softDelete']==false && !loggedInUser.blockedBy.contains(sourceMap["creator_id"])) {
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
    List<String> timebanksIdArr = new List();
    QuerySnapshot timebankSnap = await Firestore.instance
        .collection("timebanknew")
        .where('members', arrayContains: loggedInUser.sevaUserID)
        .getDocuments();
    timebankSnap.documents.forEach((DocumentSnapshot doc) {
      if (doc.documentID != "73d0de2c-198b-4788-be64-a804700a88a4") {
        timebanksIdArr.add(doc.documentID);
      }
    });
    List<String> myTimebanks = getTimebanksAndGroupsOfUser(
        currentCommunityOfUser.timebanks, timebanksIdArr);
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
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "terms": {"timebankId.keyword": myTimebanks}
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
      print("sourcemappppppp "+sourceMap['id']);
      if (sourceMap['softDelete']==false
          && loggedInUser.blockedBy.length == 0
          && sourceMap['projectId'] == ""
//          && sourceMap['autoGenerated']==false
      ) {
        print("inside if");
        RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
        print("asd===>"+model.toString());
        if (model.accepted == false) requestsList.add(model);
      } else {
        if (sourceMap['softDelete']==false
            && !loggedInUser.blockedBy.contains(sourceMap["sevauserid"])
            && sourceMap['projectId'] == ""
//            && sourceMap['autoGenerated']==false
        ) {
          RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
          print(model.id);
          if (model.accepted == false) requestsList.add(model);
        }
      }
      requestsList.sort((a, b) => a.title.compareTo(b.title));
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
      print("group id===${sourceMap['id']}");
      if (sourceMap['softDelete']==false && loggedInUser.blockedBy.length == 0) {
        var timeBank = TimebankModel.fromMap(sourceMap);
        timeBanksList.add(timeBank);
      } else {
        if (sourceMap['softDelete']==false && !loggedInUser.blockedBy.contains(sourceMap["creator_id"])) {
          var timeBank = TimebankModel.fromMap(sourceMap);
          timeBanksList.add(timeBank);
        }
      }
//      timeBanksList.sort((a, b) => a.name.compareTo(b.name));
    });
    yield timeBanksList;
  }

  // Members DONE

  static Stream<List<UserModel>> searchMembersOfTimebank(
      {@required queryString,
      @required UserModel loggedInUser,
      @required CommunityModel currentCommunityOfUser,
      QuerySnapshot skillsListSnap,
      QuerySnapshot interestsListSnap,
  }) async* {
    Map<String, List<String>> allSkillsInterestsConsolidated = getSkillsInterestsIdsOfUser(skillsListSnap, interestsListSnap, queryString.toLowerCase());
    print("ids of selected skills " + allSkillsInterestsConsolidated['skills'].toString());
    String url = FlavorConfig.values.elasticSearchBaseURL +
        '//elasticsearch/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
      {
        "size": 3000,
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "bool": {
                  "should": [
                    {
                      "multi_match": {
                        "query": queryString,
                        "fields": [
                          "email",
                          "fullname",
                          "bio"
                        ],
                        "type": "phrase_prefix"
                      }
                    },
                    {
                      "terms": {
                        "skills.keyword": allSkillsInterestsConsolidated['skills']
                      }
                    },
                    {
                      "terms": {
                        "interests.keyword": allSkillsInterestsConsolidated['interests']
                      }
                    }
                  ]
                }
              }
//              {
//                "multi_match": {
//                  "query": queryString,
//                  "fields": ["email", "fullname", "bio"],
//                  "type": "phrase_prefix"
//                }
//              },
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
        if (sourceMap['communities'].contains(loggedInUser.currentCommunity) &&
            loggedInUser.sevaUserID != sourceMap['sevauserid']) {
          UserModel user = UserModel.fromMap(sourceMap);
          usersList.add(user);
        }
      } else {
        if (sourceMap['communities'].contains(loggedInUser.currentCommunity) &&
            !loggedInUser.blockedBy.contains(sourceMap['sevauserid']) &&
            loggedInUser.sevaUserID != sourceMap['sevauserid']) {
          UserModel user = UserModel.fromMap(sourceMap);
          usersList.add(user);
        }
      }
    });
    usersList.sort((a, b) => a.fullname.compareTo(b.fullname));
    yield usersList;
  }

  static List<String> getTimebanksAndGroupsOfUser(
      timebanksOfCommunity, timebanksOfUser) {
    List<String> timebankarr = new List();
    timebanksOfCommunity.forEach((tb) {
      if (timebanksOfUser.contains(tb)) {
        timebankarr.add(tb);
      }
    });
    return timebankarr;
  }

  static Map<String, List<String>> getSkillsInterestsIdsOfUser(
      QuerySnapshot allSkills, QuerySnapshot allInterests, String queryString) {
    Map<String, List<String>> skillsInterestsConsolidated = {};
    List<String> skillsarr = List();
    List<String> interestsarr = List();
    String temp = "";
    allSkills.documents.forEach((skillDoc){
      temp = skillDoc.data['name'].toLowerCase();
      print("temp.contains is "+ temp + " "+queryString);
      if(temp.contains(queryString.toLowerCase())){
        print("temp.contains is ---"+temp);
        skillsarr.add(skillDoc.documentID);
      }
    });
    allInterests.documents.forEach((interestDoc){
      temp = interestDoc.data['name'].toLowerCase();
      if(temp.contains(queryString)){
        interestsarr.add(interestDoc.documentID);
      }
    });


    skillsInterestsConsolidated['skills'] = skillsarr;
    skillsInterestsConsolidated['interests'] = interestsarr;
//    print("id of selected skill " + skillsInterestsConsolidated['skills'].toString());

    return skillsInterestsConsolidated;
  }
}
