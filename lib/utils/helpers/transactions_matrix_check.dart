import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';
import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
import 'package:sevaexchange/views/core.dart';

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
      Map<String, dynamic> plan_transactions_matrix = json.decode(AppConfig.remoteConfig.getString('transactions_plans_matrix'));
      Map<String, dynamic> matrix_current_plan = plan_transactions_matrix[paymentStatusMap['planId']];
      allowTransaction = matrix_current_plan[transaction_matrix_type]['allow'];
      return GestureDetector(
          onTap: () {
              _showDialog(context, matrix_current_plan['planName']);
          },
          child: AbsorbPointer(
              absorbing: !allowTransaction,
              child: child,
          ),
      );
  }

  void _showDialog(context, String planName) {
      showDialog(
          context: context,
          builder: (BuildContext _context) {
              return AlertDialog(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 30,
                              ),
                          ),
                          Text('This feature is not available for the $planName. Please upgrade your plan to access this feature.', textAlign: TextAlign.center,),
                          SizedBox(width: 10),
                          FlatButton(
                              color: Theme.of(context).accentColor,
                              child: Text(
                                  S.of(context).close,
                                  style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                  Navigator.of(_context).pop();
                              },
                          ),
                      ],
                  ),
              );
          },
      );
  }

}

