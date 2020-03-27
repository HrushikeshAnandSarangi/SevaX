import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/card_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/utils/animations/fade_animation.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_plan_details.dart';
import 'package:sevaexchange/views/timebanks/billing/billing_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../flavor_config.dart';

class TimeBankBillingAdminView extends StatefulWidget {
  @override
  _TimeBankBillingAdminViewState createState() =>
      _TimeBankBillingAdminViewState();
}

class _TimeBankBillingAdminViewState extends State<TimeBankBillingAdminView> {
  String _billingDetailsError = '';
  String communityImageError = '';
  final _formKey = GlobalKey<FormState>();

  var scollContainer = ScrollController();
  PanelController _pc = new PanelController();
  var scrollIsOpen = false;
  List<FocusNode> focusNodes;
  GlobalKey<FormState> _billingInformationKey = GlobalKey();
  CommunityModel communityModel = CommunityModel({});
  CardModel cardModel;
  BuildContext parentContext;
  var planData = [];
  var transactionPaymentData;

  @override
  void initState() {
    super.initState();
    focusNodes = List.generate(8, (_) => FocusNode());

    Future.delayed(Duration.zero, () {
      FirestoreManager.getCommunityDetailsByCommunityId(
              communityId: SevaCore.of(context).loggedInUser.currentCommunity)
          .then((onValue) {
        communityModel = onValue;
      });
    });
  }

  String planName(String text) {
    List<String> x = text.split('_');
    return '${x[0][0].toUpperCase() + x[0].substring(1)} ${x[1][0].toUpperCase() + x[1].substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    this.parentContext = context;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            headingText("Plan Details"),
            StreamBuilder<CardModel>(
              stream: FirestoreManager.getCardModelStream(
                  communityId:
                      SevaCore.of(context).loggedInUser.currentCommunity),
              builder: (parentContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  cardModel = snapshot.data;

                  //print('cardmodel ${cardModel.currentPlan}');
                  //  print('subscription  ${cardModel.toString()}');
                  //print('subscription  ${cardModel.subscriptionModel}');
                  if (cardModel.subscriptionModel != null) {
                    String data = "";
                    cardModel.subscriptionModel.forEach((subscritpion) {
                      if (subscritpion.containsKey("items")) {
                        if (subscritpion['items']['data'] != null) {
                          planData = subscritpion['items']['data'] ?? [];

                          if (cardModel.currentPlan == "grande_plan") {
                            data =
                                "Your community is on the ${cardModel.currentPlan ?? ""}, paying Yearly. for \$${planData[0]['plan']['amount'] / 100 ?? ""} And For Additional Subscitption paying Monthly.";
                          } else {
                            data =
                                "Your community is on the ${cardModel.currentPlan ?? ""}, paying ${planData[0]['plan']['interval'] == 'month' ? 'Monthly' : 'Yearly'}. for \$${planData[0]['plan']['amount'] / 100 ?? ""}.";
                          }
                          return spendingsTextWidgettwo(data ?? "");
                        } else {
                          return emptyText();
                        }
                      } else {
                        return emptyText();
                      }
                    });

                    return spendingsTextWidgettwo(data ?? "");
                  } else {
                    return emptyText();
                  }
                } else {
                  return emptyText();
                }
              },
            ),
            headingText("Status"),

            statusWidget(),
            cardsHeadingWidget(),
            // cardsDetailWidget(),
            configureBillingHeading(parentContext),
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

