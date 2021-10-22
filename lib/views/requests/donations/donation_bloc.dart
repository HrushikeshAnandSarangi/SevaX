import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/constants/dropdown_currency_constants.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/new_baseline/models/acceptor_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/offers_data_manager.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/utils.dart';

class DonationBloc {
  final _goodsDescription = BehaviorSubject<String>();
  final _community = BehaviorSubject<CommunityModel>();
  final _amountPledged = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();
  final _comment = BehaviorSubject<String>();
  final _selectedList = BehaviorSubject<Map<String, String>>.seeded(Map<String, String>());
  final _offerDonatedCurrency = BehaviorSubject<String>();
  final _requestDonatedCurrency = BehaviorSubject<String>();
  //Donations search bar cod
  final _donationsDetailsController = BehaviorSubject<List<DonationModel>>();
  final _searchQuery = BehaviorSubject<String>.seeded(null);

  Stream<List<DonationModel>> get _donationDetailsStream => _donationsDetailsController.stream;
  Stream<String> get _query => _searchQuery.stream;

  Stream<String> get goodsDescription => _goodsDescription.stream;
  Stream<String> get amountPledged => _amountPledged.stream;
  Stream<String> get commentEntered => _comment.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<Map<dynamic, dynamic>> get selectedList => _selectedList.stream;
  Stream<String> get offerDonatedCurrency => _offerDonatedCurrency.stream;
  Stream<String> get requestDonatedCurrency => _requestDonatedCurrency.stream;

  bool get isSelectedListEmpty => _selectedList.value?.isEmpty ?? true;

  Map<dynamic, dynamic> get selectedListVal => _selectedList.value;
  String get commentEnteredVal => _comment.value;

  Function(CommunityModel) get addCommunity => _community.sink.add;
  Function(String) get onDescriptionChange => _goodsDescription.sink.add;
  Function(String) get onAmountChange => _amountPledged.sink.add;
  Function(String) get onCommentChanged => _comment.sink.add;
  Function(String) get offerDonatedCurrencyType => _offerDonatedCurrency.sink.add;
  Function(String) get requestDonatedCurrencyType => _requestDonatedCurrency.sink.add;

  void addAddRemove({
    String selectedKey,
    String selectedValue,
  }) {
    var localMap = _selectedList.value;

    localMap.containsKey(selectedKey) ? localMap.remove(selectedKey) : localMap[selectedKey] = selectedValue;

    _selectedList.add(localMap);
  }

  Future<bool> donateOfferGoods(
      {DonationModel donationModel, OfferModel offerModel, String notificationId, UserModel notify}) async {
    if (offerModel.type == RequestType.GOODS) {
      if (_selectedList == null || _selectedList.value.isEmpty) {
        _errorMessage.add('goods');
        return false;
      } else {
        donationModel.requestIdType = 'offer';
        donationModel.goodsDetails.comments = _comment.value;
        donationModel.goodsDetails.requiredGoods = _selectedList.value;
        donationModel.goodsDetails.toAddress = donationModel.goodsDetails.toAddress;
        var newDonors = new List<String>.from(offerModel.goodsDonationDetails.donors);
        newDonors.add(donationModel.donatedTo);
        offerModel.goodsDonationDetails.donors = newDonors;
      }
    } else {
      donationModel.requestIdType = 'offer';
      var newDonors = new List<String>.from(offerModel.cashModel.donors);
      newDonors.add(donationModel.donatedTo);
      offerModel.cashModel.donors = newDonors;
      donationModel.cashDetails.cashDetails.offerDonatedCurrencyType =
          _offerDonatedCurrency.value ?? kDefaultCurrencyType;
      donationModel.cashDetails.cashDetails.offerCurrencyType = offerModel.cashModel.offerCurrencyType;
    }

    //Setting the receiver Community Title
    donationModel.receiverDetails.communityName = _community.value.name;

    //HERE

    try {
      await FirestoreManager.createDonation(donationModel: donationModel);
      await updateOfferWithRequest(offer: offerModel);
      await sendNotification(
        donationModel: donationModel,
        offerModel: offerModel,
        donor: notify,
      );
      if (notificationId != null && notificationId != '') {
        await FirestoreManager.readUserNotification(notificationId, notify.email);
      }
      return true;
    } on Exception catch (_) {
      _errorMessage.add("net_error");
    }
    return false;
  }

