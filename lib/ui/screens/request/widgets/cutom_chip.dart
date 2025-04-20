import 'package:flutter/material.dart';
import 'package:sevaexchange/flavor_config.dart';

class CustomChip extends StatelessWidget {
  final bool? isSelected;
  final VoidCallback? onTap;
  final String? label;

  const CustomChip({Key? key, this.isSelected, this.onTap, this.label})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: isSelected!
            ? Padding(
                padding: EdgeInsets.only(left: 2.0),
                child: Container(
                  height: 16,
                  width: 16,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFFFFFFF),
                    foregroundColor: Color(0xFFF70C493),
                    child: Icon(
                      Icons.check,
                      size: 14,
                    ),
                  ),
                ),
              )
            : null,
        label: Text(
          label!,
          style: TextStyle(
              color:
                  isSelected! ? Colors.white : Theme.of(context).primaryColor),
        ),
        side: BorderSide(
          color:
              isSelected! ? Theme.of(context).primaryColor : Colors.grey[300]!,
        ),
        backgroundColor:
            isSelected! ? Theme.of(context).primaryColor : Colors.transparent,
      ),
    );
  }
}
