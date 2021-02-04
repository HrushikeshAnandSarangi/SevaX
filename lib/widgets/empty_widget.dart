import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String sub_title;
  final double titleFontSize;

  const EmptyWidget({Key key, this.title, this.sub_title, this.titleFontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Image.asset(
            'images/icons/empty_widget.png',
            height: 160,
            width: 214,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 22,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            sub_title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
