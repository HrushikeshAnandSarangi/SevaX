import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:doseform/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/components/pdf_screen.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/agreement_form__selection_model.dart';
import 'package:sevaexchange/models/agreement_template_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/community/webview_seva.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/empty_text_span.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:flutter/material.dart' as prefix0;

class AgreementForm extends StatefulWidget {
  final RequestModel requestModel;
  final bool isOffer;
  final String placeOrItem;
  final LendingModel lendingModel;
  final List<LendingModel> lendingModelListBorrowRequest;
  final String timebankId;
  final String communityId;
  final int startTime;
  final int endTime;
  final void Function(String borrowAgreementLinkFinal, String documentName,
      Map<String, dynamic> agreementConfig, String agreementId) onPdfCreated;

  AgreementForm({
    required this.requestModel,
    required this.isOffer,
    required this.placeOrItem,
    required this.timebankId,
    required this.communityId,
    required this.onPdfCreated,
    required this.lendingModel,
    required this.lendingModelListBorrowRequest,
    required this.startTime,
    required this.endTime,
  });

  @override
  _OfferAgreementFormState createState() => _OfferAgreementFormState();
}

class _OfferAgreementFormState extends State<AgreementForm> {
  String agreementDocumentType = AgreementDocumentType.NEW.readable;
  prefix0.TextEditingController searchTextController = TextEditingController();
  prefix0.TextEditingController searchTextController2 = TextEditingController();
  prefix0.TextEditingController specificConditionsController =
      TextEditingController();
  prefix0.TextEditingController documentNameController =
      TextEditingController();
  Color primaryColor = FlavorConfig.values.theme!.primaryColor;
  AgreementTemplateModel? selectedAgreementTemplate;
  AgreementTemplateModel agreementTemplateModel = AgreementTemplateModel();
  AgreementFormSelectionModel agreementFormSelectionModel =
      AgreementFormSelectionModel();
  bool saveAsTemplate = false;
  String templateName = '';
  bool templateFound = false;
  int? value;
  FocusNode documentNameNode = FocusNode();
  FocusNode specificConditionNode = FocusNode();
  FocusNode searchFocusNode = FocusNode();

// Form Related Values
  String documentName = '';
  bool isDamageLiability = false;
  bool isUseDisclaimer = false;
  bool isDeliveryReturn = false;
  bool isMaintainRepair = false;
  bool isRefundDepositNeeded = false;
  bool isMaintainAndclean = false;
  String specificConditions = '';
  String otherDetails = '';
  String agreementLink = '';
  String agreementId = '';
  Map<String, dynamic> agreementConfig = {};
  // String otherDetails = '';

  final formKey = GlobalKey<DoseFormState>();
  final _formKeyElastic = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final _formDialogKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final _debouncer = Debouncer(milliseconds: 600);

    searchTextController2.addListener(() {
      _debouncer.run(() {
        String s = searchTextController2.text;

        if (s.isEmpty) {
        } else {
          if (templateName != s) {
            setState(() {});
            SearchManager.searchAgrrementTemplateForDuplicate(
                    queryString: s.trim())
                .catchError((onError) {
              templateFound = false;
            }).then((commFound) {
              if (commFound) {
                setState(() {
                  templateFound = true;
                });
              } else {
                setState(() {
                  templateFound = false;
                });
              }
            });
          }
        }
      });
    });

    //  searchTextController2
    //     .addListener(() => _textUpdates2.add(searchTextController2.text));

