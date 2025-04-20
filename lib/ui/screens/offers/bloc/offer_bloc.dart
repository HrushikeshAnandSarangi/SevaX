import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/offer_dialogs.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

class OfferBloc extends BlocBase {
  final _participants = BehaviorSubject<List<OfferParticipantsModel>>();
  final _completedParticipants =
      BehaviorSubject<List<TimeOfferParticipantsModel>>();
  final _timeOfferParticipants =
      BehaviorSubject<List<TimeOfferParticipantsModel>>();
  final _totalEarnings = BehaviorSubject<num>.seeded(0.0);

  OfferModel offerModel;

  Stream<List<OfferParticipantsModel>> get participants => _participants.stream;

  Stream<List<TimeOfferParticipantsModel>> get timeOfferParticipants =>
      _timeOfferParticipants.stream;

  Stream<List<TimeOfferParticipantsModel>> get completedParticipants =>
      _completedParticipants.stream;

  Stream<num> get totalEarnings => _totalEarnings.stream;

  void init() {
    CollectionRef.offers
        .doc(offerModel.id)
        .collection("offerParticipants")
        .snapshots()
        .listen((QuerySnapshot snap) {
      List<OfferParticipantsModel> offer = [];
      snap.docs.forEach((DocumentSnapshot doc) {
        OfferParticipantsModel model =
            OfferParticipantsModel.fromJson(doc.data());
        model.id = doc.id;
        offer.add(model);
      });
      _participants.add(offer);
    });

    CollectionRef.offers
        .doc(offerModel.id)
        .collection("offerAcceptors")
        .snapshots()
        .listen((QuerySnapshot snap) async {
      List<TransactionModel> completedParticipantsTransactions =
          await getCompletedMembersTransaction(
              associatedOfferId: offerModel.id);

      List<TimeOfferParticipantsModel> offer = [];
      List<TimeOfferParticipantsModel> completedParticipants = [];
      _totalEarnings.value = 0;

      for (int i = 0; i < snap.docs.length; i++) {
        TimeOfferParticipantsModel model =
            TimeOfferParticipantsModel.fromJSON(snap.docs[i].data());
        offer.add(model);

        for (int j = 0; j < completedParticipantsTransactions.length; j++) {
          if (completedParticipantsTransactions[j].from ==
                  model.participantDetails.sevauserid ||
              completedParticipantsTransactions[j].from == model.timebankId) {
            completedParticipants.add(model);
            _totalEarnings.value +=
                completedParticipantsTransactions[j].credits;
            completedParticipantsTransactions.removeAt(j);
          }
        }
      }
      _timeOfferParticipants.add(offer);
      _completedParticipants.add(completedParticipants);
    });
  }

  Future<List<TransactionModel>> getCompletedMembersTransaction({
    String associatedOfferId,
  }) async {
    var completedParticipants = <TransactionModel>[];

    await CollectionRef.transactions
        .where('offerId', isEqualTo: associatedOfferId)
        .get()
        .then(
          (value) => {
            logger.i(" >>>>>>>> " + value.docs.length.toString()),
            value.docs.forEach((map) {
              var model = TransactionModel.fromMap(map.data());
              completedParticipants.add(model);
            })
          },
        );
    return completedParticipants;
  }

  void handleRequestActions(context, index, ParticipantStatus status) {
    DocumentReference ref = CollectionRef.offers
        .doc(offerModel.id)
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

  void updateOfferAcceptorAction({
    OfferAcceptanceStatus action,
    String offerId,
    String acceptorDocumentId,
    String notificationId,
    @required String hostEmail,
  }) {
    var batch = CollectionRef.batch;

    batch.update(
        CollectionRef.offers
            .doc(offerId)
            .collection("offerAcceptors")
            .doc(acceptorDocumentId),
        {"status": action.readable});

    batch.delete(CollectionRef.users
        .doc(hostEmail)
        .collection('notifications')
        .doc(notificationId));

    batch.commit();
  }

  @override
  void dispose() {
    _participants.close();
  }
}
