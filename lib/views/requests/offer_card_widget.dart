import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

class OfferCardWidget extends StatelessWidget {
  final String offerId;
  final UserModel userModel;
  final bool memberInvited;
  final TimebankModel timebankModel;
  final List<String> offerAcceptors;
  final List<String> offerInvites;
  final OfferModel offerModel;

  OfferCardWidget({
    required this.offerId,
    required this.userModel,
    required this.memberInvited,
    required this.timebankModel,
    required this.offerAcceptors,
    required this.offerInvites,
    required this.offerModel,
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
          getUserThumbnail(context),
        ],
      ),
    );
  }

  Widget getUserThumbnail(BuildContext context) {
    return UserProfileImage(
      photoUrl: userModel.photoURL!,
      email: userModel.email!,
      userId: userModel.sevaUserID!,
      height: 60,
      width: 60,
      timebankModel: timebankModel,
    );
  }

  Widget getUserCard(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: Container(
        height: 200,
        width: 500,
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
                  SizedBox(
                    width: 8,
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
                    height: 40,
                    margin: EdgeInsets.only(bottom: 10),
                    child: CustomElevatedButton(
                      shape: StadiumBorder(),
                      color: Colors.indigo,
                      textColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      onPressed: () {
                        if (!offerAcceptors.contains(userModel.sevaUserID) &&
                            !offerInvites.contains(userModel.sevaUserID)) {
                          CollectionRef.offers.doc(offerId).update({
                            'individualOfferDataModel.offerInvites':
                                FieldValue.arrayUnion([userModel.sevaUserID])
                          });
                          //Create a notification for other member
                          //String id, NotificationType type, Map<String, dynamic> data, String targetUserId, bool isRead = false, String senderUserId, String timebankId, String communityId, int timestamp, bool isTimebankNotification

                          String notificationId = utils.Utils.getUuid();

                          var notificationModel = NotificationsModel()
                            ..id = notificationId
                            ..isRead = false
                            ..isTimebankNotification = false
                            ..targetUserId = userModel.sevaUserID
                            ..communityId = SevaCore.of(context)
                                .loggedInUser
                                .currentCommunity
                            ..timestamp = DateTime.now().millisecondsSinceEpoch
                            ..type =
                                NotificationType.TimeOfferInvitationFromCreator
                            ..senderUserId =
                                SevaCore.of(context).loggedInUser.sevaUserID
                            ..data = offerModel.toMap();

                          CollectionRef.users
                              .doc(userModel.email)
                              .collection('notifications')
                              .doc(notificationModel.id)
                              .set(notificationModel.toMap());
                        }
                      },
                      child: Text(
                        getStatus(
                          offerAcceptors: offerAcceptors,
                          offerInvites: offerInvites,
                          sevaUserId: userModel.sevaUserID!,
                        ),
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

  String getStatus({
    List<String>? offerAcceptors,
    List<String>? offerInvites,
    String? sevaUserId,
  }) {
    if (offerAcceptors!.contains(sevaUserId)) return 'Accepted Offer';
    if (offerInvites!.contains(sevaUserId)) return 'Invited';
    return 'Invite';
  }
}
