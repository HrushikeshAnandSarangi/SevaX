import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/new_baseline/models/amenities_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_place_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/lending_offer_borrower_update.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../flavor_config.dart';
import '../labels.dart';

class LendingOffersRepo {
  static Future<List<AmenitiesModel>> getAllAmenities() async {
    List<AmenitiesModel> modelList = [];
    await CollectionRef.amenities.get().then((data) {
      data.docs.forEach((document) {
        AmenitiesModel model = AmenitiesModel.fromMap(document.data());
        modelList.add(model);
      });
    });
    return modelList;
  }

  static Future<List<LendingModel>> getAllLendingItems(
      {@required String creatorId}) async {
    List<LendingModel> modelList = [];
    await CollectionRef.lendingItems
        .where('creatorId', isEqualTo: creatorId)
        .get()
        .then((data) {
      data.docs.forEach((document) {
        LendingModel model = LendingModel.fromMap(document.data());
        modelList.add(model);
      });
    });
    return modelList;
  }

  static Future<List<LendingModel>> getAllLendingPlaces(
      {@required String creatorId}) async {
    List<LendingModel> modelList = [];
    await CollectionRef.lendingItems
        .where('creatorId', isEqualTo: creatorId)
        .where('lendingType', isEqualTo: 'PLACE')
        .get()
        .then((data) {
      data.docs.forEach((document) {
        LendingModel model = LendingModel.fromMap(document.data());
        modelList.add(model);
      });
    });
    return modelList;
  }

  static Future<List<LendingModel>> getAllLendingItemModels(
      {@required String creatorId}) async {
    logger.e('items repo ${creatorId}');

    List<LendingModel> modelList = [];
    await CollectionRef.lendingItems
        .where('creatorId', isEqualTo: creatorId)
        .where('lendingType', isEqualTo: 'ITEM')
        .get()
        .then((data) {
      data.docs.forEach((document) {
        LendingModel model = LendingModel.fromMap(document.data());
        modelList.add(model);
        log('items len ${modelList.length}');
      });
    });
    log('items len ${modelList.length}');

    return modelList;
  }

  static Future<List<LendingModel>> getAllLendingModels(
      {@required String creatorId}) async {
    List<LendingModel> modelList = [];
    await CollectionRef.lendingItems
        .where('creatorId', isEqualTo: creatorId)
        .get()
        .then((data) {
      data.docs.forEach((document) {
        LendingModel model = LendingModel.fromMap(document.data());
        modelList.add(model);
      });
    });

    return modelList;
  }

  static Future<List<LendingModel>> getApprovedLendingModels(
      {List<String> lendingModelsIds}) async {
    List<LendingModel> modelList = [];
    for (int i = 0; i < lendingModelsIds.length; i += 1) {
      LendingModel model =
          await getLendingModel(lendingId: lendingModelsIds[i]);
      modelList.add(model);
    }
    return modelList;
  }

  static Future<LendingModel> getLendingModel({String lendingId}) async {
    var documentsnapshot =
        await CollectionRef.lendingItems.doc(lendingId).get();
    LendingModel model = LendingModel.fromMap(documentsnapshot.data());
    return model;
  }

  static Future<void> addAmenitiesToDb({
    String id,
    String title,
    String languageCode,
  }) async {
    await CollectionRef.skills.doc(id).set(
      {'title_' + languageCode ?? 'en': title?.firstWordUpperCase(), 'id': id},
    );
  }

  static Future<void> addNewLendingPlace({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).set(model.toMap());
  }

  static Future<void> updateNewLendingPlace({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).update(model.toMap());
  }

  static Future<void> addNewLendingItem({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).set(model.toMap());
  }

  static Future<void> updateNewLendingItem({LendingModel model}) async {
    await CollectionRef.lendingItems.doc(model.id).update(model.toMap());
  }

