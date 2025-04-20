import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

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
    required this.userModel,
    required this.timebankModel,
    required this.isFavorite,
    required this.isAdmin,
    required this.addStatus,
    required this.currentCommunity,
    required this.loggedUserId,
    required this.onAddClick,
  });

  @override
  Widget build(BuildContext context) {
    return makeUserWidget(context);
  }

  Widget makeUserWidget(context) {
    return InkWell(
      onTap: () {
        onAddClick();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Container(
          margin: EdgeInsets.fromLTRB(5, 4, 0, 4),
          child: Container(
            height: MediaQuery.of(context).size.width * 0.08,
            child: Row(
              children: <Widget>[
                getUserThumbnail(context),
                getUserCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUserThumbnail(BuildContext context) {
    return UserProfileImage(
      photoUrl: (userModel.photoURL != null && userModel.photoURL != '')
          ? userModel.photoURL!
          : defaultUserImageURL,
      email: userModel.email!,
      userId: userModel.sevaUserID!,
      height: 35,
      width: 35,
      timebankModel: timebankModel,
    );
  }

  Widget getUserCard(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.07,
        child: Text(
          userModel.fullname ?? S.of(context).name_not_available,
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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

  //   await CollectionRef
  //       .users
  //       .doc(userModel.email)
  //       .collection("notifications")
  //       .doc(notification.id)
  //       .set(notification.toMap());
  // }
}
