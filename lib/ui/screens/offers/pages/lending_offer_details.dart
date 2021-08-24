import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/repositories/notifications_repository.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_item_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_card_widget.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_place_details_widget.dart';
import 'package:sevaexchange/ui/screens/request/pages/borrow_request_participants.dart';
import 'package:sevaexchange/ui/screens/request/widgets/cutom_chip.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

import '../../../../labels.dart';
import 'borrower_accept_lending_offer.dart';
import 'individual_offer.dart';
import 'lending_offer_participants.dart';

class LendingOfferDetails extends StatefulWidget {
  final OfferModel offerModel;
  final TimebankModel timebankModel;
  final ComingFrom comingFrom;

  LendingOfferDetails({this.offerModel, this.timebankModel, this.comingFrom});

  @override
  _LendingOfferDetailsState createState() => _LendingOfferDetailsState();
}

class _LendingOfferDetailsState extends State<LendingOfferDetails> {
  LendingPlaceModel lendingPlaceModel;
  LendingItemModel lendingItemModel;
  LendingOfferAcceptorModel lendingOfferAcceptorModel;
  LendingOfferStatus lendingOfferStatus;
  String lendingOfferStatusTitle = '';
  String lendingOfferButtonActionTitle = '';
  LendingType lendingType;
  OfferModel offerModel;
  bool isApproved = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<OfferModel>(
          stream:
              LendingOffersRepo.getOfferStream(offerId: widget.offerModel.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null) {
              offerModel = widget.offerModel;
            }
            offerModel = snapshot.data;
            if (offerModel.lendingOfferDetailsModel.lendingModel.lendingType ==
                LendingType.PLACE) {
              lendingPlaceModel = offerModel
                  .lendingOfferDetailsModel.lendingModel.lendingPlaceModel;
              lendingType = LendingType.PLACE;
            } else {
              lendingItemModel = offerModel
                  .lendingOfferDetailsModel.lendingModel.lendingItemModel;

              lendingType = LendingType.ITEM;
            }
            var approvedUsers =
                offerModel.lendingOfferDetailsModel.approvedUsers ?? [];
            isApproved =
                approvedUsers.contains(SevaCore.of(context).loggedInUser.email);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            color: Colors.teal,
                            child: ImagesPreview(
                                urls: offerModel.lendingOfferDetailsModel
                                            .lendingModel.lendingType ==
                                        LendingType.PLACE
                                    ? offerModel
                                        .lendingOfferDetailsModel
                                        .lendingModel
                                        .lendingPlaceModel
                                        .houseImages
                                    : offerModel
                                        .lendingOfferDetailsModel
                                        .lendingModel
                                        .lendingItemModel
                                        .itemImages),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                lendingType == LendingType.ITEM
                                    ? lendingItemModel.itemName
                                    : lendingPlaceModel.placeName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Europa',
                                  color: Colors.black,
                                ),
                              ),
                              lendingType == LendingType.PLACE
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        title('${lendingPlaceModel.noOfGuests}'
                                            ' ${L.of(context).guests} '),
                                        title('${lendingPlaceModel.noOfRooms}'
                                            ' ${L.of(context).bed_rooms} .'),
                                        title(
                                            '${lendingPlaceModel.noOfBathRooms}'
                                            ' ${L.of(context).bath_rooms} '),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: 10,
                              ),
                              CustomListTile(
                                leading: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Card(
                                      color: Colors.transparent,
                                      elevation: 3,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 58,
                                            height: 15,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .accentColor,
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(7),
                                                    topRight:
                                                        Radius.circular(7))),
                                          ),
                                          Container(
                                            width: 58,
                                            height: 38,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(7),
                                                    bottomRight:
                                                        Radius.circular(7))),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        DateFormat(
                                                'dd',
                                                Locale(getLangTag())
                                                    .toLanguageTag())
                                            .format(
                                          getDateTimeAccToUserTimezone(
                                              dateTime: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      widget
                                                          .offerModel
                                                          .lendingOfferDetailsModel
                                                          .startDate),
                                              timezoneAbb: SevaCore.of(context)
                                                  .loggedInUser
                                                  .timezone),
                                        ),
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 16.0, left: 8),
                                  child: date,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: dateDetailsComponentLendingOffer,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              lendingType == LendingType.ITEM
                                  ? LendingItemCardWidget(
                                      hidden: true,
                                      lendingItemModel: lendingItemModel,
                                    )
                                  : AmenitiesAndHouseRules(
                                      lendingModel: offerModel
                                          .lendingOfferDetailsModel
                                          .lendingModel,
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                S.of(context).description,
                                style: titleStyle,
                              ),
                              Text(
                                offerModel
                                        .individualOfferDataModel.description ??
                                    " ",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                L
                                    .of(context)
                                    .estimated_value
                                    .replaceAll('*', ''),
                                style: titleStyle,
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.grey),
                                  Text(
                                    lendingType == LendingType.ITEM
                                        ? widget
                                            .offerModel
                                            .lendingOfferDetailsModel
                                            .lendingModel
                                            .lendingItemModel
                                            .estimatedValue
                                            .toString()
                                        : widget
                                            .offerModel
                                            .lendingOfferDetailsModel
                                            .lendingModel
                                            .lendingPlaceModel
                                            .estimatedValue
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                child: Text(
                                  offerModel.lendingOfferDetailsModel
                                                  .lendingOfferAgreementLink ==
                                              null ||
                                          offerModel.lendingOfferDetailsModel
                                                  .lendingOfferAgreementLink ==
                                              ''
                                      ? L
                                          .of(context)
                                          .offer_agreement_not_available
                                      : L
                                          .of(context)
                                          .click_to_view_offer_agreement,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                onTap: () async {
                                  if (offerModel.lendingOfferDetailsModel
                                              .lendingOfferAgreementLink ==
                                          null ||
                                      offerModel.lendingOfferDetailsModel
                                              .lendingOfferAgreementLink ==
                                          '') {
                                    return null;
                                  } else {
                                    if ((offerModel.email ==
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .email &&
                                            offerModel.lendingOfferDetailsModel
                                                    .approvedUsers.length >
                                                0) ||
                                        offerModel.lendingOfferDetailsModel
                                            .approvedUsers
                                            .contains(SevaCore.of(context)
                                                .loggedInUser
                                                .email)) {
                                      await openPdfViewer(
                                          offerModel.lendingOfferDetailsModel
                                              .lendingOfferApprovedAgreementLink,
                                          offerModel.lendingOfferDetailsModel
                                                  .lendingOfferAgreementName ??
                                              'Lending Offer Agreement',
                                          context);
                                    } else {
                                      await openPdfViewer(
                                          offerModel.lendingOfferDetailsModel
                                              .lendingOfferAgreementLink,
                                          offerModel.lendingOfferDetailsModel
                                                  .lendingOfferAgreementName ??
                                              'Lending Offer Agreement',
                                          context);
                                    }
                                  }
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Offstage(
                                  offstage: !isApproved,
                                  child: LendingOfferProgressWidget()),
                              SizedBox(
                                height: 10,
                              ),
                              addressComponentBorrowRequestForApproved(
                                  offerModel.selectedAdrress ?? '', context),
                              SizedBox(
                                height: 10,
                              ),
                              lendingOfferCreatorWidget,
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                getBottomBar(
                  context,
                  SevaCore.of(context).loggedInUser.email,
                  SevaCore.of(context).loggedInUser.sevaUserID,
                )
              ],
            );
          }),
    );
  }

  bool canDeleteOffer = false;

  Widget getBottomBar(BuildContext context, String email, String userId) {
    bool isAccepted = getOfferParticipants(offerDataModel: offerModel).contains(
      email,
    );
    var approvedUsers = offerModel.lendingOfferDetailsModel.approvedUsers ?? [];
    var offerAcceptors =
        offerModel.lendingOfferDetailsModel.offerAcceptors ?? [];
    bool isCreator = offerModel.sevaUserId == userId;
    canDeleteOffer =
        isCreator && offerAcceptors.length == 0 && approvedUsers.length == 0;

    if (lendingType == LendingType.PLACE) {
      return Container(
        decoration: BoxDecoration(color: Colors.white54, boxShadow: [
          BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
        ]),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20.0, left: 10, bottom: 20, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      canDeleteOffer
                          ? TextSpan(
                              text: '${S.of(context).you_created_offer}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : isApproved
                              ? TextSpan(
                                  text: getStatusLabel(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : TextSpan(
                                  text: isCreator
                                      ? S.of(context).you_created_offer
                                      : isAccepted
                                          ? L.of(context).withdraw_lending_offer
                                          : S
                                              .of(context)
                                              .would_like_to_accept_offer,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  canDeleteOffer ||
                          utils.isDeletable(
                            communityCreatorId: isPrimaryTimebank(
                              parentTimebankId:
                                  widget.timebankModel.parentTimebankId,
                            )
                                ? widget.timebankModel.creatorId
                                : (widget.timebankModel.managedCreatorIds !=
                                            null &&
                                        widget.timebankModel.managedCreatorIds
                                                .length >
                                            0)
                                    ? widget.timebankModel.managedCreatorIds[0]
                                    : '',
                            // communityCreatorId: timebankModel != null ,
                            context: context,
                            contentCreatorId: offerModel.sevaUserId,
                            timebankCreatorId: widget.timebankModel.creatorId,
                          )
                      ? deleteActionButton(isAccepted, context)
                      : Container(),
                  SizedBox(
                    height: 8,
                  ),
                  Offstage(offstage: !isCreator, child: editLendingOffer()),
                  Offstage(
                      offstage: isCreator ||
                          lendingOfferStatus == LendingOfferStatus.CHECKED_OUT,
                      child: ActionButton(
                          isAccepted: isAccepted, isApproved: isApproved)),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(color: Colors.white54, boxShadow: [
          BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
        ]),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 20.0, left: 10, bottom: 20, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      canDeleteOffer
                          ? TextSpan(
                              text: '${S.of(context).you_created_offer}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : isApproved
                              ? TextSpan(
                                  text: getStatusLabel(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : TextSpan(
                                  text: isCreator
                                      ? S.of(context).you_created_offer
                                      : isAccepted
                                          ? L.of(context).withdraw_lending_offer
                                          : S
                                              .of(context)
                                              .would_like_to_accept_offer,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  canDeleteOffer ||
                          utils.isDeletable(
                            communityCreatorId: widget.timebankModel != null
                                ? isPrimaryTimebank(
                                    parentTimebankId:
                                        widget.timebankModel.parentTimebankId,
                                  )
                                    ? widget.timebankModel.creatorId
                                    : (widget.timebankModel.managedCreatorIds !=
                                                null &&
                                            widget.timebankModel
                                                    .managedCreatorIds.length >
                                                0)
                                        ? widget
                                            .timebankModel.managedCreatorIds[0]
                                        : ''
                                : '',
                            // communityCreatorId: timebankModel != null ,
                            context: context,
                            contentCreatorId: offerModel.sevaUserId,
                            timebankCreatorId: widget.timebankModel.creatorId,
                          )
                      ? deleteActionButton(isAccepted, context)
                      : Container(),
                  SizedBox(
                    height: 8,
                  ),
                  Offstage(offstage: !isCreator, child: editLendingOffer()),
                  Offstage(
                      offstage: isCreator ||
                          lendingOfferStatus ==
                              LendingOfferStatus.ITEMS_RETURNED,
                      child: ActionButton(
                          isAccepted: isAccepted, isApproved: isApproved)),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  String getButtonActionLabel() {
    if (offerModel.lendingOfferDetailsModel.lendingModel.lendingType ==
            LendingType.PLACE &&
        !offerModel.lendingOfferDetailsModel.checkedIn &&
        !offerModel.lendingOfferDetailsModel.checkedOut) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_IN;
      return L.of(context).check_in;
    } else if (offerModel.lendingOfferDetailsModel.lendingModel.lendingType ==
            LendingType.ITEM &&
        !offerModel.lendingOfferDetailsModel.collectedItems &&
        !offerModel.lendingOfferDetailsModel.returnedItems) {
      return L.of(context).collect_items;
    } else if (offerModel.lendingOfferDetailsModel.checkedIn) {
      return L.of(context).check_out;
    } else if (offerModel.lendingOfferDetailsModel.collectedItems) {
      return L.of(context).return_items;
    } else if (offerModel.lendingOfferDetailsModel.returnedItems) {
      return L.of(context).returned_items;
    } else if (offerModel.lendingOfferDetailsModel.checkedOut) {
      return L.of(context).checked_out;
    }
  }

  String getStatusLabel() {
    if (offerModel.lendingOfferDetailsModel.lendingModel.lendingType ==
            LendingType.PLACE &&
        !offerModel.lendingOfferDetailsModel.checkedIn &&
        !offerModel.lendingOfferDetailsModel.checkedOut) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_IN;
      return S.of(context).request_approved;
    } else if (offerModel.lendingOfferDetailsModel.lendingModel.lendingType ==
            LendingType.ITEM &&
        !offerModel.lendingOfferDetailsModel.collectedItems &&
        !offerModel.lendingOfferDetailsModel.returnedItems) {
      return S.of(context).request_approved;
    } else if (offerModel.lendingOfferDetailsModel.checkedIn) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_OUT;

      return L.of(context).lending_offer_return_place_hint;
    } else if (offerModel.lendingOfferDetailsModel.collectedItems) {
      lendingOfferStatus = LendingOfferStatus.ITEMS_RETURNED;
      return L.of(context).lending_offer_return_items_hint;
    } else if (offerModel.lendingOfferDetailsModel.returnedItems) {
      lendingOfferStatus = LendingOfferStatus.ITEMS_RETURNED;
      return L.of(context).returned_items;
    } else if (offerModel.lendingOfferDetailsModel.checkedOut) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_OUT;
      return L.of(context).checked_out;
    }
  }

  Widget editLendingOffer() {
    return Container(
      width: 110,
      height: 32,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        color: Color.fromRGBO(44, 64, 140, 0.7),
        child: Text(
          S.of(context).edit,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => IndividualOffer(
                offerModel: offerModel,
                timebankId: offerModel.timebankId,
                loggedInMemberUserId:
                    SevaCore.of(context).loggedInUser.sevaUserID,
                timebankModel: widget.timebankModel,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget ActionButton({bool isAccepted, bool isApproved}) {
    log('isACeepted $isAccepted');
    log('isAprroved $isApproved');
    return Container(
      width: 110,
      height: 32,
      child: ConfigurationCheck(
        actionType: ConfigurationCheckExtension.getOfferAcceptanceKey(
          offerModel,
        ),
        role: memberType(
            widget.timebankModel, SevaCore.of(context).loggedInUser.sevaUserID),
        child: CustomTextButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Color.fromRGBO(44, 64, 140, 0.7),
          child: Row(
            children: <Widget>[
              SizedBox(width: 1),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(44, 64, 140, 1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              Text(
                isApproved
                    ? getButtonActionLabel()
                    : isAccepted
                        ? S.of(context).withdraw
                        : S.of(context).yes,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
          onPressed: () async {
            TimebankModel timebankModel;
            if (Provider.of<HomePageBaseBloc>(context, listen: false)
                    .timebankModel(offerModel.timebankId) ==
                null) {
              timebankModel = await utils.getTimeBankForId(
                  timebankId: offerModel.timebankId);
            } else {
              timebankModel =
                  Provider.of<HomePageBaseBloc>(context, listen: false)
                      .timebankModel(offerModel.timebankId);
            }
            if (isApproved) {
              if (lendingOfferStatus == LendingOfferStatus.CHECKED_OUT ||
                  lendingOfferStatus == LendingOfferStatus.ITEMS_RETURNED) {
                showDialog<bool>(
                  context: context,
                  builder: (BuildContext _context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: Text(
                          lendingOfferStatus == LendingOfferStatus.CHECKED_OUT
                              ? L.of(context).check_out
                              : L.of(context).return_items),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            lendingOfferStatus == LendingOfferStatus.CHECKED_OUT
                                ? L.of(context).check_out_alert
                                : L.of(context).return_items_alert,
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Spacer(),
                              CustomTextButton(
                                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                shape: StadiumBorder(),
                                color: HexColor("#d2d2d2"),
                                child: Text(
                                  S.of(context).cancel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Europa',
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(_context).pop();
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              CustomTextButton(
                                shape: StadiumBorder(),
                                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                color: Theme.of(context).accentColor,
                                child: Text(
                                  S.of(context).yes,
                                  style: TextStyle(
                                    fontFamily: 'Europa',
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                onPressed: () async {
                                  Navigator.of(_context).pop();
                                  await LendingOffersRepo
                                          .updateLendingOfferStatus(
                                              lendingOfferAcceptorModel:
                                                  lendingOfferAcceptorModel,
                                              offerModel: offerModel,
                                              lendingOfferStatus:
                                                  lendingOfferStatus)
                                      .then((value) {
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              } else {
                await LendingOffersRepo.updateLendingOfferStatus(
                        lendingOfferAcceptorModel: lendingOfferAcceptorModel,
                        offerModel: offerModel,
                        lendingOfferStatus: lendingOfferStatus)
                    .then((value) {
                  Navigator.of(context).pop();
                });
              }
            } else if (!isAccepted) {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => BorrowerAcceptLendingOffer(
                        offerModel: offerModel,
                        timeBankId: offerModel.timebankId,
                        notificationId: null,
                      ),
                    ),
                  )
                  .then((value) => Navigator.of(context).pop());

              //TO DO accept and send notification to lending offer creator and create acceptor model and push it to subcollections
            } else {
              await LendingOffersRepo.removeAcceptorLending(
                model: offerModel,
                acceptorEmail: SevaCore.of(context).loggedInUser.email,
              ).then((_) => Navigator.of(context).pop());
            }
          },
        ),
      ),
    );
  }

  Widget LendingOfferProgressWidget() {
    String title = 'Title';
    String subTitle = '';
    String additionalInstruction = '';
    String dateText = '';
    String dateSubText = '';
    Widget reviewWidget = Container();

    return StreamBuilder<LendingOfferAcceptorModel>(
        stream: LendingOffersRepo.getApprovedModelStream(
            acceptorEmail: SevaCore.of(context).loggedInUser.email,
            offerId: offerModel.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null) {
            return Container();
          }
          lendingOfferAcceptorModel = snapshot.data;
          if (lendingType == LendingType.PLACE) {
            if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.APPROVED) {
              title = S.of(context).request_approved_by_msg +
                  ' ' +
                  offerModel.fullName;
              subTitle = ' ';
              dateText = L.of(context).arrival +
                  ':' +
                  DateFormat('EEEEEE, MMMM dd yyyy',
                          Locale(getLangTag()).toLanguageTag())
                      .format(
                    getDateTimeAccToUserTimezone(
                        dateTime: DateTime.fromMillisecondsSinceEpoch(
                            lendingOfferAcceptorModel.startDate),
                        timezoneAbb:
                            SevaCore.of(context).loggedInUser.timezone),
                  );
              dateSubText = L.of(context).departure +
                  ':' +
                  DateFormat.MMMd(getLangTag()).add_jm().format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              lendingOfferAcceptorModel.endDate),
                          timezoneAbb:
                              SevaCore.of(context).loggedInUser.timezone,
                        ),
                      );
              additionalInstruction =
                  lendingOfferAcceptorModel.additionalInstructions != null
                      ? lendingOfferAcceptorModel.additionalInstructions
                      : '';
            } else if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.CHECKED_IN) {
              title = L.of(context).your_departure_date_is;
              subTitle = ' ';
              dateText = DateFormat('EEEEEE, MMMM dd yyyy',
                      Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        lendingOfferAcceptorModel.endDate),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              );
              dateSubText = DateFormat('hh:mm').format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                      lendingOfferAcceptorModel.endDate),
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                ),
              );
            } else if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.CHECKED_OUT) {
              title = L.of(context).you_departed_on;
              subTitle = ' ';
              dateText = DateFormat('EEEEEE, MMMM dd yyyy',
                      Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        lendingOfferAcceptorModel.endDate),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              );
              if (!lendingOfferAcceptorModel.isBorrowerGaveReview) {
                additionalInstruction = L.of(context).share_feedback_place;

                reviewWidget = Center(
                  child: CustomChip(
                    label: S.of(context).review,
                    isSelected: false,
                    onTap: () {
                      handleFeedBackNotificationLendingOffer(
                          offerModel: offerModel,
                          notificationId: null,
                          context: context,
                          email: SevaCore.of(context).loggedInUser.email,
                          feedbackType:
                              FeedbackType.FEEDBACK_FOR_LENDER_FROM_BORROWER,
                          lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                    },
                  ),
                );
              }
            }
          } else {
            if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.APPROVED) {
              title = S.of(context).request_approved_by_msg +
                  ' ' +
                  offerModel.fullName;
              subTitle = L.of(context).items_collected_alert;
              dateText = DateFormat(
                      'EEEEEE MMMM dd', Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        lendingOfferAcceptorModel.startDate),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              );
              dateSubText = DateFormat.MMMd(getLangTag()).add_jm().format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                            lendingOfferAcceptorModel.startDate,
                          ),
                          timezoneAbb:
                              SevaCore.of(context).loggedInUser.timezone,
                        ),
                      ) +
                  ' - ' +
                  DateFormat.MMMd(getLangTag()).add_jm().format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              lendingOfferAcceptorModel.endDate),
                          timezoneAbb:
                              SevaCore.of(context).loggedInUser.timezone,
                        ),
                      );
              additionalInstruction =
                  lendingOfferAcceptorModel.additionalInstructions != null
                      ? lendingOfferAcceptorModel.additionalInstructions
                      : '';
            } else if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.ITEMS_COLLECTED) {
              title = L.of(context).items_collected_alert_two +
                  ' ' +
                  offerModel.fullName;
              subTitle = L.of(context).please_return_by;
              dateText = DateFormat(
                      'EEEEEE MMMM dd', Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        lendingOfferAcceptorModel.endDate),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              );
              dateSubText = DateFormat.MMMd(getLangTag()).add_jm().format(
                    getDateTimeAccToUserTimezone(
                      dateTime: DateTime.fromMillisecondsSinceEpoch(
                          lendingOfferAcceptorModel.endDate),
                      timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                    ),
                  );
            } else if (lendingOfferAcceptorModel.status ==
                LendingOfferStatus.ITEMS_RETURNED) {
              title = L.of(context).items_returned_to_lender +
                  ' ' +
                  offerModel.fullName;
              subTitle = L.of(context).exchanged_completed;
              dateText = DateFormat(
                      'EEEEEE MMMM dd', Locale(getLangTag()).toLanguageTag())
                  .format(
                getDateTimeAccToUserTimezone(
                    dateTime: DateTime.fromMillisecondsSinceEpoch(
                        lendingOfferAcceptorModel.endDate),
                    timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
              );
              dateSubText = DateFormat.MMMd(getLangTag()).add_jm().format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                            lendingOfferAcceptorModel.startDate,
                          ),
                          timezoneAbb:
                              SevaCore.of(context).loggedInUser.timezone,
                        ),
                      ) +
                  ' - ' +
                  DateFormat.MMMd(getLangTag()).add_jm().format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              lendingOfferAcceptorModel.endDate),
                          timezoneAbb:
                              SevaCore.of(context).loggedInUser.timezone,
                        ),
                      );
              if (!lendingOfferAcceptorModel.isBorrowerGaveReview) {
                additionalInstruction = L.of(context).share_feedback_place;

                reviewWidget = Center(
                  child: CustomChip(
                    label: S.of(context).review,
                    isSelected: false,
                    onTap: () {
                      handleFeedBackNotificationLendingOffer(
                          offerModel: offerModel,
                          notificationId: null,
                          context: context,
                          email: SevaCore.of(context).loggedInUser.email,
                          feedbackType:
                              FeedbackType.FEEDBACK_FOR_LENDER_FROM_BORROWER,
                          lendingOfferAcceptorModel: lendingOfferAcceptorModel);
                    },
                  ),
                );
              }
            }
          }

          return Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.white54, boxShadow: [
              BoxShadow(
                color: Colors.grey[300],
              )
            ]),
            width: MediaQuery.of(context).size.width,
            height: 240,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomListTile(
                leading: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Card(
                      color: Colors.transparent,
                      elevation: 3,
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    topRight: Radius.circular(7))),
                          ),
                          Container(
                            width: 58,
                            height: 38,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(7),
                                    bottomRight: Radius.circular(7))),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        DateFormat('dd', Locale(getLangTag()).toLanguageTag())
                            .format(
                          getDateTimeAccToUserTimezone(
                              dateTime: DateTime.fromMillisecondsSinceEpoch(
                                  lendingOfferAcceptorModel.startDate),
                              timezoneAbb:
                                  SevaCore.of(context).loggedInUser.timezone),
                        ),
                        style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8),
                  child: Text(
                    dateText,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    dateSubText,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Offstage(
                offstage: additionalInstruction == null ||
                    additionalInstruction == '',
                child: Text(
                  L.of(context).notes,
                  style: TextStyle(
                    fontSize: 14,
                    color: HexColor('#606670'),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                additionalInstruction,
                style: TextStyle(
                  fontSize: 14,
                  color: HexColor('#9B9B9B'),
                  fontWeight: FontWeight.bold,
                ),
              ),
              reviewWidget,
            ]),
          );
        });
  }

  Widget get date {
    return Text(
      DateFormat('EEEEEEE, MMMM dd', Locale(getLangTag()).toLanguageTag())
          .format(
        getDateTimeAccToUserTimezone(
            dateTime: DateTime.fromMillisecondsSinceEpoch(
                offerModel.lendingOfferDetailsModel.startDate),
            timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
      ),
      style: titleStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get dateDetailsComponentLendingOffer {
    return Text(
      DateFormat.MMMd(getLangTag()).add_jm().format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                    offerModel.lendingOfferDetailsModel.startDate,
                  ),
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                ),
              ) +
          ' - ' +
          DateFormat.MMMd(getLangTag()).add_jm().format(
                getDateTimeAccToUserTimezone(
                  dateTime: DateTime.fromMillisecondsSinceEpoch(
                      offerModel.lendingOfferDetailsModel.endDate),
                  timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
                ),
              ),
      style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget get lendingOfferCreatorWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          S.of(context).posted_by,
          style: titleStyle,
          maxLines: 1,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                offerModel.photoUrlImage ?? defaultUserImageURL,
              ),
              backgroundColor: Colors.white,
              radius: MediaQuery.of(context).size.width / 11.5,
            ),
            SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offerModel.fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: HexColor('#49485D'),
                    ),
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 2),
                widget.offerModel.lendingOfferDetailsModel.lendingModel
                            .lendingPlaceModel.contactInformation !=
                        null
                    ? Text(
                        widget.offerModel.lendingOfferDetailsModel.lendingModel
                            .lendingPlaceModel.contactInformation,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis)
                    : Container(),
                SizedBox(height: 7),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget deleteActionButton(bool isAccepted, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      width: 110,
      height: 32,
      child: CustomTextButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(0),
        color: Colors.green,
        child: Row(
          children: <Widget>[
            SizedBox(width: 1),
            Spacer(),
            Text(
              '${S.of(context).delete}',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Spacer(
              flex: 1,
            ),
          ],
        ),
        onPressed: () async {
          deleteOffer(context: context, offerId: offerModel.id);
        },
      ),
    );
  }
}

