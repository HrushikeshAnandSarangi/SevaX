// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/change_ownership_model.dart';
// import 'package:sevaexchange/models/user_model.dart';
// import 'package:sevaexchange/new_baseline/models/community_model.dart';
// import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
// import 'package:sevaexchange/utils/data_managers/blocs/payment_bloc.dart';
// import 'package:sevaexchange/utils/data_managers/user_data_manager.dart';
// import 'package:sevaexchange/utils/helpers/show_limit_badge.dart';
// import 'package:sevaexchange/views/core.dart';
// import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
// import 'package:stripe_payment/stripe_payment.dart';

// import '../../../main_app.dart';
// import '../../../main_seva_dev.dart' as dev;
// import '../../../widgets/credit_card/credit_card.dart';

// class BillingView extends StatefulWidget {
//   final timebankid;
//   final String planId;
//   final UserModel user;
//   final bool isFromChangeOwnership;
//   final String notificationId;
//   final ChangeOwnershipModel changeOwnershipModel;
//   final CommunityModel communityModel;

//   BillingView(
//     this.timebankid,
//     this.planId, {
//     this.user,
//     this.isFromChangeOwnership,
//     this.notificationId,
//     this.changeOwnershipModel,
//     this.communityModel,
//   });

//   @override
//   State<StatefulWidget> createState() {
//     return BillingViewState();
//   }
// }

// class BillingViewState extends State<BillingView> {
//   GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//   Future<UserCardsModel> userCardDetails;

//   BuildContext dialogContext;
//   @override
//   void initState() {
//     userCardDetails = getUserCard(widget.user.currentCommunity);
//     StripePayment.setOptions(
//       StripeOptions(
//         publishableKey: FlavorConfig.values.stripePublishableKey,
//         androidPayMode: FlavorConfig.values.androidPayMode,
//         merchantId: 'acct_1BuMJNIPTZX4UEIO',
//       ),
//     );
//     super.initState();
//   }

//   void setError(Error error) {
//     //Handle failed transactions and errors in this method
//   }

//   Future<void> connectToStripe(String paymentMethodId) async {
//     PaymentMethod paymentMethod = PaymentMethod();
//     if (paymentMethodId == null) {
//       paymentMethod = await StripePayment.paymentRequestWithCardForm(
//         CardFormPaymentRequest(),
//       ).then((PaymentMethod paymentMethod) {
//         return paymentMethod;
//       });
//       var paymentbloc = PaymentsBloc();
//       paymentbloc.storeNewCard(paymentMethod.id, widget.timebankid,
//           widget.user ?? SevaCore.of(context).loggedInUser, widget.planId);

//       if (widget.isFromChangeOwnership) {
//         showProgressDialog(S.of(context).updating_details);
//         setDefaultCard(
//                 token: paymentMethod.id,
//                 communityId: widget.user.currentCommunity)
//             .then((_) {
//           userCardDetails = getUserCard(widget.timebankid);
//           changeOwnership(
//                   primaryTimebank: widget.communityModel.primary_timebank,
//                   adminId: widget.user.sevaUserID,
//                   communityId: widget.communityModel.id,
//                   adminEmail: widget.user.email,
//                   notificaitonId: widget.notificationId)
//               .commit()
//               .then((onValue) {
//             updateCustomer();
//           });
//           setState(() {});
//         });
//       } else {
//         _cardAlertMessage(
//           isSuccess: true,
//           communityId: widget.user.currentCommunity,
//         );
//       }
//     }
//   }

//   void updateCustomer() async {
//     String response = await updateChangeOwnerDetails(
//         communityId: widget.communityModel.id,
//         email: widget.user.email,
//         city: widget.communityModel.billing_address.city,
//         country: widget.communityModel.billing_address.country,
//         pinCode: widget.communityModel.billing_address.pincode.toString(),
//         state: widget.communityModel.billing_address.state,
//         streetAddress1: widget.communityModel.billing_address.street_address1,
//         streetAddress2: widget.communityModel.billing_address.street_address2);
//     if (response == "200") {
//       if (dialogContext != null) {
//         Navigator.pop(dialogContext);
//       }
//       getSuccessDialog();
//     } else {
//       if (dialogContext != null) {
//         Navigator.pop(dialogContext);
//       }
//       _cardAlertMessage(isSuccess: false);
//     }
//   }

