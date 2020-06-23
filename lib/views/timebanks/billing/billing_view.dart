import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/user_cards_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/payment_bloc.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/credit_card/utils/card_background.dart';
import 'package:stripe_payment/stripe_payment.dart';

import '../../../main_app.dart';
import '../../../main_seva_dev.dart' as dev;
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

  Future<UserCardsModel> userCardDetails;
  @override
  void initState() {
    print(widget.planId);
    userCardDetails = getUserCard(widget.user.currentCommunity);
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: FlavorConfig.values.stripePublishableKey,
        androidPayMode: FlavorConfig.values.androidPayMode,
        merchantId: 'acct_1BuMJNIPTZX4UEIO',
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)
                .translate('billing_admin', 'subscriptions'),
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
                    Text(
                      AppLocalizations.of(context)
                          .translate('billing_admin', 'card_details'),
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        connectToStripe(null);
                      },
                      child: Text(
                        '+ ${AppLocalizations.of(context).translate('billing_admin', 'add_new')}',
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
              FutureBuilder<UserCardsModel>(
                future: userCardDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('billing_admin', 'no_cards')),
                    );
                  }
                  if (snapshot.data != null && snapshot.hasData) {
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('billing_admin', 'note'),
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
                            //  print(" user cards data ${snapshot.data.data[index]}");

                            bool isDefault = false;
                            if (snapshot.data.data[index].isDefault != null &&
                                snapshot.data.data[index].isDefault == true) {
                              isDefault = true;
                            }

                            return GestureDetector(
                              onTap: () {
                                // connectToStripe(cards[index]['paymentMethodId']);
                                connectToStripe(snapshot.data.data[index].id);
                              },
                              onLongPress: () => isDefault
                                  ? _showAlreadyDefaultMessage()
                                  : _showDialog(
                                      token: snapshot.data.data[index].id,
                                      communityId: widget.user.currentCommunity,
                                    ),
                              child: Stack(
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CustomCreditCard(
                                    isDefaultCard: isDefault,
                                    bankName: AppLocalizations.of(context)
                                        .translate(
                                            'billing_admin', 'bank_name'),
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
                                    offstage: isDefault ? false : true,
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
                                          AppLocalizations.of(context)
                                              .translate(
                                                  'billing_admin', 'default'),
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

  void _showAlreadyDefaultMessage() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(AppLocalizations.of(context)
              .translate('billing_admin', 'default')),
          content: new Text(AppLocalizations.of(context)
              .translate('billing_admin', 'default_card_desc')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                  AppLocalizations.of(context).translate('shared', 'close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
              Text(AppLocalizations.of(context)
                  .translate('billing_admin', 'make_default')),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text(AppLocalizations.of(context)
                        .translate('billing_admin', 'confirm')),
                    onPressed: () {
                      //showProgressDialog('Adding default card');
                      setDefaultCard(token: token, communityId: communityId)
                          .then((_) {
                        userCardDetails = getUserCard(widget.timebankid);

                        setState(() {});
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 10),
                  FlatButton(
                    color: Colors.white,
                    child: Text(AppLocalizations.of(context)
                        .translate('billing_admin', 'cancel')),
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
                builder: (context1) => FlavorConfig.appFlavor == Flavor.APP
                    ? MainApplication()
                    : dev.MainApplication(),
              ),
              (Route<dynamic> route) => false);
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppLocalizations.of(context)
                  .translate('billing_admin', 'card_added')),
              Text(AppLocalizations.of(context)
                  .translate('billing_admin', 'synced')),
            ],
          ),
        );
      },
    );
  }
}

Future<UserCardsModel> getUserCard(String communityId) async {
  var result = await http.post(
      "${FlavorConfig.values.cloudFunctionBaseURL}/getCardsOfCustomer",
      body: {"communityId": communityId});
  // print(result.body);
  if (result.statusCode == 200) {
    return userCardsModelFromJson(result.body);
  } else {
    throw Exception('No cards available');
  }
}

Future<bool> setDefaultCard({String communityId, String token}) async {
  var result = await http.post(
    "${FlavorConfig.values.cloudFunctionBaseURL}/setDefaultCardForCustomer",
    body: {"communityId": communityId, "token": token},
  );
  print(result.body);
  return true;
}