  Widget spendingsTextWidgettwo(String data) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0, left: 20),
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: 16),
              text: data,
            ),
            TextSpan(
              text: data != "" ? ' change plan' : 'View selected plans',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontFamily: 'Europa',
                  decoration: TextDecoration.underline),
              recognizer: new TapGestureRecognizer()
                ..onTap = () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BillingPlanDetails(
                          user: SevaCore.of(context).loggedInUser,
                          planName: cardModel.currentPlan,
                          isPlanActive: data != "",
                          autoImplyLeading: true,
                        ),
                      ),
                    ),
            ),
          ],
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
    var now = new DateTime.now();
    var month = now.month - 1 == 0 ? 12 : now.month - 1;
    var year = now.year;
    var pastPlans = [];
    return StreamBuilder(
        stream: Firestore.instance
            .collection("communities")
            .document(SevaCore.of(context).loggedInUser.currentCommunity)
            .collection("transactions")
            .document("${month}_$year")
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            print('snap data ===>${snapshot.data.data}');

            if (snapshot.data.data != null &&
                snapshot.data.data['payment_state'] != null) {
              pastPlans = snapshot.data.data['payment_state']['plans'] ?? [];
              return ListView.builder(
                  itemCount: pastPlans.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return spendingsTextWidget(
                        "For the ${pastPlans[index]['nickname'] ?? " "} charged \$${pastPlans[index]['amount'] / 100 ?? ""} .");
                  });
            } else {
              return emptyText();
            }
          } else {
            return emptyText();
          }
        });
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: <Widget>[
////        spendingsTextWidget(
////            "You are currenlty biller to the card ending in 7777."),
//        //spendingsTextWidget("you are paying for 4 users."),
//        spendingsTextWidget(
//            "Billing emails are sent to ${SevaCore.of(parentContext).loggedInUser.email}"),
//      ],
//    );
  }

  Widget emptyText() {
    return Center(
      child: Text("No data available"),
    );
  }

  Widget cardsHeadingWidget() {
    return FutureBuilder(
        future: Firestore.instance
            .collection('cards')
            .document(SevaCore.of(context).loggedInUser.currentCommunity)
            .get(),
        builder: (context, snapshot) {
          String planName = '';
          if (snapshot.hasData && snapshot.data.data != null) {
            planName = snapshot.data.data['currentplan'];
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              headingText("Monthly subscriptions"),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 15, right: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                  ),
                  onPressed: () {
                    print("clicked");
                    if (planName == '') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BillingPlanDetails(
                            user: SevaCore.of(context).loggedInUser,
                            isPlanActive: false,
                            autoImplyLeading: true,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BillingView(
                              SevaCore.of(context)
                                  .loggedInUser
                                  .currentCommunity,
                              planName,
                              user: SevaCore.of(context).loggedInUser),
                        ),
                      );
                    }
//                builder: (context) => CustomCreditCard(
//                  frontBackground: CardBackgrounds.white,
//                  cardNumber: "7777",
//                  cardExpiry: "03/22",
//                  cardHolderName: "Umesh Raj",
//                  cardType: CardType.masterCard,
//                  bankName: "HDFC",
//                ),
//              ));
                  },
                ),
              ),
            ],
          );
        });
  }

  Widget configureBillingHeading(BuildContext buildContext) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        headingText("Edit Billing Address"),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10, right: 10),
          child: IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              print("clicked");
              FocusScope.of(buildContext).requestFocus(new FocusNode());
              _billingBottomsheet(buildContext);

//              _pc.open();
//              scrollIsOpen = true;
            },
          ),
        ),
      ],
    );
  }

  void _billingBottomsheet(BuildContext mcontext) {
    showModalBottomSheet(
        context: mcontext,
        builder: (BuildContext bc) {
          return Container(
            child: _scrollingList(focusNodes),
          );
        });
  }

