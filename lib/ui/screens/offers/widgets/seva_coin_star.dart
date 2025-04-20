import 'package:flutter/material.dart';

class SevaCoinStarWidget extends StatelessWidget {
  final String? title;
  final String? amount;
  const SevaCoinStarWidget({
    Key? key,
    this.title,
    this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title!,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(
          height: 2,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.yellow[700],
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.yellow[400],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                amount!,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
