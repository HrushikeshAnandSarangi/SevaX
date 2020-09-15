import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:usage/uuid/uuid.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  String projectId;

  CreateRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.projectId,
      this.projectModel})
      : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _title,
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: StreamBuilder<UserModelController>(
            stream: userBloc.getLoggedInUser,
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Text(
                  S.of(context).general_stream_error,
                );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingIndicator();
              }
              if (snapshot.data != null) {
                return RequestCreateForm(
                  isOfferRequest: widget.isOfferRequest,
                  offer: widget.offer,
                  timebankId: widget.timebankId,
                  userModel: widget.userModel,
                  loggedInUser: snapshot.data.loggedinuser,
                  projectId: widget.projectId,
                  projectModel: widget.projectModel,
                );
              }
              return Text('');
            }));
  }

  String get _title {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
      return S.of(context).create_request;
    }
    return S.of(context).create_project_request;
  }
}

class RequestCreateForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  final ProjectModel projectModel;
  String projectId;
  RequestCreateForm(
      {this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.loggedInUser,
      this.projectId,
      this.projectModel});

  @override
  RequestCreateFormState createState() {
    return RequestCreateFormState();
  }
}

class RequestCreateFormState extends State<RequestCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();

  RequestModel requestModel = RequestModel(
    requestType: RequestType.TIME,
    cashModel: CashModel(
        paymentType: RequestPaymentType.ZELLEPAY, achdetails: new ACHModel()),
    goodsDonationDetails: GoodsDonationDetails(),
  );
  End end = End();
  var focusNodes = List.generate(16, (_) => FocusNode());

  GeoFirePoint location;

  double sevaCoinsValue = 0;
  String hoursMessage;
  String selectedAddress;
  int sharedValue = 0;

  String _selectedTimebankId;

  Future<TimebankModel> getTimebankAdminStatus;
  Future getProjectsByFuture;
  TimebankModel timebankModel;
  final profanityDetector = ProfanityDetector();
  bool autoValidateText = false;
  bool autoValidateCashText = false;
  RegExp regExp = RegExp(
    r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
    caseSensitive: false,
    multiLine: false,
  );
  @override
  void initState() {
    super.initState();
    print(requestModel);
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = widget.projectId;

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );
    getProjectsByFuture =
        FirestoreManager.getAllProjectListFuture(timebankid: widget.timebankId);

    fetchRemoteConfig();

    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      // _fetchCurrentlocation;
    }
  }

  void get _fetchCurrentlocation async {
    try {
      Location templocation = Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;

      _serviceEnabled = await templocation.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await templocation.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await templocation.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await templocation.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      Location().getLocation().then((onValue) {
        location = GeoFirePoint(onValue.latitude, onValue.longitude);
        LocationUtility()
            .getFormattedAddress(
          location.latitude,
          location.longitude,
        )
            .then((address) {
          setState(() {
            this.selectedAddress = address;
          });
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
    }
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.instance;
    AppConfig.remoteConfig.fetch(expiration: const Duration(hours: 0));
    AppConfig.remoteConfig.activateFetched();
  }

  @override
  void didChangeDependencies() {
    if (widget.loggedInUser?.sevaUserID != null)
      FirestoreManager.getUserForIdStream(
              sevaUserId: widget.loggedInUser.sevaUserID)
          .listen((userModel) {});
    super.didChangeDependencies();
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );
  Widget addToProjectContainer(snapshot, projectModelList, requestModel) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    timebankModel = snapshot.data;
    if (snapshot.data.admins
        .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
      return ProjectSelection(
          requestModel: requestModel,
          projectModelList: projectModelList,
          selectedProject: null,
          admin: snapshot.data.admins
              .contains(SevaCore.of(context).loggedInUser.sevaUserID));
    } else {
      this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      this.requestModel.requestType = RequestType.TIME;
      return ProjectSelection(
        requestModel: requestModel,
        projectModelList: projectModelList,
        selectedProject: null,
        admin: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    hoursMessage = S.of(context).set_duration;
    UserModel loggedInUser = SevaCore.of(context).loggedInUser;
    this.requestModel.email = loggedInUser.email;
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;

    Widget headerContainer(snapshot) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (snapshot.data.admins
          .contains(SevaCore.of(context).loggedInUser.sevaUserID)) {
        return requestSwitch();
      } else {
        this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
        this.requestModel.requestType = RequestType.TIME;
        return Container();
      }
    }

    return FutureBuilder<TimebankModel>(
        future: getTimebankAdminStatus,
        builder: (context, snapshot) {
          return FutureBuilder<List<ProjectModel>>(
              future: getProjectsByFuture,
              builder: (projectscontext, projectListSnapshot) {
                List<ProjectModel> projectModelList = projectListSnapshot.data;
                return Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            headerContainer(snapshot),
                            RequestTypeWidget(),
                            Text(
                              S.of(context).request_title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Europa',
                                color: Colors.black,
                              ),
                            ),
                            TextFormField(
                              autovalidate: autoValidateText,
                              onChanged: (value) {
                                if (value.length > 1 && !autoValidateText) {
                                  setState(() {
                                    autoValidateText = true;
                                  });
                                }
                                if (value.length <= 1 && autoValidateText) {
                                  setState(() {
                                    autoValidateText = false;
                                  });
                                }
                              },
                              onFieldSubmitted: (v) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[0]);
                              },
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter(
                                    RegExp("[a-zA-Z0-9_ ]*"))
                              ],
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                hintText: S.of(context).request_title_hint,
                                hintStyle: hintTextStyle,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              initialValue:
                                  widget.offer != null && widget.isOfferRequest
                                      ? getOfferTitle(
                                          offerDataModel: widget.offer,
                                        )
                                      : "",
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).request_subject;
                                }
                                if (profanityDetector.isProfaneString(value)) {
                                  return S.of(context).profanity_text_alert;
                                }
                                requestModel.title = value;
                              },
                            ),
                            SizedBox(height: 30),
                            OfferDurationWidget(
                              title: S.of(context).request_duration,
                            ),
                            requestModel.requestType == RequestType.TIME
                                ? TimeRequest(snapshot, projectModelList)
                                : requestModel.requestType == RequestType.CASH
                                    ? CashRequest(snapshot, projectModelList)
                                    : GoodsRequest(snapshot, projectModelList),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30.0),
                              child: Center(
                                child: Container(
                                  // width: 150,
                                  child: RaisedButton(
                                    onPressed: createRequest,
                                    child: Text(
                                      S
                                          .of(context)
                                          .create_request
                                          .padLeft(10)
                                          .padRight(10),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .button,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  Widget RequestGoodsDescriptionData() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).request_goods_description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          GoodsDynamicSelection(
            onSelectedGoods: (goods) => {
              print(goods),
              requestModel.goodsDonationDetails.requiredGoods = goods
            },
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
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[8],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[8]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).request_goods_address_inputhint,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                print(requestModel);
                requestModel.goodsDonationDetails.address = value;
//                setState(() {});
              }
              return null;
            },
          ),
        ]);
  }

  Widget RequestPaymentACH(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[13]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.bank_name = value;
                print(true);
              } else {
                print('not url');
                return S.of(context).enter_valid_bank_name;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_bank_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[13],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[14]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.bank_address = value;
                print(true);
              } else {
                print('not url');

                return S.of(context).enter_valid_bank_address;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_routing_number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[14],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.routing_number = value;
                print(true);
              } else {
                print('not url');

                return S.of(context).enter_valid_routing_number;
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_payment_ach_account_no,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[15],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                requestModel.cashModel.achdetails.account_number = value;
              } else {
                return S.of(context).enter_valid_account_number;
              }
              return null;
            },
          )
        ]);
  }

  Widget RequestPaymentZellePay(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText:
                  S.of(context).request_payment_descriptionZelle_inputhint,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              requestModel.cashModel.zelleId = value;
            },
            validator: (value) {
              requestModel.cashModel.zelleId = value;
              return _validateEmailAndPhone(value);
            },
          )
        ]);
  }

  String _validateEmailAndPhone(String value) {
    String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value)) {
      return null;
    } else if (regExp.hasMatch(value)) {
      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
    return null;
  }

  String _validateEmailId(String value) {
    RegExp emailPattern = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value.isEmpty) return S.of(context).validation_error_general_text;
    if (!emailPattern.hasMatch(value))
      return S.of(context).validation_error_invalid_email;
    return null;
  }

  Widget RequestPaymentPaypal(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidate: autoValidateCashText,
            onChanged: (value) {
              if (value.length > 1) {
                setState(() {
                  autoValidateCashText = true;
                });
              } else {
                setState(() {
                  autoValidateCashText = false;
                });
              }
            },
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).email_hint,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.emailAddress,
            maxLines: 1,
            onSaved: (value) {
              requestModel.cashModel.paypalId = value;
            },
            validator: (value) {
              requestModel.cashModel.paypalId = value;
              return _validateEmailId(value);
            },
          )
        ]);
  }

  Widget RequestPaymentDescriptionData(RequestModel requestModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          S.of(context).request_payment_description,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Europa',
            color: Colors.black,
          ),
        ),
        Text(
          S.of(context).request_payment_description_hint,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        _optionRadioButton(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_paypal,
            value: RequestPaymentType.PAYPAL,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_zellepay,
            value: RequestPaymentType.ZELLEPAY,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        requestModel.cashModel.paymentType == RequestPaymentType.ACH
            ? RequestPaymentACH(requestModel)
            : requestModel.cashModel.paymentType == RequestPaymentType.PAYPAL
                ? RequestPaymentPaypal(requestModel)
                : RequestPaymentZellePay(requestModel),
      ],
    );
  }

  Widget RequestDescriptionData(hintTextDesc) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).request_description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            autovalidate: autoValidateText,
            onChanged: (value) {
              if (value.length > 1 && !autoValidateText) {
                setState(() {
                  autoValidateText = true;
                });
              }
              if (value.length <= 1 && autoValidateText) {
                setState(() {
                  autoValidateText = false;
                });
              }
            },
            focusNode: focusNodes[0],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[1]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: hintTextDesc,
              hintStyle: hintTextStyle,
            ),
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getOfferDescription(
                    offerDataModel: widget.offer,
                  )
                : "",
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              }
              if (profanityDetector.isProfaneString(value)) {
                return S.of(context).profanity_text_alert;
              }
              requestModel.description = value;
            },
          ),
        ]);
  }

  Widget RequestTypeWidget() {
    return requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).request_type,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Europa',
                  color: Colors.black,
                ),
              ),
              Column(
                children: <Widget>[
                  _optionRadioButton(
                    title: S.of(context).request_type_time,
                    value: RequestType.TIME,
                    groupvalue: requestModel.requestType,
                    onChanged: (value) {
                      requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  _optionRadioButton(
                      title: S.of(context).request_type_cash,
                      value: RequestType.CASH,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.requestType = value;
                        setState(() => {});
                      }),
                  _optionRadioButton(
                      title: S.of(context).request_type_goods,
                      value: RequestType.GOODS,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.requestType = value;
                        setState(() => {});
                      }),
                ],
              )
            ],
          )
        : Container();
  }

  Widget TimeRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RepeatWidget(),
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          Text(
            S.of(context).max_credits,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  focusNode: focusNodes[1],
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[2]);
                  },
                  onChanged: (v) {
                    if (v.isNotEmpty && int.parse(v) >= 0) {
                      requestModel.maxCredits = int.parse(v);
                      setState(() {});
                    }
                  },
                  decoration: InputDecoration(
                    hintText: S.of(context).max_credit_hint,
                    hintStyle: hintTextStyle,
                    // labelText: 'No. of volunteers',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please enter maximum credits";
                    } else if (int.parse(value) < 0) {
                      return "Please enter maximum credits";
                    } else if (int.parse(value) == 0) {
                      return "Please enter maximum credits";
                    } else {
                      requestModel.maxCredits = int.parse(value);
                      setState(() {});
                      return null;
                    }
                  },
                ),
              ),
              infoButton(
                context: context,
                key: GlobalKey(),
                type: InfoType.MAX_CREDITS,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).number_of_volunteers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            focusNode: focusNodes[2],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.numberOfApprovals = int.parse(v);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).number_of_volunteers,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_volunteer_count;
              } else if (int.parse(value) < 0) {
                return S.of(context).validation_error_volunteer_count_negative;
              } else if (int.parse(value) == 0) {
                return S.of(context).validation_error_volunteer_count_zero;
              } else {
                requestModel.numberOfApprovals = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          TotalCredits(
            context: context,
            requestModel: requestModel,
            requestCreditsMode: TotalCreditseMode.CREATE_MODE,
          ),
          SizedBox(height: 40),
          Center(
            child: LocationPickerWidget(
              selectedAddress: selectedAddress,
              location: location,
              onChanged: (LocationDataModel dataModel) {
                log("received data model");
                setState(() {
                  location = dataModel.geoPoint;
                  this.selectedAddress = dataModel.location;
                });
              },
            ),
          )
        ]);
  }

  Widget CashRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_cash),
          SizedBox(height: 20),
          Text(
            S.of(context).request_target_donation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            focusNode: focusNodes[5],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              print(v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                print('hey');
                print(requestModel.cashModel);
                requestModel.cashModel.targetAmount = int.parse(v);
                print(requestModel.cashModel);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).request_target_donation_hint,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_target_donation_count;
              } else if (int.parse(value) < 0) {
                return S
                    .of(context)
                    .validation_error_target_donation_count_negative;
              } else if (int.parse(value) == 0) {
                return S
                    .of(context)
                    .validation_error_target_donation_count_zero;
              } else {
                requestModel.cashModel.targetAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            S.of(context).request_min_donation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Europa',
              color: Colors.black,
            ),
          ),
          TextFormField(
            focusNode: focusNodes[6],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.cashModel.minAmount = int.parse(v);
                print(requestModel.cashModel);
                setState(() {});
              }
            },
            decoration: InputDecoration(
              hintText: S.of(context).request_min_donation_hint,
              hintStyle: hintTextStyle,
              // labelText: 'No. of volunteers',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_min_donation_count;
              } else if (int.parse(value) < 0) {
                return S
                    .of(context)
                    .validation_error_min_donation_count_negative;
              } else if (int.parse(value) == 0) {
                return S.of(context).validation_error_min_donation_count_zero;
              } else if (requestModel.cashModel.targetAmount != null &&
                  requestModel.cashModel.targetAmount < int.parse(value)) {
                return S.of(context).target_amount_less_than_min_amount;
              } else {
                requestModel.cashModel.minAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestPaymentDescriptionData(requestModel),
        ]);
  }

  Widget GoodsRequest(snapshot, projectModelList) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_goods),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  projectModelList,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestGoodsDescriptionData(),
        ]);
  }

  bool isFromRequest({String projectId}) {
    return projectId == null || projectId.isEmpty || projectId == "";
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

  Widget requestSwitch() {
    if (widget.projectId == null ||
        widget.projectId.isEmpty ||
        widget.projectId == "") {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        width: double.infinity,
        child: CupertinoSegmentedControl<int>(
          selectedColor: Theme.of(context).primaryColor,
          children: {
            0: Text(
              S.of(context).timebank_request(1),
              style: TextStyle(fontSize: 12.0),
            ),
            1: Text(
              S.of(context).personal_request(1),
              style: TextStyle(fontSize: 12.0),
            ),
          },
          borderColor: Colors.grey,
          padding: EdgeInsets.only(left: 5.0, right: 5.0),
          groupValue: sharedValue,

          onValueChanged: (int val) {
            if (val != sharedValue) {
              setState(() {
                if (val == 0) {
                  requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
                } else {
                  requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
                  requestModel.requestType = RequestType.TIME;
                }
                sharedValue = val;
              });
            }
          },
          //groupValue: sharedValue,
        ),
      );
    } else {
      if (widget.projectModel != null) {
        if (widget.projectModel.mode == 'Timebank') {
          requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
          requestModel.requestType = RequestType.TIME;
        }
      }
      return Container();
    }
  }

  BuildContext dialogContext;

  void createRequest() async {
    print('clicked here');
    // verify f the start and end date time is not same
    var connResult = await Connectivity().checkConnectivity();
    if (connResult == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).check_internet),
          action: SnackBarAction(
            label: S.of(context).dismiss,
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
      return;
    }

    requestModel.requestStart = OfferDurationWidgetState.starttimestamp;
    requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
    requestModel.autoGenerated = false;
    requestModel.isRecurring = RepeatWidgetState.isRecurring;

    if (requestModel.isRecurring) {
      requestModel.recurringDays = RepeatWidgetState.getRecurringdays();
      requestModel.occurenceCount = 1;
      end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
      end.on = end.endType == "on"
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after =
          (end.endType == "after" ? int.parse(RepeatWidgetState.after) : null);
      print("end model is = ${end.toMap()} ${end.endType}");
      requestModel.end = end;
      print("request model is = ${requestModel.toMap()}");
    }

    if (_formKey.currentState.validate()) {
      // validate request start and end date

      if (requestModel.requestStart == 0 || requestModel.requestEnd == 0) {
        showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
        return;
      }

      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }
      if (requestModel.requestType == RequestType.GOODS &&
          requestModel.goodsDonationDetails.requiredGoods == null) {
        showDialogForTitle(dialogTitle: S.of(context).goods_validation);
        return;
      }

      if (widget.isOfferRequest == true && widget.userModel != null) {
        if (requestModel.approvedUsers == null) requestModel.approvedUsers = [];

        List<String> approvedUsers = [];
        approvedUsers.add(widget.userModel.email);
        requestModel.approvedUsers = approvedUsers;
      }
      requestModel.softDelete = false;

      if (requestModel.isRecurring) {
        if (requestModel.recurringDays.length == 0) {
          showDialogForTitle(
              dialogTitle: S.of(context).validation_error_empty_recurring_days);
          return;
        }
      }

      //Form and date is valid
      switch (requestModel.requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          var myDetails = SevaCore.of(context).loggedInUser;
          this.requestModel.fullName = myDetails.fullname;
          this.requestModel.photoUrl = myDetails.photoURL;
          var onBalanceCheckResult = await hasSufficientCredits(
            credits: requestModel.numberOfHours.toDouble(),
            userId: myDetails.sevaUserID,
          );

          if (!onBalanceCheckResult) {
            showInsufficientBalance();
            return;
          }
          break;

        case RequestMode.TIMEBANK_REQUEST:
          requestModel.fullName = timebankModel.name;
          requestModel.photoUrl = timebankModel.photoUrl;
          break;
      }

      linearProgressForCreatingRequest();
      int resVar = await _writeToDB();
      await _updateProjectModel();
      Navigator.pop(dialogContext);

      if (widget.isOfferRequest == true && widget.userModel != null) {
        Navigator.pop(context, {'response': 'ACCEPTED'});
      } else {
        if (resVar == 0) {
          showInsufficientBalance();
        }
        Navigator.pop(context);
      }
    }
  }

  bool hasRegisteredLocation() {
    return location != null;
  }

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).creating_request),
            content: LinearProgressIndicator(),
          );
        });
  }

  void showInsufficientBalance() {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(S.of(context).insufficient_credits_for_request),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  void showDialogForTitle({String dialogTitle}) async {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  Map<String, UserModel> selectedUsers;
  Map onActivityResult;

  String memberAssignment;

  Widget addVolunteersForAdmin() {
    if (selectedUsers == null) {
      selectedUsers = HashMap();
    }

    if (widget.userModel != null) {
      Map<String, UserModel> map = HashMap();
      map[widget.userModel.email] = widget.userModel;
      selectedUsers.addAll(map);
    }
    memberAssignment = S.of(context).assign_to_volunteers;
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: RaisedButton(
        child: Text(selectedUsers != null && selectedUsers.length > 0
            ? "${selectedUsers.length} ${S.of(context).members_selected(selectedUsers.length)}"
            : memberAssignment),
        onPressed: () async {
          onActivityResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SelectMembersInGroup(
                timebankId: widget.loggedInUser.currentTimebank,
                userEmail: widget.loggedInUser.email,
                userSelected: selectedUsers,
                listOfalreadyExistingMembers: [],
              ),
            ),
          );

          if (onActivityResult != null &&
              onActivityResult.containsKey("membersSelected")) {
            selectedUsers = onActivityResult['membersSelected'];
            setState(() {
              if (selectedUsers != null && selectedUsers.length == 0)
                memberAssignment = S.of(context).assign_to_volunteers;
              else
                memberAssignment =
                    "${selectedUsers.length ?? ''} ${S.of(context).volunteers_selected(selectedUsers.length)}";
            });
          } else {
            //no users where selected
          }
          // SelectMembersInGroup
        },
      ),
    );
  }

  String getTimeInFormat(int timeStamp) {
    return DateFormat('EEEEEEE, MMMM dd yyyy',
            Locale(AppConfig.prefs.getString('language_code')).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
    );
  }

  bool hasSufficientBalance() {
    var requestCoins = requestModel.numberOfHours;
    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
    return requestCoins <= finalbalance;
  }

  Future<int> _writeToDB() async {
    print(requestModel.cashModel);
    print(requestModel.cashModel.achdetails);
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String timestampString = timestamp.toString();
    requestModel.id = '${requestModel.email}*$timestampString';
    if (requestModel.isRecurring) {
      requestModel.parent_request_id = requestModel.id;
    } else {
      requestModel.parent_request_id = null;
    }
    requestModel.postTimestamp = timestamp;
    requestModel.accepted = false;
    requestModel.acceptors = [];
    requestModel.invitedUsers = [];
    requestModel.address = selectedAddress;
    requestModel.location = location;
    requestModel.root_timebank_id = FlavorConfig.values.timebankId;
    requestModel.softDelete = false;
    if (requestModel.id == null) return 0;
    // credit the timebank the required credits before the request creation
    await TransactionBloc().createNewTransaction(
        requestModel.timebankId,
        requestModel.timebankId,
        DateTime.now().millisecondsSinceEpoch,
        requestModel.numberOfHours,
        true,
        "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
        requestModel.id,
        requestModel.timebankId);
    if (!requestModel.isRecurring) {
      await FirestoreManager.createRequest(requestModel: requestModel);
    }
    int resultVar = 1;
    if (requestModel.isRecurring) {
      resultVar = await FirestoreManager.createRecurringEvents(
          requestModel: requestModel);
      return resultVar;
    }
    return resultVar;
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty && !requestModel.isRecurring) {
      ProjectModel projectModel = widget.projectModel;
//      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
//      if (!projectModel.members.contains(userSevaUserId)) {
//        projectModel.members.add(userSevaUserId);
//      }
      projectModel.pendingRequests.add(requestModel.id);
      await FirestoreManager.updateProject(projectModel: projectModel);
    }
  }

  Future<Map> showTimebankAdvisory() {
    return showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(
              "Select Project",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            content: Form(
              child: Container(
                height: 300,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    "Projects here",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop({'PROCEED': false});
                },
              ),
              FlatButton(
                child: Text(
                  S.of(context).proceed,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
//                  return Navigator.of(viewContext).pop({'PROCEED': true});
                },
              ),
            ],
          );
        });
  }
}

