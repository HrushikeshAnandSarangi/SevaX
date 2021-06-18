// import 'dart:developer';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:sevaexchange/components/ProfanityDetector.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/new_baseline/models/card_model.dart';
// import 'package:sevaexchange/new_baseline/models/community_model.dart';
// import 'package:sevaexchange/ui/screens/home_page/bloc/user_data_bloc.dart';
// import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
// import 'package:sevaexchange/utils/animations/fade_animation.dart';
// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/utils/bloc_provider.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/timebanks/billing/billing_view.dart';
// import 'package:sevaexchange/views/timebanks/billing/widgets/plan_card.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

// import '../../flavor_config.dart';

// class TimeBankBillingAdminView extends StatefulWidget {
//   @override
//   _TimeBankBillingAdminViewState createState() =>
//       _TimeBankBillingAdminViewState();
// }

// class _TimeBankBillingAdminViewState extends State<TimeBankBillingAdminView> {
//   String communityImageError = '';

//   var scollContainer = ScrollController();
//   var scrollIsOpen = false;
//   List<FocusNode> focusNodes;
//   GlobalKey<FormState> _billingInformationKey = GlobalKey();
//   CommunityModel communityModel = CommunityModel({});
//   CardModel cardModel;
//   BuildContext parentContext;
//   var planData = [];
//   var transactionPaymentData;
//   final profanityDetector = ProfanityDetector();
//   final String NO_SELECTED_PLAN_YET = "";
//   List<BillingPlanDetailsModel> _billingPlanDetailsModels = [];
//   UserModel currentUser = null;
//   @override
//   void initState() {
//     super.initState();
//     focusNodes = List.generate(8, (_) => FocusNode());

//     Future.delayed(Duration.zero, () {
//       FirestoreManager.getCommunityDetailsByCommunityId(
//               communityId: SevaCore.of(context).loggedInUser.currentCommunity)
//           .then((onValue) {
//         communityModel = onValue;
//       });
//       _billingPlanDetailsModels = billingPlanDetailsModelFromJson(
//         AppConfig.remoteConfig
//             .getString('billing_plans_${S.of(context).localeName}'),
//       );
//     });
//     setState(() {});
//   }

//   String planName(String text) {
//     switch (text) {
//       case 'neighbourhood_plan':
//         return 'Neighbourhood Plan';
//         break;
//       case 'tall_plan':
//         return 'Community Plan';
//         break;
//       case 'grande_plan':
//         return 'Non-Profit Plan';
//         break;
//       case 'venti_plan':
//         return 'Enterprise Plan';
//         break;
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // FocusScope.of(context).requestFocus(FocusNode());
//     currentUser = SevaCore.of(context).loggedInUser;
//     final _bloc = BlocProvider.of<UserDataBloc>(context);
//     this.parentContext = context;
//     var currentCommunityId = SevaCore.of(context).loggedInUser.currentCommunity;

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             _bloc.community.billMe
//                 ? planCard(_bloc)
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       headingText(S.of(context).plan_details),
//                       StreamBuilder<CardModel>(
//                         stream: FirestoreManager.getCardModelStream(
//                           communityId: currentCommunityId,
//                         ),
//                         builder: (parentContext, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return LoadingIndicator();
//                           }
//                           //No Card added user is on neighbourhood plan
//                           if (snapshot.data == null) {
//                             return spendingsTextWidgettwo(
//                               "You are on neighbourhood plan.",
//                             );
//                           }

