import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/rich_text_view/rich_text_view.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/users_circle_avatar_list.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/custom_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavor_config.dart';
import 'individual_offer.dart';
import 'one_to_many_offer.dart';

class OfferDetails extends StatelessWidget {
  final OfferModel offerModel;
  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  OfferDetails({Key key, this.offerModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
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
                      DateFormat(
                              'EEEEEEE, MMMM dd h:mm a',
                              "en")
                          .format(
                        getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                            offerModel.timestamp,
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
                              SevaCore.of(context).loggedInUser.sevaUserID ||
                          (getOfferParticipants(offerDataModel: offerModel)
                                  .isNotEmpty &&
                              offerModel.offerType == OfferType.GROUP_OFFER),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 80,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Color.fromRGBO(44, 64, 140, 1),
                              child: Text(
                                S.of(context).edit,
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => _onEdit(context),
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
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: RichTextView(
                      text: getOfferDescription(offerDataModel: offerModel),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: UserCircleAvatarList(
                      sizeOfClass: offerModel.groupOfferDataModel.sizeOfClass,
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
            height: 30,
            width: 90,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.red,
              child: Text(
                "Cancel",
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IndividualOffer(
              offerModel: offerModel,
              timebankId: offerModel.timebankId,
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
                FlatButton(
                  child: Text(S.of(context).close),
                  onPressed: () {
                    Navigator.of(_context).pop();
                  },
                ),
                FlatButton(
                  child: Text(S.of(context).cancel_offer),
                  onPressed: () async {
                    Navigator.of(_context).pop();
                    await Firestore.instance
                        .collection('offers')
                        .document(offerModel.id)
                        .updateData({'groupOfferDataModel.isCanceled': true});
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

  Widget getBottombar(BuildContext context, String userId) {
    bool isAccepted = getOfferParticipants(offerDataModel: offerModel).contains(
      userId,
    );
    bool isCreator = offerModel.sevaUserId == userId;

    return Container(
      decoration: BoxDecoration(color: Colors.white54, boxShadow: [
        BoxShadow(color: Colors.grey[300], offset: Offset(2.0, 2.0))
      ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: isCreator
                            ? S.of(context).you_created_offer
                            : '${S.of(context).you_have} ${isAccepted ? '' : " ${S.of(context).not_yet}"} ${offerModel.offerType == OfferType.GROUP_OFFER ? S.of(context).signed_up_for : S.of(context).bookmarked} ${S.of(context).this_offer}.',
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
            Offstage(
              offstage: isCreator ||
                  (isAccepted && offerModel.offerType == OfferType.GROUP_OFFER),
              child: Container(
                width: 120,
                height: 32,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0),
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
                        getButtonLabel(offerModel, userId),
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
                    if(SevaCore.of(context).loggedInUser.calendarId==null) {
                      _settingModalBottomSheet(context, offerModel);
                    }else{
                      offerActions(context, offerModel)
                          .then((_) => Navigator.of(context).pop());
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _settingModalBottomSheet(BuildContext context, OfferModel offerModel) {
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
                  padding: const EdgeInsets.fromLTRB(6,6,6,6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/googlecal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=google_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                            offerActions(context, offerModel)
                                .then((_) => Navigator.of(context).pop());
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/outlookcal.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=outlook_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                            offerActions(context, offerModel)
                                .then((_) => Navigator.of(context).pop());
                          }
                      ),
                      GestureDetector(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 40,
                            child: Image.asset(
                                "lib/assets/images/ical.png"),
                          ),
                          onTap: () async {
                            String redirectUrl = "https://us-central1-sevax-dev-project-for-sevax.cloudfunctions.net/callbackurlforoauth";
                            String authorizationUrl = "https://api.kloudless.com/v1/oauth?client_id=B_2skRqWhNEGs6WEFv9SQIEfEfvq2E6fVg3gNBB3LiOGxgeh&response_type=code&scope=icloud_calendar&state=${SevaCore.of(context).loggedInUser.email}&redirect_uri=$redirectUrl";
                            if (await canLaunch(authorizationUrl.toString())) {
                              await launch(authorizationUrl.toString());
                            }
                            Navigator.of(bc).pop();
                            offerActions(context, offerModel)
                                .then((_) => Navigator.of(context).pop());
                          }
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    FlatButton(
                        child: Text(S.of(context).do_it_later, style: TextStyle(color: FlavorConfig.values.theme.primaryColor),),
                        onPressed: (){
                          Navigator.of(bc).pop();
                          offerActions(context, offerModel)
                              .then((_) => Navigator.of(context).pop());
                        }
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}
