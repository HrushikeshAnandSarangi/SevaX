import 'package:flutter/material.dart';
import 'package:sevaexchange/new_baseline/models/lending_item_model.dart';
import 'package:sevaexchange/utils/utils.dart';
import 'package:sevaexchange/widgets/hide_widget.dart';

class LendingItemCardWidget extends StatelessWidget {
  final LendingItemModel? lendingItemModel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  bool hidden = false;

  LendingItemCardWidget(
      {this.lendingItemModel, this.onEdit, this.onDelete, this.hidden = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 92,
            height: 62,
            child: Image.network(lendingItemModel!.itemImages![0]),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              lendingItemModel!.itemName!,
              style: TextStyle(
                fontSize: 16,
                //fontWeight: FontWeight.bold,
                fontFamily: 'Europa',
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 3,
          ),
          HideWidget(
            hide: hidden,
            child: InkWell(
              onTap: onEdit,
              child: Icon(
                Icons.edit,
                color: HexColor('#606670'),
              ),
            ),
            secondChild: SizedBox.shrink(),
          ),
          SizedBox(
            width: 8,
          ),
          HideWidget(
            hide: hidden,
            child: InkWell(
              onTap: onDelete,
              child: Icon(
                Icons.cancel_rounded,
                color: HexColor('#BEBEBE'),
              ),
            ),
            secondChild: SizedBox.shrink(),
          )
        ],
      ),
    );
  }

  Widget title(String title) {
    return Text(title,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Europa',
          color: HexColor('#9B9B9B'),
        ));
  }
}
