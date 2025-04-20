import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/request/widgets/borrow_request_participants_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/utils/data_managers/notifications_data_manager.dart'
    as RequestNotificationManager;
import 'package:sevaexchange/views/requests/creatorApproveAcceptorAgreement.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class BorrowRequestParticipants extends StatelessWidget {
  final List<UserModel> userModelList;
  final TimebankModel timebankModel;
  final RequestModel requestModel;

  const BorrowRequestParticipants({
    Key? key,
    required this.userModelList,
    required this.timebankModel,
    required this.requestModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<BorrowAcceptorModel>>(
          stream: FirestoreManager.getBorrowRequestAcceptorsModelStream(
            requestId: requestModel.id!,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: LoadingIndicator(),
              );
            }
            if (snapshot.data == null) {
              return Center(
                child: Text(S.of(context).error_loading_data),
              );
            }
            List<BorrowAcceptorModel> borrowAcceptorModel = snapshot.data!;

            logger.e('borrowAcceptorModel length 2: ' +
                borrowAcceptorModel.length.toString());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    S
                        .of(context)
                        .you_have_received_responses
                        .replaceFirst(
                            '**', borrowAcceptorModel.length.toString())
                        .replaceFirst(
                            '***', borrowAcceptorModel.length > 1 ? 's' : ''),
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    S.of(context).lenders_text,
                    style: TextStyle(color: Colors.grey, fontSize: 22),
                  ),
                ),
                SizedBox(height: 15),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: borrowAcceptorModel.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (borrowAcceptorModel != null) {
                        return requestModel.roomOrTool ==
                                LendingType.ITEM.readable
                            ? FutureBuilder<List<LendingModel>>(
                                future:
                                    LendingOffersRepo.getApprovedLendingModels(
                                        lendingModelsIds:
                                            borrowAcceptorModel[index]
                                                .borrowedItemsIds),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return LoadingIndicator();
                                  }
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  List<LendingModel> lendingModelList =
                                      snapshot.data!;

                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                    child: Container(
                                      // width: 400,
                                      // height: 250,
                                      child: BorrowRequestParticipantsCard(
                                        requestModel: requestModel,
                                        borrowAcceptorModel:
                                            borrowAcceptorModel[index],
                                        context: context,
                                        lendingModelList: lendingModelList,
                                        onImageTap: () {
                                          logger.d(
                                              "@@REQ ${borrowAcceptorModel[index].acceptorId}");
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ProfileViewer(
                                              timebankId: timebankModel.id,
                                              entityName: timebankModel.name,
                                              isFromTimebank: isPrimaryTimebank(
                                                  parentTimebankId:
                                                      timebankModel
                                                          .parentTimebankId),
                                              userId: borrowAcceptorModel[index]
                                                  .acceptorId,
                                              userEmail:
                                                  borrowAcceptorModel[index]
                                                      .acceptorEmail,
                                            );
                                          }));
                                        },
                                        buttonsContainer:
                                            ((requestModel.borrowModel!
                                                        .itemsCollected!) &&
                                                    requestModel.approvedUsers!
                                                        .contains(
                                                            borrowAcceptorModel[
                                                                    index]
                                                                .acceptorEmail))
                                                ? Chip(
                                                    label: Text(
                                                      (requestModel.borrowModel!
                                                                  .itemsCollected! &&
                                                              requestModel
                                                                  .borrowModel!
                                                                  .itemsReturned!)
                                                          ? S
                                                              .of(context)
                                                              .items_returned
                                                          : S
                                                              .of(context)
                                                              .items_collected,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11),
                                                    ),
                                                  )
                                                : Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        !requestModel
                                                                    .borrowModel!
                                                                    .itemsCollected! &&
                                                                !requestModel
                                                                    .borrowModel!
                                                                    .itemsReturned!
                                                            ? ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  shape:
                                                                      new RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        new BorderRadius
                                                                            .circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  if (requestModel
                                                                          .approvedUsers!
                                                                          .length <=
                                                                      0) {
                                                                    var notificationId = await readBorrowerRequestAcceptNotification(
                                                                        fromNotification:
                                                                            false,
                                                                        borrowAcceptorModel:
                                                                            borrowAcceptorModel[
                                                                                index],
                                                                        requestModel:
                                                                            requestModel);
                                                                    logger.e(
                                                                        'NOTIFICATION ID RECEIVED 1:  ' +
                                                                            notificationId);
                                                                    //Creator accepts lender
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CreatorApproveAcceptorAgreeement(
                                                                          requestModel:
                                                                              requestModel,
                                                                          timeBankId:
                                                                              requestModel.timebankId!,
                                                                          userId: SevaCore.of(context)
                                                                              .loggedInUser
                                                                              .sevaUserID!,
                                                                          parentContext:
                                                                              context,
                                                                          acceptorUserModel: getUserModel(
                                                                              userModelList,
                                                                              borrowAcceptorModel[index].acceptorEmail!),
                                                                          notificationId:
                                                                              notificationId,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    //show dialog
                                                                    await alreadyAcceptedLenderDialog(
                                                                        context,
                                                                        requestModel
                                                                            .roomOrTool!);
                                                                  }
                                                                },
                                                                child: Text(
                                                                  requestModel
                                                                          .approvedUsers!
                                                                          .contains(borrowAcceptorModel[index]
                                                                              .acceptorEmail)
                                                                      ? S
                                                                          .of(
                                                                              context)
                                                                          .accepted
                                                                      : S
                                                                          .of(context)
                                                                          .accept,
                                                                  style: TextStyle(
                                                                      color: requestModel.approvedUsers!.length > 0
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black,
                                                                      fontSize:
                                                                          11.5),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  );
                                })
                            : FutureBuilder<LendingModel>(
                                future: LendingOffersRepo.getLendingModel(
                                    lendingId: borrowAcceptorModel[index]
                                        .borrowedPlaceId!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return LoadingIndicator();
                                  }
                                  if (snapshot.data == null) {
                                    return Container();
                                  }
                                  LendingModel lendingModelList =
                                      snapshot.data!;

                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 0),
                                    child: Container(
                                      // width: 400,
                                      // height: 250,
                                      child: BorrowRequestParticipantsCard(
                                        requestModel: requestModel,
                                        borrowAcceptorModel:
                                            borrowAcceptorModel[index],
                                        context: context,
                                        lendingPlaceModel: lendingModelList,
                                        onImageTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ProfileViewer(
                                              timebankId: timebankModel.id,
                                              entityName: timebankModel.name,
                                              isFromTimebank: isPrimaryTimebank(
                                                  parentTimebankId:
                                                      timebankModel
                                                          .parentTimebankId),
                                              userId: borrowAcceptorModel[index]
                                                  .acceptorId,
                                              userEmail:
                                                  borrowAcceptorModel[index]
                                                      .acceptorEmail,
                                            );
                                          }));
                                        },
                                        buttonsContainer:
                                            ((requestModel.borrowModel!
                                                        .isCheckedIn!) &&
                                                    requestModel.approvedUsers!
                                                        .contains(
                                                            borrowAcceptorModel[
                                                                    index]
                                                                .acceptorEmail))
                                                ? Chip(
                                                    label: Text(
                                                      (requestModel.borrowModel!
                                                                  .isCheckedIn! &&
                                                              requestModel
                                                                  .borrowModel!
                                                                  .isCheckedOut!)
                                                          ? S
                                                              .of(context)
                                                              .checked_out_text
                                                          : S
                                                              .of(context)
                                                              .checked_in_text,
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11),
                                                    ),
                                                  )
                                                : Container(
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        !requestModel
                                                                    .borrowModel!
                                                                    .isCheckedIn! &&
                                                                !requestModel
                                                                    .borrowModel!
                                                                    .isCheckedOut!
                                                            ? ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  shape:
                                                                      new RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        new BorderRadius
                                                                            .circular(
                                                                            30.0),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  if (requestModel
                                                                          .approvedUsers!
                                                                          .length <=
                                                                      0) {
                                                                    var notificationId = await readBorrowerRequestAcceptNotification(
                                                                        fromNotification:
                                                                            false,
                                                                        borrowAcceptorModel:
                                                                            borrowAcceptorModel[
                                                                                index],
                                                                        requestModel:
                                                                            requestModel);
                                                                    logger.e(
                                                                        'NOTIFICATION ID RECEIVED 2:  ' +
                                                                            notificationId);
                                                                    //Creator accepts lender
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CreatorApproveAcceptorAgreeement(
                                                                          requestModel:
                                                                              requestModel,
                                                                          timeBankId:
                                                                              requestModel.timebankId!,
                                                                          userId: SevaCore.of(context)
                                                                              .loggedInUser
                                                                              .sevaUserID!,
                                                                          parentContext:
                                                                              context,
                                                                          acceptorUserModel: getUserModel(
                                                                              userModelList,
                                                                              borrowAcceptorModel[index].acceptorEmail!),
                                                                          notificationId:
                                                                              notificationId,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    //show dialog
                                                                    await alreadyAcceptedLenderDialog(
                                                                        context,
                                                                        requestModel
                                                                            .roomOrTool!);
                                                                  }
                                                                },
                                                                child: Text(
                                                                  requestModel
                                                                          .approvedUsers!
                                                                          .contains(borrowAcceptorModel[index]
                                                                              .acceptorEmail)
                                                                      ? S
                                                                          .of(
                                                                              context)
                                                                          .accepted
                                                                      : S
                                                                          .of(context)
                                                                          .accept,
                                                                  style: TextStyle(
                                                                      color: requestModel.approvedUsers!.length > 0
                                                                          ? Colors
                                                                              .grey
                                                                          : Colors
                                                                              .black,
                                                                      fontSize:
                                                                          11.5),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                      ),
                                    ),
                                  );
                                });
                      } else {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(S.of(context).error_loading_data),
                          ),
                        );
                      }
                    }),
              ],
            );
          },
        ),
      ),
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

