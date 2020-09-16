import 'package:sevaexchange/models/request_model.dart';

class DonationAssociatedTimebankDetails {
  String timebankTitle;
  String timebankPhotoURL;
  DonationAssociatedTimebankDetails({
    this.timebankPhotoURL,
    this.timebankTitle,
  });

  DonationAssociatedTimebankDetails.fromMap(Map<String, String> map) {
    this.timebankTitle =
        map.containsKey('timebankTitle') ? map['timebankTitle'] : null;

    this.timebankPhotoURL =
        map.containsKey('timebankPhotoURL') ? map['timebankPhotoURL'] : null;
  }

  Map<String, String> toMap() {
    Map<String, String> map = Map();
    map['timebankPhotoURL'] = this.timebankPhotoURL;
    map['timebankTitle'] = this.timebankTitle;
    return map;
  }
}

class DonationModel {
  DonationModel({
    this.communityId,
    this.donorSevaUserId,
    this.donatedTo,
    this.donatedToTimebank,
    this.donationInBetween,
    this.donationType,
    this.id,
    this.requestId,
    this.requestTitle,
    this.timebankId,
    this.timestamp,
    this.cashDetails,
    this.goodsDetails,
    this.donationStatus,
    this.notificationId,
    this.donorDetails,
    this.donationAssociatedTimebankDetails,
    this.lastModifiedBy,
    this.minimumAmount,
  });
  String communityId;
  String donorSevaUserId;
  String donatedTo;
  bool donatedToTimebank;
  List<String> donationInBetween;
  RequestType donationType;
  String id;
  String requestId;
  String requestTitle;
  String timebankId;
  String notificationId;
  int timestamp;
  int minimumAmount;
  DonationStatus donationStatus;
  CashDetails cashDetails;
  GoodsDetails goodsDetails;
  DonorDetails donorDetails;
  DonationAssociatedTimebankDetails donationAssociatedTimebankDetails;
  String lastModifiedBy;

  factory DonationModel.fromMap(Map<String, dynamic> json) => DonationModel(
        communityId: json["communityId"] == null ? null : json["communityId"],
        notificationId:
            json["notificationId"] == null ? null : json["notificationId"],
        donorSevaUserId:
            json["donorSevaUserId"] == null ? null : json["donorSevaUserId"],
        donatedTo: json["donatedTo"] == null ? null : json["donatedTo"],
        donatedToTimebank: json["donatedToTimebank"] == null
            ? null
            : json["donatedToTimebank"],
        donationType: json["donationType"] == null
            ? null
            : json["donationType"] == "CASH"
                ? RequestType.CASH
                : json["donationType"] == "GOODS"
                    ? RequestType.GOODS
                    : RequestType.TIME,
        id: json["id"] == null ? null : json["id"],
        requestId: json["requestId"] == null ? null : json["requestId"],
        requestTitle:
            json["requestTitle"] == null ? null : json["requestTitle"],
        timebankId: json["timebankId"] == null ? null : json["timebankId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        minimumAmount:
            json["minimumAmount"] == null ? null : json["minimumAmount"],
        donationStatus: json["donationStatus"] == null
            ? null
            : _donationStatusMapper[json["donationStatus"]],
        cashDetails: json['cashDetails'] == null
            ? null
            : CashDetails.fromMap(
                Map<String, dynamic>.from(
                  json['cashDetails'],
                ),
              ),
        goodsDetails: json['goodsDetails'] == null
            ? null
            : GoodsDetails.fromMap(
                Map<String, dynamic>.from(json['goodsDetails'])),
        donorDetails: json['donorDetails'] == null
            ? null
            : DonorDetails.fromMap(
                Map<String, dynamic>.from(
                  json['donorDetails'],
                ),
              ),
        donationAssociatedTimebankDetails:
            json.containsKey('donationAssociatedTimebankDetails')
                ? DonationAssociatedTimebankDetails.fromMap(
                    Map<String, String>.from(
                        json['donationAssociatedTimebankDetails']),
                  )
                : null,
        lastModifiedBy: json['lastModifiedBy'],
      );

  Map<String, dynamic> toMap() => {
        "communityId": communityId == null ? null : communityId,
        "notificationId": notificationId == null ? null : notificationId,
        "donorSevaUserId": donorSevaUserId == null ? null : donorSevaUserId,
        "donatedTo": donatedTo == null ? null : donatedTo,
        "donatedToTimebank":
            donatedToTimebank == null ? null : donatedToTimebank,
        "donationInBetween": [donatedTo, donorSevaUserId],
        "donationType": donationType == null
            ? null
            : donationType == RequestType.CASH
                ? 'CASH'
                : donationType == RequestType.GOODS ? 'GOODS' : 'TIME',
        "id": id == null ? null : id,
        "requestId": requestId == null ? null : requestId,
        "requestTitle": requestTitle == null ? null : requestTitle,
        "timebankId": timebankId == null ? null : timebankId,
        "minimumAmount": minimumAmount == null ? null : minimumAmount,
        "donationStatus": donationStatus == null
            ? null
            : donationStatus.toString().split('.')[1],
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "cashDetails": cashDetails == null ? null : cashDetails.toMap(),
        "goodsDetails": goodsDetails == null ? null : goodsDetails.toMap(),
        "donorDetails": donorDetails == null ? null : donorDetails.toMap(),
        'donationAssociatedTimebankDetails':
            donationAssociatedTimebankDetails.toMap(),
        "changeHistory": lastModifiedBy,
      };

  @override
  String toString() {
    return 'DonationModel{communityId: $communityId, donorSevaUserId: $donorSevaUserId,minimumAmount: $minimumAmount, donatedTo: $donatedTo, donatedToTimebank: $donatedToTimebank, donationInBetween: $donationInBetween, donationType: $donationType, id: $id, requestId: $requestId, requestTitle: $requestTitle, timebankId: $timebankId, notificationId: $notificationId, timestamp: $timestamp, donationStatus: $donationStatus, cashDetails: $cashDetails, goodsDetails: $goodsDetails, donorDetails: $donorDetails}';
  }
}

class CashDetails {
  CashDetails({
    this.pledgedAmount,
  });

