import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
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
  final bool isBillMe;

  const BillingPlanCard(
      {Key key,
      this.plan,
      this.user,
      this.isSelected = false,
      this.isPlanActive = false,
      this.canBillMe,
      this.billMeVisibility,
      this.isBillMe})
      : super(key: key);

  @override
  _BillingPlanCardState createState() => _BillingPlanCardState();
}

class _BillingPlanCardState extends State<BillingPlanCard> {
  bool isBillMe;

  void initState() {
    super.initState();
    isBillMe = widget.isBillMe;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isSelected ? Colors.white : Colors.black;
    print("co id ==>> ${widget.user.currentCommunity} ${widget.isBillMe}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        child: Card(
          color:
              widget.isSelected ? Theme.of(context).primaryColor : Colors.white,
          elevation: 3, //widget.isSelected ? 5 : 2,
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
                        text: "${widget.plan.planName}\n",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "${widget.plan.planDescription}",
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
                      "${widget.plan.note1}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    SizedBox(width: 4),
                  ],
                ),
                Text(
                  "${widget.plan.note2}",
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
                SizedBox(height: 4),
                Offstage(
                  offstage: widget.plan.id == "community_plan",
                  child: Row(
                    children: <Widget>[
                      Text(
                        S.of(context).click_for_more_info,
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
                        widget.plan.freeTransaction[index],
                        style: TextStyle(color: textColor),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: widget.plan.freeTransaction.length,
                  ),
                ),
                SizedBox(height: 4),
                widget.billMeVisibility
                    ? Row(
                        children: <Widget>[
                          Text(
                            S.of(context).bill_me,
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              _showBillMeDialog(
                                  context, S.of(context).bill_me_info1);
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
                              if (widget.canBillMe) {
                                setState(() {
                                  isBillMe = value;
                                });
                              } else {
                                _showBillMeDialog(
                                  context,
                                  S.of(context).bill_me_info2,
                                );
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
                    widget.isPlanActive
                        ? widget.isSelected
                            ? S.of(context).currently_active
                            : S.of(context).change
                        : S.of(context).choose,
                    style: TextStyle(
                      color: widget.isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                    ),
                  ),
                  onPressed: () {
                    if (widget.isPlanActive) {
                      _changePlanAlert(context);
                    } else {
                      if (widget.plan.id ==
                              SevaBillingPlans.NEIGHBOUR_HOOD_PLAN ||
                          isBillMe) {
                        _planSuccessMessage(
                          context: context,
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BillingView(
                              widget.user.currentCommunity,
                              widget.plan.id,
                              user: widget.user,
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

    if (widget.plan.price == '0') {
      price.add('');
      price.add('FREE');
      price.add('');
    } else {
      price.add(widget.plan.currency);
      price.add(widget.plan.price);
      price.add("/${widget.plan.duration}");
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
          title: Text(S.of(context).billable_transactions),
          content: Container(
            height: 300,
            width: 300,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Text(widget.plan.billableTransaction[index]);
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: widget.plan.billableTransaction.length,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                S.of(context).ok,
              ),
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
          title: Text(S.of(context).billable_transactions),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).ok),
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
          title: Text(S.of(context).plan_change),
          content: Container(
            child: Text(S.of(context).contact_seva_to_change_plan),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(S.of(context).close),
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
            .document(widget.user.currentCommunity)
            .updateData(
          {
            "payment": {
              "payment_success": true,
              "planId": widget.plan.id,
              "message": isBillMe
                  ? widget.plan.planName
                  : "You are on neighbourhood plan"
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
              Text(S.of(context).taking_to_new_timebank),
              // Text('It may take couple of minutes to synchronize your payment'),
            ],
          ),
        );
      },
    );
  }
}

class SevaBillingPlans {
  static String NEIGHBOUR_HOOD_PLAN = 'neighbourhood_plan';
  static String COMMUNITY_PLAN = 'tall_plan';
  static String NON_PROFIT = 'grande_plan';
  static String ENTERPRISE = 'venti_plan';
}
