import 'package:sevaexchange/models/data_model.dart';

class ChangeOwnershipModel extends DataModel {
  String? adminId;
  String? creatorName;
  String? creatorEmail;
  String? message;
  String? timebank;
  String? creatorPhotoUrl;

  ChangeOwnershipModel(
      {this.creatorName,
      this.adminId,
      this.creatorEmail,
      this.message,
      this.timebank,
      this.creatorPhotoUrl}); //  String userName;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.creatorName != null && this.creatorName?.isNotEmpty == true) {
      object['creatorName'] = this.creatorName;
    }

    if (this.creatorEmail != null && this.creatorEmail?.isNotEmpty == true) {
      object['creatorEmail'] = this.creatorEmail;
    }

    if (this.adminId != null && this.adminId?.isNotEmpty == true) {
      object['adminId'] = this.adminId;
    }
    if (this.message != null && this.message?.isNotEmpty == true) {
      object['message'] = this.message;
    }
    if (this.timebank != null && this.timebank?.isNotEmpty == true) {
      object['timebank'] = this.timebank;
    }
    if (this.creatorPhotoUrl != null &&
        this.creatorPhotoUrl?.isNotEmpty == true) {
      object['creatorPhotoUrl'] = this.creatorPhotoUrl;
    }

    return object;
  }

  ChangeOwnershipModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('creatorName')) {
      this.creatorName = map['creatorName'];
    }

    if (map.containsKey('creatorEmail')) {
      this.creatorEmail = map['creatorEmail'];
    }
    if (map.containsKey('adminId')) {
      this.adminId = map['adminId'];
    }

    if (map.containsKey('message')) {
      this.message = map['message'];
    }

    if (map.containsKey('timebank')) {
      this.timebank = map['timebank'];
    }

    if (map.containsKey('creatorPhotoUrl')) {
      this.creatorPhotoUrl = map['creatorPhotoUrl'];
    }
  }
}
