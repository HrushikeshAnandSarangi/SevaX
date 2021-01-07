import 'package:cloud_firestore/cloud_firestore.dart';

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
  static const String offers = 'offers';
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

class _CollectionNames {
  final String notifications = 'notifications';
  final String requests = 'requests';
  final String cards = 'cards';
  final String chats = 'chatsnew';
  final String communities = 'communities';
  final String csvFiles = 'csv_files';
  final String invitations = 'invitations';
  final String transactions = 'transactions';
  final String donations = 'donations';
  final String timebank = 'timebanknew';
  final String users = 'users';
}

class CollectionRef {
  static final _CollectionNames _collectionNames = _CollectionNames();
  static final Firestore _firestore = Firestore.instance;
  static final CollectionReference timebank =
      _firestore.collection(_collectionNames.timebank);

  static final CollectionReference notifications =
      _firestore.collection(_collectionNames.notifications);

  static final CollectionReference requests =
      _firestore.collection(_collectionNames.requests);

  static final CollectionReference cards =
      _firestore.collection(_collectionNames.cards);

  static final CollectionReference chatsRef =
      _firestore.collection(_collectionNames.chats);

  static final CollectionReference communities =
      _firestore.collection(_collectionNames.communities);

  static final CollectionReference csvFiles =
      _firestore.collection(_collectionNames.csvFiles);

  static final CollectionReference invitations =
      _firestore.collection(_collectionNames.invitations);

  static final CollectionReference transactions =
      _firestore.collection(_collectionNames.transactions);

  static final CollectionReference donations =
      _firestore.collection(_collectionNames.donations);

  static final CollectionReference users =
      _firestore.collection(_collectionNames.users);
}
