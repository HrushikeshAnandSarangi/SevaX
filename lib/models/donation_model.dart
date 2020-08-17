import 'package:sevaexchange/models/request_model.dart';

class DonationModel {
  DonationModel(
      {this.communityId,
      this.donorSevaUserId,
      this.donatedTo,
      this.donatedToTimebank,
      this.donationInBetween,
      this.donationType,
      this.id,
      this.requestId,
      this.timebankId,
      this.timestamp,
      this.cashDetails,
      this.goodsDetails,
      this.donationStatus,
      this.notificationId,
      this.donorDetails});

  String communityId;
  String donorSevaUserId;
  String donatedTo;
  bool donatedToTimebank;
  List<String> donationInBetween;
  RequestType donationType;
  String id;
  String requestId;
  String timebankId;
  String notificationId;
  int timestamp;
  bool donationStatus;
  CashDetails cashDetails;
  GoodsDetails goodsDetails;
  DonorDetails donorDetails;
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
        donationInBetween: json["donationInBetween"] == null
            ? null
            : List<String>.from(json["donationInBetween"].map((x) => x)),
        donationType: json["donationType"] == null
            ? null
            : json["donationType"] == "CASH"
                ? RequestType.CASH
                : json["donationType"] == "GOODS"
                    ? RequestType.GOODS
                    : RequestType.TIME,
        id: json["id"] == null ? null : json["id"],
        requestId: json["requestId"] == null ? null : json["requestId"],
        timebankId: json["timebankId"] == null ? null : json["timebankId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        donationStatus:
            json["donationStatus"] == null ? null : json["donationStatus"],
        cashDetails: json['cashDetails'] == null
            ? null
            : CashDetails.fromMap(
                Map<String, dynamic>.from(
                  json['cashDetails'],
                ),
              ),
        goodsDetails: json['goodsDetails'] == null
            ? null
            : GoodsDetails.fromMap(json['goodsDetails']),
        donorDetails: json['donorDetails'] == null
            ? null
            : DonorDetails.fromMap(
                Map<String, dynamic>.from(
                  json['donorDetails'],
                ),
              ),
      );

  Map<String, dynamic> toMap() => {
        "communityId": communityId == null ? null : communityId,
        "notificationId": notificationId == null ? null : notificationId,
        "donorSevaUserId": donorSevaUserId == null ? null : donorSevaUserId,
        "donatedTo": donatedTo == null ? null : donatedTo,
        "donatedToTimebank":
            donatedToTimebank == null ? null : donatedToTimebank,
        "donationInBetween": donationInBetween == null
            ? []
            : List<dynamic>.from(donationInBetween.map((x) => x)),
        "donationType": donationType == null
            ? null
            : donationType == RequestType.CASH
                ? 'CASH'
                : donationType == RequestType.GOODS ? 'GOODS' : 'TIME',
        "id": id == null ? null : id,
        "requestId": requestId == null ? null : requestId,
        "timebankId": timebankId == null ? null : timebankId,
        "donationStatus": donationStatus == null ? null : donationStatus,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "cashDetails": cashDetails == null ? null : cashDetails.toMap(),
        "goodsDetails": goodsDetails == null ? null : goodsDetails.toMap(),
        "donorDetails": donorDetails == null ? null : donorDetails.toMap(),
      };
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
  GoodsDetails({this.comments, this.donatedGoods});

  String comments;
  Map<dynamic, dynamic> donatedGoods;

  factory GoodsDetails.fromMap(Map<String, dynamic> json) => GoodsDetails(
      comments: json["comments"] == null ? null : json["comments"],
      donatedGoods: json.containsKey('donatedGoods')
          ? Map<dynamic, dynamic>.from(json["donatedGoods"])
          : null);

  Map<String, dynamic> toMap() => {
        "comments": comments == null ? null : comments,
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
