import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/dropdown_currency_constants.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/currency_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/payment_detail_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/individual_offer_bloc.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/payment_detail/capture_payment_detail_widget.dart';
import 'package:sevaexchange/views/exchange/widgets/request_utils.dart';
import 'package:sevaexchange/views/requests/donations/donation_bloc.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_drop_down.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationView extends StatefulWidget {
  final RequestModel? requestModel;
  final OfferModel? offerModel;
  final String? timabankName;
  final String? notificationId;

  const DonationView({
    this.requestModel,
    this.offerModel,
    this.timabankName,
    this.notificationId,
  });

  @override
  _DonationViewState createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  final IndividualOfferBloc _bloc = IndividualOfferBloc();
  final GlobalKey<DoseFormState> _formKey = GlobalKey();
  final DonationBloc donationBloc = DonationBloc();
  late ProgressDialog progressDialog;
  RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  String mobilePattern = r'^[0-9]+$';
  List<String> donationsCategories = [];
  int amountEntered = 0;
  Map selectedList = {};
  Color _checkColor = Colors.black;
  late PageController pageController;
  DonationModel donationsModel = DonationModel(
    donorDetails: DonorDetails(),
    receiverDetails: DonorDetails(),
    cashDetails: CashDetails(
      cashDetails: CashModel(
          paymentType: RequestPaymentType.ZELLEPAY, achdetails: ACHModel()),
    ),
    goodsDetails: GoodsDetails(),
  );
  UserModel sevaUser = UserModel();
  String none = '';
  late PaymentDetailModel paymentDetailModel;
  var focusNodes = List.generate(4, (_) => FocusNode());
  final profanityDetector = ProfanityDetector();
  double rate = 0.0;
  double amountConverted = 0.0;
  String defaultDonationCurrencyType = 'USD';
  String defaultOfferCurrenyType = 'USD';
  String currencyKey = 'USD';
  List<CurrencyModel> currencyList = CurrencyModel().getCurrency();
  String defaultFlag = kDefaultFlagImageUrl;
  final LayerLink _layerLink = LayerLink();
  int indexSelected = -1;
  bool isDropdownOpened = false;
  bool isNeedCloseDropDown = false;
  TextEditingController amountController = TextEditingController(),
      addressController = TextEditingController(),
      commentController = TextEditingController();

  @override
  void initState() {
    donationsModel.id = Utils.getUuid();
    donationsModel.notificationId = Utils.getUuid();
    paymentDetailModel = RequestUtils().initializePaymentModel(
        cashModel: donationsModel.cashDetails!.cashDetails!);
    if (widget.offerModel == null && defaultDonationCurrencyType == 'USD') {
      setState(() {
        donationsModel.cashDetails?.cashDetails?.requestDonatedCurrency =
            defaultDonationCurrencyType;
      });
    }

    var temp = (widget.offerModel != null
        ? (widget.offerModel?.type == RequestType.GOODS
            ? 3
            : widget.offerModel?.type == RequestType.CASH
                ? 4
                : 0)
        : widget.requestModel != null
            ? widget.requestModel?.requestType == RequestType.GOODS
                ? 0
                : 1
            : 0);

//    popUpHeight = (widget.offerModel != null
//        ? (widget.offerModel.type == RequestType.GOODS
//            ? 450
//            : widget.offerModel.type == RequestType.CASH
//                ? 280
//                : 280)
//        : widget.requestModel != null
//            ? widget.requestModel.requestType == RequestType.GOODS
//                ? 450
//                : 280
//            : 280);
    Future.delayed(Duration(milliseconds: 200), () {
      setUpModel();
    });
    super.initState();
    getCommunity();
    donationBloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        if (event.isNotEmpty) {
          showScaffold(event == 'general'
              ? S.of(context).general_stream_error
              : event == 'amount1'
                  ? S.of(context).enter_valid_amount
                  : event == 'amount2'
                      ? S.of(context).minmum_amount
                      : S.of(context).select_goods_category);
        }
      }
    });
  }

  void getCommunity() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      CollectionRef.communities
          .doc(SevaCore.of(context).loggedInUser.currentCommunity)
          .get()
          .then((value) {
        logger.i(">>>>>>>>>>>" +
            CommunityModel(value.data() as Map<String, dynamic>)
                .toMap()
                .toString());
        donationBloc
            .addCommunity(CommunityModel(value.data() as Map<String, dynamic>));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            S.of(context).donations,
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: DoseForm(
          formKey: _formKey,
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Card(
              margin: EdgeInsets.only(bottom: 10, top: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadowColor: Color.fromRGBO(0, 0, 0, 0.4),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        S.of(context).donations,
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    new Expanded(
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: pageController,
                        scrollDirection: Axis.horizontal,
                        pageSnapping: true,
                        onPageChanged: (number) {},
                        children: [
                          donatedItems(),
                          amountWidget(),
                          donationDetails(),
                          donationOfferAt(),
                          SingleChildScrollView(
                            // physics: NeverScrollableScrollPhysics(),
                            child: RequestPaymentDescriptionData(
                              widget.offerModel!,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setUpModel() {
    logger.e("Setting up model");
    sevaUser = SevaCore.of(context).loggedInUser;
    if (widget.requestModel != null) {
      donationsModel.timebankId = widget.requestModel?.timebankId;
      donationsModel.requestId = widget.requestModel?.id;
      donationsModel.donatedToTimebank =
          widget.requestModel?.requestMode != RequestMode.PERSONAL_REQUEST;
      donationsModel.donationType = widget.requestModel?.requestType;
      donationsModel.donatedTo =
          widget.requestModel?.requestMode == RequestMode.PERSONAL_REQUEST
              ? widget.requestModel?.sevaUserId
              : widget.requestModel?.timebankId;
      donationsModel.requestTitle = widget.requestModel?.title;

      donationsModel.donationAssociatedTimebankDetails =
          DonationAssociatedTimebankDetails(
        timebankTitle: widget.requestModel?.fullName,
        timebankPhotoURL: widget.requestModel?.photoUrl,
      );
      donationsModel.donationStatus = DonationStatus.PLEDGED;
      donationsModel.donorSevaUserId = sevaUser.sevaUserID;
      donationsModel.donorDetails?.name = sevaUser.fullname;
      donationsModel.donorDetails?.photoUrl = sevaUser.photoURL;
      donationsModel.donorDetails?.email = sevaUser.email;
      donationsModel.donorDetails?.bio = sevaUser.bio;
      donationsModel.donorDetails?.communityId = sevaUser.currentCommunity;

      donationsModel.receiverDetails?.name = widget.requestModel?.fullName;
      donationsModel.receiverDetails?.photoUrl = widget.requestModel?.photoUrl;
      donationsModel.receiverDetails?.email = widget.requestModel?.email;
      donationsModel.receiverDetails?.communityId =
          widget.requestModel?.communityId;
      donationsModel.communityId = widget.requestModel?.communityId;
    } else if (widget.offerModel != null) {
      donationsModel.timebankId = widget.offerModel?.timebankId;
      donationsModel.requestId = widget.offerModel?.id;
      donationsModel.donatedToTimebank = false;
      donationsModel.donationType = widget.offerModel?.type;
      donationsModel.donatedTo = sevaUser.sevaUserID;
      donationsModel.requestTitle =
          widget.offerModel?.individualOfferDataModel?.title;
      donationsModel.donationAssociatedTimebankDetails =
          DonationAssociatedTimebankDetails();
      donationsModel.donationStatus = DonationStatus.REQUESTED;
      donationsModel.donorSevaUserId = widget.offerModel?.sevaUserId;
      donationsModel.donorDetails?.name = widget.offerModel?.fullName;
      donationsModel.donorDetails?.photoUrl = widget.offerModel?.photoUrlImage;
      donationsModel.donorDetails?.email = widget.offerModel?.email;
      donationsModel.donorDetails?.communityId = widget.offerModel?.communityId;

      donationsModel.receiverDetails?.name = sevaUser.fullname;
      donationsModel.receiverDetails?.email = sevaUser.email;
      donationsModel.receiverDetails?.photoUrl = sevaUser.photoURL;
      donationsModel.receiverDetails?.communityId = sevaUser.currentCommunity;
      donationsModel.communityId = widget.offerModel?.communityId;
    }
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  Widget RequestPaymentDescriptionData(OfferModel offerModel) {
    return widget.offerModel != null
        ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 0,
            ),
            child: Builder(builder: (builderCntxt) {
              return Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(builderCntxt).size.height * 1.8,
                  minWidth: double.infinity,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        S.of(context).donations_cash_request,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Europa',
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        S.of(context).donations_cash_request_hint,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Europa',
                          color: Colors.grey,
                        ),
                      ),
                      DoseTextField(
                        isRequired: true,
                        controller: amountController,
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                        ],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        focusNode: focusNodes[0],
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(focusNodes[1]);
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          // prefixIcon: Icon(Icons.attach_money),
                          prefixIcon: FutureBuilder<double>(
                              future: currencyConversion(
                                  fromCurrency:
                                      offerModel.cashModel?.offerCurrencyType ??
                                          'USD',
                                  toCurrency: defaultOfferCurrenyType,
                                  amount:
                                      (offerModel.cashModel?.targetAmount ?? 0)
                                          .toDouble()),
                              builder: (context, snapshot) {
                                amountConverted = snapshot.data ?? 0.0;
                                return Container(
                                  width: 90,
                                  child: CompositedTransformTarget(
                                    link: _layerLink,
                                    child: CustomDropdownView(
                                      layerLink: _layerLink,
                                      isNeedCloseDropdown: isNeedCloseDropDown,
                                      elevationShadow: 20,
                                      decorationDropdown: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      defaultWidget: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        // padding: EdgeInsets.symmetric(horizontal: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              indexSelected != -1
                                                  ? "${currencyList[indexSelected].code}"
                                                  : defaultOfferCurrenyType,
                                              style: kDropDownChildCurrencyCode,
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              height: kFlagImageContainerHeight,
                                              width: kFlagImageContainerWidth,
                                              child: Image.network(
                                                defaultFlag,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            isDropdownOpened
                                                ? Icon(
                                                    Icons.keyboard_arrow_up,
                                                    color: Color(0xFF737579),
                                                  )
                                                : kDropDownArrowIcon,
                                          ],
                                        ),
                                      ),
                                      onTapDropdown:
                                          (bool _isDropdownOpened) async {
                                        await Future.delayed(Duration.zero);
                                        setState(() {
                                          isDropdownOpened = _isDropdownOpened;
                                          if (_isDropdownOpened == false)
                                            isNeedCloseDropDown = false;
                                        });
                                      },
                                      listWidgetItem: List.generate(
                                          currencyList.length, (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              indexSelected = index;
                                              isNeedCloseDropDown = true;
                                              defaultOfferCurrenyType =
                                                  currencyList[indexSelected]
                                                          .code ??
                                                      'USD';
                                              currencyKey =
                                                  currencyList[indexSelected]
                                                          .code ??
                                                      'USD';
                                              _bloc.offerDonatedCurrencyType(
                                                  currencyKey);
                                              donationBloc
                                                  .offerDonatedCurrencyType(
                                                      currencyList[
                                                                  indexSelected]
                                                              .code ??
                                                          'USD');
                                              defaultFlag =
                                                  currencyList[indexSelected]
                                                          .imagePath ??
                                                      '';
                                            });

                                            if (currencyKey !=
                                                offerModel.cashModel
                                                    ?.offerCurrencyType) {
                                              progressDialog =
                                                  ProgressDialog(context,
                                                      customBody: Container(
                                                        height: 100,
                                                        width: 100,
                                                        child:
                                                            LoadingIndicator(),
                                                      ));

                                              progressDialog.show();
                                            }
                                            currencyConversion(
                                                    fromCurrency: offerModel
                                                            .cashModel
                                                            ?.offerCurrencyType ??
                                                        'USD',
                                                    toCurrency: currencyList[
                                                                indexSelected]
                                                            .code ??
                                                        'USD',
                                                    amount: offerModel.cashModel
                                                            ?.targetAmount
                                                            ?.toDouble() ??
                                                        0.0)
                                                .then((value) {
                                              amountConverted = value;
                                              setState(() {});
                                              progressDialog.hide();
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: index == 0
                                                    ? Radius.circular(4)
                                                    : Radius.zero,
                                                bottom: index ==
                                                        currencyList.length - 1
                                                    ? Radius.circular(4)
                                                    : Radius.zero,
                                              ),
                                              color: indexSelected == index
                                                  ? Color(0xFFE8EFFF)
                                                  : Colors.white,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 12,
                                                        width: 16,
                                                        child: Image.network(
                                                          "${currencyList[index].imagePath}",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "${currencyList[index].code}",
                                                        style:
                                                            kDropDownChildCurrencyCode,
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "${currencyList[index].name}",
                                                        style:
                                                            kDropDownChildCurrencyName,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 9,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).validation_error_general_text;
                          } else if (int.parse(value.toString()) < 1) {
                            return S.of(context).please_enter_valid_amount;
                          } else if (value.isNotEmpty) {
                            if (int.parse(value.toString()) > amountConverted) {
                              return S
                                  .of(context)
                                  .request_amount_cannot_be_greater;
                            }
                            /*  if (int.parse(value) > offerModel.cashModel.targetAmount) {
                      return S.of(context).request_amount_cannot_be_greater;
                    }*/
                            donationsModel.cashDetails?.cashDetails
                                ?.amountRaised = double.parse(value.toString());
                          } else {
                            return S.of(context).enter_valid_amount;
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CapturePaymentDetailWidget(
                          paymentDetailModel: paymentDetailModel,
                          capturePaymentFrom: CapturePaymentFrom.DONATION,
                          onDropDownChanged: (value) {
                            switch (value) {
                              case PaymentMode.ACH:
                                donationsModel.cashDetails?.cashDetails
                                    ?.paymentType = RequestPaymentType.ACH;
                                break;
                              case PaymentMode.ZELLEPAY:
                                donationsModel.cashDetails!.cashDetails!
                                    .paymentType = RequestPaymentType.ZELLEPAY;
                                break;
                              case PaymentMode.PAYPAL:
                                donationsModel.cashDetails!.cashDetails!
                                    .paymentType = RequestPaymentType.PAYPAL;
                                break;
                              case PaymentMode.VENMO:
                                donationsModel.cashDetails!.cashDetails!
                                    .paymentType = RequestPaymentType.VENMO;
                                break;
                              case PaymentMode.SWIFT:
                                donationsModel.cashDetails!.cashDetails!
                                    .paymentType = RequestPaymentType.SWIFT;
                                break;
                              case PaymentMode.OTHER:
                                donationsModel.cashDetails!.cashDetails!
                                    .paymentType = RequestPaymentType.OTHER;
                                break;
                            }
                            // donationsModel.cashDetails.cashDetails.paymentType = value;
                          },
                          onPaymentEventChanged: (event) {
                            if (event is ZellePayment) {
                              donationsModel.cashDetails?.cashDetails?.zelleId =
                                  event.zelleId;
                            } else if (event is ACHPayment) {
                              donationsModel.cashDetails?.cashDetails
                                  ?.achdetails?.bank_name = event.bank_name;
                              donationsModel
                                  .cashDetails
                                  ?.cashDetails
                                  ?.achdetails
                                  ?.bank_address = event.bank_address;
                              donationsModel
                                  .cashDetails
                                  ?.cashDetails
                                  ?.achdetails
                                  ?.account_number = event.account_number;
                              donationsModel
                                  .cashDetails
                                  ?.cashDetails
                                  ?.achdetails
                                  ?.routing_number = event.routing_number;
                            } else if (event is PayPalPayment) {
                              donationsModel.cashDetails!.cashDetails!
                                  .paypalId = event.paypalId;
                            } else if (event is VenmoPayment) {
                              donationsModel.cashDetails!.cashDetails!.venmoId =
                                  event.venmoId;
                            } else if (event is SwiftPayment) {
                              donationsModel.cashDetails!.cashDetails!.swiftId =
                                  event.swiftId;
                            } else if (event is OtherPayment) {
                              donationsModel.cashDetails!.cashDetails!.others =
                                  event.others;
                              donationsModel.cashDetails!.cashDetails!
                                  .other_details = event.other_details;
                            }
                            // logger.d("*DONATIONS* CASH MODEL CHANGED ${jsonEncode(cashModel.toMap())}");
                            // donationsModel.cashDetails.cashDetails = cashModel;
                          }),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CustomTextButton(
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              child: Text(S.of(context).submit),
                              onPressed: () async {
                                //check validation here
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  var connResult =
                                      await Connectivity().checkConnectivity();
                                  if (connResult == ConnectivityResult.none) {
                                    showScaffold(S.of(context).check_internet);
                                    return;
                                  }

                                  showProgress(S.of(context).please_wait);
                                  if (widget.offerModel == null) return;
                                  donationBloc
                                      .donateOfferGoods(
                                          notificationId:
                                              widget.notificationId ?? '',
                                          donationModel: donationsModel,
                                          offerModel: widget.offerModel!,
                                          notify: UserModel(
                                              email: donationsModel
                                                  .donorDetails!.email,
                                              fullname: donationsModel
                                                  .donorDetails!.name,
                                              photoURL: donationsModel
                                                  .donorDetails!.photoUrl,
                                              sevaUserID: donationsModel
                                                  .donorSevaUserId))
                                      .then((value) {
                                    if (value) {
                                      hideProgress();
                                      getSuccessDialog(S
                                              .of(context)
                                              .donations_requested
                                              .toLowerCase())
                                          .then(
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
                              buttonColor: Colors.grey,
                              textColor: Colors.black,
                              buttonTitle: S.of(context).do_it_later,
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ],
                      )
                    ]),
              );
            }))
        : Container();
  }

  Widget donatedItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          titleText(title: S.of(context).tell_what_you_donated),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<String>(
              stream: donationBloc.commentEntered,
              builder: (context, snapshot) {
                return DoseTextField(
                  controller: commentController,
                  keyboardType: TextInputType.text,
                  focusNode: focusNodes[3],
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  onChanged: donationBloc.onCommentChanged,
                  decoration: InputDecoration(
                    filled: true,
                    focusColor: Colors.grey[200],
                    focusedErrorBorder: customTextFieldBorder(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: customTextFieldBorder(),
                    errorBorder: customTextFieldBorder(),
                    enabledBorder: customTextFieldBorder(),
                    hintStyle: subTitleStyle,
                    hintText: S.of(context).describe_goods,
                  ),
                );
              }),
          StreamBuilder<Map<dynamic, dynamic>>(
              stream: donationBloc.selectedList,
              builder: (context, snapshot) {
                List<String> keys = List.from(widget
                    .requestModel!.goodsDonationDetails!.requiredGoods.keys);
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget
                      .requestModel!.goodsDonationDetails!.requiredGoods.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Checkbox(
                          value:
                              snapshot.data?.containsKey(keys[index]) ?? false,
                          checkColor: _checkColor,
                          onChanged: (bool? value) {
                            donationBloc.addAddRemove(
                              selectedValue: widget
                                      .requestModel
                                      ?.goodsDonationDetails
                                      ?.requiredGoods[keys[index]] ??
                                  '',
                              selectedKey: keys[index],
                            );
                          },
                          activeColor: Colors.grey[200],
                        ),
                        Text(
                          widget.requestModel?.goodsDonationDetails
                                  ?.requiredGoods[keys[index]] ??
                              '',
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
                  buttonColor: Colors.grey,
                  textColor: Colors.black,
                  buttonTitle: S.of(context).do_it_later,
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              SizedBox(
                width: 20,
              ),
              actionButton(
                  buttonTitle: S.of(context).donate_text,
                  buttonColor: Colors.orange,
                  textColor: Colors.white,
                  onPressed: () async {
                    var connResult = await Connectivity().checkConnectivity();
                    if (connResult == ConnectivityResult.none) {
                      showScaffold(S.of(context).check_internet);
                      return;
                    }
                    if (donationBloc.selectedListVal == null) {
                      logger.i("no donation items");
                      showScaffold(S.of(context).select_goods_category);
                    } else if (donationBloc.selectedListVal.length == 0) {
                      logger.i("no donation items");
                      showScaffold(S.of(context).select_goods_category);
                    } else if (donationBloc.commentEnteredVal == null) {
                      showScaffold("Description cannot be empty");
                    } else if (donationBloc.commentEnteredVal.isEmpty) {
                      showScaffold("Description cannot be empty");
                    } else {
                      logger.i("donation items selectedddddddd");
                      showProgress(S.of(context).please_wait);
                      donationBloc
                          .donateGoods(
                              notificationId: widget.notificationId!,
                              donationModel: donationsModel,
                              requestModel: widget.requestModel!,
                              donor: sevaUser)
                          .then((value) {
                        if (value) {
                          hideProgress();
                          getSuccessDialog(S.of(context).pledged.toLowerCase())
                              .then(
                            //to pop the screen
                            (_) => Navigator.of(context).pop(),
                          );
                        }
                      });
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget donationOfferAt() {
    TextStyle hintTextStyle = TextStyle(
      fontSize: 14,
      // fontWeight: FontWeight.bold,
      color: Colors.grey,
      fontFamily: 'Europa',
    );
    var focusNodes = List.generate(2, (_) => FocusNode());
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
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
            DoseTextField(
              isRequired: true,
              controller: addressController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                donationsModel.goodsDetails?.toAddress = value;
              },
              focusNode: focusNodes[1],
              onFieldSubmitted: (v) {
                FocusScope.of(context).requestFocus(focusNodes[1]);
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                filled: true,
                focusColor: Colors.grey[200],
                focusedErrorBorder: customTextFieldBorder(),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: customTextFieldBorder(),
                errorBorder: customTextFieldBorder(),
                enabledBorder: customTextFieldBorder(),
                errorMaxLines: 2,
                hintText: S.of(context).request_goods_address_inputhint,
                hintStyle: hintTextStyle,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return S.of(context).validation_error_general_text;
                } else {
                  donationsModel.goodsDetails?.toAddress = value;
                  // setState(() {});
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
                      .offerModel!.goodsDonationDetails!.requiredGoods.keys);
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: widget
                        .offerModel!.goodsDonationDetails!.requiredGoods.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Checkbox(
                            value: snapshot.data?.containsKey(keys[index]) ??
                                false,
                            checkColor: _checkColor,
                            onChanged: (bool? value) {
                              donationBloc.addAddRemove(
                                selectedValue: widget
                                        .offerModel
                                        ?.goodsDonationDetails
                                        ?.requiredGoods[keys[index]] ??
                                    '',
                                selectedKey: keys[index],
                              );
                            },
                            activeColor: Colors.grey[200],
                          ),
                          Text(
                            widget.offerModel?.goodsDonationDetails
                                    ?.requiredGoods[keys[index]] ??
                                '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
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
                    buttonColor: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    buttonTitle: S.of(context).submit,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (donationBloc.isSelectedListEmpty) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select the goods that you want to receive',
                              ),
                            ),
                          );
                          return;
                        } else {
                          var connResult =
                              await Connectivity().checkConnectivity();
                          if (connResult == ConnectivityResult.none) {
                            showScaffold(S.of(context).check_internet);
                            return;
                          }
                          if (donationBloc.selectedListVal == null) {
                            showScaffold(S.of(context).select_goods_category);
                          } else {
                            showProgress(S.of(context).please_wait);

                            donationBloc
                                .donateOfferGoods(
                                    notificationId: widget.notificationId!,
                                    donationModel: donationsModel,
                                    offerModel: widget.offerModel!,
                                    notify: UserModel(
                                        email: widget.offerModel!.email,
                                        fullname: widget.offerModel!.fullName,
                                        photoURL:
                                            widget.offerModel!.photoUrlImage,
                                        sevaUserID:
                                            widget.offerModel!.sevaUserId))
                                .then((value) {
                              if (value) {
                                hideProgress();
                                getSuccessDialog(S
                                        .of(context)
                                        .donations_requested
                                        .toLowerCase())
                                    .then(
                                  //to pop the screen
                                  (_) => Navigator.of(context).pop(),
                                );
                              }
                            });
                          }
                        }
                      }
                    }),
                SizedBox(
                  width: 20,
                ),
                actionButton(
                    buttonColor: Colors.grey,
                    textColor: Colors.black,
                    buttonTitle: S.of(context).do_it_later,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget amountWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          titleText(title: S.of(context).amount_pledged + '?'),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<String>(
            stream: donationBloc.amountPledged,
            builder: (context, snapshot) {
              return Container(
                // constraints: BoxConstraints(maxHeight: 55, minHeight: 50),
                child: DoseTextField(
                  isRequired: false,
                  controller: amountController,
                  focusNode: focusNodes[2],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      donationBloc.onAmountChange(value);
                      setState(() {
                        amountEntered = int.parse(value);
                      });
                    }
                  },
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 10),
                    filled: true,
                    focusColor: Colors.grey[200],
                    focusedErrorBorder: customTextFieldBorder(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: customTextFieldBorder(),
                    errorBorder: customTextFieldBorder(),
                    enabledBorder: customTextFieldBorder(),
                    errorText: snapshot.error == 'amount1'
                        ? S.of(context).enter_valid_amount
                        : snapshot.error == 'amount2'
                            ? S.of(context).minmum_amount +
                                ' ' +
                                rate.toInt().toString() +
                                ' ' +
                                (donationsModel.cashDetails?.cashDetails
                                        ?.requestDonatedCurrency ??
                                    'USD')
                            : '',
                    hintStyle: subTitleStyle,
                    hintText: S.of(context).add_amount_donated,
                    alignLabelWithHint: true,
                    prefixIcon: Container(
                      width: 90,
                      child: CompositedTransformTarget(
                        link: _layerLink,
                        child: CustomDropdownView(
                          layerLink: _layerLink,
                          isNeedCloseDropdown: isNeedCloseDropDown,
                          elevationShadow: 20,
                          decorationDropdown: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          defaultWidget: Container(
                            height: 51,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            // padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 4),
                                Text(
                                  indexSelected != -1
                                      ? "${currencyList[indexSelected].code}"
                                      : defaultDonationCurrencyType,
                                  style: kDropDownChildCurrencyCode,
                                ),
                                SizedBox(width: 8),
                                Container(
                                  height: kFlagImageContainerHeight,
                                  width: kFlagImageContainerWidth,
                                  child: Image.network(
                                    defaultFlag,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8),
                                isDropdownOpened
                                    ? Icon(
                                        Icons.keyboard_arrow_up,
                                        color: Color(0xFF737579),
                                      )
                                    : kDropDownArrowIcon,
                              ],
                            ),
                          ),
                          onTapDropdown: (bool _isDropdownOpened) async {
                            await Future.delayed(Duration.zero);
                            setState(() {
                              isDropdownOpened = _isDropdownOpened;
                              if (_isDropdownOpened == false)
                                isNeedCloseDropDown = false;
                            });
                          },
                          listWidgetItem:
                              List.generate(currencyList.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  indexSelected = index;
                                  isNeedCloseDropDown = true;
                                  defaultDonationCurrencyType =
                                      currencyList[indexSelected].code ?? 'USD';
                                  donationBloc.requestDonatedCurrencyType(
                                      currencyList[indexSelected].code ??
                                          'USD');
                                  donationsModel.cashDetails?.cashDetails
                                          ?.requestDonatedCurrency =
                                      currencyList[indexSelected].code ?? 'USD';
                                  defaultFlag =
                                      currencyList[indexSelected].imagePath ??
                                          '';
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    top: index == 0
                                        ? Radius.circular(4)
                                        : Radius.zero,
                                    bottom: index == currencyList.length - 1
                                        ? Radius.circular(4)
                                        : Radius.zero,
                                  ),
                                  color: indexSelected == index
                                      ? Color(0xFFE8EFFF)
                                      : Colors.white,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 12,
                                            width: 16,
                                            child: Image.network(
                                              "${currencyList[index].imagePath}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "${currencyList[index].code}",
                                            style: kDropDownChildCurrencyCode,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "${currencyList[index].name}",
                                            style: kDropDownChildCurrencyName,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 9,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              actionButton(
                buttonTitle: S.of(context).cancel,
                buttonColor: Colors.grey,
                textColor: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                width: 20,
              ),
              actionButton(
                buttonTitle: S.of(context).next,
                buttonColor: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () async {
                  // logger.d("#FROM C ${defaultDonationCurrencyType}");
                  rate = await currencyConversion(
                          fromCurrency: widget?.requestModel?.cashModel
                                  ?.requestCurrencyType ??
                              "USD",
                          toCurrency: donationsModel?.cashDetails?.cashDetails
                                  ?.requestDonatedCurrency ??
                              "USD",
                          amount: widget?.requestModel?.cashModel?.minAmount
                                  ?.toDouble() ??
                              0.0)
                      .then((value) => rate = value);
                  logger.d("#FROM C ${defaultDonationCurrencyType}");
                  logger.d("#rate C ${rate}");
                  //  logger.d("#FROM C ${defaultDonationCurrencyType}");

                  donationBloc
                      .validateAmount(
                    minmumAmount: rate.toInt(),
                  )
                      .then((value) {
                    FocusScope.of(context).unfocus();
                    if (value) {
                      pageController.animateToPage(
                        2,
                        curve: Curves.easeInOut,
                        duration: Duration(milliseconds: 500),
                      );
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
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            titleText(title: S.of(context).donations),
            SizedBox(
              height: 10,
            ),
            Text(
              "${S.of(context).donation_description_one}  ${widget.timabankName}  ${S.of(context).donation_description_two}  ${amountEntered.toString()} ${donationsModel.cashDetails?.cashDetails?.requestDonatedCurrency ?? 'USD'}",
              style: TextStyle(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              S.of(context).payment_link_description,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text: widget.requestModel!.donationInstructionLink!));
                showScaffold(S.of(context).copied_to_clipboard);
              },
              onTap: () async {
                String link = getDonationLink();
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  showScaffold('Could not launch');
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
                  buttonColor: Colors.grey,
                  textColor: Colors.black,
                  buttonTitle: S.of(context).do_it_later,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                actionButton(
                  buttonTitle: S.of(context).pledge,
                  buttonColor: Colors.orange,
                  textColor: Colors.white,
                  onPressed: () {
                    showProgress(S.of(context).please_wait);
                    donationBloc
                        .donateAmount(
                            notificationId: widget.notificationId!,
                            donationModel: donationsModel,
                            requestModel: widget.requestModel!,
                            donor: sevaUser)
                        .then((value) {
                      if (value) {
                        hideProgress();
                        getSuccessDialog(S.of(context).pledged.toLowerCase())
                            .then(
                          //to pop the screen
                          (_) => Navigator.of(context).pop(),
                        );
                      }
                    });
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
    if (widget.requestModel != null &&
        widget.requestModel?.requestType == RequestType.CASH) {
      switch (widget.requestModel?.cashModel?.paymentType) {
        case RequestPaymentType.ZELLEPAY:
          return widget.requestModel?.cashModel?.zelleId ?? '';
        case RequestPaymentType.PAYPAL:
          return widget.requestModel?.cashModel?.paypalId ?? '';
        case RequestPaymentType.VENMO:
          return widget.requestModel?.cashModel?.venmoId ?? '';
        case RequestPaymentType.SWIFT:
          return widget.requestModel?.cashModel?.swiftId ?? '';
        case RequestPaymentType.ACH:
          final achDetails = widget.requestModel?.cashModel?.achdetails;
          return [
            S.of(context).account_information,
            achDetails?.account_number ?? '',
            achDetails?.bank_name ?? '',
            achDetails?.bank_address ?? '',
            achDetails?.routing_number ?? ''
          ].join('\n');
        case RequestPaymentType.OTHER:
          return [
            S.of(context).other_payment_details,
            widget.requestModel?.cashModel?.others ?? '',
            widget.requestModel?.cashModel?.other_details ?? ''
          ].join('\n');
        default:
          return "Link not provided!";
      }
    }
    return "";
  }

  void showScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: S.of(context).dismiss,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void showProgress(String message) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
    );
    progressDialog.show();
  }

  void hideProgress() {
    try {
      progressDialog.hide();
    } catch (e) {
      logger.i("ERROR Please ADDDRESS");
    }
  }

  Widget actionButton({
    required VoidCallback onPressed,
    required String buttonTitle,
    required Color buttonColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        height: 37,
        child: CustomElevatedButton(
          textColor: textColor,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          elevation: 0,
          child: Text(
            buttonTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          color: buttonColor,
          shape: StadiumBorder(),
        ),
      ),
    );
  }

  Widget titleText({required String title}) {
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
            CustomTextButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
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

  OutlineInputBorder customTextFieldBorder() {
    return OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!, width: 0.5),
        borderRadius: BorderRadius.circular(5));
  }
}
