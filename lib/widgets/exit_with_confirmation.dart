import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class ExitWithConfirmation extends StatelessWidget {
  final Widget child;

  const ExitWithConfirmation({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitDialog(context),
      child: child,
    );
  }

  Future<bool> showExitDialog(BuildContext context) {
    return showDialog(
          context: context,
          builder: (_context) => AlertDialog(
            title: Text(
              S.of(context).cancel_editing_confirmation,
            ),
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
}
