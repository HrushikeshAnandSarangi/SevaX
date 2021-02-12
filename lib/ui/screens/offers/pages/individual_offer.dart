import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/individual_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class IndividualOffer extends StatefulWidget {
  final OfferModel offerModel;
  final String timebankId;

  const IndividualOffer({Key key, this.offerModel, this.timebankId})
      : super(key: key);

  @override
  _IndividualOfferState createState() => _IndividualOfferState();
}

class _IndividualOfferState extends State<IndividualOffer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final IndividualOfferBloc _bloc = IndividualOfferBloc();
  String selectedAddress;
  CustomLocation customLocation;

  String title = '';
  String title_hint;
  String description_hint;

  FocusNode _title = FocusNode();
  FocusNode _description = FocusNode();
  FocusNode _availability = FocusNode();
  var focusNodes = List.generate(8, (_) => FocusNode());
  @override
  void initState() {
    AppConfig.helpIconContext = HelpIconContextClass.TIME_OFFERS;

    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel);
      title = widget.offerModel.individualOfferDataModel.title;
      AppConfig.helpIconContext = widget.offerModel.type == RequestType.TIME
          ? HelpIconContextClass.TIME_OFFERS
          : widget.offerModel.type == RequestType.CASH
              ? HelpIconContextClass.MONEY_OFFERS
              : HelpIconContextClass.GOODS_OFFERS;
    }
    super.initState();

    _bloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        showScaffold(
            event == 'goods' ? S.of(context).select_goods_category : null);
      }
    });
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

  @override
  void dispose() {
    _bloc.dispose();
    _title.dispose();
    _description.dispose();
    _availability.dispose();
    super.dispose();
  }

  Widget _optionRadioButton(
      {String title, value, groupvalue, Function onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading:
          Radio(value: value, groupValue: groupvalue, onChanged: onChanged),
    );
  }

  Widget RequestTypeWidget() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<RequestType>(
              stream: _bloc.type,
              builder: (context, snapshot) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).offer_type,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    ),
                    TransactionsMatrixCheck(
                      upgradeDetails:
                          AppConfig.upgradePlanBannerModel.cash_donation,
                      transaction_matrix_type: "cash_goods_offers",
                      comingFrom: ComingFrom.Offers,
                      child: Column(
                        children: <Widget>[
                          _optionRadioButton(
                            title: S.of(context).request_type_time,
                            value: RequestType.TIME,
                            groupvalue: snapshot.data != null
                                ? snapshot.data
                                : RequestType.TIME,
                            onChanged: (data) {
                              AppConfig.helpIconContext =
                                  HelpIconContextClass.TIME_OFFERS;
                              _bloc.onTypeChanged(data);
                              title_hint = S.of(context).offer_title_hint;
                              description_hint =
                                  S.of(context).offer_description_hint;
                              setState(() {});
                            },
                          ),
                          _optionRadioButton(
                              title: S.of(context).request_type_cash,
                              value: RequestType.CASH,
                              groupvalue: snapshot.data != null
                                  ? snapshot.data
                                  : RequestType.TIME,
                              onChanged: (data) {
                                AppConfig.helpIconContext =
                                    HelpIconContextClass.MONEY_OFFERS;
                                _bloc.onTypeChanged(data);
                                title_hint =
                                    S.of(context).cash_offer_title_hint;
                                description_hint =
                                    S.of(context).cash_offer_desc_hint;
                                setState(() {});
                              }),
                          _optionRadioButton(
                              title: S.of(context).request_type_goods,
                              value: RequestType.GOODS,
                              groupvalue: snapshot.data != null
                                  ? snapshot.data
                                  : RequestType.TIME,
                              onChanged: (data) {
                                AppConfig.helpIconContext =
                                    HelpIconContextClass.GOODS_OFFERS;
                                title_hint =
                                    S.of(context).goods_offer_title_hint;
                                description_hint =
                                    S.of(context).goods_offer_desc_hint;
                                _bloc.onTypeChanged(data);
                                setState(() {});
                              })
                        ],
                      ),
                    )
                  ],
                );
              })
        ]);
  }

  Widget TimeRequest() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<String>(
            stream: _bloc.availability,
            builder: (context, snapshot) {
              return CustomTextField(
                currentNode: _availability,
                value: snapshot.data,
                heading: S.of(context).availablity,
                onChanged: _bloc.onAvailabilityChanged,
                hint: S.of(context).availablity_description,
                maxLength: 100,
                error: getValidationError(context, snapshot.error),
              );
            },
          ),
        ]);
  }

  Widget CashRequest() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<CashModel>(
            stream: _bloc.cashModel,
            builder: (context, snapshot) {
              return TextFormField(
                focusNode: _availability,
                onChanged: (data) => {
                  snapshot.data.targetAmount = int.parse(data),
                  _bloc.onCashModelChanged(snapshot.data)
                },
                inputFormatters: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: S.of(context).add_amount_donate ?? '',
                  errorText: getValidationError(context, snapshot.error),
                ),
                keyboardType: TextInputType.number,
                initialValue: widget.offerModel != null
                    ? widget.offerModel.cashModel.targetAmount.toString()
                    : '',
                onFieldSubmitted: (v) {
                  _availability.unfocus();
                  snapshot.data.targetAmount = int.parse(v);
                  _bloc.onCashModelChanged(snapshot.data);
                },
              );
            },
          ),
        ]);
  }

  Widget RequestGoodsDescriptionData(GoodsDonationDetails requestGoodsData) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).request_goods_offer.replaceAll("  ", " "),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          GoodsDynamicSelection(
            goodsbefore: requestGoodsData.requiredGoods,
            onSelectedGoods: (goods) => {
              requestGoodsData.requiredGoods = goods,
              _bloc.onGoodsDetailsChanged(requestGoodsData)
            },
          )
        ]);
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  Widget GoodsRequest() {
    return StreamBuilder<GoodsDonationDetails>(
        stream: _bloc.goodsDonationDetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                RequestGoodsDescriptionData(snapshot.data),
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.offerModel != null
          ? AppBar(
              title: Text(
                S.of(context).edit,
                style: TextStyle(fontSize: 18),
              ),
              actions: [CommonHelpIconWidget()])
          : null,
      body: SafeArea(
        child: StreamBuilder<Status>(
          stream: _bloc.status,
          builder: (context, status) {
            if (status.data == Status.COMPLETE) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pop(context),
              );
            }

            if (status.data == Status.LOADING) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.offerModel == null
                            ? S.of(context).creating_offer
                            : S.of(context).updating_offer,
                      ),
                    ),
                  );
                },
              );
            }

            if (status.data == Status.ERROR) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.offerModel == null
                            ? S.of(context).offer_error_creating
                            : S.of(context).offer_error_updating,
                      ),
                    ),
                  );
                },
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        widget.offerModel == null
                            ? RequestTypeWidget()
                            : Container(),
                        StreamBuilder<String>(
                          stream: _bloc.title,
                          builder: (context, snapshot) {
                            return CustomTextField(
                              currentNode: _title,
                              nextNode: _description,
                              value: snapshot.data,
                              heading: "${S.of(context).title}*",
                              onChanged: (String value) {
                                _bloc.onTitleChanged(value);
                                title = value;
                              },
                              hint: title_hint != null
                                  ? title_hint
                                  : S.of(context).offer_title_hint,
                              maxLength: null,
                              error:
                                  getValidationError(context, snapshot.error),
                            );
                          },
                        ),
                        SizedBox(height: 30),
                        StreamBuilder<String>(
                          stream: _bloc.offerDescription,
                          builder: (context, snapshot) {
                            return CustomTextField(
                              currentNode: _description,
                              nextNode: _availability,
                              value: snapshot.data,
                              heading: "${S.of(context).offer_description}*",
                              onChanged: _bloc.onOfferDescriptionChanged,
                              hint: description_hint != null
                                  ? description_hint
                                  : S.of(context).offer_description_hint,
                              maxLength: 500,
                              error:
                                  getValidationError(context, snapshot.error),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        StreamBuilder<RequestType>(
                            stream: _bloc.type,
                            builder: (context, snapshot) {
                              var type = snapshot.data != null
                                  ? snapshot.data
                                  : RequestType.TIME;
                              return type == RequestType.TIME
                                  ? TimeRequest()
                                  : type == RequestType.CASH
                                      ? CashRequest()
                                      : GoodsRequest();
                            }),
                        SizedBox(height: 10),
                        StreamBuilder<CustomLocation>(
                            stream: _bloc.location,
                            builder: (context, snapshot) {
                              return LocationPickerWidget(
                                selectedAddress: snapshot.data?.address,
                                location: snapshot.data?.location,
                                color: snapshot.error == null
                                    ? Colors.green
                                    : Colors.red,
                                onChanged: (LocationDataModel dataModel) {
                                  _bloc.onLocatioChanged(
                                    CustomLocation(
                                      dataModel.geoPoint,
                                      dataModel.location,
                                    ),
                                  );
                                },
                              );
                            }),
                        SizedBox(height: 10),
                        RaisedButton(
                          onPressed: status.data == Status.LOADING
                              ? () {}
                              : () async {
                                  var connResult =
                                      await Connectivity().checkConnectivity();
                                  if (connResult == ConnectivityResult.none) {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(S.of(context).check_internet),
                                        action: SnackBarAction(
                                          label: S.of(context).dismiss,
                                          onPressed: () => _scaffoldKey
                                              .currentState
                                              .hideCurrentSnackBar(),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (widget.offerModel == null) {
                                    if (SevaCore.of(context)
                                            .loggedInUser
                                            .calendarId !=
                                        null) {
                                      _bloc.allowedCalenderEvent = true;
                                      await _bloc.createOrUpdateOffer(
                                        user: SevaCore.of(context).loggedInUser,
                                        timebankId: widget.timebankId,
                                      );
                                    } else {
                                      _bloc.allowedCalenderEvent = true;
                                      await _bloc.createOrUpdateOffer(
                                        user: SevaCore.of(context).loggedInUser,
                                        timebankId: widget.timebankId,
                                      );
                                      if (_bloc.offerCreatedBool) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return AddToCalendar(
                                                  isOfferRequest: false,
                                                  offer: _bloc.mainOfferModel,
                                                  requestModel: null,
                                                  userModel: null,
                                                  eventsIdsArr: _bloc.offerIds);
                                            },
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    _bloc.updateIndividualOffer(
                                      widget.offerModel,
                                    );
                                  }
                                },
                          child: status.data == Status.LOADING
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      widget.offerModel == null
                                          ? S.of(context).creating_offer
                                          : S.of(context).updating_offer,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  widget.offerModel == null
                                      ? S.of(context).create_offer
                                      : S.of(context).update_offer,
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
