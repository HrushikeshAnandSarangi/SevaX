import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:sevaexchange/models/device_details.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/utils/data_managers/timebank_data_manager.dart';

import '../flavor_config.dart';

class UserModel extends DataModel {
  bool seenIntro;
  String bio;
  String email;
  String fullname;
  List<String> interests;
  List<String> skills;
  List<String> communities = [];
  String currentCommunity;
  String calendar;
  List<String> membershipTimebanks;
  List<String> membershipCampaigns;
  List<String> favoriteByTimeBank;
  List<String> favoriteByMember;
  List<String> recommendedForRequestIds;
  String photoURL;
  String sevaUserID;
  List<String> invitedRequests;
  double currentBalance;
  double sandboxCurrentBalance;
  double trustworthinessscore;
  double reliabilityscore;
  int totalReviews;
  String timezone;
  String otp;
  String requestStatus;
  String locationName;
  String lat_lng;
  bool emailSent;
  String language;
  String cvUrl;
  String cvName;
  bool skipCreateCommunityPage;

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
  List<String> curatedRequestIds = [];
  bool notificationAlerts;

  String calendarId;
  int calendarAccId;
  String calendarAccessToken;
  String calendarEmail;
  String calendarScope;
  DeviceDetails deviceDetails;
  DeviceDetails creationSource;

  UserModel(
      {this.seenIntro,
      this.calendarScope,
      this.calendarEmail,
      this.calendarAccessToken,
      this.calendarId,
      this.calendarAccId,
      this.bio,
      this.email,
      this.fullname,
      this.photoURL,
      this.interests,
      this.membershipCampaigns,
      this.membershipTimebanks,
      this.favoriteByMember,
      this.favoriteByTimeBank,
      this.recommendedForRequestIds,
      this.sevaUserID,
      this.skills,
      this.currentBalance,
      this.sandboxCurrentBalance,
      this.reliabilityscore,
      this.trustworthinessscore,
      this.totalReviews,
      this.calendar,
      this.otp,
      this.requestStatus,
      //this.availability,
      this.skipCreateCommunityPage,
      this.currentTimebank,
      this.timezone,
      this.tokens,
      this.reportedUsers,
      this.blockedMembers,
      this.acceptedEULA,
      this.completedIntro,
      this.pastHires,
      this.blockedBy,
      this.currentCommunity,
      this.communities,
      this.emailSent,
      this.language,
      this.notificationAlerts,
      this.cvUrl,
      this.cvName,
      this.deviceDetails,
      this.curatedRequestIds,
      this.creationSource});

  UserModel.fromMap(Map<String, dynamic> map, @required String from) {
    if (map.containsKey('calendarScope')) {
      this.calendarScope = map['calendarScope'];
    }
    if (map.containsKey('seenIntro')) {
      this.seenIntro = map['seenIntro'];
    } else {
      this.seenIntro = false;
    }
    if (map.containsKey('calendarEmail')) {
      this.calendarEmail = map['calendarEmail'];
    }
    if (map.containsKey('calendarId')) {
      this.calendarId = map['calendarId'];
    }
    if (map.containsKey('skipCreateCommunityPage')) {
      this.skipCreateCommunityPage = map['skipCreateCommunityPage'] ?? false;
    } else {
      this.skipCreateCommunityPage = false;
    }
    if (map.containsKey('calendarAccId')) {
      this.calendarAccId = map['calendarAccId'];
    }
    if (map.containsKey('calendarAccessToken')) {
      this.calendarAccessToken = map['calendarAccessToken'];
    }
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
      //  log("Nearby Settings for user not found....");
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
      this.pastHires = [];
    }
    if (map.containsKey('recommendedForRequestIds')) {
      List<String> recommendedForRequests =
          List.castFrom(map['recommendedForRequestIds']);
      this.recommendedForRequestIds = recommendedForRequests;
    } else {
      this.recommendedForRequestIds = [];
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
      this.blockedMembers = [];
    }

    if (map.containsKey('curatedRequestIds')) {
      List<String> curatedRequests = List.castFrom(map['curatedRequestIds']);
      this.curatedRequestIds = curatedRequests;
    } else {
      this.curatedRequestIds = [];
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
      this.communities = [FlavorConfig.values.timebankId];
    }