//
//  Widget cardsDetailWidget() {
//    return ListView.separated(
//      itemCount: 2,
//      shrinkWrap: true,
//      physics: NeverScrollableScrollPhysics(),
//      itemBuilder: (parentContext, index) {
//        return getCardWidget();
//      },
//      separatorBuilder: (BuildContext parentContext, int index) =>
//          const Divider(),
//    );
//  }
//
//  Widget getCardWidget() {
//    return Card(
//      child: Padding(
//        padding: EdgeInsets.only(left: 10, bottom: 0, right: 5),
//        child: Row(
//          children: <Widget>[
//            Icon(
//              Icons.credit_card,
//              size: 45,
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 10),
//            ),
//            Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                Text(
//                  "FY 6773",
//                  style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontFamily: 'Europa',
//                    fontSize: 20,
//                    color: Colors.black,
//                  ),
//                ),
//                Text(
//                  "Volkswagen Golf 3",
//                  style: TextStyle(
//                    fontFamily: 'Europa',
//                    fontWeight: FontWeight.bold,
//                    fontSize: 14,
//                    color: Colors.grey,
//                  ),
//                ),
//              ],
//            ),
//            Padding(
//              padding: EdgeInsets.only(left: 20),
//            ),
//            Text(
//              "....",
//              textAlign: TextAlign.center,
//              style: TextStyle(
//                fontWeight: FontWeight.bold,
//                fontSize: 30,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 8, top: 15),
//              child: Text(
//                "7777",
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                    fontFamily: "Europa", color: Colors.black, fontSize: 18),
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.only(left: 5, top: 15),
//              child: Image.asset(
//                "images/card_provider/master_card.png",
//                width: 55,
//                height: 40,
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }

  Widget get _billingDetailsTitle {
    return Container(
//        margin: EdgeInsets.fromLTRB(10, 0, 20, 10),
        margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  'Billing Details',
                  style: TextStyle(
                      color: FlavorConfig.values.theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    //_pc.close();
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    child: Text(
                      ''' x ''',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  static InputDecoration getInputDecoration({String fieldTitle}) {
    return InputDecoration(
      errorStyle: TextStyle(
        color: Colors.red,
        wordSpacing: 2.0,
      ),
//      focusedBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.greenAccent, width: 1.0),
//      ),
//      border: OutlineInputBorder(
//          gapPadding: 0.0, borderRadius: BorderRadius.circular(1.5)),
//      enabledBorder: OutlineInputBorder(
//        borderSide: BorderSide(color: Colors.green, width: 1.0),
//      ),
      hintText: fieldTitle,

      alignLabelWithHint: true,
    );
  }

  Widget _scrollingList(List<FocusNode> focusNodes) {
    print(focusNodes);
    Widget _cityWidget(String city) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[2]);
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.city = value;
          },
          initialValue: city != null ? city : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[1],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "City",
          ),
        ),
      );
    }

    Widget _stateWidget(String state) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[1]);
          },
          onChanged: (value) {
            communityModel.billing_address.state = value;
          },
          initialValue: state != null ? state : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[0],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "State",
          ),
        ),
      );
    }

    Widget _pinCodeWidget(int pinCode) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[3]);
          },
          onChanged: (value) {
            print(value);
            communityModel.billing_address.pincode = int.parse(value);
          },
          initialValue: pinCode != null ? pinCode.toString() : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[2],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 15,
          decoration: getInputDecoration(
            fieldTitle: "ZIP Code",
          ),
        ),
      );
    }

    Widget _additionalNotesWidget(String notes) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            scrollToBottom();
          },
          onChanged: (value) {
            communityModel.billing_address.additionalnotes = value;
          },
          initialValue: notes != null ? notes : '',
