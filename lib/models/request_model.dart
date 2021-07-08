import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/models/basic_user_details.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/selectedSpeakerTimeDetails.dart';
import 'package:sevaexchange/utils/helpers/location_helper.dart';
import 'package:sevaexchange/utils/utils.dart';

class TaskModel extends DataModel {
  String id;
  String sevaUserId;
  String title;
  int requestStart;
  int requestEnd;
  Color color;
  String description;
  String fullName;
  int postTimestamp;
  String email;
  String requestid;
  String timebankId;

  TaskModel(
      {this.id,
      this.sevaUserId,
      this.title,
      this.requestStart,
      this.requestEnd,
      this.color,
      this.description,
      this.fullName,
      this.postTimestamp,
      this.email,
      this.requestid,
      this.timebankId});

  TaskModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }
    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('requestStart')) {
      this.requestStart = map['requestStart'];
    }
    if (map.containsKey('requestEnd')) {
      this.requestEnd = map['requestEnd'];
    }
    if (map.containsKey('color')) {
      this.color = map['color'];
    }
    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('postTimestamp')) {
      this.postTimestamp = map['postTimestamp'];
    }
    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('requestid')) {
      this.requestid = map['requestid'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.id != null && this.id.isNotEmpty) {
      object['id'] = this.id;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      object['sevaUserId'] = this.sevaUserId;
    }
    if (this.title != null && this.title.isNotEmpty) {
      object['title'] = this.title;
    }
    if (this.requestStart != null) {
      object['requestStart'] = this.requestStart;
    }
    if (this.requestEnd != null) {
      object['requestEnd'] = this.requestEnd;
    }
    if (this.color != null) {
      object['color'] = this.color;
    }
    if (this.description != null && this.description.isNotEmpty) {
      object['description'] = this.description;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      object['fullName'] = this.fullName;
    }
    if (this.postTimestamp != null) {
      object['postTimestamp'] = this.postTimestamp;
    }
    if (this.email != null && this.email.isNotEmpty) {
      object['email'] = this.email;
    }
    if (this.requestid != null && this.requestid.isNotEmpty) {
      object['requestid'] = this.requestid;
    }
    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
  }
}

class End extends DataModel {
  String endType = "on";
  int on;
  int after;

  End({this.endType, this.on, this.after});

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};
    if (this.endType != null) {
      object['endType'] = this.endType;
    }
    if (this.on != null) {
      object['on'] = this.on;
    }
    if (this.after != null) {
      object['after'] = this.after;
    }
    return object;
  }

  End.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('endType')) {
      this.endType = map['endType'];
    }
    if (map.containsKey('on')) {
      this.on = map['on'];
    }
    if (map.containsKey('after')) {
      this.after = map['after'];
    }
  }
}

class RequestModel extends DataModel {
  String id;
  String title;
  String description;
  String email;
  String fullName;
  String requestCreatorName;
  String sevaUserId;
  String photoUrl;
  String roomOrTool;
  List<String> acceptors;
  int durationOfRequest;
  int postTimestamp;
  int requestEnd;
  int requestStart;
  int numberOfHours;
  int maxCredits;
  bool accepted;
  String rejectedReason;
  List<TransactionModel> transactions;
  String timebankId;
  int numberOfApprovals;
  List<String> approvedUsers;
  List<String> invitedUsers;
  List<String> categories;
  List<String> oneToManyRequestAttenders;
  GeoFirePoint location;
  String root_timebank_id;
  Color color;
  bool isNotified = false;
  bool isSpeakerCompleted = false;
  String projectId = "";
  String address;
  bool softDelete;
  bool isRecurring;
  List<int> recurringDays;
  int occurenceCount = 1;
  End end;
  String parent_request_id;
  bool autoGenerated = false;
  bool lenderReviewed = false;
  bool borrowerReviewed = false;
  String donationInstructionLink;
  List<String> allowedCalenderUsers;
  List<String> recommendedMemberIdsForRequest = [];
  RequestMode requestMode;
  RequestType requestType;
  CashModel cashModel = new CashModel();
  GoodsDonationDetails goodsDonationDetails = new GoodsDonationDetails();
  String communityId;
  BasicUserDetails selectedInstructor = new BasicUserDetails();
  SelectedSpeakerTimeDetails selectedSpeakerTimeDetails =
      new SelectedSpeakerTimeDetails();
  Map<String, dynamic> skills;
  bool liveMode = true;

  List<String> timebanksPosted;
  bool public;
  bool virtualRequest;
  bool hasBorrowAgreement;
  Map<dynamic, dynamic> participantDetails = {};
  String creatorName = '';
  String borrowAgreementLink;
  bool isFromOfferRequest;
  int minimumCredits;
  List<String> imageUrls = [];
  String communityName;
  DocumentReference speakerInviteNotificationDocRef;

