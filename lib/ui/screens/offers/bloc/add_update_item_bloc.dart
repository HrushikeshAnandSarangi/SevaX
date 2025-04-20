import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/utils.dart';

import '../../../../labels.dart';

class AddUpdateItemBloc extends BlocBase {
  final _itemName = BehaviorSubject<String>();
  final _estimated_value = BehaviorSubject<String>();
  final _item_images = BehaviorSubject<List<String>>();
  final profanityDetector = ProfanityDetector();
  final _message = BehaviorSubject<String>();
  final _status = BehaviorSubject<Status>.seeded(Status.IDLE);
  final _model = BehaviorSubject<LendingModel>();

  Stream<Status> get status => _status.stream;

  Stream<String> get itemName => _itemName.stream;

  Stream<String> get estimatedValue => _estimated_value.stream;

  Stream<List<String>> get itemImages => _item_images.stream;

  Stream<String> get message => _message.stream;

  Function(String value) get onPlaceNameChanged => _itemName.sink.add;

  Function(String value) get onEstimatedValueChanged =>
      _estimated_value.sink.add;

  Function(List<String> value) get onItemImageAdded => _item_images.sink.add;

  void loadData(LendingItemModel lendingPlaceModel) {
    _item_images.add(lendingPlaceModel.itemImages!.toList());
  }

  LendingModel getLendingItemModel() {
    return _model.value;
  }

  void createLendingOfferPlace({UserModel? creator}) {
    LendingModel lendingModel;
    if (!validateForm()) {
      _message.add('create');
      var timestamp = DateTime.now().millisecondsSinceEpoch;

      lendingModel = LendingModel(
        id: Utils.getUuid(),
        lendingItemModel: LendingItemModel(
          itemName: _itemName.value,
          estimatedValue: int.parse(_estimated_value.value),
          itemImages: _item_images.value.toList(),
        ),
        creatorId: creator!.sevaUserID!,
        email: creator!.email!,
        timestamp: timestamp,
        lendingType: LendingType.ITEM,
      );
      LendingOffersRepo.addNewLendingItem(model: lendingModel).then((_) {
        _model.add(lendingModel);
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  void updateLendingOfferPlace({LendingModel? model}) async {
    if (model == null) return;
    LendingModel lendingModel = model;
    if (!validateForm()) {
      lendingModel.lendingItemModel!.itemName = _itemName.value;
      lendingModel.lendingItemModel!.estimatedValue =
          int.parse(_estimated_value.value);
      lendingModel.lendingItemModel!.itemImages = _item_images.value.toList();

      LendingOffersRepo.updateNewLendingItem(model: lendingModel).then((_) {
        _model.add(lendingModel);
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  String validateName(String val) {
    if (_itemName.value == null || _itemName.value == '') {
      _itemName.addError(AddItemValidationErrors.itemNameError);
      return AddItemValidationErrors.itemNameError;
    } else if (_itemName.value.substring(0, 1).contains('_') &&
        !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
      _itemName.addError(AddItemValidationErrors.underscore_error);
      return AddItemValidationErrors.underscore_error;
    } else if (profanityDetector.isProfaneString(_itemName.value)) {
      _itemName.addError(AddItemValidationErrors.profanityError);
      return AddItemValidationErrors.profanityError;
    }
    return null!;
  }

  String validateEstimatedVal(String val) {
    if (_estimated_value.value == null ||
        _estimated_value.value == '' ||
        _estimated_value.value == '0') {
      //check if validator working now
      _estimated_value.addError(AddItemValidationErrors.estimated_value_error);
      return AddItemValidationErrors.estimated_value_error;
    }
    return null!;
  }

  bool validateForm() {
    return !(validateName(_itemName.value) == null &&
        validateEstimatedVal(_estimated_value.value.toString()) == null);
  }

  ///[ERROR CHECKS] TO Validate input
  bool errorCheck() {
    bool flag = false;
    if (_itemName.value == null || _itemName.value == '') {
      _itemName.addError(AddItemValidationErrors.itemNameError);
      flag = true;
    } else if (_itemName.value.substring(0, 1).contains('_') &&
        !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
      _itemName.addError(AddItemValidationErrors.underscore_error);
      flag = true;
    } else if (profanityDetector.isProfaneString(_itemName.value)) {
      _itemName.addError(AddItemValidationErrors.profanityError);
      flag = true;
    } else if (_estimated_value.value == null || _estimated_value.value == '') {
      _estimated_value.addError(AddItemValidationErrors.estimated_value_error);
      flag = true;
    }

    return flag;
  }

  @override
  void dispose() {
    _itemName.close();
    _estimated_value.close();
    _item_images.close();
    _model.close();
    _message.close();
    _status.close();
  }
}

class AddItemValidationErrors {
  static const String itemNameError = 'itemName_error';
  static const String estimated_value_error = 'estimated_value_error';
  static const String profanityError = "profanity_error";
  static const String underscore_error = "underscore_error";
}

String getAddItemValidationError(BuildContext context, String errorCode) {
  S error = S.of(context);
  // L error = L.of(context);
  switch (errorCode) {
    case AddItemValidationErrors.itemNameError:
      return error.validation_error_item_name;
      break;
    case AddItemValidationErrors.estimated_value_error:
      return error.validation_error_no_estimated_value_item;
      break;
    case AddItemValidationErrors.profanityError:
      return error.profanity_text_alert;
      break;
    case AddItemValidationErrors.underscore_error:
      return 'Creating offer with "_" is not allowed';
      break;

    default:
      return null!;
      break;
  }
}
