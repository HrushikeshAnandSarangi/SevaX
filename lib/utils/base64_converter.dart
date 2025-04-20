import 'dart:convert';
import 'dart:io';

Future<String> convertImageToBase64({required File file}) async {
  final imageBytes = await file.readAsBytes();
  return base64Encode(imageBytes);
}
