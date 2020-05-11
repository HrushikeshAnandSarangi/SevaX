import 'package:flutter/material.dart';

Future<void> errorDialog({BuildContext context, String error}) async {
  await showDialog(
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
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      );
    },
  );
  return true;
}

Future<bool> confirmationDialog(
    {BuildContext context, String title, Function onConfirmed}) async {
  await showDialog(
    context: context,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(title),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.of(viewContext).pop();
            },
          ),
          FlatButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: onConfirmed != null
                ? () {
                    onConfirmed();
                    Navigator.of(viewContext).pop();
                  }
                : null,
          ),
        ],
      );
    },
  );
  return true;
}
