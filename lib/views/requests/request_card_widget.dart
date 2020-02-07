import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';

class RequestCardWidget extends StatelessWidget {
  final UserModel userModel;
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final bool isFavorite;
  final String reqStatus;
  final bool isAdmin;
  final Function refresh;

  const RequestCardWidget({
    @required this.userModel,
    @required this.requestModel,
    @required this.timebankModel,
    @required this.isFavorite,
    @required this.isAdmin,
    @required this.reqStatus,
    this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return makeUserWidget(context);
  }

  Widget makeUserWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(30, 20, 25, 10),
      child: Stack(
        children: <Widget>[
          getUserCard(context),
          getUserThumbnail(),
        ],
      ),
    );
  }

  Widget getUserThumbnail() {
    return Container(
      margin: EdgeInsets.only(top: 20, right: 15),
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: CachedNetworkImageProvider(
            userModel.photoURL,
          ),
        ),
      ),
    );
  }

  Widget getUserCard(context) {
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
            new BoxShadow(
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
                    child: Text(
                      userModel.fullname,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
//              Spacer(),
                  InkWell(
                    child: Row(
                      children: <Widget>[
                        isFavorite
                            ? Icon(
                                Icons.bookmark,
                                color: Colors.redAccent,
                                size: 35,
                              )
                            : Icon(
                                Icons.bookmark,
                                color: Colors.grey,
                                size: 35,
                              ),
                      ],
                    ),
                    onTap: () {
                      if (isFavorite) {
                        removeFromFavoriteList(
                          email: userModel.email,
                          timeBankId: timebankModel.id,
                          loggedInUserId:
                              SevaCore.of(context).loggedInUser.sevaUserID,
                        ).then((_) => refresh());
                      } else {
                        addToFavoriteList(
                          email: userModel.email,
                          timebankId: timebankModel.id,
                          loggedInUserId:
                              SevaCore.of(context).loggedInUser.sevaUserID,
                        ).then((_) => refresh());
                      }
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
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
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
                      onPressed: reqStatus != 'Invite'
                          ? null
                          : () async {
                              await timeBankBloc.updateInvitedUsersForRequest(
                                  requestModel.id, userModel.sevaUserID);
                              //showProgressDialog(context);
                              sendNotification(
                                requestModel: requestModel,
                                userModel: userModel,
                                timebankModel: timebankModel,
                                currentCommunity: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity,
                                sevaUserID: SevaCore.of(context)
                                    .loggedInUser
                                    .currentCommunity,
                              );
                            },
                      child: Text(
                        reqStatus ?? "",
                        style: TextStyle(fontSize: 14),
                      ),
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

  Future<void> sendNotification({
    RequestModel requestModel,
    UserModel userModel,
    String currentCommunity,
    String sevaUserID,
    TimebankModel timebankModel,
  }) async {
    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
        timebankImage: timebankModel.photoUrl,
        timebankName: timebankModel.name,
        requestDesc: requestModel.description,
        requestId: requestModel.id,
        requestTitle: requestModel.title);

    NotificationsModel notification = NotificationsModel(
        id: utils.Utils.getUuid(),
        timebankId: timebankModel.id,
        data: requestInvitationModel.toMap(),
        isRead: false,
        type: NotificationType.RequestInvite,
        communityId: currentCommunity,
        senderUserId: sevaUserID,
        targetUserId: userModel.sevaUserID);

    await Firestore.instance
        .collection('users')
        .document(userModel.email)
        .collection("notifications")
        .document(notification.id)
        .setData(notification.toMap());

    // if (dialogLoadingContext != null) {
    //  Navigator.pop(dialogLoadingContext);
    // }
  }

  Future<void> addToFavoriteList(
      {String email, String loggedInUserId, String timebankId}) async {
    await Firestore.instance.collection('users').document(email).updateData({
      isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember':
          FieldValue.arrayUnion(
        [isAdmin ? timebankId : loggedInUserId],
      )
    });
  }

  Future<void> removeFromFavoriteList(
      {String email, String timeBankId, String loggedInUserId}) async {
    await Firestore.instance.collection('users').document(email).updateData({
      isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember':
          FieldValue.arrayRemove(
        [isAdmin ? timeBankId : loggedInUserId],
      ),
    });
  }
}
