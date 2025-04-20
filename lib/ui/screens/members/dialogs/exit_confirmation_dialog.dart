import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/components/ProfanityDetector.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/flavor_config.dart';
import 'package:sevaexchange/l10n/l10n.dart';
import 'package:sevaexchange/widgets/custom_buttons.dart';

Future exitTimebankOrGroup({
  required BuildContext context,
  required String title,
}) async {
  final profanityDetector = ProfanityDetector();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? reason;
  return showDialog<String>(
    context: context,
    builder: (BuildContext viewContext) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                    hintText: S.of(viewContext).enter_reason_to_exit),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 17.0),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return S.of(viewContext).enter_reason_to_exit_hint;
                  } else if (profanityDetector.isProfaneString(value)) {
                    return S.of(viewContext).profanity_text_alert;
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => reason = value,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: <Widget>[
                const Spacer(),
                CustomTextButton(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  color: Theme.of(viewContext).colorScheme.secondary,
                  textColor: FlavorConfig.values.buttonTextColor,
                  child: Text(
                    S.of(viewContext).exit,
                    style: TextStyle(
                      fontSize: dialogButtonSize,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Navigator.of(viewContext).pop(reason ?? '');
                    }
                  },
                ),
                CustomTextButton(
                  child: Text(
                    S.of(viewContext).cancel,
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
