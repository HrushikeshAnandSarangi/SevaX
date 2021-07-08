import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/transaction_model.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/helpers/configuration_check.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';

import '../../app_config.dart';
import '../resources/repository.dart';

class CommunityFindBloc {
  final _repository = Repository();
  final _communitiesFetcher = PublishSubject<CommunityListModel>();
  final _timebanksFetcher = PublishSubject<TimebankListModel>();
  final searchOnChange = BehaviorSubject<String>();

  Stream<CommunityListModel> get allCommunities => _communitiesFetcher.stream;
  Stream<TimebankListModel> get allSiblingTimebanks => _timebanksFetcher.stream;

  fetchCommunities(name) async {
    CommunityListModel communityListModel = CommunityListModel();
    communityListModel.loading = true;
    _communitiesFetcher.sink.add(communityListModel);
    communityListModel =
        await _repository.searchCommunityByName(name, communityListModel);
    communityListModel.loading = false;
    _communitiesFetcher.sink.add(communityListModel);
  }

  searchTimebankSiblingsByParentId(id, timebank) async {
    TimebankListModel timebankListModel = TimebankListModel();
    timebankListModel.loading = true;
    _timebanksFetcher.sink.add(timebankListModel);
    timebankListModel = await _repository.searchTimebankSiblingsByParentId(
        id, timebankListModel);
    timebankListModel.loading = false;
    timebankListModel.timebanks.insert(0, timebank);
    _timebanksFetcher.sink.add(timebankListModel);
  }

  dispose() {
    _communitiesFetcher.close();
    searchOnChange.close();
  }
}

class TimebankListModel {
  List<TimebankModel> timebanks = [];
  bool loading = false;
  TimebankListModel();

  void add(community) {
    this.timebanks.add(community);
  }

  void removeall() {
    this.timebanks = [];
  }

  List<TimebankModel> get getTimebanks => timebanks;
}

class VolunteerFindBloc {
  final _repository = Repository();
  final _usersFetcher = PublishSubject<UserListModel>();
  final searchOnChange = BehaviorSubject<String>();

  Stream<UserListModel> get allUsers => _usersFetcher.stream;

  fetchUsers(name) async {
    UserListModel userListModel = UserListModel();
    // userListModel.loading = true;
    _usersFetcher.sink.add(userListModel);
    userListModel = await _repository.searchUserByName(name, userListModel);
    // userListModel.loading = false;
    _usersFetcher.sink.add(userListModel);
  }

  dispose() {
    _usersFetcher.close();
    searchOnChange.close();
  }
}

class CommunityCreateEditController {
  CommunityModel community = CommunityModel({});
  TimebankModel timebank = TimebankModel({});
  UserModel loggedinuser;
  List<TimebankModel> timebanks = [];
  String selectedAddress;
  String timebankAvatarURL = null;
  List addedMembersId = [];
  List addedMembersFullname = [];
  List addedMembersPhotoURL = [];
  bool loading = false;
  HashMap selectedUsers = HashMap();
  CommunityModel selectedCommunity;

  CommunityCreateEditController() {
    timebank.preventAccedentalDelete = true;
  }

  UpdateCommunityDetails(user, timebankimageurl, location, coverUrl) {
    this.community.id = Utils.getUuid();
    this.community.logo_url = timebankimageurl;
    this.community.cover_url = coverUrl;
    this.community.created_at =
        DateTime.now().millisecondsSinceEpoch.toString();
    this.community.created_by = user.sevaUserID;
    this.community.created_at =
        DateTime.now().millisecondsSinceEpoch.toString();
    this.community.primary_email = user.email;
    this.community.admins = [user.sevaUserID];
    this.community.organizers = [user.sevaUserID];
    this.community.location = location;
    this.community.isCreatedFromWeb = false;
  }

