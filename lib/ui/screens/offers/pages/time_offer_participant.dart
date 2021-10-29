import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/requests/offer_join_request.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class TimeOfferParticipants extends StatelessWidget {
  final OfferModel offerModel;
  final TimebankModel timebankModel;

  const TimeOfferParticipants({Key key, this.offerModel, this.timebankModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<TimeOfferParticipantsModel>>(
        stream: _bloc.timeOfferParticipants,
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
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ParticipantCard(
                    name: snapshot.data[index].participantDetails.fullname,
                    imageUrl: snapshot.data[index].participantDetails.photourl,
                    bio: snapshot.data[index].participantDetails.bio,
                    onImageTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return ProfileViewer(
                          timebankId: timebankModel.id,
                          entityName: timebankModel.name,
                          isFromTimebank: isPrimaryTimebank(parentTimebankId: timebankModel.parentTimebankId),
                          userEmail: snapshot.data[index].participantDetails.email,
                        );
                      }));
                    },
                    // rating: double.parse(snapshot.data[index].participantDetails.),
                    onMessageTapped: () {
                      onMessageClick(
                        context,
                        SevaCore.of(context).loggedInUser,
                        snapshot.data[index].participantDetails,
                        offerModel.timebankId,
                        offerModel.communityId,
                      );
                    },
                    buttonsContainer: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: getActions(
                          bloc: _bloc,
                          acceptorDoumentId: snapshot.data[index].id,
                          offerId: snapshot.data[index].offerId,
                          status: snapshot.data[index].status,
                          notificationId: snapshot.data[index].acceptorNotificationId,
                          hostEmail: snapshot.data[index].hostEmail,
                          timeOfferParticipantsModel: snapshot.data[index],
                          context: context,
                          user: SevaCore.of(context).loggedInUser,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> getActions({
    OfferAcceptanceStatus status,
    OfferBloc bloc,
    String offerId,
    String acceptorDoumentId,
    String notificationId,
    String hostEmail,
    TimeOfferParticipantsModel timeOfferParticipantsModel,
    BuildContext context,
    UserModel user,
  }) {
    switch (status) {
      case OfferAcceptanceStatus.ACCEPTED:
        return [
          CustomElevatedButton(
            color: Colors.green,
            onPressed: () {},
            child: Text(
              S.of(context).approved,
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
              S.of(context).declined,
              style: TextStyle(color: Colors.white),
            ),
          )
        ];

      case OfferAcceptanceStatus.REQUESTED:
        return [
          CustomElevatedButton(
            color: Colors.green,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return OfferJoinRequestDialog(
                    offerId: timeOfferParticipantsModel.offerId,
                    requestId: timeOfferParticipantsModel.requestId,
                    requestStartDate: timeOfferParticipantsModel.requestStartDate,
                    requestEndDate: timeOfferParticipantsModel.requestEndDate,
                    requestTitle: timeOfferParticipantsModel.requestTitle,
                    timeBankId: timeOfferParticipantsModel.timebankId,
                    notificationId: notificationId,
                    userModel: user,
                    timeOfferParticipantsModel: timeOfferParticipantsModel,
                  );
                },
              );

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
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          CustomElevatedButton(
            color: Colors.red,
            onPressed: () {
              bloc.updateOfferAcceptorAction(
                notificationId: notificationId,
                acceptorDocumentId: acceptorDoumentId,
                offerId: offerId,
                action: OfferAcceptanceStatus.REJECTED,
                hostEmail: hostEmail,
              );
            },
            child: Text(
              S.of(context).decline,
              style: TextStyle(color: Colors.white),
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

      String communityId2 = offerModel.participantDetails[user.sevauserid]['communityId'];

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
      showToCommunities: showToCommunities.isNotEmpty ? showToCommunities : null,
      interCommunity: showToCommunities.isNotEmpty,
    );
  }
}

enum OfferAcceptanceStatus {
  REQUESTED,
  ACCEPTED,
  REJECTED,
}

extension ReadableOfferAcceptanceStatus on OfferAcceptanceStatus {
  String get readable {
    switch (this) {
      case OfferAcceptanceStatus.REQUESTED:
        return 'REQUESTED';

      case OfferAcceptanceStatus.ACCEPTED:
        return 'ACCEPTED';

      case OfferAcceptanceStatus.REJECTED:
        return 'REJECTED';

      default:
        return 'REQUESTED';
    }
  }

  static OfferAcceptanceStatus getValue(String value) {
    switch (value) {
      case 'REQUESTED':
        return OfferAcceptanceStatus.REQUESTED;

      case 'ACCEPTED':
        return OfferAcceptanceStatus.ACCEPTED;

      case 'REJECTED':
        return OfferAcceptanceStatus.REJECTED;

      default:
        return OfferAcceptanceStatus.REQUESTED;
    }
  }
}

class TimeOfferParticipantsModel {
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

  TimeOfferParticipantsModel({
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

  factory TimeOfferParticipantsModel.fromJSON(Map<String, dynamic> json) => TimeOfferParticipantsModel(
        requestEndDate: json["requestEndDate"],
        requestStartDate: json["requestStartDate"],
        requestTitle: json["requestTitle"],
        requestId: json["requestId"],
        communityId: json["communityId"],
        status: ReadableOfferAcceptanceStatus.getValue(json["status"]),
        timebankId: json["timebankId"],
        participantDetails: ParticipantDetails.fromJson(Map<String, dynamic>.from(json["participantDetails"])),
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
