import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/utils/app_config.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

import '../flavor_config.dart';

enum InfoType {
  GROUPS,
  PROJECTS,
  REQUESTS,
  OFFERS,
  PROTECTED_TIMEBANK,
  PRIVATE_TIMEBANK,
  PRIVATE_GROUP,
  TAX_CONFIGURATION,
  MAX_CREDITS,
  SPONSORED,
  NEGATIVE_CREDITS,
  OpenScopeRequest,
  OpenScopeOffer,
  OpenScopeEvent,
  VirtualRequest,
  TestCommunity,
  VirtualOffers,
  Borrow_Liability_For_Damage,
  Borrow_Use_Disclaimer,
  Borrow_Delivery_Return,
  Borrow_Maintain_Repair,
  Borrow_Refund_Deposit,
  Borrow_Maintain_Clean,
}

Map<InfoType, String> infoKeyMapper = {
  InfoType.GROUPS: "groupsInfo",
  InfoType.PROJECTS: "projectsInfo",
  InfoType.REQUESTS: "requestsInfo",
  InfoType.OFFERS: "offersInfo",
  InfoType.PROTECTED_TIMEBANK: "protectedTimebankInfo",
  InfoType.PRIVATE_TIMEBANK: "privateTimebankInfo",
  InfoType.PRIVATE_GROUP: "privateGroupInfo",
  InfoType.TAX_CONFIGURATION: "taxInfo",
  InfoType.MAX_CREDITS: "maxCredit",
  InfoType.SPONSORED: "sponsored",
  InfoType.NEGATIVE_CREDITS: 'negativeCredits',
  InfoType.OpenScopeRequest: "openScopeRequest",
  InfoType.OpenScopeOffer: "openScopeOffer",
  InfoType.OpenScopeEvent: "openScopeEvent",
  InfoType.VirtualRequest: "virtualRequest",
  InfoType.TestCommunity: "testCommunity",
  InfoType.VirtualOffers: "virtualOffers",
  InfoType.Borrow_Liability_For_Damage: "borrowLiabilityForDamage",
  InfoType.Borrow_Use_Disclaimer: "borrowUseDisclaimer",
  InfoType.Borrow_Delivery_Return: "borrowDeliveryReturn",
  InfoType.Borrow_Maintain_Repair: "borrowMaintainRepair",
  InfoType.Borrow_Refund_Deposit: "borrowRefundDeposit",
  InfoType.Borrow_Maintain_Clean: "borrowMaintainClean",
};

Widget infoButton({
  required BuildContext context,
  required GlobalKey key,
  required InfoType type,
}) {
  assert(context != null);
  assert(key != null);
  assert(type != null);
  // var temp = AppLocalizations.of(context).translate('info_window', 'mapper');

  return IconButton(
    key: key,
    enableFeedback: true,
    padding: EdgeInsets.all(2),
    visualDensity: VisualDensity.standard,
    icon: Image.asset(
      'lib/assets/images/info.png',
      color: Theme.of(context).primaryColor,
      height: 16,
      width: 16,
    ),
    onPressed: () {
      RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
      showDialogFromInfoWindow(
          context: context,
          key: key,
          type: type,
          buttonPosition: buttonPosition);
    },
  );
}

void showDialogFromInfoWindow(
    {required BuildContext context,
    required GlobalKey key,
    required InfoType type,
    required Offset buttonPosition}) {
  Map<String, dynamic> details = json.decode(AppConfig.remoteConfig!
      .getString("i_button_info_${S.of(context).localeName}"));

  showDialog(
    context: context,
    builder: (BuildContext _context) {
      // Map<InfoType, String> infoDescriptionMapper = {
      //   InfoType.GROUPS:
      //       AppLocalizations.of(context).translate('info_window', 'groups'),
      //   InfoType.PROJECTS: AppLocalizations.of(context)
      //       .translate('info_window', 'projects'),
      //   InfoType.REQUESTS: AppLocalizations.of(context)
      //       .translate('info_window', 'requests'),
      //   InfoType.OFFERS:
      //       AppLocalizations.of(context).translate('info_window', 'offers'),
      //   InfoType.PROTECTED_TIMEBANK: AppLocalizations.of(context)
      //       .translate('info_window', 'protected_timebank'),
      //   InfoType.PRIVATE_TIMEBANK: AppLocalizations.of(context)
      //       .translate('info_window', 'private_timebank'),
      //   InfoType.PRIVATE_GROUP: AppLocalizations.of(context)
      //       .translate('info_window', 'private_group'),
      //   InfoType.TAX_CONFIGURATION: AppLocalizations.of(context)
      //       .translate('info_window', 'tax_configuration'),
      // };
      bool _isDialogBottom =
          buttonPosition.dy > (MediaQuery.of(context).size.height / 2) + 100;
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: _isDialogBottom ? null : (buttonPosition.dy - 30),
            bottom: _isDialogBottom
                ? MediaQuery.of(context).size.height - buttonPosition.dy - 45
                : null,
            left: buttonPosition.dx + 8,
            child: ClipPath(
              clipper: _isDialogBottom ? ReverseArrowClipper() : ArrowClipper(),
              child: Container(
                height: 60,
                width: 30,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: _isDialogBottom ? null : (buttonPosition.dy + 20),
            bottom: _isDialogBottom
                ? MediaQuery.of(context).size.height - buttonPosition.dy
                : null,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        details[infoKeyMapper[type]] ??
                            S.of(context).sandbox_dialog_subtitle, //??
                        // infoDescriptionMapper[key],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 15,
                          bottom: 15,
                        ),
                        child: CustomTextButton(
                          // padding: EdgeInsets.fromLTRB(10, 5, 5, 10),
                          shape: StadiumBorder(),
                          color: Colors.grey,
                          child: Text(
                            S.of(context).ok,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Europa',
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(_context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ReverseArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height / 2);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
