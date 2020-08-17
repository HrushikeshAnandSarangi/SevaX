import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/notifications_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class DonationBloc {
  final _goodsDescription = BehaviorSubject<String>();
  final _amountPledged = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();
  final _commentEntered = BehaviorSubject<String>();
  final _selectedList =
      BehaviorSubject<Map<dynamic, dynamic>>.seeded(Map<dynamic, dynamic>());

  Stream<String> get goodsDescription => _goodsDescription.stream;
  Stream<String> get amountPledged => _amountPledged.stream;
  Stream<String> get comment => _commentEntered.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<Map<dynamic, dynamic>> get selectedList => _selectedList.stream;

  Function(String) get onDescriptionChange => _goodsDescription.sink.add;
  Function(String) get onAmountChange => _amountPledged.sink.add;
  Function(String) get onCommentChanged => _commentEntered.sink.add;

  void addAddRemove({String selectedKey, String selectedValue}) {
    _selectedList.value.containsKey(selectedKey)
        ? _selectedList.value.remove(selectedKey)
        : _selectedList.value[selectedKey] = selectedValue;
  }

  Future<bool> donateGoods(
      {DonationModel donationModel,
      RequestModel requestModel,
      UserModel donor}) async {
    if (_selectedList.value.isEmpty) {
      _errorMessage.add('Select a goods category');
    } else {
      donationModel.goodsDetails.donatedGoods = _selectedList.value;
      donationModel.goodsDetails.comments = _commentEntered.value;
      requestModel.goodsDonationDetails.donors.add(donor.sevaUserID);
      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        await FirestoreManager.updateRequest(requestModel: requestModel);

        await sendNotification(
            donationModel: donationModel,
            requestModel: requestModel,
            donor: donor);
        return true;
      } on Exception catch (e) {
        _errorMessage.add("something went wrong try again later");
      }
    }
    return false;
  }

  Future<bool> validateAmount({RequestModel requestModel}) async {
    if (_amountPledged.value.isEmpty) {
      _amountPledged.addError('Enter valid amount');
    } else if (int.parse(_amountPledged.value) <
        requestModel.cashModel.minAmount) {
      _amountPledged.addError(
          'Minimum amount is ${requestModel.cashModel.minAmount.toString()}');
    } else {
      return true;
    }

    return false;
  }

  Future<bool> donateAmount(
      {DonationModel donationModel,
      RequestModel requestModel,
      UserModel donor}) async {
    if (_amountPledged.value.isEmpty || int.parse(_amountPledged.value) == 0) {
      _amountPledged.addError('Enter valid amount');
    } else if (int.parse(_amountPledged.value) <
        requestModel.cashModel.minAmount) {
      _amountPledged.addError(
          'Minimum amount is ${requestModel.cashModel.minAmount.toString()}');
    } else {
      donationModel.cashDetails.pledgedAmount = int.parse(_amountPledged.value);

      requestModel.cashModel.donors.add(donor.sevaUserID);
      requestModel.cashModel.amountRaised =
          requestModel.cashModel.amountRaised + int.parse(_amountPledged.value);
      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        await FirestoreManager.updateRequest(requestModel: requestModel);
        await sendNotification(
            donationModel: donationModel,
            requestModel: requestModel,
            donor: donor);
        return true;
      } on Exception catch (e) {
        _errorMessage.add("something went wrong try again later");
      }
    }
    return false;
  }

  Future<void> sendNotification(
      {DonationModel donationModel,
      RequestModel requestModel,
      UserModel donor}) async {
    // String donationType = donationModel.donationType == RequestType.CASH
    //     ? 'Cash'
    //     : donationModel.donationType == RequestType.GOODS ? 'Goods' : 'Time';

    DonationApproveModel donationApproveModel = DonationApproveModel(
      donationId: donationModel.id,
      donorName: donor.fullname,
      donorPhotoUrl: donor.photoURL,
      requestId: requestModel.id,
      requestTitle: requestModel.title,
      donorEmail: donor.email,
      donationType: donationModel.donationType,
      donationDetails:
          '${donationModel.donationType == RequestType.CASH ? donationModel.cashDetails.pledgedAmount.toString() : donationModel.donationType == RequestType.GOODS ? 'goods' : 'time'}',
    );
    NotificationsModel notificationsModel = NotificationsModel(
      timebankId: donationModel.timebankId,
      communityId: donationModel.communityId,
      type: NotificationType.TypeApproveDonation,
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
      data: donationApproveModel.toMap(),
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

  void dispose() {
    _amountPledged.close();
    _goodsDescription.close();
    _errorMessage.close();
  }
}
