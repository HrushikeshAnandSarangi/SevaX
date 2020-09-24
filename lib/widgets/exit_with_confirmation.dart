import 'package:flutter/material.dart';

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
                'Please confirm that you want to cancel editing. You will lose all changes if you confirm.'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(_context).pop(false);
                },
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(_context).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
