import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';

void showDialogForIncompleteTransactions({
  SoftDeleteRequestDataHolder deletionRequest,
  BuildContext context,
}) {
  var reason = " ";
  // "We couldn\'t process you request for deletion of ${deletionRequest.entityTitle}, as you are still having open transactions which are as : \n";
  if (deletionRequest.noOfOpenOffers > 0) {
    reason += '${deletionRequest.noOfOpenOffers} one to many offers\n';
  }
  if (deletionRequest.noOfOpenRequests > 0) {
    reason += '${deletionRequest.noOfOpenOffers} open requests\n';
  }

  showDialog(
    context: context,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        // title: Text(deletionRequest.entityTitle.trim()),
        content: Text(reason),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Dismiss",
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            onPressed: () {
              Navigator.of(viewContext).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> dismissTimebankNotification({
  String notificationId,
  String timebankId,
}) async {
  Firestore.instance
      .collection("timebanknew")
      .document(timebankId)
      .collection("notifications")
      .document(notificationId)
      .updateData(
    {"isRead": true},
  );
}

void _clearNotification(String timebankId, String notificationId) {}
