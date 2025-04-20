import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/models/models.dart';

class JoinRequestNotificationModel extends DataModel {
  String? timebankTitle;
  String? timebankId;
  String? reasonToJoin;

  JoinRequestNotificationModel({
    this.timebankId,
    this.timebankTitle,
    @required this.reasonToJoin,
  });

  JoinRequestNotificationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }

    if (map.containsKey('timebankTitle')) {
      this.timebankTitle = map['timebankTitle'];
    }

    if (map.containsKey('reasonToJoin')) {
      this.reasonToJoin = map['reasonToJoin'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.timebankId != null && this.timebankId?.isNotEmpty == true) {
      object['timebankId'] = this.timebankId;
    }
    if (this.timebankTitle != null && this.timebankTitle?.isNotEmpty == true) {
      object['timebankTitle'] = this.timebankTitle;
    }

    if (this.reasonToJoin != null && this.reasonToJoin?.isNotEmpty == true) {
      object['reasonToJoin'] = this.reasonToJoin;
    }

    return object;
  }
}

class OfferAcceptedNotificationModel extends DataModel {
  String? acceptedBy;
  String? notificationContent;
  String? offerId;

  OfferAcceptedNotificationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('acceptedBy')) {
      this.acceptedBy = map['acceptedBy'];
    }

    if (map.containsKey('notificationContent')) {
      this.notificationContent = map['notificationContent'];
    }

    if (map.containsKey('offerId')) {
      this.offerId = map['offerId'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.acceptedBy != null && this.acceptedBy?.isNotEmpty == true) {
      object['acceptedBy'] = this.acceptedBy;
    }

    if (this.notificationContent != null &&
        this.notificationContent?.isNotEmpty == true) {
      object['notificationContent'] = this.notificationContent;
    }

    if (this.offerId != null && this.offerId?.isNotEmpty == true) {
      object['offerId'] = this.offerId;
    }

    return object;
  }
}
