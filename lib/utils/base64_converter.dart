import 'dart:convert';
import 'dart:io';

Future<String> convertImageToBase64({File file}) async {
  List<int> imageBytes = file.readAsBytesSync();
  String base64Image = base64Encode(imageBytes);
  print(base64Image);

  return base64Image;
}
