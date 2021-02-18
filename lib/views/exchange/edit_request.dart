import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/equality.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/category_model.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/project_model.dart';
import 'package:sevaexchange/routes/requests_router.gr.dart';
import 'package:sevaexchange/ui/screens/authentication/bloc/auth_bloc.dart';
import 'package:sevaexchange/ui/screens/feeds/share_feed_component/states/share_feed_search_component.dart';
import 'package:sevaexchange/ui/screens/find_communities/pages/explore_communities_page.dart';
import 'package:sevaexchange/ui/screens/seva_community/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/ui/utils/debouncer.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/ui/utils/remote_config.dart';
import 'package:sevaexchange/ui/utils/seva_credits_manager.dart';
import 'package:sevaexchange/utils/analytics/analytics_service.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart'
    as RequestManager;
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/location_utility.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/exchange/createrequest.dart';
import 'package:sevaexchange/views/onboarding/interests_view.dart';
import 'package:sevaexchange/views/project_view/create_edit_project.dart';
import 'package:sevaexchange/views/spell_check_manager.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_chip.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/multi_select/flutter_multiselect.dart';
import 'package:sevaexchange/widgets/select_category.dart';
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
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                controller: controller,
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
          },
        ),
      ),
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
  final ScrollController controller;
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
      this.requestModel,
      this.controller});

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
  ProjectModel selectedProjectModel = null;
  RequestModel requestModel;
  GeoFirePoint location;
  String initialRequestTitle = '';
  String initialRequestDescription = '';
  var startDate;
  var endDate;
  int tempCredits = 0;
  int tempNoOfVolunteers = 0;
  End end = End();
  var focusNodes = List.generate(16, (_) => FocusNode());
  bool updateProject = false;
  double sevaCoinsValue = 0;
  String hoursMessage = ' Click to Set Duration';
  String selectedAddress;
  int sharedValue = 0;
  List<String> selectedCategoryIds = [];

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
  var futures = <Future>[];
  List<ProjectModel> userPersonalProjects = [];
  List<ProjectModel> timebankProjects = [];
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    AnalyticsService.editRequest;

    _selectedTimebankId = widget.timebankId;
    requestModel = RequestModel(
      communityId: widget.requestModel.communityId,
    );
    this.requestModel.timebankId = _selectedTimebankId;
    this.location = widget.requestModel.location;
    this.selectedAddress = widget.requestModel.address;
    this.oldHours = widget.requestModel.numberOfHours;
    this.requestModel.requestMode = RequestMode.TIMEBANK_REQUEST;
    this.requestModel.projectId = selectedProjectModel?.id ?? widget.projectId;

    getTimebankAdminStatus = getTimebankDetailsbyFuture(
      timebankId: _selectedTimebankId,
    );
    futures.add(FirestoreManager.getUserPersonalProjectsListFuture(
        timebankid: _selectedTimebankId,
        sevauserid: widget.loggedInUser.sevaUserID));
    futures.add(FirestoreManager.getTimebankProjectsListFuture(
      timebankid: _selectedTimebankId,
    ));

    if (widget.requestModel.categories != null) {
      getCategoryModels(widget.requestModel.categories);
    }
    fetchRemoteConfig();

    if ((FlavorConfig.appFlavor == Flavor.APP ||
        FlavorConfig.appFlavor == Flavor.SEVA_DEV)) {
      // _fetchCurrentlocation;
    }

    if (widget.requestModel.projectId != "" &&
        widget.requestModel.projectId != null) {
      Firestore.instance
          .collection('projects')
          .document(widget.requestModel.projectId)
          .get()
          .then((selectedProjectDoc) {
        selectedProjectModel = ProjectModel.fromMap(selectedProjectDoc.data);
        log("project id getttted is ${selectedProjectModel.name}");
        setState(() {});
      });
    }
    Future.wait(futures).then((value) {
      userPersonalProjects = value[0];
      timebankProjects = value[1];
      setState(() {});
    });
  }

  Future<void> fetchRemoteConfig() async {
    AppConfig.remoteConfig = await RemoteConfig.getInstance();
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
  );
  Widget addToProjectContainer(snapshot, requestModel) {
    if (snapshot.hasError) return Text(snapshot.error.toString());
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    timebankModel = snapshot.data;
    if (isAccessAvailable(
        snapshot.data, BlocProvider.of<AuthBloc>(context).user.sevaUserID)) {
      return assignProjectToRequestContainerWidget;
//      return ProjectSelection(
//          requestModel: requestModel,
//          projectModelList: projectModelList,
//          selectedProject: null,
//          admin: snapshot.data.admins
//              .contains(BlocProvider.of<AuthBloc>(context).user.sevaUserID));
    } else {
      this.requestModel.requestMode = RequestMode.PERSONAL_REQUEST;
      this.requestModel.requestType = RequestType.TIME;
      return assignProjectToRequestContainerWidget;
    }
  }

  Widget get assignProjectToRequestContainerWidget {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () async {
        ExtendedNavigator.ofRouter<RequestsRouter>()
            .pushAssignProjectToRequest(
          timebankModel: timebankModel,
          userModel: BlocProvider.of<AuthBloc>(context).user,
          timebankProjectsList: timebankProjects,
          personalProjectsList: userPersonalProjects,
        )
            .then((projectModelRes) {
          if (projectModelRes != '') {
            selectedProjectModel = projectModelRes;
            this.requestModel.projectId = selectedProjectModel.id;
            widget.requestModel.projectId = selectedProjectModel.id;
            updateProject = true;
            setState(() {});
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(S.of(context).assign_to_project,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              Spacer(),
              Icon(
                Icons.arrow_drop_down_circle,
                size: 30,
                color: Theme.of(context).primaryColor,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Chip(
            label: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 80.0),
              child: Text(
                  selectedProjectModel == null
                      ? S.of(context).unassigned
                      : selectedProjectModel.name,
                  overflow: TextOverflow.ellipsis),
            ),
            deleteIcon: Icon(
              Icons.cancel,
              size: 20,
            ),
            deleteIconColor: Colors.black38,
            onDeleted: () {
              if (selectedProjectModel != null) {
                selectedProjectModel = null;
                setState(() {});
              }
            },
          )
        ],
      ),
    );
  }

  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  @override
  Widget build(BuildContext context) {
    initialRequestTitle = widget.requestModel.title;
    initialRequestDescription = widget.requestModel.description;
    tempCredits = widget.requestModel.maxCredits;
    tempNoOfVolunteers = widget.requestModel.numberOfApprovals;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    startDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: BlocProvider.of<AuthBloc>(context).user.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestStart));
    endDate = getUpdatedDateTimeAccToUserTimezone(
        timezoneAbb: BlocProvider.of<AuthBloc>(context).user.timezone,
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            widget.requestModel.requestEnd));
    hoursMessage = S.of(context).set_duration;
    UserModel loggedInUser = BlocProvider.of<AuthBloc>(context).user;
    this.requestModel.email = loggedInUser.email;
    this.requestModel.sevaUserId = loggedInUser.sevaUserID;

    Widget headerContainer(snapshot) {
      if (snapshot.hasError) return Text(snapshot.error.toString());
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container();
      }
      timebankModel = snapshot.data;
      if (isAccessAvailable(
          snapshot.data, BlocProvider.of<AuthBloc>(context).user.sevaUserID)) {
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
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          timebankModel = snapshot.data;
          return Form(
            key: _formKey,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(left: 50, right: 120, top: 30),
              child: CustomScrollWithKeyboard(
                controller: widget.controller,
                child: Container(
                  margin: EdgeInsets.only(right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SevaPrefixIconForTitle(
                        margin: EdgeInsets.only(top: 22, right: 15),
                        prefixIcon: SevaWebAssetIcons.requests,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            margin: EdgeInsets.only(right: 30),
                            child: Column(
                              //COLUMN
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          // horizontal: 20,
                                          // vertical: 10,
                                          ),
                                      child: Text(
                                        S.of(context).edit_request,
                                        // textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 32,
                                          color: HexColor('#212121'),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    CustomCloseButton(
                                      onCleared: () {
                                        ExtendedNavigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Text(
                                    S.of(context).request_title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                CustomTextField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onChanged: (value) {
                                    setState(() {
                                      initialRequestTitle = value;
                                    });
                                    updateExitWithConfirmationValue(
                                        context, 1, value);
                                  },
                                  // onFieldSubmitted: (v) {
                                  //   FocusScope.of(context)
                                  //       .requestFocus(focusNodes[0]);
                                  // },
                                  formatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter(
                                        RegExp("[a-zA-Z0-9_ ]*"))
                                  ],
                                  errorMaxLines: 2,
                                  hintText: requestModel.requestType ==
                                          RequestType.TIME
                                      ? S.of(context).request_title_hint
                                      : requestModel.requestType ==
                                              RequestType.CASH
                                          ? "Fundraiser for women’s shelter..."
                                          : "Non-perishable goods for Food Bank...",
                                  // decoration: InputDecoration(
                                  //   hintStyle: hintTextStyle,
                                  // ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  initialValue: widget.requestModel.title,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return S.of(context).request_subject;
                                    }
                                    if (profanityDetector
                                        .isProfaneString(value)) {
                                      return S.of(context).profanity_text_alert;
                                    }
                                    //widget.requestModel.title = value;
                                    initialRequestTitle = value;
                                  },
                                ),
                                SizedBox(height: 30),
                                OfferDurationWidgetWeb(
                                    title:
                                        S.of(context).request_duration + " *",
                                    startTime: startDate,
                                    endTime: endDate),
                                widget.requestModel.requestType ==
                                        RequestType.TIME
                                    ? TimeRequest(snapshot)
                                    : widget.requestModel.requestType ==
                                            RequestType.CASH
                                        ? CashRequest(snapshot)
                                        : GoodsRequest(snapshot),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 30.0),
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
                                        style: TextStyle(
                                          color: Colors.white,
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
                    ],
                  ),
                ),
              ),
            ),
          );
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
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          GoodsDynamicSelection(
            goodsbefore: widget.requestModel.goodsDonationDetails.requiredGoods,
            onSelectedGoods: (goods) => {
              widget.requestModel.goodsDonationDetails.requiredGoods = goods
            },
          ),
          SizedBox(height: 10),
          Text(
            S.of(context).request_goods_address,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 2, value);
            },
            focusNode: focusNodes[8],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[8]);
            // },
            textInputAction: TextInputAction.next,
            errorMaxLines: 2,
            hintText: S.of(context).request_goods_address_inputhint,

            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            // ),
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: requestModel.cashModel.achdetails.bank_name,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 3, value);
            },
            focusNode: focusNodes[12],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[13]);
            // },
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: requestModel.cashModel.achdetails.bank_address,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 4, value);
            },
            focusNode: focusNodes[13],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[14]);
            // },
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: requestModel.cashModel.achdetails.routing_number,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 5, value);
            },
            focusNode: focusNodes[14],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[15]);
            // },
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: requestModel.cashModel.achdetails.account_number,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 6, value);
            },
            focusNode: focusNodes[15],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[15]);
            // },
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
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 7, value);
            },
            focusNode: focusNodes[12],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[12]);
            // },
            errorMaxLines: 2,
            hintText: S.of(context).request_payment_descriptionZelle_inputhint,
            textInputAction: TextInputAction.next,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            // ),
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
    } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
      widget.requestModel.cashModel.zelleId = value;
      return null;
    } else {
      return S.of(context).enter_valid_link;
    }
  }

  Widget RequestPaymentPaypal(RequestModel requestModel) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              updateExitWithConfirmationValue(context, 8, value);
            },
            focusNode: focusNodes[12],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[12]);
            // },
            textInputAction: TextInputAction.next,
            errorMaxLines: 2,
            hintText: S.of(context).email_hint,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            // ),
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
          CustomTextField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {},
            focusNode: focusNodes[12],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).requestFocus(focusNodes[12]);
            // },
            textInputAction: TextInputAction.next,
            errorMaxLines: 2,
            hintText: S.of(context).venmo_hint,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            // ),
            initialValue: requestModel.cashModel.venmoId ?? '',
            keyboardType: TextInputType.multiline,
            maxLines: 1,
            onSaved: (value) {
              widget.requestModel.cashModel.venmoId = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_general_text;
              } else {
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
            title: 'Venmo',
            value: RequestPaymentType.VENMO,
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

      case RequestPaymentType.VENMO:
        return RequestPaymentVenmo(widget.requestModel);
      case RequestPaymentType.ZELLEPAY:
        return RequestPaymentZellePay(widget.requestModel);
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
            color: Colors.black,
          ),
        ),
        CustomTextField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            setState(() {
              initialRequestDescription = value;
            });

            if (value != null && value.length > 5) {
              _debouncer.run(() {
                getCategoriesFromApi(value);
              });
            }

            updateExitWithConfirmationValue(context, 9, value);
          },
          focusNode: focusNodes[0],
          // onFieldSubmitted: (v) {
          //   FocusScope.of(context).requestFocus(focusNodes[1]);
          // },
          textInputAction: TextInputAction.next,
          maxLength: 500,
          errorMaxLines: 2,
          hintText: hintTextDesc,
          // decoration: InputDecoration(
          //   hintStyle: hintTextStyle,
          // ),
          initialValue: widget.requestModel.description,
          keyboardType: TextInputType.multiline,
          maxLines: 7,
          validator: (value) {
            if (value.isEmpty) {
              return S.of(context).validation_error_general_text;
            }
            if (profanityDetector.isProfaneString(value)) {
              return S.of(context).profanity_text_alert;
            }
            //widget.requestModel.description = value;
            initialRequestDescription = value;
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
                        widget.controller?.animateTo(
                          300,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() => {});
                      }),
                ],
              )
            ],
          )
        : Container();
  }

  List categories;
  List<CategoryModel> modelList = List();

  void updateInformation(List category) {
    setState(() => categories = category);
  }

  Future<void> getCategoriesFromApi(String query) async {
    try {
      var response = await http.post(
        "https://proxy.sevaexchange.com/" +
            "http://ai.api.sevaxapp.com/request_categories",
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "description": query,
        }),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> bodyMap = json.decode(response.body);
        List<String> categoriesList = bodyMap.containsKey('string_vec')
            ? List.castFrom(bodyMap['string_vec'])
            : [];
        if (categoriesList != null && categoriesList.length > 0) {
          getCategoryModels(categoriesList);
        }
      } else {
        return null;
      }
    } catch (exception) {
      log(exception.toString());
      return null;
    }
  }

  Future<void> getCategoryModels(List<String> categoriesList) async {
    for (int i = 0; i < categoriesList.length; i += 1) {
      CategoryModel categoryModel = await FirestoreManager.getCategoryForId(
        categoryID: categoriesList[i],
      );
      modelList.add(categoryModel);
    }
    updateInformation([S.of(context).suggested_categories, modelList]);
  }

  // Navigat to Category class and geting data from the class
  void moveToCategory() async {
    var category =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Category(
        selectedSubCategoriesids: selectedCategoryIds,
      );
    }));
