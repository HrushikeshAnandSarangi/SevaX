// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:flutter/material.dart';
// import 'package:sevaexchange/components/ProfanityDetector.dart';
// import 'package:sevaexchange/constants/sevatitles.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/change_ownership_model.dart';
// import 'package:sevaexchange/models/models.dart';
// import 'package:sevaexchange/new_baseline/models/community_model.dart';
// import 'package:sevaexchange/ui/screens/home_page/pages/home_page_router.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/views/timebanks/billing/billing_view.dart';

// import '../../core.dart';

// class ChangeOwnershipDialog extends StatefulWidget {
//   final ChangeOwnershipModel changeOwnershipModel;
//   final String timeBankId;
//   final String notificationId;
//   final NotificationsModel notificationModel;
//   final UserModel loggedInUser;
//   final BuildContext parentContext;
//   ChangeOwnershipDialog({
//     this.changeOwnershipModel,
//     this.timeBankId,
//     this.notificationId,
//     this.notificationModel,
//     this.loggedInUser,
//     this.parentContext,
//   });

//   @override
//   _ChangeOwnershipDialogViewState createState() =>
//       _ChangeOwnershipDialogViewState();
// }

// class _ChangeOwnershipDialogViewState extends State<ChangeOwnershipDialog> {
//   ChangeOwnershipModel changeOwnershipModel;
//   String timeBankId;
//   String notificationId;
//   NotificationsModel notificationModel;
//   UserModel loggedInUser;

//   List<FocusNode> focusNodes;
//   CommunityModel communityModel = CommunityModel({});
//   final GlobalKey<FormState> _billingInformationKey = GlobalKey();
//   BuildContext progressContext;
//   var scollContainer = ScrollController();
//   final profanityDetector = ProfanityDetector();

//   @override
//   void initState() {
//     super.initState();
//     changeOwnershipModel = widget.changeOwnershipModel;
//     timeBankId = widget.timeBankId;
//     notificationId = widget.notificationId;
//     notificationModel = widget.notificationModel;
//     loggedInUser = widget.loggedInUser;
//     getCommunityDetails();
//     focusNodes = List.generate(8, (_) => FocusNode());
//   }

//   void getCommunityDetails() async {
//     await FirestoreManager.getCommunityDetailsByCommunityId(
//             communityId: widget.loggedInUser.currentCommunity)
//         .then((value) {
//       communityModel = value;
//     });
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(25.0))),
//       content: Form(
//         //key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             _getCloseButton(context),
//             Container(
//               height: 70,
//               width: 70,
//               child: CircleAvatar(
//                 backgroundImage: NetworkImage(
//                     changeOwnershipModel.creatorPhotoUrl ??
//                         defaultUserImageURL),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(4.0),
//             ),
//             Padding(
//               padding: EdgeInsets.all(4.0),
//               child: Text(
//                 S.of(context).change_ownership,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
//               child: Text(
//                 changeOwnershipModel.timebank ??
//                     "${S.of(context).timebank} name not updated",
//               ),
//             ),
// //              Padding(
// //                padding: EdgeInsets.all(0.0),
// //                child: Text(
// //                  "About ${requestInvitationModel.}",
// //                  style: TextStyle(
// //                      fontSize: 13, fontWeight: FontWeight.bold),
// //                ),
// //              ),
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 S.of(context).change_ownership_message1 +
//                     ' ' +
//                     changeOwnershipModel.timebank +
//                     ' ' +
//                     S.of(context).change_ownership_message2,
//                 maxLines: 5,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Center(
//               child: Text(
//                 S.of(context).by_accepting_owner_timebank,
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(5.0),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   width: double.infinity,
//                   child: CustomElevatedButton(
//                     color: FlavorConfig.values.theme.primaryColor,
//                     child: Text(
//                       S.of(context).accept,
//                       style:
//                           TextStyle(color: Colors.white, fontFamily: 'Europa'),
//                     ),
//                     onPressed: () async {
//                       //Once approved
//                       getAdvisoryDialog(context, changeOwnershipModel.timebank);

//                       // showProgressDialog(context, 'Accepting Invitation');
// //                      approveInvitation(
// //                        model: changeOwnershipModel,
// //                        notificationId: widget.notificationId,
// //                      );

// //                      if (progressContext != null) {
// //                        Navigator.pop(progressContext);
// //                      }

