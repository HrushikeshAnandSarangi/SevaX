import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/custom_info_dialog.dart';

class OpenScopeCheckBox extends StatelessWidget {
  final bool isChecked;
  final InfoType infoType;
  final CheckBoxType checkBoxTypeLabel;
  final ValueChanged<bool> onChangedCB;

  OpenScopeCheckBox(
      {this.isChecked,
      @required this.infoType,
      @required this.checkBoxTypeLabel,
      @required this.onChangedCB});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 250,
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: isChecked ?? false,
              onChanged: onChangedCB,
            ),
            Text(getCheckBoxLabel(checkBoxTypeLabel),
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

String getCheckBoxLabel(CheckBoxType checkBoxType) {
  switch (checkBoxType) {
    case CheckBoxType.type_Requests:
      return "Make this request public";
    case CheckBoxType.type_Offers:
      return "Make this offer public";
    case CheckBoxType.type_Events:
      return "Make this event public";
    case CheckBoxType.type_VirtualRequest:
      return "Make this request virtual";
    default:
      return "";
  }
}

enum CheckBoxType {
  type_Requests,
  type_Offers,
  type_Events,
  type_VirtualRequest,
}