//          validator: (value) {
//            return value.isEmpty ? 'Field cannot be left blank' : null;
//          },
          // onSaved: (value) {

          // },
          focusNode: focusNodes[7],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Additional Notes",
          ),
        ),
      );
    }

    Widget _streetAddressWidget(String street_address1) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[4]);
          },
          onChanged: (value) {
            communityModel.billing_address.street_address1 = value;
          },
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[3],
          textInputAction: TextInputAction.next,
          initialValue: street_address1 != null ? street_address1 : '',
          decoration: getInputDecoration(
            fieldTitle: "Street Address 1",
          ),
        ),
      );
    }

    Widget _streetAddressTwoWidget(String street_address2) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
            onFieldSubmitted: (input) {
              FocusScope.of(parentContext).requestFocus(focusNodes[5]);
            },
            onChanged: (value) {
              communityModel.billing_address.street_address2 = value;
            },
            focusNode: focusNodes[4],
            textInputAction: TextInputAction.next,
            initialValue: street_address2 != null ? street_address2 : '',
            decoration: getInputDecoration(
              fieldTitle: "Street Address 2",
            )),
      );
    }

    Widget _countryNameWidget(String country) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[6]);
          },
          onChanged: (value) {
            communityModel.billing_address.country = value;
          },
          initialValue: country != null ? country : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[5],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Country Name",
          ),
        ),
      );
    }

    Widget _companyNameWidget(String companyname) {
      return Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          onFieldSubmitted: (input) {
            FocusScope.of(parentContext).requestFocus(focusNodes[7]);
          },
          onChanged: (value) {
            communityModel.billing_address.companyname = value;
          },
          initialValue: companyname != null ? companyname : '',
          validator: (value) {
            return value.isEmpty ? 'Field cannot be left blank*' : null;
          },
          focusNode: focusNodes[6],
          textInputAction: TextInputAction.next,
          decoration: getInputDecoration(
            fieldTitle: "Company Name",
          ),
        ),
      );
    }

    Widget _continueBtn(controller) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(100, 10, 100, 20),
        child: RaisedButton(
          child: Text(
            "Continue",
            style: Theme.of(parentContext).primaryTextTheme.button,
          ),
          onPressed: () async {
            FocusScope.of(parentContext).requestFocus(new FocusNode());
            if (_billingInformationKey.currentState.validate()) {
              if (communityModel.billing_address.country == null) {
                scrollToTop();
              } else {
                print("All Good");
                showProgressDialog('Updating details');

                await FirestoreManager.updateCommunityDetails(
                    communityModel: communityModel);

                if (dialogContext != null) {
                  Navigator.pop(dialogContext);
                }
                Navigator.pop(context);
                // _pc.close();
                //scrollIsOpen = false;
              }
            }
          },
        ),
      );
    }

    return Container(
      // var scrollController = Sc
      //adding a margin to the top leaves an area where the user can swipe
      //to open/close the sliding panel
      margin: const EdgeInsets.only(top: 15.0),
      color: Colors.white,
      child: Form(
        key: _billingInformationKey,
        child: ListView(
          controller: scollContainer,
          children: <Widget>[
            _billingDetailsTitle,
            _stateWidget(communityModel.billing_address.state),
            _cityWidget(communityModel.billing_address.city),
            _pinCodeWidget(communityModel.billing_address.pincode),
            _streetAddressWidget(
                communityModel.billing_address.street_address1),
            _streetAddressTwoWidget(
                communityModel.billing_address.street_address2),
            _countryNameWidget(communityModel.billing_address.country),
            _companyNameWidget(communityModel.billing_address.companyname),
            _additionalNotesWidget(
                communityModel.billing_address.additionalnotes),
            _continueBtn(communityModel),
          ],
        ),
      ),
    );
  }

  BuildContext dialogContext;

  void showProgressDialog(String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(),
          );
        });
  }

  void scrollToTop() {
    scollContainer.animateTo(
      0.0,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  void scrollToBottom() {
    scollContainer.animateTo(
      scollContainer.position.maxScrollExtent,
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget changeButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 30,
            width: 100,
            child: RaisedButton(
              color: FlavorConfig.values.theme.accentColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillingPlanDetails(
                      user: SevaCore.of(context).loggedInUser,
                      planName: cardModel.currentPlan,
                      isPlanActive: true,
                    ),
                  ),
                );
              },
              child: Text(
                "Change",
                style: TextStyle(color: Colors.white, fontFamily: 'Europa'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpendingsCardView extends StatefulWidget {
  final CommunityModel communityModel;

  SpendingsCardView({this.communityModel});

  @override
  _SpendingsCardViewState createState() => _SpendingsCardViewState();
}

class _SpendingsCardViewState extends State<SpendingsCardView> {
  @override
  Widget build(BuildContext parentContext) {
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
            itemBuilder: (parentContext, index) {
              return spendingsCard();
            },
          ),
        ));
  }

  Widget spendingsCard() {
    return InkWell(
      onTap: () {
//        Navigator.push(
//          parentContext,
//          MaterialPageRoute(
//            builder: (parentContext) => TimebankTabsViewHolder.of(
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
