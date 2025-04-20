import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/pages/time_offer_participant.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/member_card_with_single_action.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/seva_coin_star.dart';
import 'package:sevaexchange/ui/utils/helpers.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/profile/profileviewer.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class TimeOfferEarnings extends StatelessWidget {
  final OfferModel? offerModel;
  final TimebankModel? timebankModel;

  const TimeOfferEarnings({Key? key, this.offerModel, this.timebankModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: StreamBuilder<List<TimeOfferParticipantsModel>>(
          stream: _bloc!.completedParticipants,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator();
            }
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return Container(
                margin: EdgeInsets.only(top: 20, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SevaCoinStarWidget(
                      title: S.of(context).your_earnings,
                      amount: '0',
                    ),
                    Divider(),
                  ],
                ),
              );
            }

            return StreamBuilder<num>(
                stream: _bloc.totalEarnings,
                builder: (context, earnings) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SevaCoinStarWidget(
                            title: S.of(context).your_earnings,
                            amount: "${earnings.data}",
                          ),
                        ],
                      ),
                      Divider(),
                      Expanded(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return MemberCardWithSingleAction(
                              name: snapshot
                                  .data![index].participantDetails.fullname!,
                              timestamp: DateFormat.MMMd().format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  snapshot.data![index].timestamp,
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
                                        .data![index].participantDetails.email,
                                  );
                                }));
                              },
                              onMessagePressed: () {},
                              action: () {},
                              status: snapshot.data![index].status.readable,
                              photoUrl: snapshot
                                  .data![index].participantDetails.photourl!,
                              buttonColor: Colors.green,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                        ),
                      )
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
