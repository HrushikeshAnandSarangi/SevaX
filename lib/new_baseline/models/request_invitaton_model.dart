import 'package:sevaexchange/models/models.dart';

class RequestInvitationModel extends DataModel {
  RequestModel? requestModel;
  TimebankModel? timebankModel;
  OfferModel? offerModel;

  RequestInvitationModel({
    this.requestModel,
    this.timebankModel,
    this.offerModel,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.requestModel != null)
      object['requestModel'] = this.requestModel!.toMap();

    if (this.timebankModel != null)
      object['timebankModel'] = this.timebankModel!.toMap();
    if (this.offerModel != null)
      object['offerModel'] = this.offerModel!.toMap();

    return object;
  }

  RequestInvitationModel.fromMap(Map<dynamic, dynamic> map) {
    this.requestModel = RequestModel.fromMap(map['requestModel']);
    this.timebankModel = TimebankModel.fromMap(map['timebankModel']);
    if (map.containsKey('offerModel')) {
      this.offerModel = OfferModel.fromMap(map['offerModel']);
    } else {
      this.offerModel = OfferModel();
    }
  }
}
