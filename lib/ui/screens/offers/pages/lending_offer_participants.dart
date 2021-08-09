import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/requests/offer_join_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/lending_participants_card.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class LendingOfferParticipants extends StatelessWidget {
  final OfferModel offerModel;
  final TimebankModel timebankModel;

  const LendingOfferParticipants({Key key, this.offerModel, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<LendingOfferParticipantsModel>>(
        stream: _bloc.timeOfferParticipants2,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null || snapshot.data.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              alignment: Alignment.center,
              child: Center(child: Text(S.of(context).no_participants_yet)),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 14.0, left: 20.0),
                child: Text(
                  'Borrowers',
                  style: TextStyle(fontSize: 21, color: Colors.grey),
                ),
              ),
              SizedBox(height: 17),
              ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      LendingParticipantCard(
                        name: 'Jesse Gonzalez',
                        imageUrl:
                            'https://www.pngitem.com/pimgs/m/404-4042710_circle-profile-picture-png-transparent-png.png',
                        bio: 'test bio test bio test bio',
                        onImageTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProfileViewer(
                              timebankId: timebankModel.id,
                              entityName: timebankModel.name,
                              isFromTimebank: isPrimaryTimebank(
                                  parentTimebankId:
                                      timebankModel.parentTimebankId),
                              userEmail: 'email@yopmail.com',
                            );
                          }));
                        },
                        // rating: double.parse(snapshot.data[index].participantDetails.),
                        onMessageTapped: () {
                          // onMessageClick(
                          //   context,
                          //   SevaCore.of(context).loggedInUser,
                          //   snapshot.data[index].participantDetails,
                          //   offerModel.timebankId,
                          //   offerModel.communityId,
                          // );
                        },
                        buttonsContainer: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: getActions(
                              bloc: _bloc,
                              acceptorDoumentId: snapshot.data[index].id,
                              offerId: snapshot.data[index].offerId,
                              status: snapshot.data[index].status,
                              notificationId:
                                  snapshot.data[index].acceptorNotificationId,
                              hostEmail: snapshot.data[index].hostEmail,
                              lendingOfferParticipantsModel:
                                  snapshot.data[index],
                              context: context,
                              user: SevaCore.of(context).loggedInUser,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<dynamic> cannotApproveMultipleDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            content: Container(
              height: MediaQuery.of(context).size.width * 0.40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.cancel_rounded,
                          color: Colors.grey,
                        ),
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  Text(L
                      .of(context)
                      .cannot_approve_multiple_borrowers
                      .replaceAll(" **name", 'Daniel James')),
                ],
              ),
            ), //replace with active/current borrower name
            // actions: [
            //   CustomElevatedButton(
            //     color: Colors.red,
            //     onPressed: () => Navigator.of(dialogContext).pop(),
            //     child: Text(S.of(context).ok),
            //   )
            // ],
          );
        });
  }

  List<Widget> getActions({
    OfferAcceptanceStatus status,
    OfferBloc bloc,
    String offerId,
    String acceptorDoumentId,
    String notificationId,
    String hostEmail,
    LendingOfferParticipantsModel lendingOfferParticipantsModel,
    BuildContext context,
    UserModel user,
  }) {
    switch (status) {
      case OfferAcceptanceStatus.ACCEPTED:
        return [
          CustomElevatedButton(
            color: Colors.green,
            onPressed: () async {},
            child: Text(
              'Approved',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 5,
          ),
        ];

      case OfferAcceptanceStatus.REJECTED:
        return [
          CustomElevatedButton(
            color: Colors.red,
            onPressed: () {},
            child: Text(
              'Declined',
              style: TextStyle(color: Colors.white),
            ),
          )
        ];

      case OfferAcceptanceStatus.REQUESTED:
        return [
          IconButton(
            icon: Icon(
              Icons.chat_bubble,
              color: Colors.grey,
            ),
            iconSize: 30,
            onPressed: null,
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[300],
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () async {
              //on approve functionality here.

              //Dialog box also to restrict approving more than one Borrower at a time.
              bool isCurrentlyLent = true;
              if (isCurrentlyLent) {
                await cannotApproveMultipleDialog(context);
              }
              // bloc.updateOfferAcceptorAction(
              //   notificationId: notificationId,
              //   acceptorDocumentId: acceptorDoumentId,
              //   offerId: offerId,
              //   action: OfferAcceptanceStatus.ACCEPTED,
              //   hostEmail: hostEmail,
              // );
            },
            child: Text(
              S.of(context).approve,
              style: TextStyle(color: Colors.black, fontSize: 11.5),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[300],
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () {
              // bloc.updateOfferAcceptorAction(
              //   notificationId: notificationId,
              //   acceptorDocumentId: acceptorDoumentId,
              //   offerId: offerId,
              //   // action: OfferAcceptanceStatus.REJECTED,
              //   hostEmail: hostEmail,
              // );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Text(
                S.of(context).reject,
                style: TextStyle(color: Colors.black, fontSize: 11.5),
              ),
            ),
          )
        ];
    }
  }

  void onMessageClick(
    context,
    UserModel loggedInUser,
    ParticipantDetails user,
    String timebankId,
    String communityId,
  ) {
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      photoUrl: loggedInUser.photoURL,
      name: loggedInUser.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    ParticipantInfo reciever = ParticipantInfo(
      id: user.sevauserid,
      photoUrl: user.photourl,
      name: user.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    List<String> showToCommunities = [];
    try {
      String communityId1 = loggedInUser.currentCommunity;

      String communityId2 =
          offerModel.participantDetails[user.sevauserid]['communityId'];

      if (communityId1 != null &&
          communityId2 != null &&
          communityId1.isNotEmpty &&
          communityId2.isNotEmpty &&
          communityId1 != communityId2) {
        showToCommunities.add(communityId1);
        showToCommunities.add(communityId2);
      }
    } catch (e) {
      logger.e(e);
    }

    createAndOpenChat(
      context: context,
      timebankId: timebankId,
      communityId: communityId,
      sender: sender,
      reciever: reciever,
      showToCommunities:
          showToCommunities.isNotEmpty ? showToCommunities : null,
      interCommunity: showToCommunities.isNotEmpty,
    );
  }
}

enum LendingOfferStates {
  REQUESTED,
  ACCEPTED,
  REJECTED,
}

extension ReadableLendingOfferStates on LendingOfferStates {
  String get readable {
    switch (this) {
      case LendingOfferStates.REQUESTED:
        return 'REQUESTED';

      case LendingOfferStates.ACCEPTED:
        return 'ACCEPTED';

      case LendingOfferStates.REJECTED:
        return 'REJECTED';

      default:
        return 'REQUESTED';
    }
  }

  static LendingOfferStates getValue(String value) {
    switch (value) {
      case 'REQUESTED':
        return LendingOfferStates.REQUESTED;

      case 'ACCEPTED':
        return LendingOfferStates.ACCEPTED;

      case 'REJECTED':
        return LendingOfferStates.REJECTED;

      default:
        return LendingOfferStates.REQUESTED;
    }
  }
}

class LendingOfferParticipantsModel {
  String id;
  String timebankId;
  OfferAcceptanceStatus status;
  String communityId;
  String acceptorNotificationId;
  String acceptorDocumentId;
  int timestamp;
  ParticipantDetails participantDetails;
  String offerId;
  String hostEmail;

  String requestId;
  String requestTitle;
  int requestStartDate;
  int requestEndDate;

  LendingOfferParticipantsModel({
    this.requestId,
    this.requestTitle,
    this.requestStartDate,
    this.requestEndDate,
    this.id,
    this.timebankId,
    this.status,
    this.communityId,
    this.acceptorNotificationId,
    this.participantDetails,
    this.acceptorDocumentId,
    this.timestamp,
    this.offerId,
    this.hostEmail,
  });

  factory LendingOfferParticipantsModel.fromJSON(Map<String, dynamic> json) =>
      LendingOfferParticipantsModel(
        requestEndDate: json["requestEndDate"],
        requestStartDate: json["requestStartDate"],
        requestTitle: json["requestTitle"],
        requestId: json["requestId"],
        communityId: json["communityId"],
        status: ReadableOfferAcceptanceStatus.getValue(json["status"]),
        timebankId: json["timebankId"],
        participantDetails: ParticipantDetails.fromJson(
            Map<String, dynamic>.from(json["participantDetails"])),
        timestamp: json["timestamp"],
        acceptorDocumentId: json["acceptorDocumentId"],
        acceptorNotificationId: json["acceptorNotificationId"],
        id: json["id"],
        offerId: json['offerId'],
        hostEmail: json['hostEmail'],
      );

  // Map<String, dynamic> toMap() {

  //     TimeOfferParticipantsModel(
  //       communityId: json["communityId"],
  //       status: ReadableOfferAcceptanceStatus.getValue(json["status"]),
  //       timebankId: json["timebankId"],
  //       participantDetails: ParticipantDetails.fromJson(
  //           Map<String, dynamic>.from(json["participantDetails"])),
  //       timestamp: json["timestamp"],
  //       acceptorDocumentId: json["acceptorDocumentId"],
  //       acceptorNotificationId: json["acceptorNotificationId"],
  //       id: json["id"],
  //       offerId: json['offerId'],
  //       hostEmail: json['hostEmail'],
  //     );
  // }

}
