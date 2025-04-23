import 'dart:convert';
import 'package:universal_io/io.dart' as io;

Future<String> convertImageToBase64({required io.File file}) async {
  final imageBytes = await file.readAsBytes();
  return base64Encode(imageBytes);
}
