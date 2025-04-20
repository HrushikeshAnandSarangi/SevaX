import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CustomDialogs {
  static Future<bool> generalConfirmationDialogWithMessage(
    BuildContext context,
    String title,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (_context) => AlertDialog(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
            ),
            child: CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Colors.grey,
              onPressed: () {
                Navigator.of(_context).pop(false);
              },
              child: Text(
                S.of(context).no,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Europa',
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
              right: 15,
            ),
            child: CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.of(_context).pop(true);
              },
              child: Text(
                S.of(context).yes,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Europa',
                ),
              ),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  /// return true when close button is pressed
  static Future<bool> generalDialogWithCloseButton(
    BuildContext context,
    String title,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (_context) => AlertDialog(
        title: Text(title),
        actions: [
          CustomTextButton(
            shape: StadiumBorder(),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              Navigator.of(_context).pop(true);
            },
            child: Text(
              S.of(context).close,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Europa',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
