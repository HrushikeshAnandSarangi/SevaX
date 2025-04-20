import 'dart:convert';

import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';

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

  final bool? adult;
  final bool? spoof;
  final bool? medical;
  final bool? violence;
  final bool? racy;
  final double? adultConfidence;
  final double? spoofConfidence;
  final double? medicalConfidence;
  final double? violenceConfidence;
  final double? racyConfidence;
  final double? nsfwConfidence;

  factory ProfanityImageModel.fromMap(Map<String, dynamic> json) {
    logger.d(">>>>> ${json.toString()}");

    return ProfanityImageModel(
      adult: json["adult"] as bool?,
      spoof: json["spoof"] as bool?,
      medical: json["medical"] as bool?,
      violence: json["violence"] as bool?,
      racy: json["racy"] as bool?,
      adultConfidence: json["adultConfidence"] as double?,
      spoofConfidence: json["spoofConfidence"] as double?,
      medicalConfidence: json["medicalConfidence"] as double?,
      violenceConfidence: json["violenceConfidence"] as double?,
      racyConfidence: json["racyConfidence"] as double?,
      nsfwConfidence: json["nsfwConfidence"] as double?,
    );
  }

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

  bool? isProfane;
  String? category;

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
