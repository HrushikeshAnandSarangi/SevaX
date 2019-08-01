class ProjectModel {
    String id;
    String name;
    String timebankId;
    String description;
    String emailId;
    String phoneNumber;
    String creatorId;
    String address;
    String photoUrl;
    int createdAt;
    int startTime;
    int endTime;
    List<String> members;

    ProjectModel({
        this.id,
        this.name,
        this.timebankId,
        this.description,
        this.emailId,
        this.phoneNumber,
        this.creatorId,
        this.address,
        this.photoUrl,
        this.createdAt,
        this.startTime,
        this.endTime,
        this.members,
    });

    factory ProjectModel.fromMap(Map<String, dynamic> json) => new ProjectModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        timebankId: json["timebank_id"] == null ? null : json["timebank_id"],
        description: json["description"] == null ? null : json["description"],
        emailId: json["email_id"] == null ? null : json["email_id"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        address: json["address"] == null ? null : json["address"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        startTime: json["start_time"] == null ? null : json["start_time"],
        endTime: json["end_time"] == null ? null : json["end_time"],
        members: json["members"] == null ? null : new List<String>.from(json["members"].map((x) => x)),
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "timebank_id": timebankId == null ? null : timebankId,
        "description": description == null ? null : description,
        "email_id": emailId == null ? null : emailId,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "creator_id": creatorId == null ? null : creatorId,
        "address": address == null ? null : address,
        "photo_url": photoUrl == null ? null : photoUrl,
        "created_at": createdAt == null ? null : createdAt,
        "start_time": startTime == null ? null : startTime,
        "end_time": endTime == null ? null : endTime,
        "members": members == null ? null : new List<dynamic>.from(members.map((x) => x)),
    };
}