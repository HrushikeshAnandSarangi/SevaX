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
  int postTimestamp;
  List<String> admins;
  List<String> coordinators;
  List<String> members;

  TimebankModel({
    this.id,
    this.name,
    this.missionStatement,
    this.postTimestamp,
    this.address,
    this.creatorEmail,
    this.members = const <String>[],
    this.admins = const <String>[],
    this.coordinators = const <String>[],
    this.ownerSevaUserId,
    this.primaryEmail,
    this.primaryNumber,
    this.avatarUrl,
  });

  TimebankModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('timebankname')) {
      this.name = map['timebankname'];
    }
    if (map.containsKey('missionstatement')) {
      this.missionStatement = map['missionstatement'];
    }
    if (map.containsKey('primaryemail')) {
      this.primaryEmail = map['primaryemail'];
    }
    if (map.containsKey('primarynumber')) {
      this.primaryNumber = map['primarynumber'];
    }
    if (map.containsKey('ownersevauserid')) {
      this.ownerSevaUserId = map['ownersevauserid'];
    }
    if (map.containsKey('creatoremail')) {
      this.creatorEmail = map['creatoremail'];
    }
    if (map.containsKey('address')) {
      this.address = map['address'];
    }
    if (map.containsKey('timebankavatarurl')) {
      this.avatarUrl = map['timebankavatarurl'];
    }

    if (map.containsKey('admins')) {
      List adminList = map['admins'];
      this.admins = List.castFrom(adminList);
    }

    if (map.containsKey('coordinators')) {
      List coordinatorList = map['coordinators'];
      this.coordinators = List.castFrom(coordinatorList);
    }

    if (map.containsKey('members')) {
      List memberList = map['members'];
      this.members = List.castFrom(memberList);
    }

//    List membersEmail = map['membersemail'];
//    List membersFullName = map['membersfullname'];
//    List membersPhotoUrl = map['membersphotourl'];
//
//    List<String> membersEmailList = List.castFrom(membersEmail);
//    List<String> membersFullNameList = List.castFrom(membersFullName);
//    List<String> membersPhotoUrlList = List.castFrom(membersPhotoUrl);
//
//    this.members = _getMembersList(
//        emailList: membersEmailList,
//        fullNameList: membersFullNameList,
//        photoUrlList: membersPhotoUrlList);

    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
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
    return object;
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
