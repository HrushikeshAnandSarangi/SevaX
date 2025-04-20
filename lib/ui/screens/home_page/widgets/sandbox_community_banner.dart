import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class SandBoxBanner extends StatelessWidget {
  final String title;
  const SandBoxBanner({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.e("issandbox" + AppConfig.isTestCommunity.toString());
    return AppConfig.isTestCommunity
        ? Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
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
