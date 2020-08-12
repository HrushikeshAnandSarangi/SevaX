import 'dart:collection';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';

import '../flavor_config.dart';

class UserModel extends DataModel {
  String bio;
  String email;
  String fullname;
  List<String> interests;
  List<String> skills;
  List<String> communities = List();
  String currentCommunity;
  String calendar;
  List<String> membershipTimebanks;
  List<String> membershipCampaigns;
  List<String> favoriteByTimeBank;
  List<String> favoriteByMember;
  String photoURL;
  String sevaUserID;
  List<String> invitedRequests;
  double currentBalance;
  String timezone;
  String otp;
  String requestStatus;
  String locationName;
  String lat_lng;
  bool emailSent;
  String language;
  String cvUrl;
  String cvName;

  NearBySettings nearBySettings;

  int notificationsRead;
  Map<dynamic, dynamic> notificationsReadCount;
  Map<dynamic, dynamic> notificationSetting;

  String root_timebank_id;

  //AvailabilityModel availability;
  String currentTimebank = FlavorConfig.values.timebankId;

  int associatedWithTimebanks = 1;
  int adminOfYanagGangs = 0;
  String timebankIdForYangGangAdmin;

  String tokens;

  bool acceptedEULA = false;
  bool completedIntro = false;

  List<String> pastHires = [];
  List<String> reportedUsers = [];
  List<String> blockedBy = [];
  List<String> blockedMembers = [];
  LocationData currentPosition;
  bool notificationAlerts;

  UserModel(
      {this.bio,
      this.email,
      this.fullname,
      this.photoURL,
      this.interests,
      this.membershipCampaigns,
      this.membershipTimebanks,
      this.favoriteByMember,
      this.favoriteByTimeBank,
      this.sevaUserID,
      this.skills,
      this.currentBalance,
      this.calendar,
      this.otp,
      this.requestStatus,
      //this.availability,
      this.currentTimebank,
      this.timezone,
      this.tokens,
      this.reportedUsers,
      this.blockedMembers,
      this.acceptedEULA,
      this.completedIntro,
      this.pastHires,
      this.blockedBy,
      this.currentPosition,
      this.currentCommunity,
      this.communities,
      this.emailSent,
      this.language,
      this.notificationAlerts,
      this.cvUrl,
      this.cvName});

