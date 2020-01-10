import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/community_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import '../resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class CommunityFindBloc {
  final _repository = Repository();
  final _communitiesFetcher = PublishSubject<CommunityListModel>();
  final searchOnChange = new BehaviorSubject<String>();

  Observable<CommunityListModel> get allCommunities => _communitiesFetcher.stream;

  fetchCommunities(name) async {
    CommunityListModel communityListModel = CommunityListModel();
    communityListModel.loading = true;
    _communitiesFetcher.sink.add(communityListModel);
    communityListModel = await _repository.searchCommunityByName(name, communityListModel);
    communityListModel.loading = false;
    print(communityListModel.communities.length);
    _communitiesFetcher.sink.add(communityListModel);
  }

  dispose() {
    _communitiesFetcher.close();
    searchOnChange.close();
  }
}

class CommunityCreateEditController {
  CommunityModel community = CommunityModel({});
  TimebankModel timebank = new TimebankModel({});
  UserModel loggedinuser;
  List<TimebankModel> timebanks = [];
  String selectedAddress;
  String timebankAvatarURL = null;
  List addedMembersId = [];
  List addedMembersFullname = [];
  List addedMembersPhotoURL = [];
  bool loading  = false;
  HashMap selectedUsers = HashMap();
  CommunityModel selectedCommunity;

  CommunityCreateEditController() {
    print(timebank);
  }

  UpdateCommunityDetails(user, timebankimageurl) {
    this.community.id = Utils.getUuid();
    this.community.logo_url = timebankimageurl;
    this.community.created_at = DateTime.now().millisecondsSinceEpoch.toString();
    this.community.created_by = user.sevaUserID;
    this.community.created_at = DateTime.now().millisecondsSinceEpoch.toString();
    this.community.primary_email = user.email;
    this.community.admins = [user.sevaUserID];
  }

  UpdateTimebankDetails(user,  timebankimageurl, widget) {
    this.timebank.updateValueByKey('id',  Utils.getUuid());
    this.timebank.updateValueByKey('name', this.community.name);
    this.timebank.updateValueByKey('creatorId', user.sevaUserID);
    this.timebank.updateValueByKey('photoUrl', timebankimageurl);
    this.timebank.updateValueByKey('createdAt', DateTime.now().millisecondsSinceEpoch);
    this.timebank.updateValueByKey('admins', [user.sevaUserID].cast<String>());
    this.timebank.updateValueByKey('coordinators', [].cast<String>());
    this.timebank.updateValueByKey('members', [].cast<String>());
    this.timebank.updateValueByKey('children', [].cast<String>());
    this.timebank.updateValueByKey('balance', 0.0);
    this.timebank.updateValueByKey('protected', this.timebank.protected);
    this.timebank.updateValueByKey('parentTimebankId', widget.timebankId);
    this.timebank.updateValueByKey('rootTimebankId', FlavorConfig.values.timebankId);
    this.timebank.updateValueByKey('communityId', this.community.id);
    this.timebank.updateValueByKey('address', this.timebank.address);
    this.timebank.updateValueByKey('location', location == null ? GeoFirePoint(40.754387, -73.984291) : location);
  }

  updateUserDetails(userdata) {
    this.loggedinuser = userdata;
  }

  selectCommunity(CommunityModel community) {
    this.selectedCommunity = community;
  }
}

class CommunityCreateEditBloc {
  final _repository = Repository();
  final _createEditCommunity = BehaviorSubject<CommunityCreateEditController>();

  Observable<CommunityCreateEditController> get createEditCommunity => _createEditCommunity.stream;

  CommunityCreateEditBloc(){
    _createEditCommunity.add(CommunityCreateEditController());
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
  getChildTimeBanks() async{
    var community = this._createEditCommunity.value;
    var timebanks = await _repository.getSubTimebanksForUser(community.loggedinuser.currentCommunity);
    community.timebanks = timebanks;
    _createEditCommunity.add(community);
  }
  getCommunityPrimaryTimebank() async{
    var community = this._createEditCommunity.value;
    var timebank = await _repository.getTimebankDetailsById(community.selectedCommunity.primary_timebank);
    community.timebank = timebank;
    _createEditCommunity.add(community);
  }
  createCommunity(CommunityCreateEditController community, UserModel user) async {
    // create a community flow;
    await _repository.createCommunityByName(community.community);
    // create a timebank flow;
    await _repository.createTimebankById(community.timebank);
    // update user to the timebank.
    await _repository.updateUserWithTimeBankIdCommunityId(user, community.timebank.id, community.community.id);
  }
  Future VerifyTimebankWithCode(String code, func) async {
    // get the timebanks with the code.
    Firestore.instance
        .collection("timebankCodes")
        .where("timebankCode", isEqualTo: code)
        .getDocuments()
        .then((QuerySnapshot snapshot)  async {
      if (snapshot.documents.length > 0) {
        // timabnk code exists , check its validity
        snapshot.documents.forEach((f) async {
          if (DateTime.now().millisecondsSinceEpoch > f.data['validUpto']) {
            await func("Invalid");
          } else {
            //code matche and is alive
            // add to usersOnBoarded
            Firestore.instance
                .collection("timebankCodes")
                .document(f.documentID)
                .updateData({
              'usersOnboarded': FieldValue.arrayUnion(
                  [this._createEditCommunity.value.loggedinuser.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .updateData({
              'members': FieldValue.arrayUnion(
                  [this._createEditCommunity.value.loggedinuser.sevaUserID])
            });

            Firestore.instance
                .collection("timebanknew")
                .document(f.data['timebankId'])
                .get()
                .then((DocumentSnapshot timeBank) async {
              await func(timeBank.data['name'].toString());
            });
          }
        });
      } else {
        func("no_code");
      }
    });
  }
}
final createEditCommunityBloc = CommunityCreateEditBloc();
final communityBloc = CommunityFindBloc();
