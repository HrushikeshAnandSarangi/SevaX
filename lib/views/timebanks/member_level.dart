import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';

import '../../flavor_config.dart';

class MembershipManager {
  static Future<bool> updateMembershipStatus({
    required String communityId,
    required String timebankId,
    required String timebankName,
    required String targetUserId,
    required String parentTimebankId,
    required String userEmail,
    required String associatedName,
    required NotificationType notificationType,
  }) async {
    var batch = CollectionRef.batch;
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
        batch.update(
          CollectionRef.communities.doc(communityId),
          {
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        batch.update(
          CollectionRef.timebank.doc(timebankId),
          {
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        break;

      case NotificationType.MEMBER_DEMOTED_FROM_ADMIN:
        batch.update(
          CollectionRef.communities.doc(communityId),
          {
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        batch.update(
          CollectionRef.timebank.doc(timebankId),
          {
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        break;

      default:
    }
    batch.set(
      CollectionRef.users
          .doc(userEmail)
          .collection('notifications')
          .doc(notification.id),
      notification.toMap(),
    );
    return await batch.commit().then((value) => true).catchError((onError) {
      return false;
    });
  }

  static Future<bool> updateOrganizerStatus({
    required String communityId,
    required String timebankId,
    required String timebankName,
    required String targetUserId,
    required String parentTimebankId,
    required String userEmail,
    required String associatedName,
    required NotificationType notificationType,
  }) async {
    var batch = CollectionRef.batch;
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

        batch.update(
          CollectionRef.communities.doc(communityId),
          {
            'organizers': FieldValue.arrayUnion([targetUserId]),
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        batch.update(
          CollectionRef.timebank.doc(timebankId),
          {
            'organizers': FieldValue.arrayUnion([targetUserId]),
            'admins': FieldValue.arrayRemove([targetUserId])
          },
        );

        break;

      case NotificationType.ADMIN_DEMOTED_FROM_ORGANIZER:
        log('inside demote');

        batch.update(
          CollectionRef.communities.doc(communityId),
          {
            'organizers': FieldValue.arrayRemove([targetUserId]),
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        batch.update(
          CollectionRef.timebank.doc(timebankId),
          {
            'organizers': FieldValue.arrayRemove([targetUserId]),
            'admins': FieldValue.arrayUnion([targetUserId])
          },
        );

        break;

      default:
    }
    batch.set(
      CollectionRef.users
          .doc(userEmail)
          .collection('notifications')
          .doc(notification.id),
      notification.toMap(),
    );
    return await batch.commit().then((value) => true).catchError((onError) {
      return false;
    });
  }
}
