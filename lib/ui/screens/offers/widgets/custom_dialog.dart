import 'package:flutter/material.dart';

void errorDialog({BuildContext context, String error}) {
  showDialog(
    context: context,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(error),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
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
