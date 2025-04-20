import 'package:doseform/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

/// Creates a [DoseTextField] that contains a [heading].
///
///  [initialValue] must be null since [TextEditingController] is being used implicitly
///
///
class CustomDoseTextField extends DoseTextField {
  final bool isRequired;
  final String? heading;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final int? maxLength;
  final String? error;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextNode;
  final List<TextInputFormatter>? formatters;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool? autovalidate;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int minLines;
  final int? errorMaxLines;
  final void Function(String?)? onSaved;
  final InputDecoration? decoration;

  CustomDoseTextField(
      {required this.isRequired,
      this.heading,
      this.onChanged,
      this.hint,
      this.maxLength,
      this.error,
      this.keyboardType = TextInputType.text,
      this.value,
      this.focusNode,
      this.nextNode,
      this.formatters,
      this.validator,
      this.autovalidate,
      this.textInputAction,
      this.textCapitalization = TextCapitalization.sentences,
      this.maxLines = 1,
      this.minLines = 1,
      this.errorMaxLines,
      this.onSaved,
      this.controller,
      this.decoration});

  final TextStyle titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
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
        heading != null
            ? Text(
                heading!,
                style: titleStyle,
              )
            : Container(),
        DoseTextField(
          isRequired: isRequired,
          focusNode: focusNode,
          controller: controller,
          onChanged: (value) {
            onChanged?.call(value);
            if (ExitWithConfirmation.of(context)?.fieldValues != null) {
              ExitWithConfirmation.of(context)?.fieldValues[context.hashCode] =
                  value;
            }
          },
          formatters: formatters,
          textCapitalization:
              textCapitalization ?? TextCapitalization.sentences,
          decoration: decoration ??
              InputDecoration(
                hintText: hint ?? '',
                errorText: error,
                errorMaxLines: errorMaxLines,
              ),
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction:
              nextNode != null ? TextInputAction.next : TextInputAction.done,
          style: subTitleStyle,
          onSaved: (v) {
            focusNode!.unfocus();
            nextNode != null
                ? nextNode!.requestFocus()
                : FocusScope.of(context).unfocus();
          },
          validator: validator,
          // onSaved: onSaved,
          maxLines: maxLines,
          minLines: minLines,
        ),
      ],
    );
  }
}
