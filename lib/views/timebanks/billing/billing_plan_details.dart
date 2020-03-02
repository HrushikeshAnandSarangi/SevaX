import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sevaexchange/models/billing_plan_details.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';

class BillingPlanDetails extends StatefulWidget {
  final UserModel user;

  const BillingPlanDetails({Key key, this.user}) : super(key: key);
  @override
  _BillingPlanDetailsState createState() => _BillingPlanDetailsState();
}

class _BillingPlanDetailsState extends State<BillingPlanDetails> {
  List<BillingPlanDetailsModel> plans = [];

  void getPlanData() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: Duration.zero);
    await remoteConfig.activateFetched();
    plans = billingPlanDetailsModelFromJson(
      remoteConfig.getString("billing_plan_details"),
    );
    setState(() {});
  }

  @override
  void initState() {
    getPlanData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: plans.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    "Choose a suitable plan",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return BillingPlanCard(
                        billingDetails: plans[index],
                        user: widget.user,
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
