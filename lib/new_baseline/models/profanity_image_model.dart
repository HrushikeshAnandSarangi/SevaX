import 'dart:convert';

import 'package:sevaexchange/models/data_model.dart';

ProfanityImageModel profanityImageModelFromMap(String str) =>
    ProfanityImageModel.fromMap(json.decode(str));

String profanityImageModelToMap(ProfanityImageModel data) =>
    json.encode(data.toMap());

class ProfanityImageModel extends DataModel {
  ProfanityImageModel({
    this.adult,
    this.spoof,
    this.medical,
    this.violence,
    this.racy,
    this.adultConfidence,
    this.spoofConfidence,
    this.medicalConfidence,
    this.violenceConfidence,
    this.racyConfidence,
    this.nsfwConfidence,
  });

  String adult;
  String spoof;
  String medical;
  String violence;
  String racy;
  int adultConfidence;
  int spoofConfidence;
  int medicalConfidence;
  int violenceConfidence;
  int racyConfidence;
  int nsfwConfidence;

  factory ProfanityImageModel.fromMap(Map<String, dynamic> json) =>
      ProfanityImageModel(
        adult: json["adult"] == null ? null : json["adult"],
        spoof: json["spoof"] == null ? null : json["spoof"],
        medical: json["medical"] == null ? null : json["medical"],
        violence: json["violence"] == null ? null : json["violence"],
        racy: json["racy"] == null ? null : json["racy"],
        adultConfidence:
            json["adultConfidence"] == null ? null : json["adultConfidence"],
        spoofConfidence:
            json["spoofConfidence"] == null ? null : json["spoofConfidence"],
        medicalConfidence: json["medicalConfidence"] == null
            ? null
            : json["medicalConfidence"],
        violenceConfidence: json["violenceConfidence"] == null
            ? null
            : json["violenceConfidence"],
        racyConfidence:
            json["racyConfidence"] == null ? null : json["racyConfidence"],
        nsfwConfidence:
            json["nsfwConfidence"] == null ? null : json["nsfwConfidence"],
      );

  Map<String, dynamic> toMap() => {
        "adult": adult == null ? null : adult,
        "spoof": spoof == null ? null : spoof,
        "medical": medical == null ? null : medical,
        "violence": violence == null ? null : violence,
        "racy": racy == null ? null : racy,
        "adultConfidence": adultConfidence == null ? null : adultConfidence,
        "spoofConfidence": spoofConfidence == null ? null : spoofConfidence,
        "medicalConfidence":
            medicalConfidence == null ? null : medicalConfidence,
        "violenceConfidence":
            violenceConfidence == null ? null : violenceConfidence,
        "racyConfidence": racyConfidence == null ? null : racyConfidence,
        "nsfwConfidence": nsfwConfidence == null ? null : nsfwConfidence,
      };

  @override
  String toString() {
    return 'ProfanityImageModel{adult: $adult, spoof: $spoof, medical: $medical, violence: $violence, racy: $racy, adultConfidence: $adultConfidence, spoofConfidence: $spoofConfidence, medicalConfidence: $medicalConfidence, violenceConfidence: $violenceConfidence, racyConfidence: $racyConfidence, nsfwConfidence: $nsfwConfidence}';
  }
}

class ProfanityStrings {
  static const String likely = 'LIKELY';
  static const String unLikely = 'UNLIKELY';
  static const String veryLikely = 'VERY_LIKELY';
  static const String veryUnLikely = 'VERY_UNLIKELY';
  static const String possible = 'POSSIBLE';

  static const String adult = 'Adult';
  static const String spoof = 'Spoof';
  static const String medical = 'Medical';
  static const String racy = 'Racy';
  static const String violence = 'Violence';
}

class ProfanityStatusModel {
  ProfanityStatusModel({
    this.isProfane,
    this.category,
  });

  bool isProfane;
  String category;

  factory ProfanityStatusModel.fromMap(Map<String, dynamic> json) =>
      ProfanityStatusModel(
        isProfane: json["isProfane"] == null ? null : json["isProfane"],
        category: json["category"] == null ? null : json["category"],
      );

  Map<String, dynamic> toMap() => {
        "isProfane": isProfane == null ? null : isProfane,
        "category": category == null ? null : category,
      };
}
