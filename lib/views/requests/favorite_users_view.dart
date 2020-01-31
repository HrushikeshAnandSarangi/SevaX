
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;

import '../core.dart';


enum FavoriteUserStatus {LOADING,LOADED,EMPTY}

class FavoriteUsers extends StatefulWidget {
  final String timebankId;
  final String requestModelId;
  final String sevaUserId;


  FavoriteUsers({@required this.timebankId, this.requestModelId, this.sevaUserId, });

  @override
  _FavoriteUsersState createState() => _FavoriteUsersState();


}
enum RequestUserStatus{INVITE, INVITED,APPROVED,REJECTED}

class _FavoriteUsersState extends State<FavoriteUsers> {

  final _firestore = Firestore.instance;

  var validItems;
  bool isAdmin = false;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();
  static const String Invite = "Invite";
  static const String Invited = "Invited";
  static const String Approved = "Approved";
  static const String Rejected = "Rejected";

  List<UserModel> users = [];
  FavoriteUserStatus userStatus = FavoriteUserStatus.LOADING;
  BuildContext dialogLoadingContext;
   RequestModel requestModel;



  @override
  void initState() {
    super.initState();
    // print("timmeeeee   ${timebank.model.id}");

    if (timebank.model.admins.contains(widget.sevaUserId)) {
      isAdmin = true;
    }

    if (isAdmin) {
      //   print('admin is true ');
      _firestore
          .collection("users")
          .where(
        'favoriteByTimeBank',
        arrayContains: timebank.model.id,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
              if (users == null) users = List();

              querysnapshot.documents.forEach(
                (DocumentSnapshot user) =>
                users.add(
                  UserModel.fromMap(
                    user.data,
                  ),
                ),
          );

          if (users.isEmpty) {
            userStatus = FavoriteUserStatus.EMPTY;
          } else {
            userStatus = FavoriteUserStatus.LOADED;
          }
          print('users ${users.toString()}');



          setState(() {});
        },
      );
    } else {
      //    print('admin is false ');
      _firestore
          .collection("users")

          .where(
        'favoriteByMember',
        arrayContains: widget.sevaUserId,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
              if (users == null) users = List();

              querysnapshot.documents.forEach(
                (DocumentSnapshot user) =>
                users.add(
                  UserModel.fromMap(
                    user.data,
                  ),
                ),
          );

          if (users.isEmpty) {
            userStatus = FavoriteUserStatus.EMPTY;
          } else {
            userStatus = FavoriteUserStatus.LOADED;
          }

         setState(() {});
        },
      );
    }
  }


  Future<void> getRequestModel() async {
    requestModel = await  FirestoreManager.getRequestFutureById(requestId: widget.requestModelId);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getRequestModel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (userStatus == FavoriteUserStatus.LOADING) {
      return Center(child: CircularProgressIndicator());
    } else if (userStatus == FavoriteUserStatus.EMPTY) {
      return Center(child: Text('No user found'));
    } else {
      return
        ListView.builder(
          shrinkWrap: true,
          itemCount: users.length,
          itemBuilder: (context, index) {


            return RequestCardWidget(
              userModel: users[index],
              requestModel: requestModel,
              timebankModel: timebank.model,
              isFavorite: true,
              cameFromInvitedUsersPage: false,
            );
          },
        );
    }
  }



}