//    var category = await ExtendedNavigator.ofRouter<RequestsRouter>()
//        .pushCategory(selectedSubCategoriesids: selectedCategoryIds);
    updateInformation(category);
    log(' poped selectedCategory  => ${category[0]} \n poped selectedSubCategories => ${category[1]} ');
  }

  //building list of selectedSubCategories
  List<Widget> _buildselectedSubCategories(List categories) {
    List<CategoryModel> subCategories = [];
    subCategories = categories[1];
    List<Widget> selectedSubCategories = [];
    selectedCategoryIds.clear();
    logger.i('poped selectedSubCategories => ${categories[1]} ');
    subCategories.forEach((item) {
      selectedCategoryIds.add(item.typeId);
      selectedSubCategories.add(
        Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 10),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text("${item.title_en.toString()}",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      );
    });
    return selectedSubCategories;
  }

  Widget TimeRequest(snapshot) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: widget.requestModel.isRecurring == true ||
                widget.requestModel.autoGenerated == true,
            child: EditRepeatWidgetWeb(
              requestModel: widget.requestModel,
              offerModel: widget.offer,
            ),
          ),
          SizedBox(height: 20),
          RequestDescriptionData("Ex: Local Food Bank has a shortage..."),
          SizedBox(height: 20),
          // Choose Category and Sub Category
          categoryWidget(),

          SizedBox(height: 20),
          isFromRequest(projectId: widget.projectId) &&
                  isAccessAvailable(timebankModel,
                      BlocProvider.of<AuthBloc>(context).user.sevaUserID) &&
                  widget.requestModel.requestMode ==
                      RequestMode.TIMEBANK_REQUEST
              ? addToProjectContainer(snapshot, requestModel)
              : Container(),
          SizedBox(height: 20),
          Text(
            S.of(context).max_credits,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomTextField(
                  focusNode: focusNodes[1],
                  // onFieldSubmitted: (v) {
                  //   FocusScope.of(context).requestFocus(focusNodes[2]);
                  // },
                  initialValue: widget.requestModel.maxCredits.toString(),
                  onChanged: (v) {
                    updateExitWithConfirmationValue(context, 10, v);
                    if (v.isNotEmpty && int.parse(v) >= 0) {
                      //widget.requestModel.maxCredits = int.parse(v);
                      tempCredits = int.parse(v);
                    }
                  },
                  hintText: S.of(context).max_credit_hint,
                  // decoration: InputDecoration(
                  //   hintStyle: hintTextStyle,
                  //   // labelText: 'No. of volunteers',
                  // ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return S.of(context).enter_max_credits;
                    } else if (int.parse(value) < 0) {
                      return S.of(context).enter_max_credits;
                    } else if (int.parse(value) == 0) {
                      return S.of(context).enter_max_credits;
                    } else {
                      //requestModel.maxCredits = int.parse(value);
                      tempCredits = int.parse(value);
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            focusNode: focusNodes[2],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).unfocus();
            // },
            initialValue: widget.requestModel.numberOfApprovals.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 11, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                tempNoOfVolunteers = int.parse(v);
              }
            },
            hintText: S.of(context).number_of_volunteers,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            //   // labelText: 'No. of volunteers',
            // ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return S.of(context).validation_error_volunteer_count;
              } else if (int.parse(value) < 0) {
                return S.of(context).validation_error_volunteer_count_negative;
              } else if (int.parse(value) == 0) {
                return S.of(context).validation_error_volunteer_count_zero;
              } else {
                //widget.requestModel.numberOfApprovals = int.parse(value);
                tempNoOfVolunteers = int.parse(value);
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
          LocationPickerWidget(
            selectedAddress: selectedAddress,
            location: location,
            onChanged: (LocationDataModel dataModel) {
              setState(() {
                location = dataModel.geoPoint;
                this.selectedAddress = dataModel.location;
              });
            },
          )
        ]);
  }

  Widget categoryWidget() {
    return InkWell(
      child: Column(
        children: [
          Row(
            children: [
              categories == null
                  ? Text(
                      "Choose Category and Sub Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      "${categories[0]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Europa',
                        color: Colors.black,
                      ),
                    ),
              Spacer(),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
              ),
              // Container(
              //   height: 25,
              //   width: 25,
              //   decoration: BoxDecoration(
              //       color: Theme.of(context).primaryColor,
              //       borderRadius: BorderRadius.circular(100)),
              //   child: Icon(
              //     Icons.arrow_drop_down_outlined,
              //     color: Colors.white,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 20),
          categories != null
              ? Wrap(
                  alignment: WrapAlignment.start,
                  children: _buildselectedSubCategories(categories),
                )
              : Container(),
        ],
      ),
      onTap: () => moveToCategory(),
    );
  }

  Widget CashRequest(snapshot) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            S.of(context).request_target_donation,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          CustomTextField(
            focusNode: focusNodes[5],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).unfocus();
            // },
            initialValue: widget.requestModel.cashModel.targetAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 12, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.targetAmount = int.parse(v);
                setState(() {});
              }
            },
            hintText: S.of(context).request_target_donation_hint,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            //   // labelText: 'No. of volunteers',
            // ),
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
              color: Colors.black,
            ),
          ),
          CustomTextField(
            focusNode: focusNodes[6],
            // onFieldSubmitted: (v) {
            //   FocusScope.of(context).unfocus();
            // },
            initialValue: widget.requestModel.cashModel.minAmount.toString(),
            onChanged: (v) {
              updateExitWithConfirmationValue(context, 13, v);
              if (v.isNotEmpty && int.parse(v) >= 0) {
                widget.requestModel.cashModel.minAmount = int.parse(v);
                setState(() {});
              }
            },
            hintText: S.of(context).request_min_donation_hint,
            // decoration: InputDecoration(
            //   hintStyle: hintTextStyle,
            //   // labelText: 'No. of volunteers',
            // ),
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
          // Choose Category and Sub Category
          categoryWidget(),
          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
                  requestModel,
                )
              : Container(),
          SizedBox(height: 20),
          RequestPaymentDescriptionData(widget.requestModel),
        ]);
  }

  Widget GoodsRequest(snapshot) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          RequestDescriptionData(S.of(context).request_description_hint_goods),
          SizedBox(height: 20),
          // Choose Category and Sub Category
          categoryWidget(),

          SizedBox(height: 20),
          isFromRequest(
            projectId: widget.projectId,
          )
              ? addToProjectContainer(
                  snapshot,
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
        if (widget.projectModel.mode == ProjectMode.TIMEBANK_PROJECT) {
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

    if (_formKey.currentState.validate()) {
      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        //widget.requestModel.recurringDays =
        EditRepeatWidgetWebState.recurringDays =
            EditRepeatWidgetWebState.getRecurringdays();

        //end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
        //end.on = end.endType == "on"
        //    ? EditRepeatWidgetWebState.selectedDate.millisecondsSinceEpoch
        //    : null;
        //end.after = (end.endType == "after"
        //    ? EditRepeatWidgetWebState.after
        //    : 1);
        //widget.requestModel.end = end;
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

          // onBalanceCheckResult = await SevaCreditLimitManager
          //     .hasSufficientCreditsIncludingRecurring(
          //   credits: widget.requestModel.numberOfHours.toDouble(),
          //   userId: BlocProvider.of<AuthBloc>(context).user.sevaUserID,
          //   isRecurring: widget.requestModel.isRecurring,
          //   recurrences: recurrences,
          // );

          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: BlocProvider.of<AuthBloc>(context).user.email,
            userId: BlocProvider.of<AuthBloc>(context).user.sevaUserID,
            credits: widget.requestModel.isRecurring
                ? widget.requestModel.numberOfHours.toDouble() * recurrences
                : widget.requestModel.numberOfHours.toDouble(),
            associatedCommunity:
                BlocProvider.of<AuthBloc>(context).user.sevaUserID,
          );
        } else {
          // onBalanceCheckResult = await SevaCreditLimitManager
          //     .hasSufficientCreditsIncludingRecurring(
          //   credits: widget.requestModel.numberOfHours.toDouble(),
          //   userId: BlocProvider.of<AuthBloc>(context).user.sevaUserID,
          //   isRecurring: widget.requestModel.isRecurring,
          //   recurrences: 0,
          // );

          onBalanceCheckResult =
              await SevaCreditLimitManager.hasSufficientCredits(
            email: BlocProvider.of<AuthBloc>(context).user.email,
            userId: BlocProvider.of<AuthBloc>(context).user.sevaUserID,
            credits: widget.requestModel.isRecurring
                ? widget.requestModel.numberOfHours.toDouble() * 0
                : widget.requestModel.numberOfHours.toDouble(),
            associatedCommunity:
                BlocProvider.of<AuthBloc>(context).user.currentCommunity,
          );
        }

        if (!onBalanceCheckResult) {
          showInsufficientBalance();
          return;
        }
      }

      if (OfferDurationWidgetWebState.starttimestamp ==
          OfferDurationWidgetWebState.endtimestamp) {
        showDialogForTitle(
            dialogTitle:
                S.of(context).validation_error_same_start_date_end_date);
        return;
      }

      if (OfferDurationWidgetWebState.starttimestamp == 0 ||
          OfferDurationWidgetWebState.endtimestamp == 0) {
        showDialogForTitle(dialogTitle: S.of(context).validation_error_no_date);
        return;
      }

      if (OfferDurationWidgetWebState.starttimestamp >
          OfferDurationWidgetWebState.endtimestamp) {
        showDialogForTitle(
            dialogTitle: S.of(context).validation_error_end_date_greater);
        return;
      }

      //comparing the recurring days List

      Function eq = const ListEquality().equals;
      bool recurrinDaysListsMatch = eq(widget.requestModel.recurringDays,
          EditRepeatWidgetWebState.recurringDays);

      String tempSelectedEndType =
          EditRepeatWidgetWebState.endType == 0 ? 'on' : 'after';

      if (widget.requestModel.isRecurring == true ||
          widget.requestModel.autoGenerated == true) {
        if (widget.requestModel.title != initialRequestTitle ||
            startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetWebState.starttimestamp ||
            endDate.millisecondsSinceEpoch !=
                OfferDurationWidgetWebState.endtimestamp ||
            widget.requestModel.description != initialRequestDescription ||
            tempCredits != widget.requestModel.maxCredits ||
            tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
            location != widget.requestModel.location) {
          //setState(() {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.location = location;
          widget.requestModel.address = selectedAddress;
          widget.requestModel.categories = selectedCategoryIds.toList();

          widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
          widget.requestModel.maxCredits = tempCredits;

          startDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetWebState.starttimestamp
              ? widget.requestModel.requestStart =
                  OfferDurationWidgetWebState.starttimestamp
              : null;

          endDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetWebState.endtimestamp
              ? widget.requestModel.requestEnd =
                  OfferDurationWidgetWebState.endtimestamp
              : null;
          //});

          return showDialog(
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
                        ),
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
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(viewContext);
                        linearProgressForCreatingRequest();
                        await updateRequest(requestModel: widget.requestModel);
                        await RequestManager.updateRecurrenceRequestsFrontEnd(
                          updatedRequestModel: widget.requestModel,
//                          communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//                          timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
                        );

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
        }

        if (tempSelectedEndType != widget.requestModel.end.endType ||
            widget.requestModel.end.after !=
                int.parse(EditRepeatWidgetWebState.after) ||
            widget.requestModel.end.on !=
                EditRepeatWidgetWebState.selectedDate.millisecondsSinceEpoch ||
            recurrinDaysListsMatch == false) {
          //setState(() {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.isRecurring =
              EditRepeatWidgetWebState.isRecurring;
          widget.requestModel.end.after =
              int.parse(EditRepeatWidgetWebState.after);
          widget.requestModel.end.endType = tempSelectedEndType;
          widget.requestModel.recurringDays =
              EditRepeatWidgetWebState.recurringDays;
          widget.requestModel.end.on =
              EditRepeatWidgetWebState.selectedDate.millisecondsSinceEpoch;
          //});

          linearProgressForCreatingRequest();
          await updateRequest(requestModel: widget.requestModel);
          if (updateProject) {
            FirestoreManager.updateProjectPendingRequest(
                requestId: widget.requestModel.id,
                projectId: widget.requestModel.projectId);
          }
          await RequestManager.updateRecurrenceRequestsFrontEnd(
            updatedRequestModel: widget.requestModel,
//                           communityId: SevaCore.of(context).loggedInUser.currentCommunity,
//                           timebankId: SevaCore.of(context).loggedInUser.currentTimebank,
          );
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        } else {
          ExtendedNavigator.of(context).pop();
        }
      } else if (widget.requestModel.isRecurring == false &&
          widget.requestModel.autoGenerated == false) {
        if (widget.requestModel.title != initialRequestTitle ||
            startDate.millisecondsSinceEpoch !=
                OfferDurationWidgetWebState.starttimestamp ||
            endDate.millisecondsSinceEpoch !=
                OfferDurationWidgetWebState.endtimestamp ||
            widget.requestModel.description != initialRequestDescription ||
            tempCredits != widget.requestModel.maxCredits ||
            tempNoOfVolunteers != widget.requestModel.numberOfApprovals ||
            location != widget.requestModel.location) {
          widget.requestModel.title = initialRequestTitle;
          widget.requestModel.description = initialRequestDescription;
          widget.requestModel.location = location;
          widget.requestModel.address = selectedAddress;
          widget.requestModel.categories = selectedCategoryIds.toList();
          startDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetWebState.starttimestamp
              ? widget.requestModel.requestStart =
                  OfferDurationWidgetWebState.starttimestamp
              : null;
          endDate.millisecondsSinceEpoch !=
                  OfferDurationWidgetWebState.endtimestamp
              ? widget.requestModel.requestEnd =
                  OfferDurationWidgetWebState.endtimestamp
              : null;
          widget.requestModel.numberOfApprovals = tempNoOfVolunteers;
          widget.requestModel.maxCredits = tempCredits;

          linearProgressForCreatingRequest();
          await updateRequest(requestModel: widget.requestModel);
          if (updateProject) {
            FirestoreManager.updateProjectPendingRequest(
                requestId: widget.requestModel.id,
                projectId: widget.requestModel.projectId);
          }
          Navigator.pop(context);
          Navigator.pop(dialogContext);
        } else {
          ExtendedNavigator.of(context).pop();
        }
      }
    }
  }

  Future _getLocation() async {
    String address = await LocationUtility.reverseGeoCodeLocationFromLatLng(
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

  String getTimeInFormat(int timeStamp) {
    return DateFormat(
            'EEEEEEE, MMMM dd yyyy', Locale(getLangTag()).toLanguageTag())
        .format(
      getDateTimeAccToUserTimezone(
          dateTime: DateTime.fromMillisecondsSinceEpoch(timeStamp),
          timezoneAbb: BlocProvider.of<AuthBloc>(context).user.timezone),
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
//      var userSevaUserId = BlocProvider.of<AuthBloc>(context).user.sevaUserID;
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
              S.of(context).select_project,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            content: Form(
              child: Container(
                height: 300,
                child: CustomScrollWithKeyboard(
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
        "timebankproject":
            widget.projectModelList[i].mode == ProjectMode.TIMEBANK_PROJECT
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

  GoodsDynamicSelection({
    this.goodsbefore,
    @required this.onSelectedGoods,
    this.automaticallyImplyLeading = true,
  });
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
    // Firestore.instance
    //     .collection('donationCategories')
    //     .getDocuments()
    //     .then((QuerySnapshot querySnapshot) {
    //   querySnapshot.documents.forEach((DocumentSnapshot data) {
    //     // suggestionText.add(data['name']);
    //     // suggestionID.add(data.documentID);
    //     goods[data.documentID] = data['goodTitle'];
    //
    //     // ids[data['name']] = data.documentID;
    //   });
    //   setState(() {
    //     isDataLoaded = true;
    //   });
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return ConstrainedBox(
    //     constraints: BoxConstraints(
    //         maxHeight: MediaQuery.of(context).size.height * 0.25),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: <Widget>[
    //         SizedBox(height: 8),
    //         //TODOSUGGESTION
    //         TypeAheadField<SuggestedItem>(
    //             suggestionsBoxDecoration: SuggestionsBoxDecoration(
    //               borderRadius: BorderRadius.circular(8),
    //             ),
    //             errorBuilder: (context, err) {
    //               return Text(S.of(context).error_occured);
    //             },
    //             hideOnError: true,
    //             textFieldConfiguration: TextFieldConfiguration(
    //               controller: _textEditingController,
    //               decoration: InputDecoration(
    //                 hintText: S.of(context).search,
    //                 filled: true,
    //                 fillColor: Colors.grey[300],
    //                 focusedBorder: OutlineInputBorder(
    //                   borderSide: BorderSide(color: Colors.white),
    //                   borderRadius: BorderRadius.circular(25.7),
    //                 ),
    //                 enabledBorder: UnderlineInputBorder(
    //                   borderSide: BorderSide(color: Colors.white),
    //                   borderRadius: BorderRadius.circular(25.7),
    //                 ),
    //                 contentPadding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
    //                 prefixIcon: Icon(
    //                   Icons.search,
    //                   color: Colors.grey,
    //                 ),
    //                 suffixIcon: InkWell(
    //                   splashColor: Colors.transparent,
    //                   child: Icon(
    //                     Icons.clear,
    //                     color: Colors.grey,
    //                   ),
    //                   onTap: () {
    //                     _textEditingController.clear();
    //                     controller.close();
    //                   },
    //                 ),
    //               ),
    //             ),
    //             suggestionsBoxController: controller,
    //             suggestionsCallback: (pattern) async {
    //               List<SuggestedItem> dataCopy = [];
    //               goods.forEach(
    //                 (k, v) => dataCopy.add(SuggestedItem()
    //                   ..suggestionMode = SuggestionMode.FROM_DB
    //                   ..suggesttionTitle = v),
    //               );
    //               dataCopy.retainWhere((s) => s.suggesttionTitle
    //                   .toLowerCase()
    //                   .contains(pattern.toLowerCase()));
    //
    //               if (pattern.length > 2 &&
    //                   !dataCopy.contains(
    //                       SuggestedItem()..suggesttionTitle = pattern)) {
    //                 var spellCheckResult =
    //                     await SpellCheckManager.evaluateSpellingFor(pattern,
    //                         language: 'en');
    //                 if (spellCheckResult.hasErros) {
    //                   dataCopy.add(SuggestedItem()
    //                     ..suggestionMode = SuggestionMode.USER_DEFINED
    //                     ..suggesttionTitle = pattern);
    //                 } else if (spellCheckResult.correctSpelling != pattern) {
    //                   dataCopy.add(SuggestedItem()
    //                     ..suggestionMode = SuggestionMode.SUGGESTED
    //                     ..suggesttionTitle = spellCheckResult.correctSpelling);
    //
    //                   dataCopy.add(SuggestedItem()
    //                     ..suggestionMode = SuggestionMode.USER_DEFINED
    //                     ..suggesttionTitle = pattern);
    //                 } else {
    //                   dataCopy.add(SuggestedItem()
    //                     ..suggestionMode = SuggestionMode.USER_DEFINED
    //                     ..suggesttionTitle = pattern);
    //                 }
    //               }
    //               return await Future.value(dataCopy);
    //             },
    //             itemBuilder: (context, suggestedItem) {
    //               switch (suggestedItem.suggestionMode) {
    //                 case SuggestionMode.FROM_DB:
    //                   return Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Text(
    //                       suggestedItem.suggesttionTitle,
    //                       style: TextStyle(
    //                         fontSize: 16,
    //                       ),
    //                     ),
    //                   );
    //
    //                 case SuggestionMode.SUGGESTED:
    //                   if (ProfanityDetector()
    //                       .isProfaneString(suggestedItem.suggesttionTitle)) {
    //                     return ProfanityDetector.getProanityAdvisory(
    //                       suggestion: suggestedItem.suggesttionTitle,
    //                       suggestionMode: SuggestionMode.SUGGESTED,
    //                       context: context,
    //                     );
    //                   }
    //                   return searchUserDefinedEntity(
    //                     keyword: suggestedItem.suggesttionTitle,
    //                     language: 'en',
    //                     suggestionMode: suggestedItem.suggestionMode,
    //                     showLoader: true,
    //                   );
    //
    //                 case SuggestionMode.USER_DEFINED:
    //                   if (ProfanityDetector()
    //                       .isProfaneString(suggestedItem.suggesttionTitle)) {
    //                     return ProfanityDetector.getProanityAdvisory(
    //                       suggestion: suggestedItem.suggesttionTitle,
    //                       suggestionMode: SuggestionMode.USER_DEFINED,
    //                       context: context,
    //                     );
    //                   }
    //
    //                   return searchUserDefinedEntity(
    //                     keyword: suggestedItem.suggesttionTitle,
    //                     language: 'en',
    //                     suggestionMode: suggestedItem.suggestionMode,
    //                     showLoader: false,
    //                   );
    //
    //                 default:
    //                   return Container();
    //               }
    //             },
    //             noItemsFoundBuilder: (context) {
    //               return searchUserDefinedEntity(
    //                 keyword: _textEditingController.text,
    //                 language: 'en',
    //                 showLoader: false,
    //               );
    //             },
    //             onSuggestionSelected: (SuggestedItem suggestion) {
    //               if (ProfanityDetector()
    //                   .isProfaneString(suggestion.suggesttionTitle)) {
    //                 return;
    //               }
    //
    //               switch (suggestion.suggestionMode) {
    //                 case SuggestionMode.SUGGESTED:
    //                   var newGoodId = Uuid().generateV4();
    //                   addGoodsToDb(
    //                     goodsId: newGoodId,
    //                     goodsLanguage: 'en',
    //                     goodsTitle: suggestion.suggesttionTitle,
    //                   );
    //                   goods[newGoodId] = suggestion.suggesttionTitle;
    //                   break;
    //
    //                 case SuggestionMode.USER_DEFINED:
    //                   var goodId = Uuid().generateV4();
    //                   addGoodsToDb(
    //                     goodsId: goodId,
    //                     goodsLanguage: 'en',
    //                     goodsTitle: suggestion.suggesttionTitle,
    //                   );
    //                   goods[goodId] = suggestion.suggesttionTitle;
    //                   break;
    //
    //                 case SuggestionMode.FROM_DB:
    //                   break;
    //               }
    //               // controller.close();
    //
    //               _textEditingController.clear();
    //               if (!_selectedGoods.containsValue(suggestion)) {
    //                 controller.close();
    //                 String id = goods.keys.firstWhere(
    //                   (k) => goods[k] == suggestion.suggesttionTitle,
    //                 );
    //                 _selectedGoods[id] = suggestion.suggesttionTitle;
    //                 widget.onSelectedGoods(_selectedGoods);
    //                 setState(() {});
    //               }
    //             }),
    //
    //         SizedBox(height: 20),
    //         !isDataLoaded
    //             ? LoadingIndicator()
    //             : Expanded(
    //                 child: ListView(
    //                   shrinkWrap: true,
    //                   scrollDirection: Axis.vertical,
    //                   children: <Widget>[
    //                     Wrap(
    //                       runSpacing: 5.0,
    //                       spacing: 5.0,
    //                       children: _selectedGoods.values
    //                           .toList()
    //                           .map(
    //                             (value) => value == null
    //                                 ? Container()
    //                                 : CustomChip(
    //                                     title: value,
    //                                     onDelete: () {
    //                                       String id =
    //                                           _selectedGoods.keys.firstWhere(
    //                                         (k) {
    //                                           return _selectedGoods[k] == value;
    //                                         },
    //                                       );
    //                                       _selectedGoods.remove(id);
    //                                       widget
    //                                           .onSelectedGoods(_selectedGoods);
    //                                       setState(() {});
    //                                     },
    //                                   ),
    //                           )
    //                           .toList(),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //         //   Spacer(),
    //       ],
    //     ));
    return FutureBuilder<Map<String, String>>(
        future: getGoodsFuture(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          goods = snapshot.data;
          return Container(
              //constraints: BoxConstraints(
              //  maxHeight: MediaQuery.of(context).size.height * 0.05,
              //  minHeight: MediaQuery.of(context).size.height * 0.12,
              //),
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(height: 8),
              //TODOSUGGESTION
              TypeAheadField<SuggestedItem>(
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                      //minHeight: MediaQuery.of(context).size.height * 0.12,
                    ),
                  ),
                  errorBuilder: (context, err) {
                    return Text(S.of(context).error_occured);
                  },
                  hideOnError: false,
                  textFieldConfiguration: TextFieldConfiguration(
                    onChanged: (_) {
                      controller.open();
                      controller.resize();
                    },
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
                      contentPadding:
                          EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 5.0),
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
                        onFocusChange: (focused) {
                          // logger.i(focused.toString() +
                          //     " <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< onFocusChange >>");
                        },
                      ),
                    ),
                  ),
                  suggestionsBoxController: controller,
                  suggestionsCallback: (pattern) async {
                    logger.i(
                      ">>>>>>>>>><<<<<<<<<<<<<<<<<>>>>>>|||" +
                          goods.length.toString(),
                    );
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
                              language: BlocProvider.of<AuthBloc>(context)
                                      .user
                                      .language ??
                                  'en');
                      if (spellCheckResult.hasErros) {
                        dataCopy.add(SuggestedItem()
                          ..suggestionMode = SuggestionMode.USER_DEFINED
                          ..suggesttionTitle = pattern);
                      } else if (spellCheckResult.correctSpelling != pattern) {
                        dataCopy.add(SuggestedItem()
                          ..suggestionMode = SuggestionMode.SUGGESTED
                          ..suggesttionTitle =
                              spellCheckResult.correctSpelling);

                        dataCopy.add(SuggestedItem()
                          ..suggestionMode = SuggestionMode.USER_DEFINED
                          ..suggesttionTitle = pattern);
                      } else {
                        dataCopy.add(SuggestedItem()
                          ..suggestionMode = SuggestionMode.USER_DEFINED
                          ..suggesttionTitle = pattern);
                      }
                    }

                    return dataCopy;
                    // return Future.value(dataCopy);
                  },
                  itemBuilder: (context, suggestedItem) {
                    switch (suggestedItem.suggestionMode) {
                      case SuggestionMode.FROM_DB:
                        return ListTile(
                          title: Text(
                            suggestedItem.suggesttionTitle,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      // return Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child:
                      // Text(
                      //   suggestedItem.suggesttionTitle,
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //   ),
                      // ),
                      // );

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

                        // return searchUserDefinedEntity(
                        //   keyword: suggestedItem.suggesttionTitle,
                        //   language: 'en',
                        //   suggestionMode: suggestedItem.suggestionMode,
                        //   showLoader: false,
                        // );
                        return
                            //(showLoaderUserDefined ?? false)  ?
                            getSuggestionLayout(
                          suggestion: _textEditingController.text,
                          suggestionMode: SuggestionMode.USER_DEFINED,
                        );

                      default:
                        return Container();
                    }
                  },
                  noItemsFoundBuilder: (context) {
                    // return searchUserDefinedEntity(
                    //   keyword: _textEditingController.text,
                    //   language: 'en',
                    //   showLoader: false,
                    // );
                    return getSuggestionLayout(
                      suggestion: _textEditingController.text,
                      suggestionMode: SuggestionMode.USER_DEFINED,
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

                        if (!_selectedGoods
                            .containsValue(suggestion.suggesttionTitle)) {
                          controller.close();
                          String id = goods.keys.firstWhere(
                            (k) => goods[k] == suggestion.suggesttionTitle,
                          );
                          _selectedGoods[id] = suggestion.suggesttionTitle;
                          widget.onSelectedGoods(_selectedGoods);
                          setState(() {});
                        }
                        break;

                      case SuggestionMode.USER_DEFINED:
                        var goodId = Uuid().generateV4();
                        addGoodsToDb(
                          goodsId: goodId,
                          goodsLanguage: 'en',
                          goodsTitle: _textEditingController.text,
                        );
                        goods[goodId] = _textEditingController.text;

                        if (!_selectedGoods
                            .containsValue(_textEditingController.text)) {
                          controller.close();
                          String id = goods.keys.firstWhere(
                            (k) => goods[k] == _textEditingController.text,
                          );
                          _selectedGoods[id] = _textEditingController.text;
                          widget.onSelectedGoods(_selectedGoods);
                          setState(() {});
                        }

                        break;

                      case SuggestionMode.FROM_DB:
                        if (!_selectedGoods
                            .containsValue(suggestion.suggesttionTitle)) {
                          controller.close();
                          String id = goods.keys.firstWhere(
                            (k) => goods[k] == suggestion.suggesttionTitle,
                          );
                          _selectedGoods[id] = suggestion.suggesttionTitle;
                          widget.onSelectedGoods(_selectedGoods);
                          setState(() {});
                        }
                        break;
                    }

                    _textEditingController.clear();
                  }),
              SizedBox(height: 20),
              //Expanded(
              // child: ListView(
              //  shrinkWrap: true,
              // scrollDirection: Axis.vertical,
              // children: <Widget>[
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
                                String id = _selectedGoods.keys.firstWhere(
                                  (k) {
                                    return _selectedGoods[k] == value;
                                  },
                                );
                                _selectedGoods.remove(id);
                                widget.onSelectedGoods(_selectedGoods);
                                setState(() {});
                              },
                            ),
                    )
                    .toList(),
              ),
              //],
              // ),
              // ),
              //   Spacer(),
            ],
          ));
        });
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
                            text: S.of(context).add + ' ',
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
                          : S.of(context).you_entered,
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
