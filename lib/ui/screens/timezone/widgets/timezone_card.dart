import 'package:flutter/material.dart';

class TimezoneCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String code;
  final Function onTap;
  final bool isSelected;

  const TimezoneCard(
      {Key? key,
      required this.title,
      required this.subTitle,
      required this.code,
      required this.onTap,
      required this.isSelected})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: isSelected
            ? Icon(
                Icons.done,
                color: Colors.green,
                size: 28,
              )
            : null,
        trailing: Text(
          code,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        title: Text(title),
        subtitle: Text(subTitle),
        onTap: () => onTap(),
      ),
    );
  }
}
