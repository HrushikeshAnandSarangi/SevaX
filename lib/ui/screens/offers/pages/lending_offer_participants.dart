import 'package:flutter/material.dart';
import 'package:sevaexchange/components/lending_borrow_widgets/approve_lending_offer.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/chat_model.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/ui/utils/message_utils.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/qna-module/ReviewFeedback.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/lending_participants_card.dart';

class LendingOfferParticipants extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const LendingOfferParticipants(
      {Key? key, this.offerModel, this.timebankModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);
    return SingleChildScrollView(
      child: StreamBuilder<List<LendingOfferAcceptorModel>>(
        stream:
            LendingOffersRepo.getLendingOfferAcceptors(offerId: offerModel!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingIndicator();
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              alignment: Alignment.center,
              child: Center(child: Text(S.of(context).no_participants_yet)),
            );
          }
          List<LendingOfferAcceptorModel> acceptorsList = snapshot.data!;
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
                itemCount: snapshot.data!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  LendingOfferAcceptorModel acceptorModel =
                      acceptorsList[index];
                  return Column(
                    children: [
                      LendingParticipantCard(
                        name: acceptorModel.acceptorName!,
                        acceptTime: acceptorModel.timestamp!,
                        imageUrl: acceptorModel.acceptorphotoURL ??
                            'https://www.pngitem.com/pimgs/m/404-4042710_circle-profile-picture-png-transparent-png.png',
                        onImageTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ProfileViewer(
                                  timebankId: timebankModel!.id,
                                  entityName: timebankModel!.name,
                                  isFromTimebank: isPrimaryTimebank(
                                      parentTimebankId:
                                          timebankModel!.parentTimebankId),
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
                            offerModel!.timebankId!,
                            offerModel!.communityId!,
                          );
                        },
                        buttonsContainer: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: getActions(
                              bloc: _bloc!,
                              acceptorDoumentId: acceptorModel.acceptorEmail,
                              offerId: offerModel!.id!,
                              status: acceptorModel.status,
                              notificationId:
                                  acceptorModel.notificationId ?? '',
                              hostEmail: offerModel!.email!,
                              lendingOfferAcceptorModel: acceptorModel,
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
      BuildContext context, String name, LendingType lendingType) {
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
                  Text(lendingType == LendingType.PLACE
                      ? S
                          .of(context)
                          .cannot_approve_multiple_borrowers_place
                          .replaceAll(" **name", name)
                      : S
                          .of(context)
                          .cannot_approve_multiple_borrowers_item
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
    LendingOfferStatus? status,
    OfferBloc? bloc,
    String? offerId,
    String? acceptorDoumentId,
    String? notificationId,
    String? hostEmail,
    LendingOfferAcceptorModel? lendingOfferAcceptorModel,
    BuildContext? context,
    UserModel? user,
  }) {
    switch (status) {
      case LendingOfferStatus.APPROVED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () async {},
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              'Approved',
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {},
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
              if (!lendingOfferAcceptorModel!.isLenderGaveReview!) {
                handleFeedBackNotificationLendingOffer(
                    offerModel: offerModel!,
                    notificationId: "",
                    context: context!,
                    email: SevaCore.of(context).loggedInUser!.email!,
                    feedbackType:
                        FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER,
                    lendingOfferAcceptorModel: lendingOfferAcceptorModel);
              }
            },
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              !lendingOfferAcceptorModel!.isLenderGaveReview!
                  ? S.of(context!).review
                  : S.of(context!).returned_items,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.ITEMS_COLLECTED:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {},
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              S.of(context!).items_collected,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.CHECKED_IN:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {},
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              S.of(context!).checked_in_text,
              style: TextStyle(color: Colors.black),
            ),
          )
        ];
      case LendingOfferStatus.CHECKED_OUT:
        return [
          CustomElevatedButton(
            color: HexColor('#FAFAFA'),
            onPressed: () {
              if (!lendingOfferAcceptorModel!.isLenderGaveReview!) {
                handleFeedBackNotificationLendingOffer(
                    offerModel: offerModel!,
                    notificationId: '',
                    context: context!,
                    email: SevaCore.of(context).loggedInUser.email!,
                    feedbackType:
                        FeedbackType.FEEDBACK_FOR_BORROWER_FROM_LENDER,
                    lendingOfferAcceptorModel: lendingOfferAcceptorModel);
              }
            },
            padding: EdgeInsets.all(0),
            elevation: 0,
            textColor: Colors.black,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              !lendingOfferAcceptorModel!.isLenderGaveReview!
                  ? S.of(context!).review
                  : S.of(context!).departed_text,
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
            padding: EdgeInsets.zero,
            iconSize: 30,
            onPressed: () {
              onMessageClick(
                context,
                SevaCore.of(context!).loggedInUser,
                ParticipantInfo(
                    id: lendingOfferAcceptorModel!.acceptorId,
                    photoUrl: lendingOfferAcceptorModel.acceptorphotoURL,
                    name: lendingOfferAcceptorModel.acceptorName,
                    type: ChatType.TYPE_PERSONAL,
                    communityId: lendingOfferAcceptorModel.communityId),
                offerModel!.timebankId!,
                offerModel!.communityId!,
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: StadiumBorder(),
            ),
            onPressed: () async {
              //Dialog box also to rsestrict approving more than one Borrower at a time.
              bool isCurrentlyLent = false;
              if (offerModel!.lendingOfferDetailsModel!.approvedUsers != null &&
                  offerModel!.lendingOfferDetailsModel!.approvedUsers.length >
                      0) {
                isCurrentlyLent = true;
              }

              LendingOfferAcceptorModel? lendingOfferAcceptorModelOfApproved;
              if (offerModel!.lendingOfferDetailsModel!.approvedUsers.length >
                  0) {
                lendingOfferAcceptorModelOfApproved =
                    await LendingOffersRepo.getBorrowAcceptorModel(
                        offerId: offerModel!.id!,
                        acceptorEmail: offerModel!
                            .lendingOfferDetailsModel!.approvedUsers.first);
              }

              if (isCurrentlyLent &&
                  lendingOfferAcceptorModelOfApproved != null) {
                await cannotApproveMultipleDialog(
                    context!,
                    lendingOfferAcceptorModelOfApproved.acceptorName ?? '',
                    offerModel!
                        .lendingOfferDetailsModel!.lendingModel!.lendingType);
              } else {
                Navigator.push(
                  context!,
                  MaterialPageRoute(
                    // fullscreenDialog: true,
                    builder: (context) => ApproveLendingOffer(
                      offerModel: offerModel!,
                      lendingOfferAcceptorModel: lendingOfferAcceptorModel!,
                    ),
                  ),
                );
              }
            },
            child: Text(
              S.of(context!).approve,
              style: TextStyle(color: Colors.black, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              shape: StadiumBorder(),
            ),
            onPressed: () {
              LendingOffersRepo.updateOfferAcceptorActionRejected(
                lendingOfferAcceptorModel: lendingOfferAcceptorModel!,
                action: OfferAcceptanceStatus.REJECTED,
                model: offerModel!,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Text(
                S.of(context).reject,
                style: TextStyle(color: Colors.black, fontSize: 11.5),
              ),
            ),
          ),
        ];
    }
    return [];
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
      String communityId1 = loggedInUser.currentCommunity!;

      String communityId2 = receiver.communityId!;

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
          showToCommunities.isNotEmpty ? showToCommunities : <String>[],
      interCommunity: showToCommunities.isNotEmpty,
      feedId: '', // Provide appropriate value if needed
      onChatCreate: () {}, // Provide appropriate callback if needed
      entityId: '', // Provide appropriate value if needed
    );
  }
}

class LendingOfferAcceptorModel {
  String? id;
  String? acceptorEmail;
  String? acceptorId;
  String? acceptorName;
  String? acceptorMobile;
  String? borrowAgreementLink;
  String? selectedAddress;
  bool? isApproved;
  List<String>? borrowedItemsIds;
  String? borrowedPlaceId;
  String? notificationId;
  int? timestamp;
  String? acceptorphotoURL;
  LendingOfferStatus? status;
  String? communityId;
  String? additionalInstructions;
  bool? isLenderGaveReview;
  bool? isBorrowerGaveReview;
  int? startDate;
  int? endDate;
  String? approvedAgreementId;

  LendingOfferAcceptorModel({
    required this.id,
    required this.acceptorEmail,
    required this.acceptorId,
    required this.acceptorName,
    required this.acceptorMobile,
    required this.borrowAgreementLink,
    required this.selectedAddress,
    required this.isApproved,
    required this.borrowedItemsIds,
    required this.borrowedPlaceId,
    required this.notificationId,
    required this.timestamp,
    required this.acceptorphotoURL,
    required this.status,
    required this.communityId,
    required this.additionalInstructions,
    required this.isLenderGaveReview,
    required this.isBorrowerGaveReview,
    required this.startDate,
    required this.endDate,
    required this.approvedAgreementId,
  });

  factory LendingOfferAcceptorModel.fromMap(Map<String, dynamic> json) =>
      LendingOfferAcceptorModel(
        id: json["id"] == null ? null : json["id"],
        acceptorEmail:
            json["acceptorEmail"] == null ? null : json["acceptorEmail"],
        acceptorId: json["acceptorId"] == null ? null : json["acceptorId"],
        acceptorName:
            json["acceptorName"] == null ? null : json["acceptorName"],
        acceptorMobile:
            json["acceptorMobile"] == null ? null : json["acceptorMobile"],
        borrowAgreementLink: json["borrowAgreementLink"] == null
            ? null
            : json["borrowAgreementLink"],
        selectedAddress:
            json["selectedAddress"] == null ? null : json["selectedAddress"],
        isApproved: json["isApproved"] == null ? false : json["isApproved"],
        borrowedItemsIds: json["borrowedItemsIds"] == null
            ? []
            : List<String>.from(json["borrowedItemsIds"].map((x) => x)),
        borrowedPlaceId:
            json["borrowedPlaceId"] == null ? null : json["borrowedPlaceId"],
        timestamp: json["timestamp"] == null ? null : json["timestamp"],
        acceptorphotoURL:
            json["acceptorphotoURL"] == null ? null : json["acceptorphotoURL"],
        notificationId:
            json["notificationId"] == null ? null : json["notificationId"],
        communityId: json["communityId"] == null ? null : json["communityId"],
        additionalInstructions: json["additionalInstructions"] == null
            ? null
            : json["additionalInstructions"],
        status: json["status"] == null
            ? LendingOfferStatus.ACCEPTED
            : ReadableLendingOfferStatus.getValue(json["status"]),
        isLenderGaveReview: json["isLenderGaveReview"] == null
            ? false
            : json["isLenderGaveReview"],
        isBorrowerGaveReview: json["isBorrowerGaveReview"] == null
            ? false
            : json["isBorrowerGaveReview"],
        startDate: json["startDate"] == null ? null : json["startDate"],
        endDate: json["endDate"] == null ? null : json["endDate"],
        approvedAgreementId: json["approvedAgreementId"] == null
            ? ''
            : json["approvedAgreementId"],
      );

  Map<String, dynamic> toMap() => {
        "id": id == null ? null : id,
        "acceptorEmail": acceptorEmail == null ? null : acceptorEmail,
        "acceptorId": acceptorId == null ? null : acceptorId,
        "acceptorName": acceptorName == null ? null : acceptorName,
        "acceptorMobile": acceptorMobile == null ? null : acceptorMobile,
        "borrowAgreementLink":
            borrowAgreementLink == null ? null : borrowAgreementLink,
        "selectedAddress": selectedAddress == null ? null : selectedAddress,
        "isApproved": isApproved == null ? null : isApproved,
        "borrowedItemsIds": borrowedItemsIds == null
            ? []
            : List<dynamic>.from(borrowedItemsIds!.map((x) => x)),
        "borrowedPlaceId": borrowedPlaceId == null ? null : borrowedPlaceId,
        "timestamp": timestamp == null ? null : timestamp,
        "acceptorphotoURL": acceptorphotoURL == null ? null : acceptorphotoURL,
        "notificationId": notificationId == null ? null : notificationId,
        "communityId": communityId == null ? null : communityId,
        "additionalInstructions":
            additionalInstructions == null ? null : additionalInstructions,
        "status": status == null ? null : status?.readable,
        "isBorrowerGaveReview":
            isBorrowerGaveReview == null ? false : isBorrowerGaveReview,
        "isLenderGaveReview":
            isLenderGaveReview == null ? false : isLenderGaveReview,
        "startDate": startDate == null ? null : startDate,
        "endDate": endDate == null ? null : endDate,
      };
}
