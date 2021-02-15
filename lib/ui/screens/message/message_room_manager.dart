import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:usage/uuid/uuid.dart';

class MessageRoomManager {
  static Future<void> addRemoveParticipant({
    String communityId,
    String timebankId,
    NotificationType notificationType,
    String messageRoomName,
    String imageUrl,
    String participantId,
    ParticipantInfo creatorDetails,
  }) async {
    var batch = Firestore.instance.batch();
    NotificationsModel notification = new NotificationsModel(
      communityId: communityId,
      id: Uuid().generateV4(),
      isRead: false,
      isTimebankNotification: false,
      senderUserId: creatorDetails.id,
      targetUserId: participantId,
      type: notificationType,
      timebankId: timebankId,
      data: {
        'creatorDetails': creatorDetails,
        'messageRoomName': messageRoomName,
        'messageRoomUrl': imageUrl,
      },
    );
  }
}
