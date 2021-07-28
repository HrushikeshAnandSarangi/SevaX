import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

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
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 15,
                ),
                child: CustomTextButton(
                  shape: StadiumBorder(),
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
                  color: Theme.of(context).accentColor,
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
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).accentColor,
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
        ) ??
        false;
  }
}
