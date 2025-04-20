import 'package:sevaexchange/models/data_model.dart';

class UserAddedModel extends DataModel {
  String? adminName;
  String? timebankName;
  String? timebankImage;
  String? addedMemberName;

  UserAddedModel({
    this.adminName,
    this.timebankName,
    this.timebankImage,
    this.addedMemberName,
  }); //  String userName;

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap

    Map<String, dynamic> object = {};
    if (this.adminName != null && this.adminName?.isNotEmpty == true) {
      object['adminName'] = this.adminName;
    }
    if (this.addedMemberName != null &&
        this.addedMemberName?.isNotEmpty == true) {
      object['addedMemberName'] = this.addedMemberName;
    }
    if (this.timebankName != null && this.timebankName?.isNotEmpty == true) {
      object['timebankName'] = this.timebankName;
    }
    if (this.timebankImage != null && this.timebankImage?.isNotEmpty == true) {
      object['timebankImage'] = this.timebankImage;
    }
    return object;
  }

  UserAddedModel.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
    if (map.containsKey('adminName')) {
      this.adminName = map['adminName'];
    }

    if (map.containsKey('addedMemberName')) {
      this.addedMemberName = map['addedMemberName'];
    }

    if (map.containsKey('timebankName')) {
      this.timebankName = map['timebankName'];
    }

    if (map.containsKey('timebankImage')) {
      this.timebankImage = map['timebankImage'];
    }
  }
}
