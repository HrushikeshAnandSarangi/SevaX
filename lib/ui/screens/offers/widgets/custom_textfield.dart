import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

class CustomTextField extends StatelessWidget {
  final enableStreamData;
  final String heading;
  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final int maxLength;
  final String error;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode currentNode;
  final FocusNode nextNode;
  final List<TextInputFormatter> formatters;
  final TextEditingController controller = TextEditingController();
  final Function(String) validator;
  final bool autovalidate;
  final textCapitalization;
  final int maxLines;
  final int errorMaxLines;
  final void Function(String) onSaved;
  CustomTextField({
    Key key,
    this.heading,
    this.onChanged,
    this.hint,
    this.maxLength,
    this.error,
    this.keyboardType = TextInputType.text,
    this.value,
    this.currentNode,
    this.nextNode,
    this.formatters,
    this.validator,
    this.autovalidate,
    this.textInputAction,
    this.textCapitalization,
    this.maxLines = 1,
    this.errorMaxLines,
    this.onSaved,
    this.enableStreamData = false,
  }) : super(key: key);

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
    if (value != null && enableStreamData) {
      controller.value = controller.value.copyWith(
        text: value,
      );
      controller.selection = controller.selection.copyWith(
        baseOffset: value?.length,
        extentOffset: value?.length,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        heading != null
            ? Text(
                heading,
                style: titleStyle,
              )
            : Container(),
        TextFormField(
          focusNode: currentNode,
          controller: enableStreamData ? controller : null,
          onChanged: (value) {
            onChanged(value);
            ExitWithConfirmation.of(context)?.fieldValues[context.hashCode] =
                value;
          },
          inputFormatters: formatters,
          textCapitalization:
              textCapitalization ?? TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint ?? '',
            errorText: enableStreamData ? error : null,
            errorMaxLines: errorMaxLines,
          ),
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction:
              nextNode != null ? TextInputAction.next : TextInputAction.done,
          style: subTitleStyle,
          onFieldSubmitted: (v) {
            currentNode.unfocus();
            nextNode != null
                ? nextNode.requestFocus()
                : FocusScope.of(context).unfocus();
          },
          onSaved: onSaved,
        ),
      ],
    );
  }
}
