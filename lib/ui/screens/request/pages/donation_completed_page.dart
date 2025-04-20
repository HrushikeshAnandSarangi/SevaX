import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/widgets/donation_participant_card.dart';
import 'package:sevaexchange/ui/utils/icons.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class DonationCompletedPage extends StatelessWidget {
  final RequestModel? requestModel;
  final OfferModel? offermodel;

  const DonationCompletedPage({Key? key, this.requestModel, this.offermodel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<DonationAcceptedBloc>(context);
    final _blocOffer = BlocProvider.of<DonationAcceptedOfferBloc>(context);
    return StreamBuilder(
      stream: requestModel != null ? _bloc!.donations : _blocOffer!.donations,
      builder: (BuildContext _, AsyncSnapshot<List<DonationModel>> snapshot) {
        var type = requestModel != null
            ? requestModel!.requestType
            : offermodel != null
                ? offermodel!.type
                : '';
        if (snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.hasError) {
          return Text(S.of(context).general_stream_error);
        }

        List<DonationModel> donations = [];
        double totalQuantity = 0;
        String? currency;
        snapshot.data!.forEach((donation) {
          if (donation.donationStatus == DonationStatus.ACKNOWLEDGED) {
            if (type == RequestType.CASH) {
              totalQuantity += donation.requestIdType == 'offer'
                  ? donation.cashDetails!.pledgedAmount!
                  : donation.cashDetails!.pledgedAmount!;
              currency = donation.requestIdType == 'offer'
                  ? donation.cashDetails!.cashDetails!.offerCurrencyType!
                  : donation.cashDetails!.cashDetails!.requestCurrencyType!;
            } else {
              totalQuantity += donation.goodsDetails!.donatedGoods!.length;
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
                currency: currency ?? '',
                type: requestModel != null ? 'request' : 'offer',
                isCashDonation: type == RequestType.CASH,
                quantity: totalQuantity
                    .toStringAsFixed(2), //update to support goods quantity
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
                  log('goods --->' +
                      model.goodsDetails!.donatedGoods.toString());
                  return DonationParticipantCard(
                    amount: model.cashDetails!.pledgedAmount.toString(),
                    currency: model.requestIdType == 'offer'
                        ? model.cashDetails!.cashDetails!.offerCurrencyType!
                        : model.cashDetails!.cashDetails!.requestCurrencyType!,
                    name: model.donorDetails!.name!,
                    isCashDonation: model.donationType == RequestType.CASH,
                    goods: model.goodsDetails?.donatedGoods != null
                        ? List<String>.from(
                            model.goodsDetails!.donatedGoods!.values,
                          )
                        : [],
                    photoUrl: model.donorDetails!.photoUrl!,
                    timestamp: model.timestamp!,
                    comments:
                        '', // Replace with the correct property if available, or leave as empty string
                    type: model.donationType!
                        .toString(), // Add the required 'type' parameter as String
                    status: model
                        .donationStatus!, // Add the required 'status' parameter
                    child: const SizedBox
                        .shrink(), // Provide a placeholder for 'child'
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
  final bool? isCashDonation;
  final String? quantity;
  final String? type;
  final String? currency;

  const _DonationProgressWidget({
    Key? key,
    this.type,
    this.isCashDonation,
    this.quantity,
    this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${S.of(context).total} ${isCashDonation! ? '${S.of(context).donations}' : S.of(context).goods} ${this.type == 'request' ? S.of(context).received : S.of(context).offered}',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Image.asset(
              isCashDonation!
                  ? SevaAssetIcon.donateCash
                  : SevaAssetIcon.donateGood,
              width: 35,
              height: 35,
            ),
            SizedBox(width: 12),
            isCashDonation!
                ? Text(
                    '${currency} $quantity',
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
