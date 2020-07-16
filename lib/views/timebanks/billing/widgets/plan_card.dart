import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/billing_plan_details.dart';
import 'package:sevaexchange/models/user_model.dart';

import '../../../../flavor_config.dart';
import '../../../../main_app.dart';
import '../../../../main_seva_dev.dart' as dev;
import '../billing_view.dart';

class BillingPlanCard extends StatefulWidget {
  final bool isSelected;
  final bool isPlanActive;
  final UserModel user;
  final BillingPlanDetailsModel plan;
  final bool canBillMe;
  final bool billMeVisibility;
  const BillingPlanCard({
    Key key,
    this.plan,
    this.user,
    this.isSelected = false,
    this.isPlanActive = false,
    this.canBillMe,
    this.billMeVisibility,
  }) : super(key: key);

  @override
  BillingPlanCardState createState() {
    return BillingPlanCardState(
        user: user,
        billMeVisibility: billMeVisibility,
        canBillMe: canBillMe,
        isPlanActive: isPlanActive,
        isSelected: isSelected,
        plan: plan);
  }
}

// the form.
class BillingPlanCardState extends State<BillingPlanCard> {
  final bool isSelected;
  final bool isPlanActive;
  final UserModel user;
  final BillingPlanDetailsModel plan;
  final bool canBillMe;
  final bool billMeVisibility;
  bool isBillMe = false;

  BillingPlanCardState(
      {this.isSelected,
      this.isPlanActive,
      this.user,
      this.plan,
      this.canBillMe,
      this.billMeVisibility});

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? Colors.white : Colors.black;
    print("co id ==>> ${user.currentCommunity}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        child: Card(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          elevation: 3, //isSelected ? 5 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(color: textColor),
                    children: [
                      TextSpan(
                        text: "${plan.planName}\n",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "${plan.planDescription}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                planPriceBuilder(textColor),
                Spacer(),
                Row(
                  children: <Widget>[
                    Text(
                      "${plan.note1}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    SizedBox(width: 4),
                  ],
                ),
                Text(
                  "${plan.note2}",
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
                SizedBox(height: 4),
                Offstage(
                  offstage: plan.id == "community_plan",
                  child: Row(
                    children: <Widget>[
                      Text(
                        AppLocalizations.of(context)
                            .translate('billing_plans', 'info_click'),
                        style: TextStyle(fontSize: 10, color: textColor),
                      ),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          _showDialog(context);
                        },
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          child: Text(
                            "i",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 8,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Text(
                        plan.freeTransaction[index],
                        style: TextStyle(color: textColor),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: plan.freeTransaction.length,
                  ),
                ),
                SizedBox(height: 4),
                billMeVisibility
                    ? Row(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context)
                                .translate('billing_plans', 'bill_me'),
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              _showBillMeDialog(
                                  context,
                                  AppLocalizations.of(context).translate(
                                      'billing_plans', 'bill_me_info'));
                            },
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              child: Text(
                                "i",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          Checkbox(
                            value: isBillMe,
                            onChanged: (value) {
                              if (canBillMe) {
                                setState(() {
                                  isBillMe = value;
                                });
                              } else {
                                _showBillMeDialog(
                                    context,
                                    AppLocalizations.of(context).translate(
                                        'billing_plans', 'bill_me_info_two'));
                              }
                            },
                          )
                        ],
                      )
                    : Offstage(),
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: textColor,
                  child: Text(
                    isPlanActive
                        ? isSelected
                            ? AppLocalizations.of(context)
                                .translate('billing_plans', 'active')
                            : AppLocalizations.of(context)
                                .translate('billing_plans', 'change')
                        : AppLocalizations.of(context)
                            .translate('billing_plans', 'choose'),
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                    ),
                  ),
                  onPressed:
                      // ? () {}
                      () {
                    if (isPlanActive) {
                      _changePlanAlert(context);
                    } else {
                      if (plan.id == "community_plan" || isBillMe == true) {
                        _planSuccessMessage(
                          context: context,
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BillingView(
                              user.currentCommunity,
                              plan.id,
                              user: user,
                              isFromChangeOwnership: false,
                            ),
                          ),
                        );
                      }
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  RichText planPriceBuilder(Color textColor) {
    List<String> price = [];

    if (plan.price == '0') {
      price.add('');
      price.add('FREE');
      price.add('');
    } else {
      price.add(plan.currency);
      price.add(plan.price);
      price.add("/${plan.duration}");
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: "${price[0]}",
            style: TextStyle(
              fontSize: 36,
            ),
          ),
          TextSpan(
            text: "${price[1]}",
            style: TextStyle(
              fontSize: 48,
            ),
          ),
          TextSpan(text: "${price[2]}"),
        ],
      ),
    );
  }

  void _showDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('billing_plans', 'billable_transactions')),
          content: Container(
            height: 300,
            width: 300,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Text(plan.billableTransaction[index]);
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: plan.billableTransaction.length,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                  AppLocalizations.of(context).translate('homepage', 'ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBillMeDialog(context, msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('billing_plans', 'billable_transactions')),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text(
                  AppLocalizations.of(context).translate('homepage', 'ok')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changePlanAlert(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)
              .translate('billing_plans', 'alert_title')),
          content: Container(
            child: Text(AppLocalizations.of(context)
                .translate('billing_plans', 'contact')),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context)
                  .translate('billing_plans', 'close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _planSuccessMessage({
    BuildContext context,
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Firestore.instance
            .collection("communities")
            .document(user.currentCommunity)
            .updateData(
          {
            "payment": {
              "payment_success": true,
              "planId": plan.id,
              "message": isBillMe
                  ? plan.planName
                  : AppLocalizations.of(context)
                      .translate('billing_admin', 'community_plan')
            },
            "billMe": isBillMe
          },
        ).then((_) {
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context1) => FlavorConfig.appFlavor == Flavor.APP
                    ? MainApplication()
                    : dev.MainApplication(),
              ),
              (Route<dynamic> route) => false);
        }).catchError((e) => print(e));
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)
                  .translate('billing_plans', 'progress')),
              // Text('It may take couple of minutes to synchronize your payment'),
            ],
          ),
        );
      },
    );
  }
}
