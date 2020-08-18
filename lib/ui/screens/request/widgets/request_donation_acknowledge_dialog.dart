import 'package:flutter/material.dart';

AlertDialog requestDonationAcknowledgementDialog(BuildContext context) {
  return AlertDialog(
    title: Text("Enter the amount recieved"),
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
            RaisedButton(
              child: Text('Ack'),
              onPressed: () {},
            ),
            RaisedButton(
              color: Colors.red,
              child: Text('Cancel'),
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
