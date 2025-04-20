import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/components/duration_picker/offer_duration_widget.dart';
import 'package:sevaexchange/components/repeat_availability/edit_repeat_widget.dart';
import 'package:sevaexchange/components/repeat_availability/repeat_widget.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/ui/screens/calendar/add_to_calander.dart';
import 'package:sevaexchange/ui/screens/members/pages/members_page.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/one_to_many_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dialog.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';
import 'package:sevaexchange/widgets/location_picker_widget.dart';
import 'package:sevaexchange/widgets/open_scope_checkbox_widget.dart';

class OneToManyOffer extends StatefulWidget {
  final OfferModel? offerModel;
  final String? timebankId;
  final String? loggedInMemberUserId;
  final TimebankModel? timebankModel;

  const OneToManyOffer({
    Key? key,
    this.offerModel,
    this.timebankId,
    required this.loggedInMemberUserId,
    required this.timebankModel,
  }) : super(key: key);
  @override
  _OneToManyOfferState createState() => _OneToManyOfferState();
}

class _OneToManyOfferState extends State<OneToManyOffer> {
  final OneToManyOfferBloc _bloc = OneToManyOfferBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  End end = End(endType: '', on: 0, after: 0);
  String? selectedAddress;
  String title = '';
  CustomLocation? customLocation;
  bool closePage = true;
  CommunityModel? communityModel;

  List<FocusNode>? focusNodes;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _preparationController = TextEditingController();
  TextEditingController _classHourController = TextEditingController();
  TextEditingController _sizeClassController = TextEditingController();
  TextEditingController _classDescriptionController = TextEditingController();

