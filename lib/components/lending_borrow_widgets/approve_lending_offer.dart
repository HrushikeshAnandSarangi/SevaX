import 'package:cached_network_image/cached_network_image.dart';
import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class ApproveLendingOffer extends StatefulWidget {
  final OfferModel offerModel;
  final LendingOfferAcceptorModel lendingOfferAcceptorModel;

  ApproveLendingOffer({
    required this.offerModel,
    required this.lendingOfferAcceptorModel,
  });

  @override
  _ApproveLendingOfferState createState() => _ApproveLendingOfferState();
}

class _ApproveLendingOfferState extends State<ApproveLendingOffer> {
  GeoFirePoint? location;
  String additionalInstructionsText = '';
  String agreementId = '';
  TextEditingController instructionController = TextEditingController();

  final _formKey = GlobalKey<DoseFormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          S.of(context).approve_lending_offer,
          style: TextStyle(
              fontFamily: "Europa", fontSize: 19, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: approveForm,
      ),
    );
  }

  Widget get approveForm {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 35, right: 35),
      child: DoseForm(
        formKey: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            requestedByWidget,
            SizedBox(height: 20),
            OfferDurationWidget(
              title: widget.offerModel?.lendingOfferDetailsModel?.lendingModel
                          ?.lendingType ==
                      LendingType.PLACE
                  ? S.of(context).date_to_check_in_out
                  : S.of(context).date_to_borrow_and_return,
            ),
            SizedBox(height: 15),
            Text(S.of(context).addditional_instructions + '*',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start),
            SizedBox(height: 2),
            DoseTextField(
              isRequired: true,
              controller: instructionController,
              onFieldSubmitted: (v) {
                FocusScope.of(context).unfocus();
              },
              onChanged: (enteredValue) {
                additionalInstructionsText = enteredValue;
                //TODO setstate causes form to reload
                // setState(() {});
              },
              decoration: InputDecoration(
                hintText: widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingModel?.lendingType ==
                        LendingType.PLACE
                    ? S.of(context).additional_instructions_hint_place
                    : S.of(context).additional_instructions_hint_item,
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                // labelText: 'No. of volunteers',
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).addditional_instructions_error_text;
                } else {
                  additionalInstructionsText = value ?? '';
                  setState(() {});
                  return null;
                }
              },
            ),
            termsAcknowledegmentText,
            bottomActionButtons,
          ],
        ),
      ),
    );
  }

  Widget get termsAcknowledegmentText {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Text(
            widget.offerModel?.lendingOfferDetailsModel?.lendingModel
                        ?.lendingType ==
                    LendingType.PLACE
                //widget.offerModel.placeOrItem == 'PLACE'
                ? S.of(context).lending_approve_terms_place
                : S.of(context).lending_approve_terms_item,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.start),
        SizedBox(height: 25),
      ],
    );
  }

  Widget get bottomActionButtons {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 32,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Colors.grey[300]!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
            textColor: Colors.black,
            child: Text(
              S.of(context).reject,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              if (widget.lendingOfferAcceptorModel == null) return;
              LendingOffersRepo.updateOfferAcceptorActionRejected(
                lendingOfferAcceptorModel: widget.lendingOfferAcceptorModel!,
                action: OfferAcceptanceStatus.REJECTED,
                model: widget.offerModel!,
              ).then((value) => Navigator.of(context).pop());
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
        ),
        Container(
          height: 32,
          child: CustomElevatedButton(
            padding: EdgeInsets.only(left: 11, right: 11),
            color: Colors.grey[300]!,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
            textColor: Colors.black,
            child: Text(
              S.of(context).approve,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              //To be implemented by lending offer team
              if (additionalInstructionsText.isEmpty) {
                errorDialog(
                  context: context,
                  error: S.of(context).addditional_instructions_error_text,
                );
                return;
              }
              if (OfferDurationWidgetState.starttimestamp != 0 &&
                  OfferDurationWidgetState.endtimestamp != 0) {
                //assigning dates to acceptor model
                widget.lendingOfferAcceptorModel!.startDate =
                    OfferDurationWidgetState.starttimestamp;
                widget.lendingOfferAcceptorModel!.endDate =
                    OfferDurationWidgetState.endtimestamp;

                if (widget.lendingOfferAcceptorModel!.endDate! <=
                    widget.lendingOfferAcceptorModel!.startDate!) {
                  errorDialog(
                    context: context,
                    error: S.of(context).validation_error_end_date_greater,
                  );
                  return;
                }

                if (widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingOfferTypeMode ==
                        'ONE_TIME' &&
                    (widget.lendingOfferAcceptorModel?.endDate ?? 0) >=
                        (widget.offerModel?.lendingOfferDetailsModel?.endDate ??
                            0)) {
                  // widget.offerModel.lendingOfferDetailsModel.lendingModel
                  //             .lendingType ==
                  //         LendingType.PLACE
                  //     ?
                  errorDialog(
                    context: context,
                    error: S.of(context).end_date_after_offer_end_date,
                  );

                  return;
                }

                if (widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingOfferAgreementLink !=
                        null ||
                    widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingOfferAgreementLink !=
                        '') {
                  agreementId = createCryptoRandomString();
                  String agreementLink = await BorrowAgreementPdf()
                      .borrowAgreementPdf(
                          context,
                          RequestModel(
                              communityId:
                                  widget.offerModel?.communityId ?? ''),
                          //request model
                          widget.offerModel!.lendingOfferDetailsModel!
                              .lendingModel!,
                          [], // empty list for borrow request items
                          // borrow request items list
                          widget.lendingOfferAcceptorModel?.acceptorName ??
                              'Unknown',
                          widget.offerModel?.lendingOfferDetailsModel?.lendingOfferAgreementName ??
                              '',
                          true,
                          OfferDurationWidgetState.starttimestamp,
                          OfferDurationWidgetState.endtimestamp,
                          widget.offerModel?.lendingOfferDetailsModel?.lendingModel?.lendingType == LendingType.PLACE
                              ? LendingType.PLACE.readable
                              : LendingType.ITEM.readable,
                          widget.offerModel?.lendingOfferDetailsModel?.agreementConfig['specificConditions'] ??
                              '' + '\n ${additionalInstructionsText ?? ''}',
                          widget.offerModel?.lendingOfferDetailsModel
                              ?.agreementConfig['isDamageLiability'],
                          widget.offerModel?.lendingOfferDetailsModel
                              ?.agreementConfig['isUseDisclaimer'],
                          widget.offerModel?.lendingOfferDetailsModel
                              ?.agreementConfig['isDeliveryReturn'],
                          widget.offerModel?.lendingOfferDetailsModel
                              ?.agreementConfig['isMaintainRepair'],
                          widget.offerModel?.lendingOfferDetailsModel
                              ?.agreementConfig['isRefundDepositNeeded'],
                          widget.offerModel?.lendingOfferDetailsModel?.agreementConfig['isMaintainAndclean'],
                          agreementId);

                  await LendingOffersRepo.approveLendingOffer(
                          model: widget.offerModel,
                          lendingOfferAcceptorModel:
                              widget.lendingOfferAcceptorModel,
                          lendingOfferApprovedAgreementLink:
                              agreementLink ?? '',
                          additionalInstructionsText:
                              additionalInstructionsText,
                          agreementId: agreementId ?? '')
                      .then((value) => Navigator.of(context).pop());
                } else {
                  await LendingOffersRepo.approveLendingOffer(
                          model: widget.offerModel,
                          lendingOfferAcceptorModel:
                              widget.lendingOfferAcceptorModel,
                          lendingOfferApprovedAgreementLink: '',
                          additionalInstructionsText:
                              additionalInstructionsText)
                      .then((value) => Navigator.of(context).pop());
                }
              } else {
                errorDialog(
                  context: context,
                  error: S.of(context).offer_start_end_date,
                );
              }
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
        ),
      ],
    );
  }

  Widget get requestedByWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          S.of(context).requested_by,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 42,
              backgroundImage: CachedNetworkImageProvider(
                widget.lendingOfferAcceptorModel.acceptorphotoURL ??
                    'https://www.pngitem.com/pimgs/m/404-4042710_circle-profile-picture-png-transparent-png.png',
              ),
            ),
            SizedBox(width: 25),
            Container(
              child: Expanded(
                child: Text(
                  widget.lendingOfferAcceptorModel.acceptorName ??
                      'Acceptor', //borrower name here from offer model
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
