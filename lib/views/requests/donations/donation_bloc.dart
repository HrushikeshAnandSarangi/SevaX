import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class DonationBloc {
  final _goodsDescription = BehaviorSubject<String>();
  final _amountPledged = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();
  final _comment = BehaviorSubject<String>();
  final _selectedList =
      BehaviorSubject<Map<String, String>>.seeded(Map<String, String>());

  Stream<String> get goodsDescription => _goodsDescription.stream;
  Stream<String> get amountPledged => _amountPledged.stream;
  Stream<String> get commentEntered => _comment.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<Map<dynamic, dynamic>> get selectedList => _selectedList.stream;

  Map<dynamic, dynamic> get selectedListVal => _selectedList.value;

  Function(String) get onDescriptionChange => _goodsDescription.sink.add;
  Function(String) get onAmountChange => _amountPledged.sink.add;
  Function(String) get onCommentChanged => _comment.sink.add;

  void addAddRemove({String selectedKey, String selectedValue}) {
    var localMap = _selectedList.value;

    localMap.containsKey(selectedKey)
        ? localMap.remove(selectedKey)
        : localMap[selectedKey] = selectedValue;

    _selectedList.add(localMap);
  }

  Future<bool> donateOfferGoods(
      {DonationModel donationModel,
      OfferModel offerModel,
      String notificationId,
      UserModel notify,}) async {
//      donationModel.goodsDetails.donatedGoods = _selectedList.value;
    if (offerModel.type == RequestType.GOODS) {
      if (_selectedList == null || _selectedList.value.isEmpty) {
        _errorMessage.add('goods');
        return false;
      } else {
        donationModel.requestIdType = 'offer';
        donationModel.goodsDetails.comments = _comment.value;
        donationModel.goodsDetails.requiredGoods = _selectedList.value;
        donationModel.goodsDetails.toAddress =
            donationModel.goodsDetails.toAddress;
        var newDonors =
            new List<String>.from(offerModel.goodsDonationDetails.donors);
        newDonors.add(donationModel.donatedTo);
        offerModel.goodsDonationDetails.donors = newDonors;
      }
    } else {
      donationModel.requestIdType = 'offer';
      var newDonors = new List<String>.from(offerModel.cashModel.donors);
      newDonors.add(donationModel.donatedTo);
      offerModel.cashModel.donors = newDonors;
    }
    try {
      // var batch = Firestore.instance.batch();
      // batch.setData(
      //   Firestore.instance.collection('donations').document(donationModel.id),
      //   donationModel.toMap(),
      // );

      // batch.updateData(
      //   Firestore.instance.collection('offers').document(offerModel.id),
      //   offerModel.toMap(),
      // );

      log("===================DDID  B4${donationModel.notificationId}");
      await FirestoreManager.createDonation(donationModel: donationModel);
      await updateOfferWithRequest(offer: offerModel);
      log("===================DDID  AF${donationModel.notificationId}");

      await sendNotification(
        donationModel: donationModel,
        offerModel: offerModel,
        donor: notify,
      );
      if (notificationId != null && notificationId != '') {
        await FirestoreManager.readUserNotification(
            notificationId, notify.email);
      }
      return true;
    } on Exception catch (e) {
      _errorMessage.add("net_error");
    }
    return false;
  }

  Future<bool> donateGoods(
      {DonationModel donationModel,
      RequestModel requestModel,
      String notificationId,
      UserModel donor}) async {
    if (_selectedList == null || _selectedList.value.isEmpty) {
      _errorMessage.add('goods');
    } else {
      donationModel.requestIdType = 'request';
      donationModel.goodsDetails.donatedGoods = _selectedList.value;
      donationModel.goodsDetails.comments = _comment.value;
      donationModel.goodsDetails.requiredGoods =
          requestModel.goodsDonationDetails.requiredGoods;

      var newDonors =
          new List<String>.from(requestModel.goodsDonationDetails.donors);
      newDonors.add(donor.sevaUserID);
      requestModel.goodsDonationDetails.donors = newDonors;
      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        await FirestoreManager.updateRequest(requestModel: requestModel);

        await sendNotification(
          donationModel: donationModel,
          requestModel: requestModel,
          donor: donor,
        );
        if (notificationId != null && notificationId != '') {
          await FirestoreManager.readUserNotification(
              notificationId, donor.email);
        }
        return true;
      } on Exception catch (e) {
        _errorMessage.add("net_error");
      }
    }
    return false;
  }

  Future<bool> validateAmount({int minmumAmount}) async {
    if (_amountPledged.value == '' || _amountPledged.value == null) {
      _amountPledged.addError('amount1');
    } else if (int.parse(_amountPledged.value) < minmumAmount) {
      _amountPledged.addError('amount2');
    } else {
      return true;
    }

    return false;
  }

  Future<bool> donateAmount(
      {DonationModel donationModel,
      RequestModel requestModel,
      String notificationId,
      UserModel donor}) async {
    donationModel.requestIdType = 'request';
    donationModel.cashDetails.pledgedAmount = int.parse(_amountPledged.value);
    donationModel.minimumAmount = requestModel.cashModel.minAmount;
    donationModel.cashDetails.cashDetails.minAmount =
        requestModel.cashModel.minAmount;

    requestModel.cashModel.donors.add(donor.sevaUserID);
    // requestModel.cashModel.amountRaised =
    //     requestModel.cashModel.amountRaised + int.parse(_amountPledged.value);
    try {
      await FirestoreManager.createDonation(donationModel: donationModel);
      await FirestoreManager.updateRequest(requestModel: requestModel);
      await sendNotification(
        donationModel: donationModel,
        requestModel: requestModel,
        donor: donor,
      );
      if (notificationId != null) {
        await FirestoreManager.readUserNotification(
            notificationId, donor.email);
      }

      return true;
    } on Exception catch (e) {
      _errorMessage.add('net_error');
    }

    return false;
  }

  Future<void> sendNotification(
      {DonationModel donationModel,
      OfferModel offerModel,
      RequestModel requestModel,
      UserModel donor}) async {
    if (offerModel != null) {
      NotificationsModel notificationsModel = NotificationsModel(
        timebankId: donationModel.timebankId,
        communityId: donationModel.communityId,
        type: NotificationType.GOODS_DONATION_REQUEST,
        id: donationModel.notificationId,
        isRead: false,
        isTimebankNotification: false,
        senderUserId: donationModel.donorSevaUserId,
        targetUserId: offerModel.sevaUserId,
        data: donationModel.toMap(),
      );
      log("WRITIN ID  NMID ${notificationsModel.id}=================DONATION MODEL NID=====${donationModel.notificationId}");
      await Firestore.instance
          .collection('users')
          .document(donor.email)
          .collection('notifications')
          .document(notificationsModel.id)
          .setData(notificationsModel.toMap());
    } else if (requestModel != null) {
      NotificationsModel notificationsModel = NotificationsModel(
        timebankId: donationModel.timebankId,
        communityId: donationModel.communityId,
        type: NotificationType.ACKNOWLEDGE_DONOR_DONATION,
        id: donationModel.notificationId,
        isRead: false,
        isTimebankNotification:
            requestModel.requestMode == RequestMode.PERSONAL_REQUEST
                ? false
                : true,
        senderUserId: donationModel.donorSevaUserId,
        targetUserId: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? requestModel.sevaUserId
            : requestModel.timebankId,
        data: donationModel.toMap(),
      );

      switch (requestModel.requestMode) {
        case RequestMode.TIMEBANK_REQUEST:
          await Firestore.instance
              .collection('timebanknew')
              .document(notificationsModel.timebankId)
              .collection('notifications')
              .document(notificationsModel.id)
              .setData(notificationsModel.toMap());
          break;
        case RequestMode.PERSONAL_REQUEST:
          await Firestore.instance
              .collection('users')
              .document(donor.email)
              .collection('notifications')
              .document(notificationsModel.id)
              .setData(notificationsModel.toMap());
          break;
      }
    }
  }

  void dispose() {
    _selectedList.close();
    _amountPledged.close();
    _goodsDescription.close();
    _errorMessage.close();
    _comment.close();
  }
}
