import 'dart:collection';
//import 'package:collection/ lib\views\timebank_content_holder.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/views/timebanks/timebank_manage_seva.dart';

class TimebankModel extends DataModel {
  String id;
  String name;
  String missionStatement;
  String emailId;
  String phoneNumber;
  String address;
  String creatorId;
  String photoUrl;
  String cover_url;
  int createdAt;
  List<String> admins;
  List<String> organizers;
  List<String> coordinators;
  List<String> members;
  bool protected;
  bool private;
  bool sponsored;
  String parentTimebankId;
  String communityId;
  String rootTimebankId;
  List<String> children;
  num balance;
  num sandboxBalance;
  GeoFirePoint location;
  bool softDelete;
  bool preventAccedentalDelete;
  bool requestedSoftDelete;
  bool liveMode;
  List<String> managedCreatorIds;
  List<SponsorDataModel> sponsors;

  int unreadMessageCount;
  DateTime lastMessageTimestamp;

  Map<String, NotificationSetting> notificationSetting;
  String associatedParentTimebankId;
  TimebankConfigurations timebankConfigurations;
  // CompareToTimeBank joinStatus;

  // List<String> members;

  TimebankModel(map) {
    this.id = map.containsKey("id") ? map["id"] : '';
    this.name = map.containsKey("name") ? map["name"] : '';
    this.missionStatement =
        map.containsKey("missionStatement") ? map["missionStatement"] : '';
    this.emailId = map.containsKey("email_id") ? map["email_id"] : '';
    this.phoneNumber =
        map.containsKey("phone_number") ? map["phone_number"] : '';
    this.address = map.containsKey("address") ? map["address"] : '';
    this.creatorId = map.containsKey("creator_id") ? map["creator_id"] : '';
    this.photoUrl = map.containsKey("photo_url") ? map["photo_url"] : '';
    this.cover_url = map.containsKey("cover_url") ? map["cover_url"] : '';
    this.createdAt = map.containsKey("created_at") ? map["created_at"] : 0;
    this.admins = map.containsKey("admins") ? List.castFrom(map['admins']) : [];
    this.organizers =
        map.containsKey("organizers") ? List.castFrom(map['organizers']) : [];
    this.coordinators = map.containsKey("coordinators")
        ? List.castFrom(map['coordinators'])
        : [];
    this.members =
        map.containsKey("members") ? List.castFrom(map['members']) : [];
    this.protected = map.containsKey("protected") ? map["protected"] : false;
    this.private = map.containsKey("private") ? map["private"] : false;
    this.sponsored = map.containsKey("sponsored") ? map["sponsored"] : false;
    this.liveMode = map.containsKey("liveMode") ? map["liveMode"] : true;
    this.parentTimebankId =
        map.containsKey("parent_timebank_id") ? map["parent_timebank_id"] : '';
    this.associatedParentTimebankId =
        map.containsKey("associatedParentTimebankId")
            ? map["associatedParentTimebankId"]
            : '';
    this.communityId =
        map.containsKey("community_id") ? map["community_id"] : '';
    this.rootTimebankId =
        map.containsKey("root_timebank_id") ? map["root_timebank_id"] : '';
    this.children =
        map.containsKey("children") ? List.castFrom(map['children']) : [];
    this.balance = map.containsKey("balance") ? map["balance"] : 0.0;
    this.sandboxBalance =
        map.containsKey("sandboxBalance") ? map["sandboxBalance"] : 0.0;
    this.location = getLocation(map);
    this.softDelete = map.containsKey("softDelete") ? map["softDelete"] : false;
    this.preventAccedentalDelete = map.containsKey("preventAccedentalDelete")
        ? map["preventAccedentalDelete"]
        : true;

    this.requestedSoftDelete = map.containsKey("requestedSoftDelete")
        ? map["requestedSoftDelete"]
        : false;

    this.lastMessageTimestamp = map.containsKey("lastMessageTimestamp")
        ? map["lastMessageTimestamp"] != null
            ? (map["lastMessageTimestamp"].toDate())
            : null
        : null;
    this.unreadMessageCount =
        map.containsKey("unreadMessages") ? map["unreadMessages"].length : -1;

    Map<String, Map<dynamic, dynamic>> temp = map
            .containsKey("notificationSetting")
        ? Map<String, Map<dynamic, dynamic>>.from(map["notificationSetting"])
        : Map();
    notificationSetting = HashMap();
    temp.forEach((key, value) {
      notificationSetting[key] = NotificationSetting.fromMap(value);
    });

    this.managedCreatorIds = map.containsKey('managedCreatorIds')
        ? List<String>.from(map['managedCreatorIds'])
        : [];

    this.sponsors = map.containsKey("sponsors")
        ? List<SponsorDataModel>.from(
            map["sponsors"].map((x) => SponsorDataModel.fromMap(x)))
        : [];
    this.timebankConfigurations = map.containsKey('timebankConfigurations')
        ? TimebankConfigurations.fromMap(map['timebankConfigurations'])
        : TimebankConfigurations();
  }

