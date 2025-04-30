import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/member_card_with_single_action.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/seva_coin_star.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class OfferEarnings extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const OfferEarnings({Key? key, this.offerModel, this.timebankModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: StreamBuilder<List<OfferParticipantsModel>>(
          stream: _bloc!.participants,
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Text(S.of(context).no_offers),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            DateTime _endTime = DateTime.fromMillisecondsSinceEpoch(
              offerModel!.groupOfferDataModel!.endDate!,
            );
            // Duration _durationLeft = _endTime.difference(DateTime.now());
            bool _isOfferOver = DateTime.now().isAfter(_endTime);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SevaCoinStarWidget(
                      title: S.of(context).your_earnings,
                      amount: offerModel!.groupOfferDataModel!.creditStatus == 1
                          ? (offerModel!.groupOfferDataModel!
                                      .numberOfClassHours! +
                                  offerModel!.groupOfferDataModel!
                                      .numberOfPreperationHours!)!
                              .toString()
                          : '0',
                    ),
                    SevaCoinStarWidget(
                      title: S.of(context).timebank_earnings,
                      amount: offerModel!.groupOfferDataModel!.creditStatus == 1
                          ? (offerModel!.groupOfferDataModel!.creditsApproved! -
                                  (offerModel!.groupOfferDataModel!
                                          .numberOfClassHours! +
                                      offerModel!.groupOfferDataModel!
                                          .numberOfPreperationHours!))
                              .toString()
                          : '0',
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ParticipantStatus status = ParticipantStatus.values
                          .firstWhere((v) =>
                              v.toString() ==
                              'ParticipantStatus.' +
                                  snapshot.data![index].status!);

                      if (_isOfferOver == true &&
                          status ==
                              ParticipantStatus
                                  .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER) {
                        status = ParticipantStatus.NO_ACTION_FROM_CREATOR;
                      }
                      return MemberCardWithSingleAction(
                        name:
                            snapshot.data![index].participantDetails!.fullname!,
                        timestamp: DateFormat.MMMd().format(
                          DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data![index].timestamp!,
                          ),
                        ),
                        onImageTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProfileViewer(
                              timebankId: timebankModel!.id,
                              entityName: timebankModel!.name,
                              isFromTimebank: isPrimaryTimebank(
                                  parentTimebankId:
                                      timebankModel!.parentTimebankId),
                              userEmail: snapshot
                                  .data![index].participantDetails!.email,
                            );
                          }));
                        },
                        onMessagePressed: () {},
                        action: () {
                          // print(_endTime.toString());
                          // if (_isOfferOver) {
                          //   _bloc.handleRequestActions(context, index, status);
                          // } else {
                          //   timeEndWarning(
                          //     context,
                          //     _durationLeft,
                          //   );
                          // }
                        },
                        //removed the status of user because of the updated flow//need change in ui
                        status: getParticipantStatus(ParticipantStatus
                            .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER),
                        photoUrl:
                            snapshot.data![index].participantDetails!.photourl!,
                        buttonColor: getStatusColor(ParticipantStatus
                            .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  // void handleActions(context, ParticipantStatus status, String documentId) {
  //   DocumentReference ref = CollectionRef
  //       offers
  //       .doc(offerModel.id)
  //       .collection("offerParticipants")
  //       .doc(documentId);
  //   if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
  //     ref.update(
  //       {
  //         "status":
  //             ParticipantStatus.NO_ACTION_FROM_CREATOR.toString().split('.')[1],
  //       },
  //     );
  //   }

  //   if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
  //     ref.update(
  //       {
  //         "status": ParticipantStatus.CREATOR_REQUESTED_CREDITS
  //             .toString()
  //             .split('.')[1]
  //       },
  //     );
  //   }

  //   if ([
  //     ParticipantStatus.MEMBER_DID_NOT_ATTEND,
  //     ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST,
  //     ParticipantStatus.MEMBER_TRANSACTION_FAILED
  //   ].contains(status)) {
  //     requestAgainDialog(context, ref);
  //   }
  // }
}