  int pledgedAmount;

  factory CashDetails.fromMap(Map<String, dynamic> json) => CashDetails(
        pledgedAmount:
            json["pledgedAmount"] == null ? null : json["pledgedAmount"],
      );

  Map<String, dynamic> toMap() => {
        "pledgedAmount": pledgedAmount == null ? null : pledgedAmount,
      };
}

class GoodsDetails {
  GoodsDetails({this.toAddress, this.comments, this.donatedGoods, this.requiredGoods});
  String toAddress;
  String comments;
  Map<String, String> donatedGoods;
  Map<String, String> requiredGoods;

  factory GoodsDetails.fromMap(Map<dynamic, dynamic> json) {
    return GoodsDetails(
      toAddress: json['toAddress'] == null ? null: json["toAddress"],
      comments: json["comments"] == null ? null : json["comments"],
      donatedGoods: json.containsKey('donatedGoods')
          ? Map<String, String>.from(json["donatedGoods"] ?? {})
          : {},
      requiredGoods: json.containsKey('requiredGoods')
          ? Map<String, String>.from(json["requiredGoods"] ?? {})
          : {},
    );
  }

  Map<dynamic, dynamic> toMap() => {
        "toAddress": toAddress == null? null: toAddress,
        "comments": comments == null ? null : comments,
        "donatedGoods": donatedGoods == null ? null : donatedGoods,
        "requiredGoods": requiredGoods == null ? null : requiredGoods,
      };
}

class DonorDetails {
  DonorDetails({
    this.name,
    this.photoUrl,
    this.email,
    this.bio,
  });

  String name;
  String photoUrl;
  String email;
  String bio;

  factory DonorDetails.fromMap(Map<String, dynamic> json) => DonorDetails(
        name: json["name"],
        photoUrl: json["photoUrl"],
        email: json["email"],
        bio: json["bio"],
      );

  Map<String, dynamic> toMap() => {
        "name": name,
        "photoUrl": photoUrl,
        "email": email,
        "bio": bio,
      };
}

enum DonationStatus {
  REQUESTED,
  PLEDGED,
  ACKNOWLEDGED,
  MODIFIED,
  APPROVED_BY_DONOR,
  APPROVED_BY_CREATOR,
}

Map<String, DonationStatus> _donationStatusMapper = {
  "REQUESTED": DonationStatus.REQUESTED,
  "PLEDGED": DonationStatus.PLEDGED,
  "ACKNOWLEDGED": DonationStatus.ACKNOWLEDGED,
  "MODIFIED": DonationStatus.MODIFIED,
  "APPROVED_BY_DONOR": DonationStatus.APPROVED_BY_DONOR,
  "APPROVED_BY_CREATOR": DonationStatus.APPROVED_BY_CREATOR,
};
