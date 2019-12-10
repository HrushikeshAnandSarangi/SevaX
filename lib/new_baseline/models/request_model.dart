class RequestModel {
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
  List<String> acceptors;
  int numberOfVolunteers;
  List<String> approvedUsers;
  bool isAccepted;
  List<TransactionModel> transactionModel;

  RequestModel({
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
    this.acceptors,
    this.numberOfVolunteers,
    this.approvedUsers,
    this.isAccepted,
    this.transactionModel,
  });

  factory RequestModel.fromMap(Map<String, dynamic> json) => new RequestModel(
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
        acceptors: json["acceptors"] == null
            ? null
            : new List<String>.from(json["acceptors"].map((x) => x)),
        numberOfVolunteers: json["number_of_volunteers"] == null
            ? null
            : json["number_of_volunteers"],
        approvedUsers: json["approved_users"] == null
            ? null
            : new List<String>.from(json["approved_users"].map((x) => x)),
        isAccepted: json["is_accepted"] == null ? null : json["is_accepted"],
        transactionModel: json["transaction_model"] == null
            ? null
            : new List<TransactionModel>.from(json["transaction_model"]
                .map((x) => TransactionModel.fromMap(x))),
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
        "acceptors": acceptors == null
            ? null
            : new List<dynamic>.from(acceptors.map((x) => x)),
        "number_of_volunteers":
            numberOfVolunteers == null ? null : numberOfVolunteers,
        "approved_users": approvedUsers == null
            ? null
            : new List<dynamic>.from(approvedUsers.map((x) => x)),
        "is_accepted": isAccepted == null ? null : isAccepted,
        "transaction_model": transactionModel == null
            ? null
            : new List<dynamic>.from(transactionModel.map((x) => x.toMap())),
      };
}

class TransactionModel {
  String id;
  String fromUserId;
  String toUserId;
  int time;
  double credits;
  bool isApproved;

  TransactionModel({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.time,
    this.credits,
    this.isApproved,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> json) =>
      new TransactionModel(
        id: json["id"] == null ? null : json["id"],
        fromUserId: json["from_user_id"] == null ? null : json["from_user_id"],
        toUserId: json["to_user_id"] == null ? null : json["to_user_id"],
        time: json["time"] == null ? null : json["time"],
        credits: json["credits"] == null ? null : json["credits"].toDouble(),
        isApproved: json["is_approved"] == null ? null : json["is_approved"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "from_user_id": fromUserId == null ? null : fromUserId,
        "to_user_id": toUserId == null ? null : toUserId,
        "time": time == null ? null : time,
        "credits": credits == null ? null : credits,
        "is_approved": isApproved == null ? null : isApproved,
      };
}
