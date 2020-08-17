import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/amount_raised_progress_indicator.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20.0,
                ),
                child: AmountRaisedProgressIndicator(
                  totalAmountRaised: totalAmountRaised,
                  targetAmount: requestModel.cashModel.targetAmount,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: donations.length,
                itemBuilder: (_, index) {
                  DonationModel model = donations[index];
                  return RequestParticipantCard(
                    name: model.donorDetails.name,
                    imageUrl: model.donorDetails.photoUrl,
                    bio: model.donorDetails.bio,
                    buttonTitle: 'ACKNOWLEDGED',
                    buttonColor: Theme.of(context).primaryColor,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
