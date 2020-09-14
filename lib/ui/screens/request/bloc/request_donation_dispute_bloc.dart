import 'package:flutter/foundation.dart';
import 'package:rxdart/subjects.dart';
import 'package:sevaexchange/components/get_location.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/repositories/donations_repository.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';

class RequestDonationDisputeBloc {
  final DonationsRepository _donationsRepository = DonationsRepository();

  final _cashAmount = BehaviorSubject<String>();
  final _goodsRecieved = BehaviorSubject<Map<String, String>>.seeded({});

  Stream<String> get cashAmount => _cashAmount.stream;
  Stream<Map<String, String>> get goodsRecieved => _goodsRecieved.stream;

  Function(String) get onAmountChanged => _cashAmount.sink.add;

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

  Future<bool> validateAmount({int minmumAmount}) async {
    if (_cashAmount.value == '' || _cashAmount.value == null) {
      _cashAmount.addError('amount1');
      return false;
    } else if (int.parse(_cashAmount.value) < minmumAmount) {
      _cashAmount.addError('min');
      return false;
    } else {
      return true;
    }
  }

  Future<bool> disputeCash({
    OperatingMode operationMode,
    double pledgedAmount,
    String donationId,
    String notificationId,
    DonationModel donationModel,
    RequestMode requestMode,
  }) async {
    var status = pledgedAmount == double.parse(_cashAmount.value);

    if (_cashAmount.value == null || _cashAmount.value == '') {
      _cashAmount.addError('amount1');
      return false;
    } else if (int.parse(_cashAmount.value) < donationModel.minimumAmount) {
      _cashAmount.addError('min');
      return false;
    } else {
      return await _donationsRepository
          .acknowledgeDonation(
            operatoreMode: operationMode,
            requestType: donationModel.donationType,
            donationStatus:
                status ? DonationStatus.ACKNOWLEDGED : DonationStatus.MODIFIED,
            associatedId: operationMode == OperatingMode.CREATOR &&
                    donationModel.donatedToTimebank
                ? donationModel.timebankId
                : donationModel.donorDetails.email,
            donationId: donationId,
            isTimebankNotification: operationMode == OperatingMode.CREATOR &&
                donationModel.donatedToTimebank,
            notificationId: notificationId,
            acknowledgementNotification: getAcknowlegementNotification(
              updatedAmount: double.parse(_cashAmount.value),
              model: donationModel,
              operatorMode: operationMode,
              requestMode: requestMode,
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
    double updatedAmount,
    DonationModel model,
    OperatingMode operatorMode,
    RequestMode requestMode,
    NotificationType notificationType,
    Map<String, String> customSelection,
  }) {
    var notificationId = Uuid().generateV4();
    if (model.donationType == RequestType.CASH)
      model.cashDetails.pledgedAmount = updatedAmount.toInt();
    else if (model.donationType == RequestType.GOODS)
      model.goodsDetails.donatedGoods = customSelection;

    model.notificationId = notificationId;

    return NotificationsModel(
      type: notificationType,
      communityId: model.communityId,
      data: model.toMap(),
      id: notificationId,
      isRead: false,
      isTimebankNotification:
          model.donatedToTimebank && operatorMode == OperatingMode.USER,
      senderUserId: requestMode == RequestMode.TIMEBANK_REQUEST
          ? model.timebankId
          : model.donatedTo,
      targetUserId: operatorMode == OperatingMode.CREATOR
          ? model.donorSevaUserId
          : model.timebankId,
      timebankId: model.timebankId,
    );
  }

  Future<bool> disputeGoods({
    OperatingMode operationMode,
    String donationId,
    String notificationId,
    DonationModel donationModel,
    RequestMode requestMode,
    Map<String, String> donatedGoods,
  }) async {
    var x = List.from(donatedGoods.keys);
    var y = List.from(_goodsRecieved.value.keys);

    x.sort();
    y.sort();
    var status = listEquals(x, y);

    await _donationsRepository.acknowledgeDonation(
      requestType: donationModel.donationType,
      operatoreMode: operationMode,
      donationStatus:
          status ? DonationStatus.ACKNOWLEDGED : DonationStatus.MODIFIED,
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
              donationModel.donatedToTimebank
          ? donationModel.timebankId
          : donationModel.donorDetails.email,
      donationId: donationId,
      // if status is true that means the notification will go to user only as the request is acknowledged
      // if true then we check whether it should go to timebank or user
      //TODO: check the condition for all scenario
      isTimebankNotification: operationMode == OperatingMode.CREATOR &&
          donationModel.donatedToTimebank,
      notificationId: notificationId,
    );
    return true;
  }

  void dispose() {
    _cashAmount.close();
    _goodsRecieved.close();
  }
}
