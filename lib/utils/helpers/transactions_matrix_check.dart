import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/upgrade_plan_banners/pages/upgrade_plan_banner.dart';

import '../app_config.dart';

class TransactionsMatrixCheck extends StatelessWidget {
  final Widget child;
  String transaction_matrix_type;
  Map<String, dynamic> paymentStatusMap;
  bool allowTransaction;

  TransactionsMatrixCheck({
    Key key,
    @required this.child,
    this.transaction_matrix_type,
    this.paymentStatusMap,
    this.allowTransaction,
  });

  //this widget checks wether this plan allows a particular transaction to be done or not

  @override
  Widget build(BuildContext context) {
    paymentStatusMap = AppConfig.paymentStatusMap;
    Map<String, dynamic> plan_transactions_matrix =
        AppConfig.plan_transactions_matrix;
    Map<String, dynamic> matrix_current_plan =
        plan_transactions_matrix[paymentStatusMap['planId']];
    allowTransaction = matrix_current_plan[transaction_matrix_type]['allow'];

    return allowTransaction
        ? child
        : GestureDetector(
            onTap: () {
              UpgradePlanBanner(
                activePlanName: paymentStatusMap['planId'],
                details: AppConfig.upgradePlanBannerModel.calendar_sync,
                isCommunityPrivate: false,
              );
            },
            child: AbsorbPointer(absorbing: true, child: child),
          );
  }
}
