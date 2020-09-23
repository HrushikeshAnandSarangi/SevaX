import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';

class UpgradePlanBanner extends StatefulWidget {
  final BannerDetails details;
  final String activePlanName;
  final bool isCommunityPrivate;
  const UpgradePlanBanner({
    Key key,
    this.details,
    this.activePlanName,
    this.isCommunityPrivate,
  })  : assert(details != null),
        super(key: key);

  @override
  _UpgradePlanBannerState createState() => _UpgradePlanBannerState();
}

class _UpgradePlanBannerState extends State<UpgradePlanBanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Upgrade Plan',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  // WidgetSpan(
                  //   child: Icon(Icons.add),
                  // ),
                  TextSpan(
                    text: 'Upgrade your plan for ${widget.details.name}',
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: PageView.builder(
                itemCount: widget.details.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.details.images[index],
                    // fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Spacer(),
            Text(
              widget.details.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            Spacer(),
            RaisedButton(
              child: Text(
                'Upgrade Plan',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillingPlanDetails(
                      user: SevaCore.of(context).loggedInUser,
                      activePlanId: widget.activePlanName,
                      isPlanActive: true,
                      autoImplyLeading: true,
                      isPrivateTimebank: widget.isCommunityPrivate,
                    ),
                  ),
                );
              },
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
