import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class CustomBackButton extends StatelessWidget {
  final Function onBackPressed;

  CustomBackButton({this.onBackPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 5, bottom: 5.0),
      child: FlatButton.icon(
        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).accentColor),
        onPressed: onBackPressed,
        label: Text(
         S.of(context).go_back,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
