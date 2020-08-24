// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sevaexchange/components/ProfanityDetector.dart';

// class CustomTextFormField extends StatelessWidget {
//   String hintText;
//   String errorText;
//   String initialValue;
//   TextEditingController controller;
//   FocusNode focusNode;
//   TextCapitalization textCapitalization;
//   TextInputAction textInputAction;
//   TextInputType textInputType;
//   int maxLines = 1;
//   List<TextInputFormatter> inputFormatters;
//   ProfanityDetector profanityDetector = ProfanityDetector();
//   FormFieldSetter<String> onSaved;
//   FormFieldValidator<String> validator;
//   bool autovalidate = false;

//   CustomTextFormField(
//       {this.hintText,
//       this.errorText,
//       this.initialValue,
//       this.controller,
//       this.focusNode,
//       this.textCapitalization,
//       this.textInputAction,
//       this.textInputType,
//       this.maxLines,
//       this.inputFormatters,
//       this.profanityDetector,
//       this.onSaved,
//       this.validator,
//       this.autovalidate});

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       autovalidate: autovalidate,
//       textInputAction: textInputAction,
//       textCapitalization: textCapitalization,
//       keyboardType: textInputType,
//       maxLines: maxLines,
//       autocorrect: true,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       onSaved: onSaved,
//       decoration: InputDecoration(
//         hintText: hintText,
//         errorText: errorText,
//       ),
//     );
//   }
// }
