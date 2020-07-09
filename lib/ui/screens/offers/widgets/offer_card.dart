import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';

class OfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionButtonLabel;
  final String selectedAddress;
  final int startDate;
  final OfferType offerType;
  final Function onActionPressed;
  final Function onCardPressed;
  final Color buttonColor;

  final bool isCreator;
  final bool isCardVisible;

  const OfferCard({
    Key key,
    this.title,
    this.subtitle,
    this.offerType,
    this.onActionPressed,
    this.onCardPressed,
    this.isCreator = false,
    this.actionButtonLabel,
    this.selectedAddress,
    this.startDate,
    this.isCardVisible = false,
    this.buttonColor,
  })  : assert(title != null),
        assert(subtitle != null),
        assert(offerType != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: isCardVisible,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onCardPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      getOfferMetaData(
                        context: context,
                        startDate: startDate,
                      ),
                      Offstage(
                        offstage: isCreator,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.only(left: 10, right: 10),
                              color:
                                  buttonColor ?? Theme.of(context).primaryColor,
                              child: Text(
                                actionButtonLabel ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: onActionPressed,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getOfferMetaData({BuildContext context, int startDate}) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: offerType == OfferType.GROUP_OFFER
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: <Widget>[
          offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                    timeStamp: startDate,
                    timeZone: SevaCore.of(context).loggedInUser.timezone,
                  ),
                  icon: Icons.calendar_today)
              : Offstage(),
          offerType == OfferType.GROUP_OFFER
              ? getStatsIcon(
                  label: getFormatedTimeFromTimeStamp(
                    timeStamp: startDate,
                    timeZone: SevaCore.of(context).loggedInUser.timezone,
                    format: "h:mm a",
                  ),
                  icon: Icons.access_time)
              : Offstage(),
          getOfferLocation(selectedAddress: selectedAddress) != null
              ? getStatsIcon(
                  label: getOfferLocation(selectedAddress: selectedAddress),
                  icon: Icons.location_on)
              : Container(),
        ],
      ),
    );
  }

  Widget getStatsIcon({String label, IconData icon}) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 15,
          color: Colors.grey,
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          label.trim(),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
