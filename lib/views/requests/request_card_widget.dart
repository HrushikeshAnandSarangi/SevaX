
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';

import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';


import 'package:smooth_star_rating/smooth_star_rating.dart';

class RequestCardWidget extends StatefulWidget {

  final UserModel userModel;
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final bool isFavorite;

  RequestCardWidget({@required this.userModel, @required this.requestModel, this.timebankModel, this.isFavorite,});




  @override
  _RequestCardWidgetState createState() => _RequestCardWidgetState();
}




enum RequestUserStatus{INVITE, INVITED,APPROVED,REJECTED}





class _RequestCardWidgetState extends State<RequestCardWidget> {

  bool isBookMarked = false;
  var validItems;
  BuildContext dialogLoadingContext;

  static const String Invite = "Invite";
  static const String Invited = "Invited";
  static const String Approved = "Approved";
  static const String Rejected = "Rejected";
  bool isAdmin =false;




  @override
  Widget build(BuildContext context) {
    if(widget.timebankModel.admins.contains(SevaCore.of(context).loggedInUser.sevaUserID)){
      isAdmin =true;
    }

    isBookMarked =widget.isFavorite;

    return makeUserWidget(context);
  }


  Widget makeUserWidget(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(35, 20, 30, 10),
        child: Stack(
            children: <Widget>[
              getUserCard(userModel: widget.userModel, requestModel: widget.requestModel, context: context, ),
              getUserThumbnail(),
            ]
        )
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
                image: NetworkImage(
                    widget.userModel.photoURL)
            )
        ));
  }

  Widget getUserCard({UserModel userModel, RequestModel requestModel,BuildContext context}) {
    bool isInvited = false;

    RequestUserStatus status;
    print('invited users ------ ${requestModel.invitedUsers} ');

    if (requestModel.invitedUsers != null) {

      if (requestModel.invitedUsers.contains(userModel.sevaUserID)) {
        status = RequestUserStatus.INVITED;

        print('invited true 1');
        isInvited = true;
      }

    } else {
      if (requestModel.acceptors.contains(userModel.sevaUserID)) {
        status = RequestUserStatus.INVITED;
        isInvited = true;
        print('invited true 2');

      } else if (requestModel.approvedUsers.contains(
          userModel.sevaUserID)) {
        status = RequestUserStatus.APPROVED;
        isInvited = true;
        print('approved true');

      }


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
                    child: Text(widget.userModel.fullname, style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    onTap: () {

                      if(isBookMarked){
                        removeFromFavoriteList(context, userModel, widget.timebankModel);

                      }else{
                        addToFavoriteList(context,userModel,widget.timebankModel);

                      }
                      isBookMarked =!isBookMarked;
                      setState(() {


                      });
                    },
                    child: Row(
                      children: <Widget>[
                        isBookMarked ?

                        Icon(
                          Icons.bookmark, color: Colors.redAccent,
                          size: 35,
                        ) : Icon(
                          Icons.bookmark,
                          color: Colors.grey,
                          size: 35,
                        ),
                      ],
                    ),
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
                  widget.userModel.bio,
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
                        onPressed: isInvited ? null : () {

                          showProgressDialog(context);
                          sendNotification(
                              context, widget.requestModel, widget.userModel,
                              widget.timebankModel, status,(){setState(() {

                              });});
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


  TextStyle get sectionTextStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 11,
      color: Colors.grey,
    );
  }

  Future<void> sendNotification(BuildContext context, RequestModel requestModel,
      UserModel userModel, TimebankModel timebankModel,


      RequestUserStatus status,Function set) async {
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

    status = RequestUserStatus.INVITED;

    if(dialogLoadingContext != null){
      Navigator.pop(dialogLoadingContext);

    }
set();
//    setState(() {
//      //status = RequestUserStatus.INVITED;
//
//      print("success request sent");
//    });
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


  Widget getEmptyWidget(String title, String notFoundValue) {
    return Center(
      child: Text(
        notFoundValue,
        overflow: TextOverflow.ellipsis,
        style: sectionHeadingStyle,
      ),
    );
  }

  TextStyle get sectionHeadingStyle {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12.5,
      color: Colors.black,
    );
  }


}