Widget TotalCredits({
  BuildContext context,
  RequestModel requestModel,
  TotalCreditseMode requestCreditsMode,
}) {
  var label;
  var totalCredits =
      requestModel.numberOfApprovals * (requestModel.maxCredits ?? 1);
  requestModel.numberOfHours = totalCredits;

  if ((requestModel.maxCredits ?? 0) > 0 && totalCredits > 0) {
    if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
      label = totalCredits.toString() +
          ' ' +
          S.of(context).timebank_max_seva_credit_message1 +
          requestModel.maxCredits.toString() +
          ' ' +
          S.of(context).timebank_max_seva_credit_message2;
    } else {
      label = totalCredits.toString() +
          ' ' +
          S.of(context).personal_max_seva_credit_message1 +
          totalCredits.toString() +
          ' ' +
          S.of(context).personal_max_seva_credit_message2;
    }
  } else {
    label = "";
  }

  return Container(
    margin: EdgeInsets.only(top: 10),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'Europa',
        color: Colors.black54,
      ),
    ),
  );
}

// Widget TotalCredits(
//   context,
//   requestModel,
//   int starttimestamp,
//   int endtimestamp,
// ) {
//   var label;
//   var totalhours = DateTime.fromMillisecondsSinceEpoch(endtimestamp)
//       .difference(DateTime.fromMillisecondsSinceEpoch(starttimestamp))
//       .inHours;
//   var totalminutes = DateTime.fromMillisecondsSinceEpoch(endtimestamp)
//       .difference(DateTime.fromMillisecondsSinceEpoch(starttimestamp))
//       .inMinutes;
//   var totalallowedhours;
//   if (totalhours == 0) {
//     totalallowedhours = (totalhours + ((totalminutes / 60) / 100).ceil());
//   } else {
//     totalallowedhours = (totalhours + ((totalminutes / 60) / 100).round());
//   }

