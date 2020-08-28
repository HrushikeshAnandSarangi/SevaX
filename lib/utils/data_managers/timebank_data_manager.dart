import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/invitation_model.dart';
import 'package:sevaexchange/models/models.dart' as prefix0;
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/card_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/neayby_setting/nearby_setting.dart';

Future<void> createTimebank({@required TimebankModel timebankModel}) async {
  return await Firestore.instance
      .collection('timebanknew')
      .document(timebankModel.id)
      .setData(timebankModel.toMap());
}

Future<void> createJoinInvite(
    {@required InvitationModel invitationModel}) async {
  return await Firestore.instance
      .collection('invitations')
      .document(invitationModel.id)
      .setData(invitationModel.toMap());
}

////to get the user invites --
Future<InvitationModel> getInvitationModel({
  @required String timebankId,
  @required String sevauserid,
}) async {
  var query = Firestore.instance
      .collection('invitations')
      .where('invitationType', isEqualTo: 'GroupInvite')
      .where('data.invitedUserId', isEqualTo: sevauserid)
      .where('timebankId', isEqualTo: timebankId);
  QuerySnapshot snapshot = await query.getDocuments();
  if (snapshot.documents.length == 0) {
    return null;
  }
  InvitationModel invitationModel;

  snapshot.documents.forEach((DocumentSnapshot documentSnapshot) {
    invitationModel = InvitationModel.fromMap(documentSnapshot.data);
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

  await Firestore.instance
      .collection('users')
      .document(userEmail)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
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
  var data = Firestore.instance
      .collection('timebanknew')
      .where('members', arrayContains: userId)
      .where('community_id', isEqualTo: communityId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
            if (model.rootTimebankId == FlavorConfig.values.timebankId)
              model.softDelete
                  ? print("Removed soft deleted timebank from list")
                  : modelList.add(model);
          },
        );
        modelList.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        timebankSink.add(modelList);
      },
    ),
  );
}

/// Get all timebanknew associated with a User as a Stream_
Future<List<TimebankModel>> getSubTimebanksForUserStream(
    {@required String communityId}) async {
  List<dynamic> timeBankIdList = [];
  List<TimebankModel> timeBankModelList = [];
  await Firestore.instance
      .collection('communities')
      .document(communityId)
      .get()
      .then((DocumentSnapshot documentSnaphot) {
    Map<String, dynamic> dataMap = documentSnaphot.data;
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
  DocumentSnapshot documentSnaphot = await Firestore.instance
      .collection('communities')
      .document(communityId)
      .get();
  var primaryTimebankId = documentSnaphot.data['primary_timebank'];
  DocumentSnapshot timebankDoc = await Firestore.instance
      .collection('timebanknew')
      .document(primaryTimebankId)
      .get();
  totalCount = timebankDoc.data['members'].length;
  return totalCount;
}

/// Get all timebanknew associated with a User as a Stream
Stream<List<TimebankModel>> getTimebanksForAdmins(
    {@required String userId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('admins', arrayContains: userId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
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
  var data = Firestore.instance
      .collection('users')
      .where('sevauserid', isEqualTo: userId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, UserModel>.fromHandlers(
      handleData: (snapshot, timebankSink) {
        timebankSink
            .add(UserModel.fromMap(snapshot.documents.first.data, 'timebank'));
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

Stream<List<CommunityModel>> getNearCommunitiesListStream(
    {@required NearBySettings nearbySettings}) async* {
  // LocationData pos = await location.getLocation();
  // double lat = pos.latitude;
  // double lng = pos.longitude;
  // Location location = Location();
  Geoflutterfire geo = Geoflutterfire();
  Geolocator geolocator = Geolocator();
  Position userLocation;
  userLocation = await geolocator.getCurrentPosition();
  double lat = userLocation.latitude;
  double lng = userLocation.longitude;

  //Here get radius from dataabse

  var radius = NearbySettingsWidget.evaluatemaxRadiusForMember(nearbySettings);
  log("Getting within the raidus ==> " + radius.toString());

  GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
  var query = Firestore.instance.collection('communities');
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
            CommunityModel model = CommunityModel(documentSnapshot.data);
            model.id = documentSnapshot.documentID;

            model.softDelete == true || model.private == true
                ? print("Removed soft deleted item")
                : communityList.add(model);

            // communityList.add(model);
          },
        );
        requestSink.add(communityList);
      },
    ),
  );
}

Stream<List<ReportModel>> getReportedUsersStream(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('reported_users_list')
      .where('timebankId', isEqualTo: FlavorConfig.values.timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<ReportModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<ReportModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            ReportModel model = ReportModel.fromMap(documentSnapshot.data);
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

  return await Firestore.instance
      .collection('timebanknew')
      .document(timebankModel.id)
      .updateData(timebankModel.toMap());
}

Future<void> updateTimebankDetails(
    {@required TimebankModel timebankModel, List members}) async {
  if (timebankModel == null) {
    return;
  }
  return await Firestore.instance
      .collection('timebanknew')
      .document(timebankModel.id)
      .updateData({
    'name': timebankModel.name,
    'missionStatement': timebankModel.missionStatement,
    'address': timebankModel.address,
    'location': timebankModel.location.data,
    'protected': timebankModel.protected,
    'photo_url': timebankModel.photoUrl,
    'preventAccedentalDelete': timebankModel.preventAccedentalDelete,
    'private': timebankModel.private,
    'members': FieldValue.arrayUnion(members),
  });
}

Future<String> getplanForCurrentCommunity(String communityId) async {
  DocumentSnapshot cardDoc =
      await Firestore.instance.collection("cards").document(communityId).get();
  if (cardDoc.exists) {
    return cardDoc.data['currentplan'];
  } else {
    DocumentSnapshot communityDoc = await Firestore.instance
        .collection("communities")
        .document(communityId)
        .get();
    return communityDoc.data['payment']['planId'];
  }
}

Future<List<Map<String, dynamic>>> getTransactionsCountsList(
    String communityId) async {
  QuerySnapshot transactionsSnap = await Firestore.instance
      .collection('communities')
      .document(communityId)
      .collection("transactions")
      .getDocuments();
  List<Map<String, dynamic>> transactionsDocs = [];
  var d = DateTime.now();
  String dStr = "${d.month}_${d.year}";
  transactionsSnap.documents.forEach((doc) {
    log("trans list doc id " + doc.documentID);
    doc.data['id'] = doc.documentID;
    if (doc.data['id'] != dStr) {
      transactionsDocs.add(doc.data);
    }
  });
  List<Map<String, dynamic>> L = transactionsDocs.reversed.toList();
  return L;
}

/// Get a particular Timebank by it's ID
Future<TimebankModel> getTimeBankForId({@required String timebankId}) async {
  assert(timebankId != null && timebankId.isNotEmpty,
      'Time bank ID cannot be null or empty');

  TimebankModel timeBankModel;
  await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    timeBankModel = TimebankModel.fromMap(dataMap);
    timeBankModel.id = documentSnapshot.documentID;
  });

  return timeBankModel;
}

Future updateCommunity({@required CommunityModel communityModel}) async {
  await Firestore.instance
      .collection('communities')
      .document(communityModel.id)
      .updateData({'members': communityModel.members});
}

Future updateCommunityDetails({@required CommunityModel communityModel}) async {
  await Firestore.instance
      .collection('communities')
      .document(communityModel.id)
      .updateData(communityModel.toMap());
}

Future<CommunityModel> getCommunityDetailsByCommunityId(
    {@required String communityId}) async {
  assert(communityId != null && communityId.isNotEmpty,
      'Time bank ID cannot be null or empty');

  CommunityModel communityModel;
  await Firestore.instance
      .collection('communities')
      .document(communityId)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> dataMap = documentSnapshot.data;
    communityModel = CommunityModel(dataMap);
  });
  return communityModel;
}

