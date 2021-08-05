import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';

class SendBoxBanner extends StatelessWidget {
  final String title;
  const SendBoxBanner({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppConfig.isTestCommunity
        ? Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Offstage(
            offstage: true,
          );
  }
}