  Future<bool> donateGoods(
      {DonationModel donationModel, RequestModel requestModel, String notificationId, UserModel donor}) async {
    if (_selectedList == null || _selectedList.value.isEmpty) {
      _errorMessage.add('goods');
    } else {
      donationModel.requestIdType = 'request';
      donationModel.goodsDetails.donatedGoods = _selectedList.value;
      donationModel.goodsDetails.comments = _comment.value;
      donationModel.goodsDetails.requiredGoods = requestModel.goodsDonationDetails.requiredGoods;

      var newDonors = new List<String>.from(requestModel.goodsDonationDetails.donors);
      newDonors.add(donor.sevaUserID);
      requestModel.goodsDonationDetails.donors = newDonors;
      AcceptorModel acceptorModel = AcceptorModel(
          timebankId: _community.value.primary_timebank,
          memberEmail: donor.email,
          memberName: donor.fullname,
          communityName: _community.value.name,
          communityId: _community.value.id,
          memberPhotoUrl: donor.photoURL);
      requestModel.participantDetails[donor.email] = acceptorModel.toMap();

      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        await FirestoreManager.updateRequest(requestModel: requestModel);

        await sendNotification(
          donationModel: donationModel,
          requestModel: requestModel,
          donor: donor,
        );
        if (notificationId != null && notificationId != '') {
          await FirestoreManager.readUserNotification(notificationId, donor.email);
        }
        return true;
      } on Exception catch (_) {
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
      {DonationModel donationModel, RequestModel requestModel, String notificationId, UserModel donor}) async {
    donationModel.requestIdType = 'request';
    donationModel.cashDetails.pledgedAmount = await currencyConversion(
            fromCurrency: donationModel?.cashDetails?.cashDetails?.requestDonatedCurrency ?? "USD",
            toCurrency: requestModel?.cashModel?.requestCurrencyType ?? "USD",
            amount: double.parse(_amountPledged?.value) ?? 0.0)
        .then((value) => donationModel.cashDetails.pledgedAmount = value);

    donationModel.minimumAmount = requestModel.cashModel.minAmount;
    donationModel.cashDetails.cashDetails.minAmount = requestModel.cashModel.minAmount;

    donationModel.cashDetails.cashDetails.requestCurrencyType = requestModel.cashModel.requestCurrencyType;
    donationModel.cashDetails.cashDetails.requestDonatedCurrency =
        _requestDonatedCurrency.value ?? kDefaultCurrencyType;
    requestModel.cashModel.requestDonatedCurrency = _requestDonatedCurrency.value ?? kDefaultCurrencyType;

    requestModel.cashModel.donors.add(donor.sevaUserID);
    // requestModel.cashModel.amountRaised =
    //     requestModel.cashModel.amountRaised + int.parse(_amountPledged.value);
    AcceptorModel acceptorModel = AcceptorModel(
        timebankId: _community.value.primary_timebank,
        memberEmail: donor.email,
        memberName: donor.fullname,
        communityName: _community.value.name,
        communityId: _community.value.id,
        memberPhotoUrl: donor.photoURL);
    requestModel.participantDetails[donor.email] = acceptorModel.toMap();
    try {
      await FirestoreManager.createDonation(donationModel: donationModel);
      await FirestoreManager.updateRequest(requestModel: requestModel);
      await sendNotification(
        donationModel: donationModel,
        requestModel: requestModel,
        donor: donor,
      );
      if (notificationId != null) {
        await FirestoreManager.readUserNotification(notificationId, donor.email);
      }

      return true;
    } on Exception catch (_) {
      _errorMessage.add('net_error');
    }

    return false;
  }

  Future<void> sendNotification(
      {DonationModel donationModel, OfferModel offerModel, RequestModel requestModel, UserModel donor}) async {
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
      await CollectionRef.users
          .doc(donor.email)
          .collection('notifications')
          .doc(notificationsModel.id)
          .set(notificationsModel.toMap());
    } else if (requestModel != null) {
      NotificationsModel notificationsModel = NotificationsModel(
        timebankId: donationModel.timebankId,
        communityId: donationModel.communityId,
        type: NotificationType.ACKNOWLEDGE_DONOR_DONATION,
        id: donationModel.notificationId,
        isRead: false,
        isTimebankNotification: requestModel.requestMode == RequestMode.PERSONAL_REQUEST ? false : true,
        senderUserId: donationModel.donorSevaUserId,
        targetUserId: requestModel.requestMode == RequestMode.PERSONAL_REQUEST
            ? requestModel.sevaUserId
            : requestModel.timebankId,
        data: donationModel.toMap(),
      );

      switch (requestModel.requestMode) {
        case RequestMode.TIMEBANK_REQUEST:
          await CollectionRef.timebank
              .doc(notificationsModel.timebankId)
              .collection('notifications')
              .doc(notificationsModel.id)
              .set(notificationsModel.toMap());
          break;
        case RequestMode.PERSONAL_REQUEST:
          await CollectionRef.users
              .doc(donor.email)
              .collection('notifications')
              .doc(notificationsModel.id)
              .set(notificationsModel.toMap());
          break;
      }
    }
  }

  /// donations for donations list
  void init({@required bool isGoods, String userId, String timebankId}) {
    FirestoreManager.getDonationList(isGoods: isGoods, timebankId: timebankId, userId: userId)
        .listen((result) => _donationsDetailsController.add(result));
  }

  Stream<List<DonationModel>> data(BuildContext context, bool isGoods) => CombineLatestStream.combine2(
        _donationDetailsStream,
        _query,
        (transactions, searchText) {
          if (searchText == null || searchText.isEmpty) {
            return transactions;
          }

          final _transactions = List<DonationModel>.from(transactions);
          final searchTextLower = searchText.toLowerCase();
          _transactions.retainWhere(
            (element) =>
                getDonationType(element.donationType, context).toLowerCase().contains(
                          searchTextLower,
                        ) ||
                    element.createdDate.toLowerCase().contains(searchTextLower) ||
                    element?.goodsDetails?.donatedGoods?.values.contains(searchTextLower) ??
                false || element?.cashDetails?.pledgedAmount.toString().contains(searchTextLower),
          );
          return _transactions;
        },
      );

  Function(String) get onSearchQueryChanged => _searchQuery.sink.add;

  String getDonationType(RequestType donationType, BuildContext context) =>
      donationType == RequestType.GOODS ? S.of(context).goods_donation : S.of(context).cash_donation;
  void dispose() {
    _selectedList.close();
    _amountPledged.close();
    _goodsDescription.close();
    _errorMessage.close();
    _community.close();
    _comment.close();
    _searchQuery.close();
    _donationsDetailsController.close();
  }
}
