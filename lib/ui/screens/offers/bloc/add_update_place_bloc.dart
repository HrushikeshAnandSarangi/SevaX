import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../../../../labels.dart';

class AddUpdatePlaceBloc extends BlocBase {
  final _placeName = BehaviorSubject<String>();
  final _no_of_guests = BehaviorSubject<String>();
  final _no_of_rooms = BehaviorSubject<String>();
  final _no_of_bathRooms = BehaviorSubject<String>();
  final _commonSpaces = BehaviorSubject<String>();
  final _house_rules = BehaviorSubject<String>();
  final _estimated_value = BehaviorSubject<String>();
  final _contactInformation = BehaviorSubject<String>();
  final _house_images = BehaviorSubject<List<String>>();
  final profanityDetector = ProfanityDetector();
  final _amenities = BehaviorSubject<Map<String, dynamic>>();
  final _message = BehaviorSubject<String>();
  final _status = BehaviorSubject<Status>.seeded(Status.IDLE);
  final _model = BehaviorSubject<LendingModel>();

  Stream<Status> get status => _status.stream;

  Stream<String> get placeName => _placeName.stream;

  Stream<String> get noOfGuests => _no_of_guests.stream;

  Stream<String> get noOfRooms => _no_of_rooms.stream;

  Stream<String> get bathRooms => _no_of_bathRooms.stream;

  Stream<String> get commonSpaces => _commonSpaces.stream;

  Stream<String> get houseRules => _house_rules.stream;

  Stream<String> get estimatedValue => _estimated_value.stream;

  Stream<String> get contactInformation => _contactInformation.stream;

  Stream<List<String>> get houseImages => _house_images.stream;

  Stream<Map<String, dynamic>> get amenitiesDetails => _amenities.stream;

  Stream<String> get message => _message.stream;

  Function(String value) get onPlaceNameChanged => _placeName.sink.add;

  Function(String value) get onNoOfGuestsChanged => _no_of_guests.sink.add;

  Function(String value) get onNoOfRoomsChanged => _no_of_rooms.sink.add;

  Function(String value) get onBathRoomsChanged => _no_of_bathRooms.sink.add;

  Function(String value) get onCommonSpacesChanged => _commonSpaces.sink.add;

  Function(String value) get onHouseRulesChanged => _house_rules.sink.add;

  Function(String value) get onEstimatedValueChanged =>
      _estimated_value.sink.add;

  Function(String value) get onContactInformationChanged =>
      _contactInformation.sink.add;

  Function(List<String> value) get onHouseImageAdded => _house_images.sink.add;

  Function(Map<String, dynamic>) get amenitiesChanged => _amenities.sink.add;

  void loadData(LendingModel lendingModel) {
    _house_images.add(lendingModel.lendingPlaceModel!.houseImages!.toList());
    _amenities.add(lendingModel.lendingPlaceModel!.amenities!);
  }

  Map<String, dynamic> getSelectedAmenities() {
    return _amenities.value;
  }

  LendingModel getLendingPlaceModel() {
    return _model.value;
  }

  void createLendingOfferPlace({UserModel? creator}) {
    LendingModel lendingModel;
    if (!validateForm()) {
      if (_amenities.value.values == null ||
          _amenities.value.values.length < 1) {
        _message.add('amenities');
      } else {
        _message.add('create');
        var timestamp = DateTime.now().millisecondsSinceEpoch;

        lendingModel = LendingModel(
            id: Utils.getUuid(),
            creatorId: creator!.sevaUserID!,
            email: creator.email!,
            timestamp: timestamp,
            lendingType: LendingType.PLACE,
            lendingPlaceModel: LendingPlaceModel(
                placeName: _placeName.value,
                noOfGuests: int.parse(_no_of_guests.value),
                noOfRooms: int.parse(_no_of_rooms.value),
                noOfBathRooms: int.parse(_no_of_bathRooms.value),
                commonSpace: _commonSpaces.value,
                houseRules: _house_rules.value,
                estimatedValue: int.parse(_estimated_value.value),
                contactInformation: _contactInformation.value,
                houseImages: _house_images.value.toList(),
                amenities: _amenities.value));
        LendingOffersRepo.addNewLendingPlace(model: lendingModel).then((_) {
          _model.add(lendingModel);
          _status.add(Status.COMPLETE);
        }).catchError((e) => _status.add(Status.ERROR));
      }
    }
  }