  RequestModel({
    this.id,
    this.title,
    this.description,
    this.durationOfRequest,
    this.email,
    this.fullName,
    this.requestCreatorName,
    this.sevaUserId,
    this.photoUrl,
    this.roomOrTool,
    this.accepted,
    this.postTimestamp,
    this.requestEnd,
    this.requestStart,
    this.acceptors,
    this.color,
    this.transactions,
    this.rejectedReason,
    this.timebankId,
    this.approvedUsers = const [],
    this.invitedUsers,
    this.numberOfApprovals = 1,
    this.location,
    this.root_timebank_id,
    this.projectId,
    this.address,
    this.softDelete,
    this.isRecurring,
    this.recurringDays,
    this.occurenceCount,
    this.end,
    this.parent_request_id,
    this.autoGenerated,
    this.borrowerReviewed,
    this.lenderReviewed,
    this.requestType,
    this.requestMode,
    this.cashModel,
    this.goodsDonationDetails,
    this.donationInstructionLink,
    this.allowedCalenderUsers,
    this.recommendedMemberIdsForRequest,
    this.categories,
    this.selectedInstructor,
    this.selectedSpeakerTimeDetails,
    @required this.communityId,
    this.skills,
    this.public,
    this.virtualRequest,
    this.hasBorrowAgreement,
    this.timebanksPosted,
    this.participantDetails,
    this.creatorName,
    this.borrowAgreementLink,
    this.isFromOfferRequest,
    this.minimumCredits,
    this.liveMode,
    this.imageUrls,
    this.oneToManyRequestAttenders,
    this.communityName,
    this.speakerInviteNotificationDocRef,
  }) {
    log("===========Constructir called $communityId =======");
  }

  RequestModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('donationInstructionLink')) {
      this.donationInstructionLink = map["donationInstructionLink"];
    }
    if (map.containsKey('recommendedMemberIdsForRequest')) {
      List<String> recommendedMembeIds =
          List.castFrom(map['recommendedMemberIdsForRequest']);
      this.recommendedMemberIdsForRequest = recommendedMembeIds;
    } else {
      this.recommendedMemberIdsForRequest = [];
    }
    if (map.containsKey('categories')) {
      List<String> categories = List.castFrom(map['categories']);
      this.categories = categories;
    } else {
      this.categories = [];
    }

    if (map.containsKey('allowedCalenderUsers')) {
      List<String> allowedCalenderUsers =
          List.castFrom(map['allowedCalenderUsers']);
      this.allowedCalenderUsers = allowedCalenderUsers;
    } else {
      this.allowedCalenderUsers = [];
    }

    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }

    if (map.containsKey('softDelete')) {
      this.softDelete = map['softDelete'];
    }

    if (map.containsKey('projectId')) {
      this.projectId = map['projectId'];
    } else {
      this.projectId = "";
    }

    if (map.containsKey('creatorName')) {
      this.creatorName = map['creatorName'];
    } else {
      this.creatorName = "";
    }

    if (map.containsKey('borrowAgreementLink')) {
      this.borrowAgreementLink = map['borrowAgreementLink'];
    } else {
      this.borrowAgreementLink = "";
    }

    if (map.containsKey('requestMode')) {
      if (map['requestMode'] == "PERSONAL_REQUEST") {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      } else if (map['requestMode'] == "TIMEBANK_REQUEST") {
        this.requestMode = RequestMode.TIMEBANK_REQUEST;
      } else {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      }
    } else {
      this.requestMode = RequestMode.PERSONAL_REQUEST;
    }

    if (map.containsKey('requestType')) {
      if (map['requestType'] == "CASH") {
        this.requestType = RequestType.CASH;
      } else if (map['requestType'] == "GOODS") {
        this.requestType = RequestType.GOODS;
      } else if (map['requestType'] == "ONE_TO_MANY_REQUEST") {
        this.requestType = RequestType.ONE_TO_MANY_REQUEST;
      } else if (map['requestType'] == "BORROW") {
        this.requestType = RequestType.BORROW;
      } else {
        this.requestType = RequestType.TIME;
      }
    } else {
      this.requestType = RequestType.TIME;
    }

    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('requestCreatorName')) {
      this.requestCreatorName = map['requestCreatorName'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }
    if (map.containsKey('requestorphotourl')) {
      this.photoUrl = map['requestorphotourl'];
    }
    if (map.containsKey('roomOrTool')) {
      this.roomOrTool = map['roomOrTool'];
    }
    if (map.containsKey('address')) {
      this.address = map['address'];
    }

    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }
    if (map.containsKey('acceptors')) {
      List<String> acceptorList = List.castFrom(map['acceptors']);
      this.acceptors = acceptorList;
    } else {
      this.acceptors = [];
    }
    if (map.containsKey('invitedUsers')) {
      List<String> invitedUsersList = List.castFrom(map['invitedUsers']);
      this.invitedUsers = invitedUsersList;
    } else {
      this.invitedUsers = [];
    }
    if (map.containsKey('durationofrequest')) {
      this.durationOfRequest = map['durationofrequest'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('request_end')) {
      this.requestEnd = map['request_end'];
    }
    if (map.containsKey('request_start')) {
      this.requestStart = map['request_start'];
    }
    if (map.containsKey('accepted')) {
      this.accepted = map['accepted'];
    }
    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }

    if (map.containsKey('isNotified')) {
      this.isNotified = map['isNotified'];
    }

    if (map.containsKey('isSpeakerCompleted')) {
      this.isSpeakerCompleted = map['isSpeakerCompleted'];
    }

    if (map.containsKey('transactions')) {
      List<TransactionModel> transactionList = [];
      List transactionDataList = List.castFrom(map['transactions']);

      transactionList = transactionDataList.map<TransactionModel>((data) {
        Map<String, dynamic> transactionmap = Map.castFrom(data);
        return TransactionModel.fromMap(transactionmap);
      }).toList();

      this.transactions = transactionList;
    }
    if (map.containsKey('rejectedReason')) {
      this.rejectedReason = map['rejectedReason'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('approvedUsers')) {
      List<String> approvedUserList = List.castFrom(map['approvedUsers']);
      this.approvedUsers = approvedUserList;
    }
    if (map.containsKey('numberOfApprovals')) {
      this.numberOfApprovals = map['numberOfApprovals'];
    }

    if (map.containsKey('numberOfHours')) {
      this.numberOfHours = map['numberOfHours'];
    }
    if (map.containsKey('maxCredits')) {
      this.maxCredits = map['maxCredits'];
    }

    if (map.containsKey('location')) {
      this.location = getLocation(map);
    }

    if (map.containsKey('isRecurring')) {
      this.isRecurring = map['isRecurring'];
    }
    if (map.containsKey('recurringDays')) {
      List<int> recurringDaysList = List.castFrom(map['recurringDays']);
      this.recurringDays = recurringDaysList;
    }
    if (map.containsKey('occurenceCount')) {
      this.occurenceCount = map['occurenceCount'];
    }
    if (map.containsKey('end')) {
      this.end = End.fromMap(Map<String, dynamic>.from(map['end']));
    }
    if (map.containsKey('parent_request_id')) {
      this.parent_request_id = map['parent_request_id'];
    }
    if (map.containsKey('autoGenerated')) {
      this.autoGenerated = map['autoGenerated'];
    }

    if (map.containsKey('lenderReviewed')) {
      this.lenderReviewed = map['lenderReviewed'];
    }

    if (map.containsKey('borrowerReviewed')) {
      this.borrowerReviewed = map['borrowerReviewed'];
    }

    if (map.containsKey('goodsDonationDetails')) {
      this.goodsDonationDetails =
          GoodsDonationDetails.fromMap(map['goodsDonationDetails']);
    }

    if (map.containsKey('selectedInstructor')) {
      this.selectedInstructor =
          BasicUserDetails.fromMap(map['selectedInstructor']);
    } else {
      this.selectedInstructor = new BasicUserDetails();
    }

    if (map.containsKey('selectedSpeakerTimeDetails')) {
      this.selectedSpeakerTimeDetails =
          SelectedSpeakerTimeDetails.fromMap(map['selectedSpeakerTimeDetails']);
    } else {
      this.selectedSpeakerTimeDetails = new SelectedSpeakerTimeDetails();
    }

    if (map.containsKey('cashModeDetails')) {
      this.cashModel = CashModel.fromMap(map['cashModeDetails']);
    } else {
      this.cashModel = new CashModel();
    }
    if (map.containsKey('communityName')) {
      this.communityName = map['communityName'];
    }
    if (map.containsKey('speakerInviteNotificationDocRef')) {
      this.speakerInviteNotificationDocRef =
          map['speakerInviteNotificationDocRef'];
    }
    if (map.containsKey('oneToManyRequestAttenders')) {
      List<String> oneToManyRequestAttenders =
          List.castFrom(map['oneToManyRequestAttenders']);
      this.oneToManyRequestAttenders = oneToManyRequestAttenders;
    } else {
      this.oneToManyRequestAttenders = [];
    }

    if (map.containsKey("skills")) {
      this.skills = Map<String, String>.from(map["skills"] ?? {}) ?? {};
    } else {
      this.skills = {};
    }
    if (map.containsKey('public')) {
      this.public = map['public'];
    } else {
      this.public = false;
    }
    if (map.containsKey('virtualRequest')) {
      this.virtualRequest = map['virtualRequest'];
    } else {
      this.virtualRequest = false;
    }
    if (map.containsKey('hasBorrowAgreement')) {
      this.hasBorrowAgreement = map['hasBorrowAgreement'];
    } else {
      this.hasBorrowAgreement = map['hasBorrowAgreement'];
    }
    if (map.containsKey('timebanksPosted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
      this.timebanksPosted = timebanksPosted;
    } else {
      this.timebanksPosted = [];
    }
    if (map.containsKey('participantDetails')) {
      this.participantDetails = Map.castFrom(map['participantDetails']);
      ;
    }
    if (map.containsKey('imageUrls')) {
      List<String> imageUrls = List.castFrom(map['imageUrls']);
      this.imageUrls = imageUrls;
    } else {
      this.imageUrls = [];
    }
    if (map.containsKey('isFromOfferRequest')) {
      this.isFromOfferRequest = map['isFromOfferRequest'];
    } else {
      this.isFromOfferRequest = false;
    }
    if (map.containsKey('minimumCredits')) {
      this.minimumCredits = map['minimumCredits'];
    }
  }

  RequestModel.fromMapElasticSearch(Map<String, dynamic> map) {
    if (map.containsKey('donationInstructionLink')) {
      this.donationInstructionLink = map["donationInstructionLink"];
    }
    if (map.containsKey('allowedCalenderUsers')) {
      List<String> allowedCalenderUsers =
          List.castFrom(map['allowedCalenderUsers']);
      this.allowedCalenderUsers = allowedCalenderUsers;
    } else {
      this.allowedCalenderUsers = [];
    }
    if (map.containsKey('recommendedMemberIdsForRequest')) {
      List<String> recommendedMembeIds =
          List.castFrom(map['recommendedMemberIdsForRequest']);
      this.recommendedMemberIdsForRequest = recommendedMembeIds;
    } else {
      this.recommendedMemberIdsForRequest = [];
    }
    if (map.containsKey('categories')) {
      List<String> categories = List.castFrom(map['categories']);
      this.categories = categories;
    } else {
      this.categories = [];
    }
    if (map.containsKey("skills")) {
      this.skills = Map<String, String>.from(map["skills"] ?? {}) ?? {};
    } else {
      this.skills = {};
    }

    if (map.containsKey('requestMode')) {
      if (map['requestMode'] == "PERSONAL_REQUEST") {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      } else if (map['requestMode'] == "TIMEBANK_REQUEST") {
        this.requestMode = RequestMode.TIMEBANK_REQUEST;
      } else {
        this.requestMode = RequestMode.PERSONAL_REQUEST;
      }
    } else {
      this.requestMode = RequestMode.PERSONAL_REQUEST;
    }
    if (map.containsKey('requestType')) {
      if (map['requestType'] == "CASH") {
        this.requestType = RequestType.CASH;
      } else if (map['requestMode'] == "GOODS") {
        this.requestType = RequestType.GOODS;
      } else if (map['requestType'] == "ONE_TO_MANY_REQUEST") {
        this.requestType = RequestType.ONE_TO_MANY_REQUEST;
      } else if (map['requestType'] == "BORROW") {
        this.requestType = RequestType.BORROW;
      } else {
        this.requestType = RequestType.TIME;
      }
    } else {
      this.requestType = RequestType.TIME;
    }
    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey('softDelete')) {
      this.softDelete = map['softDelete'];
    }

    if (map.containsKey('address')) {
      this.address = map['address'];
    }

    if (map.containsKey('projectId')) {
      this.projectId = map['projectId'];
    } else {
      this.projectId = "";
    }

    if (map.containsKey('creatorName')) {
      this.creatorName = map['creatorName'];
    } else {
      this.creatorName = "";
    }

    if (map.containsKey('borrowAgreementLink')) {
      this.borrowAgreementLink = map['borrowAgreementLink'];
    } else {
      this.borrowAgreementLink = "";
    }

    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('description')) {
      this.description = map['description'];
    }

    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullname')) {
      this.fullName = map['fullname'];
    }
    if (map.containsKey('requestCreatorName')) {
      this.requestCreatorName = map['requestCreatorName'];
    }
    if (map.containsKey('sevauserid')) {
      this.sevaUserId = map['sevauserid'];
    }
    if (map.containsKey('requestorphotourl')) {
      this.photoUrl = map['requestorphotourl'];
    }
    if (map.containsKey('roomOrTool')) {
      this.roomOrTool = map['roomOrTool'];
    }
    if (map.containsKey('acceptors')) {
      List<String> acceptorList = List.castFrom(map['acceptors']);
      this.acceptors = acceptorList;
    }
    if (map.containsKey('invitedUsers')) {
      List<String> invitedUsersList = List.castFrom(map['invitedUsers']);
      this.invitedUsers = invitedUsersList;
    }
    if (map.containsKey('durationofrequest')) {
      this.durationOfRequest = map['durationofrequest'];
    }
    if (map.containsKey('posttimestamp')) {
      this.postTimestamp = map['posttimestamp'];
    }
    if (map.containsKey('request_end')) {
      this.requestEnd = map['request_end'];
    }
    if (map.containsKey('request_start')) {
      this.requestStart = map['request_start'];
    }
    if (map.containsKey('accepted')) {
      this.accepted = map['accepted'];
    }

    if (map.containsKey('numberOfHours')) {
      this.numberOfHours = map['numberOfHours'];
    }

    if (map.containsKey('maxCredits')) {
      this.maxCredits = map['maxCredits'];
    }

    if (map.containsKey('isNotified')) {
      this.isNotified = map['isNotified'];
    }

    if (map.containsKey('isSpeakerCompleted')) {
      this.isSpeakerCompleted = map['isSpeakerCompleted'];
    }

    if (map.containsKey('transactions')) {
      List<TransactionModel> transactionList = [];
      List transactionDataList = List.castFrom(map['transactions']);

      transactionList = transactionDataList.map<TransactionModel>((data) {
        Map<String, dynamic> transactionmap = Map.castFrom(data);
        return TransactionModel.fromMap(transactionmap);
      }).toList();

      this.transactions = transactionList;
    }
    if (map.containsKey('rejectedReason')) {
      this.rejectedReason = map['rejectedReason'];
    }
    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('approvedUsers')) {
      List<String> approvedUserList = List.castFrom(map['approvedUsers']);
      this.approvedUsers = approvedUserList;
    }
    if (map.containsKey('numberOfApprovals')) {
      this.numberOfApprovals = map['numberOfApprovals'];
    }

    if (map.containsKey('location')) {
      this.location = getLocation(map);
    }

    if (map.containsKey('isRecurring')) {
      this.isRecurring = map['isRecurring'];
    }
    if (map.containsKey('recurringDays')) {
      List<int> recurringDaysList = List.castFrom(map['recurringDays']);
      this.recurringDays = recurringDaysList;
    }

    if (map.containsKey('selectedInstructor')) {
      this.selectedInstructor =
          BasicUserDetails.fromMap(map['selectedInstructor']);
    } else {
      this.selectedInstructor = new BasicUserDetails();
    }

    if (map.containsKey('selectedSpeakerTimeDetails')) {
      this.selectedSpeakerTimeDetails =
          SelectedSpeakerTimeDetails.fromMap(map['selectedSpeakerTimeDetails']);
    } else {
      this.selectedSpeakerTimeDetails = new SelectedSpeakerTimeDetails();
    }

    if (map.containsKey('occurenceCount')) {
      this.occurenceCount = map['occurenceCount'];
    }

    if (map.containsKey('end')) {
      this.end = End.fromMap(Map<String, dynamic>.from(map['end']));
    }
    if (map.containsKey('parent_request_id')) {
      this.parent_request_id = map['parent_request_id'];
    }
    if (map.containsKey('autoGenerated')) {
      this.autoGenerated = map['autoGenerated'];
    }
    if (map.containsKey('lenderReviewed')) {
      this.lenderReviewed = map['lenderReviewed'];
    }

    if (map.containsKey('borrowerReviewed')) {
      this.borrowerReviewed = map['borrowerReviewed'];
    }
    if (map.containsKey('cashModeDetails')) {
      this.cashModel = CashModel.fromMap(map['cashModeDetails']);
    } else {
      this.cashModel = CashModel();
    }

    if (map.containsKey('timebanksPosted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
      this.timebanksPosted = timebanksPosted;
    } else {
      this.timebanksPosted = [];
    }

    if (map.containsKey('hasBorrowAgreement')) {
      this.hasBorrowAgreement = map['hasBorrowAgreement'];
      if (map.containsKey('timebanksPosted')) {
        List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
        this.timebanksPosted = timebanksPosted;
      } else {
        this.timebanksPosted = [];
      }
      if (map.containsKey('timebanksPosted')) {
        List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
        this.timebanksPosted = timebanksPosted;
      } else {
        this.timebanksPosted = [];
      }

      if (map.containsKey('public')) {
        this.public = map['public'];
      } else {
        this.public = false;
      }
      if (map.containsKey('virtualRequest')) {
        this.virtualRequest = map['virtualRequest'];
      } else {
        this.virtualRequest = false;
      }
      if (map.containsKey('timebanksPosted')) {
        List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
        this.timebanksPosted = timebanksPosted;
      } else {
        this.timebanksPosted = [];
      }

      if (map.containsKey('participantDetails')) {
        this.participantDetails = Map.castFrom(map['participantDetails']);
      }
      if (map.containsKey('isFromOfferRequest')) {
        this.isFromOfferRequest = map['isFromOfferRequest'];
      } else {
        this.isFromOfferRequest = false;
      }
      if (map.containsKey('minimumCredits')) {
        this.minimumCredits = map['minimumCredits'];
      }
      if (map.containsKey('liveMode')) {
        this.liveMode = map['liveMode'];
      } else {
        this.liveMode = true;
      }
      if (map.containsKey('imageUrls')) {
        List<String> imageUrls = List.castFrom(map['imageUrls']);
        this.imageUrls = imageUrls;
      } else {
        this.imageUrls = [];
      }
    }
    if (map.containsKey('oneToManyRequestAttenders')) {
      List<String> oneToManyRequestAttenders =
          List.castFrom(map['oneToManyRequestAttenders']);
      this.oneToManyRequestAttenders = oneToManyRequestAttenders;
    } else {
      this.oneToManyRequestAttenders = [];
    }
    if (map.containsKey('communityName')) {
      this.communityName = map['communityName'];
    }
    if (map.containsKey('speakerInviteNotificationDocRef')) {
      this.speakerInviteNotificationDocRef =
          map['speakerInviteNotificationDocRef'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (donationInstructionLink != null) {
      object['donationInstructionLink'] = donationInstructionLink;
    }

    if (requestMode != null) {
      switch (requestMode) {
        case RequestMode.PERSONAL_REQUEST:
          object['requestMode'] = "PERSONAL_REQUEST";
          break;

        case RequestMode.TIMEBANK_REQUEST:
          object['requestMode'] = "TIMEBANK_REQUEST";
          break;
      }
    } else {
      object['requestMode'] = "PERSONAL_REQUEST";
    }

    if (requestType != null) {
      switch (requestType) {
        case RequestType.CASH:
          object['requestType'] = "CASH";
          break;

        case RequestType.GOODS:
          object['requestType'] = "GOODS";
          break;

        case RequestType.ONE_TO_MANY_REQUEST:
          object['requestType'] = "ONE_TO_MANY_REQUEST";
          break;

        case RequestType.BORROW:
          object['requestType'] = "BORROW";
          break;

        case RequestType.TIME:
          object['requestType'] = "TIME";
          break;
      }
    } else {
      object['requestType'] = "TIME";
    }

    if (this.projectId != null && this.projectId.isNotEmpty) {
      object['projectId'] = this.projectId;
    } else {
      object['projectId'] = "";
    }

    if (this.creatorName != null && this.creatorName.isNotEmpty) {
      object['creatorName'] = this.creatorName;
    } else {
      object['creatorName'] = "";
    }

    if (this.borrowAgreementLink != null &&
        this.borrowAgreementLink.isNotEmpty) {
      object['borrowAgreementLink'] = this.borrowAgreementLink;
    } else {
      object['borrowAgreementLink'] = "";
    }

    if (this.title != null && this.title.isNotEmpty) {
      object['title'] = this.title;
    }
    if (this.communityName != null && this.communityName.isNotEmpty) {
      object['communityName'] = this.communityName;
    }
    if (this.speakerInviteNotificationDocRef != null) {
      object['speakerInviteNotificationDocRef'] =
          this.speakerInviteNotificationDocRef;
    }
    if (this.softDelete != null) {
      object['softDelete'] = this.softDelete;
    }
    if (this.root_timebank_id != null && this.root_timebank_id.isNotEmpty) {
      object['root_timebank_id'] = this.root_timebank_id;
    }
    if (this.description != null && this.description.isNotEmpty) {
      object['description'] = this.description;
    }

    if (this.email != null && this.email.isNotEmpty) {
      object['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      object['fullname'] = this.fullName;
    }
    if (this.requestCreatorName != null && this.requestCreatorName.isNotEmpty) {
      object['requestCreatorName'] = this.requestCreatorName;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      object['sevauserid'] = this.sevaUserId;
    }
    if (this.photoUrl != null && this.photoUrl.isNotEmpty) {
      object['requestorphotourl'] = this.photoUrl;
    }
    if (this.roomOrTool != null && this.roomOrTool.isNotEmpty) {
      object['roomOrTool'] = this.roomOrTool;
    }

    if (this.acceptors != null) {
      object['acceptors'] = this.acceptors;
    }

    if (this.recommendedMemberIdsForRequest != null) {
      object['recommendedMemberIdsForRequest'] =
          this.recommendedMemberIdsForRequest;
    }
    if (allowedCalenderUsers != null) {
      object['allowedCalenderUsers'] = allowedCalenderUsers;
    }
    if (this.invitedUsers != null) {
      object['invitedUsers'] = this.invitedUsers;
    }
    if (this.durationOfRequest != null) {
      object['durationofrequest'] = this.durationOfRequest;
    }
    if (this.postTimestamp != null) {
      object['posttimestamp'] = this.postTimestamp;
    }
    if (this.requestEnd != null) {
      object['request_end'] = this.requestEnd;
    }
    if (this.requestStart != null) {
      object['request_start'] = this.requestStart;
    }

    if (this.accepted != null) {
      object['accepted'] = this.accepted;
    }

    if (this.communityId != null) {
      object['communityId'] = this.communityId;
    }

    if (this.address != null) {
      object['address'] = this.address;
    }

    if (this.numberOfHours != null) {
      object['numberOfHours'] = this.numberOfHours;
    }

    if (this.maxCredits != null) {
      object['maxCredits'] = this.maxCredits;
    }

    if (this.isNotified != null) {
      object['isNotified'] = this.isNotified;
    }

    if (this.isSpeakerCompleted != null) {
      object['isSpeakerCompleted'] = this.isSpeakerCompleted;
    }

    if (this.transactions != null) {
      List<Map<String, dynamic>> transactionList =
          this.transactions.map<Map<String, dynamic>>((map) {
        return map.toMap();
      }).toList();
      object['transactions'] = transactionList;
    } else {
      object['transactions'] = [];
    }

    if (this.rejectedReason != null && this.rejectedReason.isNotEmpty) {
      object['rejectedReason'] = this.rejectedReason;
    }
    if (this.timebankId != null && this.timebankId.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.approvedUsers != null) {
      object['approvedUsers'] = this.approvedUsers;
    }
    if (this.categories != null) {
      object['categories'] = this.categories;
    }
    if (this.numberOfApprovals != null) {
      object['numberOfApprovals'] = this.numberOfApprovals;
    }
    if (this.location != null) {
      object['location'] =
          this.location.data; //Map<String, dynamic>.from(this.location.data());
    }
    if (this.id != null) {
      object['id'] = this.id;
    }
    if (this.isRecurring != null) {
      object['isRecurring'] = this.isRecurring;
    }
    if (this.recurringDays != null) {
      object['recurringDays'] = this.recurringDays;
    }
    if (this.selectedInstructor != null) {
      object['selectedInstructor'] = this.selectedInstructor.toMap();
    }
    if (this.selectedSpeakerTimeDetails != null) {
      object['selectedSpeakerTimeDetails'] =
          this.selectedSpeakerTimeDetails.toMap();
    }
    if (this.occurenceCount != null) {
      object['occurenceCount'] = this.occurenceCount;
    }
    if (this.end != null) {
      object['end'] = this.end.toMap();
    }
    if (this.parent_request_id != null) {
      object['parent_request_id'] = this.parent_request_id;
    }
    if (this.autoGenerated != null) {
      object['autoGenerated'] = this.autoGenerated;
    }
    if (this.lenderReviewed != null) {
      object['lenderReviewed'] = this.lenderReviewed;
    }
    if (this.borrowerReviewed != null) {
      object['borrowerReviewed'] = this.borrowerReviewed;
    }
    if (this.cashModel != null) {
      object['cashModeDetails'] = this.cashModel.toMap();
    }
    if (this.goodsDonationDetails != null) {
      object['goodsDonationDetails'] = this.goodsDonationDetails.toMap();
    }
    if (this.oneToManyRequestAttenders != null) {
      object['oneToManyRequestAttenders'] = this.oneToManyRequestAttenders;
    }
    if (this.skills != null) {
      object['skills'] = this.skills;
    }
    if (this.public != null) {
      object['public'] = this.public;
    } else {
      object['public'] = false;
    }
    if (this.virtualRequest != null) {
      object['virtualRequest'] = this.virtualRequest;
    } else {
      object['virtualRequest'] = false;
    }
    if (this.hasBorrowAgreement != null) {
      object['hasBorrowAgreement'] = this.hasBorrowAgreement;
    } else {
      object['hasBorrowAgreement'] = false;
    }

    if (this.timebanksPosted != null) {
      object['timebanksPosted'] = this.timebanksPosted;
    }

    if (this.participantDetails != null) {
      object['participantDetails'] =
          Map<dynamic, dynamic>.from(this.participantDetails);
    }
    if (this.isFromOfferRequest != null) {
      object['isFromOfferRequest'] = this.isFromOfferRequest;
    } else {
      object['isFromOfferRequest'] = false;
    }
    if (this.minimumCredits != null) {
      object['minimumCredits'] = this.minimumCredits;
    }
    if (this.liveMode != null) {
      object['liveMode'] = this.liveMode;
    }
    if (this.imageUrls != null) {
      object['imageUrls'] = this.imageUrls;
    } else {
      object['imageUrls'] = [];
    }
    return object;
  }

  @override
  String toString() {
    return 'RequestModel{id: $id, title: $title, description: $description, email: $email, fullName: $fullName, requestCreatorName: $requestCreatorName, sevaUserId: $sevaUserId, photoUrl: $photoUrl, acceptors: $acceptors,oneToManyRequestAttenders: $oneToManyRequestAttenders, durationOfRequest: $durationOfRequest, postTimestamp: $postTimestamp, requestEnd: $requestEnd, requestStart: $requestStart, accepted: $accepted, rejectedReason: $rejectedReason, transactions: $transactions,  categories: $categories, timebankId: $timebankId, numberOfApprovals: $numberOfApprovals, approvedUsers: $approvedUsers, invitedUsers: $invitedUsers,recommendedMemberIdsForRequest: $recommendedMemberIdsForRequest, location: $location, root_timebank_id: $root_timebank_id, color: $color, isNotified: $isNotified, isSpeakerCompleted: $isSpeakerCompleted}';
  }

  RequestModel get flush {
    RequestModel requestModel = this;
    requestModel.id = Utils.getUuid();
    requestModel.acceptors = [];
    requestModel.allowedCalenderUsers = [];
    requestModel.approvedUsers = [];
    requestModel.invitedUsers = [];
    requestModel.transactions = [];
    requestModel.participantDetails = {};
    requestModel.postTimestamp = DateTime.now().millisecondsSinceEpoch;
    switch (this.requestType) {
      case RequestType.TIME:
        break;
      case RequestType.CASH:
        requestModel.cashModel.donors = [];
        break;
      case RequestType.GOODS:
        requestModel.goodsDonationDetails.donors = [];
        break;
      case RequestType.BORROW:
        break;
      case RequestType.ONE_TO_MANY_REQUEST:
        requestModel.oneToManyRequestAttenders = [];
        break;
    }

    return requestModel;
  }
}

class GoodsDonationDetails {
  List<String> donors;
  Map<String, String> requiredGoods;
  String address = '';

  GoodsDonationDetails({this.donors, this.address, this.requiredGoods});
  String toString() {
    return this.donors.toString() + "   " + requiredGoods.toString();
  }

  GoodsDonationDetails.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('donors')) {
      this.donors = List.castFrom(map['donors']);
    }

    if (map.containsKey('address')) {
      this.address = map['address'];
    }

    if (map.containsKey("requiredGoods")) {
      this.requiredGoods =
          Map<String, String>.from(map["requiredGoods"] ?? {}) ?? {};
    }
  }
  Map<String, dynamic> toMap() => {
        "address": address == null ? null : address,
        "donors": donors == null ? [] : List<String>.from(donors.map((x) => x)),
        "requiredGoods": requiredGoods == null ? null : requiredGoods
      };
}

