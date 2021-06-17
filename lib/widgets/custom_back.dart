import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CustomBackButton extends StatelessWidget {
  final Function onBackPressed;

  CustomBackButton({this.onBackPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(top: 5, bottom: 5.0),
      child: CustomTextButton.icon(
        icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).accentColor),
        onPressed: onBackPressed,
        label: Text(
          'Go Back',
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
