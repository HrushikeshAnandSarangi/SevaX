import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

void timeEndWarning(context, Duration duration) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(
          "${S.of(context).cant_perfrom_action_offer}.\n\n${S.of(context).time_left} ${duration.inHours}hrs",
        ),
        actions: <Widget>[
          CustomTextButton(
            child: Text(S.of(context).close),
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
        content: Text(
          S.of(context).request_credits_again,
        ),
        actions: <Widget>[
          CustomTextButton(
            child: Text(S.of(context).request.toUpperCase()),
            onPressed: () {
              ref.update({
                "status": ParticipantStatus.CREATOR_REQUESTED_CREDITS
                    .toString()
                    .split('.')[1]
              }).then((_) {
                Navigator.of(context).pop();
              }).catchError((e) => throw (e));
            },
          ),
          CustomTextButton(
            child: Text(S.of(context).close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
