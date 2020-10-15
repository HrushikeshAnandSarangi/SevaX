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
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as RequestManager;
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/messages/list_members_timebank.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/views/workshop/direct_assignment.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:usage/uuid/uuid.dart';
class EditRequest extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final ProjectModel projectModel;
  String projectId;
  RequestModel requestModel;

  EditRequest(
      {Key key,
      this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.projectId,
      this.projectModel,
      this.requestModel})
      : super(key: key);

  @override
  _EditRequestState createState() => _EditRequestState();
}

class _EditRequestState extends State<EditRequest> {
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              title,
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
                  return RequestEditForm(
                    requestModel: widget.requestModel,
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
              })),
    );
  }

  String get title {
    if (widget.requestModel.projectId == null ||
        widget.requestModel.projectId == "" ||
        widget.requestModel.projectId.isEmpty) {
      return S.of(context).edit;
    }
    return S.of(context).edit_project;
  }
}

class RequestEditForm extends StatefulWidget {
  final bool isOfferRequest;
  final OfferModel offer;
  final String timebankId;
  final UserModel userModel;
  final UserModel loggedInUser;
  final ProjectModel projectModel;
  final String projectId;
  RequestModel requestModel;
  RequestEditForm(
      {this.isOfferRequest,
      this.offer,
      this.timebankId,
      this.userModel,
      this.loggedInUser,
      this.projectId,
      this.projectModel,
      this.requestModel});

  @override
  RequestEditFormState createState() {
    return RequestEditFormState();
  }
}

class RequestEditFormState extends State<RequestEditForm> {
  final GlobalKey<_EditRequestState> _offerState = GlobalKey();
  final GlobalKey<OfferDurationWidgetState> _calendarState = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final hoursTextFocus = FocusNode();
  final volunteersTextFocus = FocusNode();

  RequestModel requestModel = RequestModel();
  GeoFirePoint location;

  End end = End();
  var focusNodes = List.generate(16, (_) => FocusNode());

  double sevaCoinsValue = 0;
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;
  int sharedValue = 0;

