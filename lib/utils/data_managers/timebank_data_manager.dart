import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
// import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/invitation_model.dart';
import 'package:sevaexchange/models/models.dart' as prefix0;
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/card_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/neayby_setting/nearby_setting.dart';
import 'package:sevaexchange/ui/utils/location_helper.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

Future<void> createTimebank({@required TimebankModel timebankModel}) async {
  return await CollectionRef.timebank
      .doc(timebankModel.id)
      .set(timebankModel.toMap());
}

Future<void> createCommunityByName(CommunityModel community) async {
  await CollectionRef.communities.doc(community.id).set(community.toMap());
}

Future<void> createJoinInvite(
    {@required InvitationModel invitationModel}) async {
  return await CollectionRef.invitations
      .doc(invitationModel.id)
      .set(invitationModel.toMap());
}

////to get the user invites --
Future<InvitationModel> getInvitationModel({
  @required String timebankId,
  @required String sevauserid,
}) async {
  var query = CollectionRef.invitations
      .where('invitationType', isEqualTo: 'GroupInvite')
      .where('data.invitedUserId', isEqualTo: sevauserid)
      .where('timebankId', isEqualTo: timebankId);
  QuerySnapshot snapshot = await query.get();
  if (snapshot.docs.length == 0) {
    return null;
  }
  InvitationModel invitationModel;

  snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
    invitationModel = InvitationModel.fromMap(documentSnapshot.data());
  });

  return invitationModel;
}

/// Get all timebanknew associated with a User
Future<List<TimebankModel>> getTimeBanksForUser(
    {@required String userEmail}) async {
  assert(userEmail != null && userEmail.isNotEmpty,
      'Email address cannot be null or empty');

  List<String> timeBankIdList = [];
  List<TimebankModel> timeBankModelList = [];

  await CollectionRef.users
      .doc(userEmail)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data();
    List timeBankList = dataMap['membershipTimebanks'];
    timeBankIdList = List.castFrom(timeBankList);
  });

  for (int i = 0; i < timeBankIdList.length; i += 1) {
    TimebankModel timeBankModel = await getTimeBankForId(
      timebankId: timeBankIdList[i],
    );
    timeBankModelList.add(timeBankModel);
  }

  return timeBankModelList;
}

/// Get all timebanknew associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForUserStream(
    {@required String userId, @required String communityId}) async* {
  var data = CollectionRef.timebank
      .where('members', arrayContains: userId)
      .where('community_id', isEqualTo: communityId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            TimebankModel model =
                TimebankModel.fromMap(documentSnapshot.data());
            if (model.rootTimebankId == FlavorConfig.values.timebankId) {
              if (!model.softDelete) {
                modelList.add(model);
              }
            }
          },
        );
        modelList.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        timebankSink.add(modelList);
      },
    ),
  );
}

//getAll the group
Future<List<TimebankModel>> getAllTheGroups(
  String communinityId,
) async {
  List<TimebankModel> timeBankModelList = [];

  if (communinityId.isNotEmpty) {
    await CollectionRef.timebank
        .where('community_id', isEqualTo: communinityId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        var timebank = TimebankModel(documentSnapshot.data);
        timeBankModelList.add(timebank);
      });
    });
  }
  return timeBankModelList;
}

/// Get all timebanknew associated with a User as a Stream_
Future<List<TimebankModel>> getSubTimebanksForUserStream(
    {@required String communityId}) async {
  List<dynamic> timeBankIdList = [];
  List<TimebankModel> timeBankModelList = [];
  await CollectionRef.communities
      .doc(communityId)
      .get()
      .then((DocumentSnapshot documentSnaphot) {
    Map<String, dynamic> dataMap = documentSnaphot.data();
    timeBankIdList = dataMap["timebanks"];
  });

  var comm = await getCommunityDetailsByCommunityId(communityId: communityId);

  for (int i = 0; i < timeBankIdList.length; i += 1) {
    if (timeBankIdList[i] != comm.primary_timebank) {
      TimebankModel timeBankModel = await getTimeBankForId(
        timebankId: timeBankIdList[i],
      );
      timeBankModelList.add(timeBankModel);
    }
    /*if(timeBankModel.members.contains(sevaUserId)){
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    } else if(timeBankModel.admins.contains(sevaUserId)){
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    }else{
      timeBankModel.joinStatus=CompareToTimeBank.JOIN;
    }*/

  }
  return timeBankModelList;
}

