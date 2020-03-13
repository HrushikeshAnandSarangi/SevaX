import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/models/user_cards_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/payment_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/credit_card/utils/card_background.dart';
import 'package:stripe_payment/stripe_payment.dart';

import '../../../main_app.dart';
import '../../../widgets/credit_card/credit_card.dart';

class BillingView extends StatefulWidget {
  BillingView(this.timebankid, this.planId, {this.user});
  final timebankid;
  final String planId;
  final UserModel user;
  @override
  State<StatefulWidget> createState() {
    return BillingViewState();
  }
}

class BillingViewState extends State<BillingView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    print(widget.planId);

    StripePayment.setOptions(
      StripeOptions(
        publishableKey: 'pk_test_Ht3PQZ4PkldeKISCo6RYsl0v004ONW8832',
        merchantId: 'acct_1BuMJNIPTZX4UEIO',
        androidPayMode: 'test',
      ),
    );
    super.initState();
  }

  void setError(Error error) {
    //Handle failed transactions and errors in this method
    print('Error---------- ${error.toString()}');
  }

  Future<void> connectToStripe(String paymentMethodId) async {
    print(paymentMethodId);
    const String url = 'YOUR_SERVER_URL';
    PaymentMethod paymentMethod = PaymentMethod();
    if (paymentMethodId == null) {
      paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      ).then((PaymentMethod paymentMethod) {
        return paymentMethod;
      }).catchError((setError) => {print(setError)});
//      StripePayment.createTokenWithCard(paymentMethod.card).then((token) {
      var paymentbloc = PaymentsBloc();
      paymentbloc.storeNewCard(paymentMethod.id, widget.timebankid,
          widget.user ?? SevaCore.of(context).loggedInUser, widget.planId);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context1) => MainApplication(
              skipToHomePage: true,
            ),
          ),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Subscriptions',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'CARD DETAILS',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        connectToStripe(null);
                      },
                      child: const Text(
                        '+ Add New',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 20),
              // GestureDetector(
              //   onDoubleTap: () {
              //     print("made default");
              //   },
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       Padding(
              //         padding: const EdgeInsets.only(left: 20),
              //         child: Text('Default card'),
              //       ),
              //       CustomCreditCard(
              //         bankName: "Bank Name",
              //         cardNumber: "xxxxxx",
              //         frontBackground: CardBackgrounds.black,
              //         brand: "mastercard",
              //         cardExpiry: "22/24",
              //         cardHolderName: "Shubham",
              //       ),
              //     ],
              //   ),
              // ),
              FutureBuilder<UserCardsModel>(
                future: getUserCard(widget.user.currentCommunity),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("No cards available"),
                    );
                  }
                  if (snapshot.data != null && snapshot.hasData) {
                    // if (snapshot.data.data.isEmpty) {
                    //   return Text("No Card");
                    // }
                    return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(height: 20);
                      },
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            // connectToStripe(cards[index]['paymentMethodId']);
                            connectToStripe(snapshot.data.data[index].id);
                          },
                          child: CustomCreditCard(
                            bankName: "Bank Name",
                            cardNumber: snapshot.data.data[index].card.last4,
                            frontBackground: CardBackgrounds.black,
                            brand: "${snapshot.data.data[index].card.brand}",
                            cardExpiry:
                                "${snapshot.data.data[index].card.expMonth}/${snapshot.data.data[index].card.expYear}",
                            cardHolderName:
                                snapshot.data.data[index].billingDetails.name,
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<UserCardsModel> getUserCard(String communityId) async {
  var result = await http.post(
      "https://us-central1-sevaxproject4sevax.cloudfunctions.net/getCardsOfCustomer",
      body: {"communityId": communityId});
  print(result.body);
  if (result.statusCode == 200) {
    return userCardsModelFromJson(result.body);
  } else {
    throw Exception('No cards available');
  }
}

Future<void> setDefaultCard() async {
  var result = await http.post('');
}
