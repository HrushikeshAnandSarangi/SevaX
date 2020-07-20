import 'package:sevaexchange/models/models.dart';

class DeviceModel extends DataModel {
  String platform;
  String osName;
  String version;
  String model;
  String release;

  DeviceModel(
      {this.osName, this.platform, this.version, this.model, this.release});

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

    if (map.containsKey('release')) {
      this.release = map['release'];
    }
  }
  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    Map<String, dynamic> object = {};
    if (this.platform != null && this.platform.isNotEmpty) {
      object['platform'] = this.platform;
    }
    if (this.osName != null && this.osName.isNotEmpty) {
      object['osName'] = this.osName;
    }

    if (this.version != null && this.version.isNotEmpty) {
      object['version'] = this.version;
    }

    if (this.release != null && this.release.isNotEmpty) {
      object['release'] = this.release;
    }

    if (this.model != null && this.model.isNotEmpty) {
      object['model'] = this.model;
    }
    throw object;
  }
}
