import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/offer_dialogs.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class TimeOfferBloc extends BlocBase {
  final _participants = BehaviorSubject<List<TimeOfferParticipantsModel>>();
  OfferModel? offerModel;

  Stream<List<TimeOfferParticipantsModel>> get participants =>
      _participants.stream;

  void init() {
    CollectionRef.offers
        .doc(offerModel!.id)
        .collection("offerParticipants")
        .snapshots()
        .listen((QuerySnapshot snap) {
      List<TimeOfferParticipantsModel> offer = [];
      snap.docs.forEach((DocumentSnapshot doc) {
        TimeOfferParticipantsModel model = TimeOfferParticipantsModel.fromJSON(
            doc.data() as Map<String, dynamic>);
        model.id = doc.id;
        offer.add(model);
      });
      _participants.add(offer);
    });
  }

  void handleRequestActions(context, index, ParticipantStatus status) {
    DocumentReference ref = CollectionRef.offers
        .doc(offerModel!.id)
        .collection("offerParticipants")
        .doc(_participants.value[index].id);

    if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
      ref.update(
        {
          "status":
              ParticipantStatus.NO_ACTION_FROM_CREATOR.toString().split('.')[1],
        },
      );
    }
    if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
      ref.update(
        {
          "status": ParticipantStatus.CREATOR_REQUESTED_CREDITS
              .toString()
              .split('.')[1]
        },
      );
    }

    if ([
      ParticipantStatus.MEMBER_DID_NOT_ATTEND,
      ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST,
      ParticipantStatus.MEMBER_TRANSACTION_FAILED
    ].contains(status)) {
      requestAgainDialog(context, ref);
    }
  }

  @override
  void dispose() {
    _participants.close();
  }
}
