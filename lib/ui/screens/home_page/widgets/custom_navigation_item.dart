import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CustomNavigationItem extends StatelessWidget {
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final bool isSelected;
  final String title;
  final bool showBadge;
  final String count;

  const CustomNavigationItem({
    Key key,
    this.primaryIcon,
    this.secondaryIcon,
    this.isSelected = false,
    this.title = '',
    this.showBadge = false,
    this.count = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Badge(
          showBadge: showBadge,
          animationDuration: Duration.zero,
          badgeColor: isSelected ? Colors.white : Colors.red,
          badgeContent: Text(
            count,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 8,
            ),
          ),
          child: Icon(
            isSelected || showBadge
                ? primaryIcon
                : secondaryIcon ?? primaryIcon,
            size: isSelected ? 28 : 24,
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
          ),
        ),
        Offstage(
          offstage: isSelected,
          child: Text(
            title,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
