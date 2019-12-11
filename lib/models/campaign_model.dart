import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/timebank_model.dart';

class CampaignModel extends DataModel {
  String id;
  String name;
  String parentTimebankId;
  String missionStatement;
  String primaryEmail;
  String primaryNumber;
  String ownerSevaUserId;
  String creatorEmail;
  String address;
  String avatarUrl;
  int postTimestamp;
  List<Member> members;

  CampaignModel({
    this.id,
    this.name,
    this.parentTimebankId,
    this.missionStatement,
    this.postTimestamp,
    this.address,
    this.creatorEmail,
    this.members = const <Member>[],
    this.ownerSevaUserId,
    this.primaryEmail,
    this.primaryNumber,
    this.avatarUrl,
  });

  CampaignModel.fromMap(Map<String, dynamic> map) {
    assert(map != null, 'Map cannot be null');

    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('campaignname')) {
      this.name = map['campaignname'];
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
    if (map.containsKey('campaignavatarurl')) {
      this.avatarUrl = map['campaignavatarurl'];
    }
    if (map.containsKey('parent_timebank')) {
      this.parentTimebankId = map['parent_timebank'];
    }

    List membersEmail = map['membersemail'];
    List membersFullName = map['membersfullname'];
    List membersPhotoUrl = map['membersphotourl'];

    List<String> membersEmailList = List.castFrom(membersEmail);
    List<String> membersFullNameList = List.castFrom(membersFullName);
    List<String> membersPhotoUrlList = List.castFrom(membersPhotoUrl);

    this.members = _getMembersList(
        emailList: membersEmailList,
        fullNameList: membersFullNameList,
        photoUrlList: membersPhotoUrlList);

    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.name != null && this.name.isNotEmpty) {
      object['campaignname'] = this.name;
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
      object['campaignavatarurl'] = this.avatarUrl;
    }
    if (this.postTimestamp != null) {
      object['posttimestamp'] = this.postTimestamp;
    }
    if (this.parentTimebankId != null && this.parentTimebankId.isNotEmpty) {
      object['parent_timebank'] = this.parentTimebankId;
    }

    if (this.members != null) {
      List<String> emailList = [];
      List<String> nameList = [];
      List<String> urlList = [];

      members.forEach((member) {
        emailList.add(member.email);
        nameList.add(member.fullName);
        urlList.add(member.photoUrl);
      });

      object['membersemail'] = emailList;
      object['membersfullname'] = nameList;
      object['membersphotourl'] = urlList;
    }

    return object;
  }

  List<Member> _getMembersList({
    List<String> emailList,
    List<String> fullNameList,
    List<String> photoUrlList,
  }) {
    assert(
        emailList.length == fullNameList.length &&
            emailList.length == photoUrlList.length,
        'Member list sizes are not equal');

    List<Member> memberList = [];
    for (int i = 0; i < emailList.length; i += 1) {
      Member member = Member(
        email: emailList[i],
        photoUrl: photoUrlList[i],
        fullName: fullNameList[i],
      );
      memberList.add(member);
    }

    return memberList;
  }
}
