import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';

void timeEndWarning(context, Duration duration) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(
            "You can't perform action before the offer ends.\n\nTime left ${duration.inHours}hrs"),
        actions: <Widget>[
          FlatButton(
            child: Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void requestAgainDialog(context, DocumentReference ref) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // title:  Text("Action Denied!"),
        content: Text(
          "Are you sure you want to request for credits again?",
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("REQUEST"),
            onPressed: () {
              ref.updateData({
                "status": ParticipantStatus.CREATOR_REQUESTED_CREDITS
                    .toString()
                    .split('.')[1]
              }).then((_) {
                Navigator.of(context).pop();
              }).catchError((e) => throw (e));
            },
          ),
          FlatButton(
            child: Text("Close"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
