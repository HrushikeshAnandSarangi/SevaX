import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/amount_raised_progress_indicator.dart';
import 'package:sevaexchange/ui/screens/request/widgets/donation_participant_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class DonationCompletedPage extends StatelessWidget {
  final RequestModel requestModel;

  const DonationCompletedPage({Key key, this.requestModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<DonationAcceptedBloc>(context);
    return StreamBuilder(
      stream: _bloc.donations,
      builder: (BuildContext _, AsyncSnapshot<List<DonationModel>> snapshot) {
        if (snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.hasError) {
          return Text(S.of(context).general_stream_error);
        }

        List<DonationModel> donations = [];
        int totalAmountRaised = 0;
        snapshot.data.forEach((donation) {
          if (donation.donationStatus == DonationStatus.ACKNOWLEDGED) {
            totalAmountRaised += donation.cashDetails.pledgedAmount;
            donations.add(donation);
          }
        });
        if (donations.isEmpty) {
          return Center(
            child: Text('No Donations Yet'),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              AmountRaisedProgressIndicator(
                totalAmountRaised: totalAmountRaised,
                targetAmount: requestModel.cashModel.targetAmount,
              ),
              SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (_, index) {
                  DonationModel model = donations[index];
                  return DonationParticipantCard(
                    name: model.donorDetails.name,
                    isCashDonation: model.donationType == RequestType.CASH,
                    goods: model.goodsDetails?.donatedGoods != null
                        ? List<String>.from(
                            model.goodsDetails.donatedGoods.values,
                          )
                        : [],
                    photoUrl: model.donorDetails.photoUrl,
                    amount: model.cashDetails.pledgedAmount.toString(),
                    timestamp: model.timestamp,
                  );
                },
                separatorBuilder: (_, index) {
                  return Divider();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
