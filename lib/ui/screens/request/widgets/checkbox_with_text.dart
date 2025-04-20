import 'package:flutter/material.dart';

/// Widget to show checkbox and text in row
///
/// Leave [onChanged] as null to disable the checkbox
///
/// [text] is the title shown in the row
class CheckboxWithText extends StatelessWidget {
  final bool? value;
  final String text;
  final ValueChanged<bool?>? onChanged;

  const CheckboxWithText({
    Key? key,
    this.value = false,
    required this.text,
    this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          activeColor: Colors.black,
          checkColor: Colors.white,
          value: value,
          onChanged: onChanged,
        ),
        SizedBox(width: 12),
        Text(text),
      ],
    );
  }
}
