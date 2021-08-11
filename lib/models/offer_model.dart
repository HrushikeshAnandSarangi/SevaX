import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_offer_details.dart';
import 'package:sevaexchange/utils/extensions.dart';
import 'package:sevaexchange/utils/helpers/location_helper.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

import 'models.dart';

enum OfferType { INDIVIDUAL_OFFER, GROUP_OFFER }

extension OfferTypeExtension on OfferType {
  String readbable(RequestType requestType, BuildContext context) {
    if (this == OfferType.GROUP_OFFER)
      return S.of(context).one_to_many.sentenceCase();
    else if (this == OfferType.INDIVIDUAL_OFFER)
      switch (requestType) {
        case RequestType.CASH:
          return S.of(context).cash;
        case RequestType.GOODS:
          return S.of(context).goods;
        case RequestType.TIME:
          return S.of(context).time;
        case RequestType.LENDING_OFFER:
          return L.of(context).lending;
        default:
          return 'Individual'; //Label to be created
      }
    else
      return 'Individual'; //Label to be created
  }
}

class GroupOfferDataModel {
  String classTitle;
  String classDescription;
  double creditsApproved;
  int creditStatus;
  int endDate;
  int numberOfClassHours;
  int numberOfPreperationHours;
  List<String> signedUpMembers;
  int startDate;
  int sizeOfClass;

  int isReviewed;
  int membersNotified;
  int completedRefund;
  bool hostNotified; //let it be bool
  bool isCanceled;

  GroupOfferDataModel();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.classTitle != null) map['classTitle'] = this.classTitle;

    if (this.startDate != null) map['startDate'] = this.startDate;

    if (this.endDate != null) map['endDate'] = this.endDate;

    if (this.numberOfPreperationHours != null)
      map['numberOfPreperationHours'] = this.numberOfPreperationHours;

    if (this.numberOfClassHours != null)
      map['numberOfClassHours'] = this.numberOfClassHours;

    if (this.sizeOfClass != null) map['sizeOfClass'] = this.sizeOfClass;

    if (this.classDescription != null)
      map['classDescription'] = this.classDescription;

    map['signedUpMembers'] = this.signedUpMembers ?? [];
    map['creditsApproved'] = this.creditsApproved ?? 0;
    map['creditStatus'] = this.creditStatus ?? 0;
    map['isReviewed'] = this.isReviewed ?? 0;
    map['membersNotified'] = this.membersNotified ?? 0;
    map['completedRefund'] = this.completedRefund ?? 0;
    map['hostNotified'] = this.hostNotified ?? false;
    map['isCanceled'] = this.isCanceled ?? false;

    return map;
  }

  @override
  GroupOfferDataModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('classTitle')) {
      this.classTitle = map['classTitle'];
    }

    if (map.containsKey('startDate')) {
      this.startDate = map['startDate'];
    }

    if (map.containsKey('endDate')) {
      this.endDate = map['endDate'];
    }

    if (map.containsKey('sizeOfClass')) {
      this.sizeOfClass = map['sizeOfClass'];
    }

    if (map.containsKey('numberOfPreperationHours')) {
      this.numberOfPreperationHours = map['numberOfPreperationHours'];
    }

    if (map.containsKey('numberOfClassHours')) {
      this.numberOfClassHours = map['numberOfClassHours'];
    }

    if (map.containsKey('classDescription')) {
      this.classDescription = map['classDescription'];
    }
    if (map.containsKey('creditsApproved')) {
      this.creditsApproved = map['creditsApproved'].toDouble();
    }
    if (map.containsKey('creditStatus')) {
      this.creditStatus = map['creditStatus'];
    }
    this.isReviewed = map['isReviewed'] ?? 0;
    this.membersNotified = map['membersNotified'] ?? 0;
    this.completedRefund = map['completedRefund'] ?? 0;
    this.hostNotified = map['hostNotified'] ?? false;
    this.isCanceled = map['isCanceled'] ?? false;

    if (map.containsKey('signedUpMembers')) {
      List<String> signedUpMembers = List.castFrom(map['signedUpMembers']);
      this.signedUpMembers = signedUpMembers;
    } else {
      this.signedUpMembers = [];
    }
  }

  @override
  String toString() {
    // TODO: implement toString
    return "classTitle:$classTitle + classDescription:$classDescription + startDate:$startDate + endDate:$endDate + numberOfClassHours:$numberOfClassHours + numberOfPreperationHours:$numberOfPreperationHours";
  }
}

