import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/invitation_model.dart';
import 'package:sevaexchange/models/models.dart' as prefix0;
import 'package:sevaexchange/models/reports_model.dart';
import 'package:sevaexchange/new_baseline/models/card_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/views/timebanks/invite_members_group.dart';

import '../app_config.dart';

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

////to get all the user invites --
Future<GroupInvitationStatus> getGroupInvitationStatus({
  @required String timebankId,
  @required String sevauserid,
}) async {
  var query = Firestore.instance
      .collection('invitations')
      .where('invitationType', isEqualTo: 'GroupInvite')
      .where('invitedUserId', isEqualTo: sevauserid)
      .where('timebankId', isEqualTo: timebankId);

  QuerySnapshot snapshot = await query.getDocuments();
  print('ghghgh ${snapshot.documents}');
  if (snapshot.documents.length > 0) {
    return GroupInvitationStatus.isInvited();
  } else {
    return GroupInvitationStatus.notYetInvited();
  }
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
    print("hey ${dataMap}");
    timeBankIdList = dataMap["timebanks"];
  });

  var comm = await getCommunityDetailsByCommunityId(communityId: communityId);

  print(timeBankIdList);
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
Future<int> getMembersCount({@required String communityId}) async {
  DocumentSnapshot documentSnaphot = await Firestore.instance
      .collection('communities')
      .document(communityId)
      .get();
  var primaryTimebankId = documentSnaphot.data['primary_timebank'];
  DocumentSnapshot timebankDoc = await Firestore.instance
      .collection('timebanknew')
      .document(primaryTimebankId)
      .get();
  int totalCount = timebankDoc.data['members'].length;
  print("full counttttttttt " + totalCount.toString());
  return totalCount;
}

/// Get all timebanknew associated with a User as a Stream_
Future<int> getMembersCountOfAllMembers({@required String communityId}) async {
  int totalCount = 0;
  totalCount = await getMembersCount(communityId: communityId);
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

Stream<List<CommunityModel>> getNearCommunitiesListStream() async* {
  // LocationData pos = await location.getLocation();
  // double lat = pos.latitude;
  // double lng = pos.longitude;
  // Location location = new Location();
  Geoflutterfire geo = Geoflutterfire();
  Geolocator geolocator = Geolocator();
  Position userLocation;
  userLocation = await geolocator.getCurrentPosition();
  double lat = userLocation.latitude;
  double lng = userLocation.longitude;

  var radius = 20;
  try {
    print('inside near');

    radius = json.decode(AppConfig.remoteConfig.getString('radius'));
  } on Exception {
    print("Exception raised while getting radius ");
  }
  print(
      "radius is fetched from remote config near community list stream ${radius.toDouble()}");

  GeoFirePoint center = geo.point(latitude: lat, longitude: lng);
  var query = Firestore.instance.collection('communities');
  var data = geo.collection(collectionRef: query).within(
        center: center,
        radius: radius.toDouble(),
        field: 'location',
        strictMode: true,
      );
  //print('near data ${data}');
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

  print("________" + timebankModel.id);
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
    'members': FieldValue.arrayUnion(members),
  });
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
      .updateData({
    'name': communityModel.name,
    'about': communityModel.about,
    'logo_url': communityModel.logo_url,
    'billing_address': communityModel.billing_address.toMap(),
    'taxPercentage': communityModel.taxPercentage,
  });
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
  print('---->>> $timebankId');
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
  print('---->>> $communityId');
  var data = Firestore.instance
      .collection('communities')
      .document(communityId)
      .snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CommunityModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        print("billing ${snapshot.data}");

        CommunityModel model = CommunityModel(snapshot.data);

        model.id = snapshot.documentID;
        modelSink.add(model);
      },
    ),
  );
}

Stream<CardModel> getCardModelStream({@required String communityId}) async* {
  // print('---->>> $communityId');
  var data =
      Firestore.instance.collection('cards').document(communityId).snapshots();

  yield* data.transform(
    StreamTransformer<DocumentSnapshot, CardModel>.fromHandlers(
      handleData: (snapshot, modelSink) {
        CardModel model = CardModel(snapshot.data);
        //print("card dataaaaa ${model}");

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
