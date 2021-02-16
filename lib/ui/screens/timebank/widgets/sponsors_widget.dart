import 'package:flutter/material.dart';

class SponsorsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Sponsored By"),
            Spacer(),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showUploadImageDialog(context);
              },
            ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              height: 100,
              color: Colors.red,
            );
          },
        ),
      ],
    );
  }

  void showUploadImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("hello"),
        );
      },
    );
  }
}
