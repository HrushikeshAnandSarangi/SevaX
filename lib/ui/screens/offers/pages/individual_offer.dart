import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_editRequest.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/help_context_enums.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/individual_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/add_update_lending_place.dart';
import 'package:sevaexchange/ui/screens/offers/pages/select_lending_place.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

import '../../../../labels.dart';
import 'lending_place_card_widget.dart';

class IndividualOffer extends StatefulWidget {
  final OfferModel offerModel;
  final String timebankId;
  final String loggedInMemberUserId;
  final TimebankModel timebankModel;

  const IndividualOffer(
      {Key key,
      this.offerModel,
      this.timebankId,
      this.loggedInMemberUserId,
      @required this.timebankModel})
      : super(key: key);

  @override
  _IndividualOfferState createState() => _IndividualOfferState();
}

class _IndividualOfferState extends State<IndividualOffer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final IndividualOfferBloc _bloc = IndividualOfferBloc();

  CommunityModel communityModel;
  String selectedAddress;
  CustomLocation customLocation;
  // String title = '';
  String title_hint;
  String description_hint;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _availabilityController = TextEditingController();
  TextEditingController _minimumCreditsController = TextEditingController();
  LendingPlaceModel lendingPlaceModel;
  FocusNode _title = FocusNode();
  FocusNode _description = FocusNode();
  FocusNode _availability = FocusNode();
  FocusNode _minimumCredits = FocusNode();
  var focusNodes = List.generate(8, (_) => FocusNode());
  @override
  void initState() {
    AppConfig.helpIconContextMember = HelpContextMemberType.time_offers;
    _bloc.onTypeChanged(RequestType.TIME);
    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel);
      _titleController.text = widget.offerModel.individualOfferDataModel.title;
      _descriptionController.text =
          widget.offerModel.individualOfferDataModel.description;
      _minimumCreditsController.text =
          widget.offerModel.individualOfferDataModel.minimumCredits.toString();
      _availabilityController.text =
          widget.offerModel.individualOfferDataModel.schedule;
      AppConfig.helpIconContextMember =
          widget.offerModel.type == RequestType.TIME
              ? HelpContextMemberType.time_offers
              : widget.offerModel.type == RequestType.CASH
                  ? HelpContextMemberType.money_offers
                  : HelpContextMemberType.goods_offers;
    }

    super.initState();
    getCommunity();
    _bloc.errorMessage.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        showScaffold(
            event == 'goods' ? S.of(context).select_goods_category : null);
      }
    });
  }

  Future<void> getCommunity() async {
    communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: widget.timebankModel.communityId);
    setState(() {});
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

  @override
  void dispose() {
    _bloc.dispose();
    _title.dispose();
    _description.dispose();
    _availability.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _availabilityController.dispose();
    _minimumCreditsController.dispose();

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
                          ConfigurationCheck(
                            actionType: 'create_time_offers',
                            role: memberType(widget.timebankModel,
                                SevaCore.of(context).loggedInUser.sevaUserID),
                            child: _optionRadioButton(
                              title: S.of(context).request_type_time,
                              value: RequestType.TIME,
                              groupvalue: snapshot.data != null
                                  ? snapshot.data
                                  : RequestType.TIME,
                              onChanged: (data) {
                                AppConfig.helpIconContextMember =
                                    HelpContextMemberType.time_offers;
                                _bloc.onTypeChanged(data);
                                title_hint = S.of(context).offer_title_hint;
                                description_hint =
                                    S.of(context).offer_description_hint;
                                setState(() {});
                              },
                            ),
                          ),
                          ConfigurationCheck(
                            actionType: 'create_money_offers',
                            role: memberType(widget.timebankModel,
                                SevaCore.of(context).loggedInUser.sevaUserID),
                            child: _optionRadioButton(
                                title: S.of(context).request_type_cash,
                                value: RequestType.CASH,
                                groupvalue: snapshot.data != null
                                    ? snapshot.data
                                    : RequestType.TIME,
                                onChanged: (data) {
                                  AppConfig.helpIconContextMember =
                                      HelpContextMemberType.money_offers;
                                  _bloc.onTypeChanged(data);
                                  title_hint =
                                      S.of(context).cash_offer_title_hint;
                                  description_hint =
                                      S.of(context).cash_offer_desc_hint;
                                  setState(() {});
                                }),
                          ),
                          ConfigurationCheck(
                            actionType: 'create_goods_offers',
                            role: memberType(widget.timebankModel,
                                SevaCore.of(context).loggedInUser.sevaUserID),
                            child: _optionRadioButton(
                                title: S.of(context).request_type_goods,
                                value: RequestType.GOODS,
                                groupvalue: snapshot.data != null
                                    ? snapshot.data
                                    : RequestType.TIME,
                                onChanged: (data) {
                                  AppConfig.helpIconContextMember =
                                      HelpContextMemberType.goods_offers;
                                  title_hint =
                                      S.of(context).goods_offer_title_hint;
                                  description_hint =
                                      S.of(context).goods_offer_desc_hint;
                                  _bloc.onTypeChanged(data);
                                  setState(() {});
                                }),
                          ),
                          _optionRadioButton(
                              title: L.of(context).lending_offer,
                              value: RequestType.LENDING_OFFER,
                              groupvalue: snapshot.data != null
                                  ? snapshot.data
                                  : RequestType.TIME,
                              onChanged: (data) {
                                AppConfig.helpIconContextMember =
                                    HelpContextMemberType.lending_offers;
                                title_hint =
                                    L.of(context).lending_offer_title_hint;
                                description_hint =
                                    L.of(context).lending_offer_desc_hint;
                                _bloc.onTypeChanged(data);
                                setState(() {});
                              }),
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
                controller: _availabilityController,
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
          StreamBuilder<String>(
            stream: _bloc.minimumCredits,
            builder: (context, snapshot) {
              return CustomTextField(
                controller: _minimumCreditsController,
                currentNode: _minimumCredits,
                value: snapshot.data,
                heading: S.of(context).minimum_credit_title,
                onChanged: _bloc.onMinimumCreditsChanged,
                hint: S.of(context).minimum_credit_hint,
                maxLength: 100,
                error: getValidationError(context, snapshot.error),
                formatters: [
                  FilteringTextInputFormatter.allow(Regex.numericRegex)
                ],
              );
            },
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: CupertinoSegmentedControl<int>(
              unselectedColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor,
              children: {
                0: Padding(
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    S.of(context).option_one, //Label to be created
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    S.of(context).option_two, //Label to be created
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              },

              borderColor: Colors.grey,
              padding: EdgeInsets.only(left: 0.0, right: 0.0),
              groupValue: _bloc.timeOfferType,
              onValueChanged: (int val) {
                if (val != _bloc.timeOfferType) {
                  setState(() {
                    if (val == 0) {
                      _bloc.timeOfferType = 0;
                    } else {
                      _bloc.timeOfferType = 1;
                    }
                    _bloc.timeOfferType = val;
                  });
                }
              },
              //groupValue: sharedValue,
            ),
          ),
        ]);
  }

  Widget CashRequest() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<int>(
            stream: _bloc.donationAmount,
            builder: (context, snapshot) {
              return TextFormField(
                focusNode: _availability,
                onChanged: (String data) =>
                    _bloc.onDonationAmountChanged(int.tryParse(data)),
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
                  _bloc.onDonationAmountChanged(int.tryParse(v));
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

  int timeTypeSelection = 0;

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
                  ScaffoldMessenger.of(context).showSnackBar(
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
                  ScaffoldMessenger.of(context).showSnackBar(
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
                            // ? Container()
                            : Container(),
                        StreamBuilder<String>(
                          stream: _bloc.title,
                          builder: (context, snapshot) {
                            return CustomTextField(
                              controller: _titleController,
                              currentNode: _title,
                              nextNode: _description,
                              value: snapshot.data,
                              heading: "${S.of(context).title}*",
                              onChanged: (String value) {
                                _bloc.onTitleChanged(value);
                                // title = value;
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
                              controller: _descriptionController,
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
                                      : type == RequestType.LENDING_OFFER
                                          ? LendingOffer()
                                          : GoodsRequest();
                            }),
                        // SizedBox(height: 10),
                        // Container(
                        //   alignment: Alignment.bottomLeft,
                        //   child: CupertinoSegmentedControl<int>(
                        //     unselectedColor: Colors.grey[200],
                        //     selectedColor: Theme.of(context).primaryColor,
                        //     children: {
                        //       0: Padding(
                        //         padding: EdgeInsets.only(left: 14, right: 14),
                        //         child: Text(
                        //           L
                        //               .of(context)
                        //               .option_one,
                        //           style: TextStyle(fontSize: 12.0),
                        //         ),
                        //       ),
                        //       1: Padding(
                        //         padding: EdgeInsets.only(left: 14, right: 14),
                        //         child: Text(
                        //           L
                        //               .of(context)
                        //               .option_two,
                        //           style: TextStyle(fontSize: 12.0),
                        //         ),
                        //       ),
                        //     },
                        //     borderColor: Colors.grey,
                        //     padding: EdgeInsets.only(left: 0.0, right: 0.0),
                        //     groupValue: _bloc.timeOfferType,
                        //     onValueChanged: (int val) {
                        //       if (val != _bloc.timeOfferType) {
                        //         setState(() {
                        //           if (val == 0) {
                        //             _bloc.timeOfferType = 0;
                        //           } else {
                        //             _bloc.timeOfferType = 1;
                        //           }
                        //           _bloc.timeOfferType = val;
                        //         });
                        //       }
                        //     },
                        //     //groupValue: sharedValue,
                        //   ),
                        // ),
                        SizedBox(height: 25),
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
                        SizedBox(height: 20),
                        Offstage(
                          offstage: AppConfig.isTestCommunity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: StreamBuilder<bool>(
                                initialData: false,
                                stream: _bloc.makeVirtual,
                                builder: (context, snapshot) {
                                  return ConfigurationCheck(
                                    actionType: 'create_virtual_offer',
                                    role: memberType(
                                        widget.timebankModel,
                                        SevaCore.of(context)
                                            .loggedInUser
                                            .sevaUserID),
                                    child: OpenScopeCheckBox(
                                        infoType: InfoType.VirtualOffers,
                                        isChecked: snapshot.data,
                                        checkBoxTypeLabel:
                                            CheckBoxType.type_VirtualOffers,
                                        onChangedCB: (bool val) {
                                          if (snapshot.data != val) {
                                            _bloc.onOfferMadeVirtual(val);
                                            setState(() {});
                                          }
                                        }),
                                  );
                                }),
                          ),
                        ),
                        StreamBuilder<bool>(
                          initialData: false,
                          stream: _bloc.isPublicVisible,
                          builder: (context, snapshot) {
                            return snapshot.data
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: StreamBuilder<bool>(
                                        initialData: false,
                                        stream: _bloc.makePublicValue,
                                        builder: (context, snapshot) {
                                          return ConfigurationCheck(
                                            actionType: 'create_public_offer',
                                            role: memberType(
                                                widget.timebankModel,
                                                SevaCore.of(context)
                                                    .loggedInUser
                                                    .sevaUserID),
                                            child: OpenScopeCheckBox(
                                                infoType:
                                                    InfoType.OpenScopeOffer,
                                                isChecked: snapshot.data,
                                                checkBoxTypeLabel:
                                                    CheckBoxType.type_Offers,
                                                onChangedCB: (bool val) {
                                                  if (snapshot.data != val) {
                                                    _bloc
                                                        .onOfferMadePublic(val);
                                                    setState(() {});
                                                  }
                                                }),
                                          );
                                        }),
                                  )
                                : Container();
                          },
                        ),
                        SizedBox(height: 20),
                        CustomElevatedButton(
                          onPressed: status.data == Status.LOADING
                              ? () {}
                              : () async {
                                  var connResult =
                                      await Connectivity().checkConnectivity();
                                  if (connResult == ConnectivityResult.none) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(S.of(context).check_internet),
                                        action: SnackBarAction(
                                          label: S.of(context).dismiss,
                                          onPressed: () =>
                                              ScaffoldMessenger.of(context)
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
                                          user:
                                              SevaCore.of(context).loggedInUser,
                                          timebankId: widget.timebankId,
                                          communityName:
                                              communityModel.name ?? '');
                                    } else {
                                      _bloc.allowedCalenderEvent = true;
                                      await _bloc.createOrUpdateOffer(
                                          user:
                                              SevaCore.of(context).loggedInUser,
                                          timebankId: widget.timebankId,
                                          communityName:
                                              communityModel.name ?? '');
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

  Widget LendingOffer() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Container(
            alignment: Alignment.bottomLeft,
            child: CupertinoSegmentedControl<int>(
              unselectedColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor,
              children: {
                0: Padding(
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    L.of(context).place, //Label to be created
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.only(left: 14, right: 14),
                  child: Text(
                    L.of(context).items, //Label to be created
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              },

              borderColor: Colors.grey,
              padding: EdgeInsets.only(left: 0.0, right: 0.0),
              groupValue: _bloc.lendingOfferType,
              onValueChanged: (int val) {
                if (val != _bloc.lendingOfferType) {
                  setState(() {
                    if (val == 0) {
                      _bloc.lendingOfferType = 0;
                    } else {
                      _bloc.lendingOfferType = 1;
                    }
                    _bloc.lendingOfferType = val;
                  });
                }
              },
              //groupValue: sharedValue,
            ),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddUpdateLendingPlace(
                      lendingPlaceModel: null,
                      onPlaceCreateUpdate: (LendingPlaceModel model) {
                        lendingPlaceModel = model;
                        setState(() {});
                      },
                    );
                  },
                ),
              );
            },
            child: Text(
              'Select a place for lending*',
              style: TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SelectLendingPlace(onSelected: (LendingPlaceModel model) {
            _bloc.onLendingModelAdded(model);
          }),
          SizedBox(
            height: 10,
          ),
          StreamBuilder<LendingPlaceModel>(
              stream: _bloc.lendingPlaceModelStream,
              builder: (context, snapshot) {
                if (snapshot.data == null || snapshot.hasError) {
                  return Container();
                }
                return LendingPlaceCardWidget(
                  lendingPlaceModel: snapshot.data,
                  onDelete: () {
                    _bloc.onLendingModelAdded(null);
                  },
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return AddUpdateLendingPlace(
                            lendingPlaceModel: snapshot.data,
                            onPlaceCreateUpdate: (LendingPlaceModel model) {
                              _bloc.onLendingModelAdded(model);
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              })
        ]);
  }
}
