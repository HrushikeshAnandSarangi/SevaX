import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/views/core.dart';

class TimeBankBillingAdminView extends StatefulWidget {
  @override
  _TimeBankBillingAdminViewState createState() =>
      _TimeBankBillingAdminViewState();
}

class _TimeBankBillingAdminViewState extends State<TimeBankBillingAdminView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10),
            ),
            headingText("Spendings"),
            SpendingsCardView(),
            headingText("Plan Spendings"),
            spendingsTextWidget(
                "Your community is on the Strater plan (Discounted  60%), paying Monthly. Your Plan will renew on March 19, 2020 for \$77."),
            headingText("Status"),
            statusWidget(),
            cardsHeadingWidget(),
            cardsDetailWidget(),
            configureBillingHeading(),
          ],
        ),
      ),
    );
  }

  Widget spendingsTextWidget(String data) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 20),
      child: Text(
        data,
        style: TextStyle(
          fontFamily: 'Europa',
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 10, left: 20),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
    );
  }

  Widget statusWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        spendingsTextWidget(
            "You are currenlty biller to the card ending in 7777."),
        spendingsTextWidget("you are paying for 4 users."),
        spendingsTextWidget(
            "Billing emails are sent to ${SevaCore.of(context).loggedInUser.email}"),
      ],
    );
  }

  Widget cardsHeadingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        headingText("Monthly subscriptions"),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 15, right: 10),
          child: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
            ),
            onPressed: () {
              print("clicked");
            },
          ),
        ),
      ],
    );
  }

  Widget configureBillingHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        headingText("Configure Billing Address"),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 15, right: 10),
          child: IconButton(
            icon: Icon(
              Icons.add_circle_outline,
            ),
            onPressed: () {
              print("clicked");
            },
          ),
        ),
      ],
    );
  }

  Widget cardsDetailWidget() {
    return ListView.separated(
      itemCount: 2,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return getCardWidget();
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget getCardWidget() {
    return Card(
      child: Padding(
        padding: EdgeInsets.only(left: 10, bottom: 0, right: 10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.credit_card,
              size: 45,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "FY 6773",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Europa',
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Volkswagen Golf 3",
                  style: TextStyle(
                    fontFamily: 'Europa',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 20),
            ),
            Text(
              "....",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 15),
              child: Text(
                "7777",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Europa",
                    color: Colors.grey,
                    fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 15),
              child: Icon(
                Icons.credit_card,
                size: 45,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SpendingsCardView extends StatefulWidget {
  @override
  _SpendingsCardViewState createState() => _SpendingsCardViewState();
}

class _SpendingsCardViewState extends State<SpendingsCardView> {
  @override
  Widget build(BuildContext context) {
    return Container(height: 210, child: getBillingDetailsWidget());
  }

  Widget getBillingDetailsWidget() {
    return FadeAnimation(
        0,
        Container(
          height: MediaQuery.of(context).size.height * 0.25,
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 12),
            scrollDirection: Axis.horizontal,
            itemCount: 1,
            itemBuilder: (context, index) {
              return spendingsCard();
            },
          ),
        ));
  }

  Widget spendingsCard() {
    return InkWell(
      onTap: () {
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => TimebankTabsViewHolder.of(
//              timebankId: timebank.id,
//              timebankModel: timebank,
//            ),
//          ),
//        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  image: CachedNetworkImageProvider("" ?? ""),
                  fit: BoxFit.cover)),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[300],
//              gradient: LinearGradient(
//                begin: Alignment.bottomRight,
//                colors: [
//                  Colors.black.withOpacity(.8),
//                  Colors.black.withOpacity(.2),
//                ],
//              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.stars,
                  color: Colors.grey,
                  size: 45,
                ),
                headingText("Seva Coins left"),
                valueText(" \$125.00"),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: RaisedButton(
                    padding:
                        EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
                    color: Colors.red[800],
                    onPressed: () {},
                    child: Text(
                      "Recharge",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Europa',
                          fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget headingText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
    );
  }

  Widget valueText(String name) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}
