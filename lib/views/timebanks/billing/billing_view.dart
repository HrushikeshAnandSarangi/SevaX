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
        publishableKey: 'pk_live_UF4dJaTWW2zXECJ5xdzuAe7P00ga985PfN',
        // publishableKey: 'pk_test_Ht3PQZ4PkldeKISCo6RYsl0v004ONW8832',
        merchantId: 'acct_1BuMJNIPTZX4UEIO',
        androidPayMode: 'production',
        // androidPayMode: 'test',
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

      _cardSuccessMessage();

      //   Navigator.of(context).pushAndRemoveUntil(
      //       MaterialPageRoute(
      //         builder: (context1) => MainApplication(
      //           skipToHomePage: true,
      //         ),
      //       ),
      //       (Route<dynamic> route) => false);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          child: Text(
                            'Note : long press to make a card default',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        ListView.separated(
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 20);
                          },
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: snapshot.data.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                // connectToStripe(cards[index]['paymentMethodId']);
                                connectToStripe(snapshot.data.data[index].id);
                              },
                              onLongPress: () => _showDialog(
                                token: snapshot.data.data[index].id,
                                communityId: widget.user.currentCommunity,
                              ),
                              child: Stack(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CustomCreditCard(
                                    bankName: "Bank Name",
                                    cardNumber:
                                        snapshot.data.data[index].card.last4,
                                    frontBackground: CardBackgrounds.black,
                                    brand:
                                        "${snapshot.data.data[index].card.brand}",
                                    cardExpiry:
                                        "${snapshot.data.data[index].card.expMonth}/${snapshot.data.data[index].card.expYear}",
                                    cardHolderName: snapshot
                                        .data.data[index].billingDetails.name,
                                  ),
                                  Offstage(
                                    offstage: true,
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            )),
                                        child: Text(
                                          'Default',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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

  void _showDialog({String token, String communityId}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Make this card as default"),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      setDefaultCard(token: token, communityId: communityId);
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 10),
                  FlatButton(
                    color: Colors.white,
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  void _cardSuccessMessage() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 600), () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context1) => MainApplication(
                  skipToHomePage: true,
                ),
              ),
              (Route<dynamic> route) => false);
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Card Added'),
              Text('It may take couple of minutes to synchronize your payment'),
            ],
          ),
        );
      },
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

Future<void> setDefaultCard({String communityId, String token}) async {
  var result = await http.post(
    "https://us-central1-sevaxproject4sevax.cloudfunctions.net/setDefaultCardForCustomer",
    body: {"communityId": communityId, "token": token},
  );
  print(result.body);
}
