import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class OfferListBloc extends BlocBase {
  final _myOffers = BehaviorSubject<List<OfferModel>>();
  final _timebankOffers = BehaviorSubject<List<OfferModel>>();

  Stream<List<OfferModel>> get myOffers => _myOffers.stream;
  Stream<List<OfferModel>> get timebankOffers => _timebankOffers.stream;

  @override
  void dispose() {
    _myOffers.close();
    _timebankOffers.close();
  }
}
