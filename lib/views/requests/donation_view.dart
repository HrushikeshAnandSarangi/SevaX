import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';

class DonationView extends StatefulWidget {
  @override
  _DonationViewState createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  List<String> donationsCategories = [
    'Clothing',
    'Books',
    'Hygiene supplies',
    'Cleaning supplies'
  ];
  bool _checked = false;
  bool _selected = false;
  Color _activeColor = Colors.green;
  Color _checkColor = Colors.black;
  PageController pageController = PageController();
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
        controller: pageController,
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        onPageChanged: (number) {
          print('page changes');
        },
        children: [
          donatedItems(),
          donationDetails(),
          amountWidget(),
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
          TextFormField(
            maxLines: 1,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintStyle: subTitleStyle,
              hintText: 'Add amount that you have donated.',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                buttonTitle: 'Done',
                onPressed: () {
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
                onPressed: () {},
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
          ListView.builder(
            shrinkWrap: true,
            itemCount: donationsCategories.length,
            itemBuilder: (context, index) {
              return donationCategory(title: donationsCategories[index]);
            },
          ),
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

                    pageController.animateToPage(1,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 500));
                  }),
              SizedBox(
                width: 20,
              ),
              actionButton(
                  buttonTitle: 'Do it later',
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
    return Row(
      children: [
        Checkbox(
          value: _checked,
          activeColor: _activeColor,
          checkColor: _checkColor,
          onChanged: (bool value) {
            setState(() {
              _checked = value;
              _selected = value;
            });
          },
        ),
        Text(
          title,
          style: subTitleStyle,
        ),
      ],
    );
//    return ListTile(
//      leading: Checkbox(
//        value: _checked,
//        activeColor: _activeColor,
//        checkColor: _checkColor,
//        onChanged: (bool value) {
//          setState(() {
//            _checked = value;
//            _selected = value;
//          });
//        },
//      ),
//      title: Text(title),
//    );
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
}

class DonatedItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Tell us what you have donated'),
        TextFormField(
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Describe your goods or select from checkbox below',
          ),
        ),
      ],
    );
  }
}
