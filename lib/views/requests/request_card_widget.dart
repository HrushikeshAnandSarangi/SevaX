
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

  RequestCardWidget({@required this.userModel, @required this.requestModel, this.timebankModel});




  @override
  _RequestCardWidgetState createState() => _RequestCardWidgetState();
}




enum RequestUserStatus{INVITE, INVITED}





class _RequestCardWidgetState extends State<RequestCardWidget> {

  bool isBookMarked = false;
  var validItems;
  BuildContext dialogLoadingContext;

  static const String INVITE = "Invite";
  static const String INVITED = "Invited";


  @override
  Widget build(BuildContext context) {
    return makeUserWidget(context);
  }


  Widget makeUserWidget(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(35, 20, 30, 10),
        child: Stack(
            children: <Widget>[
              getUserCard(context: context, requestModel: widget.requestModel, userModel: widget.userModel),
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
    bool shouldInvite = true;

    RequestUserStatus status;

    if(requestModel.invitedUsers != null) {
      if (requestModel.invitedUsers.contains(
          userModel.sevaUserID)) {
        status = RequestUserStatus.INVITED;
        shouldInvite = false;
      }
    } else{
      if (requestModel.acceptors.contains(userModel.sevaUserID) ||
          requestModel.approvedUsers.contains(
              userModel.sevaUserID)) {
        status = RequestUserStatus.INVITED;

        shouldInvite = false;
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
                    child: Text(widget.userModel.email, style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),),
                  ),
//              Spacer(),
                  InkWell(

                    onTap: () {
                      setState(() {
                        isBookMarked = !isBookMarked;
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
                        onPressed: !shouldInvite ? null : () {

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
        return INVITE;


      case RequestUserStatus.INVITED:
        return INVITED;

      default:
        return INVITE;
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

