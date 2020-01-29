import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/utils/common_timebank_model_singleton.dart';
import 'package:sevaexchange/views/requests/request_card_widget.dart';
//import 'package:smooth_star_rating/smooth_star_rating.dart';

enum PastHiredUserStatus {LOADING,LOADED,EMPTY}

class PastHiredUsersView extends StatefulWidget {
  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;

  PastHiredUsersView({@required this.timebankId, this.requestModel, this.sevaUserId});

  @override
  _PastHiredUsersViewState createState() {
    return _PastHiredUsersViewState();
  }
}

enum UserFavoriteStatus {Favorite,NotFavorite}

class _PastHiredUsersViewState extends State<PastHiredUsersView> {
  final _firestore = Firestore.instance;
  TimeBankModelSingleton timebank = TimeBankModelSingleton();
  List<UserModel> users = [];
  List<UserModel> favoriteUsers;
  bool isAdmin =false;
  PastHiredUserStatus userStatus = PastHiredUserStatus.LOADING;

  @override
  void initState() {
    super.initState();

    _firestore
        .collection("users")
        .where(
          "recommendedTimebank",
          arrayContains: widget.timebankId,
        )
        .getDocuments()
        .then(
      (QuerySnapshot querysnapshot) {
        querysnapshot.documents.forEach(
          (DocumentSnapshot user) => users.add(
            UserModel.fromMap(
              user.data,
            ),
          ),
        );
        if(users.isEmpty)
        {
          userStatus = PastHiredUserStatus.EMPTY;
        }else{
          userStatus = PastHiredUserStatus.LOADED;
        }

        setState(() {

        });
      },
    );



    if(timebank.model.admins.contains(widget.sevaUserId)){
      isAdmin =true;
    }

    print(" ---------called init 1");


    if(isAdmin){

      print(" ---------called init A1");

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

              print(" ---------called init AF1 ${querysnapshot.documents.length}");

              if (favoriteUsers == null) favoriteUsers = List();
              querysnapshot.documents.forEach((DocumentSnapshot user) => favoriteUsers.add(UserModel.fromDynamic(user.data)),);

        },
      );
    }else{

      print(" ---------called init M1");

      _firestore
          .collection("users")
          .where(
        'favoriteByMember',
        arrayContains: widget.sevaUserId,
      )
          .getDocuments()
          .then(
            (QuerySnapshot querysnapshot) {
              if (favoriteUsers == null) favoriteUsers = List();

              querysnapshot.documents.forEach(
                (DocumentSnapshot user) => favoriteUsers.add(
              UserModel.fromMap(
                user.data,
              ),
            ),
          );

        },
      );

    }


  }

  @override
  Widget build(BuildContext context) {
    if (userStatus == PastHiredUserStatus.LOADING) {
      return Center(child: CircularProgressIndicator());
    } else if (userStatus == PastHiredUserStatus.EMPTY) {
      return Center(child: Text('No user found'));
    } else {
      return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,

      itemBuilder: (context, index) {

        bool isfavorite = false;

        UserModel user = users.elementAt(index);


        if(favoriteUsers != null){


          favoriteUsers.forEach((f){

            if (f.sevaUserID == user.sevaUserID){
            //  print("found a match for ${f.fullname}   --  ${user.sevaUserID}");
              isfavorite = true;
            }

          });

          return RequestCardWidget(
            userModel: user,
            requestModel: widget.requestModel,
            timebankModel: timebank.model,
            isFavorite: isfavorite,
          );


        } else{


          return RequestCardWidget(
            userModel: user,
            requestModel: widget.requestModel,
            timebankModel: timebank.model,
            isFavorite: false,

          );
        }
          },
        );
    }
  }



  /*Widget getUserWidget(List<UserModel> favoriteUsers, UserModel user){


    if(favoriteUsers != null){

      bool isfavorite =false;

      print(" favorite ids are ${favoriteUsers[0].sevaUserID}");



      return RequestCardWidget(
        userModel: user,
        requestModel: widget.requestModel,
        timebankModel: timebank.model,
        isFavorite: true,
      );


    } else{
      return RequestCardWidget(
        userModel: user,
        requestModel: widget.requestModel,
        timebankModel: timebank.model,
        isFavorite: false,

      );
    }

  }
*/




}
