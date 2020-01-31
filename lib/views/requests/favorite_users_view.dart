
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

import '../core.dart';


enum FavoriteUserStatus {LOADING,LOADED,EMPTY}

class FavoriteUsers extends StatefulWidget {
  final String timebankId;
  final RequestModel requestModel;
  final String sevaUserId;


  FavoriteUsers({@required this.timebankId, this.requestModel, this.sevaUserId, });

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

            return makeUserWidget(context: context, userModel: users[index], requestModel: widget.requestModel);
           /* return RequestCardWidget(
              userModel: users[index],
              requestModel: widget.requestModel,
              timebankModel: timebank.model,
              isFavorite: true,
              cameFromInvitedUsersPage: false,
            );*/
          },
        );
    }
  }

  Widget makeUserWidget({BuildContext context, UserModel userModel, RequestModel requestModel, bool isFavorite}) {
    return Container(
        margin: EdgeInsets.fromLTRB(30, 20, 25, 10),

        child: Stack(
            children: <Widget>[
              getUserCard(userModel: userModel, requestModel: requestModel, context: context, ),
              getUserThumbnail(photoURL: userModel.photoURL),
            ]
        )
    );
  }


  Widget getUserThumbnail({String photoURL}) {
    return Container(
        margin: EdgeInsets.only(top: 20, right: 15),
        width: 60.0,
        height: 60.0,

        decoration: BoxDecoration(
            shape: BoxShape.circle,

            image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(
                    photoURL ?? defaultUserImageURL)
            )
        ));
  }
  Widget getUserCard({UserModel userModel, RequestModel requestModel,BuildContext context}) {
    bool isInvited = false;

    RequestUserStatus status;


      if (requestModel.invitedUsers.contains(userModel.sevaUserID)) {
        status = RequestUserStatus.INVITED;
       // shouldInvite = false;

        isInvited = true;
        //   print('invited true 2');

      }else if (requestModel.acceptors.contains(userModel.email)) {
        status = RequestUserStatus.INVITED;
      //  shouldInvite = false;

        isInvited = true;
        //  print('invited true 2');

      } else if (requestModel.approvedUsers.contains(
          userModel.email)) {
        status = RequestUserStatus.APPROVED;
       // shouldInvite = false;

        isInvited = true;
//        print('approved true');



    }

    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 200,
        width: 500,
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
             BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: new Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(userModel.fullname, style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    child:  Icon(
                        Icons.bookmark, color: Colors.redAccent,
                        size: 35,
                      ),
                      /*child: Row(
                      children: <Widget>[

                        Icon(
                          Icons.bookmark, color: Colors.redAccent,
                          size: 35,
                        ) : Icon(
                          Icons.bookmark,
                          color: Colors.grey,
                          size: 35,
                        ),
                      ],
                    ),*/
                    onTap: () {
                      //removeFromFavoriteList(context, userModel, timebank.model);

/*
                      if(isBookMarked){
                        removeFromFavoriteList(context, userModel, widget.timebankModel);
                        isBookMarked = false;
                      }else{
                        addToFavoriteList(context,userModel,widget.timebankModel);

                        isBookMarked = true;
                      }*/
                      removeFromFavoriteList(context, userModel, timebank.model);

                    },
                  ),
                ],
              ),
//              SmoothStarRating(
//                  allowHalfRating: true,
//                  onRatingChanged: (v) {
////                    rating = v;
////                    setState(() {});
//                  },
//                  starCount: 5,
//                  rating: 3.5,
//                  size: 20.0,
//                  filledIconData: Icons.star,
//                  halfFilledIconData: Icons.star_half,
//                  defaultIconData: Icons.star_border,
//                  color: Colors.orangeAccent,
//                  borderColor: Colors.orangeAccent,
//                  spacing: 1.0
//              ),
//              SizedBox(
//                  height: 10
//              ),
              Expanded(
                child: Text(
                  userModel.bio,
                  maxLines: 3,
                  style: TextStyle(color: Colors.black, fontSize: 12,),),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    /*  decoration: BoxDecoration(

                        boxShadow: [BoxShadow(
                            color: Colors.indigo[50],
                            blurRadius: 1,
                            offset: Offset(0.0, 0.50)
                        )]
                    ),*/
                    height: 40,
                    padding: EdgeInsets.only(bottom: 10),
                    child: RaisedButton(
                        shape: StadiumBorder(),
                        color: Colors.indigo,
                        textColor: Colors.white,
                        elevation: 5,
                        onPressed: isInvited ? null : () async {
                          await timeBankBloc.updateInvitedUsersForRequest(requestModel.id, userModel.sevaUserID);

                          showProgressDialog(context);
                          sendNotification(
                              context, requestModel, userModel,
                              timebank.model, status,);


                          setState(() {
                            isInvited =true;
                            status = RequestUserStatus.INVITED;

                          });

                        },
                        child: Text(
                            getRequestUserTitle(status) ?? "",
                            style: TextStyle(fontSize: 14)
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> sendNotification(BuildContext context, RequestModel requestModel,
      UserModel userModel, TimebankModel timebankModel, RequestUserStatus status,) async {
    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        requestDesc: requestModel.description,
        requestId: requestModel.id,
        requestTitle: requestModel.title
    );

    NotificationsModel notification =
    NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: timebankModel.id,
        data: requestInvitationModel.toMap(),
        isRead: false,
        type: NotificationType.RequestInvite,
        communityId: SevaCore
            .of(context)
            .loggedInUser
            .currentCommunity,
        senderUserId: SevaCore
            .of(context)
            .loggedInUser
            .sevaUserID,
        targetUserId: userModel.sevaUserID
    );

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());





    if(dialogLoadingContext != null){
      Navigator.pop(dialogLoadingContext);

    }
  }


  Future<void> addToFavoriteList(BuildContext context, UserModel userModel, TimebankModel timebankModel) async {

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .updateData({ isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember'
        : FieldValue.arrayUnion([isAdmin ? timebankModel.id : SevaCore.of(context).loggedInUser.sevaUserID])
    });


  }

  Future<void> removeFromFavoriteList(BuildContext context, UserModel userModel, TimebankModel timebankModel) async {

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .updateData({ isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember' :
    FieldValue.arrayRemove([isAdmin ? timebankModel.id : SevaCore.of(context).loggedInUser.sevaUserID])
    });


  }


  void showProgressDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          dialogLoadingContext = createDialogContext;
          return AlertDialog(
            title: Text('Sending Invitation'),
            content: LinearProgressIndicator(),
          );
        });
  }

  String getRequestUserTitle(RequestUserStatus status) {
    switch (status) {
      case RequestUserStatus.INVITE:
        return Invite;

      case RequestUserStatus.INVITED:
        return Invited;

      case RequestUserStatus.APPROVED:
        return Approved;

      case RequestUserStatus.REJECTED:
        return Rejected;
      default:
        return Invite;
    }
  }

}









