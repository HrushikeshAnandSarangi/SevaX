class GetUserVerified<UserVerify> {
  static bool verify(
          {String? userId,
          String? creatorId,
          List<String>? admins,
          List<String>? organizers}) =>
      creatorId == userId ||
              admins!.contains(userId) ||
              organizers!.contains(userId)
          ? true
          : false;
}