  static Future<void> storeAcceptorDataLendingOffer(
      {@required OfferModel model,
      @required LendingOfferAcceptorModel lendingOfferAcceptorModel}) async {
    model.lendingOfferDetailsModel.offerAcceptors
        .add(lendingOfferAcceptorModel.acceptorEmail);
    NotificationsModel notification = NotificationsModel(
        timebankId: model.timebankId,
        id: utils.Utils.getUuid(),
        targetUserId: model.sevaUserId,
        senderUserId: lendingOfferAcceptorModel.acceptorId,
        type: NotificationType.MEMBER_ACCEPT_LENDING_OFFER,
        data: model.toMap(),
        communityId: lendingOfferAcceptorModel.communityId,
        isTimebankNotification: false,
        isRead: false,
        senderPhotoUrl: lendingOfferAcceptorModel.acceptorphotoURL);
    lendingOfferAcceptorModel.notificationId = notification.id;
    WriteBatch batch = CollectionRef.batch;
    var offersRef = CollectionRef.offers.doc(model.id);
    var lenderNotificationRef =
        CollectionRef.userNotification(model.email).doc(notification.id);
    var offerAcceptorsReference = CollectionRef.lendingOfferAcceptors(model.id)
        .doc(lendingOfferAcceptorModel.id);
    batch.update(offersRef, {
      'lendingOfferDetailsModel.offerAcceptors':
          FieldValue.arrayUnion([lendingOfferAcceptorModel.acceptorEmail]),
    });

    batch.set(
      offerAcceptorsReference,
      lendingOfferAcceptorModel.toMap(),
      SetOptions(merge: true),
    );
    batch.set(
      lenderNotificationRef,
      notification.toMap(),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  static Future<void> removeAcceptorLending({
    @required OfferModel model,
    @required String acceptorEmail,
  }) async {
    WriteBatch batch = CollectionRef.batch;
    var offersRef = CollectionRef.offers.doc(model.id);

    LendingOfferAcceptorModel lendingOfferAcceptorModel =
        await getBorrowAcceptorModel(
            offerId: model.id, acceptorEmail: acceptorEmail);
    var offerAcceptorsReference = CollectionRef.lendingOfferAcceptors(model.id)
        .doc(lendingOfferAcceptorModel.id);
    batch.update(offersRef, {
      'lendingOfferDetailsModel.offerAcceptors':
          FieldValue.arrayRemove([acceptorEmail]),
    });
    batch.update(
        CollectionRef.userNotification(model.email)
            .doc(lendingOfferAcceptorModel.notificationId),
        {"isRead": true});
    batch.delete(offerAcceptorsReference);
    await batch.commit();
  }

  static Stream<List<LendingOfferAcceptorModel>> getLendingOfferAcceptors(
      {@required offerId}) async* {
    var data = CollectionRef.lendingOfferAcceptors(offerId).snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot,
          List<LendingOfferAcceptorModel>>.fromHandlers(
        handleData: (snapshot, acceptorsList) {
          List<LendingOfferAcceptorModel> offerList = [];
          snapshot.docs.forEach(
            (documentSnapshot) {
              LendingOfferAcceptorModel model =
                  LendingOfferAcceptorModel.fromMap(documentSnapshot.data());
              offerList.add(model);
            },
          );
          acceptorsList.add(offerList);
        },
      ),
    );
  }

  static Future<void> updateOfferAcceptorActionRejected(
      {OfferAcceptanceStatus action,
      @required OfferModel model,
      @required LendingOfferAcceptorModel lendingOfferAcceptorModel}) async {
    var batch = CollectionRef.batch;
    NotificationsModel notification = NotificationsModel(
        timebankId: model.timebankId,
        id: utils.Utils.getUuid(),
        targetUserId: lendingOfferAcceptorModel.acceptorId,
        senderUserId: model.sevaUserId,
        type: NotificationType.NOTIFICATION_TO_BORROWER_REJECTED_LENDING_OFFER,
        data: model.toMap(),
        communityId: lendingOfferAcceptorModel.communityId,
        isTimebankNotification: false,
        isRead: false,
        senderPhotoUrl: model.photoUrlImage);
    var offersRef = CollectionRef.offers.doc(model.id);

    batch.update(offersRef, {
      'lendingOfferDetailsModel.offerAcceptors':
          FieldValue.arrayRemove([lendingOfferAcceptorModel.acceptorEmail]),
    });
    var acceptorNotificationRef =
        CollectionRef.userNotification(lendingOfferAcceptorModel.acceptorEmail)
            .doc(notification.id);
    batch.update(
        CollectionRef.lendingOfferAcceptors(model.id)
            .doc(lendingOfferAcceptorModel.id),
        {"status": action.readable});
    batch.set(
      acceptorNotificationRef,
      notification.toMap(),
      SetOptions(merge: true),
    );
    batch.update(
        CollectionRef.userNotification(model.email)
            .doc(lendingOfferAcceptorModel.notificationId),
        {"isRead": true});

    batch.commit();
  }

  static Future<LendingOfferAcceptorModel> getBorrowAcceptorModel(
      {String offerId, String acceptorEmail}) async {
    LendingOfferAcceptorModel model;
    await CollectionRef.lendingOfferAcceptors(offerId)
        .where('acceptorEmail', isEqualTo: acceptorEmail)
        .get()
        .then((data) {
      data.docs.forEach((document) {
        model = LendingOfferAcceptorModel.fromMap(document.data());
      });
    });
    return model;
  }

  static Stream<OfferModel> getOfferStream({
    @required String offerId,
  }) async* {
    var data = CollectionRef.offers.doc(offerId).snapshots();

    yield* data.transform(
      StreamTransformer<DocumentSnapshot, OfferModel>.fromHandlers(
        handleData: (snapshot, offerSink) {
          OfferModel model = OfferModel.fromMap(snapshot.data());
          model.id = snapshot.id;
          offerSink.add(model);
        },
      ),
    );
  }

  static Future<LendingOfferAcceptorModel> updateLendingParticipantModel(
      {LendingOfferAcceptorModel model, String offerId}) async {
    await CollectionRef.lendingOfferAcceptors(offerId)
        .doc(model.id)
        .update(model.toMap());
    return model;
  }

  static Future<void> approveLendingOffer(
      {@required OfferModel model,
      @required LendingOfferAcceptorModel lendingOfferAcceptorModel,
      @required String lendingOfferApprovedAgreementLink,
      String additionalInstructionsText,
      String agreementId}) async {
    model.lendingOfferDetailsModel.offerAcceptors
        .remove(lendingOfferAcceptorModel.acceptorEmail);
    model.lendingOfferDetailsModel.approvedUsers
        .add(lendingOfferAcceptorModel.acceptorEmail);
    model.lendingOfferDetailsModel.lendingOfferApprovedAgreementLink =
        lendingOfferApprovedAgreementLink ?? '';

    if (model.lendingOfferDetailsModel.lendingModel.lendingType ==
        LendingType.PLACE) {
      model.lendingOfferDetailsModel.checkedOut = false;
    } else {
      model.lendingOfferDetailsModel.returnedItems = false;
    }
    model.lendingOfferDetailsModel.approvedStartDate =
        lendingOfferAcceptorModel.startDate;
    model.lendingOfferDetailsModel.approvedEndDate =
        lendingOfferAcceptorModel.endDate;
    NotificationsModel notification = NotificationsModel(
        timebankId: model.timebankId,
        id: utils.Utils.getUuid(),
        targetUserId: lendingOfferAcceptorModel.acceptorId,
        senderUserId: model.sevaUserId,
        type: NotificationType.NOTIFICATION_TO_BORROWER_APPROVED_LENDING_OFFER,
        data: model.toMap(),
        communityId: lendingOfferAcceptorModel.communityId,
        isTimebankNotification: false,
        isRead: false,
        senderPhotoUrl: model.photoUrlImage);
    WriteBatch batch = CollectionRef.batch;
    var offersRef = CollectionRef.offers.doc(model.id);
    var acceptorNotificationRef =
        CollectionRef.userNotification(lendingOfferAcceptorModel.acceptorEmail)
            .doc(notification.id);
    var offerAcceptorsReference = CollectionRef.lendingOfferAcceptors(model.id)
        .doc(lendingOfferAcceptorModel.id);
    batch.update(offersRef, model.toMap());
    batch.update(
        CollectionRef.userNotification(model.email)
            .doc(lendingOfferAcceptorModel.notificationId),
        {"isRead": true});
    batch.update(offerAcceptorsReference, {
      "status": LendingOfferStatus.APPROVED.readable,
      "isApproved": true,
      'additionalInstructions': additionalInstructionsText ?? '',
      'startDate': lendingOfferAcceptorModel.startDate,
      'endDate': lendingOfferAcceptorModel.endDate,
      'approvedAgreementId': agreementId.isNotEmpty ? agreementId : '',
      'borrowAgreementLink': lendingOfferApprovedAgreementLink,
    });
    batch.set(
      acceptorNotificationRef,
      notification.toMap(),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  static Future<LendingOfferAcceptorModel> getApprovedModel(
      {String offerId, String acceptorEmail}) async {
    LendingOfferAcceptorModel model;
    await CollectionRef.lendingOfferAcceptors(offerId)
        .where('acceptorEmail', isEqualTo: acceptorEmail)
        .where('status', isNotEqualTo: LendingOfferStatus.REJECTED.readable)
        .get()
        .then((data) {
      data.docs.forEach((document) {
        model.id = document.id;
        if (document.data()['status'] == LendingOfferStatus.ACCEPTED.readable ||
            document.data()['status'] ==
                LendingOfferStatus.CHECKED_OUT.readable ||
            document.data()['status'] ==
                LendingOfferStatus.ITEMS_RETURNED.readable) {
          //dont add
        } else {
          model = LendingOfferAcceptorModel.fromMap(document.data());
        }
      });
    });
    return model;
  }

  static Stream<LendingOfferAcceptorModel> getApprovedModelStream(
      {String offerId, String acceptorEmail}) async* {
    var data = await CollectionRef.lendingOfferAcceptors(offerId)
        .where('acceptorEmail', isEqualTo: acceptorEmail)
        .where('status', isNotEqualTo: LendingOfferStatus.REJECTED.readable)
        .snapshots();

    yield* data.transform(
      StreamTransformer<QuerySnapshot, LendingOfferAcceptorModel>.fromHandlers(
        handleData: (snapshot, requestSink) {
          snapshot.docs.forEach((document) {
            LendingOfferAcceptorModel model =
                LendingOfferAcceptorModel.fromMap(document.data());
            model.id = document.id;
            if (model.status == LendingOfferStatus.ACCEPTED ||
                model.status == LendingOfferStatus.CHECKED_OUT ||
                model.status == LendingOfferStatus.ITEMS_RETURNED) {
              //dont add
            } else {
              requestSink.add(model);
            }
          });
        },
      ),
    );
  }

  static Future<void> updateLendingOfferStatus(
      {@required OfferModel offerModel,
      @required LendingOfferAcceptorModel lendingOfferAcceptorModel,
      @required LendingOfferStatus lendingOfferStatus}) async {
    NotificationType notificationType;
    if (lendingOfferStatus == LendingOfferStatus.CHECKED_IN) {
      notificationType =
          NotificationType.NOTIFICATION_TO_LENDER_PLACE_CHECKED_IN;
      offerModel.lendingOfferDetailsModel.checkedIn = true;
    } else if (lendingOfferStatus == LendingOfferStatus.CHECKED_OUT) {
      notificationType =
          NotificationType.NOTIFICATION_TO_LENDER_PLACE_CHECKED_OUT;
      if (offerModel.lendingOfferDetailsModel.lendingOfferTypeMode ==
          'ONE_TIME') {
        offerModel.acceptedOffer = true;
      }
      offerModel.lendingOfferDetailsModel.checkedOut = true;
      offerModel.lendingOfferDetailsModel.checkedIn = false;
      offerModel.lendingOfferDetailsModel.approvedUsers
          .remove(lendingOfferAcceptorModel.acceptorEmail);
      offerModel.lendingOfferDetailsModel.completedUsers
          .add(lendingOfferAcceptorModel.acceptorEmail);
    } else if (lendingOfferStatus == LendingOfferStatus.ITEMS_COLLECTED) {
      notificationType =
          NotificationType.NOTIFICATION_TO_LENDER_ITEMS_COLLECTED;
      offerModel.lendingOfferDetailsModel.collectedItems = true;
    } else if (lendingOfferStatus == LendingOfferStatus.ITEMS_RETURNED) {
      notificationType = NotificationType.NOTIFICATION_TO_LENDER_ITEMS_RETURNED;
      if (offerModel.lendingOfferDetailsModel.lendingOfferTypeMode ==
          'ONE_TIME') {
        offerModel.acceptedOffer = true;
      }
      offerModel.lendingOfferDetailsModel.returnedItems = true;
      offerModel.lendingOfferDetailsModel.collectedItems = false;
      offerModel.lendingOfferDetailsModel.approvedUsers
          .remove(lendingOfferAcceptorModel.acceptorEmail);
      offerModel.lendingOfferDetailsModel.completedUsers
          .add(lendingOfferAcceptorModel.acceptorEmail);
    }

    NotificationsModel notification = NotificationsModel(
        timebankId: offerModel.timebankId,
        id: utils.Utils.getUuid(),
        targetUserId: offerModel.sevaUserId,
        senderUserId: lendingOfferAcceptorModel.acceptorId,
        type: notificationType,
        data: offerModel.toMap(),
        communityId: offerModel.communityId,
        isTimebankNotification: false,
        isRead: false,
        senderPhotoUrl: offerModel.photoUrlImage);

    WriteBatch batch = CollectionRef.batch;
    var offersRef = CollectionRef.offers.doc(offerModel.id);
    var lenderNotificationRef =
        CollectionRef.userNotification(offerModel.email).doc(notification.id);
    var offerAcceptorsReference =
        CollectionRef.lendingOfferAcceptors(offerModel.id)
            .doc(lendingOfferAcceptorModel.id);
    batch.update(offersRef, offerModel.toMap());
    batch.update(offerAcceptorsReference, {
      "status": lendingOfferStatus.readable,
    });
    batch.set(
      lenderNotificationRef,
      notification.toMap(),
      SetOptions(merge: true),
    );
    if (lendingOfferStatus == LendingOfferStatus.ITEMS_RETURNED ||
        lendingOfferStatus == LendingOfferStatus.CHECKED_OUT) {
      NotificationsModel feedbackNotification = NotificationsModel(
          timebankId: offerModel.timebankId,
          id: utils.Utils.getUuid(),
          targetUserId: lendingOfferAcceptorModel.acceptorId,
          senderUserId: offerModel.sevaUserId,
          type: NotificationType.NOTIFICATION_TO_BORROWER_FOR_LENDING_FEEDBACK,
          data: offerModel.toMap(),
          communityId: lendingOfferAcceptorModel.communityId,
          isTimebankNotification: false,
          isRead: false,
          senderPhotoUrl: offerModel.photoUrlImage);
      batch.set(
        CollectionRef.userNotification(lendingOfferAcceptorModel.acceptorEmail)
            .doc(feedbackNotification.id),
        feedbackNotification.toMap(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  static void getDialogForBorrowerToUpdate({
    BuildContext context,
    OfferModel offerModel,
    LendingOfferAcceptorModel lendingOfferAcceptorModel,
  }) async {
    showDialog(
      context: context,
      builder: (BuildContext viewContext) {
        return LendingOfferBorrowerUpdateWidget(
          offerModel: offerModel,
          lendingOfferAcceptorModel: lendingOfferAcceptorModel,
        );
      },
    );
  }
}