/// Get all timebanknew associated with a User as a Stream_
Future<int> getMembersCountOfAllMembers({@required String communityId}) async {
  int totalCount = 0;
  DocumentSnapshot documentSnaphot =
      await CollectionRef.communities.doc(communityId).get();
  var primaryTimebankId = documentSnaphot.data()['primary_timebank'];
  DocumentSnapshot timebankDoc =
      await CollectionRef.timebank.doc(primaryTimebankId).get();
  totalCount = timebankDoc.data()['members'].length;
  return totalCount;
}

/// Get all timebanknew associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForAdmins(
    {@required String userId}) async* {
  var data =
      CollectionRef.timebank.where('admins', arrayContains: userId).snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            TimebankModel model =
                TimebankModel.fromMap(documentSnapshot.data());
            if (model.rootTimebankId == FlavorConfig.values.timebankId)
              modelList.add(model);
          },
        );

        timebankSink.add(modelList);
      },
    ),
  );
}

/// Get all timebanknew associated with a User as a Stream
Stream<UserModel> getUserDetails({@required String userId}) async* {
  var data =
      CollectionRef.users.where('sevauserid', isEqualTo: userId).snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        timebankSink
            .add(UserModel.fromMap(snapshot.docs.first.data(), 'timebank'));
      },
    ),
  );
}

class NearBySettings {
  int radius;
  bool isMiles;

  @override
  String toString() {
    return "${radius.toString()} = radius, ${isMiles.toString()} =  isMiles";
  }
}

Stream<List<CommunityModel>> getNearCommunitiesListStream({
  @required NearBySettings nearbySettings,
}) async* {
  Geoflutterfire geo = Geoflutterfire();
  Location locationData;
  try {
    var lastLocation = await LocationHelper.getLocation();
    if (lastLocation.isLeft())
      yield* Stream.error("service disabled");
    else {
      lastLocation.fold((l) => null, (r) {
        locationData = r;
      });

      double lat = locationData?.latitude;
      double lng = locationData?.longitude;

      //Here get radius from dataabse
      var radius =
          NearbySettingsWidget.evaluatemaxRadiusForMember(nearbySettings);
      log("Getting within the raidus ==> " + radius.toString());

      GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
      var query = CollectionRef.communities;
      var data = geo.collection(collectionRef: query).within(
            center: center,
            radius: radius.toDouble(),
            field: 'location',
            strictMode: true,
          );
      yield* data.transform(
        StreamTransformer<List<DocumentSnapshot>,
            List<CommunityModel>>.fromHandlers(
          handleData: (snapshot, requestSink) {
            List<CommunityModel> communityList = [];
            snapshot.forEach(
              (documentSnapshot) {
                CommunityModel model = CommunityModel(documentSnapshot.data());
                model.id = documentSnapshot.id;
                if (AppConfig.isTestCommunity) {
                  if (model.testCommunity) {
                    communityList.add(model);
                  }
                } else {
                  model.softDelete == true ||
                          model.private == true ||
                          AppConfig.isTestCommunity
                      ? null
                      : communityList.add(model);
                }
              },
            );
            requestSink.add(communityList);
          },
        ),
      );
    }
  } catch (e) {
    yield* Stream.error(e);
    logger.e(e);
  }
}

