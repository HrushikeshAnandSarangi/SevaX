// To parse this JSON data, do
//
//     final acceptorModel = acceptorModelFromMap(jsonString);

import 'dart:convert';

AcceptorModel acceptorModelFromMap(String str) =>
    AcceptorModel.fromMap(json.decode(str));

String acceptorModelToMap(AcceptorModel data) => json.encode(data.toMap());

class AcceptorModel {
  AcceptorModel({
    this.communityId,
    this.communityName,
    this.memberName,
    this.memberEmail,
    this.memberPhotoUrl,
    this.timebankId,
  });

  String communityId;
  String communityName;
  String memberName;
  String memberEmail;
  String memberPhotoUrl;
  String timebankId;

  factory AcceptorModel.fromMap(Map<String, dynamic> json) => AcceptorModel(
        communityId: json["communityId"] == null ? null : json["communityId"],
        communityName:
            json["communityName"] == null ? null : json["communityName"],
        memberName: json["memberName"] == null ? null : json["memberName"],
        memberEmail: json["memberEmail"] == null ? null : json["memberEmail"],
        memberPhotoUrl:
            json["memberPhotoUrl"] == null ? null : json["memberPhotoUrl"],
        timebankId: json["timebankId"] == null ? null : json["timebankId"],
      );

  Map<String, dynamic> toMap() => {
        "communityId": communityId == null ? null : communityId,
        "communityName": communityName == null ? null : communityName,
        "memberName": memberName == null ? null : memberName,
        "memberEmail": memberEmail == null ? null : memberEmail,
        "memberPhotoUrl": memberPhotoUrl == null ? null : memberPhotoUrl,
        "timebankId": timebankId == null ? null : timebankId,
      };
}
