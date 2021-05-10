import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/models/community_category_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/services/firestore_service/firestore_service.dart';
import 'package:sevaexchange/ui/screens/neayby_setting/nearby_setting.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

mixin CommunityRepository {
  static CollectionReference _ref =
      Firestore.instance.collection('communities');
  static CollectionReference _categoriesRef =
      Firestore.instance.collection('communityCategories');

  static Future<List<CommunityCategoryModel>> getCommunityCategories() async {
    var result = await _categoriesRef.getDocuments();
    List<CommunityCategoryModel> models = [];
    result.documents.forEach((document) {
      models.add(CommunityCategoryModel.fromMap(document.data));
    });
    return models;
  }

  Stream<List<CommunityModel>> getAllCommunitiesOfUser(String userId) async* {
    var data = _ref.where('members', arrayContains: userId).snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<CommunityModel>>.fromHandlers(
        handleData: (data, sink) {
          List<CommunityModel> _communities = [];

          try {
            data.documents.forEach((element) {
              var community = CommunityModel(element.data);
              _communities.add(community);
            });
            sink.add(_communities);
          } catch (e) {
            logger.e(e);
            sink.addError(e);
          }
        },
        handleError: (error, stackTrace, sink) {
          logger.e(error, stackTrace);
          sink.add(error);
        },
      ),
    );
  }

  static Future<CommunityModel> getCommunity(String communityId) async {
    var result = await _ref.document(communityId).get();
    return result.exists ? CommunityModel(result.data) : null;
  }

  static Stream<List<CommunityModel>> getCommunitiesForExplore({
    @required NearBySettings nearbySettings,
  }) async* {
    Geoflutterfire geo = Geoflutterfire();
    LocationData locationData;
    Location location = Location();

    try {
      var permission = await location.hasPermission();
      var serviceEnabled = await location.serviceEnabled();
      logger.i("<><><>$permission $serviceEnabled");
      if (permission != PermissionStatus.granted || !serviceEnabled) {
        var data = _ref
            .where("private", isEqualTo: false)
            .where("softDelete", isEqualTo: false)
            .limit(10)
            .snapshots();

        yield* data.map<List<CommunityModel>>((event) {
          List<CommunityModel> models = [];
          event.documents.forEach((element) {
            models.add(CommunityModel(element.data));
          });
          return models;
        });
      } else {
        logger.i("fetching location");
        locationData =
            await location.getLocation().timeout(Duration(seconds: 3));

        double lat = locationData?.latitude;
        double lng = locationData?.longitude;

        var radius =
            NearbySettingsWidget.evaluatemaxRadiusForMember(nearbySettings);

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
                  if (!model.softDelete && !model.private) {
                    communityList.add(model);
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

  static Stream<List<CommunityModel>> getFeatureCommunities() async* {
    var data = _ref
        .where("private", isEqualTo: false)
        .where("softDelete", isEqualTo: false)
        .limit(10)
        .snapshots();

    yield* data.map<List<CommunityModel>>((event) {
      List<CommunityModel> models = [];
      event.documents.forEach((element) {
        models.add(CommunityModel(element.data));
      });
      return models;
    });
  }

  static Future<List<CommunityModel>> getFeatureCommunitiesFuture() async {
    var data = await _ref
        .where("private", isEqualTo: false)
        .where("softDelete", isEqualTo: false)
        .limit(10)
        .getDocuments();

    List<CommunityModel> models = [];
    data.documents.forEach((element) {
      CommunityModel model = CommunityModel(element.data);
      if (AppConfig.isTestCommunity != null && AppConfig.isTestCommunity) {
        if (model.testCommunity) models.add(model);
      } else {
        models.add(model);
      }
    });
    return models;
  }
}
