import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

AlertDialog requestDonationAcknowledgementDialog(BuildContext context) {
  return AlertDialog(
    title: Text(S.of(context).enter_the_amount_received),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          decoration: InputDecoration(
              // border: OutlineInputBorder(),
              // focusedBorder: OutlineInputBorder(),
              // enabledBorder: OutlineInputBorder(),
              ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomElevatedButton(
              child: Text(S.of(context).ack),
              onPressed: () {},
            ),
            CustomElevatedButton(
              color: Colors.red,
              child: Text(S.of(context).cancel),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        )
      ],
    ),
  );
}
