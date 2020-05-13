import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/billing_plan_details.dart';
import 'package:sevaexchange/models/user_model.dart';

import '../../../../main_app.dart';
import '../billing_view.dart';

class BillingPlanCard extends StatelessWidget {
  final bool isSelected;
  final bool isPlanActive;
  final UserModel user;
  final BillingPlanDetailsModel plan;
  const BillingPlanCard({
    Key key,
    this.plan,
    this.user,
    this.isSelected = false,
    this.isPlanActive = false,
  }) : super(key: key);
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
                        "Click here for more info",
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
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: textColor,
                  child: Text(
                    isPlanActive
                        ? isSelected ? 'Currently Active' : 'Change'
                        : 'Choose',
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
                      if (plan.id == "community_plan") {
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
          title: new Text("Billable transactions"),
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
            new FlatButton(
              child: new Text("Close"),
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
          title: new Text("Plan change"),
          content: Container(
            child: Text('Please contact SevaX support to change the plans'),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
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
              "message": "You are on Community Plan"
            }
          },
        ).then((_) {
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context1) => MainApplication(
                  skipToHomePage: true,
                ),
              ),
              (Route<dynamic> route) => false);
        }).catchError((e) => print(e));
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Taking you to your new Timebank..."),
              // Text('It may take couple of minutes to synchronize your payment'),
            ],
          ),
        );
      },
    );
  }
}
