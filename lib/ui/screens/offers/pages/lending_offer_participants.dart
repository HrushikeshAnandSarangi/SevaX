import 'package:flutter/material.dart';
import 'package:sevaexchange/components/lending_borrow_widgets/approve_lending_offer.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/borrow_agreement/borrow_agreement_pdf.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
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
      child: StreamBuilder<List<BorrowAcceptorModel>>(
        stream:
            LendingOffersRepo.getLendingOfferAcceptors(offerId: offerModel.id),
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
          List<BorrowAcceptorModel> acceptorsList = snapshot.data;
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
                  BorrowAcceptorModel acceptorModel = acceptorsList[index];
                  return Column(
                    children: [
                      LendingParticipantCard(
                        name: acceptorModel.acceptorName,
                        imageUrl: acceptorModel.acceptorphotoURL ??
                            'https://www.pngitem.com/pimgs/m/404-4042710_circle-profile-picture-png-transparent-png.png',
                        onImageTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ProfileViewer(
                                  timebankId: timebankModel.id,
                                  entityName: timebankModel.name,
                                  isFromTimebank: isPrimaryTimebank(
                                      parentTimebankId:
                                          timebankModel.parentTimebankId),
                                  userEmail: acceptorModel.acceptorEmail,
                                );
                              },
                            ),
                          );
                        },
                        // rating: double.parse(snapshot.data[index].participantDetails.),
                        onMessageTapped: () {
                          onMessageClick(
                            context,
                            SevaCore.of(context).loggedInUser,
                            ParticipantInfo(
                                id: acceptorModel.acceptorId,
                                photoUrl: acceptorModel.acceptorphotoURL,
                                name: acceptorModel.acceptorName,
                                type: ChatType.TYPE_PERSONAL,
                                communityId: acceptorModel.communityId),
                            offerModel.timebankId,
                            offerModel.communityId,
                          );
                        },
                        buttonsContainer: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: getActions(
                              bloc: _bloc,
                              acceptorDoumentId: acceptorModel.acceptorEmail,
                              offerId: offerModel.id,
                              status: snapshot.data[index].status,
                              notificationId:
                                  acceptorModel.notificationId ?? '',
                              hostEmail: offerModel.email,
                              borrowAcceptorModel: acceptorModel,
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

  Future<dynamic> cannotApproveMultipleDialog(
      BuildContext context, String name) {
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
                      .replaceAll(" **name", name)),
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
    LendingOfferStatus status,
    OfferBloc bloc,
    String offerId,
    String acceptorDoumentId,
    String notificationId,
    String hostEmail,
    BorrowAcceptorModel borrowAcceptorModel,
    BuildContext context,
    UserModel user,
  }) {
    switch (status) {
      case LendingOfferStatus.APPROVED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () async {},
            child: Text(
              'Approved',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            width: 5,
          ),
        ];

      case LendingOfferStatus.REJECTED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {},
            child: Text(
              'Rejected',
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.ITEMS_RETURNED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {
              //To be implemented by lending offer team
            },
            child: Text(
              S.of(context).review,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.ITEMS_COLLECTED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {
              //To be implemented by lending offer team
            },
            child: Text(
              L.of(context).items_taken,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.CHECKED_IN:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {
              //To be implemented by lending offer team
            },
            child: Text(
              L.of(context).arrived,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.CHECKED_OUT:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {
              //To be implemented by lending offer team
            },
            child: Text(
              L.of(context).departed,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.ACCEPTED:
        return [
          IconButton(
            icon: Icon(
              Icons.chat_bubble,
              color: Colors.grey,
            ),
            iconSize: 30,
            onPressed: null,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[300],
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            onPressed: () async {
              //Dialog box also to restrict approving more than one Borrower at a time.
              bool isCurrentlyLent = false;
              if (offerModel.lendingOfferDetailsModel.approvedUsers != null &&
                  offerModel.lendingOfferDetailsModel.approvedUsers.length >
                      0) {
                isCurrentlyLent = true;
              }

              if (isCurrentlyLent) {
                await cannotApproveMultipleDialog(
                    context, borrowAcceptorModel.acceptorName ?? '');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // fullscreenDialog: true,
                    builder: (context) => ApproveLendingOffer(
                      offerModel: offerModel,
                      borrowAcceptorModel: borrowAcceptorModel,
                    ),
                  ),
                );
              }
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
              LendingOffersRepo.updateOfferAcceptorAction(
                borrowAcceptorModel: borrowAcceptorModel,
                action: OfferAcceptanceStatus.REJECTED,
                model: offerModel,
              );
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
    ParticipantInfo receiver,
    String timebankId,
    String communityId,
  ) {
    ParticipantInfo sender = ParticipantInfo(
      id: loggedInUser.sevaUserID,
      photoUrl: loggedInUser.photoURL,
      name: loggedInUser.fullname,
      type: ChatType.TYPE_PERSONAL,
    );

    List<String> showToCommunities = [];
    try {
      String communityId1 = loggedInUser.currentCommunity;

      String communityId2 = receiver.communityId;

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
      reciever: receiver,
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
