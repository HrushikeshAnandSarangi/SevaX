import 'package:sevaexchange/models/data_model.dart';
import 'package:sevaexchange/models/models.dart';

class BorrowAgreementTemplateModel extends DataModel {
  final String id;
  final String timebankId;
  final String communityId;
  final String templateName;
  final int createdAt;
  final bool softDelete;
  final String documentName;
  final String otherDetails;
  final String specificConditions;
  final String itemDescription;
  final String additionalConditions;
  final bool isFixedTerm;
  final bool isQuietHoursAllowed;
  final bool isPetsAllowed;
  final int maximumOccupants;
  final int securityDeposit;
  final String contactDetails;
  final String roomOrTool;
  final bool isRequest;

  BorrowAgreementTemplateModel({
    required this.id,
    required this.timebankId,
    required this.communityId,
    required this.templateName,
    required this.createdAt,
    required this.softDelete,
    required this.documentName,
    required this.otherDetails,
    required this.specificConditions,
    required this.itemDescription,
    required this.additionalConditions,
    required this.isFixedTerm,
    required this.isQuietHoursAllowed,
    required this.isPetsAllowed,
    required this.maximumOccupants,
    required this.securityDeposit,
    required this.contactDetails,
    required this.roomOrTool,
    required this.isRequest,
  });

  factory BorrowAgreementTemplateModel.fromMap(Map<String, dynamic> json) =>
      BorrowAgreementTemplateModel(
        id: json["id"] == null ? null : json["id"],
        documentName:
            json["documentName"] == null ? null : json["documentName"],
        otherDetails:
            json["otherDetails"] == null ? null : json["otherDetails"],
        templateName:
            json["templateName"] == null ? null : json["templateName"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        specificConditions: json["specificConditions"] == null
            ? null
            : json["specificConditions"],
        itemDescription:
            json["itemDescription"] == null ? null : json["itemDescription"],
        additionalConditions: json["additionalConditions"] == null
            ? null
            : json["additionalConditions"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        softDelete: json["softDelete"] == null ? false : json["softDelete"],
        isFixedTerm: json["isFixedTerm"] == null ? false : json["isFixedTerm"],
        isQuietHoursAllowed: json["isQuietHoursAllowed"] == null
            ? false
            : json["isQuietHoursAllowed"],
        isPetsAllowed:
            json["isPetsAllowed"] == null ? false : json["isPetsAllowed"],
        maximumOccupants:
            json["maximumOccupants"] == null ? null : json["maximumOccupants"],
        securityDeposit:
            json["securityDeposit"] == null ? null : json["securityDeposit"],
        contactDetails:
            json["contactDetails"] == null ? null : json["contactDetails"],
        roomOrTool: json["roomOrTool"] == null ? null : json["roomOrTool"],
        isRequest: json["isRequest"] == null ? false : json["isRequest"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "documentName": documentName == null ? null : documentName,
        "otherDetails": otherDetails == null ? null : otherDetails,
        "templateName": templateName == null ? null : templateName,
        "timebank_id": timebankId == null ? null : timebankId,
        "communityId": communityId == null ? null : communityId,
        "specificConditions":
            specificConditions == null ? null : specificConditions,
        "itemDescription": itemDescription == null ? null : itemDescription,
        "additionalConditions":
            additionalConditions == null ? null : additionalConditions,
        "softDelete": softDelete ?? false,
        "isFixedTerm": isFixedTerm ?? false,
        "isQuietHoursAllowed": isQuietHoursAllowed ?? false,
        "isPetsAllowed": isPetsAllowed ?? false,
        "created_at": createdAt == null ? null : createdAt,
        "maximumOccupants": maximumOccupants == null ? null : maximumOccupants,
        "securityDeposit": securityDeposit == null ? null : securityDeposit,
        "contactDetails": contactDetails == null ? null : contactDetails,
        "roomOrTool": roomOrTool == null ? null : roomOrTool,
        "isRequest": isRequest ?? false,
      };

  @override
  String toString() {
    return 'BorrowAgreementTemplateModel{id: $id, documentName: $documentName, otherDetails: $otherDetails, templateName: $templateName, timebankId: $timebankId, communityId: $communityId, specificConditions: $specificConditions, itemDescription: $itemDescription, additionalConditions: $additionalConditions, createdAt: $createdAt, softDelete: $softDelete, isFixedTerm: $isFixedTerm, isQuietHoursAllowed: $isQuietHoursAllowed, isPetsAllowed: $isPetsAllowed, maximumOccupants: $maximumOccupants, securityDeposit: $securityDeposit, contactDetails: $contactDetails, roomOrTool: $roomOrTool, isRequest: $isRequest}';
  }
}
