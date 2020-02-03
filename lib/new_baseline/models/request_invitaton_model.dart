
import 'package:sevaexchange/models/models.dart';


class RequestInvitationModel extends DataModel{
    String timebankName;
    String timebankImage;
    String requestTitle;
    String requestDesc;
    String requestId;


    RequestInvitationModel({this.timebankName, this.timebankImage,
        this.requestTitle, this.requestDesc, this.requestId,});

    @override
  Map<String, dynamic> toMap() {
      Map<String, dynamic> object = {};


      if(this.timebankName != null && this.timebankName.isNotEmpty){
        object['timebankName'] = this.timebankName;
      }
      if(this.timebankImage != null && this.timebankImage.isNotEmpty){
        object['timebankImage'] = this.timebankImage;
      }
      if(this.requestTitle != null && this.requestTitle.isNotEmpty){
        object['requestTitle'] = this.requestTitle;
      }
      if(this.requestDesc != null && this.requestDesc.isNotEmpty){
        object['requestDescription'] = this.requestDesc;
      }
      if(this.requestId != null && this.requestId.isNotEmpty){
        object['requestId'] = this.requestId;
      }



      // TODO: implement toMap
    return object;
  }


  RequestInvitationModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('timebankName')) {
      this.timebankName = map['timebankName'];
    }

    if (map.containsKey('timebankImage')) {
      this.timebankImage = map['timebankImage'];
    }

    if (map.containsKey('requestTitle')) {
      this.requestTitle = map['requestTitle'];
    }

    if (map.containsKey('requestDescription')) {
      this.requestDesc = map['requestDescription'];
    }

    if (map.containsKey('requestId')) {
      this.requestId = map['requestId'];
        }

    }

}