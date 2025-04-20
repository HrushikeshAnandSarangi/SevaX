import 'package:flutter/material.dart';
import 'package:sevaexchange/constants/sevatitles.dart';
import 'package:sevaexchange/ui/screens/request/widgets/checkbox_with_text.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';

class GoodsDisplayPage extends StatelessWidget {
  final String label;
  final String name;
  final String photoUrl;
  final List<String> goods;
  final String message;

  const GoodsDisplayPage({
    Key? key,
    required this.label,
    required this.name,
    required this.photoUrl,
    required this.goods,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.label,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomNetworkImage(
                  photoUrl ?? defaultUserImageURL,
                  entityName: name ?? '',
                  fit: BoxFit.cover,
                  size: 60,
                ),
                SizedBox(width: 12),
                Text(
                  name ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                message ?? '',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            ...goods
                .map((String text) => CheckboxWithText(
                      text: text,
                      value: true,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