  UpdateTimebankDetails(user, timebankimageurl, coverUrl) {
    this.timebank.updateValueByKey('id', Utils.getUuid());
    this.timebank.updateValueByKey('name', this.community.name);
    this.timebank.updateValueByKey('creatorId', user.sevaUserID);
    this.timebank.updateValueByKey('photoUrl', timebankimageurl);
    this.timebank.updateValueByKey('coverUrl', coverUrl);
    this
        .timebank
        .updateValueByKey('createdAt', DateTime.now().millisecondsSinceEpoch);
    this.timebank.updateValueByKey('admins', [user.sevaUserID].cast<String>());
    this.timebank.updateValueByKey(
        'managedCreatorIds', [user.sevaUserID].cast<String>());
    this
        .timebank
        .updateValueByKey('organizers', [user.sevaUserID].cast<String>());
    this.timebank.updateValueByKey('coordinators', [].cast<String>());
    this.timebank.updateValueByKey('members', [user.sevaUserID].cast<String>());
    this.timebank.updateValueByKey('children', [].cast<String>());
    this.timebank.updateValueByKey('balance', 0.0);
    this.timebank.updateValueByKey('protected', this.timebank.protected);
    this.timebank.updateValueByKey('private', this.timebank.private);
    this.timebank.updateValueByKey('sponsors', this.timebank.sponsors);
    this.timebank.updateValueByKey('emailId', user.email);
    this
        .timebank
        .updateValueByKey('parentTimebankId', this.timebank.parentTimebankId);
    this
        .timebank
        .updateValueByKey('rootTimebankId', FlavorConfig.values.timebankId);
    this.timebank.updateValueByKey('community_id', this.community.id);
    this.timebank.updateValueByKey('address', this.timebank.address);
    this.timebank.updateValueByKey(
        'preventAccedentalDelete', this.timebank.preventAccedentalDelete);
    this.timebank.updateValueByKey('location',
        location == null ? GeoFirePoint(40.754387, -73.984291) : location);
    this.timebank.updateValueByKey(
        'timebankConfigurations', getNeighbourhoodPlanConfigurationModel());
  }

  updateUserDetails(userdata) {
    this.loggedinuser = userdata;
  }

  selectCommunity(CommunityModel community) {
    this.selectedCommunity = community;
  }
}

class UserModelController {
  var loggedinuser = UserModel();

  updateLoggedInUserDetails(UserModel userdata) {
    this.loggedinuser = userdata;
  }
}

class UserBloc {
  final _userController = BehaviorSubject<UserModelController>();
  Stream<UserModelController> get getLoggedInUser => _userController.stream;
  UserBloc() {
    _userController.add(UserModelController());
  }
  updateUserDetails(UserModel userdata) {
    var userc = this._userController.value;
    userc.updateLoggedInUserDetails(userdata);
    _userController.add(userc);
  }
}

class TransactionBloc {
  final _repository = Repository();
  final _transactionController = PublishSubject<TransactionController>();

  Stream<TransactionController> get trasactionController =>
      _transactionController.stream;

