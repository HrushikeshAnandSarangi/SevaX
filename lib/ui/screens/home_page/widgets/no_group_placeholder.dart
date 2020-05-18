import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

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
                  text:
                  AppLocalizations.of(context).translate('groups','no_groups_helptext'),
                ),
                TextSpan(
                    text: AppLocalizations.of(context).translate('groups','create_one'),
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