//                       // Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(4.0),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   child: CustomElevatedButton(
//                     color: Theme.of(context).accentColor,
//                     child: Text(
//                       S.of(context).decline,
//                       style:
//                           TextStyle(color: Colors.white, fontFamily: 'Europa'),
//                     ),
//                     onPressed: () async {
//                       await FirestoreManager.readUserNotification(
//                           notificationId, loggedInUser.email);
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void cardsHeadingWidget() {
//     String planName = '';
//     if (communityModel.billMe == true) {
//       showProgressDialog(S.of(context).updating_details);
//       changeOwnership(
//               primaryTimebank: communityModel.primary_timebank,
//               adminId: loggedInUser.sevaUserID,
//               communityId: communityModel.id,
//               adminEmail: loggedInUser.email,
//               notificaitonId: notificationId)
//           .commit()
//           .then((onValue) {
//         if (progressContext != null) {
//           Navigator.pop(progressContext);
//         }
//         getSuccessDialog();
//       });
//     } else {
//       CollectionRef
//           .cards
//           .doc(loggedInUser.currentCommunity)
//           .get()
//           .then((value) {
//         if (value.data != null) {
//           planName = value.data['currentplan'];
//           if (planName == '' && !communityModel.payment.containsKey("planId")) {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => BillingPlanDetails(
//                   user: loggedInUser,
//                   isPlanActive: false,
//                   autoImplyLeading: true,
//                   isPrivateTimebank: communityModel.private,
//                   isBillMe: communityModel.billMe,
//                 ),
//               ),
//             );
//           } else {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => BillingView(
//                   loggedInUser.currentCommunity,
//                   planName,
//                   user: loggedInUser,
//                   notificationId: notificationId,
//                   isFromChangeOwnership: true,
//                   changeOwnershipModel: changeOwnershipModel,
//                   communityModel: communityModel,
//                 ),
//               ),
//             );
//           }
//         } else {}
//       });
//     }
//   }

//   void resetAndLoad() async {
//     await Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//             builder: (context) =>
//                 SevaCore(loggedInUser: loggedInUser, child: HomePageRouter())),
//         (Route<dynamic> route) => false);
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

//   void getAdvisoryDialog(BuildContext mContext, String timebankName) {
//     showDialog(
//       context: mContext,
//       builder: (BuildContext context) {
//         // return object of type Dialog
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(S.of(context).change_ownership_message1 +
//                   ' ' +
//                   timebankName +
//                   ' ' +
//                   S.of(context).change_ownership_advisory),
//               SizedBox(height: 15),
//               Row(
//                 children: [
//                   Spacer(),
//                   CustomTextButton(
//                     child: Text(S.of(context).cancel,
//                         style: TextStyle(
//                             fontSize: dialogButtonSize, color: Colors.red)),
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                   CustomTextButton(
//                     color: Theme.of(mContext).accentColor,
//                     textColor: FlavorConfig.values.buttonTextColor,
//                     child: Text(
//                       S.of(context).ok,
//                       style: TextStyle(
//                         fontSize: dialogButtonSize,
//                       ),
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pop();

//                       _billingBottomsheet(mContext);
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             // usually buttons at the bottom of the dialog
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
//       'billing_address': communityModel.billing_address.toMap()
//     });

//     batch.update(timebankRef, {
//       "creator_id": adminId,
//       "email_id": adminEmail,
//     });

//     batch.update(personalNotifications, {'isRead': true});

//     return batch;
//   }

//   BuildContext dialogContext;

//   void showProgressDialog(String message) {
//     showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (createDialogContext) {
//           progressContext = createDialogContext;
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

//   void declineInvitationbRequest({
//     ChangeOwnershipModel model,
//     String notificationId,
//   }) {
// //    rejectInviteRequest(
// //      requestId: model.requestId,
// //      rejectedUserId: userModel.sevaUserID,
// //      notificationId: notificationId,
// //    );
// //
// //    FirestoreManager.readUserNotification(notificationId, userModel.email);
//   }

//   void approveInvitation({
//     ChangeOwnershipModel model,
//     String notificationId,
//   }) {
// //    FirestoreManager.readUserNotification(notificationId, user.email);
//   }
//   void _billingBottomsheet(
//     BuildContext mcontext,
//   ) {
//     showModalBottomSheet(
//         context: mcontext,
//         builder: (BuildContext bc) {
//           return Container(
//             child: _scrollingList(
//               focusNodes,
//               bc,
//             ),
//           );
//         });
//   }

//   Widget _scrollingList(
//     List<FocusNode> focusNodes,
//     BuildContext bc,
//   ) {
//     Widget _cityWidget() {
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
//           focusNode: focusNodes[0],
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

//     Widget _stateWidget() {
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
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           focusNode: focusNodes[1],
//           decoration: getInputDecoration(fieldTitle: S.of(context).state),
//         ),
//       );
//     }

//     Widget _pinCodeWidget() {
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
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : null;
//           },
//           focusNode: focusNodes[3],
//           keyboardType: TextInputType.number,
//           maxLength: 15,
//           decoration: getInputDecoration(fieldTitle: S.of(context).zip),
//         ),
//       );
//     }

//     Widget _additionalNotesWidget() {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           onFieldSubmitted: (input) {
//             scrollToBottom();
//           },
//           validator: (value) {
//             return (profanityDetector.isProfaneString(value))
//                 ? S.of(context).profanity_text_alert
//                 : null;
//           },
//           onChanged: (value) {
//             communityModel.billing_address.additionalnotes = value;
//           },
//           focusNode: focusNodes[7],
//           textInputAction: TextInputAction.done,
//           decoration:
//               getInputDecoration(fieldTitle: S.of(context).additional_notes),
//         ),
//       );
//     }

//     Widget _streetAddressWidget() {
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
//           focusNode: focusNodes[4],
//           textInputAction: TextInputAction.next,
//           decoration: getInputDecoration(fieldTitle: S.of(context).street_add1),
//         ),
//       );
//     }

//     Widget _streetAddressTwoWidget() {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//             textCapitalization: TextCapitalization.sentences,
//             onFieldSubmitted: (input) {
//               // FocusScope.of(bc).requestFocus(focusNodes[6]);
//               FocusScope.of(bc).unfocus();
//             },
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             validator: (value) {
//               return (profanityDetector.isProfaneString(value))
//                   ? S.of(context).profanity_text_alert
//                   : null;
//             },
//             onChanged: (value) {
//               communityModel.billing_address.street_address2 = value;
//             },
//             focusNode: focusNodes[5],
//             textInputAction: TextInputAction.next,
//             decoration: getInputDecoration(
//               fieldTitle: S.of(context).street_add2,
//             )),
//       );
//     }

//     Widget _countryNameWidget() {
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
//           validator: (value) {
//             return value.isEmpty
//                 ? S.of(context).validation_error_required_fields
//                 : (profanityDetector.isProfaneString(value))
//                     ? S.of(context).profanity_text_alert
//                     : null;
//           },
//           focusNode: focusNodes[2],
//           decoration: getInputDecoration(
//             fieldTitle: S.of(context).company_name,
//           ),
//         ),
//       );
//     }

//     Widget _companyNameWidget() {
//       return Container(
//         margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
//         child: TextFormField(
//           textCapitalization: TextCapitalization.sentences,
//           onFieldSubmitted: (input) {
//             // FocusScope.of(bc).requestFocus(focusNodes[7]);
//             FocusScope.of(bc).unfocus();
//           },
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           onChanged: (value) {
//             communityModel.billing_address.companyname = value;
//           },
//           validator: (value) {
//             return (profanityDetector.isProfaneString(value))
//                 ? S.of(context).profanity_text_alert
//                 : null;
//           },
//           focusNode: focusNodes[6],
//           textInputAction: TextInputAction.next,
//           decoration: getInputDecoration(
//             fieldTitle: S.of(context).company_name,
//           ),
//         ),
//       );
//     }

//     Widget _continueBtn() {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
//         child: CustomElevatedButton(
//           child: Text(
//             S.of(context).continue_text,
//             style: Theme.of(bc).primaryTextTheme.button,
//           ),
//           onPressed: () async {
//             FocusScope.of(bc).requestFocus(FocusNode());
//             if (_billingInformationKey.currentState.validate()) {
//               if (communityModel.billing_address.country == null) {
//                 scrollToTop();
//               } else {
//                 cardsHeadingWidget();
//                 //  Navigator.pop(context);
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
//             _cityWidget(),
//             _stateWidget(),
//             _countryNameWidget(),
//             _pinCodeWidget(),
//             _streetAddressWidget(),
//             _streetAddressTwoWidget(),
//             _companyNameWidget(),
//             _additionalNotesWidget(),
//             _continueBtn(),
//             SizedBox(
//               height: 220,
//             ),
//           ],
//         ),
//       ),
//     );
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

//   Widget _getCloseButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
//       child: Container(
//         alignment: FractionalOffset.topRight,
//         child: Container(
//           width: 20,
//           height: 20,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage(
//                 'lib/assets/images/close.png',
//               ),
//             ),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//           ),
//         ),
//       ),
//     );
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
// }