UserModel getUserModel(List<UserModel> userModelList, String email) {
  UserModel userModel;
  userModel = userModelList.firstWhere((element) => element.email == email);
  return userModel;
}

Future<dynamic> alreadyAcceptedLenderDialog(
    BuildContext context, String roomOrTool) {
  return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.width * 0.36,
            child: Column(
              children: [
                SizedBox(height: 10),
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
                SizedBox(height: 25),
                Text(roomOrTool == LendingType.PLACE.readable
                    ? S.of(context).already_accepted_lender_place
                    : S.of(context).already_accepted_lender_item),
              ],
            ),
          ),
        );
      });
}

// List<Widget> getActions({
//   OfferAcceptanceStatus status,
//   OfferBloc bloc,
//   String offerId,
//   String acceptorDoumentId,
//   String notificationId,
//   String hostEmail,
//   BuildContext context,
//   UserModel user,
// }) {
//   switch (status) {
//     case OfferAcceptanceStatus.ACCEPTED:
//       return [
//         CustomElevatedButton(
//           color: Colors.green,
//           onPressed: () async {},
//           child: Text(
//             'Approved',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//         SizedBox(
//           width: 5,
//         ),
//       ];

//     case OfferAcceptanceStatus.REJECTED:
//       return [
//         CustomElevatedButton(
//           color: Colors.red,
//           onPressed: () {},
//           child: Text(
//             'Declined',
//             style: TextStyle(color: Colors.white),
//           ),
//         )
//       ];

