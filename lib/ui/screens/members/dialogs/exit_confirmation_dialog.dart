import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

Future exitTimebankOrGroup({
  BuildContext context,
  String title,
}) async {
  final profanityDetector = ProfanityDetector();
  GlobalKey<FormState> _formKey = GlobalKey();
  String reason;
  return showDialog<String>(
    context: context,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          title,
          style: TextStyle(fontSize: 15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: S.of(context).enter_reason_to_exit),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 17.0),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                validator: (value) {
                  if (value.isEmpty) {
                    return S.of(context).enter_reason_to_exit_hint;
                  } else if (profanityDetector.isProfaneString(value)) {
                    return S.of(context).profanity_text_alert;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => reason = value,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                Spacer(),
                CustomTextButton(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                  color: Theme.of(context).accentColor,
                  textColor: FlavorConfig.values.buttonTextColor,
                  child: Text(
                    S.of(context).exit,
                    style: TextStyle(
                      fontSize: dialogButtonSize,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      Navigator.of(viewContext).pop(reason);
                    }
                  },
                ),
                CustomTextButton(
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(
                      fontSize: dialogButtonSize,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(viewContext).pop(null);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
