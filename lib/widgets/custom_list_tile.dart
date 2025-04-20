import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;

  CustomListTile({
    Key? key,
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          leading ?? Container(),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                title ?? Container(),
                subtitle ?? Container(),
              ],
            ),
          ),
          trailing ?? Container(),
        ],
      ),
    );
  }
}
