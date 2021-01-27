import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import '../flavor_config.dart';


Widget get CommonHelpIconWidget{
  return Container(
    height: 40,
    width: 40,
    child: IconButton(
      icon: Image.asset(
        'lib/assets/images/help.png',
      ),
      color: FlavorConfig.values.theme.primaryColor,
      //iconSize: 16,
      onPressed: (){
        logger.i("hitting url ${HelpIconContextClass.helpContextLinks[AppConfig.helpIconContext]}");
        // navigateToWebView(
        //   aboutMode: AboutMode(
        //       // title: S.of(context).projects + ' ' + S.of(context).help,
        //       urlToHit: HelpIconContextClass.helpContextLinks[AppConfig.helpIconContext]
        //   ),
        //   context: context,
        // );
      },
    ),
  );

}