  String _selectedTimebankId;
  int oldHours = 0;
  int oldTotalRecurrences = 0;

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
    _selectedTimebankId = widget.timebankId;
    this.requestModel.timebankId = _selectedTimebankId;
    this.location = widget.requestModel.location;
    this.selectedAddress = widget.requestModel.address;
    this.oldHours = widget.requestModel.numberOfHours;
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
    this.requestModel.email = widget.requestModel.email;
    this.requestModel.fullName = widget.requestModel.fullName;
    this.requestModel.photoUrl = widget.requestModel.photoUrl;
    this.requestModel.sevaUserId = widget.requestModel.sevaUserId;
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
    TextStyle textStyle = Theme.of(context).textTheme.title;
    var startDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestStart));
    var endDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: SevaCore.of(context).loggedInUser.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestEnd));
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
                            // headerContainer(snapshot),
                            // RequestTypeWidget(),
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
                              initialValue: widget.requestModel.title,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return S.of(context).request_subject;
                                }
                                if (profanityDetector.isProfaneString(value)) {
                                  return S.of(context).profanity_text_alert;
                                }
                                widget.requestModel.title = value;
                              },
                            ),
                            SizedBox(height: 30),
                            OfferDurationWidget(
                                title: S.of(context).request_duration,
                                startTime: startDate,
                                endTime: endDate),
                            widget.requestModel.requestType == RequestType.TIME
                                ? TimeRequest(snapshot, projectModelList)
                                : widget.requestModel.requestType ==
                                        RequestType.CASH
                                    ? CashRequest(snapshot, projectModelList)
                                    : GoodsRequest(snapshot, projectModelList),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 30.0),
                              child: Center(
                                child: Container(
                                  // width: 150,
                                  child: RaisedButton(
                                    onPressed: editRequest,
                                    child: Text(
                                      S
                                          .of(context)
                                          .update_request
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
            goodsbefore: widget.requestModel.goodsDonationDetails.requiredGoods,
            onSelectedGoods: (goods) => {
              widget.requestModel.goodsDonationDetails.requiredGoods = goods
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
            initialValue: widget.requestModel.goodsDonationDetails.address,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
                widget.requestModel.goodsDonationDetails.address = value;
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
            initialValue: requestModel.cashModel.achdetails.bank_name,
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
                widget.requestModel.cashModel.achdetails.bank_name = value;
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
            initialValue: requestModel.cashModel.achdetails.bank_address,
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
                widget.requestModel.cashModel.achdetails.bank_address = value;
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
            initialValue: requestModel.cashModel.achdetails.routing_number,
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
                widget.requestModel.cashModel.achdetails.routing_number = value;
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
            initialValue: requestModel.cashModel.achdetails.account_number,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 6, value);
            },
            focusNode: focusNodes[15],
            onFieldSubmitted: (v) {
              FocusScope.of(context).requestFocus(focusNodes[15]);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.achdetails.account_number = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!value.isEmpty) {
                widget.requestModel.cashModel.achdetails.account_number = value;
              } else {
                return S.of(context).enter_valid_account_number;
              }
              return null;
            },
          )
        ]);
  }

  RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

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
            initialValue: requestModel.cashModel.zelleId != null
                ? requestModel.cashModel.zelleId
                : '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.zelleId = value;
            },
            validator: (value) {
              return _validateEmailAndPhone(value);
            },
          )
        ]);
  }

  String _validateEmailAndPhone(String value) {
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value)) {
      widget.requestModel.cashModel.zelleId = value;

      return null;
    } else if (regExp.hasMatch(value)) {
      widget.requestModel.cashModel.zelleId = value;

      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
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
            initialValue: requestModel.cashModel.paypalId ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.paypalId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else if (!emailPattern.hasMatch(value)) {
                return S.of(context).enter_valid_link;
              } else {
                widget.requestModel.cashModel.paypalId = value;

                return null;
              }
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
            initialValue: requestModel.cashModel.venmoId ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              }
              // else if (!emailPattern.hasMatch(value)) {
              //   return S.of(context).enter_valid_link;
              // }
              else {
                widget.requestModel.cashModel.venmoId = value;

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
        _optionRadioButton(
          title: S.of(context).request_paymenttype_ach,
          value: RequestPaymentType.ACH,
          groupvalue: requestModel.cashModel.paymentType,
          onChanged: (value) {
            widget.requestModel.cashModel.paymentType = value;
            setState(() => {});
          },
        ),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_paypal,
            value: RequestPaymentType.PAYPAL,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        _optionRadioButton(
            title: S.of(context).request_paymenttype_zellepay,
            value: RequestPaymentType.ZELLEPAY,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        _optionRadioButton(
            title: 'Venmo',
            value: RequestPaymentType.VENMO,
            groupvalue: requestModel.cashModel.paymentType,
            onChanged: (value) {
              widget.requestModel.cashModel.paymentType = value;
              setState(() => {});
            }),
        getPaymentInformation
      ],
    );
  }

  Widget get getPaymentInformation {
    switch (widget.requestModel.cashModel.paymentType) {
      case RequestPaymentType.ACH:
        return RequestPaymentACH(widget.requestModel);

      case RequestPaymentType.PAYPAL:
        return RequestPaymentPaypal(widget.requestModel);

      case RequestPaymentType.ZELLEPAY:
        return RequestPaymentZellePay(widget.requestModel);

      case RequestPaymentType.VENMO:
        return RequestPaymentVenmo(widget.requestModel);

      default:
        return RequestPaymentACH(widget.requestModel);
    }
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
          maxLength: 500,
          decoration: InputDecoration(
            errorMaxLines: 2,
            hintText: hintTextDesc,
            hintStyle: hintTextStyle,
          ),
          initialValue: widget.requestModel.description,
          keyboardType: TextInputType.multiline,
          maxLines: 1,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            }
            if (profanityDetector.isProfaneString(value)) {
              return S.of(context).profanity_text_alert;
            }
            widget.requestModel.description = value;
          },
        ),
      ],
    );
  }

  Widget RequestTypeWidget() {
    return widget.requestModel.requestMode == RequestMode.TIMEBANK_REQUEST
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
                    groupvalue: widget.requestModel.requestType,
                    onChanged: (value) {
                      widget.requestModel.requestType = value;
                      setState(() => {});
                    },
                  ),
                  _optionRadioButton(
                      title: S.of(context).request_type_cash,
                      value: RequestType.CASH,
                      groupvalue: widget.requestModel.requestType,
                      onChanged: (value) {
                        widget.requestModel.requestType = value;
                        setState(() => {});
                      }),
                  _optionRadioButton(
                      title: S.of(context).request_type_goods,
                      value: RequestType.GOODS,
                      groupvalue: widget.requestModel.requestType,
                      onChanged: (value) {
                        widget.requestModel.requestType = value;
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
                  initialValue: widget.requestModel.maxCredits.toString(),
                  onChanged: (v) {
                    updateExitWithConfirmationValue(context, 10, v);
                    if (v.isNotEmpty && int.parse(v) >= 0) {
                      widget.requestModel.maxCredits = int.parse(v);
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
            initialValue: widget.requestModel.numberOfApprovals.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 11, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.numberOfApprovals = int.parse(v);
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
                widget.requestModel.numberOfApprovals = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          CommonUtils.TotalCredits(
            context: context,
            requestCreditsMode: TotalCreditseMode.EDIT_MODE,
            requestModel: widget.requestModel,
          ),
          SizedBox(height: 40),
          Center(
            child: LocationPickerWidget(
              selectedAddress: selectedAddress,
              location: location,
              onChanged: (LocationDataModel dataModel) {
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
            initialValue: widget.requestModel.cashModel.targetAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 12, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.targetAmount = int.parse(v);
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
                widget.requestModel.cashModel.targetAmount = int.parse(value);
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
            initialValue: widget.requestModel.cashModel.minAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 13, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.minAmount = int.parse(v);
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
              } else {
                widget.requestModel.cashModel.minAmount = int.parse(value);
                setState(() {});
                return null;
              }
            },
          ),
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_cash),
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
          RequestPaymentDescriptionData(widget.requestModel),
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
                  widget.requestModel.requestMode =
                      RequestMode.TIMEBANK_REQUEST;
                } else {
                  widget.requestModel.requestMode =
                      RequestMode.PERSONAL_REQUEST;
                  widget.requestModel.requestType = RequestType.TIME;
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
          widget.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
        } else {
          widget.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
          widget.requestModel.requestType = RequestType.TIME;
        }
      }
      return Container();
    }
  }

  BuildContext dialogContext;

  void editRequest() async {
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

    if (_formKey.currentState.validate()) {
      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        widget.requestModel.recurringDays =
            EditRepeatWidgetState.getRecurringdays();
        end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
        end.on = end.endType == "on"
            ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch
            : null;
        end.after = (end.endType == "after"
            ? int.parse(EditRepeatWidgetState.after)
            : 1);
        widget.requestModel.end = end;
      }

      if (widget.requestModel.requestMode == RequestMode.PERSONAL_REQUEST) {
        var onBalanceCheckResult;
        if (widget.requestModel.isRecurring == true ||
            widget.requestModel.autoGenerated == true) {
          int recurrences = widget.requestModel.end.endType == "after"
              ? (widget.requestModel.end.after -
                      widget.requestModel.occurenceCount)
                  .abs()
              : calculateRecurrencesOnMode(widget.requestModel);
          onBalanceCheckResult =
              await RequestManager.hasSufficientCreditsIncludingRecurring(
                  credits: widget.requestModel.numberOfHours.toDouble(),
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
                  isRecurring: widget.requestModel.isRecurring,
                  recurrences: recurrences);
        } else {
          onBalanceCheckResult =
              await RequestManager.hasSufficientCreditsIncludingRecurring(
                  credits: widget.requestModel.numberOfHours.toDouble(),
                  userId: SevaCore.of(context).loggedInUser.sevaUserID,
                  isRecurring: widget.requestModel.isRecurring,
                  recurrences: 0);
        }

        if (!onBalanceCheckResult) {
          showInsufficientBalance();
          return;
        }
      }

      /// TODO take language from Prakash
      if (OfferDurationWidgetState.starttimestamp ==
          OfferDurationWidgetState.endtimestamp) {
        showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }

      // if (location != null) {
      widget.requestModel.requestStart =
          OfferDurationWidgetState.starttimestamp;
      widget.requestModel.requestEnd = OfferDurationWidgetState.endtimestamp;
      widget.requestModel.location = location;
      widget.requestModel.address = selectedAddress;

      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext viewContext) {
            return WillPopScope(
              onWillPop: () {},
              child: AlertDialog(
                title: Text(S.of(context).this_is_repeating_event),
                actions: [
                  FlatButton(
                    child: Text(
                      S.of(context).edit_this_event,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                      linearProgressForCreatingRequest();
                      await updateRequest(requestModel: widget.requestModel);
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      S.of(context).edit_subsequent_event,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                      linearProgressForCreatingRequest();
                      await updateRequest(requestModel: widget.requestModel);
                      await RequestManager.updateRecurrenceRequestsFrontEnd(
                          updatedRequestModel: widget.requestModel);

                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      S.of(context).cancel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontFamily: 'Europa',
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(viewContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      } else {
        linearProgressForCreatingRequest();

        await updateRequest(requestModel: widget.requestModel);

        Navigator.pop(dialogContext);
        Navigator.pop(context);
      }
    }
  }

  Future _getLocation() async {
    String address = await LocationUtility().getFormattedAddress(
      location.latitude,
      location.longitude,
    );

    setState(() {
      this.selectedAddress = address;
    });
  }

  int calculateRecurrencesOnMode(RequestModel requestModel) {
    DateTime eventStartDate =
        DateTime.fromMillisecondsSinceEpoch(requestModel.requestStart);
    int recurrenceCount = 0;
    bool lastRound = false;
    while (lastRound == false) {
      eventStartDate = DateTime(
          eventStartDate.year,
          eventStartDate.month,
          eventStartDate.day + 1,
          eventStartDate.hour,
          eventStartDate.minute,
          eventStartDate.second);
      if (eventStartDate.millisecondsSinceEpoch <= requestModel.end.on &&
          recurrenceCount < 11) {
        if (requestModel.recurringDays.contains(eventStartDate.weekday % 7)) {
          recurrenceCount++;
        }
      } else {
        lastRound = true;
      }
    }
    log("on mode recurrence count isss $recurrenceCount");
    return recurrenceCount;
  }

  bool hasRegisteredLocation() {
    return location != null;
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

  void linearProgressForCreatingRequest() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogContext = createDialogContext;
          return AlertDialog(
            title: Text(S.of(context).updating_request),
            content: LinearProgressIndicator(),
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
    return DateFormat(
            'EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: SevaCore.of(context).loggedInUser.timezone),
    );
  }

  bool hasSufficientBalance() {
    var requestCoins = widget.requestModel.numberOfHours;
    var lowerLimit =
        json.decode(AppConfig.remoteConfig.getString('user_minimum_balance'));

    var finalbalance = (sevaCoinsValue + lowerLimit ?? 10);
    return requestCoins <= finalbalance;
  }

  Future _updateProjectModel() async {
    if (widget.projectId.isNotEmpty && !widget.requestModel.isRecurring) {
      ProjectModel projectModel = widget.projectModel;
//      var userSevaUserId = SevaCore.of(context).loggedInUser.sevaUserID;
//      if (!projectModel.members.contains(userSevaUserId)) {
//        projectModel.members.add(userSevaUserId);
//      }
      projectModel.pendingRequests.add(widget.requestModel.id);
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
  Map<String, String> goodsbefore;
  final StringMapCallback onSelectedGoods;

  GoodsDynamicSelection(
      {this.goodsbefore,
      @required this.onSelectedGoods,
      this.automaticallyImplyLeading = true});
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
    this._selectedGoods = widget.goodsbefore != null ? widget.goodsbefore : {};
    Firestore.instance
        .collection('donationCategories')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.documents.forEach((DocumentSnapshot data) {
        // suggestionText.add(data['name']);
        // suggestionID.add(data.documentID);
        goods[data.documentID] = data['goodTitle'];

        // ids[data['name']] = data.documentID;
      });
      setState(() {
        isDataLoaded = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8),
            //TODOSUGGESTION
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
                      borderRadius: BorderRadius.circular(25.7),
                    ),
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
                      !dataCopy.contains(
                          SuggestedItem()..suggesttionTitle = pattern)) {
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
                    showLoader: false,
                  );
                },
                onSuggestionSelected: (SuggestedItem suggestion) {
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
                }
                // onSuggestionSelected: (suggestion) {
                //   _textEditingController.clear();
                //   if (!_selectedGoods.containsValue(suggestion)) {
                //     controller.close();
                //     String id =
                //         goods.keys.firstWhere((k) => goods[k] == suggestion);
                //     _selectedGoods[id] = suggestion;
                //     widget.onSelectedGoods(_selectedGoods);
                //     setState(() {});
                //   }
                // },
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
                                          String id =
                                              _selectedGoods.keys.firstWhere(
                                            (k) {
                                              return _selectedGoods[k] == value;
                                            },
                                          );
                                          _selectedGoods.remove(id);
                                          widget
                                              .onSelectedGoods(_selectedGoods);
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
        ));
  }

  // FutureBuilder<SpellCheckResult> searchUserDefinedEntity({
  //   String keyword,
  //   String language,
  // }) {
  //   return FutureBuilder<SpellCheckResult>(
  //     future: SpellCheckManager.evaluateSpellingFor(
  //       keyword,
  //       language: language,
  //     ),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return getLinearLoading;
  //       }

  //       return getSuggestionLayout(
  //         suggestion:
  //             !snapshot.data.hasErros ? snapshot.data.correctSpelling : keyword,
  //       );
  //     },
  //   );
  // }

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
      {'goodTitle': goodsTitle, 'lang': goodsLanguage},
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
                            text: "Add ",
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
                          ? 'Suggested'
                          : 'You entered',
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
  // Padding getSuggestionLayout({
  //   String suggestion,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.all(18.0),
  //     child: GestureDetector(
  //       onTap: () async {
  //         _textEditingController.clear();
  //         controller.close();
  //         var goodsId = Uuid().generateV4();
  //         await addGoodsToDb(
  //           goodsId: goodsId,
  //           goodsLanguage: 'en',
  //           goodsTitle: suggestion,
  //         );
  //         goods[goodsId] = suggestion;

  //         if (!_selectedGoods.containsValue(suggestion)) {
  //           controller.close();
  //           String id = goods.keys.firstWhere((k) => goods[k] == suggestion);
  //           _selectedGoods[id] = suggestion;
  //           setState(() {});
  //         }
  //       },
  //       child: Container(
  //           height: 40,
  //           alignment: Alignment.centerLeft,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "${S.of(context).add.toUpperCase()} \"${suggestion}\"",
  //                       style: TextStyle(fontSize: 16, color: Colors.blue),
  //                     ),
  //                     Text(
  //                       S.of(context).no_data,
  //                       style: TextStyle(fontSize: 16, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Icon(
  //                 Icons.add,
  //                 color: Colors.grey,
  //               ),
  //             ],
  //           )),
  //     ),
  //   );
  // }
}

enum TotalCreditseMode { EDIT_MODE, CREATE_MODE }
