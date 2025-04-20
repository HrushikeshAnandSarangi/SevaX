import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';

class CommonHelpIconWidget extends StatelessWidget {
  const CommonHelpIconWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TimebankModel>(
      stream: Provider.of<HomePageBaseBloc>(context).currentTimebank,
      builder: (context, snapshot) {
        bool isAdmin = false;
        if (snapshot.data != null) {
          isAdmin = isAccessAvailable(
            snapshot.data!,
            SevaCore.of(context).loggedInUser.sevaUserID ?? '',
          );
        }
        return Container(
          height: 40,
          width: 40,
          child: IconButton(
            icon: Image.asset(
              'lib/assets/images/help.png',
              color: Colors.white,
            ),
            onPressed: () {
              logger.wtf("isAdmin: $isAdmin");
              navigateToWebView(
                aboutMode: AboutMode(
                  title: S.of(context).help,
                  urlToHit: HelpIconContextClass.linkBuilder(
                    isAdmin: isAdmin,
                  ),
                ),
                context: context,
              );
            },
          ),
        );
      },
    );
  }
}
