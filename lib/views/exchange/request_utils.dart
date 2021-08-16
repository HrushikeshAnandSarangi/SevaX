import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/exit_with_confirmation.dart';

void updateExitWithConfirmationValue(BuildContext context, int index, String value) {
  ExitWithConfirmation.of(context).fieldValues[index] = value;
}


bool isFromRequest({String projectId}) {
  return projectId == null || projectId.isEmpty || projectId == "";
}

TextStyle hintTextStyle = TextStyle(
  fontSize: 14,
  // fontWeight: FontWeight.bold,
  color: Colors.grey,
  fontFamily: 'Europa',
);
