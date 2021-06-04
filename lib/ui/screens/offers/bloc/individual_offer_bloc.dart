import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/ui/utils/offer_utility.dart';
import 'package:sevaexchange/ui/utils/validators.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import '../../../../flavor_config.dart';

class IndividualOfferBloc extends BlocBase with Validators {
  bool allowedCalenderEvent = false;
  bool offerCreatedBool = false;
  var timeOfferType = 0;

  List<String> offerIds = [];

  OfferModel mainOfferModel;
  final _errorMessage = BehaviorSubject<String>();

  final _type = BehaviorSubject<RequestType>();
  final _title = BehaviorSubject<String>();
  final _makePublic = BehaviorSubject<bool>.seeded(false);
  final _makeVirtual = BehaviorSubject<bool>.seeded(false);
  final _offerDescription = BehaviorSubject<String>();
  final _availabilty = BehaviorSubject<String>();
  final _minimumCredits = BehaviorSubject<String>();
  final _location = BehaviorSubject<CustomLocation>();
  final _status = BehaviorSubject<Status>.seeded(Status.IDLE);
  final _isVisible = BehaviorSubject<bool>.seeded(false);
  final _isPublicVisible = BehaviorSubject<bool>.seeded(false);

  final _cashModel = BehaviorSubject<CashModel>.seeded(CashModel(
      donors: [],
      achdetails: ACHModel(),
      paymentType: RequestPaymentType.ACH,
      amountRaised: 0,
      minAmount: 0,
      targetAmount: 0));
  final _goodsDonationDetails = BehaviorSubject<GoodsDonationDetails>.seeded(
      GoodsDonationDetails(address: '', donors: [], requiredGoods: {}));

  final profanityDetector = ProfanityDetector();
  Stream<String> get errorMessage => _errorMessage.stream;

  Function(String value) get onTitleChanged => _title.sink.add;
  Function(String value) get onMinimumCreditsChanged =>
      _minimumCredits.sink.add;
  Function(bool value) get onOfferMadePublic => _makePublic.sink.add;

  Function(String) get onOfferDescriptionChanged => _offerDescription.sink.add;

  Function(String) get onAvailabilityChanged => _availabilty.sink.add;
  Function(CustomLocation) get onLocatioChanged => _location.sink.add;
  Function(RequestType) get onTypeChanged => _type.sink.add;
  Function(CashModel) get onCashModelChanged => _cashModel.sink.add;
  Function(bool) get isVisibleChanged => _isVisible.sink.add;

  void onOfferMadeVirtual(bool value) {
    if (value != null) {
      if (!value) {
        onOfferMadePublic(false);
      }
      _isVisible.add(value);
      _makeVirtual.add(value);
    }
  }

  Function(GoodsDonationDetails) get onGoodsDetailsChanged =>
      _goodsDonationDetails.sink.add;

  Stream<String> get title => _title.stream;
  Stream<bool> get makePublicValue => _makePublic.stream;
  Stream<bool> get makeVirtual => _makeVirtual.stream;
  Stream<String> get offerDescription => _offerDescription.stream;
  Stream<String> get availability => _availabilty.stream;
  Stream<String> get minimumCredits => _minimumCredits.stream;

  Stream<CustomLocation> get location => _location.stream;
  Stream<Status> get status => _status.stream;
  Stream<bool> get isVisible => _isVisible.stream;
  Stream<RequestType> get type => _type.stream;
  Stream<CashModel> get cashModel => _cashModel.stream;

  Stream<GoodsDonationDetails> get goodsDonationDetails =>
      _goodsDonationDetails.stream;

  Stream<bool> get isPublicVisible =>
      CombineLatestStream.combine2(makeVirtual, isVisible, (a, b) => a && b);

  ///[Function] to create offer
  void createOrUpdateOffer(
      {UserModel user, String timebankId, String communityName}) {
    //   print(errorCheck());
    if (!errorCheck()) {
      if (_type.value == RequestType.GOODS &&
          _goodsDonationDetails.value.requiredGoods.length < 1) {
        _errorMessage.add('goods');
      } else {
        var timestamp = DateTime.now().millisecondsSinceEpoch;
        var id = '${user.email}*$timestamp';

        IndividualOfferDataModel individualOfferDataModel =
            IndividualOfferDataModel();

        individualOfferDataModel.title = _title.value;
        individualOfferDataModel.description = _offerDescription.value;
        individualOfferDataModel.schedule = _availabilty.value;
        individualOfferDataModel.minimumCredits = _minimumCredits.value != null
            ? int.parse(_minimumCredits.value)
            : 0;

        individualOfferDataModel.timeOfferType =
            timeOfferType == 0 ? 'SPOT_ON' : 'ONE_TIME';

        OfferModel offerModel = OfferModel(
            id: id,
            email: user.email,
            softDelete: false,
            fullName: user.fullname,
            sevaUserId: user.sevaUserID,
            photoUrlImage: user.photoURL ?? defaultUserImageURL,
            timebankId: timebankId,
            communityId: user.currentCommunity,
            allowedCalenderUsers: allowedCalenderEvent ? [user.email] : [],
            creatorAllowedCalender: allowedCalenderEvent,
            autoGenerated: false,
            isRecurring: false,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            location: _location.value == null ? null : _location.value.location,
            groupOfferDataModel: GroupOfferDataModel(),
            selectedAdrress:
                _location.value == null ? null : _location.value.address,
            individualOfferDataModel: IndividualOfferDataModel()
              ..title = _title.value
              ..description = _offerDescription.value
              ..schedule = _availabilty.value
              ..minimumCredits = _minimumCredits.value != null
                  ? int.parse(_minimumCredits.value)
                  : 0
              ..timeOfferType = timeOfferType == 0 ? 'SPOT_ON' : 'ONE_TIME',
            offerType: OfferType.INDIVIDUAL_OFFER,
            type: _type.value,
            public: _makePublic.value ?? false,
            virtual: _makeVirtual.value ?? false,
            liveMode: !AppConfig.isTestCommunity,
            cashModel: _cashModel.value,
            goodsDonationDetails: _goodsDonationDetails.value,
            timebanksPosted: _makePublic.value ?? false
                ? [timebankId, FlavorConfig.values.timebankId]
                : [timebankId],
            communityName: communityName);
        offerIds.add(offerModel.id);

        createOffer(offerModel: offerModel).then((_) {
          _status.add(Status.COMPLETE);
          mainOfferModel = offerModel;
          offerCreatedBool = true;
        }).catchError((e) => _status.add(Status.ERROR));
      }
    }
  }

