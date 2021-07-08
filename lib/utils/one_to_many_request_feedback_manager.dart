import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

WriteBatch batch = CollectionRef.batch;

Future<void> sendFeedbackNotificationsToAttendees(
    {@required List attendeesList,
    @required RequestModel requestModel,
    @required BuildContext context}) async {
  // ONETOMANY_REQUEST_ATTENDEES_FEEDBACK
// if(requestModel.oneToManyRequestAttenders)
  for (var attendee in attendeesList) {
    NotificationsModel notification = NotificationsModel(
        id: Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: requestModel.toMap(),
        isRead: false,
        isTimebankNotification: false,
        type: NotificationType.ONETOMANY_REQUEST_ATTENDEES_FEEDBACK,
        communityId: requestModel.communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: attendee['sevaUserID']);

    batch.set(
        CollectionRef.users
            .doc(attendee['email'])
            .collection("notifications")
            .doc(notification.id),
        notification.toMap());
  }

  batch.commit();

  logger.e('Feedback Notifications sent to one to many request Attendees');
}
