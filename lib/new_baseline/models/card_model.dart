import 'package:sevaexchange/models/data_model.dart';

class CardModel extends DataModel {
  late String currentPlan;
  late String custId;
  late String email;
  late String timebankid;
  late List<Map> subscriptionModel;

  CardModel(Map<String, dynamic> map) {
    this.currentPlan = map.containsKey("currentplan") ? map["currentplan"] : '';
    this.custId = map.containsKey("custId") ? map["custId"] : '';
    this.email = map.containsKey("email") ? map["email"] : '';
    this.timebankid = map.containsKey("timebankid") ? map["timebankid"] : '';
    this.subscriptionModel = map.containsKey('subscription')
        ? List.castFrom(map['subscription'])
        : [];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'currentplan': currentPlan,
      'custId': custId,
      'email': email,
      'timebankid': timebankid,
      'subscription': subscriptionModel,
    };
  }
}

class PaymentStateModel extends DataModel {
  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {};
  }
}
