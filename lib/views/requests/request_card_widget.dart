import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/user_model.dart';
import 'package:sevaexchange/new_baseline/models/request_invitaton_model.dart';
import 'package:sevaexchange/repositories/firestore_keys.dart';
import 'package:sevaexchange/utils/data_managers/blocs/communitylist_bloc.dart';
import 'package:sevaexchange/utils/utils.dart' as utils;
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/user_profile_image.dart';

class RequestCardWidget extends StatelessWidget {
  final UserModel userModel;
  final RequestModel requestModel;
  final TimebankModel timebankModel;
  final bool isFavorite;
  final String reqStatus;
  final bool isAdmin;
  final Function? refresh;
  final String currentCommunity;
  final String loggedUserId;

  RequestCardWidget({
    required this.userModel,
    required this.requestModel,
    required this.timebankModel,
    required this.isFavorite,
    required this.isAdmin,
    required this.reqStatus,
    this.refresh,
    required this.currentCommunity,
    required this.loggedUserId,
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
//              Spacer(),
                  requestModel.recommendedMemberIdsForRequest != null &&
                          requestModel.recommendedMemberIdsForRequest!
                              .contains(userModel.sevaUserID)
                      ? Image.asset(
                          'images/icons/recommended.png',
                          height: 30,
                          width: 30,
                          color: Colors.orange,
                        )
                      : Container(),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    child: isFavorite
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 30,
                          )
                        : Icon(
                            Icons.favorite,
                            color: Colors.grey,
                            size: 30,
                          ),
                    onTap: () async {
                      if (isFavorite) {
                        await removeFromFavoriteList(
                          email: userModel.email!,
                          timeBankId: requestModel.timebankId!,
                          loggedInUserId: loggedUserId,
                        );
                        Future.delayed(
                          Duration(milliseconds: 1800),
                          refresh != null ? () => refresh!() : () {},
                        );
                      } else {
                        await addToFavoriteList(
                          email: userModel.email!,
                          timebankId: requestModel.timebankId!,
                          loggedInUserId: loggedUserId,
                        );
                        Future.delayed(
                          Duration(milliseconds: 1800),
                          () => refresh?.call(),
                        );
                      }
                    },
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
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Container(
                      /*  decoration: BoxDecoration(

                          boxShadow: [BoxShadow(
                              color: Colors.indigo[50],
                              blurRadius: 1,
                              offset: Offset(0.0, 0.50)
                          )]
                      ),*/
                      height: 38,
                      width: 85,
                      child: CustomElevatedButton(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: StadiumBorder(),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        elevation: 2,
                        onPressed: reqStatus != S.of(context).invite
                            ? null!
                            : () async {
                                await timeBankBloc.updateInvitedUsersForRequest(
                                  requestModel.id,
                                  userModel.sevaUserID,
                                  userModel.email!,
                                );

                                if (requestModel.requestType ==
                                    RequestType.BORROW) {
                                  if (requestModel.invitedUsers != null) {
                                    requestModel.invitedUsers!
                                        .add(userModel.sevaUserID!);
                                  }
                                }

                                sendNotification(
                                  requestModel: requestModel,
                                  userModel: userModel,
                                  timebankModel: timebankModel,
                                  currentCommunity: currentCommunity,
                                  sevaUserID: loggedUserId,
                                );
                              },
                        child: Text(
                          reqStatus ?? "",
                          style: TextStyle(fontSize: 14),
                        ),
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
    RequestModel? requestModel,
    UserModel? userModel,
    String? currentCommunity,
    String? sevaUserID,
    TimebankModel? timebankModel,
  }) async {
    RequestInvitationModel requestInvitationModel = RequestInvitationModel(
      requestModel: requestModel,
      timebankModel: timebankModel,
    );

    NotificationsModel notification = NotificationsModel(
      id: utils.Utils.getUuid(),
      timebankId: timebankModel!.id!,
      data: requestInvitationModel.toMap(),
      isRead: false,
      type: NotificationType.RequestInvite,
      communityId: currentCommunity,
      senderUserId: sevaUserID,
      targetUserId: userModel!.sevaUserID!,
    );

    await CollectionRef.users
        .doc(userModel.email)
        .collection("notifications")
        .doc(notification.id)
        .set(notification.toMap());
  }

  Future<void> addToFavoriteList(
      {String? email,
      String? loggedInUserId,
      String? timebankId,
      RequestMode? requestMode}) async {
    await CollectionRef.users.doc(email).update({
      isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember':
          FieldValue.arrayUnion(
        [isAdmin ? timebankId : loggedInUserId],
      )
    });
  }

  Future<void> removeFromFavoriteList(
      {String? email,
      String? timeBankId,
      String? loggedInUserId,
      RequestMode? requestMode}) async {
    await CollectionRef.users.doc(email).update({
      isAdmin ? 'favoriteByTimeBank' : 'favoriteByMember':
          FieldValue.arrayRemove(
        [isAdmin ? timeBankId : loggedInUserId],
      ),
    });
  }
}
