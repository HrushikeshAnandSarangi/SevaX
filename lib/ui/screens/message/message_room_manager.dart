import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/screens/members/bloc/members_bloc.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

enum ParticipantMode { ADDED, REMOVED }

class MessageRoomManager {
  static Future<void> addRemoveParticipant({
    String communityId,
    String timebankId,
    NotificationType notificationType,
    String messageRoomName,
    String messageRoomImageUrl,
    String participantId,
    ParticipantInfo creatorDetails,
    BuildContext context,
  }) async {
    NotificationsModel notification = NotificationsModel(
      communityId: communityId,
      id: utils.Utils.getUuid(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: creatorDetails.id,
      targetUserId: participantId,
      type: notificationType,
      timebankId: timebankId,
      data: {
        'creatorDetails': creatorDetails.toMap(),
        'messageRoomName': messageRoomName,
        'messageRoomUrl': messageRoomImageUrl,
      },
    );
    UserModel user = await Provider.of<MembersBloc>(
      context,
      listen: false,
    ).getMemberFromLocalData(userId: participantId);
    log('email ${user.email}');
    return await Firestore.instance
        .collection('users')
        .document(user.email)
        .collection('notifications')
        .document(notification.id)
        .setData(notification.toMap())
        .then((value) => true)
        .catchError((onError) {
      return false;
    });
  }
}