//   var totalCredits = requestModel.numberOfApprovals * totalallowedhours;
//   requestModel.numberOfHours = totalCredits;
//   if (totalallowedhours > 0 && totalCredits > 0) {
//     if (requestModel.requestMode == RequestMode.TIMEBANK_REQUEST) {
//       label = totalCredits.toString() +
//           ' ' +
//           S.of(context).timebank_max_seva_credit_message1 +
//           totalallowedhours.toString() +
//           ' ' +
//           S.of(context).timebank_max_seva_credit_message2;
//     } else {
//       label = totalCredits.toString() +
//           ' ' +
//           S.of(context).personal_max_seva_credit_message1 +
//           totalallowedhours.toString() +
//           ' ' +
//           S.of(context).personal_max_seva_credit_message2;
//     }
//   } else {
//     label = "";
//   }

//   return Text(
//     label,
//     style: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.normal,
//       fontFamily: 'Europa',
//       color: Colors.black54,
//     ),
//   );
// }

class ProjectSelection extends StatefulWidget {
  ProjectSelection(
      {Key key,
      this.requestModel,
      this.admin,
      this.projectModelList,
      this.selectedProject})
      : super(key: key);
  final admin;
  final List<ProjectModel> projectModelList;
  final ProjectModel selectedProject;
  RequestModel requestModel;

