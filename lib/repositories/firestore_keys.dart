import 'package:cloud_firestore/cloud_firestore.dart';

class _CollectionNames {
  final String notifications = 'notifications';
  final String timeline = 'timeline';
  final String requests = 'requests';
  final String feeds = 'news';
  final String projects = 'projects';
  final String cards = 'cards';
  final String chats = 'chatsnew';
  final String communities = 'communities';
  final String csvFiles = 'csv_files';
  final String invitations = 'invitations';
  final String transactions = 'transactions';
  final String donations = 'donations';
  final String timebank = 'timebanknew';
  final String users = 'users';
  final String entryExitLogs = 'entryExitLogs';
  final String joinRequests = 'join_requests';
  final String manualTimeClaims = 'manualTimeClaims';
  final String offers = 'offers';
  final String communityCategories = 'communityCategories';
  final String reviews = 'reviews';
  final String donationCategories = 'donationCategories';
  final String interests = 'interests';
  final String skills = 'skills';
  final String reportedUsersList = 'reported_users_list';
  final String timebankCodes = 'timebankCodes';
  final String remoteConfigurations = 'remoteConfigurations';
  final String softDeleteRequests = 'softDeleteRequests';
  final String claimedRequestStatus = 'claimedRequestStatus';
  final String projectTemplates = 'project_templates';
  final String requestCategories = 'requestCategories';
  final String agreementTemplates = 'agreementTemplates';
  final String borrowItems = 'borrowItems';
  final String amenities = 'amenities';
  final String lendingItems = 'lendingItems';
  final String borrowRequestAcceptors = 'borrowRequestAcceptors';
  final String lendingOfferAcceptors = 'lendingOfferAcceptors';
}

class CollectionRef {
  static final _CollectionNames _collectionNames = _CollectionNames();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference timebank =
      _firestore.collection(_collectionNames.timebank);

  static final CollectionReference notifications =
      _firestore.collection(_collectionNames.notifications);

  static final CollectionReference requests =
      _firestore.collection(_collectionNames.requests);

  static final CollectionReference feeds =
      _firestore.collection(_collectionNames.feeds);

  static final CollectionReference projects =
      _firestore.collection(_collectionNames.projects);

  static final CollectionReference claimedRequestStatus =
      _firestore.collection(_collectionNames.claimedRequestStatus);

  static final CollectionReference projectTemplates =
      _firestore.collection(_collectionNames.projectTemplates);

  static final CollectionReference requestCategories =
      _firestore.collection(_collectionNames.requestCategories);

  static final CollectionReference softDeleteRequests =
      _firestore.collection(_collectionNames.softDeleteRequests);

  static final CollectionReference offers =
      _firestore.collection(_collectionNames.offers);

  static final CollectionReference cards =
      _firestore.collection(_collectionNames.cards);

  static final CollectionReference chats =
      _firestore.collection(_collectionNames.chats);

  static final CollectionReference donationCategories =
      _firestore.collection(_collectionNames.donationCategories);

  static final CollectionReference communities =
      _firestore.collection(_collectionNames.communities);

  static final CollectionReference interests =
      _firestore.collection(_collectionNames.interests);

  static final CollectionReference timebankCodes =
      _firestore.collection(_collectionNames.timebankCodes);

  static final CollectionReference skills =
      _firestore.collection(_collectionNames.skills);

  static final CollectionReference csvFiles =
      _firestore.collection(_collectionNames.csvFiles);

  static final CollectionReference remoteConfigurations =
      _firestore.collection(_collectionNames.remoteConfigurations);

  static final CollectionReference invitations =
      _firestore.collection(_collectionNames.invitations);

  static final CollectionReference transactions =
      _firestore.collection(_collectionNames.transactions);

  static final CollectionReference donations =
      _firestore.collection(_collectionNames.donations);

  static final CollectionReference communityCategories =
      _firestore.collection(_collectionNames.communityCategories);

  static final CollectionReference manualTimeClaims =
      _firestore.collection(_collectionNames.manualTimeClaims);

  static final CollectionReference agreementTemplates =
      _firestore.collection(_collectionNames.agreementTemplates);

  static final CollectionReference users =
      _firestore.collection(_collectionNames.users);

  static final CollectionReference reportedUsersList =
      _firestore.collection(_collectionNames.reportedUsersList);

  static final CollectionReference joinRequests =
      _firestore.collection(_collectionNames.joinRequests);

  static Query notificationGroup =
      _firestore.collectionGroup(_collectionNames.notifications);

  static CollectionReference reviews =
      _firestore.collection(_collectionNames.reviews);

  static CollectionReference entryExitLogs(String path) => _firestore
      .collection(_collectionNames.timebank)
      .doc(path)
      .collection(_collectionNames.entryExitLogs);

  static CollectionReference timebankNotification(String timebankId) =>
      _firestore
          .collection(_collectionNames.timebank)
          .doc(timebankId)
          .collection(_collectionNames.notifications);

  static CollectionReference userNotification(String email) => _firestore
      .collection(_collectionNames.users)
      .doc(email)
      .collection(_collectionNames.notifications);

  static final CollectionReference borrowItems =
      _firestore.collection(_collectionNames.borrowItems);

  static Query timelineGroup =
      _firestore.collectionGroup(_collectionNames.timeline);

  static WriteBatch get batch => _firestore.batch();
  static final CollectionReference amenities =
      _firestore.collection(_collectionNames.amenities);
  static final CollectionReference lendingItems =
      _firestore.collection(_collectionNames.lendingItems);
  static CollectionReference borrowRequestAcceptors(String requestId) =>
      _firestore
          .collection(_collectionNames.requests)
          .doc(requestId)
          .collection(_collectionNames.borrowRequestAcceptors);
  static CollectionReference lendingOfferAcceptors(String offerId) => _firestore
      .collection(_collectionNames.offers)
      .doc(offerId)
      .collection(_collectionNames.lendingOfferAcceptors);
}
