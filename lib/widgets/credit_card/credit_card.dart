import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/credit_card/utils/card_type.dart';
import 'package:sevaexchange/widgets/credit_card/utils/helper.dart';
import 'package:sevaexchange/widgets/credit_card/utils/style.dart';

class CustomCreditCard extends StatefulWidget {
  final String cardNumber;
  final String cardExpiry;
  final String cardHolderName;
  final String bankName;
  final String brand;
  final bool isDefaultCard;

  final Color frontTextColor;
  final Color backTextColor;

  final Widget frontBackground;

  final Widget? frontLayout;

  final bool showShadow;
  final CardType cardType;
  final double? width;
  final double? height;

  CustomCreditCard({
    Key? key,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cardHolderName,
    required this.bankName,
    required this.brand,
    required this.frontBackground,
    this.cardType = CardType.other,
    this.frontLayout,
    this.frontTextColor = Colors.white,
    this.backTextColor = Colors.black,
    this.showShadow = false,
    this.width,
    this.height,
    this.isDefaultCard = false,
  }) : super(key: key);

  @override
  _CustomCreditCardState createState() => _CustomCreditCardState();
}

class _CustomCreditCardState extends State<CustomCreditCard> {
  late double cardWidth;
  late double cardHeight;

  @override
  Widget build(BuildContext context) {
    cardWidth = widget.width ?? MediaQuery.of(context).size.width - 40;
    cardHeight = widget.height ?? (cardWidth / 2) + 10;
    return Container(
      child: Stack(
        children: <Widget>[
          _buildFrontCard(),
        ],
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 12.0,
                  spreadRadius: 0.2,
                  offset: Offset(
                    3.0,
                    3.0,
                  ),
                )
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: <Widget>[
            // Background for card
            widget.frontBackground,

            // Front Side Layout
            widget.frontLayout ??
                CardFrontLayout(
                        bankName: widget.bankName,
                        cardNumber: "XXXX XXXX ${widget.cardNumber}",
                        cardExpiry: widget.cardExpiry,
                        cardHolderName: widget.cardHolderName,
                        cardTypeIcon: getCardTypeIcon(
                            cardType: widget.cardType, brand: widget.brand),
                        cardHeight: cardHeight,
                        cardWidth: cardWidth,
                        textColor: widget.frontTextColor)
                    .layout1(),
          ],
        ),
      ),
    );
  }
}
