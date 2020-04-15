import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';

class IndividualOfferBloc extends BlocBase with Validators {
  final _title = BehaviorSubject<String>();
  final _offerDescription = BehaviorSubject<String>();
  final _availabilty = BehaviorSubject<String>();
  final _location = BehaviorSubject<CustomLocation>();
  final _status = BehaviorSubject<Status>.seeded(Status.IDLE);

  Function(String value) get onTitleChanged => _title.sink.add;
  Function(String) get onOfferDescriptionChanged => _offerDescription.sink.add;
  Function(String) get onAvailabilityChanged => _availabilty.sink.add;
  Function(CustomLocation) get onLocatioChanged => _location.sink.add;

  Stream<String> get title => _title.stream;
  Stream<String> get offerDescription => _offerDescription.stream;
  Stream<String> get availability => _availabilty.stream;
  Stream<CustomLocation> get location => _location.stream;
  Stream<Status> get status => _status.stream;

  ///[Function] to create offer
  void createOrUpdateOffer({UserModel user, String timebankId}) {
    print(errorCheck());
    if (!errorCheck()) {
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var id = '${user.email}*$timestamp';

      IndividualOfferDataModel individualOfferDataModel =
          IndividualOfferDataModel();

      individualOfferDataModel.title = _title.value;
      individualOfferDataModel.description = _offerDescription.value;
      individualOfferDataModel.schedule = _availabilty.value;

      OfferModel offerModel = OfferModel(
        id: id,
        email: user.email,
        fullName: user.fullname,
        sevaUserId: user.sevaUserID,
        timebankId: timebankId,
        communityId: user.currentCommunity,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        location: _location.value == null
            ? GeoFirePoint(40.754387, -73.984291)
            : _location.value.location,
        groupOfferDataModel: GroupOfferDataModel(),
        selectedAdrress: _location.value.address,
        individualOfferDataModel: IndividualOfferDataModel()
          ..title = _title.value
          ..description = _offerDescription.value
          ..schedule = _availabilty.value,
        offerType: OfferType.INDIVIDUAL_OFFER,
      );

      createOffer(offerModel: offerModel).then((_) {
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  ///[FUNCTION] to update offer
  void updateIndividualOffer(OfferModel offerModel) {
    OfferModel offer = offerModel;
    if (!errorCheck()) {
      offer.location = _location.value.location;
      offer.selectedAdrress = _location.value.address;
      offer.individualOfferDataModel = IndividualOfferDataModel()
        ..title = _title.value.replaceAll('__*__', '')
        ..description = _offerDescription.value.replaceAll('__*__', '')
        ..schedule = _availabilty.value.replaceAll('__*__', '');

      updateOfferWithRequest(offer: offerModel).then((_) {
        _status.add(Status.COMPLETE);
      }).catchError((e) => _status.add(Status.ERROR));
    }
  }

  ///[PRELOAD DATA FOR UPDATE]
  void loadData(OfferModel offerModel) {
    _title.add(
      offerModel.individualOfferDataModel.title + '__*__',
    );
    _offerDescription.add(
      offerModel.individualOfferDataModel.description + '__*__',
    );
    _availabilty.add(
      offerModel.individualOfferDataModel.schedule + '__*__',
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
    if (_offerDescription.value == null || _offerDescription.value == '') {
      _offerDescription.addError(ValidationErrors.genericError);
      flag = true;
    }
    if (_availabilty.value == null || _availabilty.value == '') {
      _availabilty.addError(ValidationErrors.genericError);
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
    _offerDescription.close();
    _availabilty.close();
    _location.close();
    _status.close();
  }
}