  handleApprovedTransaction(
      isApproved, from, to, timebankid, type, credits) async {
    if (isApproved) {
      // update user to user transaction balances
      // TODO burhan suggest to do this in cloud function; current is a background task.
      if (type == RequestMode.PERSONAL_REQUEST) {
        // debit from user
        Query query = CollectionRef.users.where('sevauserid', isEqualTo: from);
        QuerySnapshot snapshot = await query.get();
        DocumentSnapshot document =
            snapshot.docs != null && snapshot.docs.length > 0
                ? snapshot.docs.first
                : null;
        if (document != null)
          CollectionRef.users.doc(document.id).set({
            AppConfig.isTestCommunity
                    ? 'sandboxCurrentBalance'
                    : 'currentBalance':
                FieldValue.increment(-(num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
        // credit to user
        query = CollectionRef.users.where('sevauserid', isEqualTo: to);
        snapshot = await query.get();
        document = snapshot.docs != null && snapshot.docs.length > 0
            ? snapshot.docs.first
            : null;
        if (document != null)
          CollectionRef.users.doc(document.id).set({
            AppConfig.isTestCommunity
                    ? 'sandboxCurrentBalance'
                    : 'currentBalance':
                FieldValue.increment(num.parse(credits.toStringAsFixed(2)))
          }, SetOptions(merge: true));
      } else if (type == RequestMode.TIMEBANK_REQUEST) {
        // debit from timebank
        Query query = CollectionRef.timebank.where('id', isEqualTo: timebankid);
        QuerySnapshot snapshot = await query.get();
        DocumentSnapshot document =
            snapshot.docs?.length > 0 && snapshot.docs != null
                ? snapshot.docs.first
                : null;
        if (document != null)
          CollectionRef.timebank.doc(document.id).set({
            'balance':
                FieldValue.increment(-(num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
        // credit to user
        query = CollectionRef.users.where('sevauserid', isEqualTo: to);
        snapshot = await query.get();
        document = snapshot.docs != null && snapshot.docs.length > 0
            ? snapshot.docs.first
            : null;
        if (document != null)
          CollectionRef.users.doc(document.id).set({
            AppConfig.isTestCommunity
                    ? 'sandboxCurrentBalance'
                    : 'currentBalance':
                FieldValue.increment(num.parse(credits.toStringAsFixed(2)))
          }, SetOptions(merge: true));
      } else if (type == 'REQUEST_CREATION_TIMEBANK_FILL_CREDITS') {
        // credit request hours to timebank
        Query query = CollectionRef.timebank.where('id', isEqualTo: timebankid);
        QuerySnapshot snapshot = await query.get();
        DocumentSnapshot document =
            snapshot.docs != null && snapshot.docs?.length > 0
                ? snapshot.docs.first
                : null;
        if (document != null)
          CollectionRef.timebank.doc(document.id).set({
            'balance':
                FieldValue.increment((num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
      } else if (type == "USER_DONATE_TOTIMEBANK") {
        // debit from timebank
        Query query = CollectionRef.timebank.where('id', isEqualTo: timebankid);
        QuerySnapshot snapshot = await query.get();
        DocumentSnapshot document =
            snapshot.docs != null && snapshot.docs.length > 0
                ? snapshot.docs.first
                : null;
        if (document != null)
          CollectionRef.timebank.doc(document.id).set({
            'balance':
                FieldValue.increment(num.parse(credits.toStringAsFixed(2)))
          }, SetOptions(merge: true));
        // credit to user

        query = CollectionRef.users.where('sevauserid', isEqualTo: from);
        snapshot = await query.get();
        document = snapshot.docs != null && snapshot.docs.length > 0
            ? snapshot.docs.first
            : null;
        if (document != null)
          CollectionRef.users.doc(document.id).set({
            AppConfig.isTestCommunity
                    ? 'sandboxCurrentBalance'
                    : 'currentBalance':
                FieldValue.increment(-(num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
      } else if (type == "ADMIN_DONATE_TOUSER") {
        // debit from timebank
        Query query = CollectionRef.timebank.where('id', isEqualTo: timebankid);
        QuerySnapshot snapshot = await query.get();
        DocumentSnapshot document =
            snapshot.docs != null && snapshot.docs.length > 0
                ? snapshot.docs.first
                : null;
        if (document != null)
          CollectionRef.timebank.doc(document.id).set({
            'balance':
                FieldValue.increment(-(num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
        // credit to user
        query = CollectionRef.users.where('sevauserid', isEqualTo: to);
        snapshot = await query.get();
        document = snapshot.docs != null && snapshot.docs.length > 0
            ? snapshot.docs.first
            : null;
        if (document != null)
          CollectionRef.users.doc(document.id).set({
            AppConfig.isTestCommunity
                    ? 'sandboxCurrentBalance'
                    : 'currentBalance':
                FieldValue.increment((num.parse(credits.toStringAsFixed(2))))
          }, SetOptions(merge: true));
      }
    }
  }

  void createNewTransaction(
    from,
    to,
    timestamp,
    credits,
    isApproved,
    type,
    typeid,
    timebankid, {
    @required String communityId,
    @required String fromEmailORId,
    @required String toEmailORId,
  }) async {
    TransactionModel transactionModel = TransactionModel(
      communityId: communityId,
      from: from,
      to: to,
      timestamp: timestamp,
      credits: num.parse(credits.toStringAsFixed(2)),
      isApproved: isApproved,
      type: type,
      typeid: typeid,
      timebankid: timebankid,
      transactionbetween: [from, to],
      toEmail_Id: toEmailORId,
      fromEmail_Id: fromEmailORId,
      liveMode: !AppConfig.isTestCommunity,
    );

    //commented because transaction and balance handling will be done in backend

//    await handleApprovedTransaction(isApproved, from, to, timebankid, type,
//        num.parse(credits.toStringAsFixed(2)));
    await CollectionRef.transactions
        .doc()
        .set(transactionModel.toMap(), SetOptions(merge: true));
  }

//   updateNewTransaction(
//     from,
//     to,
//     timestamp,
//     credits,
//     isApproved,
//     type,
//     typeid,
//     timebankid,
//     id, {
//     @required String communityId,
//     @required String fromEmailORId,
//     @required String toEmailORId,
//   }) async {
//     TransactionModel prevtransactionModel;
//     TransactionModel transactionModel = TransactionModel(
//       from: from,
//       to: to,
//       timestamp: timestamp,
//       credits: num.parse(credits.toStringAsFixed(2)),
//       isApproved: isApproved,
//       type: type.toString(),
//       typeid: typeid,
//       timebankid: timebankid,
//       transactionbetween: [from, to],
//       communityId: communityId,
//       toEmail_Id: toEmailORId,
//       fromEmail_Id: fromEmailORId,
//     );
//     if (id) {
//       var document = await CollectionRef
//           .transactions
//           .doc(id)
//           .get();
//       prevtransactionModel = TransactionModel.fromMap(document.data());
//       if (document.data() != null) {
//         await CollectionRef
//             .transactions
//             .doc(document.id)
//             .set(transactionModel.toMap(), merge: true);
//         if (!prevtransactionModel.isApproved && isApproved) {
//           //commented because transaction and balance handling will be done in backend

// //          await handleApprovedTransaction(isApproved, from, to, timebankid,
// //              type, num.parse(credits.toStringAsFixed(2)));
//         }
//       }
//     } else {
//       Query query = CollectionRef
//           .transactions
//           .where('typeid', isEqualTo: typeid)
//           .where('from', isEqualTo: from)
//           .where('to', isEqualTo: to);
//       QuerySnapshot snapshot = await query.get();
//       DocumentSnapshot document =
//           snapshot.docs?.length > 0 && snapshot.docs != null
//               ? snapshot.docs.first
//               : null;
//       if (document != null)
//         prevtransactionModel = TransactionModel.fromMap(document.data());
//       if (!prevtransactionModel.isApproved && isApproved) {
//         //commented because transaction and balance handling will be done in backend

// //        await handleApprovedTransaction(isApproved, from, to, timebankid, type,
// //            num.parse(credits.toStringAsFixed(2)));
//       }
//       return await CollectionRef
//           .transactions
//           .doc(document.id)
//           .set(transactionModel.toMap(), merge: true);
//     }
//   }

  dispose() {
    _transactionController.close();
  }
}

class TransactionController {
  TimebankModel selectedtimebank;
  List<TransactionModel> userTransactions = [];
  List<TransactionModel> timebankTransactions = [];
  TransactionController() {}

  setUserTransactionsList(user_transactions) {
    this.userTransactions = user_transactions;
  }

  setTimebankTransactionsList(timebank_transactions) {
    this.timebankTransactions = timebank_transactions;
  }
}

class TimebankController {
  TimebankModel selectedtimebank;
  List<RequestModel> requests = [];
  RequestModel selectedrequest;
  List<UserModel> invitedUsersForRequest = [];
  bool isAdmin = false;

  TimebankController() {}

  setRequestList(requests) {
    this.requests = requests;
  }

  setSelectedRequest(RequestModel request) {
    this.selectedrequest = request;
  }

  setSelectedTimebank(timebank) {
    this.selectedtimebank = timebank;
  }

  setInvitedUsersDataForRequest(usersListData) {
    this.invitedUsersForRequest = usersListData;
  }

  setIsAdmin(isAdminStatus) {
    this.isAdmin = isAdminStatus;
  }
}

class TimeBankBloc {
  final _repository = Repository();
  final _timebankController = BehaviorSubject<TimebankController>();
  Stream<TimebankController> get timebankController =>
      _timebankController.stream;

  TimeBankBloc() {
    _timebankController.add(TimebankController());
  }

  updateInvitedUsersForRequest(requestID, sevauserid, email) async {
    var result = await _repository.updateInvitedUsersForRequest(
        requestID, sevauserid, email);
  }

  setIsAdmin(isAdminStatus) {
    _timebankController.value.setIsAdmin(isAdminStatus);
    _timebankController.add(_timebankController.value);
  }

//  getSelectedRequestInvitedUsersData(usersids) async {
//    // TODO - get users from request
//    var usersdata = await _repository.getUsersFromRequest(usersids);
//    _timebankController.value.setInvitedUsersDataForRequest(usersdata);
//    _timebankController.add(_timebankController.value);
//  }

//  getRequestsFromTimebankId(String timebankId) async {
//    var requests = await _repository.getRequestsFromTimebankId(timebankId);
//    _timebankController.value.setRequestList(requests);
//    _timebankController.add(_timebankController.value);
//  }

  getRequestsStreamFromTimebankId(String timebankId, String userId) async {
    _repository
        .getRequestsStreamFromTimebankId(timebankId, userId)
        .listen((requests) {
      _timebankController.value.setRequestList(requests);
      _timebankController.add(_timebankController.value);
    });
  }

  setSelectedRequest(request) {
    _timebankController.value.setSelectedRequest(request);
    _timebankController.add(_timebankController.value);
  }

  setSelectedTimeBankDetails(timebank) {
    _timebankController.value.setSelectedTimebank(timebank);
    _timebankController.add(_timebankController.value);
  }

  setInvitedUsersData(requestID) async {
    var usersResults = await _repository.getUsersFromRequest(requestID);
    _timebankController.value.setInvitedUsersDataForRequest(usersResults);
    _timebankController.add(_timebankController.value);
  }

  dispose() {
    _timebankController.close();
  }
}

class CommunityCreateEditBloc {
  final _repository = Repository();
  final _createEditCommunity = BehaviorSubject<CommunityCreateEditController>();

  Stream<CommunityCreateEditController> get createEditCommunity =>
      _createEditCommunity.stream;

  CommunityCreateEditBloc() {
    _createEditCommunity.add(CommunityCreateEditController());
  }
  getChildTimeBanks(BuildContext context) async {
    var community = this._createEditCommunity.value;
    var communityid = userBloc.getLoggedInUser;

    var timebanks = await _repository.getSubTimebanksForUser(
        SevaCore.of(context).loggedInUser.currentCommunity);
    community.timebanks = timebanks;
    _createEditCommunity.add(community);
  }

  onChange(community) {
    _createEditCommunity.add(community);
  }

  dispose() {
    _createEditCommunity.close();
  }

  updateUserDetails(userdata) {
    var community = this._createEditCommunity.value;
    community.updateUserDetails(userdata);
    _createEditCommunity.add(community);
  }

  selectCommunity(CommunityModel currentCommunity) {
    var community = this._createEditCommunity.value;
    community.selectCommunity(currentCommunity);
    _createEditCommunity.add(community);
  }

  getCommunityPrimaryTimebank() async {
    var community = this._createEditCommunity.value;
    var timebank = await _repository
        .getTimebankDetailsById(community.selectedCommunity.primary_timebank);
    community.timebank = timebank;
    _createEditCommunity.add(community);
  }

  createCommunity(
    CommunityCreateEditController community,
    UserModel user,
  ) async {
    // create a community flow;
    await _repository.createCommunityByName(community.community);
    // create a timebank flow;
    await _repository.createTimebankById(community.timebank);
    // update user to the timebank.
    await _repository.updateUserWithTimeBankIdCommunityId(
      user,
      community.timebank.id,
      community.community.id,
    );
  }

  updateUser(timebank) async {
    var tm = TimebankModel(timebank);
    var communitytemp =
        await _repository.getCommunityDetailsByCommunityIdrepo(tm.communityId);

    await _repository.updateCommunityWithUserId(
      communitytemp.id,
      this._createEditCommunity.value.loggedinuser.sevaUserID,
    );

    await _repository.updateUserWithTimeBankIdCommunityId(
        this._createEditCommunity.value.loggedinuser, tm.id, communitytemp.id);
  }

  Future VerifyTimebankWithCode(
    String code,
    func,
    String communnityId,
  ) async {
    // get the timebanks with the code.
    CollectionRef.timebankCodes
        .where("timebankCode", isEqualTo: code)
        .where("communityId", isEqualTo: communnityId)
        .get()
        .then((QuerySnapshot snapshot) async {
      if (snapshot.docs.length > 0) {
        // timabnk code exists , check its validity

        snapshot.docs.forEach((f) async {
          if (DateTime.now().millisecondsSinceEpoch > f.data()['validUpto']) {
            await func("code_expired");
          } else {
            //code matche and is alive
            // add to usersOnBoarded
            if ((f.data()['usersOnboarded'] ?? []).contains(
                this._createEditCommunity.value.loggedinuser.sevaUserID)) {
              func("code_already_redeemed");
            } else {
              CollectionRef.timebankCodes.doc(f.id).update({
                'usersOnboarded': FieldValue.arrayUnion(
                    [this._createEditCommunity.value.loggedinuser.sevaUserID])
              });

              CollectionRef.timebank.doc(f.data()['timebankId']).update({
                'members': FieldValue.arrayUnion(
                    [this._createEditCommunity.value.loggedinuser.sevaUserID])
              });

              CollectionRef.timebank
                  .doc(f.data()['timebankId'])
                  .get()
                  .then((DocumentSnapshot timeBank) async {
                updateUser(timeBank.data);
                await func(timeBank.data()['name'].toString());
              });
            }
          }
        });
      } else {
        func("no_code");
      }
    });
  }
}

final timeBankBloc = TimeBankBloc();
final createEditCommunityBloc = CommunityCreateEditBloc();
final communityBloc = CommunityFindBloc();
final userBloc = UserBloc();
final volunteerUsersBloc = VolunteerFindBloc();
final transactionBloc = TransactionBloc();
