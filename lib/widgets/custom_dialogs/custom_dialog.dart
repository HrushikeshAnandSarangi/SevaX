import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class CustomDialogs {
  static Future<bool> generalConfirmationDialogWithMessage(
    BuildContext context,
    String title,
  ) async {
    return showDialog(
          context: context,
          builder: (_context) => AlertDialog(
            title: Text(title),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(_context).pop(false);
                },
                child: Text(S.of(context).no),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(_context).pop(true);
                },
                child: Text(S.of(context).yes),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// return true when close button is pressed
  static Future<bool> generalDialogWithCloseButton(
    BuildContext context,
    String title,
  ) async {
    return showDialog(
          context: context,
          builder: (_context) => AlertDialog(
            title: Text(title),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(_context).pop(true);
                },
                child: Text(S.of(context).close),
              ),
            ],
          ),
        ) ??
        false;
  }
}
