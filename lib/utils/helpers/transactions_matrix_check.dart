import 'package:flutter/material.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/ui/screens/upgrade_plan_banners/pages/upgrade_plan_banner.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class TransactionsMatrixCheck extends StatelessWidget {
  final Widget child;
  final String transaction_matrix_type;
  final BannerDetails upgradeDetails;
  final ComingFrom comingFrom;
  final Function onNavigationStart;

  TransactionsMatrixCheck({
    Key key,
    @required this.child,
    this.transaction_matrix_type,
    @required this.upgradeDetails,
    this.comingFrom,
    this.onNavigationStart,
  });

  //this widget checks wether this plan allows a particular transaction to be done or not
  @override
  Widget build(BuildContext context) {
    return checkAllowedTransaction(transaction_matrix_type)
        ? child
        : GestureDetector(
            onTap: () {
              try {
                onNavigationStart();
              } catch (e) {
                logger.d("Failed to launch");
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => UpgradePlanBanner(
                    activePlanName: AppConfig.paymentStatusMap['planId'],
                    details: upgradeDetails,
                  ),
                ),
              );
            },
            child: AbsorbPointer(
              absorbing: true,
              child: child,
            ),
          );
  }

  static bool checkAllowedTransaction(String transaction_matrix_type) {
    Map<String, dynamic> matrix_current_plan = AppConfig
        .plan_transactions_matrix[AppConfig.paymentStatusMap['planId']];
    return matrix_current_plan?.containsKey(transaction_matrix_type) ?? false
        ? matrix_current_plan[transaction_matrix_type]['allow']
        : true;
  }
}

enum ComingFrom {
  Requests,
  Projects,
  Offers,
  Chats,
  Groups,
  Settings,
  Members,
  Profile,
  Elasticsearch,
  Billing,
  Home,
  Community
}
