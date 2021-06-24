import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/add_update_place_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class AddUpdateLendingPlace extends StatefulWidget {
  final LendingPlaceModel lendingPlaceModel;

  AddUpdateLendingPlace({this.lendingPlaceModel});

  @override
  _AddUpdateLendingPlaceState createState() => _AddUpdateLendingPlaceState();
}

class _AddUpdateLendingPlaceState extends State<AddUpdateLendingPlace> {
  final _formKey = GlobalKey<FormState>();
  AddUpdatePlaceBloc _bloc = AddUpdatePlaceBloc();
  FocusNode _placeName = FocusNode();
  FocusNode _guests = FocusNode();
  FocusNode _rooms = FocusNode();
  FocusNode _bathrooms = FocusNode();
  FocusNode _commonSPace = FocusNode();
  FocusNode _houseRules = FocusNode();
  TextEditingController _placeNameController = TextEditingController();
  TextEditingController _guestsController = TextEditingController();
  TextEditingController _roomsController = TextEditingController();
  TextEditingController _bathroomsController = TextEditingController();
  TextEditingController _commonSpaceController = TextEditingController();
  TextEditingController _houseRulesController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          L.of(context).add_new_place,
          style: TextStyle(fontSize: 18, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<String>(
                  stream: _bloc.placeName,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _placeNameController,
                      currentNode: _placeName,
                      nextNode: _guests,
                      value: snapshot.data,
                      heading: "${L.of(context).name_of_place}",
                      onChanged: (String value) {
                        _bloc.onPlaceNameChanged(value);
                        // title = value;
                      },
                      hint: L.of(context).name_of_place_hint,
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                defaultCameraImageURL,
                              ),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(Radius.circular(75.0)),
                          boxShadow: [
                            BoxShadow(blurRadius: 7.0, color: Colors.black12)
                          ]),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                StreamBuilder<String>(
                  stream: _bloc.noOfGuests,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _guestsController,
                      currentNode: _guests,
                      nextNode: _rooms,
                      value: snapshot.data,
                      heading: "${L.of(context).no_of_guests}",
                      onChanged: (String value) {
                        _bloc.onNoOfGuestsChanged(value);
                        // title = value;
                      },
                      hint: 'Ex: 3',
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                StreamBuilder<String>(
                  stream: _bloc.noOfRooms,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _roomsController,
                      currentNode: _rooms,
                      nextNode: _bathrooms,
                      value: snapshot.data,
                      heading: "${L.of(context).bed_roooms}",
                      onChanged: (String value) {
                        _bloc.onNoOfRoomsChanged(value);
                        // title = value;
                      },
                      hint: 'Ex: 2',
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                StreamBuilder<String>(
                  stream: _bloc.bathRooms,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _bathroomsController,
                      currentNode: _bathrooms,
                      nextNode: _commonSPace,
                      value: snapshot.data,
                      heading: "${L.of(context).bath_rooms}",
                      onChanged: (String value) {
                        _bloc.onBathRoomsChanged(value);
                        // title = value;
                      },
                      hint: 'Ex: 1',
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                StreamBuilder<String>(
                  stream: _bloc.commonSpaces,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _commonSpaceController,
                      currentNode: _commonSPace,
                      nextNode: _houseRules,
                      value: snapshot.data,
                      heading: "${L.of(context).common_spaces}",
                      onChanged: (String value) {
                        _bloc.onCommonSpacesChanged(value);
                        // title = value;
                      },
                      hint: L.of(context).common_spaces_hint,
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                StreamBuilder<String>(
                  stream: _bloc.houseRules,
                  builder: (context, snapshot) {
                    return CustomTextField(
                      controller: _houseRulesController,
                      currentNode: _houseRules,
                      value: snapshot.data,
                      heading: "${L.of(context).house_rules}",
                      onChanged: (String value) {
                        _bloc.onHouseRulesChanged(value);
                        // title = value;
                      },
                      hint: L.of(context).house_rules_hint,
                      minLines: 5,
                      maxLines: 5,
                      maxLength: null,
                      error:
                          getAddPlaceValidationError(context, snapshot.error),
                    );
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 50,
                    width: 200,
                    child: CustomElevatedButton(
                      onPressed: () async {
                        var connResult =
                            await Connectivity().checkConnectivity();
                        if (connResult == ConnectivityResult.none) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(S.of(context).check_internet),
                              action: SnackBarAction(
                                label: S.of(context).dismiss,
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar(),
                              ),
                            ),
                          );
                          return;
                        }
                        if (widget.lendingPlaceModel == null) {
                          _bloc.createLendingOfferPlace();
                        } else {
                          _bloc.updateLendingOfferPlace();
                        }
                      },
                      shape: StadiumBorder(),
                      child: Text(
                          widget.lendingPlaceModel == null
                              ? L.of(context).add_place
                              : L.of(context).update_place,
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
