class UserModel {
  String id;
  String fullName;
  String emailId;
  String bio;
  String timezone;
  List<String> skills;
  List<String> interests;
  List<String> timebanks;
  List<String> projects;
  String photoUrl;
  List<Wallet> wallet;

  UserModel({
    this.id,
    this.fullName,
    this.emailId,
    this.bio,
    this.timezone,
    this.skills,
    this.interests,
    this.timebanks,
    this.projects,
    this.photoUrl,
    this.wallet,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) => new UserModel(
        id: json["id"] == null ? null : json["id"],
        fullName: json["full_name"] == null ? null : json["full_name"],
        emailId: json["email_id"] == null ? null : json["email_id"],
        bio: json["bio"] == null ? null : json["bio"],
        timezone: json["timezone"] == null ? null : json["timezone"],
        skills: json["skills"] == null
            ? null
            : new List<String>.from(json["skills"].map((x) => x)),
        interests: json["interests"] == null
            ? null
            : new List<String>.from(json["interests"].map((x) => x)),
        timebanks: json["timebanks"] == null
            ? null
            : new List<String>.from(json["timebanks"].map((x) => x)),
        projects: json["projects"] == null
            ? null
            : new List<String>.from(json["projects"].map((x) => x)),
        photoUrl: json["photo_url"] == null ? null : json["photo_url"],
        wallet: json["wallet"] == null
            ? null
            : new List<Wallet>.from(
                json["wallet"].map((x) => Wallet.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "full_name": fullName == null ? null : fullName,
        "email_id": emailId == null ? null : emailId,
        "bio": bio == null ? null : bio,
        "timezone": timezone == null ? null : timezone,
        "skills": skills == null
            ? null
            : new List<dynamic>.from(skills.map((x) => x)),
        "interests": interests == null
            ? null
            : new List<dynamic>.from(interests.map((x) => x)),
        "timebanks": timebanks == null
            ? null
            : new List<dynamic>.from(timebanks.map((x) => x)),
        "projects": projects == null
            ? null
            : new List<dynamic>.from(projects.map((x) => x)),
        "photo_url": photoUrl == null ? null : photoUrl,
        "wallet": wallet == null
            ? null
            : new List<dynamic>.from(wallet.map((x) => x.toMap())),
      };
}

class Wallet {
  String rootTimebankId;
  double balance;

  Wallet({
    this.rootTimebankId,
    this.balance,
  });

  factory Wallet.fromMap(Map<String, dynamic> json) => new Wallet(
        rootTimebankId:
            json["root_timebank_id"] == null ? null : json["root_timebank_id"],
        balance: json["balance"] == null ? null : json["balance"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "root_timebank_id": rootTimebankId == null ? null : rootTimebankId,
        "balance": balance == null ? null : balance,
      };
}
