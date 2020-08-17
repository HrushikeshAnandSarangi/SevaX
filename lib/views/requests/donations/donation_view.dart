import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationView extends StatefulWidget {
  final RequestModel requestModel;
  final String timabankName;

  DonationView({this.requestModel, this.timabankName});

  @override
  _DonationViewState createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DonationBloc donationBloc = DonationBloc();

  List<String> donationsCategories = [];
  int amountEntered = 0;
  Map selectedList = {};
  bool _checked = false;
  bool _selected = false;
  Color _checkColor = Colors.black;
  PageController pageController;
  DonationModel donationsModel = DonationModel(
      donorDetails: DonorDetails(),
      cashDetails: CashDetails(),
      goodsDetails: GoodsDetails());
  UserModel sevaUser = UserModel();
  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController(
        initialPage:
            widget.requestModel.requestType == RequestType.GOODS ? 0 : 1);
    donationBloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text(event),
            action: SnackBarAction(
              label: S.of(context).dismiss,
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
    setUpModel();

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

  void setUpModel() {
    sevaUser = SevaCore.of(context).loggedInUser;

    donationsModel.timebankId = widget.requestModel.timebankId;
    donationsModel.communityId = sevaUser.currentCommunity;
    donationsModel.id = Utils.getUuid();
    donationsModel.requestId = widget.requestModel.id;
    donationsModel.donatedToTimebank =
        widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? false
            : true;
    donationsModel.donorSevaUserId = sevaUser.sevaUserID;
    donationsModel.donationType = widget.requestModel.requestType;
    donationsModel.donatedTo =
        widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? widget.requestModel.sevaUserId
            : widget.requestModel.timebankId;
    donationsModel.donorDetails.name = sevaUser.fullname;
    donationsModel.donorDetails.photoUrl = sevaUser.photoURL;
    donationsModel.donorDetails.email = sevaUser.email;
    donationsModel.donorDetails.bio = sevaUser.bio;
    donationsModel.donationStatus = DonationStatus.PLEDGED;
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
                  onChanged: (value) {
                    donationBloc.onAmountChange(value);
                    setState(() {
                      amountEntered = int.parse(value);
                    });
                    print(amountEntered);
                  },
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
                  pageController.animateToPage(2,
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
            '${'Great, you have choose to donate for ' + widget.timabankName + ' a minimum donations is ' + amountEntered.toString() + 'USD. Please click on the below link to fo the donation.'}',
            style: subTitleStyle,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Please use the link down below to donate and once done take a pledge on how much you have donated.',
            style: subTitleStyle,
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () async {
              if (await canLaunch(
                  widget.requestModel.cashModel.donationInstructionLink)) {
                await launch(
                    widget.requestModel.cashModel.donationInstructionLink);
              } else {
                throw 'couldnt launch';
              }
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
                buttonTitle: 'Pledge',
                onPressed: () {
                  donationBloc
                      .donateAmount(
                          donationModel: donationsModel,
                          requestModel: widget.requestModel,
                          donor: sevaUser)
                      .then((value) {
                    if (value) Navigator.pop(context);
                  });
                },
              ),
              SizedBox(
                width: 20,
              ),
              actionButton(
                buttonTitle: 'Do it later',
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
              hintText: 'Describe your goods and select from checkbox below',
            ),
          ),
          StreamBuilder<Map<dynamic, dynamic>>(
              stream: donationBloc.selectedList,
              builder: (context, snapshot) {
                List<String> keys = List.from(widget
                    .requestModel.goodsDonationDetails.requiredGoods.keys);
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget
                      .requestModel.goodsDonationDetails.requiredGoods.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Checkbox(
                          value: snapshot.data?.containsKey(widget
                                  .requestModel
                                  .goodsDonationDetails
                                  .requiredGoods[keys[index]]) ??
                              false,
                          checkColor: _checkColor,
                          onChanged: (bool value) {
                            print(value);
                            donationBloc.addAddRemove(
                              selectedValue: widget
                                  .requestModel
                                  .goodsDonationDetails
                                  .requiredGoods[keys[index]],
                              selectedKey: keys[index],
                            );
                          },
                          activeColor: Colors.grey[200],
                        ),
                        Text(
                          widget.requestModel.goodsDonationDetails
                              .requiredGoods[keys[index]],
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
                          content: Text(S.of(context).check_internet),
                          action: SnackBarAction(
                            label: S.of(context).dismiss,
                            onPressed: () =>
                                _scaffoldKey.currentState.hideCurrentSnackBar(),
                          ),
                        ),
                      );
                      return;
                    }
                    donationBloc
                        .donateGoods(
                            donationModel: donationsModel,
                            requestModel: widget.requestModel,
                            donor: sevaUser)
                        .then((value) {
                      if (value) Navigator.of(context).pop();
                    });
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
    donationBloc.dispose();
    amountEntered = 0;
  }
}