class IndividualOfferDataModel extends DataModel {
  String description;
  List<String> offerAcceptors;
  List<String> offerInvites;
  String schedule;
  String title;
  int minimumCredits;
  String timeOfferType;
  bool isAccepted;

  IndividualOfferDataModel();

  @override
  IndividualOfferDataModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('timeOfferType')) {
      this.timeOfferType = map['timeOfferType'];
    }
    if (map.containsKey('title')) {
      this.title = map['title'];
    }
    if (map.containsKey('isAccepted')) {
      this.isAccepted = map['isAccepted'];
      logger.i("Logger from map if");
    } else {
      logger.i("Logger from map " + map.toString());
      this.isAccepted = false;
    }

    if (map.containsKey('description')) {
      this.description = map['description'];
    }
    if (map.containsKey('schedule')) {
      this.schedule = map['schedule'];
    }

    if (map.containsKey("offerAcceptors")) {
      List<String> offerAcceptors = List.castFrom(map['offerAcceptors']);
      this.offerAcceptors = offerAcceptors;
    } else {
      this.offerAcceptors = [];
    }

    if (map.containsKey("offerInvites")) {
      List<String> offerInvites = List.castFrom(map['offerInvites']);
      this.offerInvites = offerInvites;
    } else {
      this.offerInvites = [];
    }

    if (map.containsKey('minimumCredits')) {
      this.minimumCredits = map['minimumCredits'];
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (title != null) {
      map['title'] = title;
    }

    if (description != null) {
      map['description'] = description;
    }
    if (timeOfferType != null) {
      map['timeOfferType'] = timeOfferType;
    }

    if (schedule != null) {
      map['schedule'] = schedule;
    }

    if (offerAcceptors == null) {
      map['offerAcceptors'] = [];
    }

    if (offerInvites == null) {
      map['offerInvites'] = [];
    }

    if (this.minimumCredits != null) {
      map['minimumCredits'] = this.minimumCredits;
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Title : $title,  Description : $description, Schedule  : $schedule";
  }
}

class OfferModel extends DataModel {
  bool acceptedOffer = false;
  String associatedRequest;
  String communityId;
  Color color;
  String email;
  String fullName;
  String id;
  GeoFirePoint location;
  OfferType offerType;
  String photoUrlImage;
  String root_timebank_id;
  String selectedAdrress;
  String sevaUserId;
  String timebankId;
  int timestamp;
  bool softDelete;
  bool autoGenerated = false;
  bool isRecurring = false;
  List<int> recurringDays;
  int occurenceCount;
  End end;
  String parent_offer_id;
  RequestType type;
  GoodsDonationDetails goodsDonationDetails;
  CashModel cashModel;
  GroupOfferDataModel groupOfferDataModel;
  IndividualOfferDataModel individualOfferDataModel;
  List<String> allowedCalenderUsers;
  bool creatorAllowedCalender = false;
  bool liveMode = true;
  Coordinates currentUserLocation; //to be used locally
  bool public;
  List<String> timebanksPosted;
  bool virtual;
  Map<String, dynamic> participantDetails = {};

  String communityName;
  LendingOfferDetailsModel lendingOfferDetailsModel;

  OfferModel({
    this.isRecurring,
    this.recurringDays,
    this.occurenceCount,
    this.end,
    this.parent_offer_id,
    this.autoGenerated,
    this.id,
    this.email,
    this.fullName,
    this.sevaUserId,
    this.associatedRequest,
    this.color,
    this.timestamp,
    this.timebankId,
    this.location,
    this.offerType,
    this.groupOfferDataModel,
    this.individualOfferDataModel,
    this.selectedAdrress,
    this.communityId,
    this.softDelete,
    this.type,
    this.cashModel,
    this.goodsDonationDetails,
    this.creatorAllowedCalender,
    this.allowedCalenderUsers,
    this.public,
    this.timebanksPosted,
    this.virtual,
    this.participantDetails,
    this.photoUrlImage,
    this.liveMode,
    this.communityName,
    this.lendingOfferDetailsModel,
  }) {
    this.root_timebank_id = FlavorConfig.values.timebankId;
  }

