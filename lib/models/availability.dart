
class AvailabilityModel  {
  //String text;
  String accurance_number;
  String endsData;
  String repeatAfterStr;
  String endsStatus;
  String repeatNumber;
  String distnace;
  String location;
  String lat_lng;
  Set<String> weekArray;
  AvailabilityModel(this.accurance_number,this.weekArray,this.endsData,this.endsStatus,this.repeatAfterStr,this.repeatNumber,this.lat_lng,this.distnace);
  AvailabilityModel.empty() {
    // text = "";
    accurance_number = "0";
  }
  AvailabilityModel.fromMap(Map<dynamic, dynamic> map) {
    if (map.containsKey('accurance_number')) {
      this.accurance_number = map['accurance_number'];
    }
    if (map.containsKey('endsDate')) {
      this.endsData = map['endsDate'];
    }
    if (map.containsKey('repeatAfterStr')) {
      this.repeatAfterStr = map['repeatAfterStr'];
    }
    if (map.containsKey('endsStatus')) {
      this.endsStatus = map['endsStatus'];
    }
    if (map.containsKey('repeatNumber')) {
      this.repeatNumber = map['repeatNumber'];
    }
    if (map.containsKey('distnace')) {
      this.endsData = map['distnace'];
    }
    if (map.containsKey('endsData')) {
      this.endsData = map['endsData'];
    }
    if (map.containsKey('lat_lng')) {
      this.repeatAfterStr = map['lat_lng'];
    }
    if (map.containsKey('weekArray')) {
      Set<String> interestsList = Set.castFrom(map['weekArray']);
      this.weekArray = interestsList;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.accurance_number != null && this.accurance_number.isNotEmpty) {
      object['accurance_number'] = this.accurance_number;
    }
    if (this.endsData != null && this.endsData.isNotEmpty) {
      object['endsDate'] = this.endsData;
    }
    if (this.distnace != null && this.distnace.isNotEmpty) {
      object['distance'] = this.distnace;
    }
    if (this.lat_lng != null && this.lat_lng.isNotEmpty) {
      object['lat_lng'] = this.lat_lng;
    }

    if (this.repeatAfterStr != null && this.repeatAfterStr.isNotEmpty) {
      object['repeatAfterStr'] = this.repeatAfterStr;
    }
    if (this.endsStatus != null && this.endsStatus.isNotEmpty) {
      object['endsStatus'] = this.endsStatus;
    }
    if (this.repeatNumber != null && this.repeatNumber.isNotEmpty) {
      object['repeatNumber'] = this.repeatNumber;
    }
    if (this.weekArray != null &&
        this.weekArray.isNotEmpty) {
      object['weekArray'] = this.weekArray;
    }
    return object;
  }
}