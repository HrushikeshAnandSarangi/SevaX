import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ExitWithConfirmation extends StatelessWidget {
  final Widget child;
  final formKey = GlobalKey<FormState>();
  final Map<int, String> fieldValues = {};

  ExitWithConfirmation({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (fieldValues?.values
                ?.any((element) => element != null || element.isNotEmpty) ??
            false) {
          return showExitDialog(context);
        } else {
          return Future.value(true);
        }
      },
      child: child,
    );
  }

  Future<bool> showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_context) => AlertDialog(
        title: Text(
          S.of(context).cancel_editing_confirmation,
        ),
        actions: [
          CustomTextButton(
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
          CustomTextButton(
            shape: StadiumBorder(),
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
        ],
      ),
    ).then((value) => value ?? false);
  }

  static ExitWithConfirmation of(BuildContext context) {
    final ExitWithConfirmation provider =
        context.findAncestorWidgetOfExactType<ExitWithConfirmation>()!;
    return provider;
  }
}
