import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
          CustomTextButton(
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
          CustomTextButton(
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
          CustomTextButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onPressed: onConfirmed != null
                ? () {
                    Navigator.of(viewContext).pop();

                    onConfirmed();
                  }
                : null,
          ),
        ],
      );
    },
  );
  return true;
}
