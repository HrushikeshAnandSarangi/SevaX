import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/globals.dart' as globals;
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/deep_link_manager/invitation_manager.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/exchange/edit_request.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usage/uuid/uuid.dart';

class CreateRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  final String projectId;

  CreateRequest({
    Key key,
    this.isOfferRequest,
    this.offer,
    this.timebankId,
    this.userModel,
    this.projectId,
    this.projectModel,
  }) : super(key: key);

  @override
  _CreateRequestState createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
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
                isOfferRequest:
                    widget.offer != null ? widget.isOfferRequest : false,
                offer: widget.offer,
                timebankId: widget.timebankId,
                userModel: widget.userModel,
                loggedInUser: snapshot.data.loggedinuser,
                projectId: widget.projectId,
                projectModel: widget.projectModel,
              );
            }
            return Text('');
          },
        ),
      ),
    );
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
  final String projectId;
  RequestCreateForm({
    this.isOfferRequest = false,
    this.offer,
    this.timebankId,
    this.userModel,
    this.loggedInUser,
    this.projectId,
    this.projectModel,
  });

  @override
  RequestCreateFormState createState() {
    return RequestCreateFormState();
  }
}

class RequestCreateFormState extends State<RequestCreateForm>
    with WidgetsBindingObserver {
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
  List<String> eventsIdsArr = [];
  bool comingFromDynamicLink = false;
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

  RegExp regExp = RegExp(
    r'(?:(?:https?|ftp|file):\/\/|www\.|ftp\.)(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[-A-Z0-9+&@#\/%=~_|$?!:,.])*(?:\([-A-Z0-9+&@#\/%=~_|$?!:,.]*\)|[A-Z0-9+&@#\/%=~_|$])',
    caseSensitive: false,
    multiLine: false,
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = widget.projectId;

    if (widget.isOfferRequest ?? false) {
      requestModel.requestType = widget.offer.type;
      requestModel.goodsDonationDetails.requiredGoods =
          widget.offer.goodsDonationDetails.requiredGoods;
    }

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && comingFromDynamicLink) {
      Navigator.of(context).pop();
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

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
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
//                            TransactionsMatrixCheck(transaction_matrix_type: "cash_goods_requests", child: RequestTypeWidget()),
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onChanged: (value) {
                                updateExitWithConfirmationValue(
                                    context, 1, value);
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

  void function(OfferModel offerModel) {
    switch (offerModel.type) {
      case RequestType.CASH:
        //radio button cash
        //prefrill offer title, offer description, pleged amount,

        // TODO: Handle this case.
        break;

      case RequestType.TIME:
        // TODO: Handle this case.
        break;
      case RequestType.GOODS:
        //radio button goods
        //prefrill offer title, offer description, pleged amount,

        // TODO: Handle this case.
        break;
    }
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
            selectedGoods: requestModel.goodsDonationDetails.requiredGoods,
            onSelectedGoods: (goods) =>
                {requestModel.goodsDonationDetails.requiredGoods = goods},
          ),
          SizedBox(height: 20),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 2, value);
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
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 3, value);
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
              } else {
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 4, value);
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
              } else {
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 5, value);
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
              } else {
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 6, value);
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 7, value);
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
            // initialValue: widget.offer != null && widget.isOfferRequest
            //     ? getOfferDescription(
            //         offerDataModel: widget.offer,
            //       )
            //     : "",
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 8, value);
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

  Widget RequestPaymentVenmo(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {},
            focusNode: focusNodes[12],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[12]);
            },
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              errorMaxLines: 2,
              hintText: S.of(context).venmo_hint,
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
              requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                requestModel.cashModel.venmoId = value;
                return null;
              }
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
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_paypal,
          value: RequestPaymentType.PAYPAL,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: S.of(context).request_paymenttype_zellepay,
          value: RequestPaymentType.ZELLEPAY,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton<RequestPaymentType>(
          title: 'Venmo',
          value: RequestPaymentType.VENMO,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        requestModel.cashModel.paymentType == RequestPaymentType.ACH
            ? RequestPaymentACH(requestModel)
            : requestModel.cashModel.paymentType == RequestPaymentType.PAYPAL
                ? RequestPaymentPaypal(requestModel)
                : requestModel.cashModel.paymentType == RequestPaymentType.VENMO
                    ? RequestPaymentVenmo(requestModel)
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 9, value);
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
                  _optionRadioButton<RequestType>(
                    title: S.of(context).request_type_time,
                    isEnabled: !widget.isOfferRequest,
                    value: RequestType.TIME,
                    groupvalue: requestModel.requestType,
                    onChanged: (value) {
                      requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.cash_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    child: _optionRadioButton<RequestType>(
                      title: S.of(context).request_type_cash,
                      value: RequestType.CASH,
                      isEnabled: !widget.isOfferRequest,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.requestType = value;
                        setState(() => {});
                      },
                    ),
                  ),
                  TransactionsMatrixCheck(
                    upgradeDetails:
                        AppConfig.upgradePlanBannerModel.goods_request,
                    transaction_matrix_type: 'cash_goods_requests',
                    child: _optionRadioButton<RequestType>(
                      title: S.of(context).request_type_goods,
                      isEnabled: !(widget.isOfferRequest ?? false),
                      value: RequestType.GOODS,
                      groupvalue: requestModel.requestType,
                      onChanged: (value) {
                        requestModel.requestType = value;
                        setState(() => {});
                      },
                    ),
                  ),
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
                    updateExitWithConfirmationValue(context, 10, v);
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
              updateExitWithConfirmationValue(context, 11, v);
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
          CommonUtils.TotalCredits(
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
            initialValue: widget.offer != null && widget.isOfferRequest
                ? getCashDonationAmount(
                    offerDataModel: widget.offer,
                  )
                : "",
            focusNode: focusNodes[5],
            onFieldSubmitted: (v) {
              FocusScope.of(context).unfocus();
            },
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 12, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.cashModel.targetAmount = int.parse(v);
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
              updateExitWithConfirmationValue(context, 13, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                requestModel.cashModel.minAmount = int.parse(v);
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

  Widget _optionRadioButton<T>({
    String title,
    T value,
    T groupvalue,
    Function onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: (isEnabled ?? true) ? onChanged : null,
      ),
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
      requestModel.end = end;
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
        //create an invitation for the request

      }

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
            communityId: timebankModel.communityId
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
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      String timestampString = timestamp.toString();
      requestModel.id = '${requestModel.email}*$timestampString';
      if (requestModel.isRecurring) {
        requestModel.parent_request_id = requestModel.id;
      } else {
        requestModel.parent_request_id = null;
      }
      requestModel.softDelete = false;
      requestModel.postTimestamp = timestamp;
      requestModel.accepted = false;
      requestModel.acceptors = [];
      requestModel.invitedUsers = [];
      requestModel.address = selectedAddress;
      requestModel.location = location;
      requestModel.root_timebank_id = FlavorConfig.values.timebankId;
      requestModel.softDelete = false;

      if (SevaCore.of(context).loggedInUser.calendarId != null) {
        // calendar  integrated!
        List<String> acceptorList =
            widget.isOfferRequest
                ? widget.offer.creatorAllowedCalender==null || widget.offer.creatorAllowedCalender==false ? [requestModel.email]:[widget.offer.email, requestModel.email]
                : [requestModel.email];
        requestModel.allowedCalenderUsers = acceptorList.toList();
        await continueCreateRequest(confirmationDialogContext: null);
      } else {
        linearProgressForCreatingRequest();
        eventsIdsArr = await _writeToDB();
        await _updateProjectModel();

        Navigator.pop(dialogContext);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddToCalendar(
                  isOfferRequest: widget.isOfferRequest,
                  offer: widget.offer,
                  requestModel: requestModel,
                  userModel: widget.userModel,
                  eventsIdsArr: eventsIdsArr);
            },
          ),
        );
        // await _settingModalBottomSheet(context);
      }
    }
  }

  bool hasRegisteredLocation() {
    return location != null;
  }

  void continueCreateRequest({BuildContext confirmationDialogContext}) async {
    linearProgressForCreatingRequest();

    List<String> resVar = await _writeToDB();
    eventsIdsArr = resVar;
    await _updateProjectModel();
    Navigator.pop(dialogContext);

    if (resVar.length == 0) {
      showInsufficientBalance();
    }
    if (confirmationDialogContext != null) {
      Navigator.pop(confirmationDialogContext);
    }
    if (widget.isOfferRequest == true && widget.userModel != null) {
      Navigator.pop(context, {'response': 'ACCEPTED'});
    } else {
      Navigator.pop(context);
    }
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

  Future<void> fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    log("<<<<<<<<<<<<<<<<<<<< $link");
    // buildContext = context;
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    FirebaseDynamicLinks.instance.onLink(
        onError: (_) async {},
        onSuccess: (PendingDynamicLinkData dynamicLink) async {});

    // This will handle incoming links if the application is already opened
  }

  String getTimeInFormat(int timeStamp) {
    return DateFormat(
            'EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag())
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

  Future<List<String>> _writeToDB() async {
    if (requestModel.id == null) return [];
    // credit the timebank the required credits before the request creation
    await TransactionBloc().createNewTransaction(
        requestModel.timebankId,
        requestModel.timebankId,
        DateTime.now().millisecondsSinceEpoch,
        requestModel.numberOfHours ?? 0,
        true,
        "REQUEST_CREATION_TIMEBANK_FILL_CREDITS",
        requestModel.id,
        requestModel.timebankId);
    List<String> resultVar = [];
    if (!requestModel.isRecurring) {
      await FirestoreManager.createRequest(requestModel: requestModel);
      //create invitation if its from offer only for cash and goods
      try {
        await OfferInvitationManager
            .handleInvitationNotificationForRequestCreatedFromOffer(
          currentCommunity: widget.userModel.currentCommunity,
          offerModel: widget.offer,
          requestModel: requestModel,
          senderSevaUserID: requestModel.sevaUserId,
          timebankModel: timebankModel,
        );
      } on Exception catch (exception) {
        //Log to crashlytics
      }

      resultVar.add(requestModel.id);
      return resultVar;
    } else {
      resultVar = await FirestoreManager.createRecurringEvents(
          requestModel: requestModel);
      return resultVar;
    }
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
              S.of(context).select_project,
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
                    S.of(context).projects_here,
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

class ProjectSelection extends StatefulWidget {
  ProjectSelection({
    Key key,
    this.requestModel,
    this.admin,
    this.projectModelList,
    this.selectedProject,
  }) : super(key: key);
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
  final StringMapCallback onSelectedGoods;
  final Map<String, String> selectedGoods;

  GoodsDynamicSelection({@required this.onSelectedGoods, this.selectedGoods});
  @override
  _GoodsDynamicSelectionState createState() => _GoodsDynamicSelectionState();
}

class _GoodsDynamicSelectionState extends State<GoodsDynamicSelection> {
  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController _textEditingController = TextEditingController();
  Map<String, String> goods = {};
  Map<String, String> _selectedGoods = {};
  bool isDataLoaded = false;

  @override
  void initState() {
    _selectedGoods = widget.selectedGoods ?? {};
    Firestore.instance
        .collection('donationCategories')
        .orderBy('goodTitle')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        goods[data.documentID] = data['goodTitle'];
      });
      isDataLoaded = true;
      if (this.mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 8),
        TypeAheadField<SuggestedItem>(
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          errorBuilder: (context, err) {
            return Text(S.of(context).error_occured);
          },
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
            List<SuggestedItem> dataCopy = [];
            goods.forEach(
              (k, v) => dataCopy.add(SuggestedItem()
                ..suggestionMode = SuggestionMode.FROM_DB
                ..suggesttionTitle = v),
            );
            dataCopy.retainWhere((s) => s.suggesttionTitle
                .toLowerCase()
                .contains(pattern.toLowerCase()));

            if (pattern.length > 2 &&
                !dataCopy
                    .contains(SuggestedItem()..suggesttionTitle = pattern)) {
              var spellCheckResult =
                  await SpellCheckManager.evaluateSpellingFor(pattern,
                      language: 'en');
              if (spellCheckResult.hasErros) {
                dataCopy.add(SuggestedItem()
                  ..suggestionMode = SuggestionMode.USER_DEFINED
                  ..suggesttionTitle = pattern);
              } else if (spellCheckResult.correctSpelling != pattern) {
                dataCopy.add(SuggestedItem()
                  ..suggestionMode = SuggestionMode.SUGGESTED
                  ..suggesttionTitle = spellCheckResult.correctSpelling);

                dataCopy.add(SuggestedItem()
                  ..suggestionMode = SuggestionMode.USER_DEFINED
                  ..suggesttionTitle = pattern);
              } else {
                dataCopy.add(SuggestedItem()
                  ..suggestionMode = SuggestionMode.USER_DEFINED
                  ..suggesttionTitle = pattern);
              }
            }
            return await Future.value(dataCopy);
          },
          itemBuilder: (context, suggestedItem) {
            switch (suggestedItem.suggestionMode) {
              case SuggestionMode.FROM_DB:
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    suggestedItem.suggesttionTitle,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                );

              case SuggestionMode.SUGGESTED:
                if (ProfanityDetector()
                    .isProfaneString(suggestedItem.suggesttionTitle)) {
                  return ProfanityDetector.getProanityAdvisory(
                    suggestion: suggestedItem.suggesttionTitle,
                    suggestionMode: SuggestionMode.SUGGESTED,
                    context: context,
                  );
                }
                return searchUserDefinedEntity(
                  keyword: suggestedItem.suggesttionTitle,
                  language: 'en',
                  suggestionMode: suggestedItem.suggestionMode,
                  showLoader: true,
                );

              case SuggestionMode.USER_DEFINED:
                if (ProfanityDetector()
                    .isProfaneString(suggestedItem.suggesttionTitle)) {
                  return ProfanityDetector.getProanityAdvisory(
                    suggestion: suggestedItem.suggesttionTitle,
                    suggestionMode: SuggestionMode.USER_DEFINED,
                    context: context,
                  );
                }

                return searchUserDefinedEntity(
                  keyword: suggestedItem.suggesttionTitle,
                  language: 'en',
                  suggestionMode: suggestedItem.suggestionMode,
                  showLoader: false,
                );

              default:
                return Container();
            }
          },
          noItemsFoundBuilder: (context) {
            return searchUserDefinedEntity(
              keyword: _textEditingController.text,
              language: 'en',
            );
          },
          onSuggestionSelected: (suggestion) {
            if (ProfanityDetector()
                .isProfaneString(suggestion.suggesttionTitle)) {
              return;
            }

            switch (suggestion.suggestionMode) {
              case SuggestionMode.SUGGESTED:
                var newGoodId = Uuid().generateV4();
                addGoodsToDb(
                  goodsId: newGoodId,
                  goodsLanguage: 'en',
                  goodsTitle: suggestion.suggesttionTitle,
                );
                goods[newGoodId] = suggestion.suggesttionTitle;
                break;

              case SuggestionMode.USER_DEFINED:
                var goodId = Uuid().generateV4();
                addGoodsToDb(
                  goodsId: goodId,
                  goodsLanguage: 'en',
                  goodsTitle: suggestion.suggesttionTitle,
                );
                goods[goodId] = suggestion.suggesttionTitle;
                break;

              case SuggestionMode.FROM_DB:
                break;
            }
            // controller.close();

            _textEditingController.clear();
            if (!_selectedGoods.containsValue(suggestion)) {
              controller.close();
              String id = goods.keys.firstWhere(
                (k) => goods[k] == suggestion.suggesttionTitle,
              );
              _selectedGoods[id] = suggestion.suggesttionTitle;
              widget.onSelectedGoods(_selectedGoods);
              setState(() {});
            }
          },
        ),
        SizedBox(height: 20),
        !isDataLoaded
            ? LoadingIndicator()
            : Wrap(
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
                                String id = goods.keys
                                    .firstWhere((k) => goods[k] == value);
                                _selectedGoods.remove(id);
                                setState(() {});
                              },
                            ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
    String keyword,
    String language,
    SuggestionMode suggestionMode,
    bool showLoader,
  }) {
    return FutureBuilder<SpellCheckResult>(
      future: SpellCheckManager.evaluateSpellingFor(
        keyword,
        language: language,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return showLoader ? getLinearLoading : LinearProgressIndicator();
        }

        return getSuggestionLayout(
          suggestion: keyword,
          suggestionMode: suggestionMode,
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
    SuggestionMode suggestionMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: S.of(context).add,
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          TextSpan(
                            text: "\"${suggestion}\"",
                            style: suggestionMode == SuggestionMode.SUGGESTED
                                ? TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  )
                                : TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.red,
                                    decorationStyle: TextDecorationStyle.wavy,
                                    decorationThickness: 1.5,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      suggestionMode == SuggestionMode.SUGGESTED
                          ? S.of(context).suggested
                          : S.of(context).entered,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
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
    );
  }
}
