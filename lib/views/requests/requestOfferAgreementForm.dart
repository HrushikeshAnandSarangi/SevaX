// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:progress_dialog/progress_dialog.dart';
// import 'package:sevaexchange/components/pdf_screen.dart';
// import 'package:sevaexchange/flavor_config.dart';
// import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/models/request_model.dart';
// import 'package:sevaexchange/new_baseline/models/borrow_agreement_template_model.dart';
// import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
// import 'package:sevaexchange/ui/utils/debouncer.dart';
// import 'package:sevaexchange/ui/utils/helpers.dart';
// import 'package:sevaexchange/utils/app_config.dart';
// import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
// import 'package:sevaexchange/utils/search_manager.dart';
// import 'package:sevaexchange/utils/soft_delete_manager.dart';
// import 'package:sevaexchange/utils/utils.dart';
// import 'package:sevaexchange/views/community/webview_seva.dart';
// import 'package:sevaexchange/widgets/custom_buttons.dart';
// import 'package:sevaexchange/widgets/empty_text_span.dart';
// import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

// import '../../labels.dart';

// class RequestOfferAgreementForm extends StatefulWidget {
//   final bool isRequest; //false means offer
//   final String roomOrTool; //'PLACE' or 'ITEM' (for request) (for offer same?)
//   final RequestModel requestModel;
//   final String timebankId;
//   final String communityId;
//   void Function(String borrowAgreementLinkFinal, String documentName)
//       onPdfCreated;

//   RequestOfferAgreementForm({
//     @required this.isRequest,
//     @required this.roomOrTool,
//     @required this.requestModel,
//     @required this.timebankId,
//     @required this.communityId,
//     @required this.onPdfCreated,
//   });

//   @override
//   _RequestOfferAgreementFormState createState() =>
//       _RequestOfferAgreementFormState();
// }

// class _RequestOfferAgreementFormState extends State<RequestOfferAgreementForm> {
//   String agreementDocumentType = AgreementDocumentType.NEW.readable;
//   TextEditingController searchTextController = TextEditingController();
//   final _textUpdates = StreamController<String>();
//   TextEditingController searchTextController2 = TextEditingController();
//   final _textUpdates2 = StreamController<String>();
//   bool saveAsTemplate = false;
//   String templateName = '';
//   bool templateFound = false;
//   String borrowAgreementLinkFinal = '';
//   String documentName = '';
//   String otherDetails = '';
//   int value;
//   AgreementTemplateModel selectedBorrowAgreementTemplate;
//   BorrowAgreementTemplateModel borrowAgreementTemplateModel =
//       BorrowAgreementTemplateModel();
//   Color primaryColor = FlavorConfig.values.theme.primaryColor;

//   //TOOLS specific fields variables below
//   String specificConditions = '';
//   String itemDescription = '';
//   String additionalConditions = '';

//   //PLACE specific fields variables below
//   bool isFixedTerm = true; //if false then its long term
//   bool isQuietHoursAllowed = false;
//   bool isPetsAllowed = false;
//   int maximumOccupants = 0;
//   int securityDeposit = 0;
//   String contactDetails = '';

//   final _formKey = GlobalKey<FormState>();
//   final GlobalKey<ScaffoldState> _key = GlobalKey();
//   final _formDialogKey = GlobalKey<FormState>();
//   final _debouncer = Debouncer(milliseconds: 400);

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     // //get agreement document templates
//     // searchTextController
//     //     .addListener(() => _textUpdates.add(searchTextController.text));
//     //
//     // Stream(_textUpdates.stream)
//     //     .debounceTime(Duration(milliseconds: 400))
//     //     .forEach((s) {
//     //   if (s.isEmpty) {
//     //     setState(() {
//     //       //_searchText = "";
//     //     });
//     //   } else {
//     //     setState(() {
//     //       // _searchText = s;
//     //     });
//     //   }
//     // });

//     searchTextController2.addListener(() {
//       _debouncer.run(() {
//         String s = searchTextController.text;