  void updateLendingOfferPlace({LendingModel? model}) async {
    LendingModel lendingModel = model!;
    if (!validateForm()) {
      if (_amenities.value.values == null ||
          _amenities.value.values.length < 1) {
        _message.add('amenities');
      } else {
        lendingModel.lendingPlaceModel!.amenities = _amenities.value;
        lendingModel.lendingPlaceModel!.placeName = _placeName.value;
        lendingModel.lendingPlaceModel!.houseImages =
            _house_images.value.toList();
        lendingModel.lendingPlaceModel!.noOfRooms =
            int.parse(_no_of_rooms.value);
        lendingModel.lendingPlaceModel!.noOfGuests =
            int.parse(_no_of_guests.value);
        lendingModel.lendingPlaceModel!.noOfBathRooms =
            int.parse(_no_of_bathRooms.value);
        lendingModel.lendingPlaceModel!.commonSpace = _commonSpaces.value;
        lendingModel.lendingPlaceModel!.houseRules = _house_rules.value;
        lendingModel.lendingPlaceModel!.estimatedValue =
            int.parse(_estimated_value.value);
        lendingModel.lendingPlaceModel!.contactInformation =
            _contactInformation.value;

        LendingOffersRepo.updateNewLendingPlace(model: lendingModel).then((_) {
          _model.add(lendingModel);
          _status.add(Status.COMPLETE);
        }).catchError((e) => _status.add(Status.ERROR));
      }
    }
  }

  String validatePlaceName(String val) {
    if (_placeName.value == null || _placeName.value == '') {
      _placeName.addError(AddPlaceValidationErrors.placeNameError);
      return AddPlaceValidationErrors.placeNameError;
    } else if (_placeName.value.substring(0, 1).contains('_') &&
        !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
      _placeName.addError(AddPlaceValidationErrors.underscore_error);
      return AddPlaceValidationErrors.underscore_error;
    } else if (profanityDetector.isProfaneString(_placeName.value)) {
      _placeName.addError(AddPlaceValidationErrors.profanityError);
      return AddPlaceValidationErrors.profanityError;
    }
    return null!;
  }

  String validateGuest(String val) {
    logger.d("#room guest ${_no_of_guests.value}");

    if (_no_of_guests.value == null ||
        _no_of_guests.value.isEmpty ||
        _no_of_guests.value == "0") {
      _no_of_guests.addError(AddPlaceValidationErrors.no_guests_error);
      return AddPlaceValidationErrors.no_guests_error;
    }
    return null!;
  }

  String validateRooms(String val) {
    logger.d("#room ${_no_of_rooms.value}");
    if (_no_of_rooms.value == null ||
        _no_of_rooms.value.isEmpty ||
        _no_of_rooms.value == '0') {
      _no_of_rooms.addError(AddPlaceValidationErrors.no_rooms_error);
      return AddPlaceValidationErrors.no_rooms_error;
    }
    return null!;
  }

  String validateBathroom(String val) {
    if (_no_of_bathRooms.value == null ||
        _no_of_bathRooms.value.isEmpty ||
        _no_of_bathRooms.value == "0") {
      _no_of_bathRooms.addError(AddPlaceValidationErrors.bath_rooms_error);
      return AddPlaceValidationErrors.bath_rooms_error;
    }
    return null!;
  }

  String validateCommonSpace(String val) {
    if (_commonSpaces.value == null || _commonSpaces.value == '') {
      _commonSpaces.addError(AddPlaceValidationErrors.commonSpaces_error);
      return AddPlaceValidationErrors.commonSpaces_error;
    }
    return null!;
  }

  String validateHouseRule(String val) {
    if (_house_rules.value == null || _house_rules.value == '') {
      _house_rules.addError(AddPlaceValidationErrors.house_rules_error);
      return AddPlaceValidationErrors.house_rules_error;
    }
    /*else if (_amenities.value == null || _amenities.value.length == 0) {
      _amenities.addError(AddPlaceValidationErrors.amenities_error);
      return AddPlaceValidationErrors.amenities_error;
    }*/
    return null!;
  }

  String validateEstimatedValue(String val) {
    if (_estimated_value.value.trimLeft() == null ||
        _estimated_value.value.isEmpty ||
        _estimated_value.value == "0") {
      _estimated_value.addError(AddPlaceValidationErrors.estimated_value_error);
      return AddPlaceValidationErrors.estimated_value_error;
    }
    return null!;
  }

  bool validateForm() {
    return !(validatePlaceName(_placeName.value) == null &&
        validateGuest(_no_of_guests.value.toString()) == null &&
        validateRooms(_no_of_rooms.value.toString()) == null &&
        validateBathroom(_no_of_bathRooms.value.toString()) == null &&
        validateCommonSpace(_commonSpaces.value.toString()) == null &&
        validateHouseRule(_house_rules.value.toString()) == null &&
        validateEstimatedValue(_estimated_value.value.toString()) == null);
  }

