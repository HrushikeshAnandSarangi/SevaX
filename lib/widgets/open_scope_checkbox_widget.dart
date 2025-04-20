import 'package:flutter/material.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

class OpenScopeCheckBox extends StatelessWidget {
  final bool isChecked;
  final InfoType infoType;
  final CheckBoxType checkBoxTypeLabel;
  final ValueChanged<bool?> onChangedCB;

  OpenScopeCheckBox(
      {required this.isChecked,
      required this.infoType,
      required this.checkBoxTypeLabel,
      required this.onChangedCB});

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 200,
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked ?? false,
              onChanged: onChangedCB,
            ),
            Text(
                getCheckBoxLabel(
                  checkBoxTypeLabel,
                  context,
                ),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            SizedBox(width: 5),
            infoButton(
              context: context,
              key: GlobalKey(),
              type: infoType,
              // text: infoDetails['projectsInfo'] ?? description,
            ),
          ],
        ));
  }
}

String getCheckBoxLabel(CheckBoxType checkBoxType, BuildContext context) {
  switch (checkBoxType) {
    case CheckBoxType.type_Offers:
    case CheckBoxType.type_Events:
    case CheckBoxType.type_Requests:
      return S.of(context).public_to_sevax;

    case CheckBoxType.type_VirtualOffers:
    case CheckBoxType.type_VirtualRequest:
      return S.of(context).virtual;
    default:
      return "";
  }
}

enum CheckBoxType {
  type_Requests,
  type_Offers,
  type_Events,
  type_VirtualRequest,
  type_VirtualOffers,
}