//         if (s.isEmpty) {
//         } else {
//           if (templateName != s) {
//             SearchManager.searchBorrowAgrrementTemplateForDuplicate(
//                     queryString: s)
//                 .then((commFound) {
//               if (commFound) {
//                 setState(() {
//                   templateFound = true;
//                 });
//               } else {
//                 setState(() {
//                   templateFound = false;
//                 });
//               }
//             });
//           }
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       key: _key,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).primaryColor,
//         leading: BackButton(
//           color: Colors.white,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         centerTitle: true,
//         title: Text(
//           S.of(context).choose_document, //Labels to be created
//           style: TextStyle(
//               fontFamily: "Europa", fontSize: 20, color: Colors.white),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: agreementDocumentType ==
//                 AgreementDocumentType.NO_AGREEMENT.readable
//             ? noAgreementWidget
//             : Form(
//                 key: _formKey,
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.only(top: 15.0, left: 30, right: 30),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       SizedBox(height: 14),

//                       agreementText,

//                       SizedBox(height: 15),

//                       //Radio Buttons
//                       _optionRadioButtonMain<String>(
//                         title: S.of(context).create_new,
//                         value: AgreementDocumentType.NEW.readable,
//                         groupvalue: agreementDocumentType,
//                         onChanged: (value) {
//                           agreementDocumentType = value;
//                           saveAsTemplate = false;
//                           setState(() => {});
//                         },
//                       ),
//                       _optionRadioButtonMain<String>(
//                         title: S.of(context).choose_previous_agreement,
//                         value: AgreementDocumentType.TEMPLATE.readable,
//                         groupvalue: agreementDocumentType,
//                         onChanged: (value) {
//                           agreementDocumentType = value;
//                           setState(() => {});
//                         },
//                       ),

//                       //Below two widgets for previous templates created
//                       searchFieldWidget(),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       buildTemplateWidget(),

//                       _optionRadioButtonMain<String>(
//                         title: S.of(context).no_agrreement,
//                         value: AgreementDocumentType.NO_AGREEMENT.readable,
//                         groupvalue: agreementDocumentType,
//                         onChanged: (value) {
//                           agreementDocumentType = value;
//                           saveAsTemplate = false;
//                           setState(() => {});
//                         },
//                       ),

//                       //Text Fields
//                       SizedBox(height: 15),