//   void resetAndLoad() async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => SevaCore(
//           loggedInUser: widget.user,
//           child: HomePageRouter(),
//         ),
//       ),
//     );
//   }

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

//   void getSuccessDialog() {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           content: Text(S.of(context).ownership_success),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             CustomTextButton(
//               child: Text(S.of(context).ok),
//               onPressed: () {
//                 resetAndLoad();
//                 // Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   WriteBatch changeOwnership({
//     String primaryTimebank,
//     String adminId,
//     String communityId,
//     String adminEmail,
//     String notificaitonId,
//   }) {
//     //add to timebank members

//     WriteBatch batch = CollectionRef.batch;
//     var timebankRef =
//         CollectionRef.timebank.doc(primaryTimebank);

//     var personalNotifications = CollectionRef
//         .users
//         .doc(adminEmail)
//         .collection("notifications")
//         .doc(notificaitonId);

//     var addToCommunityRef =
//         CollectionRef.communities.doc(communityId);

//     batch.update(addToCommunityRef, {
//       'created_by': adminId,
//       'primary_email': adminEmail,
//       'billing_address': widget.communityModel.billing_address.toMap()
//     });

//     batch.update(timebankRef, {
//       "creator_id": adminId,
//       "email_id": adminEmail,
//     });

//     batch.update(personalNotifications, {'isRead': true});

//     return batch;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             S.of(context).subscription(4), //for plural
//             style: TextStyle(
//               fontSize: 20,
//             ),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           width: double.infinity,
//           decoration: const BoxDecoration(color: Colors.white),
//           child: ListView(
//             children: <Widget>[
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Text(
//                       S.of(context).card_details,
//                       style: TextStyle(
//                         fontSize: 14.0,
//                         color: Colors.black,
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         connectToStripe(null);
//                       },
//                       child: Text(
//                         '+ ${S.of(context).add_new}',
//                         style: TextStyle(
//                           fontSize: 14.0,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Divider(),
//               FutureBuilder<UserCardsModel>(
//                 future: userCardDetails,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState != ConnectionState.done) {
//                     return LoadingIndicator();
//                   }
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text(S.of(context).no_cards_available),
//                     );
//                   }
//                   if (snapshot.data != null && snapshot.hasData) {
//                     return Column(
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 22, vertical: 10),
//                           child: Text(
//                             S.of(context).default_card_note,
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                         ),
//                         ListView.separated(
//                           separatorBuilder: (BuildContext context, int index) {
//                             return SizedBox(height: 20);
//                           },
//                           shrinkWrap: true,
//                           physics: ClampingScrollPhysics(),
//                           itemCount: snapshot.data.data.length,
//                           itemBuilder: (BuildContext context, int index) {
//                             //

//                             bool isDefault = false;
//                             if (snapshot.data.data[index].isDefault != null &&
//                                 snapshot.data.data[index].isDefault == true) {
//                               isDefault = true;
//                             }

//                             return GestureDetector(
//                               onTap: () {
//                                 // connectToStripe(cards[index]['paymentMethodId']);