  @override
  void initState() {
    focusNodes = List.generate(5, (_) => FocusNode());
    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel!);
      _titleController.text =
          widget.offerModel!.groupOfferDataModel!.classTitle;
      _preparationController.text = widget
          .offerModel!.groupOfferDataModel!.numberOfPreperationHours
          .toString();
      _classHourController.text =
          widget.offerModel!.groupOfferDataModel!.numberOfClassHours.toString();
      _sizeClassController.text =
          widget.offerModel!.groupOfferDataModel!.sizeOfClass.toString();
      _classDescriptionController.text =
          widget.offerModel!.groupOfferDataModel!.classDescription;
    }
    super.initState();
    getCommunity();

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

  Future<void> getCommunity() async {
    communityModel = await FirestoreManager.getCommunityDetailsByCommunityId(
        communityId: widget.timebankModel!.communityId);
    setState(() {});
  }

  @override
  void dispose() {
    focusNodes!.forEach((node) => node.dispose());
    _bloc.dispose();
    _titleController.dispose();
    _preparationController.dispose();
    _classHourController.dispose();
    _sizeClassController.dispose();
    _classDescriptionController.dispose();
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
              actions: [CommonHelpIconWidget()])
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
                          StreamBuilder<String>(
                            stream: _bloc.title,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                controller: _titleController,
                                currentNode: focusNodes![0],
                                nextNode: focusNodes![1],
                                // formatters: <TextInputFormatter>[
                                //   WhitelistingTextInputFormatter(
                                //       RegExp("[a-zA-Z0-9_ ]*"))
                                // ],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).title}*",
                                onChanged: _bloc.onTitleChanged,
                                hint: S.of(context).one_to_many_offer_hint,
                                maxLength: null,
                                error: getValidationError(
                                    context, snapshot.error?.toString() ?? ''),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          OfferDurationWidget(
                            title: S.of(context).offer_duration,
                            startTime: widget.offerModel != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    widget!.offerModel!.groupOfferDataModel!
                                        .startDate,
                                  )
                                : null,
                            endTime: widget.offerModel != null
                                ? DateTime.fromMillisecondsSinceEpoch(
                                    widget.offerModel!.groupOfferDataModel!
                                        .endDate,
                                  )
                                : null,
                          ),
                          SizedBox(height: 20),
                          widget.offerModel == null
                              ? RepeatWidget()
                              : Container(),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.preparationHours,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                controller: _preparationController,
                                currentNode: focusNodes![1],
                                nextNode: focusNodes![2],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).offer_prep_hours} *",
                                onChanged: _bloc.onPreparationHoursChanged,
                                hint: S.of(context).offer_prep_hours_required,
                                error: getValidationError(
                                    context, snapshot.error?.toString() ?? ''),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classHours,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                controller: _classHourController,
                                currentNode: focusNodes![2],
                                nextNode: focusNodes![3],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading:
                                    "${S.of(context).offer_number_class_hours} *",
                                onChanged: _bloc.onClassHoursChanged,
                                hint: S
                                    .of(context)
                                    .offer_number_class_hours_required,
                                error: getValidationError(
                                    context, snapshot.error?.toString() ?? ''),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classSize,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                controller: _sizeClassController,
                                currentNode: focusNodes![3],
                                nextNode: focusNodes![4],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading: "${S.of(context).offer_size_class} *",
                                onChanged: _bloc.onClassSizeChanged,
                                hint: S.of(context).offer_enter_participants,
                                error: getValidationError(
                                    context, snapshot.error?.toString() ?? ''),
                                keyboardType: TextInputType.number,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.classDescription,
                            builder: (_, snapshot) {
                              return CustomTextField(
                                controller: _classDescriptionController,
                                currentNode: focusNodes![4],
                                value: snapshot.data != null
                                    ? snapshot.data
                                    : null,
                                heading:
                                    "${S.of(context).offer_class_description} *",
                                onChanged: _bloc.onclassDescriptionChanged,
                                hint: S.of(context).offer_description_error,
                                maxLength: 500,
                                error: getValidationError(
                                    context, snapshot.error?.toString() ?? ''),
                                keyboardType: TextInputType.multiline,
                              );
                            },
                          ),
                          SizedBox(height: 12),
                          Text(S.of(context).onetomany_createoffer_note),
                          SizedBox(height: 35),
                          StreamBuilder<CustomLocation>(
                              stream: _bloc.location,
                              builder: (_, snapshot) {
                                return LocationPickerWidget(
                                  location: snapshot.data?.location,
                                  selectedAddress: snapshot.data!.address!,
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
                          HideWidget(
                            secondChild: SizedBox.shrink(),
                            hide: AppConfig.isTestCommunity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: StreamBuilder<bool>(
                                  stream: _bloc.makeVirtualValue,
                                  builder: (context, snapshot) {
                                    return ConfigurationCheck(
                                      actionType: 'create_virtual_offer',
                                      // S.of(context).create_virtual_offer,
                                      role: MemberType.MEMBER,
                                      child: OpenScopeCheckBox(
                                          infoType: InfoType.VirtualOffers,
                                          isChecked: snapshot.data!,
                                          checkBoxTypeLabel:
                                              CheckBoxType.type_VirtualOffers,
                                          onChangedCB: (bool? val) {
                                            logger.e(
                                                'value for virtual offer $val');
                                            if (snapshot.data != val) {
                                              _bloc.onOfferMadeVirtual(val!);
                                              log('value ${val}');
                                              setState(() {});
                                            }
                                          }),
                                    );
                                  }),
                            ),
                          ),
                          StreamBuilder<bool>(
                              initialData: false,
                              stream: _bloc.isVisible,
                              builder: (context, snapshot) {
                                return snapshot.data!
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: StreamBuilder<bool>(
                                            stream: _bloc.makePublicValue,
                                            builder: (context, snapshot) {
                                              return ConfigurationCheck(
                                                actionType:
                                                    'create_public_offer',
                                                // S.of(context).create_public_offer,
                                                role: MemberType.MEMBER,
                                                child: OpenScopeCheckBox(
                                                    infoType:
                                                        InfoType.OpenScopeOffer,
                                                    isChecked: snapshot.data!,
                                                    checkBoxTypeLabel:
                                                        CheckBoxType
                                                            .type_Offers,
                                                    onChangedCB: (bool? val) {
                                                      if (snapshot.data !=
                                                          val) {
                                                        _bloc.onOfferMadePublic(
                                                            val!);
                                                        log('value ${val}');
                                                        setState(() {});
                                                      }
                                                    }),
                                              );
                                            }),
                                      )
                                    : Container();
                              }),
                          SizedBox(height: 20),
                          TransactionsMatrixCheck(
                            comingFrom: ComingFrom.Offers,
                            upgradeDetails: AppConfig
                                .upgradePlanBannerModel!.onetomany_offers!,
                            transaction_matrix_type: "onetomany_offers",
                            child: CustomElevatedButton(
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 32.0),
                              elevation: 2.0,
                              textColor: Colors.white,
                              onPressed: status.data == Status.LOADING
                                  ? () {}
                                  : () async {
                                      var connResult = await Connectivity()
                                          .checkConnectivity();
                                      if (connResult ==
                                          ConnectivityResult.none) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                S.of(context).check_internet),
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
                                      FocusScope.of(context).unfocus();
                                      if (OfferDurationWidgetState
                                                  .starttimestamp !=
                                              0 &&
                                          OfferDurationWidgetState
                                                  .endtimestamp !=
                                              0) {
                                        _bloc.startTime =
                                            OfferDurationWidgetState
                                                .starttimestamp;
                                        _bloc.endTime = OfferDurationWidgetState
                                            .endtimestamp;
                                        if (_bloc.endTime! <=
                                            _bloc.startTime!) {
                                          errorDialog(
                                            context: context,
                                            error: S
                                                .of(context)
                                                .validation_error_end_date_greater,
                                          );
                                          return;
                                        }
                                        if (widget.offerModel == null) {
                                          createOneToManyOfferFunc();
                                        } else {
                                          if (widget
                                                  .offerModel!.autoGenerated! ||
                                              widget.offerModel!.isRecurring!) {
                                            showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext viewContext) {
                                                  return WillPopScope(
                                                      onWillPop: () async =>
                                                          false,
                                                      child: AlertDialog(
                                                          title: Text(S
                                                              .of(context)
                                                              .this_is_repeating_event),
                                                          actions: [
                                                            CustomTextButton(
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .edit_this_event,
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
                                                                    .offerModel!
                                                                    .autoGenerated!;
                                                                _bloc.isRecurring = widget
                                                                    .offerModel!
                                                                    .isRecurring!;

                                                                updateOneToManyOfferFunc(
                                                                    0);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            CustomTextButton(
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .edit_subsequent_event,
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
                                                                    .offerModel!
                                                                    .autoGenerated!;
                                                                _bloc.isRecurring = widget
                                                                    .offerModel!
                                                                    .isRecurring!;

                                                                updateOneToManyOfferFunc(
                                                                    1);

                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            CustomTextButton(
                                                              child: Text(
                                                                S
                                                                    .of(context)
                                                                    .cancel,
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
      end.endType = RepeatWidgetState.endType == 0
          ? S.of(context).on
          : S.of(context).after;
      end.on = end.endType == S.of(context).on
          ? RepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null!;
      end.after = (end.endType == S.of(context).after
          ? int.parse(RepeatWidgetState.after)
          : null!);
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

      _bloc.createOneToManyOffer(
          context: context,
          user: SevaCore.of(context).loggedInUser,
          timebankId: widget.timebankId,
          communityName: communityModel!.name ?? '');
    } else {
      _bloc.allowedCalenderEvent = false;

      _bloc.createOneToManyOffer(
          context: context,
          user: SevaCore.of(context).loggedInUser,
          timebankId: widget.timebankId,
          communityName: communityModel!.name ?? '');
      log("creation statusss - ${_bloc.offerCreatedBool}");
      if (_bloc.offerCreatedBool) {
        log("inside if with ${_bloc.offerCreatedBool}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AddToCalendar(
                  isOfferRequest: true,
                  offer: _bloc.mainOfferModel,
                  requestModel: RequestModel(
                      communityId: widget.timebankModel!
                          .communityId), // Provide required communityId
                  userModel: SevaCore.of(context)
                      .loggedInUser, // Replace with a valid UserModel instance if needed
                  eventsIdsArr: _bloc.offerIds);
            },
          ),
        ).then((_) {
          logger.i("came back from cal page");
        });
      }
    }
  }

  void updateOneToManyOfferFunc(int editType) async {
    if (_bloc.isRecurring || _bloc.autoGenerated) {
      _bloc.recurringDays = EditRepeatWidgetState.getRecurringdays();
      _bloc.occurenceCount = widget.offerModel!.occurenceCount;
      end.endType = EditRepeatWidgetState.endType == 0
          ? S.of(context).on
          : S.of(context).after;
      end.on = end.endType == S.of(context).on
          ? EditRepeatWidgetState.selectedDate.millisecondsSinceEpoch
          : null!;
      end.after = (end.endType == S.of(context).after
          ? int.parse(EditRepeatWidgetState.after)
          : null!);
      _bloc.end = end;
    }

    if (_bloc.isRecurring || _bloc.autoGenerated) {
      if (_bloc.recurringDays.length == 0) {
        errorDialog(context: context, error: S.of(context).recurringDays_err);
        return;
      }
    }

    _bloc.updateOneToManyOffer(widget.offerModel!, editType);
  }
}
