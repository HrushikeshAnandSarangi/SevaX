import 'package:flutter/material.dart';
import 'package:sevaexchange/utils/utils.dart';
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

class CustomChipWithTap extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final bool isHidden;

  const CustomChipWithTap({
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
          label: Text(label),
          side: BorderSide(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

class CustomChipWithTick extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final bool isHidden;

  const CustomChipWithTick({
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
              ? CircleAvatar(
                  backgroundColor: Color(0xFFFFFFFF),
                  foregroundColor: Color(0xFFF70C493),
                  child: Icon(
                    Icons.done,
                    size: 22,
                  ),
                )
              : Container(),
          label: Text(
            label,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black54),
          ),
          backgroundColor:
              isSelected ? HexColor('#70C493') : HexColor('#EBECEF'),
        ),
      ),
    );
  }
}