  @override
  String toString() {
    return 'OfferModel{acceptedOffer: $acceptedOffer, associatedRequest: $associatedRequest, communityId: $communityId, color: $color, email: $email, fullName: $fullName, id: $id, location: $location, offerType: $offerType, photoUrlImage: $photoUrlImage, root_timebank_id: $root_timebank_id, selectedAdrress: $selectedAdrress, sevaUserId: $sevaUserId, timebankId: $timebankId, timestamp: $timestamp, softDelete: $softDelete, autoGenerated: $autoGenerated, isRecurring: $isRecurring, recurringDays: $recurringDays, occurenceCount: $occurenceCount, end: $end, parent_offer_id: $parent_offer_id, type: $type, goodsDonationDetails: $goodsDonationDetails, cashModel: $cashModel,lendingOfferDetailsModel: $lendingOfferDetailsModel, groupOfferDataModel: $groupOfferDataModel, individualOfferDataModel: $individualOfferDataModel, allowedCalenderUsers: $allowedCalenderUsers, creatorAllowedCalender: $creatorAllowedCalender, currentUserLocation: $currentUserLocation, public: $public}';
  }

  OfferModel.fromMapElasticSearch(Map<String, dynamic> map) {
    if (map.containsKey('participantDetails')) {
      this.participantDetails = Map.castFrom(map['participantDetails']);
    }

    if (map.containsKey('timebanksPosted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
      this.timebanksPosted = timebanksPosted;
    } else {
      this.timebanksPosted = [];
    }

    if (map.containsKey('virtual')) {
      this.virtual = map['virtual'];
    }

    if (map.containsKey('requestType')) {
      if (map['requestType'] == "CASH") {
        this.type = RequestType.CASH;
      } else if (map['requestType'] == "GOODS") {
        this.type = RequestType.GOODS;
      } else if (map['requestType'] == "LENDING_OFFER") {
        this.type = RequestType.LENDING_OFFER;
      } else if (map['requestType'] == "ONE_TO_MANY_OFFER") {
        this.type = RequestType.ONE_TO_MANY_OFFER;
      } else {
        this.type = RequestType.TIME;
      }
    } else {
      this.type = RequestType.TIME;
    }
    if (map.containsKey('isRecurring')) {
      this.isRecurring = map['isRecurring'];
    }
    if (map.containsKey('allowedCalenderUsers')) {
      List<String> allowedCalenderUsers =
          List.castFrom(map['allowedCalenderUsers']);
      this.allowedCalenderUsers = allowedCalenderUsers;
    } else {
      this.allowedCalenderUsers = [];
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
    if (map.containsKey('parent_offer_id')) {
      this.parent_offer_id = map['parent_offer_id'];
    }
    if (map.containsKey('autoGenerated')) {
      this.autoGenerated = map['autoGenerated'];
    }
    if (map.containsKey('creatorAllowedCalender')) {
      this.creatorAllowedCalender = map['creatorAllowedCalender'];
    }
    if (map.containsKey('offerType')) {
      this.offerType = offerTypeMapper[map['offerType']];
    }
    if (map.containsKey('softDelete')) {
      this.softDelete = map['softDelete'];
    }

    if (map.containsKey('id')) {
      this.id = map['id'];
    }

    if (map.containsKey("selectedAdrress")) {
      this.selectedAdrress = map['selectedAdrress'];
    }

    if (map.containsKey("offerAccepted")) {
      this.acceptedOffer = map['offerAccepted'];
    }

    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }
    if (map.containsKey('associatedRequest')) {
      this.associatedRequest = map['associatedRequest'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }
    location = getLocation(map);

    if (map.containsKey("individualOfferDataModel"))
      this.individualOfferDataModel =
          IndividualOfferDataModel.fromMap(map['individualOfferDataModel']);
    else
      this.individualOfferDataModel = null;

    if (map.containsKey("groupOfferDataModel"))
      this.groupOfferDataModel =
          GroupOfferDataModel.fromMap(map['groupOfferDataModel']);
    else
      this.groupOfferDataModel = null;

    if (map.containsKey('goodsDonationDetails')) {
      this.goodsDonationDetails =
          GoodsDonationDetails.fromMap(map['goodsDonationDetails']);
    }

    if (map.containsKey('cashModeDetails')) {
      this.cashModel = CashModel.fromMap(map['cashModeDetails']);
    } else {
      this.cashModel = new CashModel();
    }

    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }

    if (map.containsKey('public')) {
      this.public = map['public'];
    } else {
      this.public = false;
    }
    if (map.containsKey('communityName')) {
      this.communityName = map['communityName'];
    }
    if (map.containsKey('photoUrlImage')) {
      this.photoUrlImage = map['photoUrlImage'];
    }
    if (map.containsKey('lendingOfferDetailsModel')) {
      this.lendingOfferDetailsModel =
          LendingOfferDetailsModel.fromMap(map['lendingOfferDetailsModel']);
    } else {
      this.lendingOfferDetailsModel = new LendingOfferDetailsModel();
    }
  }

  OfferModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('participantDetails')) {
      this.participantDetails = Map.castFrom(map['participantDetails']);
    }