//                       widget.roomOrTool == 'ITEM'
//                           //TOOLS FORM BELOW
//                           ? toolWidget
//                           : //PLACE FORM BELOW
//                           Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 documentNameTextField,
//                                 SizedBox(height: 17),
//                                 Text(
//                                   S.of(context).usage_term,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Europa',
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5),
//                                 _optionRadioButtonRoomForm<bool>(
//                                   title: S.of(context).fixed,
//                                   value: true,
//                                   groupvalue: isFixedTerm,
//                                   onChanged: (value) {
//                                     isFixedTerm = value;
//                                     setState(() => {});
//                                   },
//                                 ),
//                                 _optionRadioButtonRoomForm<bool>(
//                                   title: S.of(context).long_term_month_to_month,
//                                   value: false,
//                                   groupvalue: isFixedTerm,
//                                   onChanged: (value) {
//                                     isFixedTerm = value;
//                                     setState(() => {});
//                                   },
//                                 ),
//                                 Row(
//                                   children: [
//                                     Checkbox(
//                                       value: isQuietHoursAllowed,
//                                       onChanged: (Value) {
//                                         setState(() {
//                                           isQuietHoursAllowed = Value;
//                                         });
//                                       },
//                                     ),
//                                     Text(
//                                       S.of(context).quite_hours_allowed,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'Europa',
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     Checkbox(
//                                       value: isPetsAllowed,
//                                       onChanged: (Value) {
//                                         setState(() {
//                                           isPetsAllowed = Value;
//                                         });
//                                       },
//                                     ),
//                                     Text(
//                                       S.of(context).pets_allowed,
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'Europa',
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 17),
//                                 Text(
//                                   S.of(context).max_occupants,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Europa',
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 TextFormField(
//                                   onFieldSubmitted: (v) {
//                                     FocusScope.of(context).unfocus();
//                                   },
//                                   onChanged: (enteredValue) {
//                                     maximumOccupants = int.parse(enteredValue);
//                                     setState(() {});
//                                   },
//                                   initialValue:
//                                       selectedBorrowAgreementTemplate != null
//                                           ? selectedBorrowAgreementTemplate
//                                                   .maximumOccupants ??
//                                               ''
//                                           : '',

//                                   decoration: InputDecoration(
//                                     hintText: S
//                                         .of(context)
//                                         .request_offer_agreement_hint_text,
//                                     hintStyle: TextStyle(
//                                         fontSize: 13, color: Colors.grey),
//                                     // labelText: 'No. of volunteers',
//                                   ),
//                                   keyboardType: TextInputType.number,
//                                   // validator: (value) {
//                                   //   if (value.isEmpty) {
//                                   //     return "Ex: 3";
//                                   //   } else {
//                                   //     maximumOccupants = int.parse(value);
//                                   //     setState(() {});
//                                   //     return null;
//                                   //   }
//                                   // },
//                                 ),
//                                 SizedBox(height: 17),
//                                 Text(
//                                   S.of(context).security_deposits,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Europa',
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 TextFormField(
//                                   onFieldSubmitted: (v) {
//                                     FocusScope.of(context).unfocus();
//                                   },
//                                   onChanged: (enteredValue) {
//                                     securityDeposit = int.parse(enteredValue);
//                                     setState(() {});
//                                   },
//                                   initialValue:
//                                       selectedBorrowAgreementTemplate != null
//                                           ? selectedBorrowAgreementTemplate
//                                                   .securityDeposit
//                                                   .toString() ??
//                                               ''
//                                           : '',

//                                   decoration: InputDecoration(
//                                     hintText: S
//                                         .of(context)
//                                         .request_offer_agreement_hint_text2,
//                                     hintStyle: TextStyle(
//                                         fontSize: 13, color: Colors.grey),
//                                     // labelText: 'No. of volunteers',
//                                   ),
//                                   keyboardType: TextInputType.number,
//                                   // validator: (value) {
//                                   //   if (value.isEmpty) {
//                                   //     return "Ex: 3";
//                                   //   } else {
//                                   //     maximumOccupants = int.parse(value);
//                                   //     setState(() {});
//                                   //     return null;
//                                   //   }
//                                   // },
//                                 ),
//                                 SizedBox(height: 17),
//                                 Text(
//                                   S.of(context).person_of_contact_details,
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Europa',
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 TextFormField(
//                                   onFieldSubmitted: (v) {
//                                     FocusScope.of(context).unfocus();
//                                   },
//                                   onChanged: (enteredValue) {
//                                     contactDetails = enteredValue;
//                                     setState(() {});
//                                   },
//                                   initialValue:
//                                       selectedBorrowAgreementTemplate != null
//                                           ? selectedBorrowAgreementTemplate
//                                                   .contactDetails ??
//                                               ''
//                                           : '',
//                                   decoration: InputDecoration(
//                                     hintText: S.of(context).request_title_hint,
//                                     hintStyle: TextStyle(
//                                         fontSize: 13, color: Colors.grey),
//                                     // labelText: 'No. of volunteers',
//                                   ),
//                                   keyboardType: TextInputType.text,
//                                   // validator: (value) {
//                                   //   if (value.isEmpty) {
//                                   //     return "Please enter document name";
//                                   //   } else {
//                                   //     documentName = value;
//                                   //     setState(() {});
//                                   //     return null;
//                                   //   }
//                                   // },
//                                 ),
//                                 SizedBox(height: 17),
//                                 otherDetailsWidget,
//                               ],
//                             ),

//                       SizedBox(height: 35),

//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 15),
//                                 child: Checkbox(
//                                   value: saveAsTemplate,
//                                   onChanged: (bool value) {
//                                     if (saveAsTemplate) {
//                                       setState(() {
//                                         saveAsTemplate = false;
//                                       });
//                                     } else {
//                                       _showSaveAsTemplateDialog()
//                                           .then((templateName) {
//                                         if (templateName != null) {
//                                           setState(() {
//                                             saveAsTemplate = true;
//                                           });
//                                         } else {
//                                           setState(() {
//                                             saveAsTemplate = false;
//                                           });
//                                         }
//                                       });
//                                     }
//                                   },
//                                 ),
//                               ),
//                               headingText(S.of(context).save_as_template),
//                             ],
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 20),

//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             alignment: Alignment.topCenter,
//                             decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.grey[300]),
//                             child: Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: Icon(
//                                 Icons.check,
//                                 size: 20.0,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: RichText(
//                               text: TextSpan(
//                                 style: TextStyle(
//                                     color: Colors.black45, fontSize: 14),
//                                 text: S.of(context).login_agreement_message1,
//                                 children: <TextSpan>[
//                                   emptyTextSpan(),
//                                   TextSpan(
//                                     text: S
//                                         .of(context)
//                                         .login_agreement_terms_link,
//                                     style: TextStyle(
//                                         color: Theme.of(context).primaryColor),
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = showTermsPage,
//                                   ),
//                                   emptyTextSpan(placeHolder: '.'),
//                                   // emptyTextSpan(),
//                                   TextSpan(
//                                     text:
//                                         S.of(context).login_agreement_message2,
//                                   ),
//                                   emptyTextSpan(),
//                                   TextSpan(
//                                     text: S
//                                         .of(context)
//                                         .login_agreement_privacy_link,
//                                     style: TextStyle(
//                                         color: Theme.of(context).primaryColor),
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = showPrivacyPolicyPage,
//                                   ),
//                                   emptyTextSpan(placeHolder: '.'),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: 25),

//                       useActionButtonWidget(),
//                       SizedBox(height: 25),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget get toolWidget {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 17),
//         documentNameTextField,
//         Text(
//           S.of(context).any_specific_conditions,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           onChanged: (enteredValue) {
//             specificConditions = enteredValue;
//           },
//           initialValue: selectedBorrowAgreementTemplate != null
//               ? selectedBorrowAgreementTemplate.specificConditions ?? ''
//               : '',

//           decoration: InputDecoration(
//             hintMaxLines: 3,
//             hintText: S.of(context).item_returned_hint_text,
//             hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.text,
//           // validator: (value) {
//           //   if (value.isEmpty) {
//           //     return "Please enter specific conditions";
//           //   } else {
//           //     specificConditions = value;
//           //     return null;
//           //   }
//           // },
//         ),
//         SizedBox(height: 17),
//         Text(
//           S.of(context).description_of_item,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           onChanged: (enteredValue) {
//             itemDescription = enteredValue;
//           },
//           initialValue: selectedBorrowAgreementTemplate != null
//               ? selectedBorrowAgreementTemplate.itemDescription ?? ''
//               : '',

//           decoration: InputDecoration(
//             hintMaxLines: 3,
//             hintText: S.of(context).request_offer_agreement_hint_text3,
//             hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.text,
//           // validator: (value) {
//           //   if (value.isEmpty) {
//           //     return "Please enter specific conditions";
//           //   } else {
//           //     specificConditions = value;
//           //     return null;
//           //   }
//           // },
//         ),
//         SizedBox(height: 17),
//         Text(
//           S.of(context).request_offer_agreement_tool_widget_text,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           onChanged: (enteredValue) {
//             additionalConditions = enteredValue;
//           },
//           initialValue: selectedBorrowAgreementTemplate != null
//               ? selectedBorrowAgreementTemplate.additionalConditions ?? ''
//               : '',

//           decoration: InputDecoration(
//             hintMaxLines: 3,
//             hintText: S.of(context).request_offer_agreement_hint_text4,
//             hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.text,
//           // validator: (value) {
//           //   if (value.isEmpty) {
//           //     return "Please enter specific conditions";
//           //   } else {
//           //     specificConditions = value;
//           //     return null;
//           //   }
//           // },
//         ),
//         SizedBox(height: 17),
//         otherDetailsWidget,
//       ],
//     );
//   }

//   Widget get documentNameTextField {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           S.of(context).document_name,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           onChanged: (enteredValue) {
//             documentName = enteredValue;
//           },
//           initialValue: selectedBorrowAgreementTemplate != null
//               ? selectedBorrowAgreementTemplate.documentName
//               : '',
//           decoration: InputDecoration(
//             hintText: S.of(context).request_title_hint,
//             hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.text,
//           validator: (value) {
//             if (value.isEmpty) {
//               return S.of(context).please_enter_doc_name;
//             } else {
//               documentName = value;
//               return null;
//             }
//           },
//         ),
//       ],
//     );
//   }

//   Widget get otherDetailsWidget {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           S.of(context).other_details,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Europa',
//             color: Colors.black,
//           ),
//         ),
//         TextFormField(
//           onFieldSubmitted: (v) {
//             FocusScope.of(context).unfocus();
//           },
//           onChanged: (enteredValue) {
//             otherDetails = enteredValue;
//             setState(() {});
//           },
//           initialValue: selectedBorrowAgreementTemplate != null
//               ? selectedBorrowAgreementTemplate.otherDetails ?? ''
//               : '',

//           decoration: InputDecoration(
//             hintMaxLines: 11,
//             hintText: S.of(context).request_offer_agreement_hint_text5,
//             hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
//             // labelText: 'No. of volunteers',
//           ),
//           keyboardType: TextInputType.text,
//           // validator: (value) {
//           //   if (value.isEmpty) {
//           //     return "Please enter specific conditions";
//           //   } else {
//           //     specificConditions = value;
//           //     setState(() {});
//           //     return null;
//           //   }
//           // },
//         ),
//       ],
//     );
//   }

//   Widget get noAgreementWidget {
//     return Padding(
//         padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(height: 14),
//             agreementText,
//             SizedBox(height: 15),

//             //Radio Buttons
//             _optionRadioButtonMain<String>(
//               title: S.of(context).create_new,
//               value: AgreementDocumentType.NEW.readable,
//               groupvalue: agreementDocumentType,
//               onChanged: (value) {
//                 agreementDocumentType = value;
//                 saveAsTemplate = false;
//                 setState(() => {});
//               },
//             ),
//             _optionRadioButtonMain<String>(
//               title: S.of(context).choose_previous_agreement,
//               value: AgreementDocumentType.TEMPLATE.readable,
//               groupvalue: agreementDocumentType,
//               onChanged: (value) {
//                 agreementDocumentType = value;
//                 setState(() => {});
//               },
//             ),
//             _optionRadioButtonMain<String>(
//               title: S.of(context).no_agrreement,
//               value: AgreementDocumentType.NO_AGREEMENT.readable,
//               groupvalue: agreementDocumentType,
//               onChanged: (value) {
//                 agreementDocumentType = value;
//                 saveAsTemplate = false;
//                 setState(() => {});
//               },
//             ),

//             SizedBox(height: 25),
//             useActionButtonWidget(),
//             SizedBox(height: 25),
//           ],
//         ));
//   }

//   Widget get agreementText {
//     return Text(S.of(context).agreement,
//         style: TextStyle(
//           fontSize: 17,
//           fontWeight: FontWeight.w600,
//         ),
//         textAlign: TextAlign.start);
//   }

//   Widget useActionButtonWidget() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Container(
//           height: 37,
//           width: 150,
//           child: CustomElevatedButton(
//               padding: EdgeInsets.only(left: 11, right: 11),
//               color: Theme.of(context).primaryColor,
//               child: Text(
//                 S.of(context).use,
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               onPressed: () async {
//                 if (agreementDocumentType ==
//                     AgreementDocumentType.NO_AGREEMENT.readable) {
//                   widget.onPdfCreated(borrowAgreementLinkFinal, documentName);
//                   Navigator.of(context).pop();
//                 } else {
//                   if (_formKey.currentState.validate()) {
//                     if (saveAsTemplate) {
//                       borrowAgreementTemplateModel.documentName = documentName;
//                       borrowAgreementTemplateModel.id = Utils.getUuid();
//                       borrowAgreementTemplateModel.timebankId =
//                           widget.timebankId;
//                       borrowAgreementTemplateModel.communityId =
//                           widget.communityId;
//                       borrowAgreementTemplateModel.createdAt =
//                           DateTime.now().millisecondsSinceEpoch;
//                       borrowAgreementTemplateModel.isRequest = widget.isRequest;
//                       borrowAgreementTemplateModel.roomOrTool =
//                           widget.roomOrTool;
//                       borrowAgreementTemplateModel.additionalConditions =
//                           additionalConditions ?? '';
//                       borrowAgreementTemplateModel.contactDetails =
//                           contactDetails ?? "";
//                       borrowAgreementTemplateModel.itemDescription =
//                           itemDescription;
//                       borrowAgreementTemplateModel.maximumOccupants =
//                           maximumOccupants ?? 0;
//                       borrowAgreementTemplateModel.specificConditions =
//                           specificConditions;
//                       borrowAgreementTemplateModel.softDelete = false;
//                       borrowAgreementTemplateModel.otherDetails = otherDetails;
//                       borrowAgreementTemplateModel.securityDeposit =
//                           securityDeposit;
//                       borrowAgreementTemplateModel.templateName = templateName;
//                       borrowAgreementTemplateModel.isFixedTerm =
//                           isFixedTerm ?? true;
//                       borrowAgreementTemplateModel.isPetsAllowed =
//                           isPetsAllowed;
//                       borrowAgreementTemplateModel.isQuietHoursAllowed =
//                           isQuietHoursAllowed;
//                       await FirestoreManager.createBorrowAgreementTemplate(
//                           agreementTemplateModel: borrowAgreementTemplateModel);
//                     }
//                     // Step 1
//                     //if save as template option is true, store template data in
//                     //   collection 'borrowAgreement_templates'

//                     //       Step 2
//                     //     2.1 - Generate agreement pdf according to template (pending)
//                     //   2.2 - Then store pdf in Storage and obtain download url

//                     borrowAgreementLinkFinal = await BorrowAgreementPdf()
//                         .borrowAgreementPdf(
//                             context,
//                             widget.requestModel,
//                             documentName,
//                             widget.isRequest,
//                             widget.roomOrTool,
//                             otherDetails,
//                             specificConditions,
//                             itemDescription,
//                             additionalConditions,
//                             isFixedTerm,
//                             isQuietHoursAllowed,
//                             isPetsAllowed,
//                             maximumOccupants,
//                             securityDeposit,
//                             contactDetails);

//                     widget.onPdfCreated(borrowAgreementLinkFinal, documentName);

//                     Navigator.of(context).pop;
//                   }
//                 }
//               }),
//         ),
//       ],
//     );
//   }

//   Future openPdfViewer(String pdfURL, String documentName) {
//     progressDialog = ProgressDialog(
//       context,
//       type: ProgressDialogType.Normal,
//       isDismissible: true,
//     );
//     progressDialog.show();
//     createFileOfPdfUrl(pdfURL, documentName).then((f) {
//       progressDialog.hide();
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => PDFScreen(
//                   docName: documentName,
//                   pathPDF: f.path,
//                   isFromFeeds: false,
//                   isDownloadable: false,
//                 )),
//       );
//     });
//   }

//   void showTermsPage() {
//     var dynamicLinks = json.decode(
//       AppConfig.remoteConfig.getString(
//         "links_" + S.of(context).localeName,
//       ),
//     );

//     navigateToWebView(
//       aboutMode: AboutMode(
//           title: S.of(context).login_agreement_terms_link,
//           urlToHit: dynamicLinks['termsAndConditionsLink']),
//       context: context,
//     );
//   }

//   void showPrivacyPolicyPage() {
//     var dynamicLinks = json.decode(
//       AppConfig.remoteConfig.getString(
//         "links_" + S.of(context).localeName,
//       ),
//     );
//     navigateToWebView(
//       aboutMode: AboutMode(
//           title: S.of(context).login_agreement_privacy_link,
//           urlToHit: dynamicLinks['privacyPolicyLink']),
//       context: context,
//     );
//   }

//   void showPaymentPolicyPage() {
//     var dynamicLinks = json.decode(
//       AppConfig.remoteConfig.getString(
//         "links_" + S.of(context).localeName,
//       ),
//     );
//     navigateToWebView(
//       aboutMode: AboutMode(
//           title: S.of(context).login_agreement_payment_link,
//           urlToHit: dynamicLinks['paymentPolicyLink']),
//       context: context,
//     );
//   }

//   Widget _optionRadioButtonMain<T>({
//     String title,
//     T value,
//     T groupvalue,
//     Function onChanged,
//     bool isEnabled = true,
//   }) {
//     return ListTile(
//       key: UniqueKey(),
//       contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
//       title: Text(title),
//       leading: Radio<T>(
//         activeColor: Theme.of(context).primaryColor,
//         value: value,
//         groupValue: groupvalue,
//         onChanged: (isEnabled ?? true) ? onChanged : null,
//       ),
//     );
//   }

//   Widget _optionRadioButtonRoomForm<T>({
//     String title,
//     T value,
//     T groupvalue,
//     Function onChanged,
//     bool isEnabled = true,
//   }) {
//     return ListTile(
//       dense: true,
//       key: UniqueKey(),
//       contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
//       title: Text(
//         title,
//         style: TextStyle(fontSize: 13),
//       ),
//       leading: Radio<T>(
//         value: value,
//         groupValue: groupvalue,
//         onChanged: (isEnabled ?? true) ? onChanged : null,
//       ),
//     );
//   }

//   Widget searchFieldWidget() {
//     if (agreementDocumentType != AgreementDocumentType.TEMPLATE.readable) {
//       return Container();
//     }
//     return Padding(
//       padding: const EdgeInsets.only(left: 30, right: 10),
//       child: TextFormField(
//         controller: searchTextController,
//         decoration: InputDecoration(
//           isDense: true,

//           // labelText: "Enter Email",
//           hintText: S.of(context).search_template_hint,
//           fillColor: Colors.white,

//           alignLabelWithHint: true,
//           prefixIcon: Icon(
//             Icons.search,
//             size: 20,
//             color: Colors.grey,
//           ),
//           contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 10.0),

//           suffixIcon: Offstage(
//             offstage: searchTextController.text.length == 0,
//             child: IconButton(
//               splashColor: Colors.transparent,
//               icon: Icon(
//                 Icons.clear,
//                 color: Colors.black54,
//               ),
//               onPressed: () {
//                 //searchTextController.clear();
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   searchTextController.clear();
//                   //if (selectedProjectTemplate != null) {
//                   //  selectedProjectTemplate = null;
//                   //}
//                 });
//               },
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.0),
//             borderSide: BorderSide(
//               color: Colors.grey,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10.0),
//             borderSide: BorderSide(
//               color: Colors.grey,
//               width: 1.0,
//             ),
//           ),
//         ),
//         keyboardType: TextInputType.text,
//         textCapitalization: TextCapitalization.sentences,
//         style: TextStyle(fontSize: 16.0),
//         inputFormatters: [
//           LengthLimitingTextInputFormatter(50),
//         ],
//       ),
//     );
//   }

//   Widget buildTemplateWidget() {
//     if (agreementDocumentType != AgreementDocumentType.TEMPLATE.readable) {
//       return Container();
//     } else if (searchTextController.text.trim().length < 3) {
//       return getEmptyWidget(
//           S.of(context).validation_error_search_min_characters);
//     } else {
//       return StreamBuilder<List<BorrowAgreementTemplateModel>>(
//         stream: SearchManager.searchBorrowAgreementTemplate(
//             queryString: searchTextController.text),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             Text(snapshot.error.toString());
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: SizedBox(
//                 height: 25,
//                 width: 25,
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           List<BorrowAgreementTemplateModel> borrowAgreementTemplateList =
//               snapshot.data;

//           if (borrowAgreementTemplateList == null ||
//               borrowAgreementTemplateList.length == 0) {
//             return getEmptyWidget(S.of(context).no_templates_found);
//           }
//           return ListView.builder(
//             shrinkWrap: true,
//             itemCount: borrowAgreementTemplateList.length,
//             itemBuilder: (context, index) {
//               BorrowAgreementTemplateModel borrowAgreementTemplateModel =
//                   borrowAgreementTemplateList[index];
//               return RadioListTile(
//                 value: index,
//                 groupValue: value,
//                 activeColor: primaryColor,
//                 onChanged: (ind) => setState(() {
//                   value = ind;
//                   selectedBorrowAgreementTemplate =
//                       borrowAgreementTemplateList[ind];
//                 }),
//                 title: Text(borrowAgreementTemplateModel.templateName),
//               );
//             },
//           );
//         },
//       );
//     }
//   }

//   Widget getEmptyWidget(String notFoundValue) {
//     return Center(
//       child: Text(
//         notFoundValue,
//         overflow: TextOverflow.ellipsis,
//         style: sectionHeadingStyle,
//       ),
//     );
//   }

//   TextStyle get sectionHeadingStyle {
//     return TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 12.5,
//       color: Colors.black,
//     );
//   }

//   Widget headingText(String name) {
//     return Padding(
//       padding: EdgeInsets.only(top: 15),
//       child: Text(
//         name,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   Future<String> _showSaveAsTemplateDialog() {
//     return showDialog<String>(
//         context: context,
//         builder: (BuildContext viewContext) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//                 // borderRadius: BorderRadius.all(
//                 //   Radius.circular(25.0),
//                 // ),
//                 ),
//             child: Form(
//               key: _formDialogKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Container(
//                     height: 50,
//                     width: double.infinity,
//                     color: FlavorConfig.values.theme.primaryColor,
//                     child: Center(
//                       child: Text(
//                         S.of(context).template_title,
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontFamily: 'Europa'),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 15,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 10, right: 10),
//                     child: Container(
//                       child: TextFormField(
//                         controller: searchTextController2,
//                         decoration: InputDecoration(
//                           hintMaxLines: 2,
//                           border: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               const Radius.circular(0.0),
//                             ),
//                             borderSide: BorderSide(
//                               color: Colors.black,
//                               width: 1.0,
//                             ),
//                           ),
//                           contentPadding:
//                               EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
//                           hintText: S.of(context).template_hint,
//                         ),
//                         keyboardType: TextInputType.text,
//                         textCapitalization: TextCapitalization.sentences,
//                         style: TextStyle(fontSize: 17.0),
//                         inputFormatters: [
//                           LengthLimitingTextInputFormatter(50),
//                         ],
//                         onChanged: (value) {
//                           ExitWithConfirmation.of(context).fieldValues[5] =
//                               value;
//                         },
//                         validator: (value) {
//                           if (value.isEmpty) {
//                             return S.of(context).validation_error_template_name;
//                           } else if (templateFound) {
//                             return S
//                                 .of(context)
//                                 .validation_error_template_name_exists;
//                           } else {
//                             templateName = value;
//                             return null;
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 25,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: <Widget>[
//                       CustomTextButton(
//                         onPressed: () {
//                           Navigator.pop(viewContext);
//                         },
//                         child: Text(
//                           S.of(context).cancel,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Europa'),
//                         ),
//                         textColor: Colors.grey,
//                       ),
//                       CustomTextButton(
//                         child: Text(S.of(context).save,
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Europa')),
//                         textColor: FlavorConfig.values.theme.primaryColor,
//                         onPressed: () async {
//                           if (!_formDialogKey.currentState.validate()) {
//                             return;
//                           }
//                           Navigator.pop(viewContext, templateName);
//                         },
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 15,
//                   )
//                 ],
//               ),
//             ),
//           );
//         });
//   }
// }

// enum AgreementDocumentType {
//   NEW,
//   TEMPLATE,
//   NO_AGREEMENT,
//   //PDF_UPLOAD   (to be decided)
// }

// extension AgreementDocumentTypeLabel on AgreementDocumentType {
//   String get readable {
//     switch (this) {
//       case AgreementDocumentType.NEW:
//         return 'NEW';
//       case AgreementDocumentType.TEMPLATE:
//         return 'TEMPLATE';
//       case AgreementDocumentType.NO_AGREEMENT:
//         return 'NO_AGREEMENT';
//       default:
//         return 'NEW';
//     }
//   }
// }
