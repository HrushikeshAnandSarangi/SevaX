import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'lending_offer_participants.dart';

class BorrowerAcceptLendingOffer extends StatefulWidget {
  final String? timeBankId;
  final OfferModel? offerModel;
  String? notificationId;

  BorrowerAcceptLendingOffer({
    this.timeBankId,
    this.offerModel,
    this.notificationId,
    //this.onTap,
  });

  @override
  _BorrowerAcceptLendingOfferState createState() =>
      _BorrowerAcceptLendingOfferState();
  Future<void> openPdfViewer(
      String pdfUrl, String title, BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SfPdfViewer.network(pdfUrl),
        ),
      ),
    );
  }
}

class _BorrowerAcceptLendingOfferState
    extends State<BorrowerAcceptLendingOffer> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isPressed = false;
  @override
  Widget build(BuildContext context) {
    logger.e(" bool isPressed1 = $isPressed");
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
            widget.offerModel!.lendingOfferDetailsModel!.lendingModel!
                        .lendingType! ==
                    LendingType.PLACE
                ? S.of(context).accept_place_lending_offer
                : S.of(context).accept_item_lending_offer,
            style: TextStyle(
                fontFamily: "Europa", fontSize: 19, color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: mainPageAgreementComponent,
        ));
  }

  Widget get mainPageAgreementComponent {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 10),
            offerAgreementFormComponent,
            widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingOfferAgreementLink !=
                        null &&
                    widget.offerModel?.lendingOfferDetailsModel
                            ?.lendingOfferAgreementLink !=
                        ''
                ? termsAcknowledegmentText
                : Container(),
            SizedBox(height: 20),
            bottomActionButtons,
            SizedBox(height: 20),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.circle, color: Colors.grey[200], size: 40),
                Icon(Icons.check, color: Colors.green, size: 30),
              ],
            ),
            SizedBox(width: 15),
            Container(
              width: 290,
              child: Text(
                  S.of(context).terms_acknowledgement_text +
                      '. ' +
                      S.of(context).agree_to_signature_legal_text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.start),
            ),
          ],
        ),
        SizedBox(height: 15),
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
            color: Theme.of(context).primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2.0,
            textColor: Colors.white,
            child: Text(
              S.of(context).accept,
              style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              if (widget.offerModel!.lendingOfferDetailsModel!.lendingModel!
                      .lendingType ==
                  LendingType.PLACE) {
                await LendingOffersRepo.storeAcceptorDataLendingOffer(
                    model: widget.offerModel!,
                    lendingOfferAcceptorModel: LendingOfferAcceptorModel(
                      id: Utils.getUuid(),
                      communityId:
                          SevaCore.of(context).loggedInUser.currentCommunity!,
                      acceptorphotoURL:
                          SevaCore.of(context).loggedInUser.photoURL ??
                              defaultUserImageURL,
                      isApproved: false,
                      borrowedPlaceId: widget.offerModel!
                          .lendingOfferDetailsModel!.lendingModel!.id!,
                      borrowedItemsIds: [],
                      borrowAgreementLink: widget
                                  .offerModel!
                                  .lendingOfferDetailsModel!
                                  .lendingOfferAgreementLink !=
                              null
                          ? widget.offerModel!.lendingOfferDetailsModel!
                              .lendingOfferAgreementLink!
                          : '',
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      acceptorEmail: SevaCore.of(context).loggedInUser.email!,
                      acceptorId: SevaCore.of(context).loggedInUser.sevaUserID!,
                      acceptorMobile: '',
                      acceptorName: SevaCore.of(context).loggedInUser.fullname!,
                      selectedAddress: widget!.offerModel!.selectedAdrress!,
                      status: LendingOfferStatus.ACCEPTED,
                      notificationId: widget.notificationId ?? '',
                      additionalInstructions: '',
                      isLenderGaveReview: false,
                      isBorrowerGaveReview: false,
                      startDate: DateTime.now().millisecondsSinceEpoch,
                      endDate: DateTime.now().millisecondsSinceEpoch,
                      approvedAgreementId: '',
                    ));
                Navigator.of(context).pop();
              } else {
                await LendingOffersRepo.storeAcceptorDataLendingOffer(
                    model: widget.offerModel!,
                    lendingOfferAcceptorModel: LendingOfferAcceptorModel(
                      startDate: DateTime.now().millisecondsSinceEpoch,
                      endDate: DateTime.now().millisecondsSinceEpoch,
                      id: Utils.getUuid(),
                      communityId:
                          SevaCore.of(context).loggedInUser.currentCommunity!,
                      acceptorphotoURL:
                          SevaCore.of(context).loggedInUser.photoURL ??
                              defaultUserImageURL,
                      isApproved: false,
                      borrowedPlaceId: '',
                      borrowedItemsIds: [
                        widget.offerModel!.lendingOfferDetailsModel!
                            .lendingModel!.id
                      ],
                      borrowAgreementLink: widget
                                  .offerModel!
                                  .lendingOfferDetailsModel!
                                  .lendingOfferAgreementLink !=
                              null
                          ? widget.offerModel!.lendingOfferDetailsModel!
                              .lendingOfferAgreementLink!
                          : '',
                      timestamp: DateTime.now().millisecondsSinceEpoch,
                      acceptorEmail: SevaCore.of(context).loggedInUser.email!,
                      acceptorId: SevaCore.of(context).loggedInUser.sevaUserID!,
                      acceptorMobile: '',
                      acceptorName: SevaCore.of(context).loggedInUser.fullname!,
                      selectedAddress: widget.offerModel!.selectedAdrress!,
                      status: LendingOfferStatus.ACCEPTED,
                      notificationId: widget.notificationId ?? '',
                      additionalInstructions: '',
                      isLenderGaveReview: false,
                      isBorrowerGaveReview: false,
                      approvedAgreementId: '',
                    ));
                Navigator.of(context).pop();
              }
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
            color: Theme.of(context).colorScheme.secondary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 2.0,
            textColor: Colors.white,
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
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
            elevation: 2.0,
            textColor: Colors.black,
            child: Text(
              S.of(context).message,
              style: TextStyle(color: Colors.black, fontFamily: 'Europa'),
            ),
            onPressed: () async {
              UserModel loggedInUser = SevaCore.of(context).loggedInUser;

              ParticipantInfo sender = ParticipantInfo(
                id: loggedInUser.sevaUserID,
                name: loggedInUser.fullname,
                photoUrl: loggedInUser.photoURL,
                type: ChatType.TYPE_PERSONAL,
              );

              ParticipantInfo reciever = ParticipantInfo(
                id: widget.offerModel!.sevaUserId,
                name: widget.offerModel!.fullName,
                photoUrl:
                    widget.offerModel!.photoUrlImage ?? defaultUserImageURL,
                type: ChatType.TYPE_PERSONAL,
              );

              createAndOpenChat(
                context: context,
                communityId: loggedInUser.currentCommunity!,
                sender: sender,
                reciever: reciever,
                timebankId: widget.timeBankId ?? '',
                feedId: '',
                showToCommunities: [],
                entityId: widget.offerModel?.id ?? '',
                onChatCreate: () {
                  //Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget get offerAgreementFormComponent {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              S.of(context).agreement,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.68,
              child: Text(
                widget.offerModel?.lendingOfferDetailsModel
                                ?.lendingOfferAgreementLink !=
                            null &&
                        widget.offerModel?.lendingOfferDetailsModel
                                ?.lendingOfferAgreementLink !=
                            ''
                    ? S.of(context).review_before_proceding_text
                    : S.of(context).lender_not_created_agreement,
                style: TextStyle(fontSize: 15),
                softWrap: true,
              ),
            ),
            Image(
              width: 60,
              image: AssetImage(
                  'lib/assets/images/request_offer_agreement_icon.png'),
            ),
          ],
        ),
        SizedBox(height: 20),
        widget.offerModel!.lendingOfferDetailsModel!
                        .lendingOfferAgreementLink !=
                    null &&
                widget.offerModel!.lendingOfferDetailsModel!
                        .lendingOfferAgreementLink !=
                    ''
            ? Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
                alignment: Alignment.center,
                width: 300,
                height: 360,
                child: SfPdfViewer.network(
                  widget!.offerModel!.lendingOfferDetailsModel!
                      .lendingOfferAgreementLink!,
                  canShowPaginationDialog: false,
                ),
              )
            : Container(),
        SizedBox(height: 20),
        widget.offerModel!.lendingOfferDetailsModel!
                        .lendingOfferAgreementLink !=
                    null &&
                widget.offerModel!.lendingOfferDetailsModel!
                        .lendingOfferAgreementLink !=
                    ''
            ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 12),
                width: 155,
                height: 32,
                child: CustomTextButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
                  color: widget.offerModel!.lendingOfferDetailsModel!
                                  .lendingOfferAgreementLink !=
                              null &&
                          widget.offerModel!.lendingOfferDetailsModel!
                                  .lendingOfferAgreementLink !=
                              '' &&
                          isPressed == false
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 1),
                      Spacer(),
                      Text(
                        widget.offerModel!.lendingOfferDetailsModel!
                                        .lendingOfferAgreementLink !=
                                    null &&
                                widget.offerModel!.lendingOfferDetailsModel!
                                        .lendingOfferAgreementLink !=
                                    ''
                            ? S.of(context).review_agreement
                            : S.of(context).no_agrreement,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                  onPressed: isPressed
                      ? null!
                      : () async {
                          setState(() {
                            isPressed = true;
                          });
                          logger.e(" bool isPressed = $isPressed");
                          if (widget.offerModel!.lendingOfferDetailsModel!
                                      .lendingOfferAgreementLink !=
                                  null &&
                              widget.offerModel!.lendingOfferDetailsModel!
                                      .lendingOfferAgreementLink !=
                                  '') {
                            await widget.openPdfViewer(
                                widget.offerModel!.lendingOfferDetailsModel!
                                    .lendingOfferAgreementLink!,
                                'Review Agreement',
                                context);
                            setState(() {
                              isPressed = false;
                            });
                          } else {
                            return;
                          }
                        },
                ),
              )
            : Container(),
      ],
    );
  }
}
