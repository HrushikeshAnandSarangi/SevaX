import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/home_page/bloc/home_page_base_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/bookmarked_offers.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_details.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/users_circle_avatar_list.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_view.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_dialogs/custom_dialog.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavor_config.dart';
import 'individual_offer.dart';
import 'one_to_many_offer.dart';

class OfferDetails extends StatelessWidget {
  final OfferModel offerModel;
  final TimebankModel timebankModel;
  final ComingFrom comingFrom;
  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  OfferDetails({
    Key key,
    this.offerModel,
    this.comingFrom,
    this.timebankModel,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return offerModel.type == RequestType.LENDING_OFFER
        ? LendingOfferDetails(
            offerModel: offerModel,
            comingFrom: comingFrom,
            timebankModel: timebankModel,
          )
        : Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            getOfferTitle(offerDataModel: offerModel),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        CustomListTile(
                          leading: Icon(
                            Icons.access_time,
                            color: Colors.grey,
                          ),
                          title: Text(
                            S.of(context).posted_on,
                            style: titleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat('EEEEEEE, MMMM dd h:mm a', "en").format(
                              getDateTimeAccToUserTimezone(
                                dateTime: DateTime.fromMillisecondsSinceEpoch(
                                  offerModel?.groupOfferDataModel?.startDate !=
                                          null
                                      ? offerModel
                                          ?.groupOfferDataModel?.startDate
                                      : offerModel.timestamp,
                                ),
                                timezoneAbb:
                                    SevaCore.of(context).loggedInUser.timezone,
                              ),
                            ),
                            style: subTitleStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Offstage(
                            offstage: offerModel.sevaUserId !=
                                    SevaCore.of(context)
                                        .loggedInUser
                                        .sevaUserID ||
                                (getOfferParticipants(
                                            offerDataModel: offerModel)
                                        .isNotEmpty &&
                                    offerModel.offerType ==
                                        OfferType.GROUP_OFFER),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 80,
                                  child: CustomTextButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: Color.fromRGBO(44, 64, 140, 1),
                                    child: Text(
                                      S.of(context).edit,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => IndividualOffer(
                                            offerModel: offerModel,
                                            timebankId: offerModel.timebankId,
                                            loggedInMemberUserId:
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID,
                                            timebankModel: timebankModel,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                oneToManyOfferCancellation(context),
                              ],
                            ),
                          ),
                        ),
                        offerModel.selectedAdrress != null
                            ? CustomListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  S.of(context).location,
                                  style: titleStyle,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  offerModel.selectedAdrress,
                                  style: subTitleStyle,
                                  maxLines: 1,
                                ),
                              )
                            : Container(),
                        CustomListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          title: Text(
                            "${S.of(context).offered_by} ${offerModel.fullName}",
                            style: titleStyle,
                            maxLines: 1,
                          ),
                        ),
                        offerModel.type == RequestType.GOODS
                            ? Container(
                                padding:
                                    EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                                child: showGoodsDonationDetails(
                                    context, offerModel))
                            : offerModel.type == RequestType.CASH
                                ? showCashDonationDetails(context, offerModel)
                                : Container(),

                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: RichTextView(
                            text:
                                getOfferDescription(offerDataModel: offerModel),
                          ),
                        ),
                        offerModel.type == RequestType.TIME
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${S.of(context).availablity}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Offstage(
                                    offstage: offerModel.offerType !=
                                            OfferType.INDIVIDUAL_OFFER &&
                                        offerModel.individualOfferDataModel
                                                .schedule ==
                                            null,
                                    child: RichTextView(
                                        text: offerModel
                                                .individualOfferDataModel
                                                .schedule ??
                                            ''),
                                  ),
                                  Divider(
                                    height: 40,
                                    color: HexColor("#D2D2D2"),
                                    thickness: 0.8,
                                  ),
                                ],
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: UserCircleAvatarList(
                            sizeOfClass:
                                offerModel.groupOfferDataModel.sizeOfClass,
                          ),
                        ),
                        //Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              getBottombar(
                context,
                SevaCore.of(context).loggedInUser.sevaUserID,
              ),
            ],
          );
  }

  Widget showCashDonationDetails(BuildContext context, OfferModel offerModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(
            S.of(context).offering_amount,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        CustomListTile(
          title: Text(
            S.of(context).total_donation_amount,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
              '${offerModel.cashModel.offerCurrencyType} ${offerModel.cashModel.targetAmount}'),
          leading: Image.asset(
            offerModel.type == RequestType.CASH
                ? SevaAssetIcon.donateCash
                : SevaAssetIcon.donateGood,
            height: 30,
            width: 30,
          ),
          trailing: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget showGoodsDonationDetails(BuildContext context, OfferModel offerModel) {
    List<String> keys =
        List.from(offerModel.goodsDonationDetails.requiredGoods.keys);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 20),
          child: Text(
            S.of(context).offering_goods,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: offerModel.goodsDonationDetails.requiredGoods.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Checkbox(
                  value: offerModel.goodsDonationDetails.requiredGoods
                          .containsKey(keys[index]) ??
                      false,
                  checkColor: Colors.black,
                  onChanged: null,
                  activeColor: Colors.grey[200],
                ),
                Text(
                  offerModel.goodsDonationDetails.requiredGoods[keys[index]],
                  style: subTitleStyle,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget oneToManyOfferCancellation(BuildContext context) {
    if (offerModel.offerType == OfferType.GROUP_OFFER &&
        DateTime.now().millisecondsSinceEpoch <
            offerModel.groupOfferDataModel.endDate) {
      return Row(
        children: [
          SizedBox(
            width: 10,
          ),
          Container(
            height: 40,
            width: 90,
            child: CustomTextButton(
              shape: StadiumBorder(),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              color: Theme.of(context).accentColor,
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _onCancel(context),
            ),
          )
        ],
      );
    }

    return Container();
  }

  void _onEdit(BuildContext context) {
    switch (offerModel.offerType) {
      case OfferType.INDIVIDUAL_OFFER:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => IndividualOffer(
              offerModel: offerModel,
              timebankId: offerModel.timebankId,
              loggedInMemberUserId:
                  SevaCore.of(context).loggedInUser.sevaUserID,
              timebankModel: timebankModel,
            ),
          ),
        );
        break;
      case OfferType.GROUP_OFFER:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OneToManyOffer(
              offerModel: offerModel,
              timebankId: offerModel.timebankId,
              loggedInMemberUserId:
                  SevaCore.of(context).loggedInUser.sevaUserID,
              timebankModel: timebankModel,
            ),
          ),
        );
        break;
    }
  }

  void _onCancel(BuildContext context) {
    switch (offerModel.offerType) {
      case OfferType.INDIVIDUAL_OFFER:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IndividualOffer(
              offerModel: offerModel,
              timebankId: offerModel.timebankId,
              loggedInMemberUserId:
                  SevaCore.of(context).loggedInUser.sevaUserID,
              timebankModel: timebankModel,
            ),
          ),
        );
        break;
      case OfferType.GROUP_OFFER:
        showDialog(
          context: context,
          builder: (BuildContext _context) {
            return AlertDialog(
              title: Text(S.of(context).cancel_offer),
              content: Text(S.of(context).cancel_offer_confirmation),
              actions: [
                CustomTextButton(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: Theme.of(context).accentColor,
                  child: Text(
                    S.of(context).close,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(_context).pop();
                  },
                ),
                CustomTextButton(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    S.of(context).cancel_offer,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.of(_context).pop();
                    await CollectionRef.offers
                        .doc(offerModel.id)
                        .update({'groupOfferDataModel.isCanceled': true});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        break;
    }
  }

  bool canDeleteOffer = false;

  Widget getBottombar(BuildContext context, String userId) {
    bool isAccepted = getOfferParticipants(offerDataModel: offerModel).contains(
      userId,
    );

    bool isCreator = offerModel.sevaUserId == userId;
    log("creator ${timebankModel.creatorId}");
    canDeleteOffer = isCreator &&
        offerModel.offerType == OfferType.INDIVIDUAL_OFFER &&
        offerModel.individualOfferDataModel.offerAcceptors.length == 0;
    return Container(
      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
      ]),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 20.0, left: 20, bottom: 20, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
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
                              : TextSpan(
                                  text: isCreator
                                      ? S.of(context).you_created_offer
                                      : isAccepted
                                          ? S.of(context).accepted_offer_msg
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
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Wrap(
              alignment: WrapAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                canDeleteOffer ||
                        utils.isDeletable(
                          communityCreatorId: timebankModel != null
                              ? isPrimaryTimebank(
                                  parentTimebankId:
                                      timebankModel.parentTimebankId,
                                )
                                  ? timebankModel.creatorId
                                  : (timebankModel.managedCreatorIds != null &&
                                          timebankModel
                                                  .managedCreatorIds.length >
                                              0)
                                      ? timebankModel.managedCreatorIds[0]
                                      : ''
                              : '',
                          // communityCreatorId: timebankModel != null ,
                          context: context,
                          contentCreatorId: offerModel.sevaUserId,
                          timebankCreatorId: timebankModel.creatorId,
                        )
                    ? deleteActionButton(isAccepted, context)
                    : Container(),
                Offstage(
                  offstage: isCreator ||
                      (isAccepted &&
                          offerModel.offerType == OfferType.GROUP_OFFER),
                  child: Container(
                    width: isAccepted ? 150 : 120,
                    height: 32,
                    child: ConfigurationCheck(
                      actionType:
                          ConfigurationCheckExtension.getOfferAcceptanceKey(
                        offerModel,
                      ),
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: CustomTextButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        color: Color.fromRGBO(44, 64, 140, 0.7),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 1),
                            Container(
                              width: 30,
                              height: 30,
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
                              getButtonLabel(context, offerModel, userId),
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
                          bool isAccepted =
                              getOfferParticipants(offerDataModel: offerModel)
                                  .contains(userId);
                          if (isAccepted) {
                            return;
                          }

                          TimebankModel timebankModel;
                          if (Provider.of<HomePageBaseBloc>(context,
                                      listen: false)
                                  .timebankModel(offerModel.timebankId) ==
                              null) {
                            timebankModel = await utils.getTimeBankForId(
                                timebankId: offerModel.timebankId);
                          } else {
                            timebankModel = Provider.of<HomePageBaseBloc>(
                                    context,
                                    listen: false)
                                .timebankModel(offerModel.timebankId);
                          }

                          //ClubHouse
                          if (offerModel.type != RequestType.TIME &&
                              !isAccessAvailable(
                                  timebankModel,
                                  SevaCore.of(context)
                                      .loggedInUser
                                      .sevaUserID)) {
                            adminCheckToAcceptOfferDialog(
                              context,
                            );
                            return;
                          }

                          if (offerModel.type == RequestType.CASH ||
                              offerModel.type == RequestType.GOODS &&
                                  !isAccepted) {
                            navigateToDonations(context, offerModel);
                          } else {
                            // if (offerModel.offerType == OfferType.GROUP_OFFER &&
                            //     SevaCore.of(context).loggedInUser.calendarId ==
                            //         null &&
                            //     !isAccepted) {
                            //   _settingModalBottomSheet(
                            //     context,
                            //     offerModel,
                            //   );
                            // } else {
                            offerActions(context, offerModel, ComingFrom.Offers)
                                .then((_) => Navigator.of(context).pop());
                            // }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Offstage(
                  offstage: isCreator ||
                      offerModel.offerType == OfferType.GROUP_OFFER ||
                      offerModel.type != RequestType.TIME,
                  child: Container(
                    width: isAccepted ? 150 : 120,
                    height: 32,
                    child: ConfigurationCheck(
                      actionType:
                          ConfigurationCheckExtension.getOfferAcceptanceKey(
                              offerModel),
                      role: memberType(timebankModel,
                          SevaCore.of(context).loggedInUser.sevaUserID),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 2,
                        ),
                        child: CustomTextButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          color: Color.fromRGBO(44, 64, 140, 0.7),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 1),
                              Container(
                                width: 30,
                                height: 30,
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
                                S.of(context).accept_offer,
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
                            logger.i("INDIVIDUAL ========== || =======");

                            showDialogForMakingAnOffer(
                              model: offerModel,
                              parentContext: context,
                              timebankModel: timebankModel,
                              sevaUserId:
                                  SevaCore.of(context).loggedInUser.sevaUserID,
                              hideCancelBookMark: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> adminCheckToAcceptOfferDialog(BuildContext context) async {
    return CustomDialogs.generalDialogWithCloseButton(
      context,
      // 'Only admin can accept Goods/Cash offers',
      // 'Only Community admins can accept offers of money / goods',
      S.of(context).only_community_admins_can_accept,
    );
  }

  Widget deleteActionButton(bool isAccepted, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Container(
        margin: EdgeInsets.only(
          right: 10,
        ),
        width: isAccepted ? 150 : 120,
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
      ),
    );
  }

  Future<void> navigateToDonations(context, OfferModel offerModel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationView(
          offerModel: offerModel,
          timabankName: '',
          requestModel: null,
          notificationId: null,
        ),
      ),
    ).then((value) => Navigator.pop(context));
  }

  @Deprecated('Now navigating to donations')
  void navigateToCreateRequestFromOffer(context, OfferModel offerModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationView(
          offerModel: offerModel,
          timabankName: '',
          requestModel: null,
          notificationId: null,
        ),
      ),
    );
  }

  void _settingModalBottomSheet(BuildContext context, OfferModel offerModel) {
    Map<String, dynamic> stateOfcalendarCallback = {
      "email": SevaCore.of(context).loggedInUser.email,
      "mobile": globals.isMobile,
      "envName": FlavorConfig.values.envMode,
      "eventsArr": []
    };
    var stateVar = jsonEncode(stateOfcalendarCallback);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: Text(
                    S.of(context).calendars_popup_desc,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/googlecal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              offerActions(
                                context,
                                offerModel,
                                ComingFrom.Offers,
                              ).then((_) => Navigator.of(context).pop());
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset(
                                  "lib/assets/images/outlookcal.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              offerActions(
                                      context, offerModel, ComingFrom.Offers)
                                  .then((_) => Navigator.of(context).pop());
                            }),
                      ),
                      TransactionsMatrixCheck(
                        comingFrom: ComingFrom.Offers,
                        upgradeDetails:
                            AppConfig.upgradePlanBannerModel.calendar_sync,
                        transaction_matrix_type: "calender_sync",
                        child: GestureDetector(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 40,
                              child: Image.asset("lib/assets/images/ical.png"),
                            ),
                            onTap: () async {
                              String redirectUrl =
                                  "${FlavorConfig.values.cloudFunctionBaseURL}/callbackurlforoauth";
                              String authorizationUrl =
                                  "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${stateVar}&redirect_uri=$redirectUrl";
                              if (await canLaunch(
                                  authorizationUrl.toString())) {
                                await launch(authorizationUrl.toString());
                              }
                              Navigator.of(bc).pop();
                              offerActions(
                                      context, offerModel, ComingFrom.Offers)
                                  .then((_) => Navigator.of(context).pop());
                            }),
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    CustomTextButton(
                        shape: StadiumBorder(),
                        padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          S.of(context).skip_for_now,
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Europa'),
                        ),
                        onPressed: () {
                          Navigator.of(bc).pop();
                          offerActions(context, offerModel, ComingFrom.Offers)
                              .then((_) => Navigator.of(context).pop());
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }
}