//                           if (snapshot.hasData && snapshot.data != null) {
//                             cardModel = snapshot.data;
//                             if (cardModel.subscriptionModel != null) {
//                               String data = NO_SELECTED_PLAN_YET;
//                               _billingPlanDetailsModels.removeWhere((element) =>
//                                   element.id != cardModel.currentPlan);
//                               if (cardModel.subscriptionModel != null &&
//                                   cardModel.subscriptionModel.length > 0)
//                                 cardModel.subscriptionModel.forEach(
//                                   (subscritpion) {
//                                     if (subscritpion.containsKey("items")) {
//                                       if (subscritpion['items']['data'] !=
//                                           null) {
//                                         planData =
//                                             subscritpion['items']['data'] ?? [];
//                                         if (cardModel.currentPlan ==
//                                             SevaBillingPlans.COMMUNITY_PLAN) {
//                                           data =
//                                               "${S.of(context).your_community_on_the} ${cardModel.currentPlan != null ? planName(cardModel.currentPlan) : ""}, ${S.of(context).paying} \$${_billingPlanDetailsModels[0].price} ${S.of(context).monthly_charges_of} \$0.05 ${S.of(context).plan_details_quota1}.";
//                                         } else if (cardModel.currentPlan ==
//                                             SevaBillingPlans.NON_PROFIT) {
//                                           data =
//                                               "${S.of(context).your_community_on_the}  ${cardModel.currentPlan != null ? planName(cardModel.currentPlan) : ""}, ${S.of(context).plan_yearly_1500} \$0.03 ${S.of(context).plan_details_quota1}.";
//                                         } else if (cardModel.currentPlan ==
//                                             SevaBillingPlans.ENTERPRISE) {
//                                           data =
//                                               "${S.of(context).your_community_on_the} ${cardModel.currentPlan != null ? planName(cardModel.currentPlan) : ""}, ${S.of(context).paying} \$${_billingPlanDetailsModels[0].price} ${S.of(context).charges_of} \$0.01  ${S.of(context).per_transaction_quota}.";
//                                         }
//                                         return spendingsTextWidgettwo(
//                                             data ?? NO_SELECTED_PLAN_YET);
//                                       } else {
//                                         return emptyText();
//                                       }
//                                     } else {
//                                       return emptyText();
//                                     }
//                                   },
//                                 );
//                               return spendingsTextWidgettwo(
//                                   data ?? NO_SELECTED_PLAN_YET);
//                             } else {
//                               return emptyText();
//                             }
//                           } else {
//                             return emptyText();
//                           }
//                         },
//                       ),
//                       // headingText(S.of(context).status),
//                       //  statusWidget(),
//                     ],
//                   ),
//             cardsHeadingWidget(_bloc),
//             // cardsDetailWidget(),
//             configureBillingHeading(parentContext),
//               SizedBox(height: 70),
//               _bloc.community.payment['planId'] ==
//                     SevaBillingPlans.NEIGHBOUR_HOOD_PLAN
//                 ? Container()
//                 : _bloc.community.subscriptionCancelled ? Padding(
//                   padding: EdgeInsets.only(right: 12, left: 10),
//                   child: CustomTextButton(
//                       onPressed: (){},
//                       shape: RoundedRectangleBorder(
//                           borderRadius: new BorderRadius.circular(10.0),
//                           side: BorderSide(
//                               color: Colors.redAccent,
//                               width: 2,
//                               style: BorderStyle.solid)),
//                     child: Padding(
//                       padding: const EdgeInsets.only(top:3, bottom:3),
//                       child: RichText(
//                           textAlign: TextAlign.start,
//                           text: TextSpan(
//                               children: <TextSpan>[
//                                   TextSpan(
//                                       style: TextStyle(color: Colors.black, fontSize: 15),
//                                       text: "* "+S.of(context).cancel_subscription_success_label,
//                                   ),
//                               ],
//                           ),
//                       ),
//                     ),
//                   ),
//               ) : Column(
//                     children: [
//                         Row(
//                         children: [
//                           Spacer(),
//                             CustomTextButton(
//                             child: Text(
//                               S.of(context).cancel_subscription,
//                               style: TextStyle(
//                                   color: FlavorConfig.values.theme.primaryColor,
//                                   fontSize: 14),
//                             ),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: new BorderRadius.circular(10.0),
//                                 side: BorderSide(
//                                     color:
//                                         FlavorConfig.values.theme.primaryColor,
//                                     width: 1,
//                                     style: BorderStyle.solid)),
//                             onPressed: () async {
//                               _showCancelConfirmationDialog(context);
//                             },
//                           ),
//                           Spacer(),
//                         ],
//                       ),
//                     ],
//                   )
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCancelConfirmationDialog(BuildContext parentContext) {
//     showDialog(
//       context: parentContext,
//       barrierDismissible: true,
//       builder: (_context) {
//         return AlertDialog(
//           title: Text(
//               S.of(context).cancel_subscription,
//             textAlign: TextAlign.center,
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(S.of(context).are_you_sure_subs_cancel),
//               SizedBox(
//                 height: 15,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   CustomElevatedButton(
//                     padding: EdgeInsets.fromLTRB(14, 5, 14, 5),
//                     color: Theme.of(context).accentColor,
//                     textColor: FlavorConfig.values.buttonTextColor,
//                     child: Text(
//                       S.of(context).yes,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: dialogButtonSize,
//                       ),
//                     ),
//                     onPressed: () async {
//                       Navigator.pop(_context);
//                       _changePlanAlert(context);

//                       int value =
//                           await FirestoreManager.cancelTimebankSubscription(
//                         SevaCore.of(context).loggedInUser.currentCommunity,
//                         true,
//                       );
//                       Navigator.of(context, rootNavigator: true).pop();

//                       cancelSubscriptionMessage(context, value).then((_) {
//                         if (value == 1) {
//                           Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (context1) => SevaCore(
//                                   loggedInUser: currentUser,
//                                   child: HomePageRouter(),
//                                 ),
//                               ),
//                               (Route<dynamic> route) => false);
//                         }
//                       });
//                     },
//                   ),
//                   CustomTextButton(
//                     child: Text(
//                       S.of(context).no,
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: dialogButtonSize,
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(_context);
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget planCard(UserDataBloc _bloc) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         headingText(S.of(context).plan_details),
//         Padding(
//           padding: const EdgeInsets.only(left: 20.0),
//           child: RichText(
//             text: TextSpan(
//               style: TextStyle(color: Colors.black),
//               children: [
//                 TextSpan(
//                     text: _bloc.community.payment["planId"] == "community_plan"
//                         ? "${S.of(context).on_community_plan}  "
//                         : "${S.of(context).your_community_on_the} ${planName(_bloc.community.payment["planId"])}  "),
//                 TextSpan(
//                   text: S.of(context).change_plan,
//                   style: TextStyle(
//                       color: Theme.of(context).primaryColor,
//                       fontSize: 16,
//                       fontFamily: 'Europa',
//                       decoration: TextDecoration.underline),
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => BillingPlanDetails(
//                                 user: SevaCore.of(context).loggedInUser,
//                                 activePlanId: _bloc.community.payment["planId"],
//                                 isPlanActive: true,
//                                 autoImplyLeading: true,
//                                 isPrivateTimebank: communityModel.private,
//                                 isBillMe: communityModel.billMe),
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget spendingsTextWidget(String data) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 20, left: 20),
//       child: Text(
//         data,
//         style: TextStyle(
//           fontFamily: 'Europa',
//           fontSize: 16,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }

//   Widget spendingsTextWidgettwo(String data) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 0, left: 20),
//       child: RichText(
//         textAlign: TextAlign.start,
//         text: TextSpan(
//           children: <TextSpan>[
//             TextSpan(
//               style: TextStyle(color: Colors.grey, fontSize: 16),
//               text: data,
//             ),
//             TextSpan(
//               text: data != NO_SELECTED_PLAN_YET
//                   ? ' ${S.of(context).change_plan}'
//                   : S.of(context).payment_still_processing,
//               style: TextStyle(
//                   color: Theme.of(context).primaryColor,
//                   fontSize: 16,
//                   fontFamily: 'Europa',
//                   decoration: TextDecoration.underline),
//               recognizer: TapGestureRecognizer()
//                 ..onTap = () {
//                   if (data == NO_SELECTED_PLAN_YET) {
//                     return;
//                   }
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => BillingPlanDetails(
//                         user: SevaCore.of(context).loggedInUser,
//                         activePlanId:
//                             cardModel != null && cardModel.currentPlan != null
//                                 ? cardModel.currentPlan
//                                 : SevaBillingPlans.NEIGHBOUR_HOOD_PLAN,
//                         isPlanActive: data != NO_SELECTED_PLAN_YET,
//                         autoImplyLeading: true,
//                         isPrivateTimebank: communityModel.private,
//                         isBillMe: communityModel.billMe,
//                       ),
//                     ),
//                   ).then((value) {
//                     setState(() {});
//                   });
//                 },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget headingText(String name) {
//     return Padding(
//       padding: EdgeInsets.only(top: 5, bottom: 10, left: 20),
//       child: Text(
//         name,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget statusWidget() {
//     var now = DateTime.now();
//     var month = now.month - 1 == 0 ? 12 : now.month - 1;
//     var year = now.year;
//     var pastPlans = [];
//     return StreamBuilder(
//         stream: CollectionRef
//             .communities
//             .doc(SevaCore.of(context).loggedInUser.currentCommunity)
//             .snapshots(),
//         builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return LoadingIndicator();
//           }
//           if (snapshot.hasData && snapshot.data != null) {
//             if (snapshot.data.data != null &&
//                 snapshot.data.data['payment_state'] != null) {
//               pastPlans = snapshot.data.data['payment_state']['plans'] ?? [];
//               return ListView.builder(
//                   itemCount: pastPlans.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     return spendingsTextWidget(
// //                        "For the ${pastPlans[index]['nickname'] ?? " "} charged \$ ${pastPlans[index]['amount'] / 100 ?? ""} .");
//                         "Plan Active");
//                   });
//             } else {
//               return emptyText();
//             }
//           } else {
//             return emptyText();
//           }
//         });
//   }

//   Widget emptyText() {
//     return Center(
//       child: Text(
//         S.of(context).no_data,
//       ),
//     );
//   }

//   Widget cardsHeadingWidget(UserDataBloc _bloc) {
//     return FutureBuilder(
//         future: CollectionRef
//             .cards
//             .doc(SevaCore.of(context).loggedInUser.currentCommunity)
//             .get(),
//         builder: (context, snapshot) {
//           String planName = '';
//           if (snapshot.hasData && snapshot.data.data != null) {
//             planName = snapshot.data.data['currentplan'];
//           }
//           return Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               headingText(S.of(context).monthly_subscription),
//               Padding(
//                 padding: EdgeInsets.only(left: 10, top: 10, right: 10),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.edit,
//                   ),
//                   onPressed: () {
//                     if (planName == '' &&
//                         !_bloc.community.payment.containsKey("planId")) {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => BillingPlanDetails(
//                             user: SevaCore.of(context).loggedInUser,
//                             isPlanActive: false,
//                             autoImplyLeading: true,
//                             isPrivateTimebank: communityModel.private,
//                             isBillMe: communityModel.billMe,
//                           ),
//                         ),
//                       );
//                     } else {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => BillingView(
//                             SevaCore.of(context).loggedInUser.currentCommunity,
//                             planName,
//                             user: SevaCore.of(context).loggedInUser,
//                             isFromChangeOwnership: false,
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             ],
//           );
//         });
//   }

//   BuildContext buildContext;

//   Widget configureBillingHeading(BuildContext buildContext) {
//     this.buildContext = buildContext;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         headingText(S.of(context).edit_profile_information),
//         Padding(
//           padding: EdgeInsets.only(left: 10, top: 5, right: 10),
//           child: IconButton(
//             icon: Icon(
//               Icons.edit,
//             ),
//             onPressed: () {
//               FocusScope.of(buildContext).requestFocus(FocusNode());
//               _billingBottomsheet(buildContext);

// //              _pc.open();
// //              scrollIsOpen = true;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void _billingBottomsheet(BuildContext mcontext) {
//     showModalBottomSheet(
//         context: mcontext,
//         builder: (BuildContext bc) {
//           return Container(
//             child: _scrollingList(focusNodes, bc),
//           );
//         });
//   }

//   Widget get _billingDetailsTitle {
//     return Container(
// //        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
//         margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Column(
//               children: <Widget>[
//                 Text(
//                   S.of(context).timebank_profile_info,
//                   style: TextStyle(
//                       color: FlavorConfig.values.theme.primaryColor,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             Column(
//               children: <Widget>[
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                     //_pc.close();
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
//                     child: Text(
//                       ''' x ''',
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ));
//   }

