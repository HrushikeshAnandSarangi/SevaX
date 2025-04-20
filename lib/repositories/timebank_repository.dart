import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class TimebankRepository {
  static final CollectionReference _ref = CollectionRef.timebank;

  static Future<List<TimebankModel>> getChildCommunities(
      String timebankId) async {
    var data = await _ref
        .where('associatedParentTimebankId', isEqualTo: timebankId)
        .get();

    logger.i('Number of docs: ${data.docs.length}, TimebankId: $timebankId');

    List<TimebankModel> models = [];
    data.docs.forEach(
      (element) {
        var model =
            TimebankModel.fromMap(element.data() as Map<String, dynamic>);
        // if (!(model.softDelete ?? false)) {
        models.add(model);
        // }
      },
    );

    return models;
  }

  static Future<List<TimebankModel>> getTimebanksWhichUserIsPartOf(
    String userId,
    String communityId,
  ) async {
    List<TimebankModel> timebanks = [];
    QuerySnapshot querySnapshot = await _ref
        .where("community_id", isEqualTo: communityId)
        .where("members", arrayContains: userId)
        .where("softDelete", isEqualTo: false)
        .get();

    querySnapshot.docs.forEach((DocumentSnapshot document) {
      timebanks
          .add(TimebankModel.fromMap(document.data() as Map<String, dynamic>));
    });
    return timebanks;
  }

  Stream<List<TimebankModel>> getAllTimebanksOfCommunity(
      String communityId) async* {
    var data = _ref.where("community_id", isEqualTo: communityId).snapshots();
    yield* data.transform(
      StreamTransformer<QuerySnapshot, List<TimebankModel>>.fromHandlers(
        handleData: (data, sink) {
          List<TimebankModel> timebanks = [];
          try {
            data.docs.forEach((element) {
              var timebank =
                  TimebankModel.fromMap(element.data() as Map<String, dynamic>);
              timebanks.add(timebank);
            });
            sink.add(timebanks);
          } catch (e) {
            sink.addError(e);
            logger.e(sink);
          }
        },
      ),
    );
  }

  static Stream<List<TimebankModel>> getAllTimebanksUserIsAdminOf(
      String userId, String communityId) {
    return CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot,
        List<TimebankModel>>(
      //use single stream
      //fetch all timebanks of community
      _ref
          .where("community_id", isEqualTo: communityId)
          .where("admins", arrayContains: userId)
          .snapshots(),
      _ref
          .where("community_id", isEqualTo: communityId)
          .where("organizers", arrayContains: userId)
          .snapshots(),
      (a, b) {
        List<TimebankModel> _timebanks = [];
        a.docs.forEach((element) {
          _timebanks.add(
              TimebankModel.fromMap(element.data() as Map<String, dynamic>));
        });
        b.docs.forEach((element) {
          _timebanks.add(
              TimebankModel.fromMap(element.data() as Map<String, dynamic>));
        });

        return _timebanks;
      },
    );
  }

  static Stream<TimebankModel> getTimebankStream(String timebankId) async* {
    var data = _ref.doc(timebankId).snapshots();

    yield* data.transform(
      StreamTransformer.fromHandlers(
        handleData: (document, sink) {
          try {
            sink.add(
                TimebankModel.fromMap(document.data() as Map<String, dynamic>));
          } catch (e) {
            logger.e(e);
            sink.addError(e);
          }
          ;
        },
      ),
    );
  }

  Stream<List<JoinRequestModel>> getJoinRequestsCretedByUserStream({
    required String userID,
  }) async* {
    var query = CollectionRef.joinRequests
        .where('user_id', isEqualTo: userID)
        .snapshots();

    yield* query.transform(
        StreamTransformer<QuerySnapshot, List<JoinRequestModel>>.fromHandlers(
            handleData: (data, sink) {
      List<JoinRequestModel> joinRequests = [];
      try {
        data.docs.forEach((element) {
          JoinRequestModel joinRequest =
              JoinRequestModel.fromMap(element.data() as Map<String, dynamic>);
          if (joinRequest.userId == userID) {
            joinRequests.add(joinRequest);
          }
        });
        sink.add(joinRequests);
      } catch (e) {
        sink.addError(e);
      }
    }));
  }

  // static Stream<QuerySnapshot> getAllTimebanksUserIsAdminOf(
  //     String userId, String communityId) {
  //   return _ref
  //       .where("community_id", isEqualTo: communityId)
  //       .where("admins", arrayContains: userId)
  //       .snapshots();
  // }
}