  @override
  ProjectSelectionState createState() => ProjectSelectionState();
}

class ProjectSelectionState extends State<ProjectSelection> {
  @override
  Widget build(BuildContext context) {
    if (widget.projectModelList == null) {
      return Container();
    }
    List<dynamic> list = [
      {"name": S.of(context).unassigned, "code": "None"}
    ];
    for (var i = 0; i < widget.projectModelList.length; i++) {
      list.add({
        "name": widget.projectModelList[i].name,
        "code": widget.projectModelList[i].id,
        "timebankproject": widget.projectModelList[i].mode == 'Timebank'
      });
    }
    return MultiSelect(
      autovalidate: true,
      initialValue: ['None'],
      titleText: S.of(context).assign_to_project,
      maxLength: 1, // optional
      hintText: S.of(context).tap_to_select,
      validator: (dynamic value) {
        if (value == null) {
          return S.of(context).assign_to_one_project;
        }
        return null;
      },
      errorText: S.of(context).assign_to_one_project,
      dataSource: list,
      admin: widget.admin,
      textField: 'name',
      valueField: 'code',
      filterable: true,
      required: true,
      titleTextColor: Colors.black,
      change: (value) {
        if (value != null && value[0] != 'None') {
          widget.requestModel.projectId = value[0];
        }
      },
      selectIcon: Icons.arrow_drop_down_circle,
      saveButtonColor: Theme.of(context).primaryColor,
      checkBoxColor: Theme.of(context).primaryColorDark,
      cancelButtonColor: Theme.of(context).primaryColorLight,
    );
  }

//  void _onFormSaved() {
//    final FormState form = _formKey.currentState;
//    form.save();
//  }
}