//   InputDecoration getInputDecoration({String fieldTitle}) {
//     return InputDecoration(
//       errorMaxLines: 2,
//       errorStyle: TextStyle(
//         color: Colors.red,
//         wordSpacing: 2.0,
//       ),
// //      focusedBorder: OutlineInputBorder(
// //        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
// //      ),
// //      border: OutlineInputBorder(
// //          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
// //      enabledBorder: OutlineInputBorder(
// //        borderSide: BorderSide(color: Colors.green, width: 1.0),
// //      ),
//       hintText: fieldTitle,

//       alignLabelWithHint: true,
//     );
//   }

//   Widget _scrollingList(List<FocusNode> focusNodes, BuildContext bc) {
//     Widget _cityWidget(String city) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           textInputAction: TextInputAction.next,
//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[0]);
//             FocusScope.of(bc).unfocus();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.city = value;
//           },
//           initialValue: city != null ? city : '',
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           decoration: getInputDecoration(fieldTitle: S.of(context).city),
//         ),
//       );
//     }

//     Widget _stateWidget(String state) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           textInputAction: TextInputAction.next,
//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[1]);
//             FocusScope.of(bc).unfocus();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.state = value;
//           },
//           initialValue: state != null ? state : '',
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           focusNode: focusNodes[0],
//           decoration: getInputDecoration(fieldTitle: S.of(context).state),
//         ),
//       );
//     }

