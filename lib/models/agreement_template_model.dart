import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class AgreementTemplateModel extends DataModel {
  String? id;
  String? creatorId;
  String? creatorEmail;
  String? timebankId;
  String? communityId;
  String? templateName;
  int? createdAt;
  bool? softDelete;
  String? documentName;
  String? placeOrItem;
  String? otherDetails;
  String? specificConditions;
  bool? isDamageLiability;
  bool? isUseDisclaimer;
  bool? isDeliveryReturn;
  bool? isMaintainRepair;
  bool? isRefundDepositNeeded;
  bool? isMaintainAndclean;
  bool? isOffer;

  AgreementTemplateModel({
    this.id,
    this.creatorId,
    this.creatorEmail,
    this.timebankId,
    this.communityId,
    this.templateName,
    this.createdAt,
    this.softDelete,
    this.documentName,
    this.placeOrItem,
    this.otherDetails,
    this.specificConditions,
    this.isDamageLiability,
    this.isUseDisclaimer,
    this.isDeliveryReturn,
    this.isMaintainRepair,
    this.isRefundDepositNeeded,
    this.isMaintainAndclean,
    this.isOffer,
  });

  factory AgreementTemplateModel.fromMap(Map<String, dynamic> json) =>
      AgreementTemplateModel(
        id: json["id"] == null ? null : json["id"],
        creatorId: json["creatorId"] == null ? null : json["creatorId"],
        creatorEmail:
            json["creatorEmail"] == null ? null : json["creatorEmail"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        templateName:
            json["templateName"] == null ? null : json["templateName"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        softDelete: json["softDelete"] == null ? false : json["softDelete"],
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
        isRefundDepositNeeded: json["isRefundDepositNeeded"] == null
            ? null
            : json["isRefundDepositNeeded"],
        isMaintainAndclean: json["isMaintainAndclean"] == null
            ? null
            : json["isMaintainAndclean"],
        isOffer: json["isOffer"] == null ? false : json["isOffer"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "creatorId": creatorId == null ? null : creatorId,
        "creatorEmail": creatorEmail == null ? null : creatorEmail,
        "timebank_id": timebankId == null ? null : timebankId,
        "communityId": communityId == null ? null : communityId,
        "templateName": templateName == null ? null : templateName,
        "created_at": createdAt == null ? null : createdAt,
        "softDelete": softDelete ?? false,
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
        "isRefundDepositNeeded":
            isRefundDepositNeeded == null ? null : isRefundDepositNeeded,
        "isMaintainAndclean":
            isMaintainAndclean == null ? null : isMaintainAndclean,
        "isOffer": isOffer ?? false,
      };

  @override
  String toString() {
    return 'AgreementTemplateModel{id: $id, creatorId: $creatorId, creatorEmail: $creatorEmail, documentName: $documentName, otherDetails: $otherDetails, templateName: $templateName, timebankId: $timebankId, communityId: $communityId, specificConditions: $specificConditions,  createdAt: $createdAt, softDelete: $softDelete, isOffer: $isOffer, placeOrItem: $placeOrItem, isDamageLiability: $isDamageLiability, isUseDisclaimer: $isUseDisclaimer, isDeliveryReturn: $isDeliveryReturn, isMaintainRepair: $isMaintainRepair, isRefundDepositNeeded: $isRefundDepositNeeded, isMaintainAndclean: $isMaintainAndclean}';
  }
}
