class ReviewModel {
  double? ratings;
  String? req_Id;
  String? comments;
  String? user_id;

  String toString() {
    return "Ratings ${ratings} \n" +
        "RequestId ${req_Id} \n" +
        "Comments ${comments} \n" +
        "UserID ${user_id} \n" +
        "Ratings ${ratings} \n";
  }
}