    // Observable(_textUpdates2.stream)
    //     .debounceTime(Duration(milliseconds: 400))
    //     .forEach((s) {
    //   if (s.isEmpty) {
    //   } else {
    //     if (templateName != s) {
    //       SearchManager.searchAgrrementTemplateForDuplicate(queryString: s)
    //           .then((commFound) {
    //         if (commFound) {
    //           setState(() {
    //             templateFound = true;
    //           });
    //         } else {
    //           setState(() {
    //             templateFound = false;
    //           });
    //         }
    //       });
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    log('TYPE: ' + agreementDocumentType);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // resizeToAvoidBottomPadding: true,
      key: _key,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          widget.placeOrItem == LendingType.PLACE.readable
              ? S.of(context).choose_place_agreement
              : S.of(context).choose_item_agreement,
          style: TextStyle(
              fontFamily: "Europa", fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: (agreementDocumentType ==
                AgreementDocumentType.NO_AGREEMENT.readable)
            ? noAgreementWidget
            : Padding(
                padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
                child: DoseForm(
                  formKey: formKey,
                  child: prefix0.Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 14),

                      agreementText,

                      SizedBox(height: 15),

                      //Radio Buttons
                      _optionRadioButtonMain<String>(
                        title: S.of(context).create_new,
                        value: AgreementDocumentType.NEW.readable,
                        groupvalue: agreementDocumentType,
                        onChanged: (value) {
                          agreementDocumentType = value;
                          saveAsTemplate = false;
                          searchTextController.clear();
                          specificConditionsController.clear();
                          documentNameController.clear();
                          selectedAgreementTemplate = null;
                          setState(() => {});
                        },
                      ),
                      _optionRadioButtonMain<String>(
                        title: S.of(context).choose_previous_agreement,
                        value: AgreementDocumentType.TEMPLATE.readable,
                        groupvalue: agreementDocumentType,
                        onChanged: (value) {
                          agreementDocumentType = value;
                          setState(() => {});
                        },
                      ),

                      //Below two widgets for previous templates created
                      agreementDocumentType ==
                              AgreementDocumentType.TEMPLATE.readable
                          ? searchFieldWidget()
                          : Container(),

                      agreementDocumentType ==
                              AgreementDocumentType.TEMPLATE.readable
                          ? buildTemplateWidget()
                          : Container(),

                      _optionRadioButtonMain<String>(
                        title: S.of(context).no_agrreement,
                        value: AgreementDocumentType.NO_AGREEMENT.readable,
                        groupvalue: agreementDocumentType,
                        onChanged: (value) {
                          agreementDocumentType = value;
                          saveAsTemplate = false;
                          searchTextController.clear();
                          specificConditionsController.clear();
                          documentNameController.clear();
                          selectedAgreementTemplate = null;
                          setState(() => {});
                        },
                      ),

                      //Text Fields
                      SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          documentNameTextFieldWidget,
                          SizedBox(height: 17),
                          Text(
                            S.of(context).borrower_responsibilities,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            S.of(context).borrower_responsibilities_subtext,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Europa',
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).liability_damage,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Europa',
                                  color: Colors.black,
                                ),
                              ),
                              infoButton(
                                context: context,
                                key: GlobalKey(),
                                type: InfoType.Borrow_Liability_For_Damage,
                              ),
                              Spacer(),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.green,
                                value: selectedAgreementTemplate != null
                                    ? selectedAgreementTemplate!
                                            .isDamageLiability ??
                                        isDamageLiability
                                    : isDamageLiability,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isDamageLiability = newValue ?? false;
                                    if (selectedAgreementTemplate != null) {
                                      selectedAgreementTemplate!
                                              .isDamageLiability =
                                          newValue ?? false;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).use_disclaimer,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Europa',
                                  color: Colors.black,
                                ),
                              ),
                              infoButton(
                                context: context,
                                key: GlobalKey(),
                                type: InfoType.Borrow_Use_Disclaimer,
                              ),
                              Spacer(),
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: Colors.green,
                                value: selectedAgreementTemplate != null
                                    ? selectedAgreementTemplate!
                                            .isUseDisclaimer ??
                                        isUseDisclaimer
                                    : isUseDisclaimer,
                                onChanged: (value) {
                                  setState(() {
                                    isUseDisclaimer = value!;
                                    if (selectedAgreementTemplate != null) {
                                      selectedAgreementTemplate!
                                          .isUseDisclaimer = value;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          widget.placeOrItem == LendingType.ITEM.readable
                              ? Row(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).delivery_return_equipment,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                        color: Colors.black,
                                      ),
                                    ),
                                    infoButton(
                                      context: context,
                                      key: GlobalKey(),
                                      type: InfoType.Borrow_Delivery_Return,
                                    ),
                                    Spacer(),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      value: selectedAgreementTemplate != null
                                          ? selectedAgreementTemplate!
                                                  .isDeliveryReturn ??
                                              isDeliveryReturn
                                          : isDeliveryReturn,
                                      onChanged: (value) {
                                        setState(() {
                                          isDeliveryReturn = value!;
                                          if (selectedAgreementTemplate !=
                                              null) {
                                            selectedAgreementTemplate!
                                                .isDeliveryReturn = value;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).refund_deposit,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                        color: Colors.black,
                                      ),
                                    ),
                                    infoButton(
                                      context: context,
                                      key: GlobalKey(),
                                      type: InfoType.Borrow_Refund_Deposit,
                                    ),
                                    Spacer(),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      value: selectedAgreementTemplate != null
                                          ? selectedAgreementTemplate!
                                                  .isRefundDepositNeeded ??
                                              isRefundDepositNeeded
                                          : isRefundDepositNeeded,
                                      onChanged: (value) {
                                        setState(() {
                                          isRefundDepositNeeded = value!;
                                          if (selectedAgreementTemplate !=
                                              null) {
                                            selectedAgreementTemplate!
                                                .isRefundDepositNeeded = value;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                          widget.placeOrItem == LendingType.ITEM.readable
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).maintain_repair,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                        color: Colors.black,
                                      ),
                                    ),
                                    infoButton(
                                      context: context,
                                      key: GlobalKey(),
                                      type: InfoType.Borrow_Maintain_Repair,
                                    ),
                                    Spacer(),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      value: selectedAgreementTemplate != null
                                          ? selectedAgreementTemplate!
                                                  .isMaintainRepair ??
                                              isMaintainRepair
                                          : isMaintainRepair,
                                      onChanged: (value) {
                                        setState(() {
                                          isMaintainRepair = value!;
                                          if (selectedAgreementTemplate !=
                                              null) {
                                            selectedAgreementTemplate!
                                                .isMaintainRepair = value;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      S.of(context).maintain_clean,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Europa',
                                        color: Colors.black,
                                      ),
                                    ),
                                    infoButton(
                                      context: context,
                                      key: GlobalKey(),
                                      type: InfoType.Borrow_Maintain_Clean,
                                    ),
                                    Spacer(),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.green,
                                      value: selectedAgreementTemplate != null
                                          ? selectedAgreementTemplate!
                                                  .isMaintainAndclean ??
                                              isMaintainAndclean
                                          : isMaintainAndclean,
                                      onChanged: (value) {
                                        setState(() {
                                          isMaintainAndclean = value!;
                                          if (selectedAgreementTemplate !=
                                              null) {
                                            selectedAgreementTemplate!
                                                .isMaintainAndclean = value;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                          SizedBox(height: 17),
                          Text(
                            S.of(context).any_specific_conditions,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa',
                              color: Colors.black,
                            ),
                          ),
                          DoseTextField(
                            isRequired: false,
                            focusNode: specificConditionNode,
                            maxLines: 3,
                            onFieldSubmitted: (v) {
                              FocusScope.of(context).unfocus();
                            },
                            onChanged: (enteredValue) {
                              specificConditions = enteredValue;
                              setState(() {});
                            },
                            // initialValue: specificConditions,
                            controller: specificConditionsController,
                            decoration: InputDecoration(
                              hintText: widget.placeOrItem ==
                                      LendingType.PLACE.readable
                                  ? S.of(context).place_returned_hint_text
                                  : S.of(context).item_returned_hint_text,
                              hintStyle:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                              // labelText: 'No. of volunteers',
                            ),
                            keyboardType: TextInputType.text,
                            // validator: (value) {
                            //   if (value.isEmpty) {
                            //     return "Please enter document name";
                            //   } else {
                            //     documentName = value;
                            //     setState(() {});
                            //     return null;
                            //   }
                            // },
                          ),
                        ],
                      ),

                      SizedBox(height: width * 0.037),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Checkbox(
                                  value: saveAsTemplate,
                                  onChanged: (bool? value) {
                                    _showSaveAsTemplateDialog()
                                        .then((templateName) {
                                      if (templateName != null) {
                                        setState(() {
                                          saveAsTemplate = value ?? false;
                                        });
                                      } else {
                                        setState(() {
                                          saveAsTemplate = false;
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                              headingText(S.of(context).save_as_template),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: width * 0.04),

                      Container(
                        width: width * 0.80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300]),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.check,
                                  size: 20.0,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                  text: S.of(context).seva_exchange_text_new,
                                  children: <TextSpan>[
                                    emptyTextSpan(),
                                    TextSpan(
                                      text: S
                                          .of(context)
                                          .login_agreement_terms_link,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = showTermsPage,
                                    ),
                                    emptyTextSpan(placeHolder: '.'),
                                    // emptyTextSpan(),
                                    TextSpan(
                                      text: ' ' +
                                          S
                                              .of(context)
                                              .agree_to_signature_legal_text +
                                          S
                                              .of(context)
                                              .login_agreement_message2,
                                    ),
                                    emptyTextSpan(),
                                    TextSpan(
                                      text: S
                                          .of(context)
                                          .login_agreement_privacy_link,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = showPrivacyPolicyPage,
                                    ),
                                    emptyTextSpan(placeHolder: '.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: width * 0.06),
                      useActionButtonWidget(),
                      SizedBox(height: width * 0.05),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget get documentNameTextFieldWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).document_name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        DoseTextField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          isRequired: true,
          focusNode: documentNameNode,
          controller: documentNameController,
          onFieldSubmitted: (v) {
            FocusScope.of(context).unfocus();
          },
          onChanged: (enteredValue) {
            documentName = enteredValue;
            setState(() {});
          },
          // initialValue: documentName,
          decoration: InputDecoration(
            hintText: widget.placeOrItem == LendingType.PLACE.readable
                ? S.of(context).place_agreement_name_hint_place
                : S.of(context).place_agreement_name_hint_item,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
            // labelText: 'No. of volunteers',
          ),
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value!.isEmpty) {
              return S.of(context).please_enter_doc_name;
            } else {
              documentName = value;
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget get noAgreementWidget {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 14),
            agreementText,
            SizedBox(height: 15),

            //Radio Buttons
            _optionRadioButtonMain<String>(
              title: S.of(context).create_new,
              value: AgreementDocumentType.NEW.readable,
              groupvalue: agreementDocumentType,
              onChanged: (value) {
                agreementDocumentType = value;
                saveAsTemplate = false;
                searchTextController.clear();
                specificConditionsController.clear();
                documentNameController.clear();
                selectedAgreementTemplate = null;
                setState(() => {});
              },
            ),
            _optionRadioButtonMain<String>(
              title: S.of(context).choose_previous_agreement,
              value: AgreementDocumentType.TEMPLATE.readable,
              groupvalue: agreementDocumentType,
              onChanged: (value) {
                agreementDocumentType = value;
                setState(() => {});
              },
            ),

            _optionRadioButtonMain<String>(
              title: S.of(context).no_agrreement,
              value: AgreementDocumentType.NO_AGREEMENT.readable,
              groupvalue: agreementDocumentType,
              onChanged: (value) {
                agreementDocumentType = value;
                saveAsTemplate = false;
                searchTextController.clear();
                specificConditionsController.clear();
                documentNameController.clear();
                selectedAgreementTemplate = null;
                setState(() => {});
              },
            ),

            SizedBox(height: 25),
            useActionButtonWidget(),
            SizedBox(height: 25),
          ],
        ));
  }

  Widget get agreementText {
    return Text(S.of(context).agreement,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.start);
  }

  Widget useActionButtonWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 37,
          width: 150,
          child: CustomElevatedButton(
              padding: EdgeInsets.only(left: 11, right: 11),
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                S.of(context).use.sentenceCase(),
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () async {
                //generate 8 digit alphanumeric code for AgreementId
                agreementId = createCryptoRandomString();
                if (agreementDocumentType ==
                    AgreementDocumentType.NO_AGREEMENT.readable) {
                  //update text on voidcallback funtion for previous page that no agreement was selected
                  widget.onPdfCreated(
                      agreementLink, documentName, {}, agreementId);
                  Navigator.of(context).pop();
                } else {
                  if (agreementDocumentType ==
                      AgreementDocumentType.TEMPLATE.readable) {
                    if (selectedAgreementTemplate == null) {
                      searchFocusNode.requestFocus();
                      return;
                    }
                    //update on voidcallback the final model details (check also if user has edited anything from template prefilled data)
                    logger.e("MODEL 2:  " + widget.lendingModel.toString());
                    agreementLink =
                        await BorrowAgreementPdf().borrowAgreementPdf(
                      context,
                      widget.requestModel,
                      widget.lendingModel,
                      widget.lendingModelListBorrowRequest != null
                          ? widget.lendingModelListBorrowRequest
                          : null!,
                      '',
                      documentName,
                      widget.isOffer,
                      widget.startTime,
                      widget.endTime,
                      widget.placeOrItem,
                      specificConditions,
                      isDamageLiability,
                      isUseDisclaimer,
                      isDeliveryReturn,
                      isMaintainRepair,
                      isRefundDepositNeeded,
                      isMaintainAndclean,
                      agreementId,
                    );
                    agreementConfig = {
                      'specificConditions': specificConditions,
                      'isDamageLiability': isDamageLiability,
                      'isUseDisclaimer': isUseDisclaimer,
                      'isDeliveryReturn': isDeliveryReturn,
                      'isMaintainRepair': isMaintainRepair,
                      'isRefundDepositNeeded': isRefundDepositNeeded,
                      'isMaintainAndclean': isMaintainAndclean,
                    };
                    widget.onPdfCreated(agreementLink, documentName,
                        agreementConfig, agreementId);

                    Navigator.of(context).pop();
                  } else {
                    if (formKey.currentState!.validate()) {
                      // <<<-- First - Check and Save Template
                      if (saveAsTemplate) {
                        agreementTemplateModel.documentName = documentName;
                        agreementTemplateModel.templateName = templateName;
                        agreementTemplateModel.creatorEmail =
                            SevaCore.of(context).loggedInUser.email;
                        agreementTemplateModel.creatorId =
                            SevaCore.of(context).loggedInUser.sevaUserID;
                        agreementTemplateModel.id = Utils.getUuid();
                        agreementTemplateModel.timebankId = widget.timebankId;
                        agreementTemplateModel.communityId = widget.communityId;
                        agreementTemplateModel.createdAt =
                            DateTime.now().millisecondsSinceEpoch;
                        agreementTemplateModel.isOffer = widget.isOffer;
                        agreementTemplateModel.placeOrItem = widget.placeOrItem;
                        agreementTemplateModel.isDamageLiability =
                            isDamageLiability;
                        agreementTemplateModel.isUseDisclaimer =
                            isUseDisclaimer;

                        if (widget.placeOrItem == LendingType.ITEM.readable) {
                          agreementTemplateModel.isDeliveryReturn =
                              isDeliveryReturn;
                          agreementTemplateModel.isMaintainRepair =
                              isMaintainRepair;
                        } else {
                          agreementTemplateModel.isRefundDepositNeeded =
                              isRefundDepositNeeded;
                          agreementTemplateModel.isMaintainAndclean =
                              isMaintainAndclean;
                        }

                        agreementTemplateModel.specificConditions =
                            specificConditions;
                        agreementTemplateModel.softDelete = false;

                        agreementTemplateModel.otherDetails = otherDetails;

                        await FirestoreManager.createBorrowAgreementTemplate(
                            agreementTemplateModel: agreementTemplateModel);

                        log('TEMPLATE SAVED');
                      }
                      // <<<-- Second - Save Form agreementFormSelectionModel as Map in LendingOfferModel ---->>>

                      agreementLink =
                          await BorrowAgreementPdf().borrowAgreementPdf(
                        context,
                        widget.requestModel,
                        widget.lendingModel,
                        widget.lendingModelListBorrowRequest != null
                            ? widget.lendingModelListBorrowRequest
                            : null!,
                        '',
                        documentName,
                        widget.isOffer,
                        widget.startTime,
                        widget.endTime,
                        widget.placeOrItem,
                        specificConditions,
                        isDamageLiability,
                        isUseDisclaimer,
                        isDeliveryReturn,
                        isMaintainRepair,
                        isRefundDepositNeeded,
                        isMaintainAndclean,
                        agreementId,
                      );

                      logger.e('COMES Here 1.5 PDF Link:  ' +
                          agreementLink.toString());
                      agreementConfig = {
                        'specificConditions': specificConditions,
                        'isDamageLiability': isDamageLiability,
                        'isUseDisclaimer': isUseDisclaimer,
                        'isDeliveryReturn': isDeliveryReturn,
                        'isMaintainRepair': isMaintainRepair,
                        'isRefundDepositNeeded': isRefundDepositNeeded,
                        'isMaintainAndclean': isMaintainAndclean,
                      };
                      widget.onPdfCreated(agreementLink, documentName,
                          agreementConfig, agreementId);

                      Navigator.of(context).pop();
                      log('NEW TEMPLATE CREATED');
                    }
                    // } else {
                    //   log('HERE 5');
                    //   showDialog(
                    //     context: context,
                    //     builder: (BuildContext _context) {
                    //       return AlertDialog(
                    //         content: Text(S.of(context).something_went_wrong),
                    //         actions: [
                    //           CustomTextButton(
                    //             child: Text(S.of(context).close),
                    //             onPressed: () {
                    //               Navigator.of(_context).pop();
                    //             },
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   );
                    // }
                  }
                }
              }),
        ),
      ],
    );
  }

  Future<void> openPdfViewer(String pdfURL, String documentName) async {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
    );
    progressDialog!.show();
    createFileOfPdfUrl(pdfURL, documentName).then((f) {
      progressDialog!.hide();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFScreen(
                  pdfUrl: pdfURL,
                  docName: documentName,
                  pathPDF: f.path,
                  isFromFeeds: false,
                  isDownloadable: false,
                )),
      );
    });
    return;
  }

  void showTermsPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
        "links_" + S.of(context).localeName,
      ),
    );

    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_terms_link,
          urlToHit: dynamicLinks['termsAndConditionsLink']),
      context: context,
    );
  }

  void showPrivacyPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
        "links_" + S.of(context).localeName,
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_privacy_link,
          urlToHit: dynamicLinks['privacyPolicyLink']),
      context: context,
    );
  }

  void showPaymentPolicyPage() {
    var dynamicLinks = json.decode(
      AppConfig.remoteConfig!.getString(
        "links_" + S.of(context).localeName,
      ),
    );
    navigateToWebView(
      aboutMode: AboutMode(
          title: S.of(context).login_agreement_payment_link,
          urlToHit: dynamicLinks['paymentPolicyLink']),
      context: context,
    );
  }

  Widget _optionRadioButtonMain<T>({
    String? title,
    T? value,
    T? groupvalue,
    Function? onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      key: UniqueKey(),
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title!),
      leading: Radio<T>(
        activeColor: Theme.of(context).primaryColor,
        value: value!,
        groupValue: groupvalue,
        onChanged: isEnabled ? onChanged as ValueChanged<T?>? : null,
      ),
    );
  }

  Widget searchFieldWidget() {
    log('HERE 1');

    if (agreementDocumentType != AgreementDocumentType.TEMPLATE.readable) {
      log('HERE 2');
      return Container();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 10),
          child: TextFormField(
            controller: searchTextController,
            key: _formKeyElastic,
            decoration: InputDecoration(
              isDense: true,
              // labelText: "Enter Email",
              hintText: widget.placeOrItem == LendingType.PLACE.readable
                  ? S.of(context).search_agreement_hint_place
                  : S.of(context).search_agreement_hint_item,
              fillColor: Colors.white,
              alignLabelWithHint: true,
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: Colors.grey,
              ),
              contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 10.0),

              suffixIcon: Offstage(
                offstage: searchTextController.text.length == 0,
                child: IconButton(
                  splashColor: Colors.transparent,
                  icon: Icon(
                    Icons.clear,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      searchTextController.clear();
                      //if (selectedProjectTemplate != null) {
                      //  selectedProjectTemplate = null;
                      //}
                    });
                  },
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(fontSize: 16.0),
            focusNode: searchFocusNode,
            inputFormatters: [
              LengthLimitingTextInputFormatter(50),
            ],
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }

  Widget buildTemplateWidget() {
    log('HERE 3');
    if (agreementDocumentType != AgreementDocumentType.TEMPLATE.readable) {
      return Container();
    } else if (searchTextController.text.trim().length < 3) {
      return getEmptyWidget(
          S.of(context).validation_error_search_min_characters);
    } else {
      return StreamBuilder<List<AgreementTemplateModel>>(
        stream: SearchManager.searchAgreementTemplate(
            queryString: searchTextController.text,
            placeOrItem: widget.placeOrItem,
            creatorId: SevaCore.of(context).loggedInUser.sevaUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: LoadingIndicator(),
              ),
            );
          }

          List<AgreementTemplateModel> agreementTemplateList = snapshot.data!;

          if (agreementTemplateList == null ||
              agreementTemplateList.length == 0) {
            return getEmptyWidget(S.of(context).no_templates_found);
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: agreementTemplateList.length,
            itemBuilder: (context, index) {
              AgreementTemplateModel borrowAgreementTemplateModel =
                  agreementTemplateList[index];
              return Padding(
                padding: const EdgeInsets.only(left: 14),
                child: ListTile(
                  // value: index,
                  // groupValue: value,
                  // activeColor: primaryColor,
                  onTap: () => setState(() {
                    value = index;
                    selectedAgreementTemplate = agreementTemplateList[index];
                    documentNameController.text =
                        selectedAgreementTemplate!.documentName!;
                    documentName = selectedAgreementTemplate!.documentName!;
                    specificConditionsController.text =
                        selectedAgreementTemplate!.specificConditions!;
                  }),
                  title: Text(borrowAgreementTemplateModel.templateName!),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget getEmptyWidget(String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<String?> _showSaveAsTemplateDialog() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext viewContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
                // borderRadius: BorderRadius.all(
                //   Radius.circular(25.0),
                // ),
                ),
            child: Form(
              key: _formDialogKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: double.infinity,
                    color: Theme.of(context).primaryColor,
                    child: Center(
                      child: Text(
                        S.of(context).template_title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Europa'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      child: TextFormField(
                        controller: searchTextController2,
                        decoration: InputDecoration(
                          hintMaxLines: 2,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(0.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          contentPadding:
                              EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                          hintText: S.of(context).template_hint,
                        ),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(fontSize: 17.0),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        onChanged: (value) {
                          ExitWithConfirmation.of(context).fieldValues[5] =
                              value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).validation_error_template_name;
                          } else if (templateFound) {
                            return S
                                .of(context)
                                .validation_error_template_name_exists;
                          } else {
                            templateName = value;
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(viewContext);
                        },
                        child: Text(
                          S.of(context).cancel,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Europa'),
                        ),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.grey),
                      ),
                      TextButton(
                        child: Text(S.of(context).save,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa')),
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor),
                        onPressed: () async {
                          if (_formDialogKey.currentState?.validate() ??
                              false) {
                            Navigator.pop(viewContext, templateName);
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          );
        });
  }
}

enum AgreementDocumentType {
  NEW,
  TEMPLATE,
  NO_AGREEMENT,
  //PDF_UPLOAD   (to be decided)
}

extension AgreementDocumentTypeLabel on AgreementDocumentType {
  String get readable {
    switch (this) {
      case AgreementDocumentType.NEW:
        return 'NEW';
      case AgreementDocumentType.TEMPLATE:
        return 'TEMPLATE';
      case AgreementDocumentType.NO_AGREEMENT:
        return 'NO_AGREEMENT';
      default:
        return 'NEW';
    }
  }
}