    if (map.containsKey('timebanksPosted')) {
      List<String> timebanksPosted = List.castFrom(map['timebanksPosted']);
      this.timebanksPosted = timebanksPosted;
    } else {
      this.timebanksPosted = [];
    }
    if (map.containsKey('virtual')) {
      this.virtual = map['virtual'];
    }

    if (map.containsKey('requestType')) {
      if (map['requestType'] == "CASH") {
        this.type = RequestType.CASH;
      } else if (map['requestType'] == "GOODS") {
        this.type = RequestType.GOODS;
      } else if (map['requestType'] == "LENDING_OFFER") {
        this.type = RequestType.LENDING_OFFER;
      } else if (map['requestType'] == "ONE_TO_MANY_OFFER") {
        this.type = RequestType.ONE_TO_MANY_OFFER;
      } else {
        this.type = RequestType.TIME;
      }
    } else {
      this.type = RequestType.TIME;
    }
    if (map.containsKey('offerType')) {
      if (map['offerType'] == describeOfferType(OfferType.GROUP_OFFER)) {
        this.offerType = OfferType.GROUP_OFFER;
      } else {
        this.offerType = OfferType.INDIVIDUAL_OFFER;
      }
    }
    if (map.containsKey('isRecurring')) {
      this.isRecurring = map['isRecurring'];
    }

    if (map.containsKey('recurringDays')) {
      List<int> recurringDaysList = List.castFrom(map['recurringDays']);
      this.recurringDays = recurringDaysList;
    }

    if (map.containsKey('allowedCalenderUsers')) {
      List<String> allowedCalenderUsers =
          List.castFrom(map['allowedCalenderUsers']);
      this.allowedCalenderUsers = allowedCalenderUsers;
    } else {
      this.allowedCalenderUsers = [];
    }
    if (map.containsKey('occurenceCount')) {
      this.occurenceCount = map['occurenceCount'];
    }
    if (map.containsKey('end')) {
      this.end = End.fromMap(Map<String, dynamic>.from(map['end']));
    }
    if (map.containsKey('parent_offer_id')) {
      this.parent_offer_id = map['parent_offer_id'];
    }
    if (map.containsKey('autoGenerated')) {
      this.autoGenerated = map['autoGenerated'];
    }

    if (map.containsKey('creatorAllowedCalender')) {
      this.creatorAllowedCalender = map['creatorAllowedCalender'];
    }
    if (map.containsKey('id')) {
      this.id = map['id'];
    }
    if (map.containsKey('softDelete')) {
      this.softDelete = map['softDelete'];
    }

    if (map.containsKey("selectedAdrress")) {
      this.selectedAdrress = map['selectedAdrress'];
    }

    if (map.containsKey('email')) {
      this.email = map['email'];
    }
    if (map.containsKey('fullName')) {
      this.fullName = map['fullName'];
    }
    if (map.containsKey('sevaUserId')) {
      this.sevaUserId = map['sevaUserId'];
    }

