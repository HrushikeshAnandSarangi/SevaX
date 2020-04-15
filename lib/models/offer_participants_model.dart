class OfferParticipantsModel {
  String photourl;
  String creatorStatus;
  String rating;
  String bio;
  String fullname;
  String sevauserid;
  String email;
  String status;

  OfferParticipantsModel({
    this.photourl,
    this.creatorStatus,
    this.rating,
    this.bio,
    this.fullname,
    this.sevauserid,
    this.email,
    this.status,
  });

  factory OfferParticipantsModel.fromJson(Map<String, dynamic> json) =>
      OfferParticipantsModel(
        photourl: json["photourl"],
        creatorStatus: json["creator_status"],
        rating: json["rating"],
        bio: json["bio"],
        fullname: json["fullname"],
        sevauserid: json["sevauserid"],
        email: json["email"],
        status: json["status"],
      );
}