  ///[FUNCTION] to update offer
  void updateIndividualOffer(OfferModel offerModel) {
    OfferModel offer = offerModel;
    if (!errorCheck()) {
      if (_type.value == RequestType.GOODS &&
          _goodsDonationDetails.value.requiredGoods.length < 1) {
        _errorMessage.add('goods');
      } else {
        offer.location = _location.value.location;
        offer.selectedAdrress = _location.value.address;
        offer.public = _makePublic.value;
        offer.virtual = _makeVirtual.value;
        offer.timebanksPosted = _makeVirtual.value
            ? [offer.timebankId, FlavorConfig.values.timebankId]
            : [offer.timebankId];
        offer.individualOfferDataModel = IndividualOfferDataModel()
          ..title = _title.value
          ..description = _offerDescription.value
          ..timeOfferType = timeOfferType == 0 ? 'SPOT_ON' : 'ONE_TIME'
          ..schedule = _availabilty.value != null ? _availabilty.value : ''
          ..minimumCredits = _minimumCredits.value != null
              ? int.parse(_minimumCredits.value)
              : 0;

        updateOfferWithRequest(offer: offerModel).then((_) {
          _status.add(Status.COMPLETE);
        }).catchError((e) => _status.add(Status.ERROR));
      }
    }
  }

  ///[PRELOAD DATA FOR UPDATE]
  void loadData(OfferModel offerModel) {
    _title.add(
      offerModel.individualOfferDataModel.title,
    );
    _offerDescription.add(
      offerModel.individualOfferDataModel.description,
    );

    _type.add(offerModel.type);
    _makePublic.add(offerModel.public);
    _makeVirtual.add(offerModel.virtual);
    _goodsDonationDetails.add(offerModel.goodsDonationDetails);
    _cashModel.add(offerModel.cashModel);
    if (offerModel.individualOfferDataModel != null) {
      _minimumCredits
          .add(offerModel.individualOfferDataModel.minimumCredits.toString());
      timeOfferType =
          offerModel.individualOfferDataModel.timeOfferType == 'SPOT_ON'
              ? 0
              : 1;
    }
    if (offerModel.individualOfferDataModel.schedule != null) {
      _availabilty.add(
        offerModel.individualOfferDataModel.schedule,
      );
    }
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
    } else if (_title.value.substring(0, 1).contains('_') &&
        !AppConfig.testingEmails.contains(AppConfig.loggedInEmail)) {
      _title.addError(ValidationErrors.char_error);
      flag = true;
    } else if (profanityDetector.isProfaneString(_title.value)) {
      _title.addError(ValidationErrors.profanityError);
      flag = true;
    }

    if (_offerDescription.value == null || _offerDescription.value == '') {
      _offerDescription.addError(ValidationErrors.genericError);
      flag = true;
    } else if (profanityDetector.isProfaneString(_offerDescription.value)) {
      _offerDescription.addError(ValidationErrors.profanityError);
      flag = true;
    }
    if (_type.value != null) {
      if (_type.value == RequestType.TIME) {
        if (_availabilty.value == null || _availabilty.value == '') {
          _availabilty.addError(ValidationErrors.genericError);
          flag = true;
        } else if (profanityDetector.isProfaneString(_availabilty.value)) {
          _availabilty.addError(ValidationErrors.profanityError);
          flag = true;
        }
        logger.e("minimum credit value -> ${_minimumCredits.value}");
        if (_minimumCredits.value == null || _minimumCredits.value.isEmpty) {
          _minimumCredits.addError(ValidationErrors.minimumCreditsError);
          flag = true;
        }
      } else if (_type.value == RequestType.CASH) {
        if (_cashModel.value.targetAmount == null ||
            _cashModel.value.targetAmount == 0) {
          _cashModel.addError(ValidationErrors.emptyErrorCash);
          flag = true;
        }
      } else if (_type.value == RequestType.GOODS) {
        if (_goodsDonationDetails.value.requiredGoods == null ||
            _goodsDonationDetails.value.requiredGoods.length == 0) {
          _goodsDonationDetails.addError(ValidationErrors.emptyErrorCash);
          flag = true;
        }
      }
    }

    // if (_location.value == null) {
    //   _location.addError(ValidationErrors.genericError);
    //   flag = true;
    // }

    return flag;
  }

  @override
  void dispose() {
    _title.close();
    _offerDescription.close();
    _availabilty.close();
    _location.close();
    _status.close();
    _cashModel.close;
    _goodsDonationDetails.close();
    _type.close();
    _minimumCredits.close();
  }
}
