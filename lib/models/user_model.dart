import 'package:sevaexchange/models/models.dart';

import '../flavor_config.dart';

class UserModel extends DataModel {
  String bio;
  String email;
  String fullname;
  List<String> interests;
  String calendar;
  List<String> membershipTimebanks;
  List<String> membershipCampaigns;
  String photoURL;
  String sevaUserID;
  List<String> skills;
  num currentBalance;
  String timezone;
  String otp;
  String requestStatus;
  String currentTimebank =  FlavorConfig.values.timebankId;
  String locationName;
  String lat_lng;
  //String

  UserModel(
      {this.bio,
      this.email,
      this.fullname,
      this.photoURL,
      this.interests,
      this.membershipCampaigns,
      this.membershipTimebanks,
      this.sevaUserID,
      this.skills,
      this.currentBalance,
      this.calendar,
        this.otp,
      this.requestStatus,
      this.timezone,
      });


  UserModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('bio')) {
      this.bio = map['bio'];
    }
    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullname')) {
      this.fullname = map['fullname'];
    }
    if (map.containsKey('photourl')) {
      this.photoURL = map['photourl'];
    }
    if (map.containsKey('interests')) {
      List<String> interestsList = List.castFrom(map['interests']);
      this.interests = interestsList;
    }
    if (map.containsKey('calendar')) {
      this.calendar = map['calendar'];
      print("----------------------- present");
    } else {
      print("----------------------- not present");
    }
    if (map.containsKey('otp')) {
      this.email = map['otp'];
    }
    if (map.containsKey('membership_campaigns')) {
      List<String> campaignList = List.castFrom(map['membership_campaigns']);
      this.membershipCampaigns = campaignList;
    }
    if (map.containsKey('membership_timebanks')) {
      List<String> timebanksList = List.castFrom(map['membership_timebanks']);
      this.membershipTimebanks = timebanksList;
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserID = map['sevauserid'];
    }
    if (map.containsKey('skills')) {
      List<String> skillsList = List.castFrom(map['skills']);
      this.skills = skillsList;
    }
    if (map.containsKey('currentBalance')) {
      this.currentBalance = map['currentBalance'];
    } else {
      this.currentBalance = 0;
    }
    if (map.containsKey('requestStatus')) {
      this.requestStatus = map['requestStatus'];
    }
    if (map.containsKey('timezone')) {
      this.timezone = map['timezone'];
    } else {
      this.timezone = 'PT';
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.bio != null && this.bio.isNotEmpty) {
      object['bio'] = this.bio;
    }
    if (this.email != null && this.email.isNotEmpty) {
      object['email'] = this.email;
    }
    if (this.fullname != null && this.fullname.isNotEmpty) {
      object['fullname'] = this.fullname;
    }
    if (this.photoURL != null && this.photoURL.isNotEmpty) {
      object['photourl'] = this.photoURL;
    }
    if (this.interests != null && this.interests.isNotEmpty) {
      object['interests'] = this.interests;
    }
    if (this.calendar != null) {
      object['calendar'] = this.calendar;
    }
    if (this.requestStatus != null) {
      object['requestStatus'] = this.requestStatus;
    }
    if (this.otp != null) {
      object['otp'] = this.otp;
    }
    if (this.membershipCampaigns != null &&
        this.membershipCampaigns.isNotEmpty) {
      object['membership_campaigns'] = this.membershipCampaigns;
    }
    if (this.membershipTimebanks != null &&
        this.membershipTimebanks.isNotEmpty) {
      object['membership_timebanks'] = this.membershipTimebanks;
    }
    if (this.sevaUserID != null && this.sevaUserID.isNotEmpty) {
      object['sevauserid'] = this.sevaUserID;
    }
    if (this.skills != null && this.skills.isNotEmpty) {
      object['skills'] = this.skills;
    }
    if (this.currentBalance != null) {
      object['currentBalance'] = this.currentBalance;
    } else {
      object['currentBalance'] = 0;
    }
    if (this.timezone != null) {
      object['timezone'] = this.timezone;
    } else {
      object['timezone'] = 'PT';
    }
    return object;
  }
}


