import 'package:sevaexchange/models/data_model.dart';

class TimebankCodeModel extends DataModel {
  int? createdOn;
  String? timebankCode;
  String? timebankId;
  int? validUpto;
  String? timebankCodeId;
  List<String>? usersOnBoarded;
  String? communityId;

  TimebankCodeModel({
    required this.createdOn,
    required this.timebankCode,
    required this.timebankId,
    required this.validUpto,
    required this.timebankCodeId,
    required this.communityId,
  }) : usersOnBoarded = [];

  TimebankCodeModel.fromMap(Map<String, dynamic> data) {
    this.createdOn = data['createdOn'];
    this.timebankCode = data['timebankCode'];
    this.timebankId = data['timebankId'];
    this.validUpto = data['validUpto'];
    this.timebankCodeId = data['timebankCodeId'];
    this.communityId = data['communityId'];

    this.usersOnBoarded = data['usersOnboarded'] == null
        ? []
        : List<String>.from(data['usersOnboarded'].map((u) => u));
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.createdOn != null) {
      object['createdOn'] = this.createdOn;
    }
    if (this.timebankCode != null && this.timebankCode!.isNotEmpty) {
      object['timebankCode'] = this.timebankCode;
    }
    if (this.timebankId != null && this.timebankId!.isNotEmpty) {
      object['timebankId'] = this.timebankId;
    }
    if (this.validUpto != null) {
      object['validUpto'] = this.validUpto;
    }
    if (this.timebankCodeId != null && this.timebankCodeId!.isNotEmpty) {
      object['timebankCodeId'] = this.timebankCodeId;
    }

    if (this.communityId != null && this.communityId!.isNotEmpty) {
      object['communityId'] = this.communityId;
    }

    return object;
  }

  @override
  String toString() {
    return 'TimebankCodeModel{createdOn: $createdOn, timebankCode: $timebankCode, timebankId: $timebankId, validUpto: $validUpto, timebankCodeId: $timebankCodeId, usersOnBoarded: $usersOnBoarded, communityId: $communityId}';
  }
}
