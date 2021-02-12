import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/new_baseline/models/join_request_model.dart';
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
  }) {
    WriteBatch batch = Firestore.instance.batch();
    var joinRequestReference =
        Firestore.instance.collection('join_requests').document(joinRequestId);

    var timebankNotificationReference = Firestore.instance
        .collection('timebanknew')
        .document(timebankId)
        .collection("notifications")
        .document(notificaitonId);

    batch.updateData(
        joinRequestReference, {'operation_taken': true, 'accepted': false});

    batch.updateData(timebankNotificationReference, {'isRead': true});

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

    batch.updateData(joinRequestReference, {'operation_taken': true, 'accepted': true});

    batch.updateData(timebankNotificationReference, {'isRead': true});

    return batch.commit();
  }

  void dispose() {
    _joinRequests.close();
  }
}