Stream<List<ReportModel>> getReportedUsersStream(
    {@required String timebankId}) async* {
  var data = CollectionRef.reportedUsersList
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ReportModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<ReportModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            ReportModel model = ReportModel.fromMap(documentSnapshot.data());
            if (model.timebankId == FlavorConfig.values.timebankId)
              modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

/// Update Timebanks
Future<void> updateTimebank({@required TimebankModel timebankModel}) async {
  if (timebankModel == null) {
    return;
  }

  return await CollectionRef.timebank
      .doc(timebankModel.id)
      .update(timebankModel.toMap());
}

Future<void> updateTimebankDetails(
    {@required TimebankModel timebankModel, List members}) async {
  if (timebankModel == null) {
    return;
  }
  return await CollectionRef.timebank.doc(timebankModel.id).update({
    'name': timebankModel.name,
    'missionStatement': timebankModel.missionStatement,
    'address': timebankModel.address,
    'location': timebankModel.location.data,
    'protected': timebankModel.protected,
    'photo_url': timebankModel.photoUrl,
    'preventAccedentalDelete': timebankModel.preventAccedentalDelete,
    'private': timebankModel.private,
    if (members.length > 0) 'members': FieldValue.arrayUnion(members)
  });
}

Future<String> getplanForCurrentCommunity(String communityId) async {
  DocumentSnapshot cardDoc = await CollectionRef.cards.doc(communityId).get();
  if (cardDoc.exists) {
    return cardDoc.data()['currentplan'];
  } else {
    DocumentSnapshot communityDoc =
        await CollectionRef.communities.doc(communityId).get();
    return communityDoc.data()['payment']['planId'];
  }
}

Future<List<Map<String, dynamic>>> getTransactionsCountsList(
    String communityId) async {
  QuerySnapshot transactionsSnap = await CollectionRef.communities
      .doc(communityId)
      .collection('transactions')
      .get();
  List<Map<String, dynamic>> transactionsDocs = [];
  DateTime d = DateTime.now();
  Map<String, dynamic> tempObj = {};
  String dStr = "${d.month}_${d.year}";
  transactionsSnap.docs.forEach((doc) {
    tempObj = doc.data();
    tempObj['id'] = doc.id;
    if (tempObj['id'] != dStr) {
      transactionsDocs.add(tempObj);
    }
  });
  List<Map<String, dynamic>> L = transactionsDocs.reversed.toList();
  return L;
}

/// Get a particular Timebank by it's ID
Future<TimebankModel> getTimeBankForId({@required String timebankId}) async {
  TimebankModel timeBankModel;
  await CollectionRef.timebank
      .doc(timebankId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data();
    timeBankModel = TimebankModel.fromMap(dataMap);
    timeBankModel.id = documentSnapshot.id;
  });

  return timeBankModel;
}

/// Get a particular Timebank by it's ID
Future<OfferModel> getOfferFromId({@required String offerId}) async {
  OfferModel offerModel;
  await CollectionRef.offers.doc(offerId).get().then(
      (DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data();
    offerModel = OfferModel.fromMap(dataMap);
    offerModel.id = offerModel.id;
  }).catchError(
      (value) => logger.e('ERROR CATCH Timebank Details: ' + value.toString()));

  return offerModel;
}

Future updateCommunity({@required CommunityModel communityModel}) async {
  await CollectionRef.communities
      .doc(communityModel.id)
      .update({'members': communityModel.members});
}

Future updateCommunityDetails({@required CommunityModel communityModel}) async {
  await CollectionRef.communities
      .doc(communityModel.id)
      .update(communityModel.toMap());
}

Future<CommunityModel> getCommunityDetailsByCommunityId(
    {@required String communityId}) async {
  assert(communityId != null && communityId.isNotEmpty,
      'Time bank ID cannot be null or empty');

  CommunityModel communityModel;
  await CollectionRef.communities
      .doc(communityId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data();
    communityModel = CommunityModel(dataMap);
    logger.d(
        "==================|||||||||========================================");
  });
  return communityModel;
}

//check test community status by calling this api
Future<bool> checkTestCommunityStatus({@required String creatorId}) async {
  return await CollectionRef.communities
      .where('created_by', isEqualTo: creatorId)
      .where('testCommunity', isEqualTo: true)
      .get()
      .then((QuerySnapshot querySnapshot) {
    return querySnapshot.docs.length > 0;
  }).catchError((value) => false);
}

/// Get a Timebank data as a Stream
Stream<TimebankModel> getTimebankModelStream(
    {@required String timebankId}) async* {
  var data = CollectionRef.timebank.doc(timebankId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, TimebankModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        if (snapshot.data != null) {
          TimebankModel model = TimebankModel.fromMap(snapshot.data());
          model.id = snapshot.id;
          modelSink.add(model);
        }
      },
    ),
  );
}

/// Get a community data as a Stream
Stream<CommunityModel> getCommunityModelStream(
    {@required String communityId}) async* {
  var data = CollectionRef.communities.doc(communityId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CommunityModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        CommunityModel model = CommunityModel(snapshot.data());

        model.id = snapshot.id;
        modelSink.add(model);
      },
    ),
  );
}

Stream<CardModel> getCardModelStream({@required String communityId}) async* {
  var data = CollectionRef.cards.doc(communityId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CardModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        if (snapshot.exists) {
          CardModel model = CardModel(snapshot.data());
          model.timebankid = snapshot.id;
          modelSink.add(model);
        } else {
          //no card exists
          modelSink.add(null);
        }
      },
    ),
  );
}

