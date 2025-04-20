class SelectedSpeakerTimeDetails {
  int? prepTime;
  double? speakingTime;

  SelectedSpeakerTimeDetails({
    this.prepTime,
    this.speakingTime,
  });

  factory SelectedSpeakerTimeDetails.fromMap(Map<dynamic, dynamic> json) =>
      SelectedSpeakerTimeDetails(
        prepTime: json["prepTime"] == null ? null : json["prepTime"],
        speakingTime: json["speakingTime"] == null
            ? null
            : double.parse(json["speakingTime"].toString()),
      );

  Map<String, dynamic> toMap() => {
        "prepTime": prepTime == null ? null : prepTime,
        "speakingTime": speakingTime == null ? null : speakingTime,
      };
}