//     Widget _pinCodeWidget(int pinCode) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
//         child: TextFormField(
//           textInputAction: TextInputAction.next,
//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[3]);
//             FocusScope.of(bc).unfocus();
//           },
//           onChanged: (value) {
//             communityModel.billing_address.pincode = int.parse(value);
//           },
//           initialValue: pinCode != null ? pinCode.toString() : '',
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : null;
//           },
//           focusNode: focusNodes[2],
//           keyboardType: TextInputType.number,
//           maxLength: 15,
//           decoration: getInputDecoration(fieldTitle: S.of(context).zip),
//         ),
//       );
//     }

//     Widget _additionalNotesWidget(String notes) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           onFieldSubmitted: (input) {
//             scrollToBottom();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.additionalnotes = value;
//           },
//           validator: (value) {
//             return (profanityDetector.isProfaneString(value))
//                 ? S.of(context).profanity_text_alert
//                 : null;
//           },
//           initialValue: notes != null ? notes : '',
//           focusNode: focusNodes[7],
//           textInputAction: TextInputAction.done,
//           decoration:
//               getInputDecoration(fieldTitle: S.of(context).additional_notes),
//         ),
//       );
//     }

//     Widget _streetAddressWidget(String street_address1) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           onFieldSubmitted: (input) {
//             FocusScope.of(bc).unfocus();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.street_address1 = value;
//           },
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           focusNode: focusNodes[3],
//           textInputAction: TextInputAction.next,
//           initialValue: street_address1 != null ? street_address1 : '',
//           decoration: getInputDecoration(fieldTitle: S.of(context).street_add1),
//         ),
//       );
//     }

