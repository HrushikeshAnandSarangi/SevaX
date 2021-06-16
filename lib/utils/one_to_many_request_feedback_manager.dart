import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/views/core.dart';

Future<void> sendFeedbackNotificationsToAttendees(
    {@required RequestModel requestModel,
    @required BuildContext context}) async {
  // ONETOMANY_REQUEST_ATTENDEES_FEEDBACK
// if(requestModel.oneToManyRequestAttenders)
  for (var attendee in requestModel.oneToManyRequestAttenders) {
    NotificationsModel notification = NotificationsModel(
        id: Utils.getUuid(),
        timebankId: FlavorConfig.values.timebankId,
        data: requestModel.toMap(),
        isRead: false,
        isTimebankNotification: false,
        type: NotificationType.ONETOMANY_REQUEST_ATTENDEES_FEEDBACK,
        communityId: requestModel.communityId,
        senderUserId: SevaCore.of(context).loggedInUser.sevaUserID,
        targetUserId: requestModel.selectedInstructor.sevaUserID);

    await Firestore.instance
        .collection('users')
        .document(requestModel.selectedInstructor.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());
  }
}
