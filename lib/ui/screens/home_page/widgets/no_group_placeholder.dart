import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';

class NoGroupPlaceHolder extends StatelessWidget {
  final Function navigateToCreateGroup;

  const NoGroupPlaceHolder({Key key, this.navigateToCreateGroup})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'lib/assets/images/group_icon.png',
            color: Theme.of(context).primaryColor,
            width: 30,
            height: 30,
          ),
          SizedBox(height: 5),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  text: S.of(context).no_group_message,
                ),
                TextSpan(
                    text: S.of(context).creating_one,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = navigateToCreateGroup),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
