enum Collections {
  cards,
  chatsnew,
  claimedRequestStatus,
  communities,
  csv_files,
  interests,
  invitations,
  join_requests,
  news,
  offers,
  project_templates,
  projects,
  remoteConfigurations,
  reported_users_list,
  requests,
  reviews,
  skills,
  softDeleteRequests,
  timebankCodes,
  timebanknew,
  transactions,
  users
}

class DBCollection {
  static const String notifications = 'notifications';
  static const String requests = 'requests';
  static const String cards = 'cards';
  static const String chats = 'chatsnew';
  static const String communities = 'communities';
  static const String csvFiles = 'csv_files';
  static const String invitations = 'invitations';
  static const String transactions = 'transactions';
  static const String donations = 'donations';
  static const String timebank = 'timebanknew';
  static const String users = 'users';
}

class DBCardsHelper {
  static getValue() {}
}
