import 'package:sevaexchange/models/models.dart';

class DeviceModel extends DataModel {
  String? platform;
  String? osName;
  String? version;
  String? model;

  DeviceModel({
    required this.osName,
    required this.platform,
    required this.version,
    required this.model,
  });

  DeviceModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('platform')) {
      this.platform = map['platform'];
    }

    if (map.containsKey('osName')) {
      this.osName = map['osName'];
    }

    if (map.containsKey('version')) {
      this.version = map['version'];
    }

    if (map.containsKey('model')) {
      this.model = map['model'];
    }
  }
  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    Map<String, dynamic> object = {};
    if (this.platform != null && this.platform?.isNotEmpty == true) {
      object['platform'] = this.platform;
    }
    if (this.osName != null && this.osName?.isNotEmpty == true) {
      object['osName'] = this.osName;
    }

    if (this.version != null && this.version?.isNotEmpty == true) {
      object['version'] = this.version;
    }

    if (this.model != null && this.model?.isNotEmpty == true) {
      object['model'] = this.model;
    }
    return object;
  }

  @override
  String toString() {
    return 'DeviceModel{platform: $platform, osName: $osName, version: $version, model: $model,}';
  }
}
