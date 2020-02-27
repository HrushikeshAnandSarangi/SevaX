import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/data_managers/blocs/payment_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:stripe_payment/stripe_payment.dart';
class BillingView extends StatefulWidget {
  BillingView(this.timebankid);
  final timebankid;
  @override
  State<StatefulWidget> createState() {
    return BillingViewState();
  }
}

class BillingViewState extends State<BillingView> {
  final cards = [
    {
      'cardNo': 'xxxx xxxx xxxx 3875',
      'cardType': 'master',
      'expiryDate': '12/24',
      'paymentMethodId': 'pm_visa',
    },
    {
      'cardNo': 'xxxx xxxx xxxx 7275',
      'cardType': 'visa',
      'expiryDate': '1/28',
      'paymentMethodId': 'pm_master',
    }
  ];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: 'pk_test_T7u8J9XqipbkTR6p5pdThS7i',
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
      }).catchError((setError) => {
        print(setError)
      });
//      StripePayment.createTokenWithCard(paymentMethod.card).then((token) {
        var paymentbloc = PaymentsBloc();
        paymentbloc.storeNewCard(paymentMethod.id, widget.timebankid,  SevaCore.of(context).loggedInUser);
//      }).catchError((setError) => {
//        print(setError)
//      });
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
              color: Colors.white,
              fontFamily: 'ProximaNovaSemiBold',
            ),
          ),
        ),
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
              top: 24.0,
              right: 24.0,
            ),
            child: ListView(
              children: <Widget>[
                Row(
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
                SizedBox(height: 30),
                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 20);
                  },
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: cards.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        connectToStripe(cards[index]['paymentMethodId']);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.5))),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    cards[index]['cardNo'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'ProximaNova',
                                      color: Colors.black,
                                    ),
                                  ),
                                  checkCardType(cards[index]['cardType']),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'EXPIRY DATE: ',
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    cards[index]['expiryDate'],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon checkCardType(card) {
    switch (card) {
      case 'master':
        return Icon(
          Icons.map,
          size: 24,
        );
      case 'visa':
        return Icon(
          Icons.credit_card,
          size: 24,
        );
      default:
        return Icon(
          Icons.credit_card,
          size: 24,
        );
    }
  }
}