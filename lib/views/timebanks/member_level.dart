import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/notifications_model.dart';

import '../../flavor_config.dart';

class MembershipManager {
  static Future<bool> updateMembershipStatus({
    String communityId,
    String timebankId,
    String timebankName,
    String targetUserId,
    String parentTimebankId,
    String userEmail,
    String associatedName,
    NotificationType notificationType,
  }) async {
    var batch = Firestore.instance.batch();
    NotificationsModel notification = new NotificationsModel(
      communityId: communityId,
      id: Uuid().generateV4(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: timebankId,
      targetUserId: targetUserId,
      type: notificationType,
      timebankId: timebankId,
      data: {
        'associatedName': associatedName,
        'timebankName': timebankName,
        'isGroup': parentTimebankId != FlavorConfig.values.timebankId,
      },
    );
    switch (notificationType) {
      case NotificationType.MEMBER_PROMOTED_AS_ADMIN:
        batch.updateData(
          Firestore.instance.collection('communities').document(communityId),
          {
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        batch.updateData(
          Firestore.instance.collection('timebanknew').document(timebankId),
          {
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        break;

      case NotificationType.MEMBER_DEMOTED_FROM_ADMIN:
        batch.updateData(
          Firestore.instance.collection('communities').document(communityId),
          {
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        batch.updateData(
          Firestore.instance.collection('timebanknew').document(timebankId),
          {
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        break;

      default:
    }
    batch.setData(
      Firestore.instance
          .collection('users')
          .document(userEmail)
          .collection('notifications')
          .document(notification.id),
      notification.toMap(),
    );
    return await batch.commit().then((value) => true).catchError((onError) {
      return false;
    });
  }

  static Future<bool> updateOrganizerStatus({
    String communityId,
    String timebankId,
    String timebankName,
    String targetUserId,
    String parentTimebankId,
    String userEmail,
    String associatedName,
    NotificationType notificationType,
  }) async {
    var batch = Firestore.instance.batch();
    NotificationsModel notification = new NotificationsModel(
      communityId: communityId,
      id: Uuid().generateV4(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: timebankId,
      targetUserId: targetUserId,
      type: notificationType,
      timebankId: timebankId,
      data: {
        'associatedName': associatedName,
        'timebankName': timebankName,
        'isGroup': parentTimebankId != FlavorConfig.values.timebankId,
      },
    );
    switch (notificationType) {
      case NotificationType.ADMIN_PROMOTED_AS_ORGANIZER:
        log('inside promote');

        batch.updateData(
          Firestore.instance.collection('communities').document(communityId),
          {
            'organizers': FieldValue.arrayUnion([targetUserId]),
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        batch.updateData(
          Firestore.instance.collection('timebanknew').document(timebankId),
          {
            'organizers': FieldValue.arrayUnion([targetUserId]),
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        break;

      case NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER:
        log('inside demote');

        batch.updateData(
          Firestore.instance.collection('communities').document(communityId),
          {
            'organizers': FieldValue.arrayRemove([targetUserId]),
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        batch.updateData(
          Firestore.instance.collection('timebanknew').document(timebankId),
          {
            'organizers': FieldValue.arrayRemove([targetUserId]),
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        break;

      default:
    }
    batch.setData(
      Firestore.instance
          .collection('users')
          .document(userEmail)
          .collection('notifications')
          .document(notification.id),
      notification.toMap(),
    );
    return await batch.commit().then((value) => true).catchError((onError) {
      return false;
    });
  }
}
