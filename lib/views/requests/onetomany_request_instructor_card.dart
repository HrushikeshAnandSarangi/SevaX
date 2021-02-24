import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/widgets/user_profile_image.dart';

import '../../flavor_config.dart';

class OneToManyInstructorCard extends StatelessWidget {
  final UserModel userModel;
  final TimebankModel timebankModel;
  final bool isFavorite;
  final String addStatus;
  final bool isAdmin;
  final String currentCommunity;
  final String loggedUserId;
  final VoidCallback onAddClick;

  OneToManyInstructorCard({
    @required this.userModel,
    @required this.timebankModel,
    @required this.isFavorite,
    @required this.isAdmin,
    @required this.addStatus,
    @required this.currentCommunity,
    @required this.loggedUserId,
    @required this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
    return makeUserWidget(context);
  }

  Widget makeUserWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Stack(
        children: <Widget>[
          getUserCard(context),
          getUserThumbnail(context),
        ],
      ),
    );
  }

  Widget getUserThumbnail(BuildContext context) {
    return UserProfileImage(
      photoUrl: userModel.photoURL,
      email: userModel.email,
      userId: userModel.sevaUserID,
      height: 50,
      width: 50,
      timebankModel: timebankModel,
    );
  }

  Widget getUserCard(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 115,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
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
                      userModel.fullname ?? S.of(context).name_not_available,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),               
                 
                ],
              ),
              Expanded(
                child: Text(
                  userModel.bio ?? S.of(context).bio_not_updated,
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
                      onPressed: addStatus != S.of(context).add
                          ? null
                          : () async {
                              
                            onAddClick();

    //BACKEND LOGIC TO BE CONFIRMED                       
                              // await timeBankBloc.updateInvitedUsersForRequest(
                              //   requestModel.id,
                              //   userModel.sevaUserID,
                              //   userModel.email,
                              // );

                              // sendNotification(
                              //   userModel: userModel,
                              //   timebankModel: timebankModel,
                              //   currentCommunity: currentCommunity,
                              //   sevaUserID: loggedUserId,
                              // );
                            },
                      child: Text(
                        addStatus ?? "",
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

  // Future<void> sendNotification({
  //   RequestModel requestModel,
  //   UserModel userModel,
  //   String currentCommunity,
  //   String sevaUserID,
  //   TimebankModel timebankModel,
  // }) async {
  //   RequestInvitationModel requestInvitationModel = RequestInvitationModel(
  //     requestModel: requestModel,
  //     timebankModel: timebankModel,
  //   );

  //   NotificationsModel notification = NotificationsModel(
  //     id: utils.Utils.getUuid(),
  //     timebankId: FlavorConfig.values.timebankId,
  //     data: requestInvitationModel.toMap(),
  //     isRead: false,
  //     type: NotificationType.RequestInvite,
  //     communityId: currentCommunity,
  //     senderUserId: sevaUserID,
  //     targetUserId: userModel.sevaUserID,
  //   );

  //   await Firestore.instance
  //       .collection('users')
  //       .document(userModel.email)
  //       .collection("notifications")
  //       .document(notification.id)
  //       .setData(notification.toMap());
  // }

}
