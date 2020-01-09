import 'package:location/location.dart';
import 'package:sevaexchange/models/models.dart';

import '../flavor_config.dart';

class UserModel extends DataModel {
  String bio;
  String email;
  String fullname;
  List<String> interests;
  List<String> skills;
  List<String> communities;
  String currentCommunity;
  String calendar;
  List<String> membershipTimebanks;
  List<String> membershipCampaigns;
  String photoURL;
  String sevaUserID;

  num currentBalance;
  String timezone;
  String otp;
  String requestStatus;
  String locationName;
  String lat_lng;

  int notificationsRead;

  String root_timebank_id;

  //AvailabilityModel availability;
  String currentTimebank = FlavorConfig.values.timebankId;

  int associatedWithTimebanks = 1;
  int adminOfYanagGangs = 0;
  String timebankIdForYangGangAdmin;

  String tokens;

  bool acceptedEULA = false;
  bool completedIntro = false;

  List<String> reportedUsers = [];
  List<String> blockedBy = [];
  List<String> blockedMembers = [];
  LocationData currentPosition;

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
      //this.availability,
      this.timezone,
      this.tokens,
      this.reportedUsers,
      this.blockedMembers,
      this.acceptedEULA,
      this.completedIntro,
      this.blockedBy,
      this.currentPosition,
      this.currentCommunity,
      this.communities}) {
    this.root_timebank_id = FlavorConfig.values.timebankId;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('tokens')) {
      this.tokens = map['tokens'];
    }
    if (map.containsKey('reportedUsers')) {
      List<String> reportedUsersList = List.castFrom(map['reportedUsers']);
      this.reportedUsers = reportedUsersList;
    }

    if (map.containsKey('acceptedEULA')) {
      this.acceptedEULA = map['acceptedEULA'];
    }

    if (map.containsKey('completedIntro')) {
      this.completedIntro = map['completedIntro'];
    }

    if (map.containsKey('blockedMembers')) {
      //print("Blocked Data present");
      List<String> blockedMembers = List.castFrom(map['blockedMembers']);
      this.blockedMembers = blockedMembers;
      // SevaCore.of(context).loggedInUser.blockedMembers = blockedMembers;
    } else {
      this.blockedMembers = List();
      // print("Blocked Data not present");
    }
    if (map.containsKey('communities')) {
      //print("Blocked Data present");
      List<String> communities = List.castFrom(map['communities']);
      this.communities = communities;
    }

    if (map.containsKey('blockedBy')) {
      List<String> blockedBy = List.castFrom(map['blockedBy']);
      this.blockedBy = blockedBy;
      //print("data updated");
    } else {
      this.blockedBy = List();
      //print("data not found");
    }

    if (map.containsKey('bio')) {
      this.bio = map['bio'];
    }

    if (map.containsKey('notificationsRead')) {
      this.notificationsRead = map['notificationsRead'];
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
    if (map.containsKey('currentCommunity')) {
      this.currentCommunity = map['currentCommunity'];
    }
  }

  UserModel.fromDynamic(dynamic user) {
    this.fullname = user['fullname'];
    this.photoURL = user['photourl'];
    this.sevaUserID = user['sevauserid'];
    this.bio = user['bio'];
    this.email = user['email'];
  }

  UserModel setBlockedMembers(List<String> blockedMembers) {
    var tempOutput = new List<String>.from(blockedMembers);
    this.blockedMembers = tempOutput;
    return this;
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
    if (this.reportedUsers != null && this.reportedUsers.isNotEmpty) {
      object['reportedUsers'] = this.reportedUsers;
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
    if (this.communities != null && this.communities.isNotEmpty) {
      object['communities'] = this.communities;
    }
    if (this.currentCommunity != null) {
      object['currentCommunity'] = this.currentCommunity;
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

    if (this.completedIntro != null) {
      this.completedIntro = object['completedIntro'];
    }

    if (this.notificationsRead != null) {
      object['notificationsRead'] = this.notificationsRead;
    } else {
      this.notificationsRead = 0;
    }

    return object;
  }

  @override
  String toString() {
    return '''
      ${this.bio.toString()},
      ${this.email.toString()},
      ${this.fullname.toString()},
      ${this.photoURL.toString()},
      ${this.interests.toString()},
      ${this.membershipCampaigns.toString()},
      ${this.membershipTimebanks.toString()},
      ${this.sevaUserID.toString()},
      ${this.skills.toString()},
      ${this.currentBalance.toString()},
      ${this.calendar.toString()},
      ${this.otp.toString()},
      ${this.requestStatus.toString()},
      ${this.timezone.toString()},
      ${this.tokens.toString()},
      ${this.reportedUsers.toString()},
      ${this.blockedMembers.toString()},
      ${this.blockedBy.toString()},
      ${this.currentPosition.toString()},
      ${this.acceptedEULA.toString()},
    ''';
  }
}