  GeoFirePoint getLocation(map) {
    GeoFirePoint geoFirePoint;
    if (map.containsKey("location") &&
        map["location"] != null &&
        map['location']['geopoint'] != null) {
      if (map['location']['geopoint'] is GeoPoint) {
        GeoPoint geoPoint = map['location']['geopoint'];
        geoFirePoint = Geoflutterfire()
            .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
      } else {
        geoFirePoint = GeoFirePoint(
          map["location"]["geopoint"]["_latitude"],
          map["location"]["geopoint"]["_longitude"],
        );
      }
    } else {
      geoFirePoint = GeoFirePoint(40.754387, -73.984291);
    }
    return geoFirePoint;
  }

  void updateValueByKey(String key, dynamic value) {
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
    if (key == 'cover_url') {
      this.cover_url = value;
    }
    if (key == 'createdAt') {
      this.createdAt = value;
    }
    if (key == 'admins') {
      this.admins = value;
    }

    if (key == 'organizers') {
      this.organizers = value;
    }
    if (key == 'coordinators') {
      this.coordinators = value;
    }
    if (key == 'members') {
      this.members = value;
    }
    if (key == 'managedCreatorIds') {
      this.managedCreatorIds = value;
    }
    if (key == 'protected') {
      this.protected = value;
    }

    if (key == 'private') {
      this.private = value;
    }

    if (key == 'sponsored') {
      this.sponsored = value;
    }
    if (key == 'parentTimebankId') {
      this.parentTimebankId = value;
    }

    if (key == 'associatedParentTimebankId') {
      this.associatedParentTimebankId = value;
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
    if (key == 'sandboxBalance') {
      this.sandboxBalance = value;
    }
    if (key == 'community_id') {
      this.communityId = value;
    }
    if (key == 'preventAccedentalDelete') {
      this.preventAccedentalDelete = value;
    }
    if (key == 'sponsors') {
      this.sponsors = value;
    }
    if (key == 'liveMode') {
      this.liveMode = value;
    }
    if (key == 'timebankConfigurations') {
      this.timebankConfigurations = value;
    }
  }

  factory TimebankModel.fromMap(Map<dynamic, dynamic> json) {
    TimebankModel timebankModel = TimebankModel(json);
    if (json.containsKey('location')) {
      if (json['location']['geopoint'] is GeoPoint) {
        GeoPoint geoPoint = json['location']['geopoint'];
        timebankModel.location = Geoflutterfire()
            .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
      } else {
        timebankModel.location = GeoFirePoint(
          json["location"]["geopoint"]["_latitude"],
          json["location"]["geopoint"]["_longitude"],
        );
        // GeoPoint geoPoint = json['location']['geopoint'];
        // timebankModel.location = Geoflutterfire()
        //     .point(latitude: geoPoint.latitude, longitude: geoPoint.longitude);
      }
    }

    Map<String, Map<dynamic, dynamic>> temp = json
            .containsKey("notificationSetting")
        ? Map<String, Map<dynamic, dynamic>>.from(json["notificationSetting"])
        : Map();
    timebankModel.notificationSetting = HashMap();
    temp.forEach((key, value) {
      timebankModel.notificationSetting[key] =
          NotificationSetting.fromMap(value);
    });

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
      "cover_url": cover_url == null ? null : cover_url,
      "created_at": createdAt == null ? null : createdAt,
      "admins":
          admins == null ? null : List<dynamic>.from(admins.map((x) => x)),
      "organizers": organizers == null
          ? null
          : List<dynamic>.from(organizers.map((x) => x)),
      "coordinators": coordinators == null
          ? null
          : List<dynamic>.from(coordinators.map((x) => x)),
      "members":
          members == null ? null : List<dynamic>.from(members.map((x) => x)),
      "protected": protected == null ? null : protected,
      "private": private == null ? null : private,
      "sponsored": sponsored == null ? null : sponsored,
      "parent_timebank_id": parentTimebankId == null || parentTimebankId.isEmpty
          ? FlavorConfig.values.timebankId
          : parentTimebankId,
      "community_id": communityId == null ? null : communityId,
      "root_timebank_id": rootTimebankId == null ? null : rootTimebankId,
      "associatedParentTimebankId": associatedParentTimebankId == null
          ? null
          : associatedParentTimebankId,
      "children":
          children == null ? null : List<dynamic>.from(children.map((x) => x)),
      "balance": balance == null ? null : balance,
      "sandboxBalance": sandboxBalance == null ? null : sandboxBalance,
      'softDelete': false,
      "lastMessageTimestamp": null,
    };

    if (this.location != null) {
      map['location'] = this.location.data;
    }

    if (this.preventAccedentalDelete != null) {
      map['preventAccedentalDelete'] = this.preventAccedentalDelete;
    } else {
      map['preventAccedentalDelete'] = false;
    }

    if (this.softDelete != null) {
      map['softDelete'] = this.softDelete;
    } else {
      map['softDelete'] = false;
    }
    if (this.sponsored != null) {
      map['sponsored'] = this.sponsored;
    } else {
      map['sponsored'] = false;
    }

    if (this.requestedSoftDelete != null) {
      map['requestedSoftDelete'] = this.requestedSoftDelete;
    } else {
      map['requestedSoftDelete'] = false;
    }

    if (managedCreatorIds != null) {
      map['managedCreatorIds'] = managedCreatorIds;
    }

    if (this.sponsors != null && this.sponsors.isNotEmpty) {
      map['sponsors'] = List<dynamic>.from(sponsors.map((x) => x.toMap()));
    } else {
      map['sponsors'] = [];
    }
    if (this.liveMode != null) {
      map['liveMode'] = this.liveMode;
    } else {
      map['liveMode'] = true;
    }
    if (this.timebankConfigurations != null) {
      map['timebankConfigurations'] = this.timebankConfigurations.toMap();
    }
    return map;
  }

