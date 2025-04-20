import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/enums/lending_borrow_enums.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/new_baseline/models/lending_model.dart';
import 'package:sevaexchange/repositories/lending_offer_repo.dart';
import 'package:sevaexchange/ui/screens/offers/pages/lending_offer_participants.dart';
import 'package:sevaexchange/ui/utils/date_formatter.dart';
import 'package:sevaexchange/utils/data_managers/timezone_data_manager.dart';
import 'package:sevaexchange/utils/log_printer/log_printer.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../../../../flavor_config.dart';
import '../../../../labels.dart';

class LendingOfferBorrowerUpdateWidget extends StatefulWidget {
  final OfferModel? offerModel;
  final LendingOfferAcceptorModel? lendingOfferAcceptorModel;
  final BuildContext? parentContext;
  LendingOfferBorrowerUpdateWidget({
    this.offerModel,
    this.lendingOfferAcceptorModel,
    this.parentContext,
  });

  @override
  _LendingOfferBorrowerUpdateWidgetState createState() =>
      _LendingOfferBorrowerUpdateWidgetState();
}

class _LendingOfferBorrowerUpdateWidgetState
    extends State<LendingOfferBorrowerUpdateWidget> {
  _LendingOfferBorrowerUpdateWidgetState();

  late BuildContext progressContext;
  late LendingOfferStatus lendingOfferStatus;

  @override
  Widget build(BuildContext context) {
    logger.e('MODEL CHECK 1000 ---> ' +
        widget.lendingOfferAcceptorModel!.startDate.toString());
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0))),
      content: Form(
        //key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getCloseButton(context),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                widget.offerModel!.individualOfferDataModel!.title ??
                    S.of(context).anonymous,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.offerModel!.individualOfferDataModel!.description ??
                    S.of(context).description_not_updated,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.offerModel!.selectedAdrress ?? '',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            Text(
                S.of(context).start +
                    ': ' +
                    DateFormat('MMMM dd, yyyy - h:mm a',
                            Locale(getLangTag()).toLanguageTag())
                        .format(
                      getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              widget.lendingOfferAcceptorModel!.startDate!),
                          timezoneAbb: SevaCore.of(widget.parentContext!)
                              .loggedInUser
                              .timezone!),
                    ),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center),
            Text(
                S.of(context).end +
                    ': ' +
                    DateFormat('MMMM dd, yyyy - h:mm a',
                            Locale(getLangTag()).toLanguageTag())
                        .format(
                      getDateTimeAccToUserTimezone(
                          dateTime: DateTime.fromMillisecondsSinceEpoch(
                              widget.lendingOfferAcceptorModel!.endDate!),
                          timezoneAbb: SevaCore.of(widget.parentContext!)
                              .loggedInUser
                              .timezone!),
                    ),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center),
            Padding(
              padding: EdgeInsets.all(5.0),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    textColor: Colors.white,
                    child: Text(
                      getButtonLabel(),
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      showProgressDialog(context, S.of(context).updating);
                      await LendingOffersRepo.updateLendingOfferStatus(
                          lendingOfferAcceptorModel:
                              widget.lendingOfferAcceptorModel!,
                          lendingOfferStatus: lendingOfferStatus,
                          offerModel: widget.offerModel!);

                      if (progressContext != null) {
                        Navigator.of(progressContext).pop();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: CustomElevatedButton(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 2,
                    textColor: Colors.white,
                    child: Text(
                      S.of(context).cancel,
                      style:
                          TextStyle(color: Colors.white, fontFamily: 'Europa'),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String getButtonLabel() {
    if (widget.lendingOfferAcceptorModel!.status ==
            LendingOfferStatus.APPROVED &&
        widget.offerModel!.lendingOfferDetailsModel!.lendingModel!
                .lendingType! ==
            LendingType.PLACE) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_IN;
      return S.of(context).check_in_text;
    } else if (widget.lendingOfferAcceptorModel!.status ==
            LendingOfferStatus.APPROVED &&
        widget.offerModel!.lendingOfferDetailsModel!.lendingModel!
                .lendingType ==
            LendingType.ITEM) {
      lendingOfferStatus = LendingOfferStatus.ITEMS_COLLECTED;

      return S.of(context).collect_items;
    } else if (widget.lendingOfferAcceptorModel!.status ==
        LendingOfferStatus.CHECKED_IN) {
      lendingOfferStatus = LendingOfferStatus.CHECKED_OUT;

      return S.of(context).check_out_text;
    } else if (widget.lendingOfferAcceptorModel!.status ==
        LendingOfferStatus.ITEMS_COLLECTED) {
      lendingOfferStatus = LendingOfferStatus.ITEMS_RETURNED;

      return S.of(context).return_items;
    } else {
      return S.of(context).approved;
    }
  }

  void showProgressDialog(BuildContext context, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (createDialogContext) {
          progressContext = createDialogContext;
          return AlertDialog(
            title: Text(message),
            content: LinearProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        });
  }

  Widget _getCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        alignment: FractionalOffset.topRight,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'lib/assets/images/close.png',
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}
