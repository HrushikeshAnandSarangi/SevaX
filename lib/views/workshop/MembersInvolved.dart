import 'dart:convert' as prefix0;

class MembersList {
  List<MemberForRequest> membersForList;
  MembersList({this.membersForList});

  factory MembersList.fromJson(List<dynamic> parsedJson) {
    List<MemberForRequest> membersList = new List<MemberForRequest>();
    membersList = parsedJson.map((i) => MemberForRequest.fromJson(i)).toList();
    return MembersList(
      membersForList: membersList,
    );
  }
}

class MemberForRequest {
  String tokens;
  String photourl;
  String timezone;
  String email;
  String sevauserid;
  String fullname;
  bool acceptedEULA;
  String bio;

  MemberForRequest(
      {this.tokens,
      this.photourl,
      this.timezone,
      this.email,
      this.sevauserid,
      this.fullname,
      this.bio});

  factory MemberForRequest.fromJson(Map<String, dynamic> json) {
        print(json);

    return MemberForRequest(
        
        tokens: json['tokens'] == null ? '' : json['tokens'],
        photourl: json['photourl'] == null ? '' : json['photourl'],
        timezone: json['timezone'] == null ? '' : json['timezone'],
        email: json['email'] == null ? '' : json['email'],
        sevauserid: json['sevauserid'] == null ? '' : json['sevauserid'],
        fullname: json['fullname'] == null ? '' : json['fullname'],
        bio: json['bio'] == null ? '' : json['bio']);
  }


  @override
  String toString() {
    return this.fullname;
  }


}
