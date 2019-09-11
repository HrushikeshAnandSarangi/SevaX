class OfferModel {
  String id;
  String title;
  String description;
  int startTime;
  int endTime;
  String creatorId;
  String photoUrl;
  String photoCredits;
  int createdAt;
  String timebankId;
  String projectId;
  List<String> requestId;
  int numberOfRequestees;
  List<String> approvedRequests;

  OfferModel({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.creatorId,
    this.photoUrl,
    this.photoCredits,
    this.createdAt,
    this.timebankId,
    this.projectId,
    this.requestId,
    this.numberOfRequestees,
    this.approvedRequests,
  });

  factory OfferModel.fromMap(Map<String, dynamic> json) => new OfferModel(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        startTime: json["start_time"] == null ? null : json["start_time"],
        endTime: json["end_time"] == null ? null : json["end_time"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        photoCredits:
            json["photo_credits"] == null ? null : json["photo_credits"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        projectId: json["project_id"] == null ? null : json["project_id"],
        requestId: json["request_id"] == null
            ? null
            : new List<String>.from(json["request_id"].map((x) => x)),
        numberOfRequestees: json["number_of_requestees"] == null
            ? null
            : json["number_of_requestees"],
        approvedRequests: json["approved_requests"] == null
            ? null
            : new List<String>.from(json["approved_requests"].map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "start_time": startTime == null ? null : startTime,
        "end_time": endTime == null ? null : endTime,
        "creator_id": creatorId == null ? null : creatorId,
        "photo_url": photoUrl == null ? null : photoUrl,
        "photo_credits": photoCredits == null ? null : photoCredits,
        "created_at": createdAt == null ? null : createdAt,
        "timebank_id": timebankId == null ? null : timebankId,
        "project_id": projectId == null ? null : projectId,
        "request_id": requestId == null
            ? null
            : new List<dynamic>.from(requestId.map((x) => x)),
        "number_of_requestees":
            numberOfRequestees == null ? null : numberOfRequestees,
        "approved_requests": approvedRequests == null
            ? null
            : new List<dynamic>.from(approvedRequests.map((x) => x)),
      };
}