    if (map.containsKey('associatedRequest')) {
      this.associatedRequest = map['associatedRequest'];
    }

    if (map.containsKey('timestamp')) {
      this.timestamp = map['timestamp'];
    }

    if (map.containsKey('timebankId')) {
      this.timebankId = map['timebankId'];
    }
    if (map.containsKey('communityId')) {
      this.communityId = map['communityId'];
    }

    location = getLocation(map);

    if (map.containsKey("individualOfferDataModel"))
      this.individualOfferDataModel =
          IndividualOfferDataModel.fromMap(map['individualOfferDataModel']);
    else
      this.individualOfferDataModel = null;

    if (map.containsKey("groupOfferDataModel"))
      this.groupOfferDataModel =
          GroupOfferDataModel.fromMap(map['groupOfferDataModel']);
    else
      this.groupOfferDataModel = null;

    if (map.containsKey('goodsDonationDetails')) {
      this.goodsDonationDetails =
          GoodsDonationDetails.fromMap(map['goodsDonationDetails']);
    }

    if (map.containsKey('cashModeDetails')) {
      this.cashModel = CashModel.fromMap(map['cashModeDetails']);
    } else {
      this.cashModel = new CashModel();
    }
    if (map.containsKey('communityName')) {
      this.communityName = map['communityName'];
    }
    if (map.containsKey('liveMode')) {
      this.liveMode = map['liveMode'];
    } else {
      this.liveMode = true;
    }
    if (map.containsKey('public')) {
      this.public = map['public'];
    } else {
      this.public = false;
    }
    if (map.containsKey('photoUrlImage')) {
      this.photoUrlImage = map['photoUrlImage'];
    }
    if (map.containsKey('lendingOfferDetailsModel')) {
      this.lendingOfferDetailsModel =
          LendingOfferDetailsModel.fromMap(map['lendingOfferDetailsModel']);
    } else {
      this.lendingOfferDetailsModel = new LendingOfferDetailsModel();
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    if (this.participantDetails != null) {
      map['participantDetails'] =
          Map<String, dynamic>.from(this.participantDetails);
    }

    if (this.timebanksPosted != null) {
      map['timebanksPosted'] = this.timebanksPosted;
    }

    if (this.virtual != null) {
      map['virtual'] = this.virtual;
    } else {
      map['virtual'] = false;
    }
    map['groupOfferDataModel'] = this.groupOfferDataModel.toMap() ?? null;

    map['individualOfferDataModel'] =
        this.individualOfferDataModel.toMap() ?? null;

    if (this.offerType != null) {
      map['offerType'] = describeOfferType(this.offerType);
    }
    if (this.softDelete != null) {
      map['softDelete'] = this.softDelete;
    }

    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }

    if (this.selectedAdrress != null && this.selectedAdrress.isNotEmpty) {
      map['selectedAdrress'] = this.selectedAdrress;
    }

    if (this.root_timebank_id != null && this.root_timebank_id.isNotEmpty) {
      map['root_timebank_id'] = this.root_timebank_id;
    }

