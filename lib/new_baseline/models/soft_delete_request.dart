import 'dart:collection';

import 'package:sevaexchange/utils/soft_delete_manager.dart';

class SoftDeleteRequestDataHolder {
  int noOfOpenRequests;
  int noOfOpenOffers;
  bool requestAccepted;
  String entityTitle;
  SoftDelete softDeleteType;

  SoftDeleteRequestDataHolder.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('noOfOpenRequests')) {
      noOfOpenRequests = map['noOfOpenRequests'];
    }

    if (map.containsKey('entityTitle')) {
      entityTitle = map['entityTitle'];
    }

    if (map.containsKey('noOfOpenOffers')) {
      this.noOfOpenOffers = map['noOfOpenOffers'];
    }

    if (map.containsKey('requestAccepted')) {
      this.requestAccepted = map['requestAccepted'];
    } else {
      this.requestAccepted = false;
    }

    if (map.containsKey('type')) {
      this.softDeleteType = getSoftDeleteType(map['type']);
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = HashMap();

    object['noOfOpenRequests'] = this.noOfOpenOffers;
    object['noOfOpenOffers'] = this.noOfOpenOffers;
    object['requestAccepted'] = this.requestAccepted;
    object['entityTitle'] = this.entityTitle;
    object['type'] = softDeleteType.toString();

    return object;
  }

  SoftDelete getSoftDeleteType(String type) {
    switch (type) {
      case "group":
        return SoftDelete.REQUEST_DELETE_GROUP;

      case "timebank":
        return SoftDelete.REQUEST_DELETE_TIMEBANK;

      case "project":
        return SoftDelete.REQUEST_DELETE_PROJECT;

      default:
        return null;
    }
  }
}
