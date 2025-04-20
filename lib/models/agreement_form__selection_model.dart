import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class AgreementFormSelectionModel extends DataModel {
  int? createdAt;
  String? documentName;
  String? placeOrItem;
  String? otherDetails;
  String? specificConditions;
  bool? isDamageLiability;
  bool? isUseDisclaimer;
  bool? isDeliveryReturn;
  bool? isMaintainRepair;
  bool? isOffer;
  String? agreementLink;

  AgreementFormSelectionModel(
      {this.createdAt,
      this.documentName,
      this.placeOrItem,
      this.otherDetails,
      this.specificConditions,
      this.isDamageLiability,
      this.isUseDisclaimer,
      this.isDeliveryReturn,
      this.isMaintainRepair,
      this.isOffer,
      this.agreementLink});

  factory AgreementFormSelectionModel.fromMap(Map<String, dynamic> json) =>
      AgreementFormSelectionModel(
        createdAt: json["created_at"] == null ? null : json["created_at"],
        documentName:
            json["documentName"] == null ? null : json["documentName"],
        placeOrItem: json["placeOrItem"] == null ? null : json["placeOrItem"],
        otherDetails:
            json["otherDetails"] == null ? null : json["otherDetails"],
        specificConditions: json["specificConditions"] == null
            ? null
            : json["specificConditions"],
        isDamageLiability: json["isDamageLiability"] == null
            ? null
            : json["isDamageLiability"],
        isUseDisclaimer:
            json["isUseDisclaimer"] == null ? null : json["isUseDisclaimer"],
        isDeliveryReturn:
            json["isDeliveryReturn"] == null ? null : json["isDeliveryReturn"],
        isMaintainRepair:
            json["isMaintainRepair"] == null ? null : json["isMaintainRepair"],
        isOffer: json["isOffer"] == null ? false : json["isOffer"],
        agreementLink:
            json["agreementLink"] == null ? false : json["agreementLink"],
      );

  Map<String, dynamic> toMap() => {
        "createdAt": createdAt == null ? null : createdAt,
        "documentName": documentName == null ? null : documentName,
        "placeOrItem": placeOrItem == null ? null : placeOrItem,
        "otherDetails": otherDetails == null ? null : otherDetails,
        "specificConditions":
            specificConditions == null ? null : specificConditions,
        "isDamageLiability":
            isDamageLiability == null ? null : isDamageLiability,
        "isUseDisclaimer": isUseDisclaimer == null ? null : isUseDisclaimer,
        "isDeliveryReturn": isDeliveryReturn == null ? null : isDeliveryReturn,
        "isMaintainRepair": isMaintainRepair == null ? null : isMaintainRepair,
        "isOffer": isOffer == null ? null : isOffer,
        "agreementLink": agreementLink == null ? null : agreementLink,
        //data is already a map
      };

  @override
  String toString() {
    return 'AgreementTemplateModel{ documentName: $documentName, otherDetails: $otherDetails, specificConditions: $specificConditions,  createdAt: $createdAt, isOffer: $isOffer, placeOrItem: $placeOrItem, isDamageLiability: $isDamageLiability, isUseDisclaimer: $isUseDisclaimer, isDeliveryReturn: $isDeliveryReturn, isMaintainRepair: $isMaintainRepair, agreementLink: $agreementLink}';
  }
}
