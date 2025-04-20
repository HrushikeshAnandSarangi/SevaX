import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/donations_repository.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';

class RequestDonationDisputeBloc {
  final DonationsRepository _donationsRepository = DonationsRepository();

  final _cashAmount = BehaviorSubject<String>();
  final _requestModel = BehaviorSubject<RequestModel>();
  final _goodsRecieved = BehaviorSubject<Map<String, String>>.seeded({});

  Stream<String> get cashAmount => _cashAmount.stream;

  Stream<Map<String, String>> get goodsRecieved => _goodsRecieved.stream;

  String get cashAmoutVal => _cashAmount.value;

  Map<String, String> get goodsRecievedVal => _goodsRecieved.value;

  Function(String) get onAmountChanged => _cashAmount.sink.add;

  Function(RequestModel) get addRequestModel => _requestModel.sink.add;

  getgoodsRecieved() {
    return _goodsRecieved.value;
  }

  void toggleGoodsReceived(String key, String value) {
    var map = _goodsRecieved.value;
    if (map.containsKey(key)) {
      _goodsRecieved.add(map..remove(key));
    } else {
      map[key] = value;
      _goodsRecieved.add(map);
    }
  }

  void initGoodsReceived(Map<String, String> initialValue) {
    _goodsRecieved.add(Map.from(initialValue));
  }

  Future<bool> validateAmount({int? minmumAmount}) async {
    if (_cashAmount.value == '' || _cashAmount.value == null) {
      _cashAmount.addError('amount1');
      return false;
    }
    //BEWARE DONOT UNCOMMENT THIS
    // else if (int.parse(_cashAmount.value) < minmumAmount) {
    //   _cashAmount.addError('min');
    //   return false;
    // }
    else {
      return true;
    }
  }

  Future<bool> callDonateOfferCreatorPledge({
    OperatingMode? operationMode,
    double? pledgedAmount,
    String? donationId,
    String? notificationId,
    DonationModel? donationModel,
    RequestMode? requestMode,
  }) async {
    log("Inside callDonateOfferCreatorPledge");

    var amountMatched = pledgedAmount == double.parse(_cashAmount.value);
    if (_cashAmount.value == null || _cashAmount.value == '') {
      log("Inside amount 1");

      _cashAmount.addError('amount1');
      return false;
    } else if (donationModel!.minimumAmount != null &&
        int.parse(_cashAmount.value) < donationModel.minimumAmount!) {
      log("Inside min");

      _cashAmount.addError('min');
      return false;
    } else {
      donationModel.donationStatus =
          donationModel.donationStatus == DonationStatus.REQUESTED
              ? DonationStatus.PLEDGED
              : donationModel.donationStatus;
      donationModel.minimumAmount = 0;
      return await _donationsRepository
          .donateOfferCreatorPledge(
            operatoreMode: operationMode!,
            requestType: donationModel.donationType!,
            donationStatus: donationModel.donationStatus!,
            associatedId: operationMode == OperatingMode.CREATOR &&
                    donationModel.donatedToTimebank!
                ? donationModel.timebankId!
                : donationModel.donorDetails!.email!,
            donationId: donationId!,
            isTimebankNotification: operationMode == OperatingMode.CREATOR &&
                donationModel.donatedToTimebank!,
            notificationId: notificationId!,
            acknowledgementNotification: getAcknowlegementNotification(
              updatedAmount: double.parse(_cashAmount.value),
              model: donationModel,
              operatorMode: operationMode,
              requestMode: requestMode!,
              notificationType:
                  donationModel.donationStatus == DonationStatus.PLEDGED
                      ? NotificationType.ACKNOWLEDGE_DONOR_DONATION
                      : NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY,
            ),
          )
          .then((value) => true)
          .catchError((onError) => false);
    }
  }

