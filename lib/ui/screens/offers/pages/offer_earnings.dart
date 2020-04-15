import 'package:flutter/material.dart';
import 'package:sevaexchange/models/offer_participants_model.dart';
import 'package:sevaexchange/ui/screens/offers/bloc/offer_bloc.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/member_card_with_single_action.dart';
import 'package:sevaexchange/ui/screens/offers/widgets/seva_coin_star.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';

class OfferEarnings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<OfferBloc>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: StreamBuilder<List<OfferParticipantsModel>>(
            stream: _bloc.participants,
            builder: (context, snapshot) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SevaCoinStarWidget(
                        title: 'Your earnings',
                        amount: '2591',
                      ),
                      SevaCoinStarWidget(
                        title: 'Your earnings',
                        amount: '591',
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        ParticipantStatus status = ParticipantStatus.values
                            .firstWhere((v) =>
                                v.toString() ==
                                'ParticipantStatus.' +
                                    snapshot.data[index].status);
                        return MemberCardWithSingleAction(
                          name: snapshot.data[index].fullname,
                          timestamp: "Dec 15",
                          onMessagePressed: () {},
                          action: () {},
                          status: getParticipantStatus(status),
                          photoUrl: snapshot.data[index].photourl,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                    ),
                  )
                ],
              );
            }),
      ),
    );
  }
}
