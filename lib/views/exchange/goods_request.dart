import 'package:flutter/material.dart';
import 'package:sevaexchange/components/goods_dynamic_selection_createRequest.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/models/models.dart';
import 'package:sevaexchange/views/exchange/request_utils.dart';
import 'package:sevaexchange/widgets/add_images_for_request.dart';

class GoodsRequest extends StatefulWidget {
  final RequestModel requestModel;
  final Widget requestDescription;
  final Widget categoryWidget;
  final Widget addToProjectContainer;

  GoodsRequest(
      {this.requestDescription,
      this.categoryWidget,
      this.requestModel,
      this.addToProjectContainer});

  @override
  _GoodsRequestState createState() => _GoodsRequestState();
}

class _GoodsRequestState extends State<GoodsRequest> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(height: 20),
      widget.requestDescription,

      SizedBox(height: 20),
      widget.categoryWidget,

      SizedBox(height: 10),
      AddImagesForRequest(
        onLinksCreated: (List<String> imageUrls) {
          widget.requestModel.imageUrls = imageUrls;
        },
      ),
      SizedBox(height: 20),
      widget.addToProjectContainer,
      SizedBox(height: 20),
      Text(
        S.of(context).request_goods_description,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      //TODO NOTE: 2 different [GoodsDynamicSelection] for edit and create
      GoodsDynamicSelection(
        selectedGoods: widget.requestModel.goodsDonationDetails.requiredGoods,
        onSelectedGoods: (goods) =>
            {widget.requestModel.goodsDonationDetails.requiredGoods = goods},
      ),
      SizedBox(height: 20),
      Text(
        S.of(context).request_goods_address,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Europa',
          color: Colors.black,
        ),
      ),
      Text(
        S.of(context).request_goods_address_hint,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          updateExitWithConfirmationValue(context, 2, value);
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorMaxLines: 2,
          hintText: S.of(context).request_goods_address_inputhint,
          hintStyle: hintTextStyle,
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        validator: (value) {
          if (value.isEmpty) {
            return S.of(context).validation_error_general_text;
          } else {
            widget.requestModel.goodsDonationDetails.address = value;
          }
          return null;
        },
      ),
    ]);
  }
}
