import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/internationalization/app_localization.dart';
import 'package:sevaexchange/models/location_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/individual_offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/views/core.dart';
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

  FocusNode _title = FocusNode();
  FocusNode _description = FocusNode();
  FocusNode _availability = FocusNode();

  @override
  void initState() {
    if (widget.offerModel != null) {
      _bloc.loadData(widget.offerModel);
    }
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _title.dispose();
    _description.dispose();
    _availability.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            builder: (context, snapshot) {
                              print(snapshot.data);
                              return CustomTextField(
                                currentNode: _title,
                                nextNode: _description,
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'title_title')}*",
                                onChanged: _bloc.onTitleChanged,
                                hint:
                                    "${AppLocalizations.of(context).translate('create_offer', 'baby_sitting')}..",
                                maxLength: null,
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                              );
                            },
                          ),
                          SizedBox(height: 40),
                          StreamBuilder<String>(
                            stream: _bloc.offerDescription,
                            builder: (context, snapshot) {
                              return CustomTextField(
                                currentNode: _description,
                                nextNode: _availability,
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading:
                                    "${AppLocalizations.of(context).translate('create_offer', 'offer_desc')}*",
                                onChanged: _bloc.onOfferDescriptionChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'offer_desc_hash'),
                                maxLength: 500,
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          StreamBuilder<String>(
                            stream: _bloc.availability,
                            builder: (context, snapshot) {
                              return CustomTextField(
                                currentNode: _availability,
                                initialValue: snapshot.data != null
                                    ? snapshot.data.contains('__*__')
                                        ? snapshot.data
                                        : null
                                    : null,
                                heading: AppLocalizations.of(context)
                                    .translate('create_offer', 'availablity'),
                                onChanged: _bloc.onAvailabilityChanged,
                                hint: AppLocalizations.of(context).translate(
                                    'create_offer', 'availablity_desc'),
                                maxLength: 100,
                                error: AppLocalizations.of(context).translate(
                                    'validation_errors', snapshot.error),
                              );
                            },
                          ),
                          SizedBox(height: 40),
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
                                    if (widget.offerModel == null) {
                                      _bloc.createOrUpdateOffer(
                                        user: SevaCore.of(context).loggedInUser,
                                        timebankId: widget.timebankId,
                                      );
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
