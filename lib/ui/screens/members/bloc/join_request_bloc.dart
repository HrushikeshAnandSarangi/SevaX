import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_exit_community_model.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
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
    String timebankId,
    String joinRequestId,
    String notificaitonId,
    String communityId,
    String memberFullName,
    String memberPhotoUrl,
    String adminEmail,
    String adminId,
    String adminFullName,
    String adminPhotoUrl,
    String timebankTitle,
    String memberEmail,
    String memberId,
    TimebankModel timebankModel,
  }) {
    log('REJECT COMES HERE!');

    WriteBatch batch = Firestore.instance.batch();
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    var entryExitLogReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection('entryExitLogs')
        .document();

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    batch.setData(entryExitLogReference, {
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
    String timebankId,
    String memberJoiningSevaUserId,
    String joinRequestId,
    String communityId,
    String newMemberJoinedEmail,
    String notificaitonId,
    bool isFromGroup,
    String memberFullName,
    String memberPhotoUrl,
    String adminEmail,
    String adminId,
    String adminFullName,
    String adminPhotoUrl,
    String timebankTitle,
    TimebankModel timebankModel,
  }) {
    WriteBatch batch = Firestore.instance.batch();
    var timebankRef =
        Firestore.instance.collection('timebanknew').document(timebankId);
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var newMemberDocumentReference =
        Firestore.instance.collection('users').document(newMemberJoinedEmail);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    var entryExitLogReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection('entryExitLogs')
        .document();

    batch.updateData(timebankRef, {
      'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
    });

    if (!isFromGroup) {
      batch.updateData(newMemberDocumentReference, {
        'communities': FieldValue.arrayUnion([communityId]),
        'currentCommunity': communityId
      });

      var addToCommunityRef =
          Firestore.instance.collection('communities').document(communityId);
      batch.updateData(addToCommunityRef, {
        'members': FieldValue.arrayUnion([memberJoiningSevaUserId]),
      });
    }

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    batch.setData(entryExitLogReference, {
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