  ///[ERROR CHECKS] TO Validate input
  bool errorCheck() {
    bool flag = false;
    if (_placeName.value == null || _placeName.value == '') {
      _placeName.addError(AddPlaceValidationErrors.placeNameError);
      flag = true;
    } else if (_placeName.value.substring(0, 1).contains('_') &&
        !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
      _placeName.addError(AddPlaceValidationErrors.underscore_error);
      flag = true;
    } else if (profanityDetector.isProfaneString(_placeName.value)) {
      _placeName.addError(AddPlaceValidationErrors.profanityError);
      flag = true;
    }

    if (_no_of_guests.value == null || _no_of_guests.value == 0) {
      _no_of_guests.addError(AddPlaceValidationErrors.no_guests_error);
      flag = true;
    }
    if (_no_of_rooms.value == null || _no_of_rooms.value == 0) {
      _no_of_rooms.addError(AddPlaceValidationErrors.no_rooms_error);
      flag = true;
    }
    if (_no_of_bathRooms.value == null || _no_of_bathRooms.value == 0) {
      _no_of_bathRooms.addError(AddPlaceValidationErrors.bath_rooms_error);
      flag = true;
    }
    if (_commonSpaces.value == null || _commonSpaces.value == '') {
      _commonSpaces.addError(AddPlaceValidationErrors.commonSpaces_error);
      flag = true;
    }
    if (_house_rules.value == null || _house_rules.value == '') {
      _house_rules.addError(AddPlaceValidationErrors.house_rules_error);
      flag = true;
    } else if (_amenities.value == null || _amenities.value.length == 0) {
      _amenities.addError(AddPlaceValidationErrors.amenities_error);
      flag = true;
    }
    if (_estimated_value.value == null ||
        _estimated_value.value == 0 ||
        _estimated_value == '') {
      _estimated_value.addError(AddPlaceValidationErrors.estimated_value_error);
      flag = true;
    }
    // if (_location.value == null) {
    //   _location.addError(ValidationErrors.genericError);
    //   flag = true;
    // }

    return flag;
  }

  @override
  void dispose() {
    _placeName.close();
    _no_of_guests.close();
    _house_rules.close();
    _estimated_value.close();
    _contactInformation.close();
    _no_of_rooms.close();
    _no_of_bathRooms.close();
    _commonSpaces.close();
    _house_images.close();
    _amenities.close();
  }
}

class AddPlaceValidationErrors {
  static const String placeNameError = 'placeName_error';
  static const String no_guests_error = '_no_guests_error';
  static const String no_rooms_error = '_no_rooms_error';
  static const String house_rules_error = '_house_rules_error';
  static const String estimated_value_error = '_estimated_value_error';
  static const String commonSpaces_error = '_commonSpaces_error';
  static const String bath_rooms_error = '_bath_rooms_error';
  static const String amenities_error = "amenities_error";
  static const String profanityError = "profanity_error";
  static const String underscore_error = "_underscore_error";

// static const String titleError = 'Please enter the subject of your offer';
}

String getAddPlaceValidationError(BuildContext context, String errorCode) {
//  S error = S.of(context);
  S error = S.of(context);
  switch (errorCode) {
    case AddPlaceValidationErrors.placeNameError:
      return error.validation_error_place_name;
      break;
    case AddPlaceValidationErrors.no_guests_error:
      return error.validation_error_no_of_guests;
      break;
    case AddPlaceValidationErrors.bath_rooms_error:
      return error.validation_error_no_of_bathrooms;
      break;
    case AddPlaceValidationErrors.no_rooms_error:
      return error.validation_error_no_of_rooms;
      break;
    case AddPlaceValidationErrors.estimated_value_error:
      return error.validation_error_no_estimated_value_room;
      break;
    case AddPlaceValidationErrors.commonSpaces_error:
      return error.validation_error_common_spaces;
      break;
    case AddPlaceValidationErrors.house_rules_error:
      return error.validation_error_house_rules;
      break;
    case AddPlaceValidationErrors.profanityError:
      return error.profanity_text_alert;
      break;
    case AddPlaceValidationErrors.underscore_error:
      return 'Creating offer with "_" is not allowed';
      break;
    case AddPlaceValidationErrors.amenities_error:
      return error.validation_error_amenities;
      break;

    default:
      return null!;
      break;
  }
}