class OfferDonationRequest extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const OfferDonationRequest({Key? key, this.offerModel, this.timebankModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: StreamBuilder<List<OfferParticipantsModel>>(
          stream: _bloc!.participants,
          builder: (context, snapshot) {
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Center(
                child: Text(S.of(context).no_offers),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            DateTime _endTime = DateTime.fromMillisecondsSinceEpoch(
              offerModel!.groupOfferDataModel!.endDate!,
            );
            // Duration _durationLeft = _endTime.difference(DateTime.now());
            bool _isOfferOver = DateTime.now().isAfter(_endTime);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SevaCoinStarWidget(
                      title: S.of(context).your_earnings,
                      amount: offerModel!.groupOfferDataModel!.creditStatus == 1
                          ? (offerModel!.groupOfferDataModel!
                                      .numberOfClassHours! +
                                  offerModel!.groupOfferDataModel!
                                      .numberOfPreperationHours!)
                              .toString()
                          : '0',
                    ),
                    SevaCoinStarWidget(
                      title: S.of(context).timebank_earnings,
                      amount: offerModel!.groupOfferDataModel!.creditStatus == 1
                          ? (offerModel!.groupOfferDataModel!.creditsApproved! -
                                  (offerModel!.groupOfferDataModel!
                                          .numberOfClassHours! +
                                      offerModel!.groupOfferDataModel!
                                          .numberOfPreperationHours!))
                              .toString()
                          : '0',
                    ),
                  ],
                ),
                Divider(),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      ParticipantStatus status = ParticipantStatus.values
                          .firstWhere((v) =>
                              v.toString() ==
                              'ParticipantStatus.' +
                                  snapshot.data![index].status!);

                      if (_isOfferOver == true &&
                          status ==
                              ParticipantStatus
                                  .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER) {
                        status = ParticipantStatus.NO_ACTION_FROM_CREATOR;
                      }
                      return MemberCardWithSingleAction(
                        name:
                            snapshot.data![index].participantDetails!.fullname!,
                        timestamp: DateFormat.MMMd().format(
                          DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data![index].timestamp!,
                          ),
                        ),
                        onImageTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProfileViewer(
                              timebankId: timebankModel!.id,
                              entityName: timebankModel!.name,
                              isFromTimebank: isPrimaryTimebank(
                                  parentTimebankId:
                                      timebankModel!.parentTimebankId),
                              userEmail: snapshot
                                  .data![index].participantDetails!.email,
                            );
                          }));
                        },
                        onMessagePressed: () {},
                        action: () {
                          // print(_endTime.toString());
                          // if (_isOfferOver) {
                          //   _bloc.handleRequestActions(context, index, status);
                          // } else {
                          //   timeEndWarning(
                          //     context,
                          //     _durationLeft,
                          //   );
                          // }
                        },
                        //removed the status of user because of the updated flow//need change in ui
                        status: getParticipantStatus(ParticipantStatus
                            .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER),
                        photoUrl:
                            snapshot.data![index].participantDetails!.photourl!,
                        buttonColor: getStatusColor(ParticipantStatus
                            .MEMBER_SIGNED_UP_FOR_ONE2_MANY_OFFER),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

// void handleActions(context, ParticipantStatus status, String documentId) {
//   DocumentReference ref = CollectionRef
//       offers
//       .doc(offerModel.id)
//       .collection("offerParticipants")
//       .doc(documentId);
//   if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
//     ref.update(
//       {
//         "status":
//             ParticipantStatus.NO_ACTION_FROM_CREATOR.toString().split('.')[1],
//       },
//     );
//   }

//   if (status == ParticipantStatus.NO_ACTION_FROM_CREATOR) {
//     ref.update(
//       {
//         "status": ParticipantStatus.CREATOR_REQUESTED_CREDITS
//             .toString()
//             .split('.')[1]
//       },
//     );
//   }

//   if ([
//     ParticipantStatus.MEMBER_DID_NOT_ATTEND,
//     ParticipantStatus.MEMBER_REJECTED_CREDIT_REQUEST,
//     ParticipantStatus.MEMBER_TRANSACTION_FAILED
//   ].contains(status)) {
//     requestAgainDialog(context, ref);
//   }
// }
}