//     case OfferAcceptanceStatus.REQUESTED:
//       return [
//         IconButton(
//           icon: Icon(
//             Icons.chat_bubble,
//             color: Colors.grey,
//           ),
//           iconSize: 30,
//           onPressed: null,
//         ),
//         SizedBox(
//           width: 5,
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             primary: Colors.grey[300],
//             shape: new RoundedRectangleBorder(
//               borderRadius: new BorderRadius.circular(30.0),
//             ),
//           ),
//           onPressed: () async {
//             //on approve functionality here.

//             //Dialog box also to restrict approving more than one Borrower at a time.
//             bool isCurrentlyLent = true;
//             if (isCurrentlyLent) {
//               await cannotApproveMultipleDialog(context);
//             }
//             // bloc.updateOfferAcceptorAction(
//             //   notificationId: notificationId,
//             //   acceptorDocumentId: acceptorDoumentId,
//             //   offerId: offerId,
//             //   action: OfferAcceptanceStatus.ACCEPTED,
//             //   hostEmail: hostEmail,
//             // );
//           },
//           child: Text(
//             S.of(context).approve,
//             style: TextStyle(color: Colors.black, fontSize: 11.5),
//           ),
//         ),
//         SizedBox(
//           width: 8,
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             primary: Colors.grey[300],
//             shape: new RoundedRectangleBorder(
//               borderRadius: new BorderRadius.circular(30.0),
//             ),
//           ),
//           onPressed: () {
//             // bloc.updateOfferAcceptorAction(
//             //   notificationId: notificationId,
//             //   acceptorDocumentId: acceptorDoumentId,
//             //   offerId: offerId,
//             //   // action: OfferAcceptanceStatus.REJECTED,
//             //   hostEmail: hostEmail,
//             // );
//           },
//           child: Padding(
//             padding: const EdgeInsets.only(left: 4.0, right: 4.0),
//             child: Text(
//               S.of(context).reject,
//               style: TextStyle(color: Colors.black, fontSize: 11.5),
//             ),
//           ),
//         )
//       ];
//   }
// }
