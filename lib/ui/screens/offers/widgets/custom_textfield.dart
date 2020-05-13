import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String heading;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hint;
  final int maxLength;
  final String error;
  final TextInputType textInputType;
  final FocusNode currentNode;
  final FocusNode nextNode;
  final List<TextInputFormatter> formatters;
  CustomTextField(
      {Key key,
      this.heading,
      this.onChanged,
      this.hint,
      this.maxLength,
      this.error,
      this.textInputType = TextInputType.text,
      this.initialValue,
      this.currentNode,
      this.nextNode,
      this.formatters})
      : super(key: key);

  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    fontFamily: 'Europa',
    color: Colors.black,
  );
  final TextStyle subTitleStyle = TextStyle(
    fontSize: 15,
    color: Colors.black,
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
          focusNode: currentNode,
          controller: initialValue != null
              ? TextEditingController(
                  text: initialValue.replaceAll('__*__', ''),
                )
              : null,
          onChanged: onChanged,
          inputFormatters: formatters,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint ?? '',
            errorText: error,
          ),
          maxLength: maxLength,
          keyboardType: textInputType,
          textInputAction:
              nextNode != null ? TextInputAction.next : TextInputAction.done,
          style: subTitleStyle,
          onSubmitted: (v) {
            currentNode.unfocus();
            nextNode != null
                ? nextNode.requestFocus()
                : FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}
