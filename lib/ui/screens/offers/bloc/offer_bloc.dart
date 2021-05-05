import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/offer_dialogs.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class OfferBloc extends BlocBase {
  final _participants = BehaviorSubject<List<OfferParticipantsModel>>();
  final _timeOfferParticipants =
      BehaviorSubject<List<TimeOfferParticipantsModel>>();
  OfferModel offerModel;

  Stream<List<OfferParticipantsModel>> get participants => _participants.stream;
  Stream<List<TimeOfferParticipantsModel>> get timeOfferParticipants =>
      _timeOfferParticipants.stream;

  void init() {
    Firestore.instance
        .collection("offers")
        .document(offerModel.id)
        .collection("offerParticipants")
        .snapshots()
        .listen((QuerySnapshot snap) {
      List<OfferParticipantsModel> offer = [];
      snap.documents.forEach((DocumentSnapshot doc) {
        OfferParticipantsModel model =
            OfferParticipantsModel.fromJson(doc.data);
        model.id = doc.documentID;
        offer.add(model);
      });
      _participants.add(offer);
    });

    Firestore.instance
        .collection("offers")
        .document(offerModel.id)
        .collection("offerAcceptors")
        .snapshots()
        .listen((QuerySnapshot snap) {
      List<TimeOfferParticipantsModel> offer = [];
      snap.documents.forEach((DocumentSnapshot doc) {
        TimeOfferParticipantsModel model =
            TimeOfferParticipantsModel.fromJSON(doc.data);
        model.id = doc.documentID;
        offer.add(model);
      });
      _timeOfferParticipants.add(offer);
    });
  }

  void handleRequestActions(context, index, ParticipantStatus status) {
    DocumentReference ref = Firestore.instance
        .collection("offers")
        .document(offerModel.id)
        .collection("offerParticipants")
        .document(_participants.value[index].id);

    if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
      ref.updateData(
        {
          "status":
              ParticipantStatus.NO_ACTION_FROM_CREATOR.toString().split('.')[1],
        },
      );
    }
    if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
      ref.updateData(
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

  void updateOfferAcceptorAction({
    OfferAcceptanceStatus action,
    String offerId,
    String acceptorDocumentId,
    String notificationId,
    @required String hostEmail,
  }) {
    var batch = Firestore.instance.batch();

    batch.updateData(
        Firestore.instance
            .collection("offers")
            .document(offerId)
            .collection("offerAcceptors")
            .document(acceptorDocumentId),
        {"status": action.readable});

    batch.delete(Firestore.instance
        .collection('users')
        .document(hostEmail)
        .collection('notifications')
        .document(notificationId));

    batch.commit();
  }

  @override
  void dispose() {
    _participants.close();
  }
}
