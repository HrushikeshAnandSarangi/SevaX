import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/timebank_model.dart';
import 'package:sevaexchange/ui/screens/offers/pages/individual_offer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class CreateOffer extends StatefulWidget {
  final String? timebankId;
  final TimebankModel? timebankModel;

  const CreateOffer({Key? key, this.timebankId, required this.timebankModel})
      : super(key: key);
  @override
  _CreateOfferState createState() => _CreateOfferState();
}

class _CreateOfferState extends State<CreateOffer> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return ExitWithConfirmation(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            S.of(context).create_offer,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            CommonHelpIconWidget(),
          ],
        ),
        body: IndividualOffer(
          timebankId: widget.timebankId!,
          loggedInMemberUserId: SevaCore.of(context).loggedInUser.sevaUserID!,
          timebankModel: widget.timebankModel!,
          offerModel:
              OfferModel(), // TODO: Replace null with an actual OfferModel instance if available
        ),
      ),
    );
  }
}
