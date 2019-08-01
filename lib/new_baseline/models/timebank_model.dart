class TimebankModel {
    String id;
    String name;
    String missionStatement;
    String emailId;
    String phoneNumber;
    String address;
    String creatorId;
    String photoUrl;
    String photoCredits;
    int createdAt;
    List<String> admins;
    List<String> coordinators;
    List<String> members;
    bool protected;
    String parentTimebankId;
    List<String> children;
    double balance;

    TimebankModel({
        this.id,
        this.name,
        this.missionStatement,
        this.emailId,
        this.phoneNumber,
        this.address,
        this.creatorId,
        this.photoUrl,
        this.photoCredits,
        this.createdAt,
        this.admins,
        this.coordinators,
        this.members,
        this.protected,
        this.parentTimebankId,
        this.children,
        this.balance,
    });

    factory TimebankModel.fromMap(Map<String, dynamic> json) => new TimebankModel(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        missionStatement: json["missionStatement"] == null ? null : json["missionStatement"],
        emailId: json["email_id"] == null ? null : json["email_id"],
        phoneNumber: json["phone_number"] == null ? null : json["phone_number"],
        address: json["address"] == null ? null : json["address"],
        creatorId: json["creator_id"] == null ? null : json["creator_id"],
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        photoCredits: json["photo_credits"] == null ? null : json["photo_credits"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        admins: json["admins"] == null ? null : new List<String>.from(json["admins"].map((x) => x)),
        coordinators: json["coordinators"] == null ? null : new List<String>.from(json["coordinators"].map((x) => x)),
        members: json["members"] == null ? null : new List<String>.from(json["members"].map((x) => x)),
        protected: json["protected"] == null ? null : json["protected"],
        parentTimebankId: json["parent_timebank_id"] == null ? null : json["parent_timebank_id"],
        children: json["children"] == null ? null : new List<String>.from(json["children"].map((x) => x)),
        balance: json["balance"] == null ? null : json["balance"].toDouble(),
    );

    Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "missionStatement": missionStatement == null ? null : missionStatement,
        "email_id": emailId == null ? null : emailId,
        "phone_number": phoneNumber == null ? null : phoneNumber,
        "address": address == null ? null : address,
        "creator_id": creatorId == null ? null : creatorId,
        "photo_url": photoUrl == null ? null : photoUrl,
        "photo_credits": photoCredits == null ? null : photoCredits,
        "created_at": createdAt == null ? null : createdAt,
        "admins": admins == null ? null : new List<dynamic>.from(admins.map((x) => x)),
        "coordinators": coordinators == null ? null : new List<dynamic>.from(coordinators.map((x) => x)),
        "members": members == null ? null : new List<dynamic>.from(members.map((x) => x)),
        "protected": protected == null ? null : protected,
        "parent_timebank_id": parentTimebankId == null ? null : parentTimebankId,
        "children": children == null ? null : new List<dynamic>.from(children.map((x) => x)),
        "balance": balance == null ? null : balance,
    };
}