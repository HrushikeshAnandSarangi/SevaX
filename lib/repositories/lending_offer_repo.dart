import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;

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
    log('items repo ${creatorId}');

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
        communityId: model.communityId,
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

  static Future<void> updateOfferAcceptorAction(
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

  static Future<void> approveLendingOffer(
      {@required OfferModel model,
      @required LendingOfferAcceptorModel lendingOfferAcceptorModel,
      @required String lendingOfferApprovedAgreementLink,
      String additionalInstructionsText}) async {
    model.lendingOfferDetailsModel.offerAcceptors
        .remove(lendingOfferAcceptorModel.acceptorEmail);
    model.lendingOfferDetailsModel.approvedUsers
        .add(lendingOfferAcceptorModel.acceptorEmail);
    model.lendingOfferDetailsModel.lendingOfferApprovedAgreementLink =
        lendingOfferApprovedAgreementLink ?? '';
    // if (model.lendingOfferDetailsModel.lendingModel.lendingType ==
    //     LendingType.PLACE) {
    //   model.lendingOfferDetailsModel.checkedIn = true;
    // } else {
    //   model.lendingOfferDetailsModel.collectedItems = true;
    // }
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
      'additionalInstructions': additionalInstructionsText ?? ''
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
        model = LendingOfferAcceptorModel.fromMap(document.data());
      });
    });
    return model;
  }

  static void getDialogForBorrower(
      {String offerId, String acceptorEmail}) async {}
}
