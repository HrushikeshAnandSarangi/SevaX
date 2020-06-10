import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/billing_plan_details.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';
import 'package:sevaexchange/widgets/NoGlowScrollBehavior.dart';

class BillingPlanDetails extends StatefulWidget {
  final bool autoImplyLeading;
  final UserModel user;
  final bool isPlanActive;
  final bool isPrivateTimebank;
  final String planName;

  const BillingPlanDetails(
      {Key key,
      this.user,
      this.isPlanActive,
      this.planName,
      this.autoImplyLeading = false,
      this.isPrivateTimebank})
      : super(key: key);
  @override
  _BillingPlanDetailsState createState() => _BillingPlanDetailsState();
}

class _BillingPlanDetailsState extends State<BillingPlanDetails> {
  List<BillingPlanDetailsModel> _billingPlanDetailsModels;

  void getPlanData(context) {
    // final RemoteConfig remoteConfig = await RemoteConfig.instance;
    // await remoteConfig.fetch(expiration: Duration.zero);
    // await remoteConfig.activateFetched();
    // print("====> ${AppConfig.remoteConfig.getString("billing_plans")}");
    _billingPlanDetailsModels = billingPlanDetailsModelFromJson(
      AppConfig.remoteConfig.getString(AppLocalizations.of(context)
          .translate('billing_plans', 'remote_config')),
    );
    if (widget.isPrivateTimebank) {
      _billingPlanDetailsModels
          .removeWhere((element) => element.planName == 'Community Plan');
    } else {
      _billingPlanDetailsModels
          .removeWhere((element) => element.planName == 'Tall Plan');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => getPlanData(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('billing_plans', 'title'),
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: !widget.isPlanActive,
        automaticallyImplyLeading: widget.autoImplyLeading,
      ),
      body: _billingPlanDetailsModels == null ||
              _billingPlanDetailsModels.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _billingPlanDetailsModels.length,
                      itemBuilder: (context, index) {
                        return Offstage(
                          offstage: _billingPlanDetailsModels[index].hidden,
                          child: BillingPlanCard(
                            plan: _billingPlanDetailsModels[index],
                            user: widget.user,
                            isSelected: _billingPlanDetailsModels[index].id ==
                                widget.planName,
                            isPlanActive: widget.isPlanActive,
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