/// Get a Timebank data as a Stream
Stream<TimebankModel> getTimebankModelStream(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, TimebankModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        if (snapshot.data != null) {
          TimebankModel model = TimebankModel.fromMap(snapshot.data);
          model.id = snapshot.documentID;
          modelSink.add(model);
        }
      },
    ),
  );
}

/// Get a community data as a Stream
Stream<CommunityModel> getCommunityModelStream(
    {@required String communityId}) async* {
  var data = Firestore.instance
      .collection('communities')
      .document(communityId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CommunityModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        CommunityModel model = CommunityModel(snapshot.data);

        model.id = snapshot.documentID;
        modelSink.add(model);
      },
    ),
  );
}

Stream<CardModel> getCardModelStream({@required String communityId}) async* {
  var data =
      Firestore.instance.collection('cards').document(communityId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CardModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        CardModel model = CardModel(snapshot.data);
        model.timebankid = snapshot.documentID;
        modelSink.add(model);
      },
    ),
  );
}

Future<List<String>> getAllTimebankIdStream(
    {@required String timebankId}) async {
  DocumentSnapshot onValue = await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get();

  prefix0.TimebankModel model = prefix0.TimebankModel(onValue.data);

  var admins = model.admins;
  var coordinators = model.coordinators;
  var members = model.members;
  var allItems = List<String>();
  allItems.addAll(admins);
  allItems.addAll(coordinators);
  allItems.addAll(members);
  return allItems;
}

Future<TimebankModel> getTimebankIdStream({@required String timebankId}) async {
  DocumentSnapshot onValue = await Firestore.instance
      .collection('timebanknew')
      .document(timebankId)
      .get();

  prefix0.TimebankModel model = prefix0.TimebankModel(onValue.data);

  return model;
}

Stream<List<TimebankModel>> getAllMyTimebanks(
    {@required String timebankId}) async* {
  var data = Firestore.instance
      .collection('timebanknew')
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
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
  var data = Firestore.instance
      .collection('timebanknew')
      .where('parent_timebank_id', isEqualTo: timebankId)
      .orderBy('name', descending: false)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
      handleData: (snapshot, reportsList) {
        List<TimebankModel> modelList = [];

        snapshot.documents.forEach(
          (documentSnapshot) {
            TimebankModel model = TimebankModel.fromMap(documentSnapshot.data);
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
  var data = Firestore.instance
      .collection('offers')
      .where('individualOfferDataModel.offerAcceptors',
          arrayContains: sevaUserId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<QuerySnapshot, List<prefix0.OfferModel>>.fromHandlers(
      handleData: (snapshot, offersList) {
        List<prefix0.OfferModel> modelList = [];
        snapshot.documents.forEach(
          (documentSnapshot) {
            prefix0.OfferModel model =
                prefix0.OfferModel.fromMap(documentSnapshot.data);
            modelList.add(model);
          },
        );
        offersList.add(modelList);
      },
    ),
  );
}
