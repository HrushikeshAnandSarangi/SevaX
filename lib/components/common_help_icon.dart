import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';

class CommonHelpIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      child: IconButton(
        icon: Image.asset(
          'lib/assets/images/help.png',
          color: Colors.white,
        ),
        onPressed: () {
          navigateToWebView(
            aboutMode: AboutMode(
              title: S.of(context).help,
              urlToHit: HelpIconContextClass
                  .helpContextLinks[AppConfig.helpIconContext],
            ),
            context: context,
          );
        },
      ),
    );
  }
}

// Widget CommonHelpIconWidget()(BuildContext context) {
//   return Container(
//     height: 40,
//     width: 40,
//     child: IconButton(
//       icon: Image.asset(
//         'lib/assets/images/help.png',
//         color: Colors.white,
//       ),

//       //iconSize: 16,
//       onPressed: () {
//         // logger.i(
//         //     "hitting url ${HelpIconContextClass.helpContextLinks[AppConfig.helpIconContext]}");
//         navigateToWebView(
//           aboutMode: AboutMode(
//             // title: S.of(context).projects + ' ' + S.of(context).help,
//             urlToHit: HelpIconContextClass
//                 .helpContextLinks[AppConfig.helpIconContext],
//           ),
//           context: context,
//         );
//       },
//     ),
//   );
// }
