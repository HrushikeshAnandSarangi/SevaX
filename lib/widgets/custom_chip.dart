import 'package:flutter/material.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class CustomChip extends StatelessWidget {
  final String title;
  final Function onDelete;

  const CustomChip({Key key, this.title, this.onDelete}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0x0FF70C493),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFFFFFFFF),
                foregroundColor: Color(0xFFF70C493),
                child: Icon(
                  Icons.clear,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomChipExploreFilter extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final bool isHidden;

  const CustomChipExploreFilter({
    Key key,
    this.isSelected,
    this.onTap,
    this.label,
    this.isHidden = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return HideWidget(
      hide: isHidden,
      child: InkWell(
        onTap: onTap,
        child: Chip(
          avatar: isSelected
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
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black),
          ),
          side: BorderSide(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
          ),
          backgroundColor:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        ),
      ),
    );
  }
}
