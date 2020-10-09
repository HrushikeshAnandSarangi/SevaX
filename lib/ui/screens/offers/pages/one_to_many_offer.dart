import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/one_to_many_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';

class OneToManyOffer extends StatefulWidget {
  final OfferModel offerModel;
  final String timebankId;

  const OneToManyOffer({
    Key key,
    this.offerModel,
    this.timebankId,
  }) : super(key: key);
  @override
  _OneToManyOfferState createState() => _OneToManyOfferState();
}

class _OneToManyOfferState extends State<OneToManyOffer> {
  final OneToManyOfferBloc _bloc = OneToManyOfferBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  End end = End();
  String selectedAddress;
  String title = '';
  CustomLocation customLocation;
  bool closePage = true;

  List<FocusNode> focusNodes;

  @override
  void initState() {
    focusNodes = List.generate(5, (_) => FocusNode());
    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel);
    }
    super.initState();
    _bloc.classSizeError.listen((error) {
      if (error != null) {
        log(error);
        errorDialog(
          context: context,
          error: getValidationError(context, error),
        );
      }
    });
  }

  @override
  void dispose() {
    focusNodes.forEach((node) => node.dispose());
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext mcontext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.offerModel != null
          ? AppBar(
              title: Text(
                S.of(context).edit,
                style: TextStyle(fontSize: 18),
              ),
            )
          : null,
      body: Builder(builder: (context) {
        return SafeArea(
          child: StreamBuilder<Status>(
            stream: _bloc.status,
            builder: (_, status) {
              if (status.data == Status.COMPLETE && closePage) {
                closePage = false;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.of(mcontext).canPop())
                    Navigator.of(mcontext).pop();
                });
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
                          StreamBuilder<String>(
                            stream: _bloc.title,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[0],
                                nextNode: focusNodes[1],
                                formatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter(
                                      RegExp("[a-zA-Z0-9_ ]*"))
                                ],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).title}*",
                                onChanged: _bloc.onTitleChanged,
                                hint: S.of(context).one_to_many_offer_hint,
                                maxLength: null,
                                error:
                                    getValidationError(context, snapshot.error),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          OfferDurationWidget(
                            title: S.of(context).offer_duration,
                            startTime: widget.offerModel != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    widget.offerModel.groupOfferDataModel
                                        .startDate,
                                  )
                                : null,
                            endTime: widget.offerModel != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    widget
                                        .offerModel.groupOfferDataModel.endDate,
                                  )
                                : null,
                          ),
                          SizedBox(height: 20),
                          widget.offerModel == null
                              ? RepeatWidget()
                              : Visibility(
                                  visible: widget.offerModel.isRecurring ==
                                          true ||
                                      widget.offerModel.autoGenerated == true,
                                  child: Container(
                                    child: EditRepeatWidget(
                                        requestModel: null,
                                        offerModel: widget.offerModel),
                                  ),
                                ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.preparationHours,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[1],
                                nextNode: focusNodes[2],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).offer_prep_hours} *",
                                onChanged: _bloc.onPreparationHoursChanged,
                                hint: S.of(context).offer_prep_hours_required,
                                error:
                                    getValidationError(context, snapshot.error),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classHours,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[2],
                                nextNode: focusNodes[3],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading:
                                    "${S.of(context).offer_number_class_hours} *",
                                onChanged: _bloc.onClassHoursChanged,
                                hint: S
                                    .of(context)
                                    .offer_number_class_hours_required,
                                error:
                                    getValidationError(context, snapshot.error),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classSize,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[3],
                                nextNode: focusNodes[4],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).offer_size_class} *",
                                onChanged: _bloc.onClassSizeChanged,
                                hint: S.of(context).offer_enter_participants,
                                error:
                                    getValidationError(context, snapshot.error),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classDescription,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[4],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: S.of(context).offer_class_description,
                                onChanged: _bloc.onclassDescriptionChanged,
                                hint: S.of(context).offer_description_error,
                                maxLength: 500,
                                error:
                                    getValidationError(context, snapshot.error),
                                keyboardType: TextInputType.multiline,
                              );
                            },
                          ),
                          SizedBox(height: 40),
                          StreamBuilder<CustomLocation>(
                              stream: _bloc.location,
                              builder: (_, snapshot) {
                                return LocationPickerWidget(
                                  location: snapshot.data?.location,
                                  selectedAddress: snapshot.data?.address,
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
                          SizedBox(height: 40),
                          TransactionsMatrixCheck(
                            upgradeDetails: AppConfig
                                .upgradePlanBannerModel.onetomany_offers,
                            transaction_matrix_type: "onetomany_offers",
                            child: RaisedButton(
                              onPressed: status.data == Status.LOADING
                                  ? () {}
                                  : () async {
                                      var connResult = await Connectivity()
                                          .checkConnectivity();
                                      if (connResult ==
                                          ConnectivityResult.none) {
                                        _scaffoldKey.currentState.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                S.of(context).check_internet),
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
                                      FocusScope.of(context).unfocus();
                                      if (OfferDurationWidgetState.starttimestamp != 0) {
                                        _bloc.startTime =
                                            OfferDurationWidgetState
                                                .starttimestamp;
                                        _bloc.endTime = OfferDurationWidgetState
                                            .endtimestamp;
                                        if (widget.offerModel == null) {
                                          await createOneToManyOfferFunc();
                                        } else {
                                          if (widget.offerModel.autoGenerated ||
                                              widget.offerModel.isRecurring) {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext viewContext) {
                                                  return WillPopScope(
                                                      onWillPop: () {},
                                                      child: AlertDialog(
                                                          title: Text(
                                                              "This is a repeating event"),
                                                          actions: [
                                                            FlatButton(
                                                              child: Text(
                                                                "Edit this event only",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .red,
                                                                    fontFamily:
                                                                        'Europa'),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    viewContext);
                                                                _bloc.autoGenerated = widget
                                                                    .offerModel
                                                                    .autoGenerated;
                                                                _bloc.isRecurring = widget
                                                                    .offerModel
                                                                    .isRecurring;

                                                                await updateOneToManyOfferFunc(
                                                                    0);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            FlatButton(
                                                              child: Text(
                                                                "Edit subsequent events",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .red,
                                                                    fontFamily:
                                                                        'Europa'),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    viewContext);
                                                                _bloc.autoGenerated = widget
                                                                    .offerModel
                                                                    .autoGenerated;
                                                                _bloc.isRecurring = widget
                                                                    .offerModel
                                                                    .isRecurring;

                                                                await updateOneToManyOfferFunc(
                                                                    1);

                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            FlatButton(
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .red,
                                                                    fontFamily:
                                                                        'Europa'),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    viewContext);
                                                              },
                                                            ),
                                                          ]));
                                                });
                                          } else {
                                            updateOneToManyOfferFunc(2);
                                          }
                                        }
                                      } else {
                                        errorDialog(
                                          context: context,
                                          error: S
                                              .of(context)
                                              .offer_start_end_date,
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
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void createOneToManyOfferFunc() async {
    _bloc.autoGenerated = false;
    _bloc.isRecurring = RepeatWidgetState.isRecurring;
    if (_bloc.isRecurring) {
      _bloc.recurringDays = RepeatWidgetState.getRecurringdays();
      _bloc.occurenceCount = 1;
      end.endType = RepeatWidgetState.endType == 0 ? "on" : "after";
      end.on = end.endType == "on"
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after =
          (end.endType == "after" ? int.parse(RepeatWidgetState.after) : null);
      _bloc.end = end;
    }

    if (_bloc.isRecurring) {
      if (_bloc.recurringDays.length == 0) {
        errorDialog(context: context, error: S.of(context).recurringDays_err);
        return;
      }
    }

    if (SevaCore.of(context).loggedInUser.calendarId != null) {
      _bloc.allowedCalenderEvent = true;

      await _bloc.createOneToManyOffer(
          user: SevaCore.of(context).loggedInUser,
          timebankId: widget.timebankId);
    } else {
      _bloc.allowedCalenderEvent = true;

      await _bloc.createOneToManyOffer(
          user: SevaCore.of(context).loggedInUser,
          timebankId: widget.timebankId);
      if (_bloc.offerCreatedBool){
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) {
                      return AddToCalendar(
                          isOfferRequest: null,
                          offer: null,
                          requestModel: null,
                          userModel: null,
                          eventsIdsArr: _bloc.offerIds);
                  },
              ),
          );
      }
    }
  }

  void updateOneToManyOfferFunc(int editType) async {
    if (_bloc.isRecurring || _bloc.autoGenerated) {
      _bloc.recurringDays = EditRepeatWidgetState.getRecurringdays();
      _bloc.occurenceCount = widget.offerModel.occurenceCount;
      end.endType = EditRepeatWidgetState.endType == 0 ? "on" : "after";
      end.on = end.endType == "on"
          ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null;
      end.after = (end.endType == "after"
          ? int.parse(EditRepeatWidgetState.after)
          : null);
      _bloc.end = end;
    }

    if (_bloc.isRecurring || _bloc.autoGenerated) {
      if (_bloc.recurringDays.length == 0) {
        errorDialog(context: context, error: S.of(context).recurringDays_err);
        return;
      }
    }

    _bloc.updateOneToManyOffer(widget.offerModel, editType);
  }
}
