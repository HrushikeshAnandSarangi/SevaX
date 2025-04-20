import 'package:flutter/material.dart';
import 'package:sevaexchange/models/upgrade_plan-banner_details_model.dart';
import 'package:sevaexchange/utils/helpers/transactions_matrix_check.dart';

enum CustomeBottomShetCalendar {
  GOOGLE,
  OUTLOOK,
  ICLOUD_CALENDAR,
}

class CustomeShowModalBottomSheet {
  final ComingFrom comingFrom;
  final BannerDetails bannerDetails;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? transactionsMatrixCheckPadding;

  CustomeShowModalBottomSheet({
    required this.comingFrom,
    required this.bannerDetails,
    this.titlePadding,
    this.transactionsMatrixCheckPadding,
  });

  Future<void> customeShowModalBottomSheet({
    required BuildContext context,
    required String title,
    required String skipButtonTitle,
    required VoidCallback onSkippedPressed,
    required Function(CustomeBottomShetCalendar calendarType)
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
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: titlePadding ?? EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: transactionsMatrixCheckPadding ??
                    EdgeInsets.fromLTRB(6, 6, 6, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  TextButton(
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
