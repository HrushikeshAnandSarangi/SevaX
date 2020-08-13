import 'dart:collection';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/requests/donations/donation_bloc.dart';

class DonationView extends StatefulWidget {
  final RequestModel requestModel;
  final int initialScreen;

  DonationView({this.requestModel, this.initialScreen});

  @override
  _DonationViewState createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DonationBloc donationBloc = DonationBloc();
  List<String> donationsCategories = [
    'Clothing',
    'Books',
    'Hygiene supplies',
    'Cleaning supplies'
  ];
  int amountEntered = 0;
  Map selectedList = {};
  bool _checked = false;
  bool _selected = false;
  Color _checkColor = Colors.black;
  PageController pageController;
  DonationModel donationsModel;
  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController(initialPage: widget.initialScreen);
    donationBloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(event),
            action: SnackBarAction(
              label:
                  AppLocalizations.of(context).translate('shared', 'dismiss'),
              onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Donations'),
        centerTitle: true,
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        onPageChanged: (number) {
          print('page changes');
        },
        children: [
          donatedItems(),
          amountWidget(),
          donationDetails(),
        ],
      ),
    );
  }

  Widget amountWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText(title: 'Amount Donated?'),
          StreamBuilder<String>(
              stream: donationBloc.amountPledged,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: donationBloc.onAmountChange,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    errorText: snapshot.error,
                    hintStyle: subTitleStyle,
                    hintText: 'Add amount that you have donated.',
                  ),
                );
              }),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                buttonTitle: 'Done',
                onPressed: () {
                  donationBloc
                      .donateAmount(donationModel: donationsModel)
                      .then((value) {
                    if (value) Navigator.pop(context);
                  });
                  pageController.animateToPage(0,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 500));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget donationDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText(title: 'Donations'),
          SizedBox(
            height: 10,
          ),
          Text(
            'Great, you have choose to donate for Timebank name a minimum donations is 1USD. Please click on the below link to fo the donation.',
            style: subTitleStyle,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              print('clicked');
            },
            child: Text(
              'www.sevaexchange.com',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                buttonTitle: 'Donated',
                onPressed: () {
                  pageController.animateToPage(2,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 500));
                },
              ),
              SizedBox(
                width: 20,
              ),
              actionButton(
                buttonTitle: 'No later',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget donatedItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText(title: 'Tell us what you have donated'),
          TextFormField(
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            maxLines: 2,
            decoration: InputDecoration(
              hintStyle: subTitleStyle,
              hintText: 'Describe your goods or select from checkbox below',
            ),
          ),
          StreamBuilder<HashSet>(
              stream: donationBloc.selectedList,
              builder: (context, snapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: donationsCategories.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Checkbox(
                          value: snapshot.data
                                  ?.contains(donationsCategories[index]) ??
                              false,
                          checkColor: _checkColor,
                          onChanged: (bool value) {
                            print(value);
                            donationBloc.addAddRemove(
                                selectedItem: donationsCategories[index]);
                          },
                          activeColor: Colors.grey[200],
                        ),
                        Text(
                          donationsCategories[index],
                          style: subTitleStyle,
                        ),
                      ],
                    );
                  },
                );
              }),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                  buttonTitle: 'Donated',
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)
                              .translate('shared', 'check_internet')),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)
                                .translate('shared', 'dismiss'),
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }

                    await FirestoreManager.createDonation(
                        donationModel: donationsModel);
                    pageController.animateToPage(1,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 500));
                  }),
              SizedBox(
                width: 20,
              ),
              actionButton(
                  buttonTitle: 'Do it later',
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget actionButton({Function onPressed, String buttonTitle}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        height: 30,
        child: RaisedButton(
          onPressed: onPressed,
          child: Text(
            buttonTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          color: Colors.grey[200],
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Widget donationCategory({String title}) {
    bool selected = false;
    return Row(
      children: [
        Checkbox(
          value: selected,
          activeColor: Colors.white70,
          checkColor: _checkColor,
          onChanged: (bool value) {
            setState(() {
              selected = value;
              // _selected = value;
            });
          },
        ),
        Text(
          title,
          style: subTitleStyle,
        ),
      ],
    );
  }

  Widget titleText({String title}) {
    return Text(
      title,
      style: titleStyle,
    );
  }

  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Europa',
    color: Colors.black,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 13,
    color: Colors.grey,
  );

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }
}
