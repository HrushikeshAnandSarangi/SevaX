import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/one_to_many_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';

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
  CustomLocation customLocation;
  bool closePage = true;

  List<FocusNode> focusNodes;

  @override
  void initState() {
    focusNodes = List.generate(5, (_) => FocusNode());
    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel);
      print("${widget.offerModel}");
    }
    super.initState();
    _bloc.classSizeError.listen((error) {
      if (error != null) {
        log(error);
        errorDialog(
          context: context,
          error: AppLocalizations.of(context)
              .translate('validation_errors', error),
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
                AppLocalizations.of(context).translate('create_offer', 'edit'),
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
                  print("nav stat ${Navigator.of(mcontext).canPop()}");
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
                              ? AppLocalizations.of(context)
                                  .translate('create_offer', 'creating')
                              : AppLocalizations.of(context)
                                  .translate('create_offer', 'updating'),
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
                              ? AppLocalizations.of(context)
                                  .translate('create_offer', 'error_creating')
                              : AppLocalizations.of(context)
                                  .translate('create_offer', 'error_updating'),
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
                              print(snapshot.data);
                              return CustomTextField(
                                currentNode: focusNodes[0],
                                nextNode: focusNodes[1],
                                formatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter(
                                      RegExp("[a-zA-Z0-9_ ]*"))
                                ],
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'title_title')}*",
                                onChanged: _bloc.onTitleChanged,
                                hint: AppLocalizations.of(context)
                                    .translate('create_offer', 'tutor'),
                                maxLength: null,
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          OfferDurationWidget(
                            title: AppLocalizations.of(context)
                                .translate('create_offer', 'offer_duration'),
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
                          RepeatWidget(),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.preparationHours,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[1],
                                nextNode: focusNodes[2],
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'prep_hours')} *",
                                onChanged: _bloc.onPreparationHoursChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'prep_hours_required'),
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                                textInputType: TextInputType.number,
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
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'no_of_class')} *",
                                onChanged: _bloc.onClassHoursChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'no_of_class_hours'),
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                                textInputType: TextInputType.number,
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
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'size_class')} *",
                                onChanged: _bloc.onClassSizeChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'enter_participants'),
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                                textInputType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classDescription,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                currentNode: focusNodes[4],
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading: AppLocalizations.of(context)
                                    .translate('create_offer', 'class_desc'),
                                onChanged: _bloc.onclassDescriptionChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'class_desc_err'),
                                maxLength: 500,
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                                textInputType: TextInputType.multiline,
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
                          RaisedButton(
                            onPressed: status.data == Status.LOADING
                                ? () {}
                                : () async {
                                    var connResult = await Connectivity()
                                        .checkConnectivity();
                                    if (connResult == ConnectivityResult.none) {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)
                                                  .translate('shared',
                                                      'check_internet')),
                                          action: SnackBarAction(
                                            label: AppLocalizations.of(context)
                                                .translate('shared', 'dismiss'),
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
                                      _bloc.startTime = OfferDurationWidgetState
                                          .starttimestamp;
                                      _bloc.endTime =
                                          OfferDurationWidgetState.endtimestamp;
                                      if (widget.offerModel == null) {

                                        createOneToManyOfferFunc();

                                      } else {

                                        _bloc.updateOneToManyOffer(widget.offerModel);

                                      }
                                    } else {
                                      errorDialog(
                                        context: context,
                                        error: AppLocalizations.of(context)
                                            .translate('create_offer',
                                                'enter_start_end'),
                                      );
                                    }
                                  },
                            child: status.data == Status.LOADING
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        widget.offerModel == null
                                            ? AppLocalizations.of(context)
                                                .translate(
                                                    'create_offer', 'creating')
                                            : AppLocalizations.of(context)
                                                .translate(
                                                    'create_offer', 'updating'),
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
                                        ? AppLocalizations.of(context)
                                            .translate('create_offer', 'title')
                                        : AppLocalizations.of(context)
                                            .translate(
                                                'create_offer', 'title_update'),
                                    style: TextStyle(fontSize: 16),
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
      end.after = (end.endType == "after" ? int.parse(RepeatWidgetState.after) : null);
      print("end model is = ${end.toMap()} ${end.endType}");
      _bloc.end = end;
    }

    if (_bloc.isRecurring) {
      if (_bloc.recurringDays.length == 0) {
        errorDialog(
            context: context,
            error: AppLocalizations.of(context)
                .translate('create_request', 'recurringDays_err'));
        return;
      }
    }
    _bloc.createOneToManyOffer(user: SevaCore.of(context).loggedInUser, timebankId: widget.timebankId);
  }
}
