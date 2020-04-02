import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';

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


// Feeds done

  static Stream<List<NewsModel>> searchFeeds({
    @required  String queryString,
    @required UserModel loggedInUser,
    @required CommunityModel currentCommunityOfUser
  }) async* {
   List<TimebankModel> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);

    String url = baseURL + '/newsfeed/_doc/_search';
    dynamic body = json.encode(
      {
        "size":3000,
        "query": {
          "bool": {
            "must": [
              {
                "nested": {
                  "path": "entity",
                  "query": {
                    "bool": {
                      "must": {
                        "terms": {
                          "entity.entityId.keyword": myTimebanks
                        }
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
    List<Map<String, dynamic>> hitList = await _makeElasticSearchPostRequest(url, body);
    List<NewsModel> feedsList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if(loggedInUser.blockedBy != null){
        if(!loggedInUser.blockedBy.contains(sourceMap["sevauserid"])){
          NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
          news.id = map['_id'];
          feedsList.add(news);
        }
      } else {
        NewsModel news = NewsModel.fromMapElasticSearch(sourceMap);
        news.id = map['_id'];
        feedsList.add(news);
      }
    });
    feedsList.sort((a, b) => a.title.compareTo(b.title));
    yield feedsList;
  }

// Offers done

  static Stream<List<OfferModel>> searchOffers({
    @required queryString,
    @required loggedInUser,
    @required CommunityModel currentCommunityOfUser
  }) async* {
    List<TimebankModel> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = baseURL + '/offers/offer/_search';
    dynamic body = json.encode(
      {
        "size":3000,
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "terms": {
                  "timebankId.keyword": myTimebanks
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
    List<Map<String, dynamic>> hitList = await _makeElasticSearchPostRequest(url, body);

    List<OfferModel> offersList = [];
    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
       if(loggedInUser.blockedBy != null){
        if (!loggedInUser.blockedBy.contains(sourceMap["sevauserId"])) {
          OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
          if (model.associatedRequest == null ||
              model.associatedRequest.isEmpty) {
            offersList.add(model);
          }
        }
      }else{
         OfferModel model = OfferModel.fromMapElasticSearch(sourceMap);
         if (model.associatedRequest == null ||
             model.associatedRequest.isEmpty) {
           offersList.add(model);
         }
       }
    });
    offersList.sort((a, b) => a.title.compareTo(b.title));
    yield offersList;
  }

// TODO projects api integration.

//  static Stream<List<RequestModel>> searchProjects({
//    @required String queryString,
//    @required loggedInUser,
//    @required CommunityModel currentCommunityOfUser
//  }) async* {
//  List<TimebankModel> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
//    String url = baseURL + '/sevaxprojects/_doc/_search';
//    dynamic body = json.encode(
//      {
//        "size":3000,
//        "query": {
//          "bool": {
//            "must": [
//              {
//                "terms": {
//                  "timebank_id.keyword": myTimebanks
//                }
//              },
//              {
//                "multi_match": {
//                  "query": queryString,
//                  "fields": ["address", "email_id", "name"],
//                  "type": "phrase_prefix"
//                }
//              }
//            ]
//          }
//        }
//      },
//    );
//    List<Map<String, dynamic>> hitList =
//    await _makeElasticSearchPostRequest(url, body);
//    List<RequestModel> projectsList = [];
//    hitList.forEach((map) {
//      Map<String, dynamic> sourceMap = map['_source'];
//      if(loggedInUser.blockedBy != null){
//        if(!loggedInUser.blockedBy.contains(sourceMap["creator_id"])){
//          ProjectModel model = ProjectModel.fromMapElasticSearch(sourceMap);
//          projectsList.add(model);
//        }
//      }else{
//        ProjectModel model = ProjectModel.fromMapElasticSearch(sourceMap);
//        projectsList.add(model);
//      }
//
//    });
//    projectsList.sort((a, b) => a.name.compareTo(b.name));
//    yield projectsList;
//  }

  // Requests done

  static Stream<List<RequestModel>> searchRequests({
    @required String queryString,
    @required loggedInUser,
    @required CommunityModel currentCommunityOfUser
  }) async* {
    List<TimebankModel> myTimebanks = getTimebanksAndGroupsOfUser(currentCommunityOfUser.timebanks, loggedInUser.membershipTimebanks);
    String url = baseURL + '/requests/request/_search';
    dynamic body = json.encode(
      {
        "size":3000,
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "terms": {
                  "timebankId.keyword": myTimebanks
                }
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
      if(loggedInUser.blockedBy != null){
        if(!loggedInUser.blockedBy.contains(sourceMap["sevauserid"])){
          RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
          if (model.accepted == false) requestsList.add(model);
        }
      }else{
        RequestModel model = RequestModel.fromMapElasticSearch(sourceMap);
        if (model.accepted == false) requestsList.add(model);
      }
      requestsList.sort((a, b) => a.title.compareTo(b.title));
    });
    yield requestsList;
  }

  // group Timebanks

  static Stream<List<TimebankModel>> searchGroups({
    @required queryString,
    @required loggedInUser,
    @required CommunityModel currentCommunityOfUser
  }) async* {
    String url = baseURL + "/sevaxtimebanks/sevaxtimebank/_search";
    dynamic body = json.encode(
    {
      "size":3000,
      "query": {
        "bool": {
          "must": [
            {
              "term": {
                "parent_timebank_id.keyword": currentCommunityOfUser.primary_timebank
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
      if(loggedInUser.blockedBy != null){
        if(!loggedInUser.blockedBy.contains(sourceMap["creator_id"])){
          var timeBank = TimebankModel.fromMap(sourceMap);
          timeBanksList.add(timeBank);
        }
      }else{
        var timeBank = TimebankModel.fromMap(sourceMap);
        timeBanksList.add(timeBank);
      }
//      timeBanksList.sort((a, b) => a.name.compareTo(b.name));
    });
    yield timeBanksList;
  }

  // Users of a timebank done

  static Stream<List<UserModel>> searchMembersOfTimebank({
    @required queryString,
    @required loggedInUser,
    @required CommunityModel currentCommunityOfUser
  }) async* {
    String url = baseURL + '/sevaxusers/sevaxuser/_search';
    dynamic body = json.encode(
    {
      "size":3000,
        "query": {
          "bool": {
            "must": [
              {
                "match": {
                  "root_timebank_id": "${FlavorConfig.values.timebankId}"
                }
              },
              {
                "match":{
                  "communities": loggedInUser.currentCommunity
                }
              },
              {
                "multi_match": {
                  "query": queryString,
                  "fields": ["email", "fullname", "bio"],
                  "type": "phrase_prefix"
                }
              },
            ]
          }
        }
      },
    );
    List<Map<String, dynamic>> hitList = await _makeElasticSearchPostRequest(url, body);
    List<UserModel> usersList = [];

    hitList.forEach((map) {
      Map<String, dynamic> sourceMap = map['_source'];
      if(loggedInUser.blockedBy != null){
        if(!loggedInUser.blockedBy.contains(sourceMap['sevauserid'])){
          UserModel user = UserModel.fromMap(sourceMap);
          usersList.add(user);
        }
      }else{
        UserModel user = UserModel.fromMap(sourceMap);
        usersList.add(user);
      }
    });
    usersList.sort((a, b) => a.fullname.compareTo(b.fullname));
    yield usersList;
  }



  static List<TimebankModel> getTimebanksAndGroupsOfUser(timebanksOfCommunity, timebanksOfUser){
      List<TimebankModel> timebankarr = new List();
      timebanksOfCommunity.forEach( (tb) {
        if(timebanksOfUser.contains(tb)){
          timebankarr.add(tb);
        }
      });
      return timebankarr;
  }


}
