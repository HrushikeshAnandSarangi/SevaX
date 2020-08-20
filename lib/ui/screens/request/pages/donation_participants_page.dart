import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/donation_approve_model.dart';
import 'package:sevaexchange/models/donation_model.dart';
import 'package:sevaexchange/models/request_model.dart';
import 'package:sevaexchange/ui/screens/request/bloc/donation_accepted_bloc.dart';
import 'package:sevaexchange/ui/screens/request/pages/request_donation_dispute_page.dart';
import 'package:sevaexchange/ui/screens/request/widgets/donation_participant_card.dart';
import 'package:sevaexchange/utils/bloc_provider.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/requests/donations/approve_donation_dialog.dart';
import 'package:sevaexchange/views/timebanks/widgets/loading_indicator.dart';

class DonationParticipantPage extends StatelessWidget {
  final RequestModel requestModel;

  const DonationParticipantPage({Key key, this.requestModel}) : super(key: key);
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
        return ListView.separated(
          padding: EdgeInsets.all(20),
          itemCount: snapshot.data.length,
          itemBuilder: (_, index) {
            DonationModel model = snapshot.data[index];
            // DonationButtonActionModel buttonStatus =
            //     buttonActionModel(context, model);
            // return RequestParticipantCard(
            //   name: model.donorDetails.name,
            //   bio: model.donorDetails.bio,
            //   imageUrl: model.donorDetails.photoUrl,
            //   buttonTitle: buttonStatus.buttonText,
            //   buttonColor: buttonStatus.buttonColor,
            //   onTap: buttonStatus.onTap,
            // );
            return DonationParticipantCard(
              name: model.donorDetails.name,
              isCashDonation: model.donationType == RequestType.CASH,
              goods: model.goodsDetails?.donatedGoods != null
                  ? List<String>.from(model.goodsDetails.donatedGoods.values)
                  : [],
              photoUrl: model.donorDetails.photoUrl,
              amount: model.cashDetails.pledgedAmount.toString(),
              comments: model.goodsDetails.comments,
              timestamp: model.timestamp,
              child: model.donationStatus != DonationStatus.ACKNOWLEDGED
                  ? Container(
                      height: 20,
                      child: RaisedButton(
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        child: Text(
                          S.of(context).acknowledge,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestDonationDisputePage(model: model),
                            ),
                          );
                        },
                      ),
                    )
                  : null,
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
          onTap: null,
          buttonText: 'ACKLOWLEDGED',
        );
        break;
      case DonationStatus.PLEDGED:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          onTap: () => onPledged(context, model),
          buttonText: 'ACKNOWLEDGE',
        );
        break;

      case DonationStatus.MODIFIED:
        return DonationButtonActionModel(
          buttonColor: Colors.red,
          //TODO: Update methods accordingly
          buttonText: 'MODIFIED',
        );
        break;
      case DonationStatus.APPROVED_BY_DONOR:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          //TODO: Update methods accordingly
          buttonText: 'ACKNOWLEDGE',
        );
        break;
      case DonationStatus.APPROVED_BY_CREATOR:
        return DonationButtonActionModel(
          buttonColor: Colors.green,
          //TODO: Update methods accordingly
          buttonText: 'ACKNOWLEDGE',
        );
        break;
      default:
        Crashlytics.instance.log(
            'UnImplemented DonationStatus case ${model.donationStatus.toString()}');
        log('UnImplemented DonationStatus case ${model.donationStatus.toString()}');
        return DonationButtonActionModel(
          buttonColor: Colors.grey,
          buttonText: 'UN-IMPLEMENTED',
        );
    }
  }

  void onPledged(BuildContext context, DonationModel model) {
    showDialog(
      context: context,
      builder: (_context) {
        return ApproveDonationDialog(
          requestModel: requestModel,
          donationApproveModel: DonationApproveModel(
            donorName: model.donorDetails.name,
            donorEmail: model.donorDetails.email,
            donorPhotoUrl: model.donorDetails.photoUrl,
            donationId: model.id,
            donationDetails:
                '${model.donationType == RequestType.CASH ? model.cashDetails.pledgedAmount.toString() : model.donationType == RequestType.GOODS ? '${model.goodsDetails.donatedGoods.values} \n' + '\n' + model.goodsDetails.comments ?? ' ' : 'time'}',
            donationType: model.donationType,
            requestId: requestModel.id,
            requestTitle: requestModel.title,
          ),
          timeBankId: requestModel.timebankId,
          notificationId: model.notificationId,
          userId: SevaCore.of(context).loggedInUser.sevaUserID,
          parentContext: context,
          onTap: () {
            log('show dialog');
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestDonationDisputePage(model: model),
              ),
            );
            // showDialog(
            //   context: context,
            //   builder: (context) =>
            //       requestDonationAcknowledgementDialog(context),
            // );
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

  DonationButtonActionModel({this.buttonColor, this.buttonText, this.onTap});
}
