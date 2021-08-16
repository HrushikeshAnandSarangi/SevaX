import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/exchange/create_request/payment_description.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/views/timebank_modules/offer_utils.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';

class CashRequest extends StatefulWidget {
  final RequestModel requestModel;
  final Widget requestDescription;
  final List<ProjectModel> projectModelList;
  final bool isOfferRequest;
  final OfferModel offer;
  final Function onDescriptionChanged;
  final Widget addToProjectContainer;
  Widget categoryWidget;

  CashRequest(
      {this.projectModelList,
      this.requestDescription,
      this.isOfferRequest,
      this.offer,
      this.onDescriptionChanged,
      this.addToProjectContainer,
      this.requestModel,
      this.categoryWidget});

  @override
  _CashRequestState createState() => _CashRequestState();
}

class _CashRequestState extends State<CashRequest> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(height: 20),
      widget.requestDescription,
      SizedBox(height: 20),
      widget.categoryWidget,
      SizedBox(height: 20),
      AddImagesForRequest(
        onLinksCreated: (List<String> imageUrls) {
          widget.requestModel.imageUrls = imageUrls;
        },
      ),
      SizedBox(height: 20),
      Text(
        S.of(context).request_target_donation,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      TextFormField(
        initialValue: widget.offer != null && widget.isOfferRequest
            ? getCashDonationAmount(
                offerDataModel: widget.offer,
              )
            : "",
        onChanged: (v) {
          updateExitWithConfirmationValue(context, 12, v);
          if (v.isNotEmpty && int.parse(v) >= 0) {
            widget.requestModel.cashModel.targetAmount = int.parse(v);
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintText: S.of(context).request_target_donation_hint,
          hintStyle: hintTextStyle,
          prefixIcon: Icon(Icons.attach_money),

          // labelText: 'No. of volunteers',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            (RegExp("[0-9]")),
          ),
        ],
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_target_donation_count;
          } else if (int.parse(value) < 0) {
            return S.of(context).validation_error_target_donation_count_negative;
          } else if (int.parse(value) == 0) {
            return S.of(context).validation_error_target_donation_count_zero;
          } else {
            widget.requestModel.cashModel.targetAmount = int.parse(value);
            setState(() {});
            return null;
          }
        },
      ),
      SizedBox(height: 20),
      Text(
        S.of(context).request_min_donation,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      TextFormField(
        onChanged: (v) {
          updateExitWithConfirmationValue(context, 13, v);
          if (v.isNotEmpty && int.parse(v) >= 0) {
            widget.requestModel.cashModel.minAmount = int.parse(v);
            setState(() {});
          }
        },
        decoration: InputDecoration(
          hintText: S.of(context).request_min_donation_hint,
          hintStyle: hintTextStyle,
          // labelText: 'No. of volunteers',
          prefixIcon: Icon(Icons.attach_money),

          // labelText: 'No. of volunteers',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            (RegExp("[0-9]")),
          ),
        ],
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_min_donation_count;
          } else if (int.parse(value) < 0) {
            return S.of(context).validation_error_min_donation_count_negative;
          } else if (int.parse(value) == 0) {
            return S.of(context).validation_error_min_donation_count_zero;
          } else if (widget.requestModel.cashModel.targetAmount != null &&
              widget.requestModel.cashModel.targetAmount < int.parse(value)) {
            return S.of(context).target_amount_less_than_min_amount;
          } else {
            widget.requestModel.cashModel.minAmount = int.parse(value);
            setState(() {});
            return null;
          }
        },
      ),
      SizedBox(height: 20),
      widget.addToProjectContainer,
      SizedBox(height: 20),
      PaymentDescription(
        requestModel: widget.requestModel,
      ),
    ]);
  }
}
