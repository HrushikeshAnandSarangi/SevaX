import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';

import 'individual_offer_bloc.dart';

class OneToManyOfferBloc extends BlocBase {
  int startTime;
  int endTime;
  final _title = BehaviorSubject<String>();
  final _preparationHours = BehaviorSubject<String>();
  final _classHours = BehaviorSubject<String>();
  final _classDescription = BehaviorSubject<String>();
  final _location = BehaviorSubject<CustomLocation>();
  final _status = BehaviorSubject<Status>.seeded(Status.IDLE);

  Function(String value) get onTitleChanged => _title.sink.add;
  Function(String) get onPreparationHoursChanged => _preparationHours.sink.add;
  Function(String) get onClassHoursChanged => _classHours.sink.add;
  Function(String) get onclassDescriptionChanged => _classDescription.sink.add;
  Function(CustomLocation) get onLocatioChanged => _location.sink.add;

  Stream<String> get title => _title.stream;
  Stream<String> get preparationHours => _preparationHours.stream;
  Stream<String> get classHours => _classHours.stream;
  Stream<String> get classDescription => _classDescription.stream;
  Stream<CustomLocation> get location => _location.stream;

  Stream<Status> get status => _status.stream;

  ///[Function] to create or update offer
  void createOrUpdateOffer({UserModel user, String timebankId}) {
    print(errorCheck());
    if (!errorCheck()) {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var id = '${user.email}*$timestamp';

      OfferModel offerModel = OfferModel(
        id: id,
        email: user.email,
        fullName: user.fullname,
        sevaUserId: user.sevaUserID,
        timebankId: timebankId,
        selectedAdrress: _location.value.address,
        timestamp: timestamp,
        location: _location.value == null
            ? GeoFirePoint(40.754387, -73.984291)
            : _location.value.location,
        groupOfferDataModel: GroupOfferDataModel()
          ..classTitle = _title.value
          ..startDate = startTime
          ..endDate = endTime
          ..numberOfPreperationHours = int.parse(_preparationHours.value)
          ..numberOfClassHours = int.parse(_classHours.value)
          ..classDescription = _classDescription.value,
        individualOfferDataModel: IndividualOfferDataModel(),
        offerType: OfferType.GROUP_OFFER,
      );

      createOffer(offerModel: offerModel).then((_) {
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  void updateOneToManyOffer(OfferModel offerModel) {
    OfferModel offer = offerModel;
    if (!errorCheck()) {
      offer.location = _location.value.location;
      offer.selectedAdrress = _location.value.address;
      offer.groupOfferDataModel = GroupOfferDataModel()
        ..classTitle = _title.value.replaceAll('__*__', '')
        ..startDate = startTime
        ..endDate = endTime
        ..numberOfPreperationHours =
            int.parse(_preparationHours.value.replaceAll('__*__', ''))
        ..numberOfClassHours =
            int.parse(_classHours.value.replaceAll('__*__', ''))
        ..classDescription = _classDescription.value.replaceAll('__*__', '');

      updateOfferWithRequest(offer: offerModel).then((_) {
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  ///[PRELOAD DATA FOR UPDATE]
  void loadData(OfferModel offerModel) {
    _title.add(
      offerModel.groupOfferDataModel.classTitle + '__*__',
    );
    _preparationHours.add(
      offerModel.groupOfferDataModel.numberOfPreperationHours.toString() +
          '__*__',
    );
    _classHours.add(
      offerModel.groupOfferDataModel.numberOfClassHours.toString() + '__*__',
    );
    _classDescription.add(
      offerModel.groupOfferDataModel.classDescription + '__*__',
    );
    _location.add(
      CustomLocation(
        offerModel.location,
        offerModel.selectedAdrress,
      ),
    );
  }

  ///[ERROR CHECKS] TO Validate input
  bool errorCheck() {
    bool flag = false;
    if (_title.value == null || _title.value == '') {
      _title.addError(ValidationErrors.titleError);
      flag = true;
    }
    if (_classDescription.value == null || _classDescription.value == '') {
      _classDescription.addError(ValidationErrors.genericError);
      flag = true;
    }
    if (_classHours.value == null ||
        _classHours.value == '' ||
        !_isNumeric(_classHours.value?.replaceAll('__*__', ''))) {
      _classHours.addError(
        !_isNumeric(_classHours.value?.replaceAll('__*__', ''))
            ? ValidationErrors.hoursNotInt
            : ValidationErrors.classHours,
      );
      flag = true;
    }

    if (_preparationHours.value == null ||
        _preparationHours.value == '' ||
        !_isNumeric(_preparationHours.value?.replaceAll('__*__', ''))) {
      _preparationHours.addError(
        !_isNumeric(_preparationHours.value?.replaceAll('__*__', ''))
            ? ValidationErrors.hoursNotInt
            : ValidationErrors.preprationTimeError,
      );
      flag = true;
    }

    if (_location.value == null) {
      _location.addError(ValidationErrors.genericError);
      flag = true;
    }
    return flag;
  }

  @override
  void dispose() {
    _title.close();
    _classDescription.close();
    _preparationHours.close();
    _classHours.close();
    _location.close();
    _status.close();
  }

  bool _isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }
}
