import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

class CustomeShowModalBottomSheetModel {
  final ComingFrom comingFrom;
  final BannerDetails bannerDetails;
  final String transaction_matrix_type;
  final String iconUrl;
  final Function onTapTransactionsMatrixCheck;

  CustomeShowModalBottomSheetModel(
    this.comingFrom,
    this.bannerDetails,
    this.transaction_matrix_type,
    this.iconUrl,
    this.onTapTransactionsMatrixCheck,
  );
}

void customeShowModalBottomSheet({
  @required BuildContext context,
  @required String title,
  @required String actionButton,
  @required
      List<CustomeShowModalBottomSheetModel> customeShowModalBottomSheetModel,
  @required Function onPressedOfActionButton,
  EdgeInsetsGeometry titlePadding,
  EdgeInsetsGeometry transactionsMatrixCheckPadding,
}) {
  assert(customeShowModalBottomSheetModel.length != 3);
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: titlePadding ?? const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Text(
                  title ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: transactionsMatrixCheckPadding ??
                    const EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => TransactionsMatrixCheck(
                      comingFrom:
                          customeShowModalBottomSheetModel[index].comingFrom,
                      upgradeDetails:
                          customeShowModalBottomSheetModel[index].bannerDetails,
                      transaction_matrix_type:
                          customeShowModalBottomSheetModel[index]
                              .transaction_matrix_type,
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
                          child: Image.asset(
                              customeShowModalBottomSheetModel[index].iconUrl),
                        ),
                        onTap: customeShowModalBottomSheetModel[index]
                            .onTapTransactionsMatrixCheck,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Spacer(),
                  CustomTextButton(
                    child: Text(
                      actionButton,
                      style: TextStyle(
                          color: FlavorConfig.values.theme.primaryColor),
                    ),
                    onPressed: onPressedOfActionButton,
                  ),
                ],
              )
            ],
          ),
        );
      });
}