    if (this.email != null && this.email.isNotEmpty) {
      map['email'] = this.email;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      map['fullName'] = this.fullName;
    }
    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      map['sevaUserId'] = this.sevaUserId;
    }
    if (this.associatedRequest != null && this.associatedRequest.isNotEmpty) {
      map['assossiatedRequest'] = this.associatedRequest;
    } else {
      map['assossiatedRequest'] = null;
    }

    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }

    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }
    if (this.communityId != null) {
      map['communityId'] = this.communityId;
    }
    if (this.location != null) {
      map['location'] = this.location.data;
    }
    if (this.isRecurring != null) {
      map['isRecurring'] = this.isRecurring;
    }

    if (this.recurringDays != null) {
      map['recurringDays'] = this.recurringDays;
    }
    if (this.occurenceCount != null) {
      map['occurenceCount'] = this.occurenceCount;
    }
    if (this.end != null) {
      map['end'] = this.end.toMap();
    }
    if (this.parent_offer_id != null) {
      map['parent_offer_id'] = this.parent_offer_id;
    }
    if (this.autoGenerated != null) {
      map['autoGenerated'] = this.autoGenerated;
    }

    if (this.creatorAllowedCalender != null) {
      map['creatorAllowedCalender'] = this.creatorAllowedCalender;
    }
    if (this.allowedCalenderUsers != null) {
      map['allowedCalenderUsers'] = this.allowedCalenderUsers;
    }

    if (this.cashModel != null) {
      map['cashModeDetails'] = this.cashModel.toMap();
    }
    if (this.goodsDonationDetails != null) {
      map['goodsDonationDetails'] = this.goodsDonationDetails.toMap();
    }
    if (type != null) {
      switch (type) {
        case RequestType.CASH:
          map['requestType'] = "CASH";
          break;

        case RequestType.GOODS:
          map['requestType'] = "GOODS";
          break;

        case RequestType.TIME:
          map['requestType'] = "TIME";
          break;

        case RequestType.LENDING_OFFER:
          map['requestType'] = "LENDING_OFFER";
          break;
      }
    } else {
      map['requestType'] = "TIME";
    }
    if (this.public != null) {
      map['public'] = this.public;
    } else {
      map['public'] = false;
    }
    if (this.photoUrlImage != null) {
      map['photoUrlImage'] = this.photoUrlImage;
    }

    if (this.liveMode != null) {
      map['liveMode'] = this.liveMode;
    }
    if (this.communityName != null && this.communityName.isNotEmpty) {
      map['communityName'] = this.communityName;
    }
    if (this.lendingOfferDetailsModel != null) {
      map['lendingOfferDetailsModel'] = this.lendingOfferDetailsModel.toMap();
    }
    return map;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};

    if (this.timebanksPosted != null) {
      map['timebanksPosted'] = this.timebanksPosted;
    }
    if (this.id != null && this.id.isNotEmpty) {
      map['id'] = this.id;
    }
    // if (this.title != null && this.title.isNotEmpty) {
    //   map['title'] = this.title;
    // }
    // if (this.description != null && this.description.isNotEmpty) {
    //   map['description'] = this.description;
    // }
    if (this.email != null && this.email.isNotEmpty) {
      map['email'] = this.email;
    }
    if (this.softDelete != null) {
      map['softDelete'] = this.softDelete;
    }
    if (this.fullName != null && this.fullName.isNotEmpty) {
      map['fullName'] = this.fullName;
    }
    if (this.photoUrlImage != null && this.photoUrlImage.isNotEmpty) {
      map['photoUrlImage'] = this.photoUrlImage;
    }

    if (this.offerType != null) {
      map['offerType'] = this.offerType.toString();
    }

    if (this.sevaUserId != null && this.sevaUserId.isNotEmpty) {
      map['sevaUserId'] = this.sevaUserId;
    }
    if (this.associatedRequest != null && this.associatedRequest.isNotEmpty) {
      map['assossiatedRequest'] = this.associatedRequest;
    } else {
      map['assossiatedRequest'] = null;
    }
    // if (this.schedule != null && this.schedule.isNotEmpty) {
    //   map['schedule'] = this.schedule;
    // }
    if (this.timestamp != null) {
      map['timestamp'] = this.timestamp;
    }
    if (this.timebankId != null) {
      map['timebankId'] = this.timebankId;
    }
    if (this.location != null) {
      map['location'] = this.location.data;
    }
    if (this.public != null) {
      map['public'] = this.public;
    }
    if (this.communityName != null && this.communityName.isNotEmpty) {
      map['communityName'] = this.communityName;
    }
    if (this.lendingOfferDetailsModel != null) {
      map['lendingOfferDetailsModel'] = this.lendingOfferDetailsModel.toMap();
    }
    return map;
  }

  String describeOfferType(OfferType offerType) {
    switch (offerType) {
      case OfferType.GROUP_OFFER:
        return "GROUP_OFFER";
      case OfferType.INDIVIDUAL_OFFER:
        return "INDIVIDUAL_OFFER";
    }
  }
}

Map<String, OfferType> offerTypeMapper = {
  "INDIVIDUAL_OFFER": OfferType.INDIVIDUAL_OFFER,
  "GROUP_OFFER": OfferType.GROUP_OFFER,
};
