import 'dart:developer';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sevaexchange/l10n/l10n.dart';
// import 'package:sevaexchange/labels.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/offer_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/ui/screens/request/widgets/donation_participant_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/utils/soft_delete_manager.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/approve_donation_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class DonationParticipantPage extends StatelessWidget {
  final RequestModel? requestModel;
  final OfferModel? offermodel;

  const DonationParticipantPage({Key? key, this.requestModel, this.offermodel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<DonationAcceptedBloc>(context);
    final _offerbloc = BlocProvider.of<DonationAcceptedOfferBloc>(context);
    double? convertedAmount;
    double? convertedOfferAmount;

    return StreamBuilder(
      stream: requestModel != null ? _bloc!.donations : _offerbloc!.donations,
      builder: (BuildContext _, AsyncSnapshot<List<DonationModel>> snapshot) {
        if (snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator();
        }
        if (snapshot.hasError) {
          return Text(S.of(context).general_stream_error);
        }
        return ListView.separated(
          padding: EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (_, index) {
            DonationModel model = snapshot.data![index];
            log(
              '${model.lastModifiedBy == model.donatedTo}  ${model.lastModifiedBy}  ${model.donatedTo}',
              name: 'DonationParticipantPage',
            );
            return DonationParticipantCard(
              currency: model.requestIdType == 'offer'
                  ? model.cashDetails!.cashDetails!.offerCurrencyType!
                  : model.cashDetails!.cashDetails!.requestCurrencyType!,
              type: requestModel != null ? 'request' : 'offer',
              name: requestModel != null
                  ? model.donorDetails!.name!
                  : model.receiverDetails!.name!,
              isCashDonation: model.donationType == RequestType.CASH,
              goods: model.donationStatus == DonationStatus.REQUESTED
                  ? (model.goodsDetails?.requiredGoods != null
                      ? List<String>.from(
                          model.goodsDetails!.requiredGoods!.values!)
                      : <String>[])
                  : (model.goodsDetails?.donatedGoods != null
                      ? List<String>.from(
                          model.goodsDetails!.donatedGoods!.values!)
                      : <String>[]),
              status: model.donationStatus!,
              photoUrl: requestModel != null
                  ? (model.donorDetails?.photoUrl ?? '')
                  : (model.receiverDetails?.photoUrl ?? ''),
              amount: model.cashDetails!.pledgedAmount.toString(),
              comments: model.goodsDetails!.comments!,
              timestamp: model.timestamp!,
              child: model.donationStatus == DonationStatus.ACKNOWLEDGED
                  ? const SizedBox.shrink()
                  : model.donationStatus == DonationStatus.REQUESTED
                      ? Container(
                          height: 20,
                          child: CustomElevatedButton(
                            color: Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            textColor: Colors.black,
                            child: Text(
                              S.of(context).donate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              ProgressDialog? progressDialog;
                              if (model.donationType == RequestType.CASH) {
                                progressDialog = ProgressDialog(context,
                                    customBody: Container(
                                      height: 100,
                                      width: 100,
                                      child: LoadingIndicator(),
                                    ));
                                if ((model.cashDetails?.cashDetails
                                            ?.offerDonatedCurrencyType ??
                                        '') !=
                                    (model.cashDetails?.cashDetails
                                            ?.offerCurrencyType ??
                                        '')) {
                                  await progressDialog.show();
                                }
                                await progressDialog?.hide();

                                convertedOfferAmount = await currencyConversion(
                                    fromCurrency: model.cashDetails?.cashDetails
                                            ?.offerDonatedCurrencyType ??
                                        '',
                                    toCurrency: model.cashDetails?.cashDetails
                                            ?.offerCurrencyType ??
                                        '',
                                    amount: model.cashDetails?.cashDetails
                                            ?.amountRaised ??
                                        0.0);
                                await progressDialog?.hide();
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RequestDonationDisputePage(
                                    model: model,
                                    notificationId: model.notificationId ?? '',
                                    convertedAmountRaised:
                                        convertedOfferAmount ?? 0.0,
                                    convertedAmount: 0.0,
                                    currency: offermodel
                                            ?.cashModel?.offerCurrencyType ??
                                        '',
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : model.lastModifiedBy == model.donatedTo
                          ? const SizedBox.shrink()
                          : !(model.donationStatus == DonationStatus.PLEDGED &&
                                  model.requestIdType == 'offer')
                              ? Container(
                                  child: CustomElevatedButton(
                                    color: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 2,
                                    textColor: Colors.black,
                                    child: Text(
                                      S.of(context).acknowledge,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RequestDonationDisputePage(
                                                  model: model,
                                                  notificationId:
                                                      model
                                                              .notificationId ??
                                                          '',
                                                  convertedAmountRaised: model
                                                              .requestIdType ==
                                                          'offer'
                                                      ? (convertedAmount ?? 0.0)
                                                      : 0.0,
                                                  convertedAmount:
                                                      model.cashDetails
                                                              ?.pledgedAmount ??
                                                          0.0,
                                                  currency: model
                                                              .requestIdType ==
                                                          'offer'
                                                      ? (model
                                                              .cashDetails
                                                              ?.cashDetails
                                                              ?.offerCurrencyType ??
                                                          '')
                                                      : (model
                                                              .cashDetails
                                                              ?.cashDetails
                                                              ?.requestCurrencyType ??
                                                          '')),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Text(S.of(context).waiting_acknowledgement),
            );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        );
      },
    );
  }

  DonationButtonActionModel buttonActionModel(
      BuildContext context, DonationModel model) {
    switch (model.donationStatus) {
      case DonationStatus.ACKNOWLEDGED:
        return DonationButtonActionModel(
          buttonColor: Theme.of(context).primaryColor,
          onTap: () {},
          buttonText: S.of(context).acknowledged,
        );
      case DonationStatus.PLEDGED:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          onTap: () => onPledged(context, model),
          buttonText: S.of(context).acknowledge.toUpperCase(),
        );

      case DonationStatus.MODIFIED:
        return DonationButtonActionModel(
          buttonColor: Colors.red,
          onTap: () {},
          buttonText: '${S.of(context).modified.toUpperCase()}',
        );
      case DonationStatus.APPROVED_BY_DONOR:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          onTap: () {},
          buttonText: S.of(context).acknowledge.toUpperCase(),
        );
      case DonationStatus.APPROVED_BY_CREATOR:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          onTap: () {},
          buttonText: S.of(context).acknowledge.toUpperCase(),
        );
      default:
        // FirebaseCrashlytics.instance.log(
        //     'UnImplemented DonationStatus case ${model.donationStatus.toString()}');
        return DonationButtonActionModel(
          buttonColor: Colors.grey,
          onTap: () {},
          buttonText: 'UN-IMPLEMENTED',
        );
    }
  }

  void onPledged(BuildContext context, DonationModel model) {
    showDialog(
      context: context,
      builder: (_context) {
        return ApproveDonationDialog(
          requestModel: requestModel!,
          offerModel: offermodel!,
          donationApproveModel: DonationApproveModel(
            donorName: model.donorDetails?.name ?? '',
            donorEmail: model.donorDetails?.email ?? '',
            donorPhotoUrl: model.donorDetails?.photoUrl ?? '',
            donationId: model.id,
            donationDetails:
                '${model.donationType == RequestType.CASH ? model.cashDetails?.pledgedAmount.toString() : model.donationType == RequestType.GOODS ? '${model.goodsDetails?.donatedGoods?.values ?? ''} \n' + '\n' + (model.goodsDetails?.comments ?? ' ') : 'time'}',
            donationType: model.donationType,
            requestId: requestModel?.id ?? '',
            requestTitle: requestModel != null && requestModel!.title != ''
                ? requestModel!.title
                : (offermodel != null &&
                        offermodel!.individualOfferDataModel != null)
                    ? offermodel!.individualOfferDataModel!.title
                    : '',
          ),
          timeBankId: requestModel?.timebankId ?? '',
          notificationId: model.notificationId ?? '',
          userId: SevaCore.of(context).loggedInUser.sevaUserID ?? '',
          parentContext: context,
          onTap: () {
            log('show dialog');
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestDonationDisputePage(
                  model: model,
                  notificationId: model.notificationId ?? '',
                  convertedAmount: 0.0,
                  currency: '',
                  convertedAmountRaised: 0.0,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DonationButtonActionModel {
  final Color buttonColor;
  final String buttonText;
  final VoidCallback onTap;

  DonationButtonActionModel({
    required this.buttonColor,
    required this.buttonText,
    required this.onTap,
  });
}
