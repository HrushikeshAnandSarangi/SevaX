import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/repositories/donations_repository.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class DonationAcceptedBloc extends BlocBase {
  final _donations = BehaviorSubject<List<DonationModel>>();

  Stream<List<DonationModel>> get donations => _donations.stream;

  DonationsRepository _donationsRepository = DonationsRepository();
  void init(String requestId) {
    _donationsRepository.getDonationsOfRequest(requestId).listen((event) {
      List<DonationModel> temp = [];
      event.docs.forEach((element) {
        DonationModel model =
            DonationModel.fromMap(element.data() as Map<String, dynamic>);
        temp.add(model);
      });
      if (!_donations.isClosed) _donations.add(temp);
    });
  }

  void dispose() {
    _donations.close();
  }
}

class DonationAcceptedOfferBloc extends BlocBase {
  final _donations = BehaviorSubject<List<DonationModel>>();

  Stream<List<DonationModel>> get donations => _donations.stream;

  DonationsRepository _donationsRepository = DonationsRepository();
  void init(String offerId) {
    _donationsRepository.getDonationsOfOffer(offerId).listen((event) {
      List<DonationModel> temp = [];
      event.docs.forEach((element) {
        DonationModel model =
            DonationModel.fromMap(element.data() as Map<String, dynamic>);
        temp.add(model);
      });
      if (!_donations.isClosed) _donations.add(temp);
    });
  }

  void dispose() {
    _donations.close();
  }
}
