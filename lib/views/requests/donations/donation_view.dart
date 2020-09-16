import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/donation_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationView extends StatefulWidget {
  final RequestModel requestModel;
  final OfferModel offerModel;
  final String timabankName;
  final String notificationId;

  DonationView({this.requestModel,this.offerModel, this.timabankName, this.notificationId});

  @override
  _DonationViewState createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final DonationBloc donationBloc = DonationBloc();
  ProgressDialog progressDialog;

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
    goodsDetails: GoodsDetails(),
  );
  UserModel sevaUser = UserModel();
  String none = '';
  @override
  void initState() {
    if (none == '') {
      print(true);
    }
    print('hesdfsdfy');
    var temp = (widget.offerModel != null ? (widget.offerModel.type == RequestType.GOODS ? 3: widget.offerModel.type == RequestType.CASH ? 3: 0): widget.requestModel != null ? widget.requestModel.requestType == RequestType.GOODS ? 0 : 1: 0);
    print(temp);
    pageController = PageController(
        initialPage: temp);

    super.initState();
    print('hesdfy');
    donationBloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        showScaffold(event == 'net_error'
            ? S.of(context).general_stream_error
            : event == 'amount1'
                ? S.of(context).enter_valid_amount
                : event == 'amount2'
                    ? S.of(context).minmum_amount
                    : S.of(context).select_goods_category);
      }
    });
    print('hsdfsdfdsfey');
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
        title: Text(
          S.of(context).donations,
          style: TextStyle(fontSize: 18),
        ),
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
          donationOfferAt(),
        ],
      ),
    );
  }

  void setUpModel() {
    sevaUser = SevaCore.of(context).loggedInUser;
    if (widget.requestModel != null) {
      donationsModel.timebankId = widget.requestModel.timebankId;
      donationsModel.requestId = widget.requestModel.id;
      donationsModel.donatedToTimebank =
      widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? false
          : true;
      donationsModel.donationType = widget.requestModel.requestType;
      donationsModel.donatedTo =
      widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST
          ? widget.requestModel.sevaUserId
          : widget.requestModel.timebankId;
      donationsModel.requestTitle = widget.requestModel.title;

      donationsModel.donationAssociatedTimebankDetails =
          DonationAssociatedTimebankDetails(
            timebankTitle: widget.requestModel.fullName,
            timebankPhotoURL: widget.requestModel.photoUrl,
          );
      donationsModel.donationStatus = DonationStatus.PLEDGED;
    } else if (widget.offerModel != null) {
      donationsModel.timebankId = widget.offerModel.timebankId;
      donationsModel.requestId = widget.offerModel.id;
      donationsModel.donatedToTimebank = false;
      donationsModel.donationType = widget.offerModel.type;
      donationsModel.donatedTo = widget.offerModel.sevaUserId;
      donationsModel.requestTitle = widget.offerModel.individualOfferDataModel.title;
      donationsModel.donationAssociatedTimebankDetails = DonationAssociatedTimebankDetails();
      donationsModel.donationStatus = DonationStatus.REQUESTED;
    }
    donationsModel.communityId = sevaUser.currentCommunity;
    donationsModel.id = Utils.getUuid();
    donationsModel.donorSevaUserId = sevaUser.sevaUserID;
    donationsModel.donorDetails.name = sevaUser.fullname;
    donationsModel.donorDetails.photoUrl = sevaUser.photoURL;
    donationsModel.donorDetails.email = sevaUser.email;
    donationsModel.donorDetails.bio = sevaUser.bio;
    donationsModel.notificationId = Utils.getUuid();
  }
  Widget donationOfferAt() {
    bool autoValidateText = false;
    bool autoValidateCashText = false;
    TextStyle hintTextStyle = TextStyle(
      fontSize: 14,
      // fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Europa',
    );
    var focusNodes = List.generate(2, (_) => FocusNode());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).request_goods_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            S.of(context).request_goods_address_hint,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                donationsModel.goodsDetails.toAddress = value;
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[1],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[1]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).request_goods_address_inputhint,
              hintStyle: hintTextStyle,
            ),
            initialValue: "",
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                donationsModel.goodsDetails.toAddress = value;
                setState(() {});
              }
              return null;
            },
          ),
          SizedBox(
            height: 20,
          ),
          titleText(title: S.of(context).tell_what_you_get_donated),
          StreamBuilder<Map<dynamic, dynamic>>(
              stream: donationBloc.selectedList,
              builder: (context, snapshot) {
                List<String> keys = List.from(widget
                    .offerModel.goodsDonationDetails.requiredGoods.keys);
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget
                      .offerModel.goodsDonationDetails.requiredGoods.length,
                  itemBuilder: (context, index) {
                    print("===> " + snapshot.data.toString());

                    return Row(
                      children: [
                        Checkbox(
                          value:
                          snapshot.data?.containsKey(keys[index]) ?? false,
                          checkColor: _checkColor,
                          onChanged: (bool value) {
                            donationBloc.addAddRemove(
                              selectedValue: widget
                                  .offerModel
                                  .goodsDonationDetails
                                  .requiredGoods[keys[index]],
                              selectedKey: keys[index],
                            );
                          },
                          activeColor: Colors.grey[200],
                        ),
                        Text(
                          widget.offerModel.goodsDonationDetails
                              .requiredGoods[keys[index]],
                          style: subTitleStyle,
                        ),
                      ],
                    );
                  },
                );
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                  buttonTitle: S.of(context).submit,
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      showScaffold(S.of(context).check_internet);
                      return;
                    }
                    if (donationBloc.selectedList == null) {
                      showScaffold(S.of(context).select_goods_category);
                    } else {
                      // showProgress();
                      donationBloc
                          .donateOfferGoods(
                          notificationId: widget.notificationId,
                          donationModel: donationsModel,
                          offerModel: widget.offerModel,
                          donor: sevaUser)
                          .then((value) {
                        if (value) {
                          // hideProgress();
                          getSuccessDialog(S.of(context).donations_requested.toLowerCase()).then(
                            //to pop the screen
                                (_) => Navigator.of(context).pop(),
                          );
                        }
                      });
                    }
                  }),
              SizedBox(
                width: 20,
              ),
              actionButton(
                  buttonTitle: S.of(context).do_it_later,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          )
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
          titleText(title: S.of(context).amount_donated),
          StreamBuilder<String>(
              stream: donationBloc.amountPledged,
              builder: (context, snapshot) {
                return TextField(
                  onChanged: (value) {
                    donationBloc.onAmountChange(value);
                    setState(() {
                      amountEntered = int.parse(value);
                    });
                  },
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    errorText: snapshot.error == 'amount1'
                        ? S.of(context).enter_valid_amount
                        : snapshot.error == 'amount2'
                            ? S.of(context).minmum_amount +
                                ' ' +
                                widget.requestModel.cashModel.minAmount
                                    .toString()
                            : '',
                    hintStyle: subTitleStyle,
                    hintText: S.of(context).add_amount_donated,
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
                buttonTitle: S.of(context).done,
                onPressed: () {
                  donationBloc
                      .validateAmount(
                    minmumAmount: widget.requestModel.cashModel.minAmount,
                  )
                      .then((value) {
                    if (value) {
                      pageController.animateToPage(2,
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 500));
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget donationDetails() {
    if (widget.requestModel != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText(title: S.of(context).donations),
            SizedBox(
              height: 10,
            ),
            Text(
              '${S.of(context).donation_description_one + widget.timabankName + ' ${S.of(context).donation_description_two} ' + amountEntered.toString() + S.of(context).donation_description_three}',
              style: subTitleStyle,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              S.of(context).payment_link_description,
              style: subTitleStyle,
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text: widget.requestModel.donationInstructionLink));
                showScaffold(S.of(context).copied_to_clipboard);
              },
              onTap: () async {
                String link = widget.requestModel.donationInstructionLink;
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  showScaffold('Could not launch');

                  throw 'Could not launch';
                }
              },
              child: Text(
                getDonationLink(),
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
                  buttonTitle: S.of(context).pledge,
                  onPressed: () {
                    showProgress(S.of(context).please_wait);
                    donationBloc
                        .donateAmount(
                        notificationId: widget.notificationId,
                        donationModel: donationsModel,
                        requestModel: widget.requestModel,
                        donor: sevaUser)
                        .then((value) {
                      if (value) {
                        hideProgress();
                        getSuccessDialog(S.of(context).pledged.toLowerCase()).then(
                          //to pop the screen
                              (_) => Navigator.of(context).pop(),
                        );
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                actionButton(
                  buttonTitle: S.of(context).do_it_later,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  String getDonationLink() {
    if (widget.requestModel != null && widget.requestModel.requestType == RequestType.CASH) {
      switch (widget.requestModel.cashModel.paymentType) {
        case RequestPaymentType.ZELLEPAY:
          return widget.requestModel.cashModel.zelleId;
        case RequestPaymentType.PAYPAL:
          return widget.requestModel.cashModel.paypalId ?? '';

        default:
          return "Link not registered!";
      }
    }
    return "";
  }

  void showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void showProgress(String message) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );
    progressDialog.style(
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      message: message,
    );
    progressDialog.show();
  }

  void hideProgress() {
    progressDialog.hide();
  }

  Widget donatedItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText(title: S.of(context).tell_what_you_donated),
          StreamBuilder<String>(
              stream: donationBloc.commentEntered,
              builder: (context, snapshot) {
                return TextFormField(
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  onChanged: donationBloc.onCommentChanged,
                  decoration: InputDecoration(
                    hintStyle: subTitleStyle,
                    hintText: S.of(context).describe_goods,
                  ),
                );
              }),
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
                    print("===> " + snapshot.data.toString());

                    return Row(
                      children: [
                        Checkbox(
                          value:
                              snapshot.data?.containsKey(keys[index]) ?? false,
                          checkColor: _checkColor,
                          onChanged: (bool value) {
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
                  buttonTitle: S.of(context).donated,
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      showScaffold(S.of(context).check_internet);
                      return;
                    }
                    if (donationBloc.selectedList == null) {
                      showScaffold(S.of(context).select_goods_category);
                    } else {
                      // showProgress();

                      donationBloc
                          .donateGoods(
                              notificationId: widget.notificationId,
                              donationModel: donationsModel,
                              requestModel: widget.requestModel,
                              donor: sevaUser)
                          .then((value) {
                        if (value) {
                          // hideProgress();
                          getSuccessDialog(S.of(context).pledged.toLowerCase()).then(
                            //to pop the screen
                            (_) => Navigator.of(context).pop(),
                          );
                        }
                      });
                    }
                  }),
              SizedBox(
                width: 20,
              ),
              actionButton(
                  buttonTitle: S.of(context).do_it_later,
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
  Future<bool> getSuccessDialog(data) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Text(S
                  .of(context)
                  .successfully
                  .firstWordUpperCase()
                  .replaceFirst('.', '') +
              ' ' +
              data),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(S.of(context).ok),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
    donationBloc.dispose();
    amountEntered = 0;
  }
}
