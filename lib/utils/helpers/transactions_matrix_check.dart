import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/ui/screens/upgrade_plan_banners/pages/upgrade_plan_banner.dart';

import '../app_config.dart';

class TransactionsMatrixCheck extends StatelessWidget {
  final Widget child;
  final String transaction_matrix_type;
  final BannerDetails upgradeDetails;

  TransactionsMatrixCheck({
    Key key,
    @required this.child,
    this.transaction_matrix_type,
    @required this.upgradeDetails,
    // this.paymentStatusMap,
    // this.allowTransaction,
  });

  //this widget checks wether this plan allows a particular transaction to be done or not
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> matrix_current_plan = AppConfig
        .plan_transactions_matrix[AppConfig.paymentStatusMap['planId']];
    bool allowTransaction =
        matrix_current_plan[transaction_matrix_type]['allow'];
    log("<><><><><><><><> $allowTransaction");

    // paymentStatusMap = ;
    // Map<String, dynamic> plan_transactions_matrix =
    //     AppConfig.plan_transactions_matrix;
    // Map<String, dynamic> matrix_current_plan =
    //     plan_transactions_matrix[paymentStatusMap['planId']];
    // allowTransaction = matrix_current_plan[transaction_matrix_type]['allow'];
    // log("<><><><><><><><> $allowTransaction");

    return allowTransaction
        ? child
        : GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => UpgradePlanBanner(
                    activePlanName: AppConfig.paymentStatusMap['planId'],
                    details: upgradeDetails,
                  ),
                ),
              );
              // _showDialog(context, matrix_current_plan['planName']);
            },
            child: AbsorbPointer(absorbing: true, child: child),
          );
  }

  // void _showDialog(context, String planName) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext _context) {
  //       return AlertDialog(
  //         contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         content: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 10),
  //               child: Icon(
  //                 Icons.warning,
  //                 color: Colors.red,
  //                 size: 30,
  //               ),
  //             ),
  //             Text(
  //               'This feature is not available for the $planName. Please upgrade your plan to access this feature.',
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(width: 10),
  //             FlatButton(
  //               color: Theme.of(context).accentColor,
  //               child: Text(
  //                 S.of(context).close,
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(_context).pop();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
}
