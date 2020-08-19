import 'package:flutter/material.dart';
import 'package:sevaexchange/ui/screens/request/widgets/checkbox_with_text.dart';
import 'package:sevaexchange/ui/screens/search/widgets/network_image.dart';

class GoodsDisplayPage extends StatelessWidget {
  final String name;
  final String photoUrl;
  final List<String> goods;
  final String message;

  const GoodsDisplayPage({
    Key key,
    this.name,
    this.photoUrl,
    this.goods,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donation Received',
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
                  photoUrl,
                  entityName: name,
                  fit: BoxFit.cover,
                  size: 60,
                ),
                SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                'I have sent you clothes and books',
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
