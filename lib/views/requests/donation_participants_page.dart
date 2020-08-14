import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/requests/donations/donation_accepted_bloc.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/participant_card.dart';

class DonationParticipantPage extends StatelessWidget {
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
        return ListView.builder(
          itemCount: 2,
          itemBuilder: (_, index) {
            DonationModel model = snapshot.data[index];
            return RequestParticipantCard(
              name: "model.don",
              bio: "Ada",
              buttonTitle: S.of(context).accepted,
            );
          },
        );
      },
    );
  }
}