typedef StringMapCallback = void Function(Map<String, dynamic> goods);

class GoodsDynamicSelection extends StatefulWidget {
  final bool automaticallyImplyLeading;
  final StringMapCallback onSelectedGoods;

  GoodsDynamicSelection(
      {@required this.onSelectedGoods, this.automaticallyImplyLeading = true});
  @override
  _GoodsDynamicSelectionState createState() => _GoodsDynamicSelectionState();
}

class _GoodsDynamicSelectionState extends State<GoodsDynamicSelection> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();

  bool autovalidate = false;
  Map<String, String> goods = {};
  Map<String, String> _selectedGoods = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    Firestore.instance
        .collection('donationCategories')
        .orderBy('goodTitle')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        goods[data.documentID] = data['goodTitle'];
      });
      print(goods);
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 8),
          TypeAheadField<String>(
            suggestionsBoxDecoration: SuggestionsBoxDecoration(
              // color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              // shape: RoundedRectangleBorder(),
            ),
            hideOnError: true,
            textFieldConfiguration: TextFieldConfiguration(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: S.of(context).search,
                filled: true,
                fillColor: Colors.grey[300],
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25.7),
                ),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7)),
                contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                suffixIcon: InkWell(
                  splashColor: Colors.transparent,
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey,
                    // color: _textEditingController.text.length > 1
                    //     ? Colors.black
                    //     : Colors.grey,
                  ),
                  onTap: () {
                    _textEditingController.clear();
                    controller.close();
                  },
                ),
              ),
            ),
            suggestionsBoxController: controller,
            suggestionsCallback: (pattern) async {
              List<String> dataCopy = [];
              goods.forEach((id, skill) => dataCopy.add(skill));
              dataCopy.retainWhere(
                  (s) => s.toLowerCase().contains(pattern.toLowerCase()));

              return await Future.value(dataCopy);
            },
            itemBuilder: (context, suggestion) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            },
            noItemsFoundBuilder: (context) {
              return searchUserDefinedEntity(
                keyword: _textEditingController.text,
                language: 'en',
              );
            },
            onSuggestionSelected: (suggestion) {
              _textEditingController.clear();
              if (!_selectedGoods.containsValue(suggestion)) {
                controller.close();
                String id =
                    goods.keys.firstWhere((k) => goods[k] == suggestion);
                _selectedGoods[id] = suggestion;
//                   List<String> selectedID = [];
//                   _selectedGoods.forEach((id, _) => selectedID.add(id));
//                   print(selectedID);
                widget.onSelectedGoods(_selectedGoods);
                setState(() {});
              }
            },
          ),
          SizedBox(height: 20),
          !isDataLoaded
              ? LoadingIndicator()
              : Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: _selectedGoods.values
                            .toList()
                            .map(
                              (value) => value == null
                                  ? Container()
                                  : CustomChip(
                                      title: value,
                                      onDelete: () {
                                        String id = goods.keys.firstWhere(
                                            (k) => goods[k] == value);
                                        _selectedGoods.remove(id);
                                        setState(() {});
                                      },
                                    ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
          //   Spacer(),
        ],
      ),
    );
  }

  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String keyword,
    String language,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return getLinearLoading;
        }

        return getSuggestionLayout(
          suggestion:
              !snapshot.data.hasErros ? snapshot.data.correctSpelling : keyword,
        );
      },
    );
  }

  Widget get getLinearLoading {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Future<void> addGoodsToDb({
    String goodsId,
    String goodsTitle,
    String goodsLanguage,
  }) async {
    await Firestore.instance
        .collection('donationCategories')
        .document(goodsId)
        .setData(
      {'goodTitle': goodsTitle?.firstWordUpperCase(), 'lang': goodsLanguage},
    );
  }

  Padding getSuggestionLayout({
    String suggestion,
  }) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: GestureDetector(
        onTap: () async {
          _textEditingController.clear();
          controller.close();
          var goodsId = Uuid().generateV4();
          await addGoodsToDb(
            goodsId: goodsId,
            goodsLanguage: 'en',
            goodsTitle: suggestion,
          );
          goods[goodsId] = suggestion;

          if (!_selectedGoods.containsValue(suggestion)) {
            controller.close();
            String id = goods.keys.firstWhere((k) => goods[k] == suggestion);
            _selectedGoods[id] = suggestion;
            setState(() {});
          }
        },
        child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${S.of(context).add.toUpperCase()} \"${suggestion}\"",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                      Text(
                        S.of(context).no_data,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
              ],
            )),
      ),
    );
  }
}