Future<TimebankParticipantsDataHolder> getAllTimebankIdStream(
    {@required String timebankId}) async {
  DocumentSnapshot onValue = await CollectionRef.timebank.doc(timebankId).get();

  prefix0.TimebankModel model = prefix0.TimebankModel(onValue.data);

  var admins = model.admins;
  var coordinators = model.coordinators;
  var organizers = model.organizers;
  var members = model.members;
  var allItems = [];
  allItems.addAll(admins);
  allItems.addAll(coordinators);
  allItems.addAll(members);
  allItems.addAll(organizers);
  return TimebankParticipantsDataHolder()
    ..listOfElement = allItems
    ..timebankModel = model;
}

class TimebankParticipantsDataHolder {
  List<String> listOfElement;
  TimebankModel timebankModel;
}

Future<TimebankModel> getTimebankIdStream({@required String timebankId}) async {
  DocumentSnapshot onValue = await CollectionRef.timebank.doc(timebankId).get();

  prefix0.TimebankModel model = prefix0.TimebankModel(onValue.data());

  return model;
}

Future<int> changePlan(
    String communityId, String planId, bool isPrivate) async {
  // failure is 0, success is 1, error is 2
  try {
    http.Response result = await http.post(
      FlavorConfig.values.cloudFunctionBaseURL + '/planChangeHandler',
      body: json.encode({
        'communityId': communityId,
        "newPlanId": planId,
        'private': isPrivate
      }),
      headers: {"Content-type": "application/json"},
    );
    if (result.statusCode == 200) {
      Map<String, dynamic> resData = json.decode(result.body);
      return resData['cancellationStatus'] ? 1 : 0;
    }
  } catch (e) {
    logger.e(e);
  }
  return 2;
}

Future<int> cancelTimebankSubscription(
    String communityId, bool cancelSubscription) async {
  // failure is 0, success is 1, error is 2
  try {
    http.Response result = await http.post(
      FlavorConfig.values.cloudFunctionBaseURL + '/cancelRenewSubscription',
      body: json.encode({
        'communityId': communityId,
        'cancelSubscription': cancelSubscription
      }),
      headers: {"Content-type": "application/json"},
    );
    if (result.statusCode == 200) {
      Map<String, dynamic> resData = json.decode(result.body);
      return resData['subscriptionCancelledStatus'] ? 1 : 0;
    }
  } catch (e) {
    logger.e(e);
  }
  return 2;
}

Stream<List<TimebankModel>> getAllMyTimebanks(
    {@required String timebankId}) async* {
  var data = CollectionRef.timebank
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            TimebankModel model =
                TimebankModel.fromMap(documentSnapshot.data());
            modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

Stream<List<TimebankModel>> getChildTimebanks(
    {@required String timebankId}) async* {
  var data = CollectionRef.timebank
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];

        snapshot.docs.forEach(
          (documentSnapshot) {
            TimebankModel model =
                TimebankModel.fromMap(documentSnapshot.data());
            // if (model.timebankId == FlavorConfig.values.timebankId)
            modelList.add(model);
          },
        );
        reportsList.add(modelList);
      },
    ),
  );
}

Stream<List<prefix0.OfferModel>> getBookmarkedOffersByMember(
    {@required String sevaUserId}) async* {
  var data = CollectionRef.offers
      .where('individualOfferDataModeferAcceptors', arrayContains: sevaUserId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<prefix0.OfferModel>>.fromHandlers(
      handleData: (snapshot, offersList) {
        List<prefix0.OfferModel> modelList = [];
        snapshot.docs.forEach(
          (documentSnapshot) {
            prefix0.OfferModel model =
                prefix0.OfferModel.fromMap(documentSnapshot.data());
            modelList.add(model);
          },
        );
        offersList.add(modelList);
      },
    ),
  );
}

Stream<CommunityModel> getCurrentCommunityStream(String communityId) async* {
  Stream<DocumentSnapshot> ds =
      await CollectionRef.communities.doc(communityId).snapshots();

  yield* ds.transform(
    StreamTransformer<DocumentSnapshot, CommunityModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        CommunityModel communityModel = CommunityModel(snapshot.data());
        modelSink.add(communityModel);
      },
    ),
  );
}
