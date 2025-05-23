import 'package:flutter/material.dart';

const TextStyle whiteCardNumberStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

class CardFrontLayout {
  String bankName;
  String cardNumber;
  String cardExpiry;
  String cardHolderName;
  Widget cardTypeIcon;
  double cardWidth;
  double cardHeight;
  Color textColor;

  CardFrontLayout(
      {this.bankName = "",
      this.cardNumber = "",
      this.cardExpiry = "",
      this.cardHolderName = "",
      required this.cardTypeIcon,
      this.cardWidth = 0,
      this.cardHeight = 0,
      required this.textColor});

  Widget layout1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30,
                child: Center(
                  child: Text(
                    bankName,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'images/contactless_icon.png',
                    fit: BoxFit.fitHeight,
                    width: 30.0,
                    height: 30.0,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          cardNumber == null || cardNumber.isEmpty
                              ? 'XXXX XXXX XXXX XXXX'
                              : cardNumber,
                          style: TextStyle(
                              package: 'awesome_card',
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: "MavenPro",
                              fontSize: 22),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Exp. Date",
                              style: TextStyle(
                                  package: 'awesome_card',
                                  color: textColor,
                                  fontFamily: "MavenPro",
                                  fontSize: 15),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              cardExpiry == null || cardExpiry.isEmpty
                                  ? "MM/YY"
                                  : cardExpiry,
                              style: TextStyle(
                                  package: 'awesome_card',
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "MavenPro",
                                  fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          cardHolderName == null || cardHolderName.isEmpty
                              ? "Card Holder"
                              : cardHolderName,
                          style: TextStyle(
                              package: 'awesome_card',
                              color: textColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: "MavenPro",
                              fontSize: 17),
                        ),
                      ],
                    ),
                    cardTypeIcon
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
