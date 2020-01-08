import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/data_model.dart';

class TimebankModel extends DataModel{
  String id;
  String name;
  String missionStatement;
  String emailId;
  String phoneNumber;
  String address;
  String creatorId;
  String photoUrl;
  int createdAt;
  List<String> admins;
  List<String> coordinators;
  List<String> members;
  bool protected;
  String parentTimebankId;
  String communityId;
  String rootTimebankId;
  List<String> children;
  double balance;
  GeoFirePoint location;

  TimebankModel(map) {
    this.id = map.containsKey("id") ? map["id"] : '';
    this.name = map.containsKey("name") ? map["name"] : '';
    this.missionStatement = map.containsKey("missionStatement") ? map["missionStatement"] : '';
    this.emailId = map.containsKey("email_id") ? map["email_id"] : '';
    this.phoneNumber = map.containsKey("phone_number") ? map["phone_number"] : '';
    this.address = map.containsKey("address") ? map["address"] : '';
    this.creatorId = map.containsKey("creator_id") ? map["creator_id"] : '';
    this.photoUrl = map.containsKey("photo_url") ? map["photo_url"] : '';
    this.createdAt = map.containsKey("created_at") ? map["created_at"] : 0;
    this.admins = map.containsKey("admins") ? List.castFrom(map['admins']) : [];
    this.coordinators = map.containsKey("coordinators") ? List.castFrom(map['coordinators']) : [];
    this.members = map.containsKey("members") ? List.castFrom(map['members']) : [];
    this.protected = map.containsKey("protected") ? map["protected"] : false;
    this.parentTimebankId = map.containsKey("parent_timebank_id") ? map["parent_timebank_id"] : '';
    this.communityId = map.containsKey("community_id") ? map["community_id"] : '';
    this.rootTimebankId = map.containsKey("root_timebank_id") ? map["root_timebank_id"] : '';
    this.children = map.containsKey("children") ? List.castFrom(map['children']) : [];
    this.balance = map.containsKey("balance") ? map["balance"] : 0;
    this.location = map.containsKey("location") ? map["location"] : GeoFirePoint(40.754387, -73.984291);
  }
  updateValueByKey(String key, dynamic value) {
    if (key == 'id') {
      this.id = value;
    }
    if (key == 'name') {
      this.name = value;
    }
    if (key == 'missionStatement') {
      this.missionStatement = value;
    }
    if (key == 'emailId') {
      this.emailId = value;
    }
    if (key == 'phoneNumber') {
      this.phoneNumber = value;
    }
    if (key == 'address') {
      this.address = value;
    }
    if (key == 'creatorId') {
      this.creatorId = value;
    }
    if (key == 'photoUrl') {
      this.photoUrl = value;
    }
    if (key == 'createdAt') {
      this.createdAt = value;
    }
    if (key == 'admins') {
      this.admins = value;
    }
    if (key == 'coordinators') {
      this.coordinators = value;
    }
    if (key == 'members') {
      this.members = value;
    }
    if (key == 'protected') {
      this.protected = value;
    }
    if (key == 'parentTimebankId') {
      this.parentTimebankId = value;
    }
    if (key == 'rootTimebankId') {
      this.rootTimebankId = value;
    }
    if (key == 'children') {
      this.children = value;
    }
    if (key == 'balance') {
      this.balance = value;
    }
  }
  factory TimebankModel.fromMap(Map<String, dynamic> json) {
    TimebankModel timebankModel = new TimebankModel(json);
    if (json.containsKey('location')) {
      GeoPoint geoPoint = json['location']['geopoint'];
      timebankModel.location = Geoflutterfire()
          .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
    }
    return timebankModel;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": id == null ? null : id,
      "name": name == null ? null : name,
      "missionStatement": missionStatement == null ? null : missionStatement,
      "email_id": emailId == null ? null : emailId,
      "phone_number": phoneNumber == null ? null : phoneNumber,
      "address": address == null ? null : address,
      "creator_id": creatorId == null ? null : creatorId,
      "photo_url": photoUrl == null ? null : photoUrl,
      "created_at": createdAt == null ? null : createdAt,
      "admins": admins == null ? null : new List<dynamic>.from(admins.map((x) => x)),
      "coordinators": coordinators == null ? null : new List<dynamic>.from(coordinators.map((x) => x)),
      "members": members == null ? null : new List<dynamic>.from(members.map((x) => x)),
      "protected": protected == null ? null : protected,
      "parent_timebank_id": parentTimebankId == null ? null : parentTimebankId,
      "community_id" : communityId == null ? null : communityId,
      "root_timebank_id": rootTimebankId == null ? null : rootTimebankId,
      "children": children == null ? null : new List<dynamic>.from(children.map((x) => x)),
      "balance": balance == null ? null : balance,
    };
    if (this.location != null) {
      map['location'] = this.location.data;
    }
    return map;
  }
}

class Member extends DataModel {
  String email;
  String fullName;
  String photoUrl;

  Member({this.fullName, this.email, this.photoUrl});

  Member.fromMap(Map<String, dynamic> dataMap) {
    if (dataMap.containsKey('membersemail')) {
      this.email = dataMap['membersemail'];
    }

    if (dataMap.containsKey('membersfullname')) {
      this.fullName = dataMap['membersfullname'];
    }

    if (dataMap.containsKey('membersphotourl')) {
      this.photoUrl = dataMap['membersphotourl'];
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.email != null && this.email.isNotEmpty) {
      object['membersemail'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      object['membersfullname'] = this.fullName;
    }
    if (this.photoUrl != null && this.photoUrl.isNotEmpty) {
      object['membersphotourl'] = this.photoUrl;
    }

    return object;
  }
}
