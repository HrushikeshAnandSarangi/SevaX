import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class OfferBloc extends BlocBase {
  final _participants = BehaviorSubject<List<OfferParticipantsModel>>();

  Stream<List<OfferParticipantsModel>> get participants => _participants.stream;

  void init(String offerId) {
    Firestore.instance
        .collection("offers")
        .document(offerId)
        .collection("offerParticipants")
        .snapshots()
        .listen((QuerySnapshot snap) {
      List<OfferParticipantsModel> offer = [];
      snap.documents.forEach((DocumentSnapshot doc) {
        offer.add(OfferParticipantsModel.fromJson(doc.data));
      });
      _participants.add(offer);
    });
  }

  @override
  void dispose() {
    _participants.close();
  }
}
