import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/widgets/hide_blocked_content.dart';

class OfferListBloc extends BlocBase {
  final _myOffers = BehaviorSubject<List<OfferModel>>();
  final _timebankOffers = BehaviorSubject<List<OfferModel>>();
  final _offers = BehaviorSubject<OfferLists>();
  final _filter = BehaviorSubject<OfferFilter>.seeded(OfferFilter());

  Stream<List<OfferModel>> get myOffers => _myOffers.stream;
  Stream<List<OfferModel>> get timebankOffers => _timebankOffers.stream;
  Stream<OfferLists> get offers => _offers.stream;
  Stream<OfferFilter> get filter => _filter.stream;
  Function(OfferFilter) get onFilterChange => _filter.sink.add;

  void init(String timebankId, UserModel user) {
    var userId = user.sevaUserID;
    var allOffers = getOffersStream(
            timebankId: timebankId, loggedInMemberSevaUserId: userId!)
        .asBroadcastStream();

    CombineLatestStream.combine2<List<OfferModel>, OfferFilter, OfferLists>(
        allOffers, filter, (models, filter) {
      OfferLists offerLists = OfferLists([], []);
      models.forEach((model) {
        if (!HideBlockedContent.checkIfBlocked(model.sevaUserId!, user)) {
          if (filter.checkFilter(model)) {
            offerLists.addOffer(userId, model);
          }
        }
      });

      return offerLists;
    }).listen((value) {
      _offers.add(value);
    });
  }

  @override
  void dispose() {
    _myOffers.close();
    _timebankOffers.close();
    _offers.close();
    _filter.close();
  }
}

class OfferLists {
  final List<OfferModel> myOffers;
  final List<OfferModel> communityoffers;

  void addOffer(String userId, OfferModel model) {
    if (model.sevaUserId == userId) {
      myOffers?.add(model);
    } else {
      communityoffers?.add(model);
    }
  }

  bool get isEmpty => communityoffers.isEmpty && myOffers.isEmpty;

  OfferLists(this.myOffers, this.communityoffers);
}

class OfferFilter {
  final bool timeOffer;
  final bool goodsOffer;
  final bool oneToManyOffer;
  final bool cashOffer;
  final bool lendingOffer;
  final bool publicOffer;
  final bool virtualOffer;

  OfferFilter({
    this.timeOffer = false,
    this.goodsOffer = false,
    this.cashOffer = false,
    this.lendingOffer = false,
    this.oneToManyOffer = false,
    this.publicOffer = false,
    this.virtualOffer = false,
  });

  OfferFilter copyWith({
    bool? timeOffer,
    bool? goodsOffer,
    bool? cashOffer,
    bool? publicOffer,
    bool? virtualOffer,
    bool? oneToManyOffer,
    bool? lendingOffer,
  }) =>
      OfferFilter(
        timeOffer: timeOffer ?? this.timeOffer,
        goodsOffer: goodsOffer ?? this.goodsOffer,
        cashOffer: cashOffer ?? this.cashOffer,
        publicOffer: publicOffer ?? this.publicOffer,
        virtualOffer: virtualOffer ?? this.virtualOffer,
        oneToManyOffer: oneToManyOffer ?? this.oneToManyOffer,
        lendingOffer: lendingOffer ?? this.lendingOffer,
      );

  bool get isFilterSelected =>
      timeOffer ||
      goodsOffer ||
      cashOffer ||
      publicOffer ||
      virtualOffer ||
      lendingOffer ||
      oneToManyOffer;

  bool operator ==(Object other) {
    if (other is OfferFilter) {
      return this.timeOffer == other.timeOffer &&
          this.goodsOffer == other.goodsOffer &&
          this.cashOffer == other.cashOffer &&
          this.publicOffer == other.publicOffer &&
          this.virtualOffer == other.virtualOffer &&
          this.oneToManyOffer == other.oneToManyOffer &&
          this.lendingOffer == other.lendingOffer;
    } else {
      return false;
    }
  }

  bool checkFilter(OfferModel model) {
    if (isFilterSelected) {
      if (oneToManyOffer && model.offerType == OfferType.GROUP_OFFER) {
        return true;
      } else if (timeOffer &&
          model.offerType == OfferType.INDIVIDUAL_OFFER &&
          model.type == RequestType.TIME) {
        return true;
      } else if (cashOffer &&
          model.offerType == OfferType.INDIVIDUAL_OFFER &&
          model.type == RequestType.CASH) {
        return true;
      } else if (goodsOffer &&
          model.offerType == OfferType.INDIVIDUAL_OFFER &&
          model.type == RequestType.GOODS) {
        return true;
      } else if (lendingOffer &&
          model.offerType == OfferType.INDIVIDUAL_OFFER &&
          model.type == RequestType.LENDING_OFFER) {
        return true;
      } else if (publicOffer && model.public!) {
        return true;
      } else if (virtualOffer && model.virtual!) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}