    if (map.containsKey('blockedBy')) {
      List<String> blockedBy = List.castFrom(map['blockedBy']);
      this.blockedBy = blockedBy;
    } else {
      this.blockedBy = [];
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
    } else {
      this.fullname = "Anonymous";
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
    } else {
      this.membershipTimebanks = [FlavorConfig.values.timebankId];
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

    if (map.containsKey('sandboxCurrentBalance')) {
      this.sandboxCurrentBalance = map['sandboxCurrentBalance'].toDouble();
    } else {
      this.sandboxCurrentBalance = 0.0;
    }
    if (map.containsKey('trustworthinessscore')) {
      this.trustworthinessscore = map['trustworthinessscore'].toDouble();
    } else {
      this.trustworthinessscore = 0.0;
    }
    if (map.containsKey('reliabilityscore')) {
      this.reliabilityscore = map['reliabilityscore'].toDouble();
    } else {
      this.reliabilityscore = 0.0;
    }
    if (map.containsKey('totalReviews')) {
      this.totalReviews = map['totalReviews'];
    } else {
      this.totalReviews = 0;
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

    if (map.containsKey('deviceDetails')) {
      this.deviceDetails = DeviceDetails.fromMap(
        Map<String, dynamic>.from(
          map['deviceDetails'],
        ),
      );
    } else {
      this.deviceDetails = DeviceDetails();
    }
  }

  UserModel.fromDynamic(UserModel user) {
    this.fullname = user.fullname == null || user.fullname.isEmpty
        ? "Anonymous"
        : user.fullname;
    this.photoURL = user.photoURL;
    this.sevaUserID = user.sevaUserID;
    this.bio = user.bio;
    this.email = user.email;
    this.communities = List.castFrom(user.communities);
  }

  bool operator ==(o) => o is UserModel && o.sevaUserID == sevaUserID;

  int get hashCode => sevaUserID.hashCode;

  UserModel setBlockedMembers(List<String> blockedMembers) {
    var tempOutput = List<String>.from(blockedMembers);
    this.blockedMembers = tempOutput;
    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.calendarId != null && this.calendarId.isNotEmpty) {
      object['calendarId'] = this.calendarId;
    }
    if (this.calendarScope != null) {
      object['calendarScope'] = this.calendarScope;
    }
    if (this.seenIntro != null) {
      object['seenIntro'] = this.seenIntro;
    }
    if (this.calendarEmail != null) {
      object['calendarEmail'] = this.calendarEmail;
    }
    if (this.calendarAccessToken != null) {
      object['calendarAccessToken'] = this.calendarAccessToken;
    }
    if (this.calendarAccId != null) {
      object['calendarAccId'] = this.calendarAccId;
    }
    if (this.bio != null && this.bio.isNotEmpty) {
      object['bio'] = this.bio;
    }
    if (this.email != null && this.email.isNotEmpty) {
      object['email'] = this.email;
    }
    if (this.fullname != null && this.fullname.isNotEmpty) {
      object['fullname'] = this.fullname;
    } else {
      object['fullname'] = "Anonymous";
    }
    if (this.photoURL != null && this.photoURL.isNotEmpty) {
      object['photourl'] = this.photoURL;
    }
    if (this.interests != null) {
      object['interests'] = this.interests;
    }
    if (this.skipCreateCommunityPage != null) {
      object['skipCreateCommunityPage'] = this.skipCreateCommunityPage;
    }
    if (this.calendar != null) {
      object['calendar'] = this.calendar;
    }
    if (this.reportedUsers != null && this.reportedUsers.isNotEmpty) {
      object['reportedUsers'] = this.reportedUsers;
    }
    if (this.recommendedForRequestIds != null &&
        this.recommendedForRequestIds.isNotEmpty) {
      object['recommendedForRequestIds'] = this.recommendedForRequestIds;
    }
    if (this.curatedRequestIds != null && this.curatedRequestIds.isNotEmpty) {
      object['curatedRequestIds'] = this.curatedRequestIds;
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
      object['communities'] = [FlavorConfig.values.timebankId];
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
    if (this.sandboxCurrentBalance != null) {
      object['sandboxCurrentBalance'] = this.sandboxCurrentBalance;
    } else {
      object['sandboxCurrentBalance'] = 0;
    }
    if (this.trustworthinessscore != null) {
      object['trustworthinessscore'] = this.trustworthinessscore;
    } else {
      object['trustworthinessscore'] = 0;
    }
    if (this.reliabilityscore != null) {
      object['reliabilityscore'] = this.reliabilityscore;
    } else {
      object['reliabilityscore'] = 0;
    }
    if (this.totalReviews != null) {
      object['totalReviews'] = this.totalReviews;
    } else {
      object['totalReviews'] = 0;
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
    if (this.deviceDetails != null) {
      object['deviceDetails'] = this.deviceDetails.toMap();
    }
    if (this.creationSource != null) {
      object['creationSource'] = this.creationSource.toMap();
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
      ${this.curatedRequestIds.toString()},
      ${this.recommendedForRequestIds.toString()},
      ${this.sevaUserID.toString()},
      ${this.skills.toString()},
      ${this.currentBalance.toString()},
      ${this.sandboxCurrentBalance.toString()},
      ${this.reliabilityscore.toString()},
      ${this.totalReviews.toString()}, 
      ${this.trustworthinessscore.toString()},
      ${this.calendar.toString()},
      ${this.otp.toString()},
      ${this.requestStatus.toString()},
      ${this.timezone.toString()},
      ${this.language.toString()},
      ${this.tokens.toString()},
      ${this.reportedUsers.toString()},
      ${this.blockedMembers.toString()},
      ${this.blockedBy.toString()},
      ${this.acceptedEULA.toString()},
      ${this.currentTimebank.toString()},
      ${this.notificationAlerts.toString()},
      ${this.cvUrl.toString()},
      ${this.deviceDetails.toString()},
      ${this.creationSource.toString()},
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
