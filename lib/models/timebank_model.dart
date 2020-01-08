import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/models.dart';

class TimebankModel extends DataModel {
  String id;
  String name;
  String missionStatement;
  String primaryEmail;
  String primaryNumber;
  String address;
  String avatarUrl;
  String ownerSevaUserId;
  String creatorEmail;
  bool protected;
  String rootTimebankId;
  String parentTimebankId;
  GeoFirePoint location;
  String locationAddress;
  int postTimestamp;
  List<String> admins;
  List<String> coordinators;
  List<String> members;

  TimebankModel(Map<String, dynamic> map) {
    this.id = map.containsKey('id') ? map['id']: '';
    this.name = map.containsKey('name') ? map['name']: '';
    this.missionStatement = map.containsKey('missionStatement') ? map['missionStatement']: '';
    this.postTimestamp = map.containsKey('postTimestamp') ? map['postTimestamp']: 0;
    this.address = map.containsKey('address') ? map['address']: '';
    this.creatorEmail = map.containsKey('creatorEmail') ? map['creatorEmail']: '';
    this.protected = map.containsKey('protected') ? map['protected']: false;
    this.locationAddress = map.containsKey('locationAddress') ? map['locationAddress']: '';
    this.members = map.containsKey('members') ? List.castFrom(map['members']): [];
    this.admins = map.containsKey('admins') ? List.castFrom(map['admins']): [];
    this.coordinators = map.containsKey('coordinators') ? List.castFrom(map['coordinators']): [];
    this.ownerSevaUserId = map.containsKey('ownerSevaUserId') ? map['ownerSevaUserId']: '';
    this.primaryEmail = map.containsKey('primaryEmail') ? map['primaryEmail']: '';
    this.primaryNumber = map.containsKey('primaryNumber') ? map['primaryNumber']: '';
    this.avatarUrl = map.containsKey('avatarUrl') ? map['avatarUrl']: '';
  }

  updateValueByKey(String key, dynamic value) {
    if (key =='id') {
      this.id= value;
    }
    if (key =='name') {
      this.name= value;
    }
    if (key =='missionStatement') {
      this.missionStatement= value;
    }
    if (key =='postTimestamp') {
      this.postTimestamp= value;
    }
    if (key =='address') {
      this.address= value;
    }
    if (key =='creatorEmail') {
      this.creatorEmail= value;
    }
    if (key == 'protected') {
      this.protected = value;
    }
    if (key =='ownerSevaUserId') {
      this.ownerSevaUserId= value;
    }
    if (key =='primaryEmail') {
      this.primaryEmail= value;
    }
    if (key =='primaryNumber') {
      this.primaryNumber= value;
    }
    if (key =='avatarUrl') {
      this.avatarUrl= value;
    }
    if (key == 'locationAddress') {
      this.locationAddress = value;
    }
  }
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.name != null && this.name.isNotEmpty) {
      object['timebankname'] = this.name;
    }
    if (this.missionStatement != null && this.missionStatement.isNotEmpty) {
      object['missionstatement'] = this.missionStatement;
    }
    if (this.primaryEmail != null && this.primaryEmail.isNotEmpty) {
      object['primaryemail'] = this.primaryEmail;
    }
    if (this.primaryNumber != null && this.primaryNumber.isNotEmpty) {
      object['primarynumber'] = this.primaryNumber;
    }
    if (this.ownerSevaUserId != null && this.ownerSevaUserId.isNotEmpty) {
      object['ownersevauserid'] = this.ownerSevaUserId;
    }
    if (this.creatorEmail != null && this.creatorEmail.isNotEmpty) {
      object['creatoremail'] = this.creatorEmail;
    }
    if (this.protected != null) {
      object['protected'] = this.protected;
    }
    if (this.address != null && this.address.isNotEmpty) {
      object['address'] = this.address;
    }
    if (this.avatarUrl != null && this.avatarUrl.isNotEmpty) {
      object['timebankavatarurl'] = this.avatarUrl;
    }
    if (this.postTimestamp != null) {
      object['posttimestamp'] = this.postTimestamp;
    }
    if (this.admins != null) {
      object['admins'] = this.admins;
    }
    if (this.coordinators != null) {
      object['coordinators'] = this.coordinators;
    }
    if (this.members != null) {
      object['members'] = this.members;
    }
    if (this.rootTimebankId != null) {
      object['rootTimebankId'] = this.rootTimebankId;
    }
    if (this.parentTimebankId != null) {
      object['parentTimebankId'] = this.parentTimebankId;
    }
    if (this.location != null) {
      object['location'] = this.location;
    }
    if (this.locationAddress != null) {
      object['locationAddress'] = this.locationAddress;
    }
    return object;
  }
}
//
//class Member extends DataModel {
//  String email;
//  String fullName;
//  String photoUrl;
//
//  Member({this.fullName, this.email, this.photoUrl});
//
//  Member.fromMap(Map<String, dynamic> dataMap) {
//    if (dataMap.containsKey('membersemail')) {
//      this.email = dataMap['membersemail'];
//    }
//
//    if (dataMap.containsKey('membersfullname')) {
//      this.fullName = dataMap['membersfullname'];
//    }
//
//    if (dataMap.containsKey('membersphotourl')) {
//      this.photoUrl = dataMap['membersphotourl'];
//    }
//  }
//
//  Map<String, dynamic> toMap() {
//    Map<String, dynamic> object = {};
//
//    if (this.email != null && this.email.isNotEmpty) {
//      object['membersemail'] = this.email;
//    }
//    if (this.fullName != null && this.fullName.isNotEmpty) {
//      object['membersfullname'] = this.fullName;
//    }
//    if (this.photoUrl != null && this.photoUrl.isNotEmpty) {
//      object['membersphotourl'] = this.photoUrl;
//    }
//
//    return object;
//  }
//}
