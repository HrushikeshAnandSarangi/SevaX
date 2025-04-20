import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/cash_model.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/models/payment_detail_model.dart';
import 'package:sevaexchange/utils/data_managers/request_data_manager.dart';
import 'package:sevaexchange/utils/helpers/projects_helper.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/views/core.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class RequestUtils {
  void updateExitWithConfirmationValue(
      BuildContext context, int index, String value) {
    ExitWithConfirmation.of(context).fieldValues[index] = value;
  }

  Future createProjectOneToManyRequest(
      {context, projectModel, requestModel, createEvent}) async {
    //Create new Event/Project for ONE TO MANY Request
    if (projectModel == null &&
        createEvent &&
        requestModel.requestType == RequestType.ONE_TO_MANY_REQUEST) {
      String newProjectId = Utils.getUuid();
      requestModel.projectId = newProjectId;
      List<String> pendingRequests = [requestModel.selectedInstructor.email];

      ProjectModel newProjectModel = ProjectModel(
        emailId: requestModel.email,
        members: [],
        communityName: requestModel.communityName,
        //phoneNumber:,
        address: requestModel.address,
        timebanksPosted: [requestModel.timebankId],
        id: newProjectId,
        name: requestModel.title,
        communityId: requestModel.communityId,
        photoUrl: requestModel.photoUrl,
        creatorId: requestModel.sevaUserId,
        mode: ProjectMode.timebankProject,
        timebankId: requestModel.timebankId,
        associatedMessaginfRoomId: '',
        requestedSoftDelete: false,
        softDelete: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        pendingRequests: pendingRequests,
        startTime: requestModel.requestStart,
        endTime: requestModel.requestEnd,
        description: requestModel.description,
      );

      await createProject(projectModel: newProjectModel);

      log("======================== createProjectWithMessaging()");
      await ProjectMessagingRoomHelper
          .createProjectWithMessagingOneToManyRequest(
        projectModel: newProjectModel,
        projectCreator: SevaCore.of(context).loggedInUser,
      );
    }
  }

  Widget optionRadioButton<T>({
    required String title,
    required T value,
    required T groupvalue,
    required ValueChanged<T?> onChanged,
    bool isEnabled = true,
  }) {
    return ListTile(
      key: UniqueKey(),
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Text(title),
      leading: Radio<T>(
        value: value,
        groupValue: groupvalue,
        onChanged: isEnabled ? onChanged : null,
      ),
    );
  }

  void showInsufficientBalance(double credits, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(S
                .of(context)
                .insufficientSevaCreditsDialog
                .replaceFirst('***', credits.toString())),
            actions: <Widget>[
              CustomTextButton(
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  void showDialogForTitle(
      {required String dialogTitle, required BuildContext context}) async {
    showDialog(
        context: context,
        builder: (BuildContext viewContext) {
          return AlertDialog(
            title: Text(dialogTitle),
            actions: <Widget>[
              CustomTextButton(
                shape: StadiumBorder(),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                onPressed: () {
                  Navigator.of(viewContext).pop();
                },
              ),
            ],
          );
        });
  }

  TextStyle hintTextStyle = TextStyle(
    fontSize: 14,
    // fontWeight: FontWeight.bold,
    color: Colors.grey,
    fontFamily: 'Europa',
  );

  bool isFromRequest({required String projectId}) {
    return projectId.isEmpty || projectId == "";
  }

  getInitialTitle(offer, isOfferRequest) {
    return offer != null && isOfferRequest
        ? getOfferTitle(offerDataModel: offer)
        : "";
  }

  getInitialDescription(offer, isOfferRequest) {
    return offer != null && isOfferRequest
        ? getOfferDescription(offerDataModel: offer)
        : "";
  }

  getInitialAmount(offer, isOfferRequest) {
    return offer != null && isOfferRequest
        ? getCashDonationAmount(offerDataModel: offer)
        : "";
  }

  String mobilePattern = r'^[0-9]+$';
  RegExp emailPattern = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  String validateEmailAndPhone(String value, context) {
    RegExp regExp = RegExp(mobilePattern);
    if (value.isEmpty) {
      return S.of(context).validation_error_general_text;
    } else if (emailPattern.hasMatch(value) || regExp.hasMatch(value)) {
      return '';
    } else {
      return S.of(context).enter_valid_link;
    }
  }

  initializePaymentModel({required CashModel cashModel}) {
    PaymentDetailModel paymentDetailModel = PaymentDetailModel();
    switch (cashModel.paymentType) {
      case RequestPaymentType.ACH:
        paymentDetailModel.paymentMode = PaymentMode.ACH;
        paymentDetailModel.paymentEventType = ACHPayment(
            bank_name: cashModel.achdetails?.bank_name ?? '',
            bank_address: cashModel.achdetails?.bank_address ?? '',
            account_number: cashModel.achdetails?.account_number ?? '',
            routing_number: cashModel.achdetails?.routing_number ?? '');
        break;
      case RequestPaymentType.ZELLEPAY:
        paymentDetailModel.paymentMode = PaymentMode.ZELLEPAY;
        paymentDetailModel.paymentEventType = ZellePayment(
          zelleId: cashModel.zelleId ?? '',
        );
        break;
      case RequestPaymentType.PAYPAL:
        paymentDetailModel.paymentMode = PaymentMode.PAYPAL;
        paymentDetailModel.paymentEventType = PayPalPayment(
          paypalId: cashModel.paypalId ?? '',
        );
        break;
      case RequestPaymentType.VENMO:
        paymentDetailModel.paymentMode = PaymentMode.VENMO;
        paymentDetailModel.paymentEventType =
            VenmoPayment(venmoId: cashModel.venmoId ?? '');
        break;
      case RequestPaymentType.SWIFT:
        paymentDetailModel.paymentMode = PaymentMode.SWIFT;
        paymentDetailModel.paymentEventType =
            SwiftPayment(swiftId: cashModel.swiftId ?? '');
        break;
      case RequestPaymentType.OTHER:
        paymentDetailModel.paymentMode = PaymentMode.OTHER;
        paymentDetailModel.paymentEventType = OtherPayment(
            others: cashModel.others ?? '',
            other_details: cashModel.other_details ?? '');
        break;
      default:
        break;
    }
    return paymentDetailModel;
  }
}
