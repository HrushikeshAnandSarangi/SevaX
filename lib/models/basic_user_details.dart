class BasicUserDetails {
  String? fullname;
  String? email;
  String? sevaUserID;
  String? photoURL;

  BasicUserDetails({
    this.fullname,
    this.email,
    this.sevaUserID,
    this.photoURL,
  });

  factory BasicUserDetails.fromMap(Map<dynamic, dynamic> json) =>
      BasicUserDetails(
        fullname: json["fullname"] == null ? null : json["fullname"],
        email: json["email"] == null ? null : json["email"],
        sevaUserID: json["sevaUserID"] == null ? null : json["sevaUserID"],
        photoURL: json["photoURL"] == null ? null : json["photoURL"],
      );

  Map<String, dynamic> toMap() => {
        "fullname": fullname == null ? null : fullname,
        "email": email == null ? null : email,
        "photoURL": photoURL == null ? null : photoURL,
        "sevaUserID": sevaUserID == null ? null : sevaUserID,
      };
}
