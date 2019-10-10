
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

  Map<String, dynamic> toMap() {
    Map<String, dynamic> object = {};

    if (this.accurance_number != null && this.accurance_number.isNotEmpty) {
      object['accurance_number'] = this.accurance_number;
    }
    if (this.endsData != null && this.endsData.isNotEmpty) {
      object['endsData'] = this.endsData;
    }
    if (this.distnace != null && this.distnace.isNotEmpty) {
      object['distnace'] = this.distnace;
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