//     Widget _streetAddressTwoWidget(String street_address2) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//             textCapitalization: TextCapitalization.sentences,
//             onFieldSubmitted: (input) {
//               // FocusScope.of(bc).requestFocus(focusNodes[6]);
//               FocusScope.of(bc).unfocus();
//             },
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             onChanged: (value) {
//               communityModel.billing_address.street_address2 = value;
//             },
//             validator: (value) {
//               return (profanityDetector.isProfaneString(value))
//                   ? S.of(context).profanity_text_alert
//                   : null;
//             },
//             focusNode: focusNodes[5],
//             textInputAction: TextInputAction.next,
//             initialValue: street_address2 != null ? street_address2 : '',
//             decoration: getInputDecoration(
//               fieldTitle: S.of(context).street_add2,
//             )),
//       );
//     }

//     Widget _countryNameWidget(String country) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           textInputAction: TextInputAction.next,
//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[2]);
//             FocusScope.of(bc).unfocus();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.country = value;
//           },
//           initialValue: country != null ? country : '',
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           focusNode: focusNodes[1],
//           decoration: getInputDecoration(
//             fieldTitle: S.of(context).country,
//           ),
//         ),
//       );
//     }

//     Widget _companyNameWidget(String companyname) {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,

//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[7]);
//             FocusScope.of(bc).unfocus();
//           },
//           validator: (value) {
//             return (profanityDetector.isProfaneString(value))
//                 ? S.of(context).profanity_text_alert
//                 : null;
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.companyname = value;
//           },
//           initialValue: companyname != null ? companyname : '',
//           // validator: (value) {
//           //   return value.isEmpty ? 'Field cannot be left blank*' : null;
//           // },
//           focusNode: focusNodes[6],
//           textInputAction: TextInputAction.next,
//           decoration: getInputDecoration(
//             fieldTitle: S.of(context).company_name,
//           ),
//         ),
//       );
//     }

//     Widget _continueBtn(controller) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
//         child: CustomElevatedButton(
//           child: Text(
//             S.of(context).continue_text,
//             style: Theme.of(parentContext).primaryTextTheme.button,
//           ),
//           onPressed: () async {
//             FocusScope.of(bc).requestFocus(FocusNode());
//             if (_billingInformationKey.currentState.validate()) {
//               if (communityModel.billing_address.country == null) {
//                 scrollToTop();
//               } else {
//                 showProgressDialog(S.of(context).updating_details);

//                 await FirestoreManager.updateCommunityDetails(
//                     communityModel: communityModel);

//                 if (dialogContext != null) {
//                   Navigator.pop(dialogContext);
//                 }
//                 Navigator.pop(context);
//                 // _pc.close();
//                 //scrollIsOpen = false;
//               }
//             }
//           },
//         ),
//       );
//     }

//     return Container(
//       // var scrollController = Sc
//       //adding a margin to the top leaves an area where the user can swipe
//       //to open/close the sliding panel
//       margin: const EdgeInsets.only(top: 15.0),
//       color: Colors.white,
//       child: Form(
//         key: _billingInformationKey,
//         child: ListView(
//           controller: scollContainer,
//           children: <Widget>[
//             _billingDetailsTitle,
//             _cityWidget(communityModel.billing_address.city),
//             _stateWidget(communityModel.billing_address.state),
//             _countryNameWidget(communityModel.billing_address.country),
//             _pinCodeWidget(communityModel.billing_address.pincode),
//             _streetAddressWidget(
//                 communityModel.billing_address.street_address1),
//             _streetAddressTwoWidget(
//                 communityModel.billing_address.street_address2),
//             _companyNameWidget(communityModel.billing_address.companyname),
//             _additionalNotesWidget(
//                 communityModel.billing_address.additionalnotes),
//             _continueBtn(communityModel),
//           ],
//         ),
//       ),
//     );
//   }

//   BuildContext dialogContext;

//   void showProgressDialog(String message) {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (createDialogContext) {
//           dialogContext = createDialogContext;
//           return AlertDialog(
//             title: Text(message),
//             content: LinearProgressIndicator(),
//           );
//         });
//   }

//   void scrollToTop() {
//     scollContainer.animateTo(
//       0.0,
//       curve: Curves.easeOut,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   void scrollToBottom() {
//     scollContainer.animateTo(
//       scollContainer.position.maxScrollExtent,
//       curve: Curves.easeOut,
//       duration: const Duration(milliseconds: 300),
//     );
//   }

//   Future<void> cancelSubscriptionMessage(
//     BuildContext context,
//     int isSuccess,
//   ) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: Text(
//             isSuccess == 1
//                 ? S.of(context).cancellation_success_message
//                 : isSuccess == 0
//                     ? S.of(context).cancellation_failure_message
//                     : S.of(context).general_stream_error,
//           ),
//           actions: <Widget>[
//             CustomTextButton(
//               child: Text(S.of(context).close,
//                   style: TextStyle(
//                       color: isSuccess == 1 ? Colors.green : Colors.red)),
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
// }

// class SpendingsCardView extends StatefulWidget {
//   final CommunityModel communityModel;

//   SpendingsCardView({this.communityModel});

//   @override
//   _SpendingsCardViewState createState() => _SpendingsCardViewState();
// }

// class _SpendingsCardViewState extends State<SpendingsCardView> {
//   @override
//   Widget build(BuildContext parentContext) {
//     return Container(height: 210, child: getBillingDetailsWidget());
//   }

//   Widget getBillingDetailsWidget() {
//     return FadeAnimation(
//         0,
//         Container(
//           height: MediaQuery.of(context).size.height * 0.25,
//           child: ListView.builder(
//             shrinkWrap: true,
//             padding: EdgeInsets.only(left: 12),
//             scrollDirection: Axis.horizontal,
//             itemCount: 1,
//             itemBuilder: (parentContext, index) {
//               return spendingsCard();
//             },
//           ),
//         ));
//   }

//   Widget spendingsCard() {
//     return InkWell(
//       onTap: () {
// //        Navigator.push(
// //          parentContext,
// //          MaterialPageRoute(
// //            builder: (parentContext) => TimebankTabsViewHolder.of(
// //              timebankId: timebank.id,
// //              timebankModel: timebank,
// //            ),
// //          ),
// //        );
//       },
//       child: AspectRatio(
//         aspectRatio: 3 / 4,
//         child: Container(
//           margin: EdgeInsets.only(right: 10),
//           decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               image: DecorationImage(
//                   image: CachedNetworkImageProvider("" ?? ""),
//                   fit: BoxFit.cover)),
//           child: Container(
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.grey[300],
// //              gradient: LinearGradient(
// //                begin: Alignment.bottomRight,
// //                colors: [
// //                  Colors.black.withOpacity(.8),
// //                  Colors.black.withOpacity(.2),
// //                ],
// //              ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Icon(
//                   Icons.stars,
//                   color: Colors.grey,
//                   size: 45,
//                 ),
//                 headingText(
//                     S.of(context).seva_credits + ' ' + S.of(context).left),
//                 valueText(" \$125.00"),
//                 Align(
//                   alignment: Alignment.bottomLeft,
//                   child: CustomElevatedButton(
//                     padding:
//                         EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
//                     color: Colors.red[800],
//                     onPressed: () {},
//                     child: Text(
//                       "Recharge",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Europa',
//                           fontSize: 12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget headingText(String name) {
//     return Padding(
//       padding: EdgeInsets.only(top: 10, bottom: 10),
//       child: Text(
//         name,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Widget valueText(String name) {
//     return Padding(
//       padding: EdgeInsets.only(top: 10, bottom: 10),
//       child: Text(
//         name,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Europa',
//           fontSize: 20,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }
// }
