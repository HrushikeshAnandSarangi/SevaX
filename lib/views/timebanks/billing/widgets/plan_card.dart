// import 'dart:convert';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/views/core.dart';

// import '../../../../flavor_config.dart';
// import '../../../../main_app.dart';
// import '../../../../main_seva_dev.dart' as dev;
// import '../billing_view.dart';

// class BillingPlanCard extends StatefulWidget {
//   final String activePlanId;
//   final bool isSelected;
//   final bool isPlanActive;
//   final UserModel user;
//   final BillingPlanDetailsModel plan;
//   final bool canBillMe;
//   final bool billMeVisibility;
//   final bool isBillMe;

//   const BillingPlanCard({
//     Key key,
//     this.plan,
//     this.user,
//     this.isSelected = false,
//     this.isPlanActive = false,
//     this.canBillMe,
//     this.billMeVisibility,
//     this.activePlanId,
//     this.isBillMe,
//   }) : super(key: key);

//   @override
//   _BillingPlanCardState createState() => _BillingPlanCardState();
// }

// class _BillingPlanCardState extends State<BillingPlanCard> {
//   bool isBillMe;
// List<String> planIdArr = ["neighbourhood_plan","tall_plan","grande_plan","venti_plan"];
//   void initState() {
//     super.initState();
//     isBillMe = widget.isBillMe;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textColor = widget.isSelected ? Colors.white : Colors.black;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
//       child: Container(
//         width: MediaQuery.of(context).size.width - 90,
//         child: Card(
//           color:
//               widget.isSelected ? Theme.of(context).primaryColor : Colors.white,
//           elevation: 3, //widget.isSelected ? 5 : 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 RichText(
//                   overflow: TextOverflow.ellipsis,
//                   text: TextSpan(
//                     style: TextStyle(color: textColor),
//                     children: [
//                       TextSpan(
//                         text: "${widget.plan.planName}\n",
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                       TextSpan(
//                         text: "${widget.plan.planDescription}",
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Spacer(),
//                 planPriceBuilder(textColor),
//                 Spacer(),
//                 Row(
//                   children: <Widget>[
//                     Text(
//                       "${widget.plan.note1}",
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(fontSize: 16, color: textColor),
//                     ),
//                     SizedBox(width: 4),
//                   ],
//                 ),
//                 Text(
//                   "${widget.plan.note2}",
//                   style: TextStyle(fontSize: 10, color: textColor),
//                 ),
//                 SizedBox(height: 4),
//                 Offstage(
//                   offstage: widget.plan.id == "community_plan",
//                   child: Row(
//                     children: <Widget>[
//                       Text(
//                         S.of(context).click_for_more_info,
//                         style: TextStyle(fontSize: 10, color: textColor),
//                       ),
//                       SizedBox(width: 8),
//                       InkWell(
//                         onTap: () {
//                           _showDialog(context);
//                         },
//                         child: CircleAvatar(
//                           radius: 8,
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           child: Text(
//                             "i",
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Spacer(),
//                 Expanded(
//                   flex: 8,
//                   child: ListView.separated(
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       return Text(
//                         widget.plan.freeTransaction[index],
//                         style: TextStyle(color: textColor),
//                       );
//                     },
//                     separatorBuilder: (context, index) => Divider(),
//                     itemCount: widget.plan.freeTransaction.length,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 widget.billMeVisibility
//                     ? Row(
//                         children: <Widget>[
//                           Text(
//                             S.of(context).bill_me,
//                             style: TextStyle(fontSize: 14, color: textColor),
//                           ),
//                           SizedBox(width: 8),
//                           InkWell(
//                             onTap: () {
//                               _showBillMeDialog(
//                                   context, S.of(context).bill_me_info1);
//                             },
//                             child: CircleAvatar(
//                               radius: 8,
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               child: Text(
//                                 "i",
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                             ),
//                           ),
//                           Checkbox(
//                             value: isBillMe,
//                             onChanged: (value) {
//                               if (widget.canBillMe) {
//                                 setState(() {
//                                   isBillMe = value;
//                                 });
//                               } else {
//                                 _showBillMeDialog(
//                                   context,
//                                   S.of(context).bill_me_info2,
//                                 );
//                               }
//                             },
//                           )
//                         ],
//                       )
//                     : Offstage(),
//                 Spacer(),
//                 CustomTextButton(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   color: textColor,
//                   child: Text(
//                     widget.isPlanActive
//                         ? widget.isSelected
//                             ? S.of(context).currently_active
//                             : S.of(context).change
//                         : S.of(context).choose,
//                     style: TextStyle(
//                       color: widget.isSelected
//                           ? Theme.of(context).primaryColor
//                           : Colors.white,
//                     ),
//                   ),
//                   onPressed: () async {
//                     if (widget.activePlanId == widget.plan.id) {
//                       return;
//                     }
//                     if(widget.isPlanActive && widget.activePlanId != null && planIdArr.indexOf(widget.plan.id) < planIdArr.indexOf(widget.activePlanId)){
//                         cannotDowngradeMessage(context).then((_){
//                             Navigator.of(context).pop();
//                         });
//                     }
//                     else if (widget.isPlanActive && widget.activePlanId != null && widget.activePlanId != SevaBillingPlans.NEIGHBOUR_HOOD_PLAN) {
//                         _showPlanChangeConfirmationDialog(context);

//                     }
//                     else {
//                       if (widget.plan.id ==
//                               SevaBillingPlans.NEIGHBOUR_HOOD_PLAN ||
//                           isBillMe) {
//                         _planSuccessMessage(
//                           context: context,
//                         );
//                       } else {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) => BillingView(
//                               widget.user.currentCommunity,
//                               widget.plan.id,
//                               user: widget.user,
//                               isFromChangeOwnership: false,
//                             ),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   RichText planPriceBuilder(Color textColor) {
//     List<String> price = [];

//     if (widget.plan.price == '0') {
//       price.add('');
//       price.add('FREE');
//       price.add('');
//     } else {
//       price.add(widget.plan.currency);
//       price.add(widget.plan.price);
//       price.add("/${widget.plan.duration}");
//     }
//     return RichText(
//       text: TextSpan(
//         style: TextStyle(
//           color: textColor,
//           fontWeight: FontWeight.bold,
//         ),
//         children: [
//           TextSpan(
//             text: "${price[0]}",
//             style: TextStyle(
//               fontSize: 36,
//             ),
//           ),
//           TextSpan(
//             text: "${price[1]}",
//             style: TextStyle(
//               fontSize: 48,
//             ),
//           ),
//           TextSpan(text: "${price[2]}"),
//         ],
//       ),
//     );
//   }

//   void _showDialog(context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(S.of(context).bill_me),
//           content: Container(
//             height: 300,
//             width: 300,
//             child: ListView.separated(
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 return Text(widget.plan.billableTransaction[index]);
//               },
//               separatorBuilder: (context, index) => Divider(),
//               itemCount: widget.plan.billableTransaction.length,
//             ),
//           ),
//           actions: <Widget>[
//             CustomTextButton(
//               child: Text(
//                 S.of(context).ok,
//               ),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showPlanChangeConfirmationDialog(BuildContext parentContext) {
//       showDialog(
//           context: parentContext,
//           barrierDismissible: true,
//           builder: (_context) {
//               return AlertDialog(
//                   title: Text("Change plan confirmation"),
//                   content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                           Text("Are you sure you want to upgrade the plan ?"),
//                           SizedBox(
//                               height: 15,
//                           ),
//                           Row(
//                               children: <Widget>[
//                                   Spacer(),
//                                   CustomElevatedButton(
//                                       padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
//                                       color: Theme.of(context).accentColor,
//                                       textColor: FlavorConfig.values.buttonTextColor,
//                                       child: Text(
//                                           S.of(context).yes,
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: dialogButtonSize,
//                                           ),
//                                       ),
//                                       onPressed: () async {
//                                           Navigator.pop(_context);

//                                           _changePlanAlert(context);
//                                           FirestoreManager.changePlan(
//                                               SevaCore.of(context).loggedInUser.currentCommunity,
//                                               widget.plan.id,
//                                           ).then((value) {
//                                               Navigator.of(context, rootNavigator: true).pop();
//                                               return planChangedMessage(context, value);
//                                           });

//                                       },
//                                   ),
//                                   CustomTextButton(
//                                       child: Text(
//                                           S.of(context).no,
//                                           style: TextStyle(
//                                               color: Colors.red,
//                                               fontSize: dialogButtonSize,
//                                           ),
//                                       ),
//                                       onPressed: () => Navigator.pop(_context),
//                                   ),
//                               ],
//                           ),
//                       ],
//                   ),
//               );
//           },
//       );
//   }

//   void _showBillMeDialog(context, msg) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(S.of(context).billable_transactions),
//           content: Text(msg),
//           actions: <Widget>[
//             CustomTextButton(
//               child: Text(S.of(context).ok),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _changePlanAlert(
//     BuildContext context,
//   ) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Row(
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(width: 30),
//               Expanded(
//                 child: Text(S.of(context).changing_plan),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> cannotDowngradeMessage(
//       BuildContext context,
//       ) async {
//       await showDialog(
//           context: context,
//           builder: (BuildContext context) {
//               return AlertDialog(
//                   content: Text("Please contact Sevax support for downgrading your plan",
//                   ),
//                   actions: <Widget>[
//                       CustomTextButton(
//                           child: Text(S.of(context).close),
//                           onPressed: () {
//                               Navigator.of(context).pop();
//                           },
//                       ),
//                   ],
//               );
//           },
//       );
//   }

//   Future<void> planChangedMessage(
//     BuildContext context,
//     int isSuccess,
//   ) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Text(
//             isSuccess == 1
//                 ? S.of(context).plan_changed
//                 : isSuccess == 0 ? "Please clear your dues and try again !" : S.of(context).general_stream_error,
//           ),
//           actions: <Widget>[
//             CustomTextButton(
//               child: Text(S.of(context).close),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 if( isSuccess==1 ){
//                     Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(
//                             builder: (context1) => SevaCore(
//                                 loggedInUser: widget.user,
//                                 child: HomePageRouter(),
//                             ),
//                         ),
//                             (Route<dynamic> route) => false);
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _planSuccessMessage({
//     BuildContext context,
//   }) {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         CollectionRef
//             .communities
//             .doc(widget.user.currentCommunity)
//             .update(
//           {
//             "payment": {
//               "status": 200,
//               "payment_success": true,
//               "planId": widget.plan.id,
//               "message": isBillMe
//                   ? widget.plan.planName
//                   : "You are on neighbourhood plan"
//             },
//             "billMe": isBillMe
//           },
//         ).then((_) {
//           Navigator.of(context).pop();
//           Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (context1) => FlavorConfig.appFlavor == Flavor.APP
//                     ? MainApplication()
//                     : dev.MainApplication(),
//               ),
//               (Route<dynamic> route) => false);
//         });
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(S.of(context).taking_to_new_timebank),
//               // Text('It may take couple of minutes to synchronize your payment'),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

class SevaBillingPlans {
  static String NEIGHBOUR_HOOD_PLAN = 'neighbourhood_plan';
  static String COMMUNITY_PLAN = 'tall_plan';
  static String COMMUNITY_PLUS = 'community_plus_plan';
  static String NON_PROFIT = 'grande_plan';
  static String ENTERPRISE = 'venti_plan';
}
