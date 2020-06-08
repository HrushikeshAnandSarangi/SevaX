import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class CustomNavigationItem extends StatelessWidget {
  final String primaryIcon;
  final String secondaryIcon;
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
          borderRadius: 10,
          badgeColor: isSelected ? Colors.white : Colors.red,
          badgeContent: Text(
            count,
            style: TextStyle(
              color: isSelected ? Colors.red : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 8,
            ),
          ),
          child: Image.asset(
            isSelected || showBadge
                ? primaryIcon
                : secondaryIcon ?? primaryIcon,
            width: isSelected ? 25 : 22,
            height: isSelected ? 25 : 22,
            fit: BoxFit.scaleDown,
            color: isSelected ? null : Theme.of(context).primaryColor,
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