  Future<bool> disputeCash({
    OperatingMode? operationMode,
    double? pledgedAmount,
    String? donationId,
    String? notificationId,
    DonationModel? donationModel,
    RequestMode? requestMode,
  }) async {
    double convertedRate = 0.0;
    double rate = 0.0;
    if (donationModel!.requestIdType == 'offer') {
      rate = operationMode == OperatingMode.USER
          ? pledgedAmount ?? 0.0
          : await currencyConversion(
              fromCurrency:
                  donationModel.cashDetails?.cashDetails?.offerCurrencyType ??
                      "USD",
              toCurrency: donationModel
                      .cashDetails?.cashDetails?.offerDonatedCurrencyType ??
                  "USD",
              amount: pledgedAmount ?? 0.0);
    }
    if (donationModel.requestIdType == 'request') {
      rate = operationMode != OperatingMode.USER
          ? pledgedAmount ?? 0.0
          : await currencyConversion(
              fromCurrency:
                  donationModel.cashDetails!.cashDetails!.requestCurrencyType ??
                      "",
              toCurrency: donationModel
                      .cashDetails!.cashDetails!.requestDonatedCurrency ??
                  "",
              amount: pledgedAmount ?? 0.0);
    }

    var status = rate == double.parse(_cashAmount.value ?? "0.0");
    if (operationMode == OperatingMode.USER) {
      convertedRate = await currencyConversion(
          fromCurrency: donationModel.requestIdType == 'offer'
              ? donationModel?.cashDetails?.cashDetails?.offerCurrencyType ??
                  "USD"
              : donationModel
                      ?.cashDetails?.cashDetails?.requestDonatedCurrency ??
                  "USD",
          toCurrency: donationModel.requestIdType == 'offer'
              ? donationModel?.cashDetails?.cashDetails?.offerCurrencyType ??
                  "USD"
              : donationModel?.cashDetails?.cashDetails?.requestCurrencyType ??
                  "USD",
          amount: double.parse(_cashAmount.value));
    }
    if (operationMode != OperatingMode.USER) {
      convertedRate = await currencyConversion(
          fromCurrency: donationModel.requestIdType == 'request'
              ? donationModel?.cashDetails?.cashDetails?.requestCurrencyType ??
                  "USD"
              : donationModel
                      ?.cashDetails?.cashDetails?.offerDonatedCurrencyType ??
                  "USD",
          toCurrency: donationModel.requestIdType == 'request'
              ? donationModel?.cashDetails?.cashDetails?.requestCurrencyType ??
                  "USD"
              : donationModel?.cashDetails?.cashDetails?.offerCurrencyType ??
                  "USD",
          amount: double.parse(_cashAmount.value));
    }

    if (_cashAmount.value == null || _cashAmount.value == '') {
      _cashAmount.addError('amount1');
      return false;
    }
    // else if (donationModel.minimumAmount != null &&
    //     int.parse(_cashAmount.value) < donationModel.minimumAmount) {
    //   _cashAmount.addError('min');
    //   return false;
    // }
    else {
      return await _donationsRepository
          .acknowledgeDonation(
            operatoreMode: operationMode!,
            requestType: donationModel.donationType!,
            donationStatus:
                status ? DonationStatus.ACKNOWLEDGED : DonationStatus.MODIFIED,
            associatedId: operationMode == OperatingMode.CREATOR &&
                    donationModel.donatedToTimebank == true
                ? donationModel.timebankId ?? ''
                : donationModel.requestIdType == 'offer'
                    ? operationMode != OperatingMode.CREATOR
                        ? donationModel.donorDetails?.email ?? ''
                        : donationModel.receiverDetails?.email ?? ''
                    : donationModel.donorDetails?.email ?? '',
            donationId: donationId!,
            isTimebankNotification: operationMode == OperatingMode.CREATOR &&
                donationModel!.donatedToTimebank!,
            notificationId: notificationId!,
            acknowledgementNotification: getAcknowlegementNotification(
              updatedAmount: operationMode == OperatingMode.USER ||
                      operationMode != OperatingMode.USER
                  ? convertedRate
                  : double.parse(_cashAmount.value),
              model: donationModel,
              operatorMode: operationMode,
              requestMode: requestMode!,
              notificationType: status
                  ? NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY
                  : operationMode == OperatingMode.CREATOR
                      ? NotificationType.CASH_DONATION_MODIFIED_BY_CREATOR
                      : NotificationType.CASH_DONATION_MODIFIED_BY_DONOR,
            ),
          )
          .then((value) => true)
          .catchError((onError) => false);
    }
  }

