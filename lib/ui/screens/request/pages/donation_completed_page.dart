import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/donation_participant_card.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
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
        int totalQuantity = 0;

        snapshot.data.forEach((donation) {
          if (donation.donationStatus == DonationStatus.ACKNOWLEDGED) {
            if (requestModel.requestType == RequestType.CASH) {
              totalQuantity += donation.cashDetails.pledgedAmount;
            } else {
              totalQuantity += donation.goodsDetails.donatedGoods.length;
            }
            donations.add(donation);
          }
        });

        if (donations.isEmpty) {
          return Center(
            child: Text(S.of(context).no_donation_yet),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _DonationProgressWidget(
                isCashDonation: requestModel.requestType == RequestType.CASH,
                quantity:
                    totalQuantity.toString(), //update to support goods quantity
              ),
              // AmountRaisedProgressIndicator(
              //   totalQuantity: totalQuantity,
              //   targetAmount: requestModel.cashModel.targetAmount,
              // ),
              Divider(),
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
                    comments: model.goodsDetails.comments,
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

class _DonationProgressWidget extends StatelessWidget {
  final bool isCashDonation;
  final String quantity;
  const _DonationProgressWidget({
    Key key,
    this.isCashDonation,
    this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${S.of(context).total} ${isCashDonation ? '${S.of(context).donations}' : S.of(context).goods} ${S.of(context).received}',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Image.asset(
              isCashDonation
                  ? SevaAssetIcon.donateCash
                  : SevaAssetIcon.donateGood,
              width: 35,
              height: 35,
            ),
            SizedBox(width: 12),
            isCashDonation
                ? Text(
                    '\$$quantity',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      text: '$quantity',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(text: ' '),
                        TextSpan(
                          text: S.of(context).donations,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
