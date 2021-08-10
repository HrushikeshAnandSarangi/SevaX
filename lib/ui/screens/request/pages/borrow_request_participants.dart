import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/borrow_accpetor_model.dart';
import 'package:sevaexchange/ui/screens/request/widgets/borrow_request_participants_card.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/utils/firestore_manager.dart' as FirestoreManager;
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class BorrowRequestParticipants extends StatelessWidget {
  final UserModel userModel;
  final TimebankModel timebankModel;
  final RequestModel requestModel;

  const BorrowRequestParticipants({
    Key key,
    this.userModel,
    this.timebankModel,
    this.requestModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder<List<BorrowAcceptorModel>>(
        stream: FirestoreManager.getBorrowRequestAcceptorsModelStream(
          requestId: requestModel.id,
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
          List<BorrowAcceptorModel> borrowAcceptorModel = snapshot.data;

          return ListView.builder(
              shrinkWrap: true,
              itemCount: borrowAcceptorModel == null
                  ? borrowAcceptorModel.length
                  : borrowAcceptorModel.length,
              itemBuilder: (BuildContext context, int index) {
                if (borrowAcceptorModel != null) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: Container(
                      // width: 400,
                      // height: 250,
                      child: BorrowRequestParticipantsCard(
                        imageUrl: userModel.photoURL,
                        requestModel: requestModel,
                        borrowAcceptorModel: borrowAcceptorModel[index],
                        context: context,
                        onImageTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProfileViewer(
                              timebankId: timebankModel.id,
                              entityName: timebankModel.name,
                              isFromTimebank: isPrimaryTimebank(
                                  parentTimebankId:
                                      timebankModel.parentTimebankId),
                              userEmail: userModel.email,
                            );
                          }));
                        },
                        buttonsContainer: Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.grey[300],
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () async {
                                  if (requestModel.approvedUsers.length <= 0) {
                                    return null;
                                  } else {
                                    logger.e(requestModel.approvedUsers.length
                                        .toString());
                                    //When Borrower Accepts here take to Accept Borrow Request Page
                                    //Change button status accordingly
                                    //copy enum states from lending offers or something else
                                    //Borrow to do
                                  }
                                },
                                child: Text(
                                  S.of(context).accept,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 11.5),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(S.of(context).error_loading_data),
                    ),
                  );
                }
              });
        },
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


