import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/join_request_repository.dart';

class JoinRequestBloc {
  final _joinRequests = BehaviorSubject<List<JoinRequestModel>>();

  Stream<List<JoinRequestModel>> get joinRequests => _joinRequests.stream;

  void init(String timebankId) {
    JoinRequestRepository.timebankJoinRequestStream(timebankId).listen((event) {
      _joinRequests.add(event);
    });
  }

  //TODO: move database operation to repository
  Future<void> rejectMemberJoinRequest({
    required String timebankId,
    required String joinRequestId,
    required String notificaitonId,
    required String communityId,
    required String memberFullName,
    required String memberPhotoUrl,
    required String adminEmail,
    required String adminId,
    required String adminFullName,
    required String adminPhotoUrl,
    required String timebankTitle,
    required String memberEmail,
    required String memberId,
    required TimebankModel timebankModel,
  }) {
    log('REJECT COMES HERE!');

    WriteBatch batch = CollectionRef.batch;
    var joinRequestReference = CollectionRef.joinRequests.doc(joinRequestId);

    var timebankNotificationReference = CollectionRef.timebank
        .doc(timebankId)
        .collection("notifications")
        .doc(notificaitonId);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankId)
        .collection('entryExitLogs')
        .doc();

    batch.update(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.update(timebankNotificationReference, {'isRead': true});

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.REJECTED_BY_ADMIN.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': memberEmail,
        'id': memberId,
        'fullName': memberFullName,
        'photoUrl': memberPhotoUrl,
      },
      'adminDetails': {
        'email': adminEmail,
        'id': adminId,
        'fullName': adminFullName,
        'photoUrl': adminPhotoUrl,
      },
      'associatedTimebankDetails': {
        'timebankId': timebankId,
        'timebankTitle': timebankTitle,
      },
    });

    log('REJECT ENDS HERE!');

    return batch.commit();
  }

  //TODO: move database operation to repository
  Future<void> addMemberToTimebank({
    required String timebankId,
    required String memberJoiningSevaUserId,
    required String joinRequestId,
    required String communityId,
    required String newMemberJoinedEmail,
    required String notificaitonId,
    required bool isFromGroup,
    required String memberFullName,
    required String memberPhotoUrl,
    required String adminEmail,
    required String adminId,
    required String adminFullName,
    required String adminPhotoUrl,
    required String timebankTitle,
    required TimebankModel timebankModel,
  }) {
    WriteBatch batch = CollectionRef.batch;
    var timebankRef = CollectionRef.timebank.doc(timebankId);
    var joinRequestReference = CollectionRef.joinRequests.doc(joinRequestId);

    var newMemberDocumentReference =
        CollectionRef.users.doc(newMemberJoinedEmail);

    var timebankNotificationReference = CollectionRef.timebank
        .doc(timebankId)
        .collection("notifications")
        .doc(notificaitonId);

    var entryExitLogReference = CollectionRef.timebank
        .doc(timebankId)
        .collection('entryExitLogs')
        .doc();

    batch.update(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.update(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
        'currentCommunity': communityId
      });

      var addToCommunityRef = CollectionRef.communities.doc(communityId);
      batch.update(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.update(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.update(timebankNotificationReference, {'isRead': true});

    batch.set(entryExitLogReference, {
      'mode': ExitJoinType.JOIN.readable,
      'modeType': JoinMode.APPROVED_BY_ADMIN.readable,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'communityId': communityId,
      'isGroup':
          timebankModel.parentTimebankId == FlavorConfig.values.timebankId
              ? false
              : true,
      'memberDetails': {
        'email': newMemberJoinedEmail,
        'id': memberJoiningSevaUserId,
        'fullName': memberFullName,
        'photoUrl': memberPhotoUrl,
      },
      'adminDetails': {
        'email': adminEmail,
        'id': adminId,
        'fullName': adminFullName,
        'photoUrl': adminPhotoUrl,
      },
      'associatedTimebankDetails': {
        'timebankId': timebankId,
        'timebankTitle': timebankTitle,
        'missionStatement': timebankModel.missionStatement,
      },
    });

    return batch.commit();
  }

  void dispose() {
    _joinRequests.close();
  }
}