class ImagesPreview extends StatefulWidget {
  final List<String> urls;

  ImagesPreview({@required this.urls});

  @override
  State<StatefulWidget> createState() {
    return ImagesPreviewState();
  }
}

class ImagesPreviewState extends State<ImagesPreview> {
  PageController pageController = new PageController();
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: PageView.builder(
                itemCount: widget.urls.length,
                itemBuilder: (_, index) {
                  return Image.network(
                    widget.urls[index],
                    fit: BoxFit.fitWidth,
                  );
                },
                controller: pageController,
                onPageChanged: (pageIndex) {
                  this.pageIndex = pageIndex;
                },
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 5, left: 5),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => pageController.animateToPage(
                        pageIndex > 0 ? --pageIndex : pageIndex,
                        curve: Curves.linearToEaseOut,
                        duration: Duration(seconds: 1),
                      ),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HexColor('#626262'),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: HexColor('#FAFAFA'),
                          size: 15,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: () => pageController.animateToPage(
                        pageIndex < (widget.urls.length - 1)
                            ? ++pageIndex
                            : pageIndex,
                        curve: Curves.easeIn,
                        duration: Duration(seconds: 1),
                      ),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HexColor('#626262'),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: HexColor(
                            '#FAFAFA',
                          ),
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget addressComponentBorrowRequestForApproved(
    String address, BuildContext context) {
  String locationSubitleFinal = '';
  String locationTitle = '';

  if (address != null) {
    List locationTitleList = address.split(',');
    locationTitle = locationTitleList[0];

    List locationSubitleList = address.split(',');
    locationSubitleList.removeAt(0);

    locationSubitleFinal =
        locationSubitleList.toString().replaceAll('[', '').replaceAll(']', '');

    return address != null
        ? CustomListTile(
            leading: Icon(
              Icons.location_on,
              color: Colors.black,
            ),
            title: Text(
              address.trim() != null ? locationTitle : '',
              style: titleStyle,
              maxLines: 1,
            ),
            subtitle: address != null
                ? Text(locationSubitleFinal.trim(),
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600))
                : Text(''),
          )
        : Container();
  } else {
    return Text(S.of(context).location_not_provided,
        style: TextStyle(color: Colors.grey));
  }
}

TextStyle titleStyle =
    TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold);

TextStyle subTitleStyle = TextStyle(
  fontSize: 14,
);
