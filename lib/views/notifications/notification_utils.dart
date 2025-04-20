import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/soft_delete_request.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

void showDialogForIncompleteTransactions({
  SoftDeleteRequestDataHolder? deletionRequest,
  BuildContext? context,
}) {
  var reason = " ";
  // "We couldn\'t process you request for deletion of ${deletionRequest.entityTitle}, as you are still having open transactions which are as : \n";
  if (deletionRequest!.noOfOpenOffers! > 0) {
    reason += '${deletionRequest.noOfOpenOffers} one to many offers\n';
  }
  if (deletionRequest.noOfOpenRequests > 0) {
    reason += '${deletionRequest.noOfOpenOffers} open requests\n';
  }

  showDialog(
    context: context!,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        // title: Text(deletionRequest.entityTitle.trim()),
        content: Text(reason),
        actions: <Widget>[
          CustomTextButton(
            child: Text(
              S.of(context).dismiss,
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
  String? notificationId,
  String? timebankId,
}) async {
  CollectionRef.timebank
      .doc(timebankId)
      .collection("notifications")
      .doc(notificationId)
      .update(
    {"isRead": true},
  );
}

void _clearNotification(String timebankId, String notificationId) {}
