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

  Future<bool> disputeCash({
    OperatingMode operationMode,
    double pledgedAmount,
    String donationId,
    String notificationId,
    DonationModel donationModel,
    RequestMode requestMode,
  }) async {
    var status = pledgedAmount == double.parse(_cashAmount.value);

    return await _donationsRepository
        .acknowledgeDonation(
          donationStatus:
              status ? DonationStatus.ACKNOWLEDGED : DonationStatus.MODIFIED,
          associatedId: operationMode == OperatingMode.USER
              ? donationModel.timebankId
              : donationModel.donorDetails.email,
          donationId: donationId,
          isTimebankNotification: operationMode == OperatingMode.USER,
          notificationId: notificationId,
          acknowledgementNotification: getAcknowlegementNotification(
            updatedAmount: pledgedAmount,
            model: donationModel,
            operatorMode: operationMode,
            requestMode: requestMode,
            notificationType: status
                ? NotificationType.CASH_DONATION_COMPLETED_SUCCESSFULY
                : OperatingMode == OperatingMode.CREATOR
                    ? NotificationType.CASH_DONATION_MODIFIED_BY_CREATOR
                    : NotificationType.CASH_DONATION_MODIFIED_BY_DONOR,
          ),
        )
        .then((value) => true)
        .catchError((onError) => false);
  }

  NotificationsModel getAcknowlegementNotification({
    double updatedAmount,
    DonationModel model,
    OperatingMode operatorMode,
    RequestMode requestMode,
    NotificationType notificationType,
    Map<String, dynamic> customSelection,
  }) {
    var updatedModel = model;
    updatedModel.cashDetails.pledgedAmount = updatedAmount.toInt();
    updatedModel.goodsDetails.donatedGoods = customSelection;

    return NotificationsModel(
      type: notificationType,
      communityId: model.communityId,
      data: updatedModel.toMap(),
      id: Uuid().generateV4(),
      isRead: false,
      isTimebankNotification: requestMode == RequestMode.TIMEBANK_REQUEST,
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
    Map<String, dynamic> customSelection,
    OperatingMode operationMode,
    String donationId,
    String notificationId,
    DonationModel donationModel,
    RequestMode requestMode,
    Map<String, String> donatedGoods,
  }) async {
    var status = listEquals(
      List.from(donatedGoods.keys),
      List.from(_goodsRecieved.value.keys),
    );
    await _donationsRepository.acknowledgeDonation(
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
        customSelection: customSelection,
      ),
      associatedId: operationMode == OperatingMode.USER
          ? donationModel.timebankId
          : donationModel.donorDetails.email,
      donationId: donationId,
      isTimebankNotification: operationMode == OperatingMode.USER,
      notificationId: notificationId,
    );
    return true;
  }

  void dispose() {
    _cashAmount.close();
    _goodsRecieved.close();
  }
}
