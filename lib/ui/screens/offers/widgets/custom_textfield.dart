import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String heading;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hint;
  final int maxLength;
  final String error;
  final TextInputType textInputType;
  CustomTextField({
    Key key,
    this.heading,
    this.onChanged,
    this.hint,
    this.maxLength,
    this.error,
    this.textInputType = TextInputType.text,
    this.initialValue,
  }) : super(key: key);

  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Europa',
    color: Colors.grey,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          heading,
          style: titleStyle,
        ),
        TextField(
          controller: initialValue != null
              ? TextEditingController(
                  text: initialValue.replaceAll('__*__', ''),
                )
              : null,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint ?? '',
            errorText: error,
          ),
          maxLength: maxLength,
          keyboardType: textInputType,
          style: subTitleStyle,
        ),
      ],
    );
  }
}
