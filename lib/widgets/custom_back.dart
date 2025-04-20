import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onBackPressed;

  CustomBackButton({required this.onBackPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 5, bottom: 5.0),
      child: TextButton.icon(
        icon: Icon(Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.secondary),
        onPressed: onBackPressed,
        label: Text(
          S.of(context).go_back,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
