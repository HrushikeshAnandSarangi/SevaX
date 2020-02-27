import 'package:flutter/material.dart';
import 'package:sevaexchange/models/billing_plan_details.dart';
import 'package:sevaexchange/models/user_model.dart';

import '../billing_view.dart';

class BillingPlanCard extends StatelessWidget {
  final UserModel user;
  final BillingPlanDetailsModel billingDetails;
  const BillingPlanCard({Key key, this.billingDetails, this.user})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("co id ==>> ${user.currentCommunity}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(36),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "${billingDetails.planName}\n",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: "${billingDetails.planDescription}",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: "${billingDetails.currency}",
                        style: TextStyle(
                          fontSize: 36,
                        ),
                      ),
                      TextSpan(
                        text: "${billingDetails.price}",
                        style: TextStyle(
                          fontSize: 48,
                        ),
                      ),
                      TextSpan(text: "/${billingDetails.duration}"),
                    ],
                  ),
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    Text(
                      "${billingDetails.note1}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 4),
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
                Text(
                  "${billingDetails.note2}",
                  style: TextStyle(fontSize: 10),
                ),
                Spacer(),
                ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Text(billingDetails.freeTransaction[index]);
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: billingDetails.freeTransaction.length,
                ),
                Spacer(),
                FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.black,
                  child: Text('Choose'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BillingView(
                          user.currentCommunity,
                          billingDetails.id,
                          user: user,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(context) {
    // flutter defined function
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
                return Text(billingDetails.billableTransaction[index]);
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: billingDetails.billableTransaction.length,
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
}
