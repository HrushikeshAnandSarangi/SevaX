import 'package:sevaexchange/models/models.dart';

class RequestInvitationModel extends DataModel {
  RequestModel requestModel;
  TimebankModel timebankModel;

  RequestInvitationModel({
    this.requestModel,
    this.timebankModel,
  });

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.requestModel != null)
      object['requestModel'] = this.requestModel.toMap();

    if (this.timebankModel != null)
      object['timebankModel'] = this.timebankModel.toMap();
    return object;
  }

  RequestInvitationModel.fromMap(Map<String, dynamic> map) {
    this.requestModel = RequestModel.fromMap(map['requestModel']);
    this.timebankModel = TimebankModel.fromMap(map['timebankModel']);
  }
}
