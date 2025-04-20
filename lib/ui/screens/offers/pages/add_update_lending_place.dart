import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/new_baseline/models/amenities_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/ui/screens/image_picker/image_picker_dialog_mobile.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/add_update_place_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/selecrt_amenities.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_dose_text_field.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/custom_textfield.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/full_screen_widget.dart';

class AddUpdateLendingPlace extends StatefulWidget {
  final LendingModel? lendingModel;
  final String? enteredTitle;
  final Function(LendingModel lendingModel)? onPlaceCreateUpdate;

  AddUpdateLendingPlace(
      {this.lendingModel, this.onPlaceCreateUpdate, this.enteredTitle});

  @override
  _AddUpdateLendingPlaceState createState() => _AddUpdateLendingPlaceState();
}

class _AddUpdateLendingPlaceState extends State<AddUpdateLendingPlace> {
  final _formKey = GlobalKey<DoseFormState>();
  final _imageKey = GlobalKey();
  final _searchKey = GlobalKey();
  List<AmenitiesModel> amenitiesList = [];
  List<String> imagesList = [];
  AddUpdatePlaceBloc _bloc = AddUpdatePlaceBloc();
  FocusNode _placeName = FocusNode();
  FocusNode _guests = FocusNode();
  FocusNode _rooms = FocusNode();
  FocusNode _bathrooms = FocusNode();
  FocusNode _commonSPace = FocusNode();
  FocusNode _houseRules = FocusNode();
  FocusNode _estimatedValue = FocusNode();
  FocusNode _contactInformation = FocusNode();
  TextEditingController _placeNameController = TextEditingController();
  TextEditingController _guestsController = TextEditingController();
  TextEditingController _roomsController = TextEditingController();
  TextEditingController _bathroomsController = TextEditingController();
  TextEditingController _commonSpaceController = TextEditingController();
  TextEditingController _houseRulesController = TextEditingController();
  TextEditingController _estimatedValueController = TextEditingController();
  TextEditingController _contactInformationController = TextEditingController();
  bool shouldPop = true;

