
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/utils/search_manager.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

enum FavoriteUserStatus {LOADING,LOADED,EMPTY}

class FavoriteUsers extends StatefulWidget {

  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;


  FavoriteUsers({@required this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _FavoriteUsersState createState() {
    // TODO: implement createState
    return _FavoriteUsersState();
  }

}

class _FavoriteUsersState extends State<FavoriteUsers> {
  final _firestore = Firestore.instance;

  var validItems;
  bool isAdmin = false;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();

  List<UserModel> users = [];
  FavoriteUserStatus userStatus = FavoriteUserStatus.LOADING;

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
        'favoriteByTimebank',
        arrayContains: timebank.model.id,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
          querysnapshot.documents.forEach(
                (DocumentSnapshot user) =>
                users.add(
                  UserModel.fromMap(
                    user.data,
                  ),
                ),
          );

          if(users.isEmpty)
          {
            userStatus = FavoriteUserStatus.EMPTY;
          }else{
            userStatus = FavoriteUserStatus.LOADED;
          }



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
          querysnapshot.documents.forEach(
                (DocumentSnapshot user) =>
                users.add(
                  UserModel.fromMap(
                    user.data,
                  ),
                ),
          );

          if(users.isEmpty)
          {
            userStatus = FavoriteUserStatus.EMPTY;
          }else{
            userStatus = FavoriteUserStatus.LOADED;
          }

          setState(() {});
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (userStatus == FavoriteUserStatus.LOADING) {
      return Center(child: CircularProgressIndicator());
    } else if (userStatus == FavoriteUserStatus.EMPTY) {
    return  Center(child: Text('No user found'));
    } else {
    return
      ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (context, index) {
          return RequestCardWidget(
            userModel: users[index],
            requestModel: widget.requestModel,
            timebankModel: timebank.model,
            isFavorite: true,
          );
        },
      );
  }
}

}