  UserModel.fromMap(Map<String, dynamic> map, @required String from) {
    log("Called from $from");

    if (map.containsKey('nearbySettings')) {
      Map<dynamic, dynamic> _neabySetting = map['nearbySettings'];
      this.nearBySettings = NearBySettings()
        ..isMiles = _neabySetting.containsKey('isMiles')
            ? _neabySetting['isMiles']
            : true
        ..radius =
            _neabySetting.containsKey('radius') ? _neabySetting['radius'] : 10;
      // log("Found nearby settings " +
      //     nearBySettings.toString() +
      //     DateTime.now().toString());
    } else {
      log("Nearby Settings for user not found....");
    }

    if (map.containsKey('tokens')) {
      this.tokens = map['tokens'];
    } else {
      this.tokens = "";
    }
    if (map.containsKey('reportedUsers')) {
      List<String> reportedUsersList = List.castFrom(map['reportedUsers']);
      this.reportedUsers = reportedUsersList;
    }
    if (map.containsKey('recommendedTimebank')) {
      List<String> pasthires = List.castFrom(map['recommendedTimebank']);
      this.pastHires = pasthires;
    } else {
      this.pastHires = List();
    }
    if (map.containsKey('emailSent')) {
      this.emailSent = map['emailSent'] ?? false;
    } else {
      this.emailSent = false;
    }
    if (map.containsKey('acceptedEULA')) {
      this.acceptedEULA = map['acceptedEULA'];
    }

    if (map.containsKey('completedIntro')) {
      this.completedIntro = map['completedIntro'];
    }

    if (map.containsKey('blockedMembers')) {
      List<String> blockedMembers = List.castFrom(map['blockedMembers']);
      this.blockedMembers = blockedMembers;
    } else {
      this.blockedMembers = List();
    }

    if (map.containsKey('currentCommunity')) {
      this.currentCommunity = map['currentCommunity'];
    } else {
      currentCommunity = "";
    }

    if (map.containsKey('communities')) {
      List<String> communities = List.castFrom(map['communities']);
      this.communities = communities;
    } else {
      ///TODO Why this asdfadf ?
      this.communities = List();
      this.communities.add('asdfadf');
    }

    if (map.containsKey('blockedBy')) {
      List<String> blockedBy = List.castFrom(map['blockedBy']);
      this.blockedBy = blockedBy;
    } else {
      this.blockedBy = List();
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
    if (map.containsKey('invitedRequests')) {
      List<String> invitedRequests = List.castFrom(map['invitedRequests']);
      this.invitedRequests = invitedRequests;
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
    if (map.containsKey('membershipTimebanks')) {
      List<String> timebanksList = List.castFrom(map['membershipTimebanks']);
      this.membershipTimebanks = timebanksList;
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserID = map['sevauserid'];
    }
    if (map.containsKey('skills')) {
      List<String> skillsList = List.castFrom(map['skills']);
      this.skills = skillsList;
    }
    if (map.containsKey('favoriteByMember')) {
      List<String> favoriteByMemberList =
          List.castFrom(map['favoriteByMember']);
      this.favoriteByMember = favoriteByMemberList;
    }
    if (map.containsKey('favoriteByTimeBank')) {
      List<String> favoriteByTimeBankList =
          List.castFrom(map['favoriteByTimeBank']);
      this.favoriteByTimeBank = favoriteByTimeBankList;
    }
    if (map.containsKey('currentBalance')) {
      this.currentBalance = map['currentBalance'].toDouble();
    } else {
      this.currentBalance = 0.0;
    }
    if (map.containsKey('requestStatus')) {
      this.requestStatus = map['requestStatus'];
    }
    if (map.containsKey('timezone')) {
      this.timezone = map['timezone'];
    } else {
      this.timezone = 'Pacific Standard Time';
    }
    if (map.containsKey('currentCommunity')) {
      this.currentCommunity = map['currentCommunity'];
    }
    if (map.containsKey('language')) {
      this.language = map['language'];
    } else {
      this.language = 'en';
    }
    if (map.containsKey('currentTimebank')) {
      this.currentTimebank = map['currentTimebank'];
    }
    if (map.containsKey('notificationsReadCount') &&
        map['notificationsReadCount'] != null) {
      try {
        Map<dynamic, dynamic> deletedByMap = map['notificationsReadCount'];
        this.notificationsReadCount = deletedByMap;
      } catch (e) {
        this.notificationsReadCount = HashMap();
      }
    } else {
      notificationsReadCount = HashMap();
    }

    if (map.containsKey('notificationSetting') &&
        map['notificationSetting'] != null) {
      try {
        Map<dynamic, dynamic> _notificationSetting = map['notificationSetting'];
        this.notificationSetting = _notificationSetting;
      } catch (e) {
        this.notificationSetting = HashMap();
      }
    } else {
      notificationSetting = HashMap();
    }

    if (map.containsKey('notificationAlerts')) {
      this.notificationAlerts = map['notificationAlerts'];
    } else {
      this.notificationAlerts = true;
    }
    if (map.containsKey('cvName')) {
      this.cvName = map['cvName'];
    }
    if (map.containsKey('cvUrl')) {
      this.cvUrl = map['cvUrl'];
    }

//    else{
//      this.cvUrl='';
//    }
  }

  UserModel.fromDynamic(dynamic user) {
    this.fullname = user['fullname'];
    this.photoURL = user['photourl'];
    this.sevaUserID = user['sevauserid'];
    this.bio = user['bio'];
    this.email = user['email'];
    this.communities = List.castFrom(user['communities']);
  }

  UserModel setBlockedMembers(List<String> blockedMembers) {
    var tempOutput = List<String>.from(blockedMembers);
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
    if (this.interests != null) {
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
      object['membershipTimebanks'] = this.membershipTimebanks;
    }
    if (this.sevaUserID != null && this.sevaUserID.isNotEmpty) {
      object['sevauserid'] = this.sevaUserID;
    }
    if (this.skills != null) {
      object['skills'] = this.skills;
    }
    if (this.communities != null && this.communities.isNotEmpty) {
      object['communities'] = this.communities;
    } else {
      object['communities'] = List();
    }
    if (this.favoriteByTimeBank != null && this.favoriteByTimeBank.isNotEmpty) {
      object['favoriteByTimeBank'] = this.favoriteByTimeBank;
    }
    if (this.favoriteByMember != null && this.favoriteByMember.isNotEmpty) {
      object['favoriteByMember'] = this.favoriteByMember;
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
      object['timezone'] = 'Pacific Standard Time';
    }
    if (this.language != null) {
      object['language'] = this.language;
    } else {
      object['language'] = 'en';
    }

    if (this.currentTimebank != null) {
      object['currentTimebank'] = this.currentTimebank;
    }

    if (this.completedIntro != null) {
      this.completedIntro = object['completedIntro'];
    }

    if (this.notificationsRead != null) {
      object['notificationsRead'] = this.notificationsRead;
    } else {
      this.notificationsRead = 0;
    }

    if (this.pastHires != null && this.pastHires.isNotEmpty) {
      object['recommendedTimebank'] = this.pastHires;
    } else {
      object['recommendedTimebank'] = [];
    }
    object['root_timebank_id'] = FlavorConfig.values.timebankId;
    // if (this.notificationAlerts != null) {
    //   this.notificationAlerts = object['notificationAlerts'];
    // }
    if (this.cvUrl != null) {
      object['cvUrl'] = this.cvUrl;
    }

    if (this.cvName != null) {
      object['cvName'] = this.cvName;
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
      ${this.favoriteByMember.toString()},
      ${this.favoriteByTimeBank.toString()},
      ${this.sevaUserID.toString()},
      ${this.skills.toString()},
      ${this.currentBalance.toString()},
      ${this.calendar.toString()},
      ${this.otp.toString()},
      ${this.requestStatus.toString()},
      ${this.timezone.toString()},
      ${this.language.toString()},
      ${this.tokens.toString()},
      ${this.reportedUsers.toString()},
      ${this.blockedMembers.toString()},
      ${this.blockedBy.toString()},
      ${this.currentPosition.toString()},
      ${this.acceptedEULA.toString()},
      ${this.currentTimebank.toString()},
      ${this.notificationAlerts.toString()},
      ${this.cvUrl.toString()},
      Communities:${this.communities.toString()},
    ''';
  }
}

class UserListModel {
  List<UserModel> users = [];
  bool loading = false;
  UserListModel();

  void add(user) {
    this.users.add(user);
  }

  void removeall() {
    this.users = [];
  }

  List<UserModel> get getUsers => users;
}
