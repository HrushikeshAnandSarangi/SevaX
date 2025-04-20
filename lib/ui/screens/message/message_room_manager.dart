import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

enum ParticipantMode { ADDED, REMOVED }

class MessageRoomManager {
  static Future<void> addRemoveParticipant({
    String? communityId,
    String? timebankId,
    NotificationType? notificationType,
    String? messageRoomName,
    String? messageRoomImageUrl,
    String? participantId,
    ParticipantInfo? creatorDetails,
    BuildContext? context,
  }) async {
    NotificationsModel notification = NotificationsModel(
      communityId: communityId,
      id: utils.Utils.getUuid(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: creatorDetails!.id,
      targetUserId: participantId,
      type: notificationType,
      timebankId: timebankId,
      data: {
        'creatorDetails': creatorDetails.toMap(),
        'messageRoomName': messageRoomName,
        'messageRoomUrl': messageRoomImageUrl,
      },
    );
    if (context == null) {
      throw Exception('BuildContext is null');
    }
    final user = await Provider.of<MembersBloc>(
      context,
      listen: false,
    ).getMemberFromLocalData(userId: participantId);
    if (user == null) {
      throw Exception('UserModel is null');
    }
    log('email ${user.email}');
    await CollectionRef.users
        .doc(user.email)
        .collection('notifications')
        .doc(notification.id)
        .set(notification.toMap())
        .catchError((onError) {
      // Handle error if needed
    });
  }

  static Future<void> addRemoveCommunityChatParticipant({
    String? communityId,
    String? timebankId,
    NotificationType? notificationType,
    String? messageRoomName,
    String? messageRoomImageUrl,
    String? participantId,
    ParticipantInfo? creatorDetails,
    BuildContext? context,
  }) async {
    if (participantId == null) {
      throw Exception('participantId is null');
    }
    NotificationsModel notification = NotificationsModel(
      communityId: communityId,
      id: utils.Utils.getUuid(),
      isRead: false,
      isTimebankNotification: true,
      senderUserId: creatorDetails!.id,
      targetUserId: participantId,
      type: notificationType,
      timebankId: timebankId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      data: {
        'creatorDetails': creatorDetails.toMap(),
        'messageRoomName': messageRoomName,
        'messageRoomUrl': messageRoomImageUrl,
      },
    );

    await CollectionRef.timebankNotification(participantId)
        .doc(notification.id)
        .set(notification.toMap())
        .catchError((onError) {
      // Handle error if needed
    });
  }
}