enum RequestMode { PERSONAL_REQUEST, TIMEBANK_REQUEST }
enum RequestType {
  CASH,
  TIME,
  GOODS,
  BORROW,
  ONE_TO_MANY_REQUEST,
  ONE_TO_MANY_OFFER,
}
enum RequestPaymentType {
  ACH,
  ZELLEPAY,
  PAYPAL,
  VENMO,
  SWIFT,
}

enum ContantsSeva { USER_DONATE_TOTIMEBANK }

Map<String, RequestType> requestTypeMapper = {
  "CASH": RequestType.CASH,
  "TIME": RequestType.TIME,
  "GOODS": RequestType.GOODS,
  "BORROW": RequestType.BORROW,
  "ONE_TO_MANY_REQUEST": RequestType.ONE_TO_MANY_REQUEST,
  "BORROW": RequestType.BORROW,
  "ONE_TO_MANY_OFFER": RequestType.ONE_TO_MANY_OFFER,
};
Map<String, RequestPaymentType> requestPaymentTypeMapper = {
  "ACH": RequestPaymentType.ACH,
  "ZELLEPAY": RequestPaymentType.ZELLEPAY,
  "PAYPAL": RequestPaymentType.PAYPAL,
  "VENMO": RequestPaymentType.VENMO,
  "SWIFT": RequestPaymentType.SWIFT,
};