  @override
  void initState() {
    super.initState();
    if (widget.lendingModel != null) {
      _bloc.loadData(widget.lendingModel!);

      _placeNameController.text =
          widget.lendingModel!.lendingPlaceModel!.placeName!;
      _bloc.onPlaceNameChanged(
          widget.lendingModel!.lendingPlaceModel!.placeName!);

      _guestsController.text =
          widget.lendingModel!.lendingPlaceModel!.noOfGuests.toString();
      _bloc.onNoOfGuestsChanged(
          widget.lendingModel!.lendingPlaceModel!.noOfGuests.toString());

      _roomsController.text =
          widget.lendingModel!.lendingPlaceModel!.noOfRooms.toString();
      _bloc.onNoOfRoomsChanged(
          widget.lendingModel!.lendingPlaceModel!.noOfRooms.toString());

      _bathroomsController.text =
          widget.lendingModel!.lendingPlaceModel!.noOfBathRooms.toString();
      _bloc.onBathRoomsChanged(
          widget.lendingModel!.lendingPlaceModel!.noOfBathRooms.toString());

      _commonSpaceController.text =
          widget.lendingModel!.lendingPlaceModel!.commonSpace!;
      _bloc.onCommonSpacesChanged(
          widget.lendingModel!.lendingPlaceModel!.commonSpace!);

      _houseRulesController.text =
          widget.lendingModel!.lendingPlaceModel!.houseRules.toString();
      _bloc.onHouseRulesChanged(
          widget.lendingModel!.lendingPlaceModel!.houseRules.toString());

      _estimatedValueController.text =
          widget.lendingModel!.lendingPlaceModel!.estimatedValue.toString();
      _bloc.onEstimatedValueChanged(
          widget.lendingModel!.lendingPlaceModel!.estimatedValue.toString());

      _contactInformationController.text =
          widget.lendingModel!.lendingPlaceModel!.contactInformation!;
      _bloc.onContactInformationChanged(
          widget.lendingModel!.lendingPlaceModel!.contactInformation!);
    } else {
      if (widget.enteredTitle != null) {
        _placeNameController.text = widget.enteredTitle!;
        _bloc.onPlaceNameChanged(widget.enteredTitle!);
      }
    }
    setState(() {});
    _bloc.message.listen((event) {
      if (event.isNotEmpty && event != null) {
        //hideProgress();
        if (event == 'amenities') {
          showScaffold(S.of(context).validation_error_amenities);
        } else if (event == 'create') {
          showScaffold(S.of(context).creating_place);
        } else if (event == 'update') {
          showScaffold(S.of(context).updating_place);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).add_new_place_text,
          style: TextStyle(fontSize: 18, fontFamily: 'Europa'),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<Object>(
          stream: _bloc.status,
          builder: (context, status) {
            if (status.data == Status.COMPLETE) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onPlaceCreateUpdate!(_bloc.getLendingPlaceModel());
                if (shouldPop) {
                  shouldPop = false;
                  Navigator.pop(context);
                }
              });
            }

            if (status.data == Status.LOADING) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        widget.lendingModel == null
                            ? S.of(context).creating_place
                            : S.of(context).updating_place,
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
                        widget.lendingModel == null
                            ? S.of(context).creating_place_error
                            : S.of(context).updating_place_error,
                      ),
                    ),
                  );
                },
              );
            }
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(30.0),
                child: DoseForm(
                  formKey: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<String>(
                        stream: _bloc.placeName,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _placeNameController,
                            focusNode: _placeName,
                            nextNode: _guests,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validatePlaceName(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).name_of_place}*",
                            onChanged: (String value) {
                              _bloc.onPlaceNameChanged(value);
                              // title = value;
                            },
                            hint: S.of(context).name_of_place_hint,
                            maxLength: 30,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return ImagePickerDialogMobile(
                                    imagePickerType:
                                        ImagePickerType.LENDING_OFFER,
                                    onLinkCreated: (link) {
                                      imagesList.add(link);
                                      _bloc.onHouseImageAdded(imagesList);
                                    },
                                    storeImageFile: (file) {},
                                    storPdfFile: (file) {},
                                    color: Theme.of(context).primaryColor,
                                  );
                                });
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Container(
                              key: _imageKey,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        defaultCameraImageURL,
                                      ),
                                      fit: BoxFit.cover),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(75.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 7.0, color: Colors.black12)
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<List<String>>(
                        stream: _bloc.houseImages,
                        builder: (builder, snapshot) {
                          // if (snapshot.connectionState == ConnectionState.waiting) {
                          //   return LoadingIndicator();
                          // }
                          if (snapshot.hasError ||
                              snapshot.data == null ||
                              !snapshot.hasData) {
                            return Container();
                          }
                          imagesList = snapshot.data!;
                          return Container(
                            height: 100,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                imagesList.length,
                                (index) => Container(
                                  width: 80,
                                  height: 80,
                                  margin: EdgeInsets.only(left: 5),
                                  child: Stack(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext dialogContext) {
                                                return FullScreenImage(
                                                  imageUrl: imagesList[index],
                                                );
                                              });
                                        },
                                        child: Container(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                  imagesList[index])),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: () {
                                            imagesList.removeAt(index);
                                            _bloc.onHouseImageAdded(imagesList);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.transparent,
                                            ),
                                            child: Icon(
                                              Icons.cancel_rounded,
                                              color: Colors.white,
                                              size: 20,
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
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        S.of(context).amenities_text + '*',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Europa',
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        S.of(context).amenities_hint,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Container(
                        key: _searchKey,
                        child: SelectAmenities(
                          languageCode:
                              SevaCore.of(context).loggedInUser.language ??
                                  'en',
                          selectedAmenities: _bloc.getSelectedAmenities() ?? {},
                          onSelectedAmenitiesMap: (amenitiesMap) {
                            if (amenitiesMap.values != null &&
                                amenitiesMap.values.length > 0) {
                              _bloc.amenitiesChanged(amenitiesMap);
                              log('amenit ${amenitiesMap.values}');
                              //setState(() {});
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: _bloc.noOfGuests,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _guestsController,
                            focusNode: _guests,
                            nextNode: _rooms,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateGuest(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).no_of_guests}*",
                            onChanged: (String value) {
                              _bloc.onNoOfGuestsChanged(value);
                              // title = value;
                            },
                            hint: 'Ex: 3',
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  Regex.numericRegex)
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: _bloc.noOfRooms,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _roomsController,
                            focusNode: _rooms,
                            nextNode: _bathrooms,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateRooms(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).bed_roooms_text}*",
                            onChanged: (String value) {
                              _bloc.onNoOfRoomsChanged(value);
                              // title = value;
                            },
                            hint: 'Ex: 2',
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  Regex.numericRegex)
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: _bloc.bathRooms,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _bathroomsController,
                            focusNode: _bathrooms,
                            nextNode: _commonSPace,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateBathroom(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).bath_rooms}*",
                            onChanged: (String value) {
                              _bloc.onBathRoomsChanged(value);
                              // title = value;
                            },
                            hint: 'Ex: 1',
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  Regex.numericRegex)
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: _bloc.commonSpaces,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _commonSpaceController,
                            focusNode: _commonSPace,
                            nextNode: _houseRules,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateCommonSpace(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).common_spaces}*",
                            onChanged: (String value) {
                              _bloc.onCommonSpacesChanged(value);
                              // title = value;
                            },
                            hint: S.of(context).common_spaces_hint,
                            maxLength: null,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      StreamBuilder<String>(
                        stream: _bloc.houseRules,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            controller: _houseRulesController,
                            focusNode: _houseRules,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateHouseRule(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).house_rules}*",
                            onChanged: (String value) {
                              _bloc.onHouseRulesChanged(value);
                              // title = value;
                            },
                            hint: S.of(context).house_rules_hint,
                            minLines: 2,
                            maxLines: 2,
                            maxLength: null,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      //ESTIMATED VALUE FIELD HERE
                      StreamBuilder<String>(
                        stream: _bloc.estimatedValue,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 23, maxHeight: 20),
                                prefixIcon: Icon(Icons.attach_money),
                                hintText: S
                                        .of(context)
                                        .estimated_value_place_hint +
                                    S.of(context).estimated_value_hint_place,
                                errorText: getAddPlaceValidationError(
                                    context, snapshot.error! as String)),
                            controller: _estimatedValueController,
                            focusNode: _estimatedValue,
                            value: snapshot.data,
                            validator: (val) {
                              var validate = _bloc.validateEstimatedValue(val!);
                              return validate == null
                                  ? null
                                  : getAddPlaceValidationError(
                                      context, validate);
                            },
                            heading: "${S.of(context).estimated_value}",
                            onChanged: (String value) {
                              _bloc.onEstimatedValueChanged(value);
                              // title = value;
                            },
                            // hint: S.of(context).request_min_donation_hint,
                            formatters: [
                              FilteringTextInputFormatter.allow(
                                  Regex.numericRegex)
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      //CONTACT INFORMATION FIELD HERE
                      StreamBuilder<String>(
                        stream: _bloc.contactInformation,
                        builder: (context, snapshot) {
                          return CustomDoseTextField(
                            isRequired: false,
                            hint: S.of(context).email +
                                ' / ' +
                                S.of(context).phone_number,
                            controller: _contactInformationController,
                            focusNode: _contactInformation,
                            value: snapshot.data,
                            heading: S.of(context).contact_information,
                            // not mandatory field now as told by anitha
                            onChanged: (String value) {
                              _bloc.onContactInformationChanged(value);
                            },
                            keyboardType: TextInputType.text,
                            error: snapshot.error != null
                                ? getAddPlaceValidationError(
                                    context, snapshot.error as String)
                                : null,
                            validator: (String? value) {
                              // if (value.isEmpty) {
                              //   return null;   // not mandatory field now as told by anitha
                              // }
                              if (value != null &&
                                  !Regex.emailAndPhoneRegex.hasMatch(value) &&
                                  value.isNotEmpty) {
                                return 'Please enter a valid Email or Phone Number';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Container(
                          height: 50,
                          width: 200,
                          child: CustomElevatedButton(
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            elevation: 2.0,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              var connResult =
                                  await Connectivity().checkConnectivity();
                              if (connResult == ConnectivityResult.none) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(context).check_internet),
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

                              if (_bloc.getSelectedAmenities() == {} ||
                                  _bloc.getSelectedAmenities() == null) {
                                showAlertMessage(
                                    context: context,
                                    message:
                                        S.of(context).please_add_amenities);
                                FocusScope.of(context).unfocus();
                                Scrollable.ensureVisible(
                                    _searchKey.currentContext!);
                                return;
                              }

                              if (imagesList == null ||
                                  imagesList.length == 0) {
                                showAlertMessage(
                                    context: context,
                                    message: S.of(context).add_images_to_place);
                                FocusScope.of(context).unfocus();
                                Scrollable.ensureVisible(
                                    _imageKey.currentContext!);
                              } else {
                                if (widget.lendingModel == null) {
                                  _bloc.createLendingOfferPlace(
                                      creator:
                                          SevaCore.of(context).loggedInUser);
                                } else {
                                  _bloc.updateLendingOfferPlace(
                                      model: widget.lendingModel);
                                }
                              }
                            },
                            shape: StadiumBorder(),
                            child: Text(
                                widget.lendingModel == null
                                    ? S.of(context).add_place_text
                                    : S.of(context).update_place_text,
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
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
    _houseRulesController.dispose();
    _commonSpaceController.dispose();
    _bathroomsController.dispose();
    _placeNameController.dispose();
    _guestsController.dispose();
    _roomsController.dispose();
    _estimatedValueController.dispose();
    _contactInformationController.dispose();
    _bloc.dispose();
    _placeName.dispose();
    _guests.dispose();
    _rooms.dispose();
    _bathrooms.dispose();
    _commonSPace.dispose();
    _houseRules.dispose();
    _estimatedValue.dispose();
    _contactInformation.dispose();
    super.dispose();
  }
}

void showAlertMessage({BuildContext? context, String? message}) {
  showDialog(
    context: context!,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(S.of(context).alert),
        content: Text(message!),
        actions: [
          CustomTextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: Colors.deepOrange),
              )),
        ],
      );
    },
  );
}
