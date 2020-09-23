import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
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
  final controller = PageController(initialPage: 999);
  final _pageIndicator = BehaviorSubject<int>();
  Timer _timer;

  @override
  void initState() {
    if (widget.details.images.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
          await controller.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _pageIndicator.add(
            (controller.page).toInt() % widget.details.images.length,
          );
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageIndicator.close();
    super.dispose();
  }

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
                controller: controller,
                // itemCount: widget.details.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget
                        .details.images[index % widget.details.images.length],
                    // fit: BoxFit.cover,
                  );
                },
              ),
            ),
            StreamBuilder<int>(
                stream: _pageIndicator.stream,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.details.images.length,
                      (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 10,
                          width: 10,
                          color: index == (snapshot.data ?? 0)
                              ? Colors.grey
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  );
                }),
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
                      planName: widget.activePlanName,
                      isPlanActive: true,
                      autoImplyLeading: true,
                      isPrivateTimebank: widget.isCommunityPrivate ?? false,
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
