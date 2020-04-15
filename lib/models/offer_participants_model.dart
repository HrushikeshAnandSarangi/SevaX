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

enum ParticipantStatus {
  NO_ACTION_FROM_CREATOR,
  CREATOR_REQUESTED_CREDITS,
  MEMBER_APPROVED_CREDIT_REQUEST,
  MEMBER_REJECTED_CREDIT_REQUEST,
}

String getParticipantStatus(ParticipantStatus status) {
  switch (status) {
    case ParticipantStatus.NO_ACTION_FROM_CREATOR:
      return '';
      break;
    case ParticipantStatus.CREATOR_REQUESTED_CREDITS:
      return 'REQUESTED';
      break;
    case ParticipantStatus.MEMBER_APPROVED_CREDIT_REQUEST:
      return 'APPROVED';
      break;
    case ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST:
      return 'REJECTED';
      break;
    default:
      return "";
      break;
  }
}