//                                 connectToStripe(snapshot.data.data[index].id);
//                               },
//                               onLongPress: () => isDefault
//                                   ? _showAlreadyDefaultMessage()
//                                   : _showDialog(
//                                       token: snapshot.data.data[index].id,
//                                       communityId: widget.user.currentCommunity,
//                                     ),
//                               child: Stack(
//                                 // crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: <Widget>[
//                                   CustomCreditCard(
//                                     isDefaultCard: isDefault,
//                                     bankName: S.of(context).bank_name,
//                                     cardNumber:
//                                         snapshot.data.data[index].card.last4,
//                                     frontBackground: CardBackgrounds.black,
//                                     brand:
//                                         "${snapshot.data.data[index].card.brand}",
//                                     cardExpiry:
//                                         "${snapshot.data.data[index].card.expMonth}/${snapshot.data.data[index].card.expYear}",
//                                     cardHolderName: snapshot
//                                         .data.data[index].billingDetails.name,
//                                   ),
//                                   Offstage(
//                                     offstage: isDefault ? false : true,
//                                     child: Align(
//                                       alignment: Alignment.topCenter,
//                                       child: Container(
//                                         padding: EdgeInsets.symmetric(
//                                             horizontal: 10),
//                                         decoration: BoxDecoration(
//                                             color: Colors.red,
//                                             borderRadius: BorderRadius.only(
//                                               bottomLeft: Radius.circular(4),
//                                               bottomRight: Radius.circular(4),
//                                             )),
//                                         child: Text(
//                                           S.of(context).default_card,
//                                           style: TextStyle(color: Colors.white),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     );
//                   }
//                   return Container();
//                 },
//               ),
//               SizedBox(
//                 height: 100,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAlreadyDefaultMessage() {
//     // flutter defined function
//     showDialog(
//       context: context,
//       builder: (BuildContext _context) {
//         // return object of type Dialog
//         return AlertDialog(
//           title: Text(S.of(context).default_card),
//           content: Text(S.of(context).already_default_card),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
//             CustomTextButton(
//               child: Text(S.of(context).close),
//               onPressed: () {
//                 Navigator.of(_context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showDialog({String token, String communityId}) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Text(S.of(context).make_default_card),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   CustomElevatedButton(
//                     child: Text(S.of(context).confirm),
//                     onPressed: () {
//                       //showProgressDialog('Adding default card');
//                       setDefaultCard(token: token, communityId: communityId)
//                           .then((_) {
//                         userCardDetails = getUserCard(widget.timebankid);

//                         setState(() {});
//                       });
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   SizedBox(width: 10),
//                   CustomTextButton(
//                     color: Colors.white,
//                     child: Text(S.of(context).cancel),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _cardAlertMessage({
//     bool isSuccess = true,
//     String communityId,
//   }) {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         if (isSuccess) {
//           Future.delayed(Duration(milliseconds: 600), () {
//             // Here we need to update the payment to false
//             CollectionRef
//                 .communities
//                 .doc(communityId)
//                 .update({
//               'payment.message': 'Syncing payment data',
//               "payment.payment_success": false,
//               'payment.status': SevaPaymentStatusCodes.PROCESSING_PLAN_UPDATE,
//             });
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (context1) => FlavorConfig.appFlavor == Flavor.APP
//                     ? MainApplication()
//                     : dev.MainApplication(),
//               ),
//               (Route<dynamic> route) => false,
//             );
//           });
//         }
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           content: isSuccess
//               ? Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     Text(S.of(context).card_added),
//                     Text(S.of(context).card_sync),
//                   ],
//                 )
//               : Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(S.of(context).general_stream_error),
//                     SizedBox(height: 12),
//                     CustomElevatedButton(
//                       child: Text(S.of(context).ok),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     )
//                   ],
//                 ),
//         );
//       },
//     );
//   }
// }

// Future<UserCardsModel> getUserCard(String communityId) async {
//   var result = await http.post(
//       "${FlavorConfig.values.cloudFunctionBaseURL}/getCardsOfCustomer",
//       body: {"communityId": communityId});
//   // print(result.body);
//   if (result.statusCode == 200) {
//     return userCardsModelFromJson(result.body);
//   } else {
//     throw Exception('No cards available');
//   }
// }

// Future<bool> setDefaultCard({String communityId, String token}) async {
//   var result = await http.post(
//     "${FlavorConfig.values.cloudFunctionBaseURL}/setDefaultCardForCustomer",
//     body: {"communityId": communityId, "token": token},
//   );

//   return true;
// }
