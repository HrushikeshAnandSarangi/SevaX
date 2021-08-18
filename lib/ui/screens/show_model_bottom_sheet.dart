import 'package:flutter/material.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

enum CustomeBottomShetCalendar {
  GOOGLE,
  OUTLOOK,
  ICLOUD_CALENDAR,
}

class CustomeShowModalBottomSheet {
  @required
  final ComingFrom comingFrom;
  @required
  final BannerDetails bannerDetails;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry transactionsMatrixCheckPadding;

  CustomeShowModalBottomSheet({
    this.comingFrom,
    this.bannerDetails,
    this.titlePadding,
    this.transactionsMatrixCheckPadding,
  });

  Future<void> customeShowModalBottomSheet({
    @required BuildContext context,
    @required String title,
    @required String skipButtonTitle,
    @required Function onSkippedPressed,
    @required
        final Function(CustomeBottomShetCalendar caendarType)
            onTapTransactionsMatrixCheck,
  }) {
    List<CustomeBottomShetCalendar> customeCalendar = [
      CustomeBottomShetCalendar.GOOGLE,
      CustomeBottomShetCalendar.OUTLOOK,
      CustomeBottomShetCalendar.ICLOUD_CALENDAR,
    ];
    List<String> imageUrl = [
      "lib/assets/images/googlecal.png",
      "lib/assets/images/outlookcal.png",
      "lib/assets/images/ical.png",
    ];
    // assert(customeShowModalBottomSheetModel.length != 3);
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: new Wrap(
            children: <Widget>[
              Padding(
                padding: titlePadding ?? EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Text(
                  title ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: transactionsMatrixCheckPadding ??
                    EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => TransactionsMatrixCheck(
                      comingFrom: comingFrom,
                      upgradeDetails: bannerDetails,
                      transaction_matrix_type: "calendar_sync",
                      child: GestureDetector(
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 40,
                          child: Image.asset(imageUrl[index]),
                        ),
                        onTap: () => onTapTransactionsMatrixCheck(
                            customeCalendar[index]),
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
                      skipButtonTitle,
                      style: TextStyle(color: Colors.purple),
                    ),
                    onPressed: onSkippedPressed,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
