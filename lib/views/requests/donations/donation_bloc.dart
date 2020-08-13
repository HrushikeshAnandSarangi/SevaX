import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

class DonationBloc {
  final _goodsDescription = BehaviorSubject<String>();
  final _amountPledged = BehaviorSubject<String>();
  final _errorMessage = BehaviorSubject<String>();
  final _selectedList = BehaviorSubject<HashSet>.seeded(HashSet());

  Stream<String> get goodsDescription => _goodsDescription.stream;
  Stream<String> get amountPledged => _amountPledged.stream;
  Stream<String> get errorMessage => _errorMessage.stream;
  Stream<HashSet> get selectedList => _selectedList.stream;

  Function(String) get onDescriptionChange => _goodsDescription.sink.add;
  Function(String) get onAmountChange => _amountPledged.sink.add;

  void addAddRemove({String selectedItem}) {
    _selectedList.value.contains(selectedItem)
        ? _selectedList.value.remove(selectedItem)
        : _selectedList.value.add(selectedItem);
  }

  Future<bool> donateGoods({DonationModel donationModel}) async {
    if (_selectedList.value.isEmpty) {
      _errorMessage.add('Select a goods category');
    } else {
      donationModel.cashDetails.pledgedAmount = int.parse(_amountPledged.value);
      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        return true;
      } on Exception catch (e) {
        _errorMessage.add("something went wrong try again later");
      }
    }
    return false;
  }

  Future<bool> donateAmount({DonationModel donationModel}) async {
    if (_amountPledged.value.isEmpty || int.parse(_amountPledged.value) == 0) {
      _amountPledged.addError('Enter valid amount');
    } else {
      donationModel.cashDetails.pledgedAmount = int.parse(_amountPledged.value);
      try {
        await FirestoreManager.createDonation(donationModel: donationModel);
        return true;
      } on Exception catch (e) {
        _errorMessage.add("something went wrong try again later");
      }
    }
    return false;
  }

  void dispose() {
    _amountPledged.close();
    _goodsDescription.close();
    _errorMessage.close();
  }
}
