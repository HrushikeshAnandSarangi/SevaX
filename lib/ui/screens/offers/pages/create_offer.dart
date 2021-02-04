import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sevaexchange/components/common_help_icon.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/ui/screens/offers/pages/individual_offer.dart';
import 'package:sevaexchange/ui/screens/offers/pages/one_to_many_offer.dart';
import 'package:sevaexchange/ui/screens/upgrade_plan_banners/pages/upgrade_plan_banner.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class CreateOffer extends StatefulWidget {
  final String timebankId;

  const CreateOffer({Key key, this.timebankId}) : super(key: key);
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
          // iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            S.of(context).create_offer,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            CommonHelpIconWidget(),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: getSwitchForGroupOffer(),
            ),
            Expanded(
              child: IndexedStack(
                index: currentPage,
                children: <Widget>[
                  IndividualOffer(
                    timebankId: widget.timebankId,
                  ),
                  TransactionsMatrixCheck.checkAllowedTransaction(
                          'onetomany_offers')
                      ? OneToManyOffer(
                          timebankId: widget.timebankId,
                        )
                      : UpgradePlanBanner(
                          activePlanName: AppConfig.paymentStatusMap['planId'],
                          details:
                              AppConfig.upgradePlanBannerModel.onetomany_offers,
                          showAppBar: false,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSwitchForGroupOffer() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      child: CupertinoSegmentedControl<int>(
        selectedColor: Theme.of(context).primaryColor,
        children: {
          0: Text(
            S.of(context).individual_offer,
            style: TextStyle(fontSize: 12.0),
          ),
          1: Text(
            S.of(context).one_to_many,
            style: TextStyle(fontSize: 12.0),
          ),
        },
        borderColor: Colors.grey,

        padding: EdgeInsets.only(left: 0.0, right: 0),
        groupValue: currentPage,
        onValueChanged: (int val) {
          if (val != currentPage) {
            AppConfig.helpIconContext = val == 0
                ? HelpIconContextClass.TIME_OFFERS
                : HelpIconContextClass.ONE_TO_MANY_OFFERS;
            setState(() {
              currentPage = val;
            });
          }
        },
        //groupValue: sharedValue,
      ),
    );
  }
}

//class EditIndividualOfferContainer extends StatelessWidget {
//  final OfferModel offerModel;
//  final String timebankId;
//  final OfferType type;
//
//  const EditIndividualOfferContainer(
//      {Key key, this.type, this.offerModel, this.timebankId})
//      : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return ExitWithConfirmation(
//        child: Container(
//            color: Colors.white24,
//            padding: EdgeInsets.only(left: 50, right: 120, top: 30),
//            child: CustomScrollWithKeyboard(
//                child: Container(
//              margin: EdgeInsets.only(right: 30),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  SevaPrefixIconForTitle(
//                    margin: EdgeInsets.only(top: 0, right: 15),
//                    prefixIcon: SevaWebAssetIcons.offers,
//                  ),
//                  Expanded(
//                    child: Padding(
//                      padding: const EdgeInsets.symmetric(horizontal: 10),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Row(
//                            children: [
//                              Padding(
//                                padding: EdgeInsets.symmetric(
//                                    // horizontal: 20,
//                                    // vertical: 10,
//                                    ),
//                                child: Text(
//                                  S.of(context).edit,
//                                  // textAlign: TextAlign.center,
//                                  style: TextStyle(
//                                    fontSize: 32,
//                                    color: HexColor('#212121'),
//                                    fontWeight: FontWeight.bold,
//                                  ),
//                                ),
//                              ),
//                              const Spacer(),
//                              CustomCloseButton(
//                                onCleared: () {
//                                  ExtendedNavigator.of(context).pop();
//                                },
//                              ),
//                            ],
//                          ),
//                          SizedBox(height: 20),
//                          this.type == OfferType.INDIVIDUAL_OFFER
//                              ? IndividualOffer(
//                                  timebankId: timebankId,
//                                  offerModel: offerModel,
//                                )
//                              : this.type == OfferType.GROUP_OFFER
//                                  ? OneToManyOffer(
//                                      timebankId: timebankId,
//                                      offerModel: offerModel,
//                                    )
//                                  : Text('')
//                        ],
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ))));
//  }
//}
