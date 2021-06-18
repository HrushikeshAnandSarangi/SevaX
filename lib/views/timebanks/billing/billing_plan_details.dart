// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/utils/log_printer/log_printer.dart';
// import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

// class BillingPlanDetails extends StatefulWidget {
//   final bool autoImplyLeading;
//   final UserModel user;
//   final bool isPlanActive;
//   final bool isPrivateTimebank;
//   final String activePlanId;
//   final bool isBillMe;

//   const BillingPlanDetails(
//       {Key key,
//       this.user,
//       this.isPlanActive,
//       this.activePlanId,
//       this.autoImplyLeading = false,
//       this.isPrivateTimebank,
//       this.isBillMe})
//       : super(key: key);
//   @override
//   _BillingPlanDetailsState createState() => _BillingPlanDetailsState();
// }

// class _BillingPlanDetailsState extends State<BillingPlanDetails> {
//   List<BillingPlanDetailsModel> _billingPlanDetailsModels;

//   void getPlanData(context) {
//     // final RemoteConfig remoteConfig = await RemoteConfig.instance;
//     // await remoteConfig.fetch(expiration: Duration.zero);
//     // await remoteConfig.activateFetched();
//     // print("====> ${AppConfig.remoteConfig.getString("billing_plans")}");
//     _billingPlanDetailsModels = billingPlanDetailsModelFromJson(
//       AppConfig.remoteConfig
//           .getString('billing_plans_${S.of(context).localeName}'),
//     );
//     if (widget.isPrivateTimebank) {
//       _billingPlanDetailsModels.removeWhere(
//           (element) => element.id == SevaBillingPlans.NEIGHBOUR_HOOD_PLAN);
//     }
//     setState(() {});
//   }

//   List<dynamic> billMeEmails = [];
//   @override
//   void initState() {
//     super.initState();
//     if (SchedulerBinding.instance.schedulerPhase ==
//         SchedulerPhase.persistentCallbacks) {
//       SchedulerBinding.instance
//           .addPostFrameCallback((_) => getPlanData(context));
//     }
//     try {
//       billMeEmails =
//           json.decode(AppConfig.remoteConfig.getString('bill_me_emails'));
//     } on Exception {
//       logger.e("Exception raised while getting user emials ");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           S.of(context).choose_suitable_plan,
//           style: TextStyle(fontSize: 20),
//         ),
//         centerTitle: !widget.isPlanActive,
//         automaticallyImplyLeading: widget.autoImplyLeading,
//       ),
//       body: _billingPlanDetailsModels == null ||
//               _billingPlanDetailsModels.isEmpty
//           ? LoadingIndicator()
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Container(
//                   height: MediaQuery.of(context).size.height - 200,
//                   child: ScrollConfiguration(
//                     behavior: NoGlowScrollBehavior(),
//                     child: ListView.builder(
//                       physics: BouncingScrollPhysics(),
//                       shrinkWrap: true,
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _billingPlanDetailsModels.length,
//                       itemBuilder: (context, index) {
//                         return Offstage(
//                           offstage: _billingPlanDetailsModels[index].hidden,
//                           child: BillingPlanCard(
//                             activePlanId: widget.activePlanId,
//                             billMeVisibility:
//                                 _billingPlanDetailsModels[index].billMeEnabled,
//                             plan: _billingPlanDetailsModels[index],
//                             user: widget.user,
//                             isSelected: _billingPlanDetailsModels[index].id ==
//                                 widget.activePlanId,
//                             isPlanActive: widget.isPlanActive,
//                             canBillMe: billMeEmails.contains(widget.user.email),
//                             isBillMe: widget.isBillMe ?? false,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 )
//               ],
//             ),
//     );
//   }
// }
