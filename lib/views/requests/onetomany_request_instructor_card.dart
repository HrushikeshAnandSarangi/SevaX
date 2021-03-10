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
  //final VoidCallback onAddClick;

  OneToManyInstructorCard({
    @required this.userModel,
    @required this.timebankModel,
    @required this.isFavorite,
    @required this.isAdmin,
    @required this.addStatus,
    @required this.currentCommunity,
    @required this.loggedUserId,
    //@required this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
    return makeUserWidget(context);
  }

  Widget makeUserWidget(context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
      child: Row(
        children: <Widget>[
          getUserCard(context),
        ],
      ),
    );
  }

  Widget getUserCard(context) {
    return Container(
      //height: 40,
      width: 270,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                UserProfileImage(
                  photoUrl: userModel.photoURL,
                  email: userModel.email,
                  userId: userModel.sevaUserID,
                  height: 45,
                  width: 45,
                  timebankModel: timebankModel,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userModel.fullname ?? S.of(context).name_not_available,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Divider(height: 1, color: Colors.grey,)
                    ],
                  ),
                ),
              ],
            ),
          ],
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
