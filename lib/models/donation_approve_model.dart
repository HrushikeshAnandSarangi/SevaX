import 'package:sevaexchange/models/request_model.dart';

class DonationApproveModel {
  DonationApproveModel({
    this.donorName,
    this.donorEmail,
    this.donorPhotoUrl,
    this.requestTitle,
    this.requestId,
    this.donationId,
    this.donationDetails,
    this.donationType,
  });

  String? donorName;
  String? donorEmail;
  String? donorPhotoUrl;
  String? requestTitle;
  String? requestId;
  String? donationId;
  String? donationDetails;
  RequestType? donationType;

  factory DonationApproveModel.fromMap(Map<String, dynamic> json) =>
      DonationApproveModel(
        donorName: json["donorName"] == null ? null : json["donorName"],
        donorPhotoUrl:
            json["donorPhotoUrl"] == null ? null : json["donorPhotoUrl"],
        donorEmail: json["donorEmail"] == null ? null : json["donorEmail"],
        requestTitle:
            json["requestTitle"] == null ? null : json["requestTitle"],
        requestId: json["requestId"] == null ? null : json["requestId"],
        donationId: json["donationId"] == null ? null : json["donationId"],
        donationDetails:
            json["donationDetails"] == null ? null : json["donationDetails"],
        donationType: json["donationType"] == null
            ? RequestType.DONATION
            : requestTypeMapper[json["donationType"]]!,
      );

  Map<String, dynamic> toMap() => {
        "donorName": donorName == null ? null : donorName,
        "donorEmail": donorEmail == null ? null : donorEmail,
        "donorPhotoUrl": donorPhotoUrl == null ? null : donorPhotoUrl,
        "requestTitle": requestTitle == null ? null : requestTitle,
        "requestId": requestId == null ? null : requestId,
        "donationId": donationId == null ? null : donationId,
        "donationDetails": donationDetails == null ? null : donationDetails,
        "donationType":
            donationType == null ? null : donationType.toString().split('.')[1],
      };
}
