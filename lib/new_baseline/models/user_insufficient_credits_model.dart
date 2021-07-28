import 'package:sevaexchange/models/data_model.dart';

class UserInsufficentCreditsModel extends DataModel {
  String senderName;
  String senderId;
  String senderPhotoUrl;
  String timebankId;
  String timebankName;
  double creditsNeeded;
  UserInsufficentCreditsModel(
      {this.senderName,
      this.senderId,
      this.senderPhotoUrl,
      this.timebankId,
      this.timebankName,
      this.creditsNeeded}); //  String senderName;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.senderName != null && this.senderName.isNotEmpty) {
      object['senderName'] = this.senderName;
    }
    if (this.senderId != null && this.senderId.isNotEmpty) {
      object['senderId'] = this.senderId;
    }
    if (this.senderPhotoUrl != null && this.senderPhotoUrl.isNotEmpty) {
      object['senderPhotoUrl'] = this.senderPhotoUrl;
    }
    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.timebankName != null && this.timebankName.isNotEmpty) {
      object['timebankName'] = this.timebankName;
    }
    if (this.creditsNeeded != null) {
      object['creditsNeeded'] = this.creditsNeeded.toDouble();
    }
    return object;
  }

  UserInsufficentCreditsModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('senderName')) {
      this.senderName = map['senderName'];
    }

    if (map.containsKey('senderId')) {
      this.senderId = map['senderId'];
    }

    if (map.containsKey('senderPhotoUrl')) {
      this.senderPhotoUrl = map['senderPhotoUrl'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('timebankName')) {
      this.timebankName = map['timebankName'];
    }

    if (map.containsKey('creditsNeeded')) {
      this.creditsNeeded = map['creditsNeeded'].toDouble();
    }
  }
}
