import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const CustomChip({Key key, this.isSelected, this.onTap, this.label})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(label),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