  @override
  String toString() {
    return 'TimebankModel{id: $id, name: $name, missionStatement: $missionStatement, emailId: $emailId, phoneNumber: $phoneNumber, address: $address,liveMode: $liveMode, creatorId: $creatorId, photoUrl: $photoUrl, cover_url: $cover_url, createdAt: $createdAt, admins: $admins,organizers: $organizers, coordinators: $coordinators, members: $members, protected: $protected,sponsored: $sponsored,timebankConfigurations: ${timebankConfigurations.toString()}, parentTimebankId: $parentTimebankId, communityId: $communityId, rootTimebankId: $rootTimebankId, children: $children, balance: $balance, sandboxBalance: $sandboxBalance, location: $location, private: $private}';
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

class SponsorDataModel {
  SponsorDataModel({
    this.logo,
    this.name,
    this.createdAt,
    this.createdBy,
  });

  String logo;
  String name;
  int createdAt;
  String createdBy;

  SponsorDataModel copyWith({
    String logo,
    String name,
    int createdAt,
    String createdBy,
  }) =>
      SponsorDataModel(
        logo: logo ?? this.logo,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
      );

  factory SponsorDataModel.fromMap(Map<dynamic, dynamic> json) =>
      SponsorDataModel(
        logo: json["logo"],
        name: json["name"],
        createdAt: json["created_at"],
        createdBy: json["created_by"],
      );

  Map<String, dynamic> toMap() => {
        "logo": logo,
        "name": name,
        "created_at": createdAt,
        "created_by": createdBy,
      };
}

TimebankConfigurations timebankConfigurationsFromMap(String str) =>
    TimebankConfigurations.fromMap(json.decode(str));

String timebankConfigurationsToMap(TimebankConfigurations data) =>
    json.encode(data.toMap());

class TimebankConfigurations {
  TimebankConfigurations({
    this.admin,
    this.superAdmin,
    this.member,
  });

  List<String> admin;
  List<String> superAdmin;
  List<String> member;

  factory TimebankConfigurations.fromMap(Map<dynamic, dynamic> json) =>
      TimebankConfigurations(
        admin: json["admin"] == null
            ? null
            : List<String>.from(json["admin"].map((x) => x)),
        superAdmin: json["super_admin"] == null
            ? null
            : List<String>.from(json["super_admin"].map((x) => x)),
        member: json["member"] == null
            ? null
            : List<String>.from(json["member"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "admin": admin == null ? null : List<String>.from(admin.map((x) => x)),
        "super_admin": superAdmin == null
            ? null
            : List<String>.from(superAdmin.map((x) => x)),
        "member":
            member == null ? null : List<String>.from(member.map((x) => x)),
      };

  @override
  String toString() {
    return 'TimebankConfigurations{admin: $admin, superAdmin: $superAdmin, member: $member}';
  }
}