  NotificationsModel getAcknowlegementNotification({
    double? updatedAmount,
    DonationModel? model,
    OperatingMode? operatorMode,
    RequestMode? requestMode,
    NotificationType? notificationType,
    Map<String, String>? customSelection,
  }) {
    var notificationId = Uuid().generateV4();
    bool isTimebankNotification =
        model!.donatedToTimebank! && operatorMode == OperatingMode.USER;
    if (model.donationType == RequestType.CASH)
      model.cashDetails!.pledgedAmount = updatedAmount;
    else if (model.donationType == RequestType.GOODS)
      model.goodsDetails!.donatedGoods = customSelection;

    model.notificationId = notificationId;

    var communityId;

    if (model.requestIdType == 'offer') {
      communityId = getCommunitySpecificNotificationForOffer(
        model: model,
        type: notificationType!,
      );
    } else {
      communityId = model.donorDetails!.communityId;
    }

    return NotificationsModel(
      type: notificationType,
      communityId: !isTimebankNotification
          ? communityId ?? model.communityId
          : model.communityId,
      data: model.toMap(),
      id: notificationId,
      isRead: false,
      isTimebankNotification: isTimebankNotification,
      senderUserId: requestMode == RequestMode.TIMEBANK_REQUEST
          ? model.timebankId
          : model.donatedTo,
      targetUserId: operatorMode == OperatingMode.CREATOR
          ? model.donorSevaUserId
          : model.timebankId,
      timebankId: model.timebankId,
    );
  }

  String getCommunitySpecificNotificationForOffer(
      {NotificationType? type, DonationModel? model}) {
    switch (type) {
      case NotificationType.CASH_DONATION_MODIFIED_BY_CREATOR:
      case NotificationType.GOODS_DONATION_MODIFIED_BY_CREATOR:
      case NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULLY:
      case NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY:
        return model!.donorDetails!.communityId!;

      default:
        return model!.receiverDetails!.communityId!;
    }
  }

  Future<bool> disputeGoods({
    OperatingMode? operationMode,
    String? donationId,
    String? notificationId,
    DonationModel? donationModel,
    RequestMode? requestMode,
    Map<String, String>? donatedGoods,
  }) async {
    var x = List.from(donatedGoods!.keys);
    var y = List.from(_goodsRecieved.value.keys);
    DonationStatus donationStatus;

    x.sort();
    y.sort();
    var status = listEquals(x, y);
    donationStatus =
        status ? DonationStatus.ACKNOWLEDGED : DonationStatus.MODIFIED;
    donationModel!.donationStatus = donationStatus;

    await _donationsRepository.acknowledgeDonation(
      requestType: donationModel.donationType!,
      operatoreMode: operationMode!,
      donationStatus: donationStatus,

      acknowledgementNotification: getAcknowlegementNotification(
        model: donationModel,
        operatorMode: operationMode,
        requestMode: requestMode,
        notificationType: status
            ? NotificationType.GOODS_DONATION_COMPLETED_SUCCESSFULLY
            : (operationMode == OperatingMode.CREATOR
                ? NotificationType.GOODS_DONATION_MODIFIED_BY_CREATOR
                : NotificationType.GOODS_DONATION_MODIFIED_BY_DONOR),
        customSelection: _goodsRecieved.value,
      ),
      associatedId: operationMode == OperatingMode.CREATOR &&
              (donationModel.donatedToTimebank ?? false)
          ? donationModel.timebankId ?? ''
          : donationModel.requestIdType == 'offer'
              ? operationMode != OperatingMode.CREATOR
                  ? donationModel.donorDetails?.email ?? ''
                  : donationModel.receiverDetails?.email ?? ''
              : donationModel.donorDetails?.email ?? '',
      donationId: donationId!,

      // if status is true that means the notification will go to user only as the request is acknowledged
      // if true then we check whether it should go to timebank or user
      //TODO: check the condition for all scenario
      isTimebankNotification: operationMode == OperatingMode.CREATOR &&
          donationModel.donatedToTimebank!,
      notificationId: notificationId!,
    );
    return true;
  }

  void dispose() {
    _cashAmount.close();
    _goodsRecieved.close();
  }
